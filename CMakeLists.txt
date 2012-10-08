##############################################################################
# @file  CMakeLists.txt
# @brief Root build configuration file.
#
# This is the root build configuration of the BASIS package. As can be noted
# does BASIS make use of exactly the standard it advocates and hence also the
# CMake modules which implement this standard. Therefore, these modules are
# considered the cornerstone of BASIS.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
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
# version of BASIS template used by this project
set (TEMPLATE_VERSION 1.7)

# Note that this version in case of the BASIS project itself defines the
# current version of the project template. Thus, this version number has to
# be changed whenever a new (modified) project template was added.
#
# A patch version number is not used here because subtle changes of the
# template files do not need to be tracked. This version number may only
# become of importance in case the project template is noticably extended or
# modified, which has to be done with care, however, in any case and should
# be avoided.

# ----------------------------------------------------------------------------
# include BASIS policies, settings, macros, and functions

# The following variables would be set by the BASISConfig.cmake file if
# this would be a project which uses BASIS.

set (BASIS_MODULE_PATH            "${CMAKE_CURRENT_SOURCE_DIR}/src/cmake")

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

include ("${BASIS_MODULE_PATH}/BasisTools.cmake")
include ("${BASIS_MODULE_PATH}/BasisSettings.cmake" NO_POLICY_SCOPE)

# ----------------------------------------------------------------------------
# configure build system
basis_project_impl ()
