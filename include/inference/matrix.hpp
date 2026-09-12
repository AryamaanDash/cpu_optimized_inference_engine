#ifndef MATRIX_HPP
#define MATRIX_HPP
#include <cstddef>
#include <vector>

namespace inference {

class Matrix {
public:
    Matrix(std::size_t rows, std::size_t cols);

//copy constructor & assignment
    Matrix(const Matrix& other) = default;
    Matrix& operator=(const Matrix& other) = default;

// move semantics
    Matrix(Matrix&& other) noexcept;
    Matrix& operator=(Matrix&& other) noexcept;

// getters for rows and cols
    std::size_t rows() const noexcept;
    std::size_t cols() const noexcept;

// functions to view (const) a specific value in the matrix
    float& operator()(std::size_t row, std::size_t col);
    const float& operator()(std::size_t row, std::size_t col) const;

// returns read only & mutable version of matrix
    float* data() noexcept;
    const float* data() const noexcept;

private:
    std::size_t rows_;
    std::size_t cols_;
    std::vector<float> data_;
};

Matrix matmul_reference(const Matrix& a, const Matrix& b);

}

#endif // MATRIX_HPP