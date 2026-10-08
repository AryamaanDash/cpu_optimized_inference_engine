# Step 8: Cache-blocked matrix multiplication

## Status

**Step 8 is complete as of October 7, 2026.** The blocked kernel, edge/oracle
tests, benchmark integration, two complete comparisons (1,500 measurements),
and compiler inspection are complete. All three tile choices regress against
ikj on the primary and larger-square targets. Retain the configurable kernel
as an experimental implementation; do not promote a tile choice or add dispatch.

Part 1 fixed the protocol on September 25. The original hypothesis and controls
below are preserved, followed by measured results and the retention decision.

## Question and hypothesis

For contiguous row-major FP32 matrices A[M,K] and B[K,N], does tiling the
existing ikj traversal reduce allocation-inclusive CPU time for multirow GEMMs?

The hypothesis is that reusing a B tile across several output rows, while
repeatedly updating a smaller C region, will improve sufficiently large multirow
multiplications. The preselected primary target is (M,K,N) = (256,256,256);
(512,512,512) is the larger follow-up. No benefit is predicted for M=1 or N=1.

The proposed traversal is `i_tile -> j_tile -> k_tile -> i -> k -> j`.
Each output receives contributions in increasing k order. C is initialized once
and accumulated across all reduction tiles. Tiling also introduces loop setup,
partial tiles, and repeated A traversal across column tiles; these costs may
outweigh the intended reuse.

## Preserved baselines and experimental controls

Keep `matmul_reference` and `matmul_ikj`, their benchmark registrations, and the
existing curated evidence unchanged. Add the blocked kernel as a separate
function. The reference remains a correctness comparison and the faster measured
N=1 baseline; ikj is the unblocked performance baseline for wider outputs.
Independent double-precision oracle tests remain the correctness authority.

Hold the following fixed between implementations:

- Owning contiguous row-major FP32 Matrix storage and checked `operator()` access.
- Compatible-shape validation, immutable inputs, fresh M-by-N output ownership,
  empty-output semantics, and zero output when K=0.
- Single-thread execution and the same compiler and Release flags within each
  comparison. Step 7 used `-O3 -DNDEBUG -std=gnu++20 -arch arm64`; record the
  actual compiler version and commands for new captures.
- Ordinary floating-point semantics, with normal compiler auto-vectorization
  enabled and no fast-math changes. Increasing k order does not promise bitwise
  equality across differently compiled loops.
- The existing benchmark inputs:
  `A[i] = float(int(i % 17) - 8) / 8.0f` and
  `B[i] = float(int(i % 13) - 6) / 6.0f`.
- Timing includes output allocation, zero-initialization, kernel execution, and
  output destruction. Input allocation/filling and counter reporting are excluded.
  Preserve output-use barriers and the `2*M*K*N` throughput convention.
- Reused input buffers, warm-up enabled, and no explicit cache flushing.

The first experiment changes tiling only. Packing, transposition, raw-pointer
kernels, explicit SIMD, register blocking, threading, and automatic shape dispatch
are deferred. Compiler changes induced by tiling must be inspected and reported.

## Preselected candidates and workloads

Use one configurable implementation with these initial (BM,BK,BN) choices:

| BM | BK | BN | Nominal A/B/C tile data |
|---:|---:|---:|---:|
| 8 | 32 | 64 | 11 KiB |
| 16 | 32 | 64 | 14 KiB |
| 16 | 64 | 64 | 24 KiB |

The estimate is `4*(BM*BK + BK*BN + BM*BN)` bytes. These are exploratory choices,
not inferred optimal sizes or guaranteed cache residency. Unpacked rows retain
their original strides; cache-line coverage, other live data, and associativity
also affect the actual working set. Reject zero tile dimensions.

Preselect the same 15 shapes for both baselines and all three candidates:

- Squares: (32,32,32), (128,128,128), (256,256,256), (512,512,512).
- Awkward shapes: (63,65,67), (129,257,131).
- Wide multirow shapes: (32,256,N), N = 64, 255, 256, 257, 512, 1024.
- Controls: (1,1,1), (1,256,256), (256,256,1).

