# Step 8 compiler inspection

The manifest records the source/header hashes, measured Release executable hash,
actual engine compile command, compiler version, and reproduction commands.
`matrix.s` and `vectorization.txt` use the same optimization/language/architecture
flags as the engine; `binary-matmul.txt` disassembles the actual benchmark binary.
This is compiler inspection, not a hardware-counter or sampling profile.

Clang reports width-4, interleave-4 vectorization for both ikj and the blocked
inner column loop. The blocked path (`LBB17_25`) loads B and C in four vectors,
issues four `fmla.4s` instructions broadcasting A, and stores C. The scalar suffix
(`LBB17_27`) retains checks for B/C column bounds and a scalar `fmadd` plus store.
The vector path is guarded by a span threshold of 17 and a runtime overlap check.
On valid nonoverlapping inputs, it leaves 1–16 scalar elements: a full BN=64 tile
processes 48 columns in vectors and 16 scalarly. At N=256 this repeats four times,
versus a single 16-element suffix for unblocked ikj. Thus tiling changes instruction
mix as well as intended reuse; short tails and setup are paid per tile.

The blocked kernel also uses stack storage for loop state with reloads in outer
loops. These are visible control-state costs, not evidence of SIMD accumulator
spills in the vector arithmetic loop. The full function has six nested source
loops, boundary calculations, and validation. It allocates only the output Matrix;
no tile packing buffers are present. Both baselines retain their existing source.

The reference and ikj paths remain available in the same disassembly for comparison.
Any runtime difference must be interpreted together with these generated paths;
elapsed time alone cannot prove a change in cache misses or attribute the result
exclusively to cache locality.
