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
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# settings
# ============================================================================

## @brief Directory of BASIS used by tests to build test projects.
set (TESTING_BASIS_DIR "${PROJECT_BINARY_DIR}")

## @brief Build type used to build test projects.
set (TESTING_BUILD_TYPE "${CMAKE_BUILD_TYPE}")
## @brief Compiler flags to use for build of test projects.
set (TESTING_C_FLAGS "${CMAKE_C_FLAGS}")
## @brief Compiler flags to use for build of test projects.
set (TESTING_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
## @brief Linker flags to use for build of test projects.
set (TESTING_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
## @brief Linker flags to use for build of test projects.
set (TESTING_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
## @brief Linker flags to use for build of test projects.
set (TESTING_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS}")

## @brief Whether Python utilities are build.
set (TEST_PYTHON_UTILITIES "${PythonInterp_FOUND}")
## @brief Whether Perl utilities are build.
set (TEST_PERL_UTILITIES "${Perl_FOUND}")
## @brief Whether BASH utilities are build.
set (TEST_BASH_UTILITIES "${BASH_FOUND}")

# ============================================================================
# utilities
# ============================================================================

if (BASIS_UTILITIES_ENABLED MATCHES "PYTHON")
  basis_add_script (testaux.py)
endif ()

# ============================================================================
# subdirectories
# ============================================================================

add_subdirectory (ressources)
add_subdirectory (cmake)
add_subdirectory (tools)
add_subdirectory (utilities)
