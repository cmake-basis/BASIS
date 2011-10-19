##############################################################################
# @file  CMakeLists.txt
# @brief Root build configuration file.
#
# This is the root build configuration of the BASIS package. As can be noted
# does BASIS make use of exactly the standard it advocates and hence also the
# CMake modules which implement this standard. Therefore, these modules are
# considered the cornerstone of BASIS.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# CMake version
# ============================================================================

# Note: There is a bug in CMake version 2.8.2 which prevents the following
#       command to execute correctly:
#
#         cmake "-DCOMMAND=CFLAGS=-Wall [...]" -P ExecuteProcess.cmake
#
#       because of the occurrence of an equal sign (=) within the value
#       assigned to variable COMMAND. This bug was apparently fixed in
#       CMake version 2.8.4. A command such as the one above is required to
#       build MEX-files using the MEX script and MATLAB Compiler targets.
cmake_minimum_required (VERSION 2.8.4)

# ============================================================================
# initialize
# ============================================================================

# use invalid template version to indicate that this project is not
# instantiated from a template as this package provides the template
set (TEMPLATE_VERSION "0.0.0")

# the following variables would be set by the BASISConfig.cmake file if
# this would be a project which uses BASIS; in fact, this *is* BASIS, though
set (BASIS_MODULE_PATH          "${CMAKE_CURRENT_SOURCE_DIR}/src/modules")
set (BASIS_INCLUDE_DIR          "${CMAKE_CURRENT_SOURCE_DIR}/include")
set (BASIS_LIBRARY_DIR          "${CMAKE_CURRENT_BINARY_DIR}/lib")
set (BASIS_CXX_TEMPLATES_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/cxx")
set (BASIS_PYTHON_TEMPLATES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/python")
set (BASIS_PERL_TEMPLATES_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/perl")
set (BASIS_BASH_TEMPLATES_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/bash")
set (BASIS_PYTHON_LIBRARY_DIR   "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/python")
set (BASIS_PERL_LIBRARY_DIR     "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/perl5")

# include BASIS policies, settings, macros, and functions
include ("${BASIS_MODULE_PATH}/BasisProject.cmake" NO_POLICY_SCOPE)

# select languages used by this project
set (LANGUAGES "LANGUAGES")
if (BUILD_CXX_UTILITIES)
  list (APPEND LANGUAGES "CXX")
endif ()
if (BUILD_PYTHON_UTILITIES)
  list (APPEND LANGUAGES "Python")
endif ()
if (BUILD_PERL_UTILITIES)
  list (APPEND LANGUAGES "Perl")
endif ()
if (BUILD_BASH_UTILITIES)
  list (APPEND LANGUAGES "BASH")
endif ()

# initialize project
basis_project_initialize (
  NAME        "BASIS"
  VERSION     "0.0.0"
  DESCRIPTION "This package implements and supports the development of"
              " software which follows the SBIA Build system And Software"
              " Implementation Standard (BASIS)."
  ${LANGUAGES}
)

# ============================================================================
# subdirectories
# ============================================================================

# source code of programs
if (EXISTS "${PROJECT_CODE_DIR}")
  add_subdirectory ("${PROJECT_CODE_DIR}")
endif ()

# auxiliary data files
if (EXISTS "${PROJECT_DATA_DIR}")
  add_subdirectory ("${PROJECT_DATA_DIR}")
endif ()

# package documentation
if (EXISTS "${PROJECT_DOC_DIR}" AND BUILD_DOCUMENTATION)
  add_subdirectory ("${PROJECT_DOC_DIR}")
endif ()

# example application
if (EXISTS "${PROJECT_EXAMPLE_DIR}" AND BUILD_EXAMPLE)
  add_subdirectory ("${PROJECT_EXAMPLE_DIR}")
endif ()

# software testing
if (EXISTS "${PROJECT_TESTING_DIR}" AND BUILD_TESTING)
  add_subdirectory ("${PROJECT_TESTING_DIR}")
endif ()

# ============================================================================
# finalize
# ============================================================================

basis_project_finalize ()

