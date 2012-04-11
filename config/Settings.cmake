##############################################################################
# @file  Settings.cmake
# @brief Non-default project settings.
#
# This file is included by basis_project_impl() after it looked for the
# required and optional dependencies and the CMake variables related to the
# project directory structure were defined (see BASISDirectories.cmake file
# in @c PROJECT_BINARY_DIR, where BASIS is here the name of the project).
# It is further included before the BasisSettings.cmake file.
#
# In particular, build options should be added in this file using CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:option">
# option()</a> command. Further, any common settings related to using a found
# dependency can be set here if the basis_use_package() command was enable
# to import the required configuration of a particular external package.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisSettings
##############################################################################

# ============================================================================
# options
# ============================================================================

option (USE_CXX "Enable use of C++ utilities" ON)

set (BUILD_UTILITIES_FOR_CXX    ${USE_CXX})            # USE_CXX option
set (BUILD_UTILITIES_FOR_PYTHON ${PythonInterp_FOUND}) # USE_PythonInterp option
set (BUILD_UTILITIES_FOR_PERL   ${Perl_FOUND})         # USE_Perl option
set (BUILD_UTILITIES_FOR_BASH   ${BASH_FOUND})         # USE_BASH option

set (BASIS_UTILITIES_ENABLED) # set in BASISConfig.cmake for other projects
if (BUILD_UTILITIES_FOR_CXX)
  list (APPEND BASIS_UTILITIES_ENABLED CXX)
endif ()
if (BUILD_UTILITIES_FOR_PYTHON)
  list (APPEND BASIS_UTILITIES_ENABLED PYTHON)
endif ()
if (BUILD_UTILITIES_FOR_PERL)
  list (APPEND BASIS_UTILITIES_ENABLED PERL)
endif ()
if (BUILD_UTILITIES_FOR_BASH)
  list (APPEND BASIS_UTILITIES_ENABLED BASH)
endif ()

# ============================================================================
# directories
# ============================================================================

# installation directory of CMake modules
set (INSTALL_MODULES_DIR "${INSTALL_SHARE_DIR}/cmake")

# installation directory of utilities template files
set (INSTALL_CXX_TEMPLATES_DIR    "${INSTALL_SHARE_DIR}/utilities/cxx")
set (INSTALL_JAVA_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities/java")
set (INSTALL_PYTHON_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/utilities/python")
set (INSTALL_PERL_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities/perl")
set (INSTALL_BASH_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities/bash")
set (INSTALL_MATLAB_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/utilities/matlab")

# installation directory of project template files
set (INSTALL_TEMPLATE_DIR "${INSTALL_SHARE_DIR}/template")

# ============================================================================
# general settings
# ============================================================================

# do not copy public header files to build tree
set (BASIS_AUTO_PREFIX_INCLUDES FALSE)
# specify regular expressions of public header files which are excluded
# from the check whether their path is prefixed by INCLUDE_PREFIX
set (BASIS_INCLUDES_CHECK_EXCLUDE
  "^sbia/gtest/"
  "^sbia/gmock/"
  "^sbia/tclap/"
)

# ============================================================================
# utilities
# ============================================================================

# configure all BASIS utilities such that they are included in API
# documentation even if BASIS does not use them itself
if (BUILD_UTILITIES_FOR_JAVA)
  basis_set_project_property (PROPERTY PROJECT_USES_JAVA_UTILITIES TRUE)
endif ()
if (BUILD_UTILITIES_FOR_PYTHON)
  basis_set_project_property (PROPERTY PROJECT_USES_PYTHON_UTILITIES TRUE)
endif ()
if (BUILD_UTILITIES_FOR_PERL)
  basis_set_project_property (PROPERTY PROJECT_USES_PERL_UTILITIES TRUE)
endif ()
if (BUILD_UTILITIES_FOR_BASH)
  basis_set_project_property (PROPERTY PROJECT_USES_BASH_UTILITIES TRUE)
endif ()
if (BUILD_UTILITIES_FOR_MATLAB)
  basis_set_project_property (PROPERTY PROJECT_USES_MATLAB_UTILITIES TRUE)
endif ()

# target UIDs of BASIS libraries; these would be set by the package configuration
# file if this BASIS project would not be BASIS itself
if (BASIS_USE_FULLY_QUALIFIED_UIDS)
  set (BASIS_UTILITIES_LIBRARY "sbia.basis.utilities")
  set (BASIS_TEST_LIBRARY      "sbia.basis.testlib")
  set (BASIS_TEST_MAIN_LIBRARY "sbia.basis.testmain")
else ()
  set (BASIS_UTILITIES_LIBRARY "utilities")
  set (BASIS_TEST_LIBRARY      "testlib")
  set (BASIS_TEST_MAIN_LIBRARY "testmain")
endif ()
