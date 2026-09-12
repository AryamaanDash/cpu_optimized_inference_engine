#include "inference/matrix.hpp"
#include <stdexcept>
#include <utility>

namespace inference{
    Matrix::Matrix(std::size_t rows, std::size_t cols){
        if(cols != 0 && rows > data_.max_size() / cols){
            throw std::length_error("Matrix dimensions are too large");
        }
        rows_ = rows;
        cols_ = cols;
        data_.resize(rows * cols, 0.0f);
    }

    Matrix& Matrix::operator=(const Matrix& other){
        if(this != &other){
            // Finish the potentially throwing copy before changing this matrix.
            Matrix copy(other);
            *this = std::move(copy);
        }
        return *this;
    }

    Matrix::Matrix(Matrix&& other) noexcept
    : rows_(other.rows_), cols_(other.cols_), data_(std::move(other.data_))
    {
        other.rows_ = 0;
        other.cols_ = 0;
        other.data_.clear();
    }

    Matrix& Matrix::operator=(Matrix&& other) noexcept{
        if(this != &other){
        rows_ = other.rows_;
        cols_ = other.cols_;
        data_ = std::move(other.data_);
        other.rows_ = 0;
        other.cols_ = 0;
        other.data_.clear();
        }
        return *this;
    }

    std::size_t Matrix::rows() const noexcept{
        return rows_;
    }

    std::size_t Matrix::cols() const noexcept{
        return cols_;
    }

    float& Matrix::operator()(std::size_t row, std::size_t col){
        if(row >= rows_ || col >= cols_){
            throw std::out_of_range("Given input is out of range");
        }
        return data_[row * cols_ + col];
    }

    const float& Matrix::operator()(std::size_t row, std::size_t col) const{
        if(row >= rows_ || col >= cols_){
            throw std::out_of_range("Given input is out of range");
        }
        return data_[row * cols_ + col];
    }

    float* Matrix::data() noexcept{
        return data_.data();
    }
    
    const float* Matrix::data() const noexcept{
        return data_.data();
    }

    Matrix matmul_reference(const Matrix& a, const Matrix& b){
            if(a.cols() != b.rows()){
                throw std::invalid_argument("Columns of first matrix must match rows of second matrix");
            }
            Matrix result(a.rows(), b.cols());
            for(std::size_t row = 0; row < result.rows(); ++row){
                for(std::size_t col = 0; col < result.cols(); ++col){
                    float total = 0.0f;
                    for(std::size_t k = 0; k < b.rows(); ++k){
                        total += a(row, k) * b(k, col);
                    }
                    result(row, col) = total;
                }
            }
            return result;
    }
}
