##############################################################################
# \file  CMakeLists.txt
# \brief Root CMakeLists.txt file of testing component.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# CMake version
# ============================================================================

cmake_minimum_required (VERSION 2.8.2)

# ============================================================================
# template version
# ============================================================================

# Specifies the tagged project template which this project was instantiated
# from. This information is required by the automatic update of template
# files from the project template repository or working copy, respectively.
# Further, the BASIS CMake modules can make use of this variable for the
# purpose of backwards compatibility with previous template versions.

set (TEMPLATE_VERSION "0.0")

# ============================================================================
# BASIS
# ============================================================================

find_package (BASIS REQUIRED)

if (BASIS_FOUND)
  include ("${BASIS_USE_FILE}")
else ()
  return ()
endif ()

# ============================================================================
# settings
# ============================================================================

# configure custom CTest settings and/or copy them to binary tree
configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/CTestCustom.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake"
  @ONLY
)

# directories of test input data and expected output data
set (TESTING_DATA_DIR     "${CMAKE_CURRENT_SOURCE_DIR}/data")
set (TESTING_EXPECTED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/expected")

# ============================================================================
# start
# ============================================================================

basis_testing ("ReplaceByProjectName")

# ============================================================================
# subdirectories
# ============================================================================

# configure build system of test executables and/or add tests
add_subdirectory (src)

