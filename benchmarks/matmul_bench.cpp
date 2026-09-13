#include "inference/matrix.hpp"

#include <benchmark/benchmark.h>
#include <cstddef>

static void BM_MatmulReferenceAllocationIncluded(benchmark::State& state){

  const auto m = static_cast<std::size_t>(state.range(0));
  const auto k = static_cast<std::size_t>(state.range(1));
  const auto n = static_cast<std::size_t>(state.range(2));

  inference::Matrix a(m, k);
  inference::Matrix b(k, n);

  for(std::size_t i = 0; i < m * k; ++i){
    a.data()[i] = static_cast<float>(static_cast<int>(i % 17) - 8) / 8.0f;
  }

  for(std::size_t i = 0; i < k * n; ++i)
    b.data()[i] = static_cast<float>(static_cast<int>(i % 13) - 6) / 6.0f;

  for(auto _ : state){
    auto result = inference::matmul_reference(a, b);

    auto* output = result.data();
    benchmark::DoNotOptimize(output);
    benchmark::ClobberMemory();
  }

  const double flops_per_matmul = 2.0 * static_cast<double>(m) * static_cast<double>(k) * static_cast<double>(n);

  state.counters["GFLOPS"] = benchmark::Counter(
    flops_per_matmul / 1e9,
    benchmark::Counter::kIsIterationInvariantRate
  );
  // flops_per_matmul / 1e9 supplies the number of GFLOPs per iteration
  // kIsIterationInvariantRate tells Google Benchmark that every iteration performs that same amount of work
  // The framework multiplies by the iteration count and divides by measured duration producing GFLOP/s.
}

BENCHMARK(BM_MatmulReferenceAllocationIncluded)
  ->ArgNames({"M","K","N"})
  ->Args({1, 1, 1})
  ->Args({32, 32, 32})
  ->Args({128, 128, 128})
  ->Args({256, 256, 256})
  ->Args({63,65,67})
  ->Args({1, 256, 256})
  ->Args({256,256,1})
  ->Unit(benchmark::kMicrosecond);
