# Step 6: Profiling and compiler inspection

**Step 6 is complete.** The baseline Time Profiler recording identifies
`inference::matmul_reference` as the hot kernel for the 256×256×256 workload.
Compiler inspection explains the access pattern and generated arithmetic, and
the hypothesis below defines the first controlled experiment for step 7.
No kernel optimization or speedup is claimed here.

## Evidence and measurement scope

The recording was captured on September 14, 2026, at 17:10:45 PDT and reviewed
on September 15. The repository was clean at review, at commit
`957aefe9dc46996a1123886250b52b77bafff7ea`. This is the reviewed source revision;
the recording does not contain a capture-time Git manifest.

| Item | Recorded or verified value |
|---|---|
| Trace | `profiles/local/step6/reference-256.trace` |
| Instrument | Time Profiler, Instruments 16.0 (17F113) |
| Machine | MacBook Pro, macOS 26.6.2 (25G83); step-5 machine metadata identifies Apple M3 Pro |
| Target | `build/profile/matmul_bench` |
| Shape `(M,K,N)` | `(256,256,256)` |
| Build | Release, Apple Clang 21.0.0; `-O3 -g -DNDEBUG -std=gnu++20 -arch arm64` |
| Executable / dSYM UUID | `5698AD60-A720-34B9-9ECC-AAD2BFF83EBF`, matching the trace's executable image |
| Benchmark arguments | Exact shape filter, 1-second minimum warm-up, 10-second minimum measurement, 1 repetition |
| Recording duration | 19.576841 seconds; target exited with status 0 before the 20-second limit |
| Sampling configuration | 1,000-microsecond sample interval; waiting threads excluded |
| Correctness | All three CTest targets passed in the profiling build before capture |

The benchmark includes output allocation, zero-initialization, multiplication,
and destruction. Input construction and filling occur outside its timed loop.
The profiler observes the process more broadly, including framework startup,
warm-up, and calibration. A selected trace interval is therefore not necessarily
identical to Google Benchmark's timed measurement interval.

Capture-time power, thermal conditions, and background activity were not saved
in a separate conditions manifest. Do not substitute the earlier step-5
conditions for this recording. Use the unprofiled C–D baseline described in
[BENCHMARKING.md](BENCHMARKING.md) for performance comparisons; this recording
is evidence about where CPU execution is sampled.

## Profile finding

Exported `time-profile` rows were filtered to the `matmul_bench` process.
Within the selected **3–18 second interval**, all 14,254 rows had usable stacks
and equal 1 ms weights. Self weight was attributed to the first frame in each
stack; inclusive weight counted each function at most once per stack.

| Sample attribution | Samples | Share of selected samples |
|---|---:|---:|
| `inference::matmul_reference` — self | 14,248 | 99.9579% |
| `inference::matmul_reference` — inclusive | 14,248 | 99.9579% |
| All other leaf frames combined | 6 | 0.0421% |

All 14,248 matmul leaf samples are symbolized to `src/matrix.cpp:83`:

```cpp
total += a(row, k) * b(k, col);
```

The full recording has 17,980 usable target-process samples, of which 16,972
(94.3938%) have matmul as the leaf frame. It also includes 992 samples in the
benchmark framework's CPU-information initialization path. One row without a
usable process/stack was excluded from that full-recording summary. Selecting
3–18 seconds avoids the startup contribution.

**Conclusion:** multiplication dominates sampled CPU execution for this shape;
allocation and setup are not the first optimization target supported by this
trace. Sparse samples do not establish that those costs are zero. These weights
are sampling estimates, not exact function durations or invocation counts.
Optimized source-line attribution also does not identify one particular
instruction as responsible for every sample.

## Compiler inspection

The existing diagnostic files are
`profiles/local/step6-inspection/vectorization.txt` and
`profiles/local/step6-inspection/matrix.s`. They were generated from the same
matrix source with the baseline's optimization settings, without `-g`:

```sh
mkdir -p profiles/local/step6-inspection
/usr/bin/c++ -Iinclude -O3 -DNDEBUG -std=gnu++20 -arch arm64 \
  -Rpass=loop-vectorize \
  -Rpass-missed=loop-vectorize \
  -Rpass-analysis=loop-vectorize \
  -S src/matrix.cpp \
  -o profiles/local/step6-inspection/matrix.s \
  2> profiles/local/step6-inspection/vectorization.txt
```

Clang reports vectorization width 4 and interleave count 4 for the reduction
loop. The assembly qualifies that observation: it checks whether `B.cols()` is
1 and selects different paths. For `N=1` and sufficiently large K, the generated
code contains vector loads and `fmul.4s`, followed by ordered scalar additions.
For `N>1`, including the profiled shape, it selects this scalar inner loop:

```asm
LBB14_37:
    ldr     s1, [x3], #4
    ldr     s2, [x6, x17]
    fmadd   s0, s1, s2, s0
    add     x6, x6, x4
    subs    x7, x7, #1
    b.ne    LBB14_37
```

The first load advances through A in 4-byte steps. The B pointer advances by
`x4 = 4*N` bytes, or **1,024 bytes** for this shape. The scalar fused
multiply-add updates the same accumulator each iteration. Accessors are inlined,
and the remaining bounds checks are outside this repeated inner arithmetic loop.
The presence of a vectorization remark does not mean the profiled shape executes
the vector path.

This assembly was produced by a separate compiler invocation; it is not an
instruction-level attribution of the recorded samples. Together, the source,
compiler output, and profile motivate investigating access order. They do not
prove cache misses, memory-bandwidth saturation, or an exclusively memory-bound
or compute-bound kernel. No hardware-counter measurements were collected.

## Testable hypothesis for step 7

The concrete experiment definition, controls, and decision criteria are recorded
in [MEMORY_ACCESS.md](MEMORY_ACCESS.md). Both kernels now have shared correctness
coverage; benchmark integration and measurement are pending.

**Hypothesis:** for larger `N>1` workloads, changing loop order from
`row → col → k` to `row → k → col` will reduce allocation-inclusive CPU time by
accessing B contiguously and reusing each A value across columns. The strongest
initial target is the profiled `(256,256,256)` case.

Test this with a separate variant while retaining `matmul_reference` unchanged:

1. Keep the same matrix layout, checked access interface, input values,
   single-thread execution, output allocation/initialization scope, and compiler
   flags. Change traversal order and the corresponding accumulation into the
   zero-initialized result. Do not combine this experiment with packing, tiling,
   raw-pointer access, intrinsics, or fast-math.
2. Check the variant against the reference and independent oracle. Extend
   correctness coverage to benchmark-sized reductions: the current randomized
   suite stops at K=31, and its tolerance is justified for that bounded range.
   Include awkward and empty shapes and rerun sanitizer checks.
3. Benchmark both implementations without Instruments across all seven existing
   shapes, using the step-5 follow-up protocol: 1-second warm-up, at least
   1 second per repetition, and 10 repetitions. Repeat the comparison in
   comparable conditions, record those conditions, and retain every repetition.
4. Compare CPU-time medians and variability. Repeatable improvement on the
   target case supports the hypothesis; no repeatable improvement or a
   regression weakens it. Report outcomes for every shape. The step-5 observed
   1.39% variation is not a universal significance threshold.
5. Inspect the variant's compiler output. This loop-order change also changes
   C traffic and vectorization opportunities, so any speedup alone cannot be
   attributed exclusively to cache behavior. Keep or reject the variant based
   on measured results and the intended workloads.

Additional profiles of `(1,256,256)`, `(256,256,1)`, and `(1,1,1)` would help
compare strided, contiguous, and overhead-heavy cases. They are follow-up
investigations, not missing requirements for this baseline finding.

## Rechecking the evidence

Run these commands from the repository root to export the original capture:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun xctrace export \
  --input profiles/local/step6/reference-256.trace \
  --toc --output profiles/local/step6/review-toc.xml

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun xctrace export \
  --input profiles/local/step6/reference-256.trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="time-profile"]' \
  --output profiles/local/step6/review-samples.xml
```

When aggregating the XML, resolve `ref` attributes to their corresponding `id`
elements before reading processes, weights, and stacks. Filter sample timestamps
to 3–18 seconds and the target PID 78560 for this particular recording.

The trace, compiler output, profiling build, and dSYM are local ignored
artifacts. This report records their findings, but a fresh clone alone does not
contain those raw artifacts. Preserve them alongside the report when sharing
the investigation for independent review.