Every candidate must pass the existing kernel contract tests, independent oracle
checks, tile-boundary and nonmultiple cases, and Debug/Release/sanitizer checks
before performance measurements are interpreted. Every benchmark shape needs
oracle coverage. See [TESTING.md](TESTING.md) for the existing numerical contract.

## Measurement and decision protocol

Measure current baselines alongside candidates; historical timings provide
context but do not replace fresh controls. Use one second of warm-up, at least
one CPU second per repetition, and ten repetitions per implementation/shape.
Collect at least two complete comparisons with reversed implementation order.
Record the actual order and conditions, keep the machine awake during captures,
and retain all repetitions. Rotate order or collect further comparisons when
effects are close to observed variation or results drift across captures.

Short exploratory runs may check feasibility, but keep them separate from final
evidence. Confirm a selected candidate in fresh comparisons before claiming a win.
Save source snapshots, compiler commands, executable/result hashes, raw results,
test logs, and power/thermal/background-activity observations as in
[BENCHMARKING.md](BENCHMARKING.md). The collector now supports this
five-implementation suite through `--suite blocking`.

Report CPU medians, variability, GFLOP/s, wall/CPU discrepancies, and speedups
against both baselines for every shape. A repeatable reduction relative to ikj
on the primary target, distinguishable from observed variability, supports the
primary hypothesis. A win only at larger sizes supports a narrower conclusion.
Noisy results are inconclusive; repeatably equal or slower performance does not
support the hypothesis. Do not apply a historical noise percentage as a universal
threshold, hide regressions, or select only the fastest repetitions.

Inspect vectorization diagnostics and actual executable code to explain changes
in loop setup, checks, tails, and arithmetic. Timing alone cannot attribute a win
exclusively to cache reuse or establish cache-miss counts or cache capacity.

Retain a tile choice as a performance option only when its measured tradeoffs
justify it. A correct, reproducible negative result can complete Step 8. Record
that outcome before considering packing or a different schedule; packing, if
later justified, requires explicit allocation/copy costs and reuse assumptions.

## Completion gates (all satisfied)

- [x] Implement the separate blocked kernel with safe tile ends and contract handling.
- [x] Extend independent correctness coverage to every candidate and tile edges.
- [x] Extend benchmark collection and summaries while keeping historical captures valid.
- [x] Measure the candidate set and confirm conclusions with repeated comparisons.
- [x] Preserve compiler evidence, full results, and a documented keep/reject decision.

## Implementation and correctness

`matmul_blocked(a, b, MatmulTiles{bm,bk,bn})` is an explicit runtime-configured
function. It validates dimensions before allocation, allocates/zeros C once,
and returns early for empty output or K=0. Tile ends use
`start + min(tile, dimension-start)` and advance to that end, avoiding addition
overflow for large tile settings. Output values accumulate across K tiles.
The two existing kernel bodies are unchanged; all three use checked Matrix access.

Debug passed all three CTest targets; ASan/UBSan passed all three; each Release
capture passed all four, including 14 Python regressions. The shared tests run
1,536 small oracle cases and 144 larger cases for each of five kernels, plus
contract tests. An additional 780 blocked oracle cases cover boundary combinations,
unit/odd/oversized tiles, and cancellation; invalid-tile and output-overflow checks
also pass. Numerical bounds are unchanged. See [TESTING.md](TESTING.md),
[Debug log](profiles/step8-inspection/debug-tests.log), and
[sanitizer log](profiles/step8-inspection/sanitizer-tests.log).

The collector stores implementation prefixes, explicit tile dimensions, and order.
The summarizer uses saved manifests rather than the current implementation registry;
all historical curated schema-v2 captures still validate. Step 5 schema-v1 evidence
remains untouched (the summarizer continues to support schema v2 only).

## Captures and comparability

