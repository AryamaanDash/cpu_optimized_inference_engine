"""Verify schema-v2 captures and summarize every repetition into CSV and Markdown."""

import argparse
import csv
import json
import math
from pathlib import Path
import statistics

from run_benchmarks import IMPLEMENTATIONS, digest, validate_results


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
    raw_rows = []
    for capture in metadata["implementation_captures"]:
        path = folder / capture["results_file"]
        if digest(path) != capture["results_sha256"]:
            raise ValueError(f"Raw result hash mismatch: {path}")
        raw = json.loads(path.read_text())
        if raw["context"] != combined["contexts"][capture["implementation"]]:
            raise ValueError("Combined context differs from raw context")
        raw_rows.extend(raw["benchmarks"])
    if raw_rows != combined["benchmarks"]:
        raise ValueError("Combined result differs from raw results")
    repetitions = metadata["protocol"]["repetitions"]
    shapes = metadata["protocol"]["shapes_M_K_N"]
    validation = validate_results(raw_rows, repetitions, shapes=shapes)
    if validation["measurement_rows"] != metadata["measurement_rows"]:
        raise ValueError("Metadata measurement count differs from raw results")
    summaries = []
    for m, k, n in shapes:
        pair = []
        for implementation, prefix in IMPLEMENTATIONS.items():
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
        speedup = pair[0]["median_cpu_us"] / pair[1]["median_cpu_us"]
        for row in pair:
            row["reference_over_ikj_cpu_speedup"] = speedup
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
        print("| (M,K,N) | Reference CPU µs | ikj CPU µs | Ref CV % | ikj CV % | Ref GFLOP/s | ikj GFLOP/s | Speedup |")
        print("|---|---:|---:|---:|---:|---:|---:|---:|")
        for reference, ikj in zip(rows[::2], rows[1::2]):
            shape = f"({reference['M']},{reference['K']},{reference['N']})"
            print(f"| {shape} | {reference['median_cpu_us']:.6f} | {ikj['median_cpu_us']:.6f} "
                  f"| {reference['cpu_cv_percent']:.2f} | {ikj['cpu_cv_percent']:.2f} "
                  f"| {reference['median_gflops']:.3f} | {ikj['median_gflops']:.3f} "
                  f"| {reference['reference_over_ikj_cpu_speedup']:.3f}× |")
    with args.csv.open("w", newline="") as output:
        writer = csv.DictWriter(output, fieldnames=list(all_rows[0]))
        writer.writeheader()
        writer.writerows(all_rows)


if __name__ == "__main__":
    main()