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
# subdirectories
# ============================================================================

add_subdirectory (ressources)
add_subdirectory (tools)
add_subdirectory (utilities)