Both captures use the same source snapshot, build metadata, compile commands, and
executable SHA-256:
`2a2fe43fd111a9a098b4b987bfee6711a5418053c1f909db47dc5396f102d998`.
They record dirty commit `ea01e5a8c32f`; the full SHA, patches, and source manifests
are in metadata. The snapshots, rather than the commit alone, identify the build.
No sources changed during collection. Final analysis text was added afterward.
The executable hash also matches the compiler-inspection manifest.

| Capture | UTC interval, October 7 | Order | Measurements | Battery boundaries |
|---|---|---|---:|---|
| A | 22:49:47–23:10:21 | reference → ikj → 8/32/64 → 16/32/64 → 16/64/64 | 750 | 52% → 43% |
| B | 23:10:21–23:40:53 | 16/64/64 → 16/32/64 → 8/32/64 → ikj → reference | 750 | 43% → 34% |

- [Capture A metadata](benchmark-results/curated/20261007T224947.727685Z-ea01e5a8c32f/metadata.json)
  and [combined results](benchmark-results/curated/20261007T224947.727685Z-ea01e5a8c32f/results.json).
- [Capture B metadata](benchmark-results/curated/20261007T231021.275339Z-ea01e5a8c32f/metadata.json)
  and [combined results](benchmark-results/curated/20261007T231021.275339Z-ea01e5a8c32f/results.json).

Each directory also contains five raw implementation JSON files, test/build logs,
compile commands, and the complete source snapshot. Curated copies were verified
byte-for-byte against local captures. The summarizer verified source/result hashes,
raw/combined agreement, repetition counts, throughput formulas, and CPU aggregates.

Machine: Apple M3 Pro, arm64, macOS 26.6.2 (25G83), Apple Clang 21.0.0
(`clang-2100.0.123.102`), Google Benchmark v1.9.4. Engine flags:
`-O3 -DNDEBUG -std=gnu++20 -arch arm64`. Both captures used one benchmark thread,
one-second warm-up, at least one CPU second per repetition, and ten repetitions.
Output allocation, zeroing, tile validation/setup, multiplication, and destruction
are timed. Inputs are prepared outside timing and reused. There is no packing,
transposition, extra scratch allocation, explicit SIMD, or threading.

Power boundaries report battery power. Thermal probes reported no recorded warning;
they are not continuous measurements of temperature or frequency. The active desktop
included Chrome, WindowServer, audio services, indexing, Spotify, and Codex.
No apps were closed or cores pinned. Temporary `caffeinate -i` assertions were used;
frequency/affinity warnings remain in the raw logs. No assistant builds or tests ran
concurrently with the timed processes.

## Results and limits

[Complete tables](benchmark-results/curated/step8-comparison.md) and
[CSV](benchmark-results/curated/step8-comparison.csv) retain all 15 shapes and five
implementations in each capture. The CSV includes CPU medians/minima/maxima/CVs,
GFLOP/s, median wall time, maximum wall/CPU ratio, and both baseline ratios.

Selected median CPU times below are in microseconds. Each A/B entry shows the two
captures separately; these are not pooled estimates.

| (M,K,N) | reference A / B | ikj A / B | 8/32/64 A / B | 16/32/64 A / B | 16/64/64 A / B |
|---|---:|---:|---:|---:|---:|
| (256, 256, 256) | 11957.475 / 12314.395 | 1227.280 / 1247.000 | 2643.224 / 2646.345 | 2643.592 / 2637.253 | 2609.229 / 2605.663 |
| (512, 512, 512) | 109982.808 / 114468.500 | 9602.956 / 9686.615 | 21488.114 / 21239.326 | 21179.947 / 21158.091 | 20977.709 / 21000.231 |
| (63, 65, 67) | 119.067 / 122.204 | 23.620 / 24.023 | 55.019 / 54.962 | 54.864 / 54.737 | 54.279 / 54.235 |
| (32, 256, 1024) | 7008.619 / 7159.964 | 574.482 / 591.865 | 1360.256 / 1391.276 | 1352.019 / 1350.448 | 1336.464 / 1333.886 |
| (1, 256, 256) | 47.162 / 47.333 | 4.806 / 4.824 | 10.385 / 10.413 | 10.397 / 10.377 | 10.236 / 10.235 |
| (256, 256, 1) | 26.135 / 26.944 | 199.322 / 195.617 | 95.158 / 95.187 | 94.693 / 94.218 | 95.716 / 96.010 |

