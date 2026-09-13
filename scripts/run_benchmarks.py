"""Capture the current macOS matmul benchmark and its reproduction metadata."""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import re
import shlex
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]

def now():
    return datetime.now(timezone.utc).isoformat()

def capture(command, cwd=ROOT):
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(f"{shlex.join(command)}: {result.stderr.strip()}")
    return result.stdout.strip()

def probe(command):
    try:
        return {"value": capture(command), "error": None}
    except (OSError, RuntimeError) as error:
        return {"value": None, "error": str(error)}

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def cache_values(path):
    values = {}
    for line in path.read_text().splitlines():
        if line and not line.startswith(("//", "#")) and "=" in line:
            key, value = line.split("=", 1)
            values[key.split(":", 1)[0]] = value
    return values

def machine_state():
    return{
        "architecture": platform.machine(),
        "os": probe(["/usr/bin/sw_vers"]),
        "kernel": platform.release(),
        "chip": probe(["/usr/sbin/sysctl", "-n", "machdep.cpu.brand_string"]),
        "model": probe(["/usr/sbin/sysctl", "-n", "hw.model"]),
        "ram_bytes": probe(["/usr/sbin/sysctl", "-n", "hw.memsize"]),
        "logical_cpus": probe(["/usr/sbin/sysctl", "-n", "hw.logicalcpu"]),
        "power_settings": probe(["/usr/bin/pmset", "-g", "custom"]),
        "power_source": probe(["/usr/bin/pmset", "-g", "batt"]),
        "thermal_source": probe(["/usr/bin/pmset", "-g", "therm"]),
        "load_average": list(os.getloadavg()),
    }

def positive_seconds(value):
    value = float(value)
    if not math.isfinite(value) or value <= 0:
        raise argparse.ArgumentTypeError("Must be finite or greater than 0.")
    return value

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build-dir", type=Path, default=ROOT / "build/benchmark-release")
    parser.add_argument("--warmup", type=positive_seconds, default=0.5)
    parser.add_argument("--min-time", type=positive_seconds, default=1.0)
    parser.add_argument("--repetitions", type=int, default=5)
    parser.add_argument("--notes", default="User run conditions not reported")
    args = parser.parse_args()
    if args.repetitions < 2:
        parser.error("Use at least two repetitions")
    if sys.platform != "darwin":
        parser.error("This metadata collector currently supports macOS")

    build = args.build_dir.resolve()
    commit = capture(["git", "rev-parse", "HEAD"])
    status = capture(["git", "status", "--porcelain=v1", "--untracked-files=all"])
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    output = ROOT / "benchmark-results/local" / f"{stamp}-{commit[:12]}"
    output.mkdir(parents=True, exist_ok=False)
    metadata = {
        "schema_version": 1,
        "status": "in_progress",
        "started_at_utc": now(),
        "git": {"commit": commit, "dirty": bool(status), "status_porcelain": status},
        "commands": [],
        "run_conditions": {"user_notes": args.notes, "cpu_affinity": "Not pinned"},
        "protocol": {
            "dtype": "FP32", "layout": "contiguous row-major", "threads": 1,
            "timing_basis": "benchmark thread CPU time; wall time also reported",
            "timed": ["output allocation", "output zero-initialization", "matmul", "output destruction"],
            "excluded": ["input allocation", "input initialization", "counter reporting"],
            "input_seed": None,
            "input_generation": {
                "kind": "deterministic formulas; no random generator",
                "A_flat_i": "float(int(i % 17) - 8) / 8.0f",
                "B_flat_i": "float(int(i % 13) - 6) / 6.0f",
            },
            "cache_policy": "Reuse input buffers; warm-up enabled; no cache flushing",
            "gflops": "2*M*K*N / 1e9 / CPU_seconds_per_iteration",
            "warmup_seconds": args.warmup,
            "minimum_measurement_seconds": args.min_time,
            "repetitions": args.repetitions,
        },
    }

    def save_metadata():
        (output / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")

    environment = {k: v for k, v in os.environ.items() if not k.startswith("BENCHMARK_")}
    metadata["ignored_benchmark_environment_keys"] = sorted(set(os.environ) - set(environment))

    def run(command, log_name):
        metadata["commands"].append({"argv": command, "shell": shlex.join(command), "cwd": str(ROOT)})
        save_metadata()
        print(f"Running: {shlex.join(command)}", flush=True)
        with (output / log_name).open("w") as log:
            result = subprocess.run(command, cwd=ROOT, env=environment, stdout=log, stderr=subprocess.STDOUT)
        if result.returncode:
            raise RuntimeError(f"Command exited {result.returncode}; see {output / log_name}")

    try:
        # Preserve dirty tracked changes as a patch and all nonignored source
        # files as a snapshot, including untracked benchmark/runner files.
        patch = subprocess.check_output(["git", "diff", "--binary", "HEAD"], cwd=ROOT)
        (output / "working-tree.patch").write_bytes(patch)
        files = subprocess.check_output(
            ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=ROOT
        ).decode().split("\0")
        hashes = {}
        for name in sorted(set(files) - {""}):
            if Path(name).parts[0] == "benchmark-results":
                continue  # Prior curated runs are artifacts, not input source.
            source = ROOT / name
            if source.is_file():
                destination = output / "source" / name
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, destination)
                hashes[name] = digest(destination)
        metadata["source_sha256"] = hashes

        run(["cmake", "-S", str(ROOT), "-B", str(build), "-DCMAKE_BUILD_TYPE=Release",
             "-DINFERENCE_BUILD_BENCHMARKS=ON", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"], "configure.log")
        run(["cmake", "--build", str(build), "-j", "2"], "build.log")
        run(["ctest", "--test-dir", str(build), "--output-on-failure"], "tests.log")
        cache = cache_values(build / "CMakeCache.txt")
        shutil.copy2(build / "compile_commands.json", output / "compile_commands.json")
        binary = build / "matmul_bench"
        dependency = Path(cache["benchmark_SOURCE_DIR"])
        metadata["build"] = {
            "configuration": cache["CMAKE_BUILD_TYPE"],
            "compiler_path": cache["CMAKE_CXX_COMPILER"],
            "compiler_version": capture([cache["CMAKE_CXX_COMPILER"], "--version"]),
            "cmake_version": capture(["cmake", "--version"]),
            "generator": cache["CMAKE_GENERATOR"],
            "compile_commands_file": "compile_commands.json",
            "cache_settings": {k: v for k, v in cache.items()
                               if k.startswith(("CMAKE_CXX_FLAGS", "CMAKE_EXE_LINKER_FLAGS", "CMAKE_OSX"))
                               and not k.endswith("-ADVANCED")},
            "benchmark_dependency": {
                "version": capture(["git", "describe", "--tags", "--always"], cwd=dependency),
                "commit": capture(["git", "rev-parse", "HEAD"], cwd=dependency),
                "dirty": bool(capture(["git", "status", "--porcelain"], cwd=dependency)),
            },
            "executable_sha256": digest(binary),
        }
        metadata["machine_before"] = machine_state()
        run([str(binary), f"--benchmark_min_warmup_time={args.warmup}",
             f"--benchmark_min_time={args.min_time}s", f"--benchmark_repetitions={args.repetitions}",
             "--benchmark_report_aggregates_only=false", "--benchmark_display_aggregates_only=false",
             "--benchmark_counters_tabular=true", "--benchmark_out_format=json",
             f"--benchmark_out={output / 'results.json'}"], "benchmark.log")
        metadata["machine_after"] = machine_state()
        results = json.loads((output / "results.json").read_text())
        rows = results["benchmarks"]
        samples = [row for row in rows if row.get("run_type") == "iteration"]
        if not samples or any(row.get("error_occurred") for row in rows):
            raise RuntimeError("Benchmark produced no samples or reported an error")
        shapes = set()
        counts = {}
        for row in samples:
            match = re.search(r"/M:(\d+)/K:(\d+)/N:(\d+)", row["name"])
            if not match or row["threads"] != 1:
                raise RuntimeError("Results do not match the recorded single-thread matmul protocol")
            shape = tuple(map(int, match.groups()))
            shapes.add(shape)
            counts[shape] = counts.get(shape, 0) + 1
            if not math.isfinite(row.get("GFLOPS", float("nan"))):
                raise RuntimeError("Results are missing finite GFLOPS measurements")
        if any(count != args.repetitions for count in counts.values()):
            raise RuntimeError("Actual repetition counts differ from the recorded settings")
        metadata["protocol"]["shapes_M_K_N"] = [list(shape) for shape in sorted(shapes)]
        metadata["measurement_rows"] = len(samples)
        metadata["results_sha256"] = digest(output / "results.json")
        changed = [name for name, value in hashes.items()
                   if not (ROOT / name).is_file() or digest(ROOT / name) != value]
        metadata["git"]["commit_after"] = capture(["git", "rev-parse", "HEAD"])
        if changed or metadata["git"]["commit_after"] != commit:
            raise RuntimeError(f"Source or commit changed during capture: {changed}")
        metadata["status"] = "complete"
    except Exception as error:
        metadata["status"] = "failed"
        metadata["error"] = str(error)
        raise
    finally:
        metadata["finished_at_utc"] = now()
        save_metadata()
        print(f"Saved run: {output}", flush=True)

if __name__ == "__main__":
    main()