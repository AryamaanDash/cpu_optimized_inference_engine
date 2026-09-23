# Step 7 compiler inspection

The engine source is unchanged by this investigation. `manifest.json` records
the source/header hashes, benchmark executable hash, compiler version, actual
engine build command, inspection commands, and hashes of the evidence files.
`matrix.s` and `vectorization.txt` come from a separate compiler invocation with
the same Release optimization/language/architecture flags. `binary-matmul.txt`
disassembles both functions from the actual benchmark executable. The latter
confirms these paths exist in the measured build; it is not a sampling trace.

## Reference

The reference checks N against 1 before its long-reduction paths. For N>1,
`LBB14_37` loads one A float at a 4-byte step and one B float at a 4*N-byte step,
then issues scalar `fmadd` into one accumulator. C is assigned after reduction.
For N=1 and K>=16, `LBB14_30` loads contiguous vectors and uses `fmul.4s`, then
ordered scalar `fadd` instructions. Width-4 vectorization remarks therefore
do not imply that the N>1 strided path uses vector arithmetic. Bounds checks
are outside the repeated scalar arithmetic loop on the normal valid path.

## ikj

Clang reports width 4, interleave count 4 for the inner column loop (source
line 102). Each k loads A(row,k) once. On the valid shape path, the width check
compares N-1 with 15, so N<=16 uses the scalar path. For N>=17, after a runtime
B/C range-overlap check, `LBB16_12` processes 16 columns per iteration: paired
128-bit loads from B and C, four `fmla.4s` instructions broadcasting A, then
paired stores to C. Fresh result ownership means the input and output allocations
are distinct for this API, but the compiled code still performs the overlap check.

The vector bound leaves a scalar suffix of 1–16 columns (including 16 when N
is a multiple of 16). `LBB16_15` checks remaining output columns, loads B and C,
uses scalar `fmadd`, and stores C. Thus N=255 and N=256 both process 240 columns
in vectors, leaving 15/16 scalar columns; N=257 processes 256 in vectors and
leaves one. The width sweep includes 16/17 and 255/256/257 to examine these
compiler-path transitions, without assuming their timing impact in advance.

For N=1 there is no useful column vectorization: every k goes through setup,
checks, and a scalar C read/modify/write. This is additional work relative to
the reference's register accumulation. For larger N, contiguous accesses and
parallel column arithmetic can outweigh the repeated C traffic. This explains
plausible causes to test, not measured attribution of cache misses or stalls.

No packing, tiling, raw-pointer kernel, intrinsics, fast-math, or thread changes
were introduced. Automatic SIMD is an effect of the loop-order experiment;
its contribution cannot be separated from locality using elapsed time alone.
