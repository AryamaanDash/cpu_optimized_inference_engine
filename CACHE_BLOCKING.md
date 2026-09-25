# Step 8: Cache-blocked matrix multiplication

## Status

Part 1 (experiment definition and baseline preservation) is complete as of
September 25, 2026. The tiled kernel, expanded tests, benchmark integration,
measurements, and final analysis remain to be done. No Step 8 performance result
is claimed. This protocol follows the starting experiment in
[MEMORY_ACCESS.md](MEMORY_ACCESS.md#part-8-decision-completion-and-starting-point-for-step-8).

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
[BENCHMARKING.md](BENCHMARKING.md). The collector still needs extension for this
five-implementation suite; its existing CLI does not yet execute this protocol.

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

## Remaining completion gates

- Implement the separate blocked kernel with safe tile ends and contract handling.
- Extend independent correctness coverage to every candidate and tile edges.
- Extend benchmark collection and summaries while keeping historical captures valid.
- Measure the candidate set and confirm conclusions with repeated comparisons.
- Preserve compiler evidence, full results, and a documented keep/reject decision.
