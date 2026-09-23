# Step 7: Memory access experiments

Status: Parts 1–5 are complete: both kernels pass correctness checks, the benchmark
collector supports both implementations, and four full captures are preserved below.
The size/vector sweeps (Part 6) and new compiler inspection (Part 7) remain pending;
Step 7 as a whole is not complete. CPU-time findings have the limitations below.

## Experiment 1: row-col-k versus row-k-col

### Question and hypothesis

For row-major FP32 matrices A[M,K] and B[K,N], does row-k-col traversal
reduce allocation-inclusive CPU time compared with row-col-k traversal?

The hypothesis is that row-k-col will improve larger N>1 workloads by accessing
B contiguously and reusing each A value across columns. The primary target,
selected before measurement, is (M,K,N) = (256,256,256). This follows the
evidence in [PROFILING.md](PROFILING.md).

The reference inner loop advances through A by 4 bytes and B by 4*N bytes
(1,024 bytes for the primary target). The proposed variant traverses B and C
rows in 4-byte steps and holds one A value for the inner column loop. It also
replaces a local dot-product accumulator and final C assignment with repeated
C updates. These are source-level patterns; inspect compiler output to establish
the actual loads, stores, and arithmetic instructions.

### Implementations and controls

Keep `matmul_reference` unchanged. Introduce a separate `matmul_ikj` function
using row-k-col traversal, a local A(row,k) value, and accumulation into the
zero-initialized output. Contributions to each output remain in increasing k order.

Hold these conditions fixed between implementations:

- Owning, contiguous row-major FP32 Matrix storage and checked `operator()` access.
- Shape validation, fresh output ownership, input immutability, empty-output
  behavior, and zero output when K=0.
- Single-thread execution, compiler version, Release flags, and floating-point options.
- Inputs: A[i] = float(int(i % 17) - 8) / 8.0f;
  B[i] = float(int(i % 13) - 6) / 6.0f.
- Timed work: output allocation, zero-initialization, multiplication, and destruction.
  Input allocation/filling stays outside timing; retain the output-use barriers.
- Reused input buffers, warm-up enabled, and no explicit cache flushing.

Do not add tiling, packing, transposition, raw-pointer kernels, explicit SIMD,
fast-math, threading, or shape-based dispatch in this experiment. Normal compiler
auto-vectorization remains enabled equally for both implementations.

### Workloads and protocol

Measure both implementations for every existing shape:

| M | K | N | Purpose |
|---:|---:|---:|---|
| 1 | 1 | 1 | Tiny-call overhead control |
| 32 | 32 | 32 | Small square |
| 128 | 128 | 128 | Medium square |
| 256 | 256 | 256 | Primary target from Step 6 |
| 63 | 65 | 67 | Awkward rectangular dimensions |
| 1 | 256 | 256 | Row-vector times matrix |
| 256 | 256 | 1 | Matrix times column-vector; contiguous reference B access |

Both implementations have hand-computed and independent double-precision oracle
coverage, including all benchmark shapes and reductions up to K=1025. The error
bound and Debug, Release, and sanitizer commands are documented in
[TESTING.md](TESTING.md). These checks must pass before measurement.

The collector validates repetitions by implementation and shape, requires all
14 expected cases, and rejects duplicate/missing repetitions and invalid timings.
Eight parser regression tests run through CTest with benchmarks enabled.

Use the [Step 5 follow-up protocol](BENCHMARKING.md): 1-second warm-up, at least
1 second per repetition, and 10 repetitions per implementation/shape. Collect
at least two complete comparisons without Instruments, measuring the reference
again in the same session. Record execution order and counterbalance or interleave
implementations to limit order bias. Record actual background activity, power and
thermal observations, compiler flags, source revision/dirty state, and commands.
Retain all repetitions, source snapshots, metadata, and logs.

### Analysis and decision

For every shape and capture, report median CPU time, variability (including CV),
GFLOP/s, and speedup = reference median / variant median. Compare within-run
variation and agreement across captures. Historical C-D measurements provide
context, not a substitute for the current reference or a universal 1.39% cutoff.

Consistently lower time on the primary target, distinguishable from observed
variation, supports the hypothesis. Noisy results are inconclusive and require
more evidence. Consistent equal or higher time fails to support the hypothesis.
Report all shapes and regressions without selecting only winning cases.

Inspect vectorization diagnostics and assembly for both variants, including
N=1 and N>1 paths. Explain results using observed instructions and access patterns.
Timing alone cannot prove cache misses, bandwidth saturation, cache capacity,
or improvement caused exclusively by locality: vectorization, accumulator
dependencies, and C traffic may also change.

