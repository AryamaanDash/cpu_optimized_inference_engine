"""Collector regression tests; no benchmark execution or macOS probes required."""

import copy
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from run_benchmarks import IMPLEMENTATIONS, SHAPES, validate_results


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


if __name__ == "__main__":
    unittest.main()
