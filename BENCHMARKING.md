# Saving a reproducible benchmark run

**Roadmap Step 5 is complete.** The follow-up pair C–D below establishes an
allocation-inclusive, single-thread FP32 baseline on this Mac: median CPU times
agree within 1.39% across all seven shapes, with within-run CV at most 1.14%.
This is observed repeatability under the recorded conditions, not a guarantee
for other sessions or a threshold for declaring small speedups. Step 6 is
profiling and compiler inspection.

From the repository root on macOS, run:

```sh
python3 scripts/run_benchmarks.py --notes "Describe other heavy apps and relevant conditions"
```

The script configures a Release build with compile-command export, rebuilds,
runs CTest, then measures both implementations across all seven shapes with 0.5 seconds of warm-up,
at least 1 second of measurement per repetition, and 5 repetitions. It does
not edit CMakeLists.txt. Use `--warmup`, `--min-time`, `--repetitions`, or
`--build-dir` to override these defaults. Use `--implementation-order reference-first`
(the default) followed by `--implementation-order ikj-first` for a counterbalanced
pair. Each implementation runs in its own process, with sequential repetitions
in shape registration order; inherited random-interleaving settings are disabled.
Use `--prevent-idle-sleep` to wrap each timed process in `caffeinate -i`, a
temporary assertion released when that process exits. This does not change saved
power settings or prevent lid-close/explicit sleep. The choice is recorded in metadata.
Inherited `BENCHMARK_*` environment
settings are removed for this run so they cannot silently change the protocol.

Each invocation creates a unique directory under `benchmark-results/local/`:

- `results-reference.json` and `results-ikj.json`: unmodified Google Benchmark
  output, including individual repetitions, aggregate statistics, and context.
- `results.json`: a combined view of both raw files, with separate `contexts`
  and a concatenated `benchmarks` list. Schema-version-2 metadata records this
  distinction and hashes all three files; earlier curated runs retain their original format.
- `metadata.json`: full commit, dirty state, source hashes, compiler version,
  build configuration, dependency version and commit, machine and power data,
  input generation, timing scope, measured shapes, settings, and exact commands.
- `compile_commands.json`: generated compiler invocations for the engine,
  benchmark executable, tests, and Google Benchmark dependency.
- `source/` and `working-tree.patch`: source snapshot and tracked changes
  relative to the recorded commit, so dirty runs are not attributed to HEAD alone.
- `configure.log`, `build.log`, `tests.log`, `benchmark-reference.log`, and
  `benchmark-ikj.log`: command output,
  including any warnings from the benchmark framework.

The current input generator has **no random seed**. It uses fixed formulas:
`A[i] = float(int(i % 17) - 8) / 8.0f` and
`B[i] = float(int(i % 13) - 6) / 6.0f`. The metadata records a null seed and
these formulas. Keep the protocol description in the script synchronized if
you change input generation, timing scope, threading, or the GFLOPS formula.
The collector validates each implementation/shape pair against an explicit
expected set, including repetition indices, single-thread execution, positive finite
timings and throughput. Keep `SHAPES` in the collector synchronized with benchmark
registrations when expanding the experiment. Missing whole cases are errors.

Timing includes output allocation, zero-initialization, multiplication, and
destruction. Input preparation is excluded. Inputs are reused, caches are not
flushed, and execution uses one benchmark thread with no CPU affinity pinning.
GFLOPS uses the conventional `2*M*K*N` count and the default CPU-time basis.
Wall-clock latency is also present in the raw output. This is allocation-inclusive
throughput, not a hardware peak measurement.

Power source, macOS power settings, thermal status, system load, and process
executable names/CPU usage (without command arguments) are sampled
before and after measurement, including each implementation capture. Unavailable fields contain null plus the probe
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
performance change; an individual capture is not itself a repeatability study.

## Initial repeatability comparison — September 13, 2026 (PDT)

The initial pair A–B compares the same implementation in separate process
invocations. Both completed successfully, each recorded 35 measurements across
seven shapes, and both saved CTest logs show all three tests passing. Their
median differences and within-run variability are large enough that these runs
are an initial comparison, not yet a stable baseline for small performance claims.

### Saved evidence

| Run | Run folder | Capture interval (UTC, September 14) |
|---|---|---|
| A | `20260914T025158.557814Z-f06433366a6f` | 02:51:58–02:52:59 |
| B | `20260914T025345.329545Z-f06433366a6f` | 02:53:45–02:54:45 |