Keep or reject the experimental variant based on correctness and measured
workload tradeoffs, preserving the reference and evidence either way. Follow
this first comparison with matrix-vector and size sweeps before declaring
the broader Step 7 milestone complete.


## Parts 4–5 results — September 21, 2026

The primary CPU-time hypothesis is supported in these measurements: `ikj` has
lower median CPU time for (256,256,256) in every capture, with C–D speedups of
9.590× and 9.710×. For (256,256,1), it is consistently much slower: 6.891× and
7.006× the reference time in C–D. Keep both implementations; these results do
not justify replacing the reference universally or introducing dispatch yet.

### Saved evidence and comparability

The first pair A–B used opposite implementation orders. Large wall-time gaps
and noisy CPU timings prompted a complete follow-up pair C–D using a temporary
`caffeinate -i` assertion during each benchmark process. No saved power settings
were changed. All four captures contain 140 individual measurements, for **560
measurements retained without filtering**. The incomplete short collector check
in `benchmark-results/local/20260921T204833.043502Z-603cc7838199` is development
evidence only: source-integrity validation rejected it because BENCHMARKING.md
was edited during that check. It is not included in the performance comparison.

| Run | Implementation order | UTC capture interval | Prevent idle sleep |
|---|---|---|---|
| A | reference → ikj | 20:48:55–21:54:41 | No |
| B | ikj → reference | 21:55:15–22:22:49 | No |
| C | reference → ikj | 22:24:22–22:44:46 | Yes |
| D | ikj → reference | 22:45:00–22:48:47 | Yes |

- Run A: [metadata, conditions, commands, and hashes](benchmark-results/curated/20260921T204855.055031Z-603cc7838199/metadata.json), [raw reference](benchmark-results/curated/20260921T204855.055031Z-603cc7838199/results-reference.json), [raw ikj](benchmark-results/curated/20260921T204855.055031Z-603cc7838199/results-ikj.json), [test log](benchmark-results/curated/20260921T204855.055031Z-603cc7838199/tests.log).
- Run B: [metadata, conditions, commands, and hashes](benchmark-results/curated/20260921T215515.158071Z-603cc7838199/metadata.json), [raw reference](benchmark-results/curated/20260921T215515.158071Z-603cc7838199/results-reference.json), [raw ikj](benchmark-results/curated/20260921T215515.158071Z-603cc7838199/results-ikj.json), [test log](benchmark-results/curated/20260921T215515.158071Z-603cc7838199/tests.log).
- Run C: [metadata, conditions, commands, and hashes](benchmark-results/curated/20260921T222422.044823Z-603cc7838199/metadata.json), [raw reference](benchmark-results/curated/20260921T222422.044823Z-603cc7838199/results-reference.json), [raw ikj](benchmark-results/curated/20260921T222422.044823Z-603cc7838199/results-ikj.json), [test log](benchmark-results/curated/20260921T222422.044823Z-603cc7838199/tests.log).
- Run D: [metadata, conditions, commands, and hashes](benchmark-results/curated/20260921T224500.033105Z-603cc7838199/metadata.json), [raw reference](benchmark-results/curated/20260921T224500.033105Z-603cc7838199/results-reference.json), [raw ikj](benchmark-results/curated/20260921T224500.033105Z-603cc7838199/results-ikj.json), [test log](benchmark-results/curated/20260921T224500.033105Z-603cc7838199/tests.log).

The complete folders also preserve original logs, compiler commands, source
snapshots, patches, and combined results. Curated copies are byte-identical to
local captures. Source manifests match within A–B and within C–D. Between pairs,
only BENCHMARKING.md and the collector changed (sleep-prevention option and full
process names). Compiler commands, build metadata, benchmark/kernel sources,
and executable hashes match across all four captures.

All runs recorded dirty commit `603cc7838199ee1267ff3ae83e8ad404177b4e1a`;
the commit alone does not identify the measured implementation. Use each saved
source snapshot and patch. The executable SHA-256 is
`3d92d587b597edb0e495d4103a7f3f0f084df6a30167ffd2c7fc8f49c581736e`.
The report and summarizer were added after capture; measured source copies are
left unchanged. All four CTest targets passed before each capture, including
the eight collector regression tests.

Machine: Apple M3 Pro, Mac15,6, arm64, 11 logical CPUs, 18 GiB RAM;
macOS 26.6.2 (25G83). Compiler: Apple Clang 21.0.0 (`clang-2100.0.123.102`),
Release engine flags `-O3 -DNDEBUG -std=gnu++20 -arch arm64`.
Google Benchmark is v1.9.4. All implementation processes use one-second warm-up,
at least one CPU second per repetition, ten repetitions, and the same input
formulas and allocation-inclusive timing scope. No Instruments capture ran.