All three tile choices lose to ikj on 14 of 15 shapes in both captures, including
all 13 N>1 shapes and the tiny-call control. On the primary 256-square, they take 2.09–2.15 times ikj's
CPU time; on 512-square, 2.17–2.24 times. The observed repetition ranges for blocked
and ikj are disjoint for every N>1 comparison within each capture. This supports
the direction of these regressions under the measured conditions, not a universal
performance claim or a statistical confidence interval.

For (256,256,1), blocking takes about 94–96 µs and improves on ikj's 196–199 µs,
but the reference takes only 26–27 µs. Thus this is not a win against the relevant
faster baseline. Differences between tile choices are small compared with the
main regression; no tile is selected as a performance default.

Maximum CPU CV is 3.43% in A and 8.35% in B; the largest median drift across
captures is 5.84% (reference at 128-square). The primary and large-square blocked
cases have CV at most 2.36% and maximum wall/CPU ratio at most 1.053 across both
captures. Their approximately twofold CPU regression repeats without the large
wall-time anomalies described below.

Capture B has eight repetitions with wall/CPU ratios above 1.2, all in the
8/32/64 candidate: two tiny-call repetitions, one 32-square, one column-vector,
two (32,256,64), and two (32,256,255). The largest ratio is 176.72. A's maximum
is 1.091. Total timed CPU/wall seconds are 1049.40/1050.86 in A and
1053.38/1648.54 in B (excluding warm-up/calibration and other process overhead).
These gaps establish interruptions or descheduling, not their cause. No samples
were removed. Consequently this experiment supports the large CPU-time regression,
but is not a controlled wall-latency study; close differences and tiny-call timings
should not be generalized. Further wall-latency claims require a quieter session.

## Compiler evidence and decision

[Inspection report](profiles/step8-inspection/README.md),
[assembly](profiles/step8-inspection/matrix.s),
[diagnostics](profiles/step8-inspection/vectorization.txt), and
[executable disassembly](profiles/step8-inspection/binary-matmul.txt) accompany a
[hash/command manifest](profiles/step8-inspection/manifest.json).

The blocked inner loop still auto-vectorizes with four width-4 FMA operations per
vector iteration, but a full BN=64 tile processes 48 columns in vectors and 16 in
a checked scalar suffix. N=256 therefore pays four such suffixes rather than ikj's
one. Tile boundary/setup work and loop-state reloads add overhead; A is revisited
across column tiles. These observations provide plausible explanations for the
regression. They do not quantify cache misses or isolate the contribution of each
cause. There is no hardware-counter claim or new sampling profile.

The preselected hypothesis is not supported for these kernels, shapes, and tile
choices. Keep both existing baselines and retain `matmul_blocked` as an explicitly
configured experimental path with its tests and evidence. Do not replace ikj,
choose a default tile, or add dispatch. Packing is not justified by this experiment
and remains deferred. Step 8's requirements are met by correct edge handling,
measured tile choices, explicit setup costs, repeatable comparisons, and the
negative-result analysis. Step 9 can now investigate execution inside the hot loop,
using this evidence about tails/checks and preserving an unblocked control.

## Reproduce the summary

```sh
python3 scripts/summarize_benchmarks.py \
  benchmark-results/curated/20261007T224947.727685Z-ea01e5a8c32f \
  benchmark-results/curated/20261007T231021.275339Z-ea01e5a8c32f \
  --csv /tmp/step8-comparison.csv
```

New capture commands are in [BENCHMARKING.md](BENCHMARKING.md#step-8-cache-blocking-comparison).
Reproducing the results requires the saved source/compiler/settings and comparable
conditions; it does not imply identical timings.
