# Saving a reproducible benchmark run

From the repository root on macOS, run:

```sh
python3 scripts/run_benchmarks.py --notes "Describe other heavy apps and relevant conditions"
```

The script configures a Release build with compile-command export, rebuilds,
runs CTest, then measures all registered shapes with 0.5 seconds of warm-up,
at least 1 second of measurement per repetition, and 5 repetitions. It does
not edit CMakeLists.txt. Use `--warmup`, `--min-time`, `--repetitions`, or
`--build-dir` to override these defaults. Inherited `BENCHMARK_*` environment
settings are removed for this run so they cannot silently change the protocol.

Each invocation creates a unique directory under `benchmark-results/local/`:

- `results.json`: unmodified Google Benchmark output, including individual
  repetition measurements and aggregate statistics.
- `metadata.json`: full commit, dirty state, source hashes, compiler version,
  build configuration, dependency version and commit, machine and power data,
  input generation, timing scope, measured shapes, settings, and exact commands.
- `compile_commands.json`: generated compiler invocations for the engine,
  benchmark executable, tests, and Google Benchmark dependency.
- `source/` and `working-tree.patch`: source snapshot and tracked changes
  relative to the recorded commit, so dirty runs are not attributed to HEAD alone.
- `configure.log`, `build.log`, `tests.log`, `benchmark.log`: command output,
  including any warnings from the benchmark framework.

The current input generator has **no random seed**. It uses fixed formulas:
`A[i] = float(int(i % 17) - 8) / 8.0f` and
`B[i] = float(int(i % 13) - 6) / 6.0f`. The metadata records a null seed and
these formulas. Keep the protocol description in the script synchronized if
you change input generation, timing scope, threading, or the GFLOPS formula.
Shapes are extracted from the actual result names rather than copied manually.

Timing includes output allocation, zero-initialization, multiplication, and
destruction. Input preparation is excluded. Inputs are reused, caches are not
flushed, and execution uses one benchmark thread with no CPU affinity pinning.
GFLOPS uses the conventional `2*M*K*N` count and the default CPU-time basis.
Wall-clock latency is also present in the raw output. This is allocation-inclusive
throughput, not a hardware peak measurement.

Power source, macOS power settings, thermal status, and system load are sampled
before and after measurement. Unavailable fields contain null plus the probe
error; user conditions not supplied through `--notes` are marked unreported.
The script does not change power settings or stop background applications.
On Apple Silicon, Google Benchmark may report unreliable CPU frequency metadata;
retain the warning log and use the separately collected chip/model information.

For a curated baseline, commit the intended benchmark and metadata tooling first,
then run the script again. A dirty run is useful for development, but its commit
alone does not identify the measured source. Review the generated metadata and
copy the complete desired run folder into `benchmark-results/curated/` if you
want it versioned. Local runs are ignored; curated runs are not. Prior files
under `benchmark-results/` are excluded from source snapshots.

Reproduction means using the recorded source, dependency revision, compiler,
flags, benchmark settings, and comparable machine/power conditions. It does
not guarantee identical timings. Compare separate runs before declaring a
performance change; a run captured here is not itself a repeatability study.
