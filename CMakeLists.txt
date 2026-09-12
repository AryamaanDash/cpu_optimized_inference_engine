cmake_minimum_required(VERSION 3.20)

project(INFERENCE_DEMO)

add_library(inference src/matrix.cpp)
target_include_directories(inference PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_compile_features(inference PUBLIC cxx_std_20)

add_executable(inference_demo src/main.cpp)
target_compile_features(inference_demo PRIVATE cxx_std_20)

enable_testing()
add_test(NAME smoke COMMAND inference_demo)

add_executable(matrix_tests tests/matrix_tests.cpp)
target_link_libraries(matrix_tests PRIVATE inference)
add_test(NAME matrix COMMAND matrix_tests)

add_executable(matrix_copy_assignment_tests tests/matrix_copy_assignment_tests.cpp)
target_link_libraries(matrix_copy_assignment_tests PRIVATE inference)
add_test(NAME matrix_copy_assignment COMMAND matrix_copy_assignment_tests)
