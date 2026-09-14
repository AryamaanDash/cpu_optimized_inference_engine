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
performance change; an individual capture is not itself a repeatability study.

## Initial repeatability comparison — September 13, 2026 (PDT)

The two newest saved runs compare the same implementation in separate process
invocations. Both completed successfully, each recorded 35 measurements across
seven shapes, and both saved CTest logs show all three tests passing. Their
median differences and within-run variability are large enough that these runs
are an initial comparison, not yet a stable baseline for small performance claims.

### Saved evidence

| Run | Local result folder | Capture interval (UTC, September 14) |
|---|---|---|
| A | `20260914T025158.557814Z-f06433366a6f` | 02:51:58–02:52:59 |
| B | `20260914T025345.329545Z-f06433366a6f` | 02:53:45–02:54:45 |

- Run A: [raw results](benchmark-results/local/20260914T025158.557814Z-f06433366a6f/results.json),
  [metadata and exact commands](benchmark-results/local/20260914T025158.557814Z-f06433366a6f/metadata.json),
  [compiler invocations](benchmark-results/local/20260914T025158.557814Z-f06433366a6f/compile_commands.json),
  [test log](benchmark-results/local/20260914T025158.557814Z-f06433366a6f/tests.log),
  [benchmark log](benchmark-results/local/20260914T025158.557814Z-f06433366a6f/benchmark.log).
- Run B: [raw results](benchmark-results/local/20260914T025345.329545Z-f06433366a6f/results.json),
  [metadata and exact commands](benchmark-results/local/20260914T025345.329545Z-f06433366a6f/metadata.json),
  [compiler invocations](benchmark-results/local/20260914T025345.329545Z-f06433366a6f/compile_commands.json),
  [test log](benchmark-results/local/20260914T025345.329545Z-f06433366a6f/tests.log),
  [benchmark log](benchmark-results/local/20260914T025345.329545Z-f06433366a6f/benchmark.log).

These folders are ignored local artifacts; the links work in this checkout but
will not accompany a Git clone unless the evidence is deliberately curated.
Raw results and metadata were left unchanged during this review.

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

Item 6 has an initial documented comparison, but a stable baseline for small
speedup claims remains to be established. Collect an additional pair of separate
runs of the same committed implementation under comparable, accurately described
conditions. Keep power source/mode fixed, let unrelated heavy activity settle,
and record actual applications or workloads in `--notes`. Append the new results
and compare all runs rather than selecting the fastest. If substantial variation
persists, investigate it and document the practical measurement limits before
claiming small improvements. The observed 7.13% difference is evidence from this
pair, not a universal noise threshold or statistical confidence bound.
