cmake_minimum_required(VERSION 3.16.0)
# Predefine time_t size to avoid CMake check failing during cross-compilation
# This is used by the esp-idf framework CMake which tries to auto-detect
# sizeof(time_t) by compiling a small test program. When cross-compiling
# that test may fail; set the cache variable here to skip detection.
set(TIME_T_SIZE 8 CACHE INTERNAL "size of time_t in bytes")
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(DEMO_LVGL)
