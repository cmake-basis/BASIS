# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  ConfigSettings.cmake
# @brief Sets variables used in CMake package configuration.
#
# It is suggested to use @c _CONFIG as suffix for variable names that are to
# be substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# @note The default BasisConfigSettings.cmake file which is part of the BASIS
#       installation is included prior to this file. Hence, the variables are
#       valid even if a custom project-specific configuration is used and
#       default values can further be overwritten in this file.
#
# @ingroup BasisSettings
##############################################################################

# ============================================================================
# common settings
# ============================================================================

## @brief List of enabled BASIS utilities.
set (UTILITIES_ENABLED ${BASIS_UTILITIES_ENABLED})

basis_get_fully_qualified_target_uid (CXX_UTILITIES_LIBRARY_CONFIG    "${BASIS_CXX_UTILITIES_LIBRARY}")
basis_get_fully_qualified_target_uid (PYTHON_UTILITIES_LIBRARY_CONFIG "${BASIS_PYTHON_UTILITIES_LIBRARY}")
basis_get_fully_qualified_target_uid (JYTHON_UTILITIES_LIBRARY_CONFIG "${BASIS_JYTHON_UTILITIES_LIBRARY}")
basis_get_fully_qualified_target_uid (PERL_UTILITIES_LIBRARY_CONFIG   "${BASIS_PERL_UTILITIES_LIBRARY}")
basis_get_fully_qualified_target_uid (MATLAB_UTILITIES_LIBRARY_CONFIG "${BASIS_MATLAB_UTILITIES_LIBRARY}")
basis_get_fully_qualified_target_uid (BASH_UTILITIES_LIBRARY_CONFIG   "${BASIS_BASH_UTILITIES_LIBRARY}")

basis_get_fully_qualified_target_uid (TEST_LIBRARY_CONFIG      "${BASIS_TEST_LIBRARY}")
basis_get_fully_qualified_target_uid (TEST_MAIN_LIBRARY_CONFIG "${BASIS_TEST_MAIN_LIBRARY}")

# the following set() statements are simply used to document the variables
# note that this documentation is included in the Doxygen generated documentation

## @brief Name of BASIS utilities library for C++.
set (CXX_UTILITIES_LIBRARY_CONFIG    "${CXX_UTILITIES_LIBRARY_CONFIG}")
## @brief Name of BASIS utilities library for Python.
set (PYTHON_UTILITIES_LIBRARY_CONFIG "${PYTHON_UTILITIES_LIBRARY_CONFIG}")
## @brief Name of BASIS utilities library for Jython.
set (JYTHON_UTILITIES_LIBRARY_CONFIG "${JYTHON_UTILITIES_LIBRARY_CONFIG}")
## @brief Name of BASIS utilities library for Perl.
set (PERL_UTILITIES_LIBRARY_CONFIG   "${PERL_UTILITIES_LIBRARY_CONFIG}")
## @brief Name of BASIS utilities library for MATLAB.
set (MATLAB_UTILITIES_LIBRARY_CONFIG "${MATLAB_UTILITIES_LIBRARY_CONFIG}")
## @brief Name of BASIS utilities library for Bash.
set (BASH_UTILITIES_LIBRARY_CONFIG   "${BASH_UTILITIES_LIBRARY_CONFIG}")

## @brief Name of C++ unit testing library.
set (TEST_LIBRARY_CONFIG "${TEST_LIBRARY_CONFIG}")
## @brief Name of C++ unit testing library with definition of main() function.
set (TEST_MAIN_LIBRARY_CONFIG "${TEST_MAIN_LIBRARY_CONFIG}")

# ============================================================================
# build tree configuration settings
# ============================================================================

if (BUILD_CONFIG_SETTINGS)
  # CMake module path
  set (MODULE_PATH_CONFIG      "${BASIS_MODULE_PATH}")
  set (FIND_MODULE_PATH_CONFIG "${BASIS_FIND_MODULE_PATH}")
  # paths to template files of BASIS utilities
  foreach (U CXX PYTHON JYTHON PERL MATLAB BASH)
    string (TOLOWER "${U}" L)
    set (${U}_TEMPLATES_DIR_CONFIG "${PROJECT_CODE_DIR}/utilities/${L}")
  endforeach ()
  # Sphinx
  set (SPHINX_EXTENSIONS_PATH_CONFIG "${BASIS_SPHINX_EXTENSIONS_PATH}")
  set (SPHINX_HTML_THEME_PATH_CONFIG "${PROJECT_CODE_DIR}/sphinx/themes")
  return ()
endif ()

# ============================================================================
# installation configuration settings
# ============================================================================

## @brief Directory of BASIS CMake modules.
set (MODULE_PATH_CONFIG      "\${\${NS}INSTALL_PREFIX}/${INSTALL_MODULES_DIR}")
set (FIND_MODULE_PATH_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_FIND_MODULES_DIR}")
# paths to templates files of utilities
foreach (U CXX PYTHON JYTHON PERL MATLAB BASH)
  set (${U}_TEMPLATES_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_${U}_TEMPLATES_DIR}")
endforeach ()
# Sphinx
set (SPHINX_EXTENSIONS_PATH_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PYTHON_LIBRARY_DIR}/${SPHINX_EXTENSIONS_PREFIX}")
set (SPHINX_HTML_THEME_PATH_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_SPHINX_THEMES_DIR}")
