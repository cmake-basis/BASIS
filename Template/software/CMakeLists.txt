##############################################################################
# \file  CMakeLists.txt
# \brief Root CMake configuration file of software component.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# CMake version
# ============================================================================

cmake_minimum_required (VERSION 2.8.2)

# ============================================================================
# initialize
# ============================================================================

# The TEMPLATE_VERSION variable specifies the version of the BASIS Template
# which this project was instantiated from. This information is required by
# the automatic update of template files (see documentation of BASIS Core).
# Further, the BASIS Core functions might make use of this variable to ensure
# backwards compatibility with previous template versions.

set (TEMPLATE_VERSION "0.0")

find_package (BASIS REQUIRED)

if (NOT BASIS_FOUND)
  return ()
endif ()

include ("${BASIS_USE_FILE}")

# The following macro call replaces the CMake command project ().
#
# Besides calling this command, it sets further common CMake variables such
# as PROJECT_NAME_UPPER, PROJECT_NAME_LOWER, PROJECT_VERSION_MAJOR,
# PROJECT_VERSION_MINOR, PROJECT_VERSION_PATCH,... please refer to
# the documentation of the macro for a list of available variables.
#
# The project attributes have to be specified as CMake variables in the
# CMake module SOFTWARE_CONFIG_DIR/Settings.cmake.
#
# The common CMake variables PROJECT_SOURCE_DIR and PROJECT_BINARY_DIR
# should be used in the subsequent CMake code to refer to the source or
# binary tree of the project. DO NOT use CMAKE_SOURCE_DIR and CMAKE_BINARY_DIR
# as these variables differ from the project specific variables when the
# project is part of a superproject.
#
# \see basis_project ()

basis_project ("ReplaceByProjectName")

# ============================================================================
# subdirectories
# ============================================================================

add_subdirectory ("${SOFTWARE_SOURCE_DIR}")

if (EXISTS "${SOFTWARE_DATA_DIR}")
  add_subdirectory ("${SOFTWARE_DATA_DIR}")
endif ()

if (EXISTS "${SOFTWARE_TESTS_DIR}" AND BUILD_TESTING)
  add_subdirectory ("${SOFTWARE_TESTS_DIR}")
endif ()

add_subdirectory ("${SOFTWARE_DOC_DIR}")

# optionally traverse into subdirectories of other major components, too
if (EXISTS "${PROJECT_EXAMPLE_DIR}")
  add_subdirectory ("${PROJECT_EXAMPLE_DIR}")
endif ()

if (EXISTS "${PROJECT_TESTING_DIR}" AND BUILD_TESTING)
  add_subdirectory ("${PROJECT_TESTING_DIR}")
endif ()

# ============================================================================
# finalize
# ============================================================================

# finalize configuration of project
basis_project_finalize ()

