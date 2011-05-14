##############################################################################
# \file  CMakeLists.txt
# \brief Root CMakeLists.txt file of software component.
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
# BASIS
# ============================================================================

# The next variable specifies the tagged BASIS template which this project
# was instantiated from. This information is required by the automatic update
# of template files from the project template repository or working copy,
# respectively. Further, the BASIS CMake modules can make use of this variable
# for the purpose of backwards compatibility with previous template versions.

set (TEMPLATE_VERSION "0.0")

find_package (BASIS REQUIRED)

if (BASIS_FOUND)
  include ("${BASIS_USE_FILE}")
else ()
  return ()
endif ()

# ============================================================================
# start
# ============================================================================

# The following macro call replaces the CMake command project ().
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

# software component
add_subdirectory ("${SOFTWARE_SOURCE_DIR}")

if (EXISTS "${SOFTWARE_DATA_DIR}")
  add_subdirectory ("${SOFTWARE_DATA_DIR}")
endif ()

if (EXISTS "${SOFTWARE_TESTS_DIR}" AND BUILD_TESTING)
  add_subdirectory ("${SOFTWARE_TESTS_DIR}")
endif ()

add_subdirectory ("${SOFTWARE_DOC_DIR}")

# optionally traverse into subdirectories of other major components
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

