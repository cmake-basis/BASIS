# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  Settings.cmake
# @brief Non-default project settings.
#
# This file is included by basis_project_impl() after it looked for the
# required and optional dependencies and the CMake variables related to the
# project directory structure were defined (see BASISDirectories.cmake file
# in @c PROJECT_BINARY_DIR, where BASIS is here the name of the project).
# It is also included before the BasisSettings.cmake file.
#
# In particular, build options should be added in this file using CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:option">
# option()</a> command. Further, any common settings related to using a found
# dependency can be set here if the basis_use_package() command was enable
# to import the required configuration of a particular external package.
#
# @ingroup BasisSettings
##############################################################################

# ============================================================================
# directories
# ============================================================================

# change default installation directory as name of BASIS package has changed
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  string (REPLACE "/basis" "/cmake-basis" _PREFIX "${CMAKE_INSTALL_PREFIX}")
  set (CMAKE_INSTALL_PREFIX "${_PREFIX}" CACHE PATH "Installation prefix." FORCE)
  unset (_PREFIX)
endif ()

# installation directory of CMake modules
set (INSTALL_MODULES_DIR      "${INSTALL_SHARE_DIR}/modules")
set (INSTALL_FIND_MODULES_DIR "${INSTALL_SHARE_DIR}/find-modules")

# installation directory of utilities template files
set (INSTALL_CXX_TEMPLATES_DIR    "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_JAVA_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_PYTHON_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_PERL_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_MATLAB_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_BASH_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities")

# common prefix of Sphinx extensions
set (SPHINX_EXTENSIONS_PREFIX "basis/sphinx/ext/")
# installation directory of Sphinx themes
set (INSTALL_SPHINX_THEMES_DIR "${INSTALL_SHARE_DIR}/sphinx-themes")

# ============================================================================
# utilities
# ============================================================================

# system checks
include (CheckTypeSize)
include (CheckIncludeFileCXX)

# check if type long long is supported
CHECK_TYPE_SIZE ("long long" LONG_LONG)

if (HAVE_LONG_LONG)
  set (HAVE_LONG_LONG 1)
else ()
  set (HAVE_LONG_LONG 0)
endif ()

# check for presence of sstream header
include (TestForSSTREAM)

if (CMAKE_NO_ANSI_STRING_STREAM)
  set (HAVE_SSTREAM 0)
else ()
  set (HAVE_SSTREAM 1)
endif ()

# check if tr/tuple header file is available
if (CMAKE_GENERATOR MATCHES "Visual Studio [1-9][0-9]+")
  set (HAVE_TR1_TUPLE 1)
else ()
  CHECK_INCLUDE_FILE_CXX ("tr1/tuple" HAVE_TR1_TUPLE)
  if (HAVE_TR1_TUPLE)
    set (HAVE_TR1_TUPLE 1)
  else ()
    set (HAVE_TR1_TUPLE 0)
  endif ()
endif ()

# check for availibility of pthreads library
# defines CMAKE_USE_PTHREADS_INIT and CMAKE_THREAD_LIBS_INIT
find_package (Threads QUIET)

if (Threads_FOUND)
  if (CMAKE_USE_PTHREADS_INIT)
    set (HAVE_PTHREAD 1)
  else  ()
    set (HAVE_PTHREAD 0)
  endif ()
endif ()

# list of enabled utilities
# in case of other projects defined by BASISConfig.cmake
set (BASIS_UTILITIES_ENABLED CXX)
if (PythonInterp_FOUND)
  list (APPEND BASIS_UTILITIES_ENABLED PYTHON)
endif ()
if (Perl_FOUND)
  list (APPEND BASIS_UTILITIES_ENABLED PERL)
endif ()
if (BASH_FOUND)
  list (APPEND BASIS_UTILITIES_ENABLED BASH)
endif ()

# configure all BASIS utilities such that they are included in API
# documentation even if BASIS does not use them itself
if (Java_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_JAVA_UTILITIES TRUE)
endif ()
if (PythonInterp_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_PYTHON_UTILITIES TRUE)
endif ()
if (Perl_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_PERL_UTILITIES TRUE)
endif ()
if (BASH_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_BASH_UTILITIES TRUE)
endif ()
if (MATLAB_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_MATLAB_UTILITIES TRUE)
endif ()

# target UIDs of BASIS libraries; these would be set by the package configuration
# file if this BASIS project would not be BASIS itself
if (BASIS_USE_TARGET_UIDS AND BASIS_USE_FULLY_QUALIFIED_UIDS)
  set (NS "basis.")
else ()
  set (NS)
endif ()
set (BASIS_CXX_UTILITIES_LIBRARY    "${NS}utilities_cxx")
set (BASIS_PYTHON_UTILITIES_LIBRARY "${NS}utilities_python")
set (BASIS_PERL_UTILITIES_LIBRARY   "${NS}utilities_perl")
set (BASIS_BASH_UTILITIES_LIBRARY   "${NS}utilities_bash")
set (BASIS_TEST_LIBRARY             "${NS}testlib")
set (BASIS_TEST_MAIN_LIBRARY        "${NS}testmain")

# ============================================================================
# configure public header files
# ============================================================================

if (NOT BASIS_CONFIGURE_PUBLIC_HEADERS)
  configure_file ("include/basis/config.h.in" "${BINARY_INCLUDE_DIR}/basis/config.h")
endif ()
