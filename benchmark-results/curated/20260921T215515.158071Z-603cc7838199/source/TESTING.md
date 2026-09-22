# Correctness checks

Run from the repository root. Checks remain active in Release builds.

```sh
cmake -S . -B build/step7-debug -DCMAKE_BUILD_TYPE=Debug -DINFERENCE_BUILD_BENCHMARKS=OFF
cmake --build build/step7-debug -j 2
ctest --test-dir build/step7-debug --output-on-failure

cmake -S . -B build/step7-release -DCMAKE_BUILD_TYPE=Release -DINFERENCE_BUILD_BENCHMARKS=OFF
cmake --build build/step7-release -j 2
ctest --test-dir build/step7-release --output-on-failure

cmake -S . -B build/step7-sanitize -DCMAKE_BUILD_TYPE=Debug -DINFERENCE_BUILD_BENCHMARKS=OFF \
  -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer" \
  -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address,undefined"
cmake --build build/step7-sanitize -j 2
ctest --test-dir build/step7-sanitize --output-on-failure
```

## Step 7 coverage

All multiplication tests take a kernel function and run for both `matmul_reference`
and `matmul_ikj`; failure output identifies the implementation. Coverage includes
hand-computed products, incompatible and empty shapes, K=0, mixed signs, zeros,
identities, cancellation, immutable inputs, and shared-input/output ownership.
The original 1,536 deterministic oracle cases run for each implementation with
unchanged small-case tolerances.

Each implementation also runs 48 larger-oracle cases: all seven benchmark shapes
plus (3,255,5), (5,257,3), (1,1024,17), (17,1024,1), and (3,1025,7), each with
four input patterns. Patterns are deterministic random seeds 17 and 20260912,
the exact benchmark formulas, and alternating-sign binary fractions. Oracle
fixtures use separate A rows and B columns, double accumulation, and comparison
to the unrounded double result. They do not use a production kernel as the oracle.

For these bounded inputs and round-to-nearest arithmetic, let S be the computed
double sum of absolute products, u32 = 2^-24, u64 = 2^-53, and
`gamma(p,u) = p*u / (1-p*u)`. The per-element absolute error allowance is:

```
(gamma(2*K,u32) + gamma(2*K,u64)) * S / (1-gamma(2*K,u64))
```

At most 2*K rounding operations cover separate FP32 multiplication/addition and
also conservatively cover fused multiply-add. Products of these FP32 fixtures
are exact in double; the double term accounts for oracle summation error, and
the denominator accounts for possible underestimation of S. This bound depends
on product magnitudes rather than the final sum, so cancellation near zero is
covered without arbitrarily increasing a fixed tolerance. It is intentionally
conservative and applies to these fixtures without overflow/underflow or fast-math;
it is not a universal accuracy specification for every possible FP32 input.

Binary-fraction cancellation cases additionally require exact answers (zero for
even K, one residual product for odd K). Error-bound helper tests reject excess
error, nonzero results for zero products, and NaN. Failures include shape, pattern,
element, actual/expected values, and allowed error. Pattern 0 uses seed 17;
pattern 1 uses seed 20260912; patterns 2 and 3 are the fixed formulas above.

The shared tests exposed the original `matmul_ikj` allocation of M-by-K instead
of M-by-N: ten test groups failed before the one-line result-shape correction.
