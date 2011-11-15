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

# The version of the template this project was instantiated from.
# This information might be used by BASIS to maintain backwards compatibility.
#
# Note that this version in case of the BASIS project itself defines the
# current version of the project template. Thus, this version number has to
# be changed whenever the project template was modified.
#
# A patch version number is not used here because subtle changes of the
# template files do not need to be tracked. This version number may only
# become of importance in case the project template is noticably extended or
# modified, which has to be done with care, however, in any case and should
# be avoided.
set (TEMPLATE_VERSION "1.0")

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
option (BUILD_UTILITIES_FOR_CXX    "Whether to build the C++ utilities."    ON)
option (BUILD_UTILITIES_FOR_PYTHON "Whether to build the Python utilities." ON)
option (BUILD_UTILITIES_FOR_PERL   "Whether to build the Perl utilities."   ON)

if (UNIX)
  option (BUILD_UTILITIES_FOR_BASH "Whether to build the BASH utilities." ON)
else ()
  set (BUILD_UTILITIES_FOR_BASH OFF)
endif ()

set (LANGUAGES "LANGUAGES")
if (BUILD_UTILITIES_FOR_CXX)
  list (APPEND LANGUAGES "CXX")
endif ()
if (BUILD_UTILITIES_FOR_PYTHON)
  list (APPEND LANGUAGES "Python")
endif ()
if (BUILD_UTILITIES_FOR_PERL)
  list (APPEND LANGUAGES "Perl")
endif ()
if (BUILD_UTILITIES_FOR_BASH)
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
