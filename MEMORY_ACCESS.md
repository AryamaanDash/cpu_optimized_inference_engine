# Step 7: Memory access experiments

Status: the first experiment is defined; implementation and measurement are pending.
No performance improvement or completion of Step 7 is claimed.

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

Before measurement, test both implementations against hand-computed examples
and an independent double-precision oracle. Extend coverage beyond the current
K=31 limit with a justified tolerance for longer reductions. Debug, Release,
and AddressSanitizer/UndefinedBehaviorSanitizer checks must pass.

Update the collector to validate repetitions by implementation and shape;
its current shape-only count cannot handle two implementations. Verify all
expected cases are present before accepting a capture.

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
