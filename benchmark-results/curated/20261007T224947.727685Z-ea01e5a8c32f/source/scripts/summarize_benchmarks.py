"""Verify schema-v2 captures and summarize every repetition into CSV and Markdown."""

import argparse
import csv
import json
import math
from pathlib import Path
import statistics

from run_benchmarks import digest, validate_results, validate_implementation_manifest


def summarize(folder):
    metadata = json.loads((folder / "metadata.json").read_text())
    if metadata["schema_version"] != 2 or metadata["status"] != "complete":
        raise ValueError(f"Not a complete schema-v2 capture: {folder}")
    if digest(folder / "results.json") != metadata["results_sha256"]:
        raise ValueError(f"Combined result hash mismatch: {folder}")
    for name, expected in metadata["source_sha256"].items():
        if digest(folder / "source" / name) != expected:
            raise ValueError(f"Source snapshot hash mismatch: {name}")
    combined = json.loads((folder / "results.json").read_text())
    manifest = validate_implementation_manifest(metadata["protocol"]["implementations"])
    tiles = metadata["protocol"].get("tiles_BM_BK_BN", {})
    if (not isinstance(tiles, dict) or any(key not in manifest for key in tiles)
            or any(not isinstance(value, list) or len(value) != 3
                   or any(type(x) is not int or x <= 0 for x in value)
                   for value in tiles.values())):
        raise ValueError("Invalid tile manifest")
    captures = [item["implementation"] for item in metadata["implementation_captures"]]
    if len(captures) != len(set(captures)) or set(captures) != set(manifest):
        raise ValueError("Capture implementations differ from manifest")
    if captures != metadata["protocol"]["implementation_order"]:
        raise ValueError("Capture order differs from protocol")
    raw_rows = []
    for capture in metadata["implementation_captures"]:
        path = folder / capture["results_file"]
        if digest(path) != capture["results_sha256"]:
            raise ValueError(f"Raw result hash mismatch: {path}")
        raw = json.loads(path.read_text())
        if raw["context"] != combined["contexts"][capture["implementation"]]:
            raise ValueError("Combined context differs from raw context")
        validate_results(raw["benchmarks"], metadata["protocol"]["repetitions"],
                         [capture["implementation"]], metadata["protocol"]["shapes_M_K_N"],
                         manifest=manifest)
        raw_rows.extend(raw["benchmarks"])
    if raw_rows != combined["benchmarks"]:
        raise ValueError("Combined result differs from raw results")
    repetitions = metadata["protocol"]["repetitions"]
    shapes = metadata["protocol"]["shapes_M_K_N"]
    validation = validate_results(raw_rows, repetitions, shapes=shapes, manifest=manifest)
    if validation["measurement_rows"] != metadata["measurement_rows"]:
        raise ValueError("Metadata measurement count differs from raw results")
    summaries = []
    for m, k, n in shapes:
        pair = []
        for implementation, prefix in manifest.items():
            name = f"{prefix}/M:{m}/K:{k}/N:{n}"
            rows = [r for r in raw_rows if r.get("run_type") == "iteration" and r["name"] == name]
            times = [r["cpu_time"] for r in rows]
            # Verify throughput and the framework aggregates independently.
            for row in rows:
                expected = 2 * m * k * n / (1000 * row["cpu_time"])
                if not math.isclose(row["GFLOPS"], expected, rel_tol=1e-9):
                    raise ValueError(f"GFLOPS formula mismatch: {name}")
            median = statistics.median(times)
            cv = statistics.stdev(times) / statistics.mean(times)
            for aggregate_name, expected in (("median", median), ("cv", cv)):
                aggregate = next(r for r in raw_rows if r.get("run_type") == "aggregate"
                                 and r.get("run_name") == name
                                 and r.get("aggregate_name") == aggregate_name)
                if not math.isclose(aggregate["cpu_time"], expected, rel_tol=1e-8, abs_tol=1e-12):
                    raise ValueError(f"Aggregate mismatch: {name}/{aggregate_name}")
            pair.append({
                "run": folder.name, "implementation": implementation,
                "M": m, "K": k, "N": n, "repetitions": len(rows),
                "storage_bytes": 4 * (m * k + k * n + m * n),
                "reference_B_stride_bytes": 4 * n,
                "median_cpu_us": median, "cpu_cv_percent": 100 * cv,
                "min_cpu_us": min(times), "max_cpu_us": max(times),
                "median_gflops": statistics.median(r["GFLOPS"] for r in rows),
                "median_real_us": statistics.median(r["real_time"] for r in rows),
                "max_real_cpu_ratio": max(r["real_time"] / r["cpu_time"] for r in rows),
            })
        by_name = {row["implementation"]: row for row in pair}
        for row in pair:
            # Keep the historical column for the Step 7 chart.
            row["reference_over_ikj_cpu_speedup"] = (by_name["reference"]["median_cpu_us"]
                                                        / by_name["ikj"]["median_cpu_us"])
            row["reference_over_variant_cpu_speedup"] = (by_name["reference"]["median_cpu_us"]
                                                           / row["median_cpu_us"])
            row["ikj_over_variant_cpu_speedup"] = (by_name["ikj"]["median_cpu_us"]
                                                     / row["median_cpu_us"])
            tile = metadata["protocol"].get("tiles_BM_BK_BN", {}).get(row["implementation"])
            row["tiles_BM_BK_BN"] = "x".join(map(str, tile)) if tile else ""
        summaries.extend(pair)
    return summaries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("runs", nargs="+", type=Path)
    parser.add_argument("--csv", required=True, type=Path)
    args = parser.parse_args()
    all_rows = []
    for folder in args.runs:
        rows = summarize(folder)
        all_rows.extend(rows)
        print(f"\n### {folder.name}\n")
        print("| (M,K,N) | Implementation | CPU µs | CV % | GFLOP/s | Reference / variant | ikj / variant |")
        print("|---|---|---:|---:|---:|---:|---:|")
        for row in rows:
            shape = f"({row['M']},{row['K']},{row['N']})"
            print(f"| {shape} | {row['implementation']} | {row['median_cpu_us']:.6f} "
                  f"| {row['cpu_cv_percent']:.2f} | {row['median_gflops']:.3f} "
                  f"| {row['reference_over_variant_cpu_speedup']:.3f}× "
                  f"| {row['ikj_over_variant_cpu_speedup']:.3f}× |")
    with args.csv.open("w", newline="") as output:
        writer = csv.DictWriter(output, fieldnames=list(all_rows[0]))
        writer.writeheader()
        writer.writerows(all_rows)


if __name__ == "__main__":
    main()