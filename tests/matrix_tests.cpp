#include "inference/matrix.hpp"

#include <cstddef>
#include <exception>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <type_traits>
#include <utility>
#include <vector>

using inference::Matrix;

// Verify the public access contract at compile time.
static_assert(std::is_same_v<decltype(std::declval<Matrix&>()(0, 0)), float&>);
static_assert(std::is_same_v<decltype(std::declval<const Matrix&>()(0, 0)), const float&>);
static_assert(std::is_same_v<decltype(std::declval<Matrix&>().data()), float*>);
static_assert(std::is_same_v<decltype(std::declval<const Matrix&>().data()), const float*>);
static_assert(noexcept(std::declval<const Matrix&>().rows()));
static_assert(noexcept(std::declval<const Matrix&>().cols()));
static_assert(noexcept(std::declval<Matrix&>().data()));
static_assert(noexcept(std::declval<const Matrix&>().data()));
static_assert(!noexcept(std::declval<Matrix&>()(0, 0)));
static_assert(!noexcept(std::declval<const Matrix&>()(0, 0)));

namespace {

// Unlike assert(), these checks remain active in Release builds.
void check(bool condition, const char* message) {
    if (!condition) {
        throw std::runtime_error(message);
    }
}

template <typename Exception, typename Function>
void expect_throw(Function function, const char* message) {
    try {
        function();
    } catch (const Exception&) {
        return;
    }
    throw std::runtime_error(message);
}

void construction() {
    for (const auto& [rows, cols] : {
             std::pair<std::size_t, std::size_t>{2, 3}, {3, 2}, {1, 1}, {1, 7}, {7, 1}}) {
        const Matrix matrix(rows, cols);
        check(matrix.rows() == rows && matrix.cols() == cols, "Incorrect dimensions");
        check(matrix.data() != nullptr, "Nonempty matrix has no storage");
        for (std::size_t row = 0; row < rows; ++row) {
            for (std::size_t col = 0; col < cols; ++col) {
                check(matrix(row, col) == 0.0f, "Elements must start at zero");
            }
        }
    }
}

void row_major_storage() {
    Matrix matrix(2, 3);
    matrix(0, 0) = 1.0f;
    matrix(0, 1) = -2.0f;
    matrix(0, 2) = 3.5f;
    matrix(1, 0) = 4.0f;
    matrix(1, 1) = 5.0f;
    matrix(1, 2) = -6.0f;
    const float expected[] = {1.0f, -2.0f, 3.5f, 4.0f, 5.0f, -6.0f};
    const Matrix& view = matrix;
    for (std::size_t i = 0; i < 6; ++i) {
        check(view.data()[i] == expected[i], "Incorrect row-major layout");
    }
    check(&matrix(1, 0) == matrix.data() + 3, "Mutable indexing must return stored element");
    check(&view(1, 2) == view.data() + 5, "Const indexing must return stored element");
    matrix.data()[4] = 9.0f;
    check(view(1, 1) == 9.0f, "Data pointer writes must affect indexed reads");
}

void bounds() {
    Matrix matrix(2, 3);
    const Matrix& view = matrix;
    const auto largest = std::numeric_limits<std::size_t>::max();
    for (const auto& [row, col] : {
             std::pair<std::size_t, std::size_t>{2, 0}, {0, 3}, {2, 3},
             {largest, 0}, {0, largest}}) {
        // (0, 3) would still fall inside the allocation if only the flat offset were checked.
        expect_throw<std::out_of_range>([&] { (void)matrix(row, col); },
                                        "Mutable indexing accepted invalid coordinates");
        expect_throw<std::out_of_range>([&] { (void)view(row, col); },
                                        "Const indexing accepted invalid coordinates");
    }
}

void empty_shapes() {
    const auto largest = std::numeric_limits<std::size_t>::max();
    for (const auto& [rows, cols] : {
             std::pair<std::size_t, std::size_t>{0, 0}, {0, 3}, {2, 0},
             {0, largest}, {largest, 0}}) {
        Matrix matrix(rows, cols);
        const Matrix& view = matrix;
        check(matrix.rows() == rows && matrix.cols() == cols, "Empty shape was not preserved");
        expect_throw<std::out_of_range>([&] { (void)matrix(0, 0); },
                                        "Empty matrix allowed mutable element access");
        expect_throw<std::out_of_range>([&] { (void)view(0, 0); },
                                        "Empty matrix allowed const element access");
        // An empty vector's data() need not be null; never dereference it here.
    }
}

void oversized_shapes() {
    const auto largest = std::numeric_limits<std::size_t>::max();
    expect_throw<std::length_error>([&] { Matrix matrix(largest, 2); },
                                   "Overflowing element count was not rejected");
    expect_throw<std::length_error>([&] { Matrix matrix(2, largest); },
                                   "Overflow check must handle either dimension");
    const auto max_elements = std::vector<float>{}.max_size();
    if (max_elements < largest) {
        expect_throw<std::length_error>([&] { Matrix matrix(max_elements + 1, 1); },
                                       "Vector capacity limit was not enforced");
    }
}

void copy_construction() {
    Matrix source(2, 3);
    source(1, 2) = 7.0f;
    Matrix copy(source);
    check(copy.rows() == 2 && copy.cols() == 3, "Copy constructor lost shape");
    check(copy(1, 2) == 7.0f, "Copy constructor lost values");
    check(copy.data() != source.data(), "Copy shares owned storage");
    copy(1, 2) = 8.0f;
    check(source(1, 2) == 7.0f, "Changing a copy changed its source");
}

void copy_assignment() {
    Matrix source(2, 3);
    source(1, 2) = -4.0f;
    Matrix destination(1, 1);
    destination = source;
    check(destination.rows() == 2 && destination.cols() == 3, "Copy assignment lost shape");
    check(destination(1, 2) == -4.0f, "Copy assignment lost values");
    source(1, 2) = 11.0f;
    check(destination(1, 2) == -4.0f, "Copy assignment shares storage");
    const Matrix& same = destination;
    destination = same;
    check(destination(1, 2) == -4.0f, "Self-copy assignment lost values");
    destination = Matrix(0, 0);
    check(destination.rows() == 0 && destination.cols() == 0, "Empty assignment lost shape");
}

void copy_outlives_source() {
    Matrix destination(0, 0);
    {
        Matrix source(2, 3);
        source(1, 2) = 12.0f;
        destination = source;
    }
    check(destination(1, 2) == 12.0f, "Copy did not retain owned storage");
}

void check_moved_from(Matrix& matrix) {
    // Intended contract discussed for this class: moving resets the source to 0 x 0.
    // Check dimensions first so a broken implementation is never indexed unsafely.
    check(matrix.rows() == 0 && matrix.cols() == 0, "Moved-from matrix must have shape 0 x 0");
    expect_throw<std::out_of_range>([&] { (void)matrix(0, 0); },
                                    "Moved-from matrix allowed element access");
    matrix = Matrix(1, 1);
    matrix(0, 0) = 3.0f;
    check(matrix(0, 0) == 3.0f, "Moved-from matrix cannot be reassigned");
}

void move_construction() {
    Matrix source(2, 3);
    source(1, 2) = 6.0f;
    Matrix destination(std::move(source));
    check(destination.rows() == 2 && destination.cols() == 3, "Move constructor lost shape");
    check(destination(1, 2) == 6.0f, "Move constructor lost values");
    check_moved_from(source);
}

void move_assignment() {
    Matrix source(2, 3);
    source(1, 2) = 6.0f;
    Matrix destination(4, 1);
    destination = std::move(source);
    check(destination.rows() == 2 && destination.cols() == 3, "Move assignment lost shape");
    check(destination(1, 2) == 6.0f, "Move assignment lost values");
    check_moved_from(source);
}

} // namespace

int main() {
    struct Test {
        const char* name;
        void (*run)();
    };
    const Test tests[] = {
        {"construction and zero initialization", construction},
        {"row-major storage and const/mutable access", row_major_storage},
        {"bounds checking", bounds},
        {"empty shapes", empty_shapes},
        {"oversized shapes", oversized_shapes},
        {"copy construction", copy_construction},
        {"copy assignment", copy_assignment},
        {"copy outlives source", copy_outlives_source},
        {"move construction", move_construction},
        {"move assignment", move_assignment},
    };
    int failures = 0;
    for (const auto& test : tests) {
        try {
            test.run();
            std::cout << "PASS: " << test.name << '\n';
        } catch (const std::exception& error) {
            ++failures;
            std::cerr << "FAIL: " << test.name << ": " << error.what() << '\n';
        } catch (...) {
            ++failures;
            std::cerr << "FAIL: " << test.name << ": unknown exception\n";
        }
    }
    std::cout << failures << " failed test(s)\n";
    return failures == 0 ? 0 : 1;
}
