cmake_minimum_required(VERSION 3.20)

project(INFERENCE_DEMO)

add_executable(inference_demo src/main.cpp)
target_compile_features(inference_demo PRIVATE cxx_std_20)