##############################################################################
# \file  CMakeLists.txt
# \brief Root CMake configuration file.
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

# use invalid template version to indicate that this project is not
# instantiated from a template as this package contains the template
set (TEMPLATE_VERSION "0.0")

# include BASIS policies, settings, macros, and functions
set (BASIS_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src/cmake")
set (BASIS_UPDATE "OFF" CACHE INTERNAL "" FORCE)
include ("${BASIS_MODULE_PATH}/BasisProject.cmake" NO_POLICY_SCOPE)

# initialize project
basis_project_initialize (
  NAME        BASIS
  VERSION     1.0.0
  DESCRIPTION "This package implements and supports the development of"
              " software which follows the SBIA Build And Software"
              " Implementation Standard (BASIS)."
)

# ============================================================================
# subdirectories
# ============================================================================

if (EXISTS "${PROJECT_CODE_DIR}")
  add_subdirectory ("${PROJECT_CODE_DIR}")
endif ()

if (EXISTS "${PROJECT_DATA_DIR}")
  add_subdirectory ("${PROJECT_DATA_DIR}")
endif ()

if (EXISTS "${PROJECT_DOC_DIR}")
  add_subdirectory ("${PROJECT_DOC_DIR}")
endif ()

if (EXISTS "${PROJECT_EXAMPLE_DIR}" AND BUILD_EXAMPLE)
  add_subdirectory ("${PROJECT_EXAMPLE_DIR}")
endif ()

if (EXISTS "${PROJECT_TESTING_DIR}" AND BUILD_TESTING)
  add_subdirectory ("${PROJECT_TESTING_DIR}")
endif ()

# ============================================================================
# finalize
# ============================================================================

basis_project_finalize ()