- Run A: [raw results](benchmark-results/curated/20260914T025158.557814Z-f06433366a6f/results.json),
  [metadata and exact commands](benchmark-results/curated/20260914T025158.557814Z-f06433366a6f/metadata.json),
  [compiler invocations](benchmark-results/curated/20260914T025158.557814Z-f06433366a6f/compile_commands.json),
  [test log](benchmark-results/curated/20260914T025158.557814Z-f06433366a6f/tests.log),
  [benchmark log](benchmark-results/curated/20260914T025158.557814Z-f06433366a6f/benchmark.log).
- Run B: [raw results](benchmark-results/curated/20260914T025345.329545Z-f06433366a6f/results.json),
  [metadata and exact commands](benchmark-results/curated/20260914T025345.329545Z-f06433366a6f/metadata.json),
  [compiler invocations](benchmark-results/curated/20260914T025345.329545Z-f06433366a6f/compile_commands.json),
  [test log](benchmark-results/curated/20260914T025345.329545Z-f06433366a6f/tests.log),
  [benchmark log](benchmark-results/curated/20260914T025345.329545Z-f06433366a6f/benchmark.log).

All four comparison runs A–D have been copied to `benchmark-results/curated/`
for version control. The original local captures remain intact. Raw results,
metadata, logs, and source snapshots are preserved byte-for-byte; metadata
commands retain their original local output paths. Read each curated folder's
`results.json` for its copied data. The ignore rules explicitly allow curated
compile-command files so actual flags can accompany the evidence in Git.

### Comparability checks

- Both runs recorded clean commit `f06433366a6f3687d1a936031b1da0e95536ba89`,
  unchanged at the end of each capture.
- Source hash manifests match between runs, and the saved source files match
  their hashes. Each raw results file also matches its recorded SHA-256 hash.
- Both recorded executable SHA-256
  `a8b277831bbbb0b68020bc7f45489a26f6c6933c59a4f98f75b73f295beb3938`.
- Build metadata match, and the saved compile-command files are byte-identical.
  Both use Release, Apple Clang 21.0.0 (`clang-2100.0.123.102`), CMake 4.2.3,
  and Unix Makefiles. Engine and benchmark compilation includes
  `-O3 -DNDEBUG -std=gnu++20 -arch arm64`; full commands are preserved above.
- Both use unmodified Google Benchmark v1.9.4 at
  `eddb0241389718a23a42db6af5f0164b6e0139af`.
- Hardware and OS match: Apple M3 Pro, Mac15,6, arm64, 11 logical CPUs,
  19,327,352,832 bytes of RAM (18 GiB), macOS 26.6.2 build 25G83.
- Protocols match: one benchmark thread, 0.5 seconds of warm-up, a 1-second
  minimum measurement time per repetition, and five repetitions per shape.
  Inputs, allocation-inclusive timing scope, and CPU-time GFLOPS basis are
  those described earlier in this document.
- Before/after snapshots show battery power for both runs, with Low Power Mode
  disabled. Battery charge changed from 77% to 76% in A and 76% to 75% in B.

The older captures `20260913T005958.257650Z-ffdefc59881b` and
`20260913T071449.366296Z-d5fff452d2cc` remain development evidence. Both recorded
dirty trees, and their power sources differed (AC versus battery); they are not
included in this comparison table.

### Measured results

CPU times below are medians of the five per-repetition averages, in microseconds.
CV is the sample standard deviation divided by the mean of those five averages,
expressed as a percentage. The raw JSON stores CV as a fraction, so it is
multiplied by 100 here. These are not individual-call tail-latency statistics.
Medians and CVs were recomputed from the individual measurements and checked
against Google Benchmark's aggregates.

`Change % = 100 × (B median CPU time − A median CPU time) / A median CPU time`.
A positive change means B took longer. GFLOP/s columns are the saved median
throughput aggregates, including allocation and cleanup costs.

| Shape (M, K, N) | A CPU µs | B CPU µs | Change | A CV | B CV | A GFLOP/s | B GFLOP/s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| (1, 1, 1) | 0.022202 | 0.023286 | +4.88% | 1.02% | 0.67% | 0.090 | 0.086 |
| (32, 32, 32) | 11.269936 | 11.739656 | +4.17% | 5.07% | 2.24% | 5.815 | 5.582 |
| (128, 128, 128) | 1155.904800 | 1201.685321 | +3.96% | 1.42% | 1.01% | 3.629 | 3.490 |
| (256, 256, 256) | 11636.934959 | 12089.544715 | +3.89% | 1.10% | 1.05% | 2.883 | 2.775 |
| (63, 65, 67) | 117.714834 | 119.355137 | +1.39% | 19.46% | 1.55% | 4.662 | 4.597 |
| (1, 256, 256) | 50.578144 | 52.713403 | +4.22% | 4.09% | 7.35% | 2.591 | 2.487 |
| (256, 256, 1) | 28.805866 | 26.751641 | -7.13% | 2.87% | 5.64% | 4.550 | 4.900 |

