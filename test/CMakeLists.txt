##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of software testing.
#
# Unit tests test only single functions, classes, and modules of the software.
# System tests, on the other side, execute the programs of this package with
# given test input data and compare the output of the programs to the expected
# results.
#
# The built test executables can be found in @c TESTING_RUNTIME_DIR.
# The test output shall be written to @c TESTING_OUTPUT_DIR. In most cases,
# a subdirectory for each test should be created under this output directory.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# output directories
# ============================================================================

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${TESTING_LIBRARY_DIR}")
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${TESTING_LIBRARY_DIR}")

# ============================================================================
# settings
# ============================================================================

## @brief Directory of BASIS used by tests to build test projects.
set (TESTING_BASIS_DIR "${PROJECT_BINARY_DIR}")
## @brief Build type used to build test projects.
set (TESTING_BUILD_TYPE "${CMAKE_BUILD_TYPE}")

## @brief Whether C++ utilities are build.
set (TEST_CXX_UTILITIES "${BUILD_UTILITIES_FOR_CXX}")
## @brief Whether Python utilities are build.
set (TEST_PYTHON_UTILITIES "${BUILD_UTILITIES_FOR_PYTHON}")
## @brief Whether Perl utilities are build.
set (TEST_PERL_UTILITIES "${BUILD_UTILITIES_FOR_PERL}")
## @brief Whether BASH utilities are build.
set (TEST_BASH_UTILITIES "${BUILD_UTILITIES_FOR_BASH}")

# ============================================================================
# subdirectories
# ============================================================================

add_subdirectory (ressources)
add_subdirectory (tools)
add_subdirectory (utilities)
