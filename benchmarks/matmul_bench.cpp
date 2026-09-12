#include "inference/matrix.hpp"

#include <benchmark/benchmark.h>
#include <cstddef>

static void BM_MatmulReferenceAllocationIncluded(benchmark::State& state){
  const auto size = static_cast<std::size_t>(state.range(0));

  inference::Matrix a(size, size);
  inference::Matrix b(size, size);

  for (std::size_t i = 0; i < size * size; ++i){
    a.data()[i] = static_cast<float>(static_cast<int>(i % 17) - 8) / 8.0f;
    b.data()[i] = static_cast<float>(static_cast<int>(i % 13) - 6) / 6.0f;
  }

  for(auto _ : state){
    auto result = inference::matmul_reference(a, b);

    auto* output = result.data();
    benchmark::DoNotOptimize(output);
    benchmark::ClobberMemory();
  }
}

BENCHMARK(BM_MatmulReferenceAllocationIncluded)
  ->Arg(32)
  ->Unit(benchmark::kMicrosecond);
