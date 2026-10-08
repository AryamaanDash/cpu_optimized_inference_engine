"""Collector regression tests; no benchmark execution or macOS probes required."""

import copy
import json
import tempfile
from unittest.mock import patch
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from run_benchmarks import IMPLEMENTATIONS, SHAPES, MEMORY_ACCESS_SHAPES, validate_results, BLOCKING_IMPLEMENTATIONS, BLOCKING_SHAPES, ordered_implementations, digest

from summarize_benchmarks import summarize


class ResultValidationTests(unittest.TestCase):
    def setUp(self):
        self.rows = [
            {"name": f"{name}/M:{m}/K:{k}/N:{n}", "run_type": "iteration",
             "threads": 1, "repetitions": 2, "repetition_index": repetition,
             "iterations": 100, "cpu_time": 1.0, "real_time": 1.1,
             "time_unit": "us", "GFLOPS": 1.0}
            for name in IMPLEMENTATIONS.values() for m, k, n in SHAPES
            for repetition in range(2)
        ]

    def test_two_implementations_with_shared_shapes(self):
        result = validate_results(self.rows, 2)
        self.assertEqual(result["measurement_rows"], 28)
        self.assertEqual(len(result["case_order"]), 14)

    def test_single_capture_then_complete_comparison(self):
        first = self.rows[:14]
        self.assertEqual(validate_results(first, 2, ["reference"])["measurement_rows"], 14)
        with self.assertRaisesRegex(RuntimeError, "Missing benchmark cases"):
            validate_results(first, 2)

    def test_missing_shape(self):
        with self.assertRaisesRegex(RuntimeError, "Missing benchmark cases"):
            validate_results(self.rows[2:], 2)

    def test_missing_repetition(self):
        with self.assertRaisesRegex(RuntimeError, "repetition counts"):
            validate_results(self.rows[1:], 2)

    def test_duplicate_repetition(self):
        self.rows[1] = copy.deepcopy(self.rows[0])
        with self.assertRaisesRegex(RuntimeError, "duplicate repetition"):
            validate_results(self.rows, 2)

    def test_wrong_repetition_settings(self):
        with self.assertRaisesRegex(RuntimeError, "repetition"):
            validate_results(self.rows, 3)

    def test_bad_measurements(self):
        for field, value in (("cpu_time", float("nan")), ("GFLOPS", float("inf")),
                             ("real_time", 0), ("threads", 2), ("time_unit", "ns"),
                             ("iterations", 0), ("error_occurred", True),
                             ("name", "unknown/M:1/K:1/N:1"),
                             ("name", f"{IMPLEMENTATIONS['reference']}/M:9/K:9/N:9")):
            with self.subTest(field=field, value=value):
                rows = copy.deepcopy(self.rows)
                rows[0][field] = value
                with self.assertRaises(RuntimeError):
                    validate_results(rows, 2)

    def test_aggregate_rows_do_not_count_as_repetitions(self):
        rows = self.rows + [{"run_type": "aggregate", "name": "summary"}]
        self.assertEqual(validate_results(rows, 2)["measurement_rows"], 28)

    def test_memory_access_suite_and_saved_shape_manifest(self):
        rows = [dict(self.rows[0], name=f"{prefix}/M:{m}/K:{k}/N:{n}",
                     repetition_index=index)
                for prefix in IMPLEMENTATIONS.values()
                for m, k, n in MEMORY_ACCESS_SHAPES for index in range(2)]
        manifest = [list(shape) for shape in MEMORY_ACCESS_SHAPES]
        self.assertEqual(validate_results(rows, 2, shapes=manifest)["measurement_rows"], 4 * len(MEMORY_ACCESS_SHAPES))
        with self.assertRaisesRegex(RuntimeError, "Unexpected benchmark case"):
            validate_results(rows, 2)
        with self.assertRaisesRegex(RuntimeError, "Missing benchmark cases"):
            validate_results(rows[2:], 2, shapes=manifest)
        # Historical captures still validate against their own seven-shape manifest.
        self.assertEqual(validate_results(self.rows, 2, shapes=SHAPES)["measurement_rows"], 28)

    def test_invalid_shape_manifest(self):
        for shapes in ([], [(1, 1, 1), (1, 1, 1)], [(0, 1, 1)], [(1, 1)], [(1.0, 1, 1)]):
            with self.subTest(shapes=shapes), self.assertRaisesRegex(RuntimeError, "Expected shapes"):
                validate_results(self.rows, 2, shapes=shapes)

    def test_blocking_manifest_and_missing_candidate(self):
        rows = [dict(self.rows[0], name=f"{prefix}/M:{m}/K:{k}/N:{n}", repetition_index=i)
                for prefix in BLOCKING_IMPLEMENTATIONS.values()
                for m, k, n in BLOCKING_SHAPES for i in range(2)]
        result = validate_results(rows, 2, shapes=BLOCKING_SHAPES, manifest=BLOCKING_IMPLEMENTATIONS)
        self.assertEqual(result["measurement_rows"], 150)
        with self.assertRaisesRegex(RuntimeError, "Missing benchmark cases"):
            validate_results(rows[:-30], 2, shapes=BLOCKING_SHAPES, manifest=BLOCKING_IMPLEMENTATIONS)
        for manifest in ({}, {"a": "Same", "b": "Same"}, {"a": "bad/name"}):
            with self.assertRaisesRegex(RuntimeError, "implementation manifest"):
                validate_results(rows, 2, manifest=manifest)

    def test_execution_order(self):
        keys = list(BLOCKING_IMPLEMENTATIONS)
        self.assertEqual(ordered_implementations(BLOCKING_IMPLEMENTATIONS, "ikj-first"), keys[::-1])
        self.assertEqual(ordered_implementations(BLOCKING_IMPLEMENTATIONS, ",".join(keys[2:] + keys[:2])), keys[2:] + keys[:2])
        for order in ("reference", "reference,reference", "unknown"):
            with self.assertRaises(ValueError):
                ordered_implementations(BLOCKING_IMPLEMENTATIONS, order)

    def test_saved_manifest_summary_and_integrity(self):
        # A future/renamed candidate proves summaries do not use today's registry.
        manifest = {**IMPLEMENTATIONS, "future_tile": "FutureKernel"}
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            raw_rows, captures, contexts = [], [], {}
            for index, (key, prefix) in enumerate(manifest.items()):
                name = f"{prefix}/M:1/K:1/N:1"
                cpu = float(index + 1)
                rows = [dict(self.rows[0], name=name, repetition_index=i,
                             cpu_time=cpu, GFLOPS=2 / (1000 * cpu)) for i in range(2)]
                rows += [dict(run_type="aggregate", run_name=name, aggregate_name="median", cpu_time=cpu),
                         dict(run_type="aggregate", run_name=name, aggregate_name="cv", cpu_time=0)]
                path = folder / f"{key}.json"
                path.write_text(json.dumps({"context": {}, "benchmarks": rows}))
                captures.append({"implementation": key, "results_file": path.name, "results_sha256": digest(path)})
                contexts[key] = {}
                raw_rows.extend(rows)
            result_path = folder / "results.json"
            result_path.write_text(json.dumps({"contexts": contexts, "benchmarks": raw_rows}))
            metadata = {"schema_version": 2, "status": "complete", "source_sha256": {},
                        "results_sha256": digest(result_path), "measurement_rows": 6,
                        "implementation_captures": captures,
                        "protocol": {"implementations": manifest, "implementation_order": list(manifest),
                                     "repetitions": 2, "shapes_M_K_N": [[1, 1, 1]],
                                     "tiles_BM_BK_BN": {"future_tile": [3, 5, 7]}}}
            (folder / "metadata.json").write_text(json.dumps(metadata))
            rows = summarize(folder)
            self.assertEqual(rows[-1]["tiles_BM_BK_BN"], "3x5x7")
            self.assertAlmostEqual(rows[-1]["ikj_over_variant_cpu_speedup"], 2 / 3)
            metadata["protocol"]["tiles_BM_BK_BN"]["future_tile"] = [0, 5, 7]
            (folder / "metadata.json").write_text(json.dumps(metadata))
            with self.assertRaisesRegex(ValueError, "tile manifest"):
                summarize(folder)
            result_path.write_text("tampered")
            with self.assertRaisesRegex(ValueError, "hash mismatch"):
                summarize(folder)

    def test_historical_capture_survives_registry_extension(self):
        folder = Path(__file__).resolve().parents[1] / "benchmark-results/curated/20260922T174459.417805Z-4e6663560d49"
        with patch("run_benchmarks.IMPLEMENTATIONS", BLOCKING_IMPLEMENTATIONS):
            rows = summarize(folder)
        self.assertEqual(len(rows), 48)
        self.assertEqual({row["implementation"] for row in rows}, {"reference", "ikj"})


if __name__ == "__main__":
    unittest.main()
