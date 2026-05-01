cmake_minimum_required(VERSION 3.6)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

project(VirtioFS_C63_Benchmark)

file(GLOB DEC_SRCS "./*.cpp")

if (DEFINED UNIKERNEL)
  find_package(IncludeOS REQUIRED)
  include(os)

  add_compile_definitions(UNIKERNEL)

  os_add_executable(virtiofs_bench "C63IncludeOS" "${DEC_SRCS}")
  os_add_stdout(virtiofs_bench default_stdout)
  os_add_drivers(virtiofs_bench virtiofs)
else()
  add_executable(virtiofs_bench "${DEC_SRCS}")
  target_link_options(virtiofs_bench PRIVATE -static)
endif()