### Interpretation and remaining work

Six of seven shapes took longer in B; the median changes span -7.13% to +4.88%.
Because the executable is identical, these differences cannot represent an
implementation improvement or regression. Even the 128- and 256-square cases,
whose within-run CVs are around 1%, differ by approximately 4% between runs.
Low within-run CV alone therefore does not establish repeatability here.

The awkward rectangular case is especially variable in A: its five CPU averages
are 114.113, 116.124, 117.715, 138.285, and 174.815 µs, producing 19.46% CV.
All measurements are retained; the slower repetitions were not discarded.
The batch-one case also has 7.35% CV in B.

Both user-notes fields contain the literal example text
"Describe the actual background activity during this run." Actual background
applications were therefore not documented for these two captures. Earlier
notes mentioning Chrome, ChatGPT, and Spotify cannot establish what was running
during these later measurements. The sampled one-minute load averages also
changed: A 7.74 → 6.42, B 5.04 → 3.59. These observations limit the control over
conditions; they do not identify the cause of the timing differences.

The thermal probe (stored under `thermal_source`) reports no recorded thermal
or performance warning and no recorded CPU power status. That is not a continuous
temperature or frequency measurement. Both benchmark logs warn that CPU clock
rate could not be determined and thread affinity could not be set. Do not use
the displayed 24 MHz estimate as a measured chip frequency or infer cache behavior
from these timing results alone.

This initial pair motivated the follow-up below. Its observed 7.13% difference
is evidence from this pair, not a universal noise threshold or statistical
confidence bound. The initial measurements are retained alongside the follow-up.

## Follow-up baseline — September 13, 2026 (PDT)

Runs C and D were collected sequentially after the initial review. Each used
ten repetitions per shape and 1 second of warm-up; the minimum measurement
duration remained 1 second per repetition. A 20-second settling interval preceded
each capture. Both complete runs were retained without filtering any repetitions.
The pair contains 140 individual measurements in total, and all three CTest
tests passed before each benchmark invocation.

### Evidence and protocol

| Run | Curated result folder | Capture interval (UTC, September 14) |
|---|---|---|
| C | `20260914T031312.090327Z-909b26888a40` | 03:13:12–03:15:06 |
| D | `20260914T031526.195956Z-909b26888a40` | 03:15:26–03:17:19 |

- Run C: [raw results](benchmark-results/curated/20260914T031312.090327Z-909b26888a40/results.json),
  [metadata and exact commands](benchmark-results/curated/20260914T031312.090327Z-909b26888a40/metadata.json),
  [observed processes](benchmark-results/curated/20260914T031312.090327Z-909b26888a40/conditions.json),
  [compiler invocations](benchmark-results/curated/20260914T031312.090327Z-909b26888a40/compile_commands.json),
  [test log](benchmark-results/curated/20260914T031312.090327Z-909b26888a40/tests.log),
  [benchmark log](benchmark-results/curated/20260914T031312.090327Z-909b26888a40/benchmark.log).
- Run D: [raw results](benchmark-results/curated/20260914T031526.195956Z-909b26888a40/results.json),
  [metadata and exact commands](benchmark-results/curated/20260914T031526.195956Z-909b26888a40/metadata.json),
  [observed processes](benchmark-results/curated/20260914T031526.195956Z-909b26888a40/conditions.json),
  [compiler invocations](benchmark-results/curated/20260914T031526.195956Z-909b26888a40/compile_commands.json),
  [test log](benchmark-results/curated/20260914T031526.195956Z-909b26888a40/tests.log),
  [benchmark log](benchmark-results/curated/20260914T031526.195956Z-909b26888a40/benchmark.log).
- [Machine-readable comparison of both pairs](benchmark-results/curated/step5-comparison.csv).

Both runs recorded clean commit `909b26888a40358615af728f5889be3b0312a6ae`,
unchanged during capture. Their source manifests, build metadata, protocols,
and compiler invocations match, and their saved source/result hashes validate.
They used the same executable SHA-256 as A and B, shown above. Thus the new
commit records documentation work; the measured implementation did not change.
Compiler, dependency, chip, RAM, OS, input formulas, and allocation-inclusive
CPU-time measurement scope remain as recorded in the initial comparison.

The same application process names were observed before both captures: Google
Chrome and helpers, ChatGPT, Spotify and helpers, Codex and helpers, and Code
Helper processes. `conditions.json` records timestamps, names, top CPU consumers,
load, and power-source snapshots before and after each capture. These observations
establish process presence, not identical app activity or tab counts. No apps
were closed or background workloads controlled. No additional assistant build
or data analysis ran concurrently with the measurements; process sampling was
limited to capture boundaries.

