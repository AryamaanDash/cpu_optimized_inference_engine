#include "inference/matrix.hpp"

#include <algorithm>
#include <array>
#include <cstddef>
#include <exception>
#include <initializer_list>
#include <iostream>
#include <limits>
#include <random>
#include <stdexcept>
#include <type_traits>
#include <utility>
#include <vector>
#include <cmath>
#include <sstream>

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


bool nearly_equal(double actual, double expected, double atol, double rtol){
  if(!std::isfinite(actual) || !std::isfinite(expected)){
    return false;
  }
  return std::abs(actual - expected) <= atol + rtol * std::abs(expected);
}

void check_matrix_close(const Matrix& actual, const Matrix& expected, double atol, double rtol){
  check(actual.rows() == expected.rows() && actual.cols() == expected.cols(),
      "Matrix dimensions do not match.");

  for(std::size_t row = 0; row < actual.rows(); ++row){
    for(std::size_t col = 0; col < actual.cols(); ++col){
      if(!nearly_equal(actual(row, col), expected(row, col),
                        atol, rtol)){
        std::ostringstream message;
        message.precision(17);
        message << "Matrix mismatch at (" << row << ", " << col << "): actual=" << actual(row, col) << ", expected=" << expected(row, col) << ", atol=" << atol << ", rtol=" << rtol;

        throw std::runtime_error(message.str());
      }
    }
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

void matrix_comparison() {
    Matrix expected(2, 3);
    expected(0, 0) = 100.0f;
    expected(1, 2) = -2.0f;

    Matrix actual = expected;

    // Identical matrices must pass.
    check_matrix_close(actual, expected, 1e-5, 1e-5);

    // Small differences within tolerance must pass.
    actual(0, 0) += 0.0005f;  // Relative tolerance
    actual(0, 1) = 0.000001f; // Absolute tolerance near zero
    check_matrix_close(actual, expected, 1e-5, 1e-5);

    // A mismatch at the last element must be detected.
    actual = expected;
    actual(1, 2) = -3.0f;
    expect_throw<std::runtime_error>(
        [&] { check_matrix_close(actual, expected, 1e-5, 1e-5); },
        "Comparison accepted an incorrect element");

    // Different dimensions must be rejected before indexing.
    const Matrix wrong_shape(3, 2);
    expect_throw<std::runtime_error>(
        [&] { check_matrix_close(wrong_shape, expected, 1e-5, 1e-5); },
        "Comparison accepted different dimensions");

    // Unexpected NaN must be rejected.
    actual = expected;
    actual(0, 0) = std::numeric_limits<float>::quiet_NaN();
    expect_throw<std::runtime_error>(
        [&] { check_matrix_close(actual, expected, 1e-5, 1e-5); },
        "Comparison accepted NaN");
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

void matmul_square(){
  Matrix a(2, 2);
  Matrix b(2, 2);

  const float a_values[] = {1, 2, 3, 4};
  const float b_values[] = {5, 6 ,7 , 8};
  const float expected[] = {19, 22, 43, 50};

  for(std::size_t i = 0; i < 4; ++i){
    a.data()[i] = a_values[i];
    b.data()[i] = b_values[i];
  }
  const Matrix result = inference::matmul_reference(a, b);

  check(result.rows() == 2 && result.cols() == 2,
      "Square multiplication returned the wrong shape");

  for (std::size_t i = 0; i < 4; ++i){
    check(result.data()[i] == expected[i],
        "Square multiplication returned an incorrect value");
    check(a.data()[i] == a_values[i] && b.data()[i] == b_values[i],
        "Multiplication changed the input values");
  }
}

void matmul_rectangular(){

    Matrix a(2, 3);
    Matrix b(3, 2);

    const float a_values[] = {1, 2, 3, 4, 5, 6};
    const float b_values[] = {7, 8, 9, 10, 11, 12};
    const float expected[] = {58, 64, 139, 154};

    for (std::size_t i = 0; i < 6; ++i) {
        a.data()[i] = a_values[i];
        b.data()[i] = b_values[i];
    }

    const Matrix result = inference::matmul_reference(a, b);

    check(result.rows() == 2 && result.cols() == 2,
          "Rectangular multiplication returned the wrong shape");

    for (std::size_t i = 0; i < 4; ++i) {
        check(result.data()[i] == expected[i],
              "Rectangular multiplication returned an incorrect value");
    }

    for (std::size_t i = 0; i < 6; ++i) {
        check(a.data()[i] == a_values[i] &&
              b.data()[i] == b_values[i],
              "Multiplication changed its inputs");
    }
}

void  matmul_incompatible_shapes(){
  const Matrix a(2, 3);
  const Matrix b(2, 3);
  expect_throw<std::invalid_argument>(
      [&] {
          (void)inference::matmul_reference(a,b);
      },
        "Multiplication accepted incompatible shapes");
}

void matmul_zero_inner_dimension(){
  const Matrix a(2, 0);
  const Matrix b(0, 3);

  const Matrix result = inference::matmul_reference(a, b);

  check(result.rows() == 2 && result.cols() == 3,
          "Zero-inner-dimension multiplication returned the wrong shape");

  for (std::size_t row = 0; row < result.rows(); ++row) {
      for (std::size_t col = 0; col < result.cols(); ++col) {
          check(result(row, col) == 0.0f,
          "Zero-inner-dimension multiplication must produce zeros");
        }
    }
}

Matrix matrix_from_values(std::size_t rows, std::size_t cols,
                          std::initializer_list<float> values) {
    Matrix result(rows, cols);
    check(values.size() == rows * cols, "Incorrect number of test fixture values");
    if (values.size() != 0) {
        std::copy(values.begin(), values.end(), result.data());
    }
    return result;
}

void check_product(const Matrix& a, const Matrix& b, const Matrix& expected) {
    const Matrix original_a = a;
    const Matrix original_b = b;
    const Matrix actual = inference::matmul_reference(a, b);
    check_matrix_close(actual, expected, 1e-5, 1e-5);
    // Inputs must be preserved exactly, even when output comparisons use tolerance.
    check_matrix_close(a, original_a, 0.0, 0.0);
    check_matrix_close(b, original_b, 0.0, 0.0);
}

void matmul_rectangular_output() {
    const Matrix a = matrix_from_values(2, 3, {1, 2, 3, 4, 5, 6});
    const Matrix b = matrix_from_values(3, 5, {
         1,  2,  3,  4,  5,
         6,  7,  8,  9, 10,
        11, 12, 13, 14, 15
    });
    const Matrix expected = matrix_from_values(2, 5, {
         46,  52,  58,  64,  70,
        100, 115, 130, 145, 160
    });
    check_product(a, b, expected);
}

void matmul_scalar() {
    check_product(matrix_from_values(1, 1, {-2.5f}),
                  matrix_from_values(1, 1, {4.0f}),
                  matrix_from_values(1, 1, {-10.0f}));
}

void matmul_dot_product() {
    // 1 * 4 + (-2) * 5 + 3 * (-6) = -24.
    check_product(matrix_from_values(1, 3, {1, -2, 3}),
                  matrix_from_values(3, 1, {4, 5, -6}),
                  matrix_from_values(1, 1, {-24}));
}

void matmul_outer_product() {
    check_product(matrix_from_values(3, 1, {2, -1, 0.5f}),
                  matrix_from_values(1, 5, {3, 0, -2, 4, 1}),
                  matrix_from_values(3, 5, {
                       6, 0, -4,  8,  2,
                      -3, 0,  2, -4, -1,
                    1.5f, 0, -1,  2, 0.5f
                  }));
}

void matmul_mixed_signs_and_fractions() {
    check_product(matrix_from_values(2, 3, {1, -2, 0.5f, 0, 3, -1}),
                  matrix_from_values(3, 5, {
                       2,  0, -1, 4,  1,
                       1, -2,  3, 0,  2,
                      -2,  4,  0, 1, -6
                  }),
                  matrix_from_values(2, 5, {
                      -1,   6, -7, 4.5f, -6,
                       5, -10,  9,   -1, 12
                  }));

    // Decimal fractions exercise rounding; these products cancel near zero.
    check_product(matrix_from_values(1, 3, {0.1f, 0.2f, -0.3f}),
                  matrix_from_values(3, 2, {1, 2, 1, -1, 1, 0}),
                  matrix_from_values(1, 2, {0, 0}));
}

void matmul_identity() {
    const Matrix a = matrix_from_values(2, 3, {1, -2, 0.5f, 0, 3, -1});
    const Matrix identity_2 = matrix_from_values(2, 2, {1, 0, 0, 1});
    const Matrix identity_3 = matrix_from_values(3, 3, {
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    });
    check_product(identity_2, a, a);
    check_product(a, identity_3, a);
}

void matmul_zero_operands() {
    const Matrix a = matrix_from_values(2, 3, {1, -2, 0.5f, 0, 3, -1});
    check_product(a, Matrix(3, 5), Matrix(2, 5));
    check_product(Matrix(4, 2), a, Matrix(4, 3));
}

void matmul_empty_outputs() {
    check_product(Matrix(0, 3), Matrix(3, 5), Matrix(0, 5));
    check_product(Matrix(2, 3), Matrix(3, 0), Matrix(2, 0));
    check_product(Matrix(0, 3), Matrix(3, 0), Matrix(0, 0));
    check_product(Matrix(0, 0), Matrix(0, 0), Matrix(0, 0));
}

void matmul_incompatible_empty_shapes() {
    struct Shapes { std::size_t a_rows, a_cols, b_rows, b_cols; };
    for (const auto& shape : {
             Shapes{0, 3, 2, 0}, Shapes{0, 3, 2, 5},
             Shapes{2, 3, 2, 0}, Shapes{2, 0, 1, 3}}) {
        const Matrix a(shape.a_rows, shape.a_cols);
        const Matrix b(shape.b_rows, shape.b_cols);
        expect_throw<std::invalid_argument>(
            [&] { (void)inference::matmul_reference(a, b); },
            "Multiplication accepted incompatible shapes with empty storage");
    }
}

void matmul_shared_input() {
    const Matrix a = matrix_from_values(2, 2, {1, 2, 3, 4});
    const Matrix expected = matrix_from_values(2, 2, {7, 10, 15, 22});
    check_product(a, a, expected);

    Matrix result = inference::matmul_reference(a, a);
    result(0, 0) = 99.0f;
    check(a(0, 0) == 1.0f, "Multiplication result shares input storage");
}

void matmul_deterministic_cases() {
    constexpr std::array<std::size_t, 8> dimensions = {0, 1, 2, 3, 5, 7, 13, 31};
    constexpr std::array<unsigned, 3> seeds = {17u, 12345u, 20260912u};
    for (const unsigned seed : seeds) {
        std::mt19937 random(seed);
        for (const std::size_t m : dimensions) {
            for (const std::size_t k : dimensions) {
                for (const std::size_t n : dimensions) {
                    try {
                        // Separate row/column fixtures avoid Matrix's indexing
                        // and the production kernel's row-col-k traversal.
                        std::vector<std::vector<float>> a_rows(m, std::vector<float>(k));
                        std::vector<std::vector<float>> b_cols(n, std::vector<float>(k));
                        Matrix a(m, k);
                        Matrix b(k, n);
                        // Explicit mapping keeps fixtures reproducible across
                        // standard libraries (no uniform_real_distribution).
                        const auto next_value = [&] {
                            return static_cast<float>(static_cast<int>(random() % 2001) - 1000)
                                   / 1000.0f;
                        };
                        for (std::size_t row = 0; row < m; ++row) {
                            for (std::size_t inner = 0; inner < k; ++inner) {
                                a_rows[row][inner] = next_value();
                                a.data()[row * k + inner] = a_rows[row][inner];
                            }
                        }
                        for (std::size_t col = 0; col < n; ++col) {
                            for (std::size_t inner = 0; inner < k; ++inner) {
                                b_cols[col][inner] = next_value();
                                b.data()[inner * n + col] = b_cols[col][inner];
                            }
                        }

                        // Outer-product oracle: accumulate in double, then
                        // round once to the expected FP32 output matrix.
                        std::vector<std::vector<double>> sums(m, std::vector<double>(n, 0.0));
                        for (std::size_t inner = 0; inner < k; ++inner) {
                            for (std::size_t col = 0; col < n; ++col) {
                                for (std::size_t row = 0; row < m; ++row) {
                                    sums[row][col] += static_cast<double>(a_rows[row][inner])
                                                    * static_cast<double>(b_cols[col][inner]);
                                }
                            }
                        }
                        Matrix expected(m, n);
                        for (std::size_t row = 0; row < m; ++row) {
                            for (std::size_t col = 0; col < n; ++col) {
                                expected.data()[row * n + col] = static_cast<float>(sums[row][col]);
                            }
                        }
                        // The 1e-5 tolerances in check_product are for these
                        // bounded inputs in [-1, 1] and reductions of at most 31.
                        check_product(a, b, expected);
                    } catch (const std::exception& error) {
                        std::ostringstream message;
                        message << "seed=" << seed << ", M=" << m
                                << ", K=" << k << ", N=" << n << ": " << error.what();
                        throw std::runtime_error(message.str());
                    }
                }
            }
        }
    }
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
        {"matmul square", matmul_square},
        {"matmul rectangular", matmul_rectangular},
        {"matmul incompatible shapes", matmul_incompatible_shapes},
        {"matmul_zero_inner_dimension", matmul_zero_inner_dimension},
        {"matrix comparison helper", matrix_comparison},
        {"matmul rectangular output", matmul_rectangular_output},
        {"matmul scalar", matmul_scalar},
        {"matmul dot product", matmul_dot_product},
        {"matmul outer product", matmul_outer_product},
        {"matmul mixed signs, fractions, and cancellation", matmul_mixed_signs_and_fractions},
        {"matmul left and right identity", matmul_identity},
        {"matmul zero operands", matmul_zero_operands},
        {"matmul empty outputs", matmul_empty_outputs},
        {"matmul incompatible empty shapes", matmul_incompatible_empty_shapes},
        {"matmul shared input and output ownership", matmul_shared_input},
        {"matmul 1536 deterministic cases against double oracle", matmul_deterministic_cases},
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
