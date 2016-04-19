# ============================================================================
# Copyright (c) <copyright>
# All rights reserved.
#
# <license>
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Root build configuration file.
#
# @note Based on <a href="https://cmake-basis.github.io">CMake BASIS</a>.
##############################################################################

# ----------------------------------------------------------------------------
# minimum required CMake version
cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)
set (MINIMUM_BASIS_VERSION "3.3.0")

# ----------------------------------------------------------------------------
# include BASIS policies, settings, macros, and functions

set (PROJECT_CONFIG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/config")
set (CMAKE_MODULE_PATH  "${PROJECT_CONFIG_DIR}" ${CMAKE_MODULE_PATH})

# look for an existing CMake BASIS installation and use it if found
# otherwise, attempt to download and install it locally
if (NO_BASIS_BOOTSTRAPPING)
  find_package (BASIS ${MINIMUM_BASIS_VERSION} REQUIRED)
elseif (NOT BASIS_BOOTSTRAPPING)
  find_package (BASIS QUIET)
endif ()
if (NOT BASIS_FOUND)
  if (EXISTS "${PROJECT_CONFIG_DIR}/BasisBootstrapping.cmake")
    include ("${PROJECT_CONFIG_DIR}/BasisBootstrapping.cmake")
  else ()
    message (FATAL_ERROR "Could not find an existing CMake BASIS installation!\n"
                         "This project uses CMake BASIS for the build configuration."
                         " Visit https://cmake-basis.github.io for"
                         " more information about the CMake BASIS package.\n")
  endif ()
  # download and install BASIS in build tree of project
  basis_bootstrap(
    VERSION ${MINIMUM_BASIS_VERSION}
    WITH_MATLAB OFF # Enable/disable Matlab support
    WITH_Python OFF # Enable/disable Python support
    WITH_Jython OFF # Enable/disable Jython support
    WITH_Perl   OFF # Enable/disalbe Perl   support
    WITH_BASH   OFF # Enable/disable Bash   support
    WITH_ITK    OFF # Enable/disable image processing regression testing
    INFORM_USER     # Inform user during first configure step that
                    # CMake BASIS needs to be bootstrapped or installed manually
  )
  # look for local installation
  find_package (BASIS QUIET)
  if (NOT BASIS_FOUND)
    message (FATAL_ERROR "CMake BASIS setup failed. Please take the following steps:\n"
                         "\t1. Clear the CMake cache and try from scratch\n"
                         "\t2. Check the CMake BASIS website:\n"
                         "\t\thttps://cmake-basis.github.io/\n"
                         "\t3. Search for an existing issue:\n"
                         "\t\thttps://github.com/cmake-basis/BASIS/issues/\n"
                         "\t4. If this did not resolve the issue, please report your problem:\n"
                         "\t\thttps://github.com/cmake-basis/BASIS/issues/new\n"
                         "\t5. Try a manual build of CMake BASIS following the instructions at:\n"
                         "\t\thttps://cmake-basis.github.io/quickstart.html"
    )
  endif ()
else ()
  set (BASIS_INSTALL_PREFIX "${DEPENDS_BASIS_DIR}")
endif ()

# ----------------------------------------------------------------------------
# configure build system
basis_project_impl ()

# raise error if project uses the CMake BASIS Utilities, but these libraries
# were not installed in a system location as part of the bootstrapping
if (DEFINED BASIS_INSTALL_PREFIX_CONFIGURED AND NOT BASIS_INSTALL_PREFIX_CONFIGURED)
  basis_get_project_uses_utilities (PROJECT_USES_BASIS_UTILITIES)
  if (PROJECT_USES_BASIS_UTILITIES)
    message (FATAL_ERROR "This project uses the CMake BASIS Utilities. Therefore CMake BASIS"
                         " must be installed permanently. Please specify the location"
                         " where to install BASIS using the BASIS_INSTALL_PREFIX"
                         " variable and re-run CMake in order to first install BASIS"
                         " and then re-configure this project to use this installation.")
  endif ()
endif ()