All four before/after machine snapshots recorded battery power and matching
power settings with Low Power Mode disabled. Charge changed from 68% to 66%
in C and 66% to 65% in D. The one-minute load averages were C 5.11 → 3.40 and
D 3.65 → 3.52. Thermal probes reported no recorded warnings and no recorded CPU
power status. The same frequency/affinity warnings described above remained.
These are measurements on an active desktop, not an isolated or pinned CPU.

### Follow-up results

Definitions match the initial table: median CPU microseconds, signed median
change from C to D, within-run CPU CV in percent, and median allocation-inclusive
GFLOP/s. All aggregates and GFLOP/s calculations were checked against the raw
measurements. No slow samples were excluded.

| Shape (M, K, N) | C CPU µs | D CPU µs | Change | C CV | D CV | C GFLOP/s | D GFLOP/s |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| (1, 1, 1) | 0.023688 | 0.023681 | -0.03% | 0.44% | 1.00% | 0.084 | 0.084 |
| (32, 32, 32) | 11.745156 | 11.736629 | -0.07% | 1.14% | 0.72% | 5.580 | 5.584 |
| (128, 128, 128) | 1247.199029 | 1258.673479 | +0.92% | 0.49% | 1.00% | 3.363 | 3.332 |
| (256, 256, 256) | 12709.417431 | 12818.680556 | +0.86% | 0.90% | 0.43% | 2.640 | 2.618 |
| (63, 65, 67) | 125.447425 | 127.082818 | +1.30% | 0.21% | 0.94% | 4.374 | 4.318 |
| (1, 256, 256) | 49.642037 | 49.212700 | -0.86% | 0.35% | 0.31% | 2.640 | 2.663 |
| (256, 256, 1) | 28.633957 | 29.030921 | +1.39% | 0.36% | 0.41% | 4.578 | 4.515 |

### Completion and use of this baseline

Step 5's exit criteria are satisfied: Release measurements cover several shapes,
the compiler/flags/machine/commit are recorded, complete raw results are saved,
and a second invocation demonstrates comparable timings under the
documented protocol. Maximum absolute median difference is 1.39%, and maximum
within-run CV is 1.14% in this pair. The baseline is the complete C–D pair, not
the fastest run or the minimum time for each shape.

The initial A–B pair remains relevant evidence of broader session variability.
C–D used longer warm-up and more repetitions, and background activity differed;
this experiment does not isolate which factor improved consistency. Some C–D
latencies are higher than A–B despite the identical executable. Do not describe
that change as a code regression or discard C–D in favor of faster historical
numbers. The measured 1.39% is not a confidence interval or universal noise floor.

For future optimizations, use the follow-up settings below for both the reference
and changed implementation in comparable conditions, retain repetitions, and
repeat the comparison. Changes comparable to the observed variation require
more evidence; do not claim a speedup from one faster measurement.

```sh
python3 scripts/run_benchmarks.py \
  --warmup 1 \
  --min-time 1 \
  --repetitions 10 \
  --notes "Record the applications and workload actually present for this run"
```

Replace the notes text with observed conditions. Step 6's profile findings,
compiler inspection, and testable hypothesis are documented in
[PROFILING.md](PROFILING.md). The next experiment is step 7's controlled
loop-order comparison, using this unprofiled baseline methodology.

## Step 7 loop-order comparison

Both kernels now share one compile-time-parameterized benchmark harness, with
identical input generation, allocation scope, barriers, counters, and shape list.
The reference name is preserved. Function selection introduces no per-iteration
function-pointer dispatch. The parser regression tests run through CTest when
benchmarks are enabled, or directly with `python3 tests/benchmark_results_tests.py`.

Use two complete captures and retain their source snapshots even for dirty trees:

```sh
python3 scripts/run_benchmarks.py --warmup 1 --min-time 1 --repetitions 10 --prevent-idle-sleep \
  --implementation-order reference-first --notes "Actual observed conditions"
python3 scripts/run_benchmarks.py --warmup 1 --min-time 1 --repetitions 10 --prevent-idle-sleep \
  --implementation-order ikj-first --notes "Actual observed conditions"
```

Each capture includes 140 individual measurements. This yields implementation
order reference, ikj, ikj, reference across the pair. Counterbalancing limits
order bias but cannot eliminate changing desktop activity or thermal conditions.
See [MEMORY_ACCESS.md](MEMORY_ACCESS.md) for the hypothesis and comparison results.
