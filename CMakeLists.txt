# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Root build configuration file.
#
# This is the root build configuration of the BASIS package. As can be noted
# does BASIS make use of exactly the standard it advocates and hence also the
# CMake modules which implement this standard. Therefore, these modules are
# considered the cornerstone of BASIS.
##############################################################################

# ----------------------------------------------------------------------------
# minimum required CMake version

# There is a bug in CMake version 2.8.2 which prevents the following command
# to execute correctly:
#
#   cmake "-DCOMMAND=CFLAGS=-Wall [...]" -P ExecuteProcess.cmake
#
# because of the occurrence of an equal sign (=) within the value assigned to
# variable COMMAND. This bug was apparently fixed in CMake version 2.8.4.
# A command such as the one above is required to build MEX-files using the
# MEX script and MATLAB Compiler targets.

cmake_minimum_required (VERSION 2.8.4)

# ----------------------------------------------------------------------------
# BASIS Utilities settings from BASISConfig.cmake

set (BASIS_CXX_TEMPLATES_DIR      "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/cxx")
set (BASIS_PYTHON_TEMPLATES_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/python")
set (BASIS_JYTHON_TEMPLATES_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/jython")
set (BASIS_PERL_TEMPLATES_DIR     "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/perl")
set (BASIS_MATLAB_TEMPLATES_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/matlab")
set (BASIS_BASH_TEMPLATES_DIR     "${CMAKE_CURRENT_SOURCE_DIR}/src/utilities/bash")

set (BASIS_INCLUDE_DIR            "${CMAKE_CURRENT_SOURCE_DIR}/include")
set (BASIS_LIBRARY_DIR            "${CMAKE_CURRENT_BINARY_DIR}/lib")
set (BASIS_PYTHONPATH             "${BASIS_LIBRARY_DIR}/python")
set (BASIS_JYTHONPATH             "${BASIS_LIBRARY_DIR}/jython")
set (BASIS_PERL5LIB               "${BASIS_LIBRARY_DIR}/perl5")
set (BASIS_MATLABPATH             "${BASIS_LIBRARY_DIR}/matlab")
set (BASIS_BASHPATH               "${BASIS_LIBRARY_DIR}/bash")

set (BASIS_SPHINX_EXTENSIONS_PATH "${BASIS_PYTHONPATH}/basis/sphinx/ext")
set (BASIS_SPHINX_HTML_THEME_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src/sphinx/themes")

# ----------------------------------------------------------------------------
# include BASIS policies, settings, macros, and functions

set (BASIS_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/src/cmake")

include ("${BASIS_MODULE_PATH}/BasisSettings.cmake" NO_POLICY_SCOPE)
include ("${BASIS_MODULE_PATH}/BasisTools.cmake")

# ----------------------------------------------------------------------------
# configure build system
basis_project_impl ()