Every capture boundary recorded battery power and Low Power Mode disabled;
battery charge was A 73→72%, B 72→71%, C 71→69%, D 69→67%. Thermal probes
reported no recorded warnings; this is not continuous thermal monitoring.
Affinity could not be set and CPU frequency could not be determined, as recorded
in the benchmark logs. Do not use the framework's estimated frequency or cache
metadata to infer actual clock rates or cache behavior.

The desktop remained active. C–D snapshots show VS Code/C++ tooling, Spotlight
indexing, WindowServer, Chrome, and Codex processes, with changing CPU usage.
These are boundary observations, not a continuous interference trace. A–B process
names were truncated by the original `ps` field order; C–D preserve full executable
names without command arguments. Background workloads were not controlled.

### Measurement limits

| Run | Sum of measured CPU seconds | Sum of measured wall seconds | Largest per-repetition wall/CPU ratio |
|---|---:|---:|---:|
| A | 223.06 | 2623.23 | 756.12× |
| B | 216.02 | 1367.70 | 286.01× |
| C | 194.70 | 1187.14 | 910.15× |
| D | 194.80 | 195.54 | 1.034× |

These totals multiply per-iteration times by iteration counts and sum timed
repetitions; they exclude warm-up, calibration, and other process overhead.
A–C contain long wall-time gaps; boundary telemetry cannot identify their cause.
The idle-sleep assertion did not guarantee an uninterrupted C capture, and the
cleaner D capture does not prove that idle sleep caused the earlier gaps.
C's gaps above 2× occurred in the reference 32-square and 128-square cases.
Its primary 256-square case and both vector orientations had no such large gaps.
This 2× descriptor identifies conspicuous gaps, not a statistical acceptance
threshold, and no repetitions were removed.

A–B CPU CV reaches 43.84%. C has 18.96% reference CV at 32-square and 7.79% at
128-square; D's maximum CPU CV is 2.57%. At the primary target, C reference/ikj
CVs are 1.63%/0.27%, and D's are 1.88%/1.44%. The target's CPU-time ranges are
widely separated between implementations in both follow-ups. The large direction
of change is supported; a precise universal speedup or clean whole-suite latency
baseline is not. CPU time is not an end-to-end wall-latency guarantee.

### Results for every shape and capture

Tables use medians of ten per-repetition averages, not individual-call tail
latencies. CV is sample standard deviation / mean, expressed in percent.
Speedup is reference median CPU time / ikj median CPU time; below 1 means ikj
is slower. GFLOP/s columns are medians of the per-repetition throughput values,
which need not equal throughput calculated from median time for an even sample
count. Values were recomputed from raw repetitions and checked against the
framework aggregates and the `2*M*K*N` throughput formula.


### Run A

| (M,K,N) | Reference CPU µs | ikj CPU µs | Ref CV % | ikj CV % | Ref GFLOP/s | ikj GFLOP/s | Speedup |
|---|---:|---:|---:|---:|---:|---:|---:|
| (1,1,1) | 0.022795 | 0.024741 | 0.77 | 21.22 | 0.088 | 0.081 | 0.921× |
| (32,32,32) | 11.087200 | 10.785054 | 9.61 | 25.64 | 5.911 | 6.086 | 1.028× |
| (128,128,128) | 1171.828007 | 274.280736 | 10.84 | 35.75 | 3.579 | 15.297 | 4.272× |
| (256,256,256) | 13665.869919 | 1747.548128 | 33.62 | 36.39 | 2.499 | 19.586 | 7.820× |
| (63,65,67) | 115.736758 | 23.346690 | 43.84 | 0.17 | 4.741 | 23.504 | 4.957× |
| (1,256,256) | 73.984363 | 7.112244 | 14.02 | 39.44 | 1.777 | 18.709 | 10.402× |
| (256,256,1) | 28.687662 | 218.766100 | 15.96 | 19.66 | 4.570 | 0.599 | 0.131× |

### Run B

| (M,K,N) | Reference CPU µs | ikj CPU µs | Ref CV % | ikj CV % | Ref GFLOP/s | ikj GFLOP/s | Speedup |
|---|---:|---:|---:|---:|---:|---:|---:|
| (1,1,1) | 0.024324 | 0.029645 | 23.67 | 5.71 | 0.083 | 0.067 | 0.821× |
| (32,32,32) | 10.817188 | 10.452486 | 26.62 | 2.17 | 6.059 | 6.270 | 1.035× |
| (128,128,128) | 1235.362454 | 277.287724 | 10.78 | 1.80 | 3.397 | 15.126 | 4.455× |
| (256,256,256) | 11753.833333 | 2120.523634 | 21.20 | 6.15 | 2.855 | 15.833 | 5.543× |
| (63,65,67) | 115.853082 | 24.027535 | 11.56 | 19.37 | 4.737 | 22.838 | 4.822× |
| (1,256,256) | 49.583269 | 8.793935 | 16.54 | 31.57 | 2.656 | 14.905 | 5.638× |
| (256,256,1) | 26.856124 | 190.296977 | 6.49 | 10.29 | 4.881 | 0.689 | 0.141× |

