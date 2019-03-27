cmake_minimum_required(VERSION 3.1)

# так пишутся комментарии

project(cuda_second_program LANGUAGES CXX CUDA)

set(SOURCE_EXE main.cpp )

find_package(CUDA)
find_package(OpenMP)

set(SOURCE_LIB solver_file.cu)
add_library(cuda_path SHARED ${SOURCE_LIB})
set(MYLIB cuda_path)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fopenmp") # задаем флаги компилятору

include_directories(include) # расположение основных заголовочных файлов

add_executable(run_file ${SOURCE_EXE}) # создает исполняемый файл run_file

target_link_libraries(run_file ${MYLIB} )

find_package(OpenGL REQUIRED)
find_package(GLUT REQUIRED)
include_directories( ${OPENGL_INCLUDE_DIRS}  ${GLUT_INCLUDE_DIRS} )
target_link_libraries(run_file ${OPENGL_LIBRARIES} ${GLUT_LIBRARY} )


