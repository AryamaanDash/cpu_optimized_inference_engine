#include "inference/matrix.hpp"

#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <exception>
#include <new>
#include <stdexcept>

namespace {

thread_local bool fail_next_allocation = false;

class AllocationFailureScope {
public:
    AllocationFailureScope() { fail_next_allocation = true; }
    ~AllocationFailureScope() { fail_next_allocation = false; }
    AllocationFailureScope(const AllocationFailureScope&) = delete;
    AllocationFailureScope& operator=(const AllocationFailureScope&) = delete;
};

void check(bool condition, const char* message) {
    if (!condition) {
        throw std::runtime_error(message);
    }
}

} // namespace

// std::vector<float> uses ordinary scalar allocation. Replace only that path
// in this dedicated executable; no production allocator hooks are needed.
void* operator new(std::size_t size) {
    if (fail_next_allocation) {
        fail_next_allocation = false;
        throw std::bad_alloc();
    }
    if (void* memory = std::malloc(size == 0 ? 1 : size)) {
        return memory;
    }
    throw std::bad_alloc();
}

void operator delete(void* memory) noexcept {
    std::free(memory);
}

#if defined(__cpp_sized_deallocation)
void operator delete(void* memory, std::size_t) noexcept {
    std::free(memory);
}
#endif

int main() {
    try {
        inference::Matrix source(3, 5);
        inference::Matrix destination(2, 3);
        for (std::size_t i = 0; i < 15; ++i) {
            source.data()[i] = static_cast<float>(i) - 7.0f;
        }
        for (std::size_t i = 0; i < 6; ++i) {
            destination.data()[i] = static_cast<float>(i) + 10.0f;
        }
        const float* original_storage = destination.data();

        bool allocation_failed = false;
        {
            AllocationFailureScope failure;
            try {
                destination = source;
            } catch (const std::bad_alloc&) {
                allocation_failed = true;
            }
        }
        check(allocation_failed, "Copy assignment did not exercise allocation failure");
        // Check shape and storage before indexing so a regression fails safely.
        check(destination.rows() == 2 && destination.cols() == 3,
              "Failed copy assignment changed destination dimensions");
        check(destination.data() == original_storage,
              "Failed copy assignment replaced destination storage");
        for (std::size_t i = 0; i < 6; ++i) {
            check(destination(i / 3, i % 3) == static_cast<float>(i) + 10.0f,
                  "Failed copy assignment changed destination values");
        }
        check(source.rows() == 3 && source.cols() == 5,
              "Failed copy assignment changed source dimensions");
        for (std::size_t i = 0; i < 15; ++i) {
            check(source.data()[i] == static_cast<float>(i) - 7.0f,
                  "Failed copy assignment changed source values");
        }

        destination(1, 2) = 42.0f;
        check(destination(1, 2) == 42.0f, "Destination is not writable after failure");
        check(&(destination = source) == &destination,
              "Copy assignment must return its destination");
        check(destination.rows() == 3 && destination.cols() == 5,
              "Copy assignment cannot be retried after failure");
        check(destination.data() != source.data(), "Copy assignment shares storage");
        for (std::size_t i = 0; i < 15; ++i) {
            check(destination.data()[i] == source.data()[i], "Retry lost source values");
        }
        destination(0, 0) = 99.0f;
        check(source(0, 0) == -7.0f, "Writing to the copy changed the source");

        std::puts("PASS: copy assignment preserves state on allocation failure and can be retried");
        return 0;
    } catch (const std::exception& error) {
        std::fprintf(stderr, "FAIL: %s\n", error.what());
        return 1;
    }
}