### Run C

| (M,K,N) | Reference CPU µs | ikj CPU µs | Ref CV % | ikj CV % | Ref GFLOP/s | ikj GFLOP/s | Speedup |
|---|---:|---:|---:|---:|---:|---:|---:|
| (1,1,1) | 0.029381 | 0.023252 | 1.19 | 1.16 | 0.068 | 0.086 | 1.264× |
| (32,32,32) | 10.955940 | 7.027915 | 18.96 | 3.14 | 5.982 | 9.325 | 1.559× |
| (128,128,128) | 1156.757819 | 177.344887 | 7.79 | 0.34 | 3.626 | 23.651 | 6.523× |
| (256,256,256) | 11838.834711 | 1234.446005 | 1.63 | 0.27 | 2.834 | 27.182 | 9.590× |
| (63,65,67) | 117.148847 | 23.581783 | 5.06 | 0.21 | 4.686 | 23.269 | 4.968× |
| (1,256,256) | 45.256473 | 4.902100 | 0.13 | 0.66 | 2.896 | 26.738 | 9.232× |
| (256,256,1) | 26.154930 | 180.223254 | 0.32 | 0.69 | 5.011 | 0.727 | 0.145× |

### Run D

| (M,K,N) | Reference CPU µs | ikj CPU µs | Ref CV % | ikj CV % | Ref GFLOP/s | ikj GFLOP/s | Speedup |
|---|---:|---:|---:|---:|---:|---:|---:|
| (1,1,1) | 0.023882 | 0.023630 | 1.38 | 1.39 | 0.084 | 0.085 | 1.011× |
| (32,32,32) | 11.593124 | 7.005654 | 1.11 | 0.69 | 5.653 | 9.355 | 1.655× |
| (128,128,128) | 1204.422451 | 183.755086 | 0.39 | 2.57 | 3.482 | 22.826 | 6.554× |
| (256,256,256) | 12379.300000 | 1274.936994 | 1.88 | 1.44 | 2.711 | 26.319 | 9.710× |
| (63,65,67) | 121.935923 | 23.711874 | 0.98 | 0.65 | 4.500 | 23.142 | 5.142× |
| (1,256,256) | 47.135701 | 4.878220 | 0.53 | 0.83 | 2.781 | 26.869 | 9.662× |
| (256,256,1) | 26.821520 | 187.923397 | 0.60 | 2.52 | 4.887 | 0.697 | 0.143× |

### Interpretation and next work

The large-square, awkward rectangular, and row-vector cases favor ikj in all
four captures, while matrix-times-column-vector favors the reference in all
four. For 32-square the small A–B differences are inconclusive; C–D show a
larger benefit. The tiny (1,1,1) case changes direction across captures and
is inconclusive; do not claim an overhead improvement from it.

The source-level locality hypothesis is consistent with the primary result,
but new assembly inspection is still needed: the reordered loop also changes
C traffic, accumulator dependencies, bounds-check placement, and opportunities
for auto-vectorization. These CPU-time measurements do not isolate cache effects.

Next, expand the matrix-vector and size sweeps described in Part 6 while keeping
the kernel code and timing contract fixed. Preserve the current seven-shape
results as a distinct experiment. Include correctness coverage for newly added
shapes and update the collector's expected shape set and parser test counts.

### Reproduce the comparison table

[Machine-readable summary](benchmark-results/curated/step7-comparison.csv) includes
CPU minima/maxima, medians, CVs, GFLOP/s, median wall times, and maximum wall/CPU
ratios. The summarizer validates source/result hashes, complete cases, raw/combined
agreement, throughput, and CPU aggregates before writing output:

```sh
python3 scripts/summarize_benchmarks.py \
  benchmark-results/curated/20260921T204855.055031Z-603cc7838199 \
  benchmark-results/curated/20260921T215515.158071Z-603cc7838199 \
  benchmark-results/curated/20260921T222422.044823Z-603cc7838199 \
  benchmark-results/curated/20260921T224500.033105Z-603cc7838199 \
  --csv /tmp/step7-comparison.csv
```

To collect a new counterbalanced pair, use the commands in
[BENCHMARKING.md](BENCHMARKING.md), record actual conditions, keep the machine
awake, and inspect both CPU variability and wall-time gaps before interpreting it.
