##############################################################################
# @file  ConfigSettings.cmake
# @brief Sets variables used in CMake package configuration file.
#
# It is suggested to use _CONFIG as suffix for variable names that are to be
# substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

# ============================================================================
# build tree configuration settings
# ============================================================================

if (BUILD_CONFIG_SETTINGS)
  
  ## @brief Root of build tree.
  set (INSTALL_PREFIX_CONFIG "${PROJECT_BINARY_DIR}")

  ## @brief Include directories of package configuration of build tree.
  set (INCLUDE_DIR_CONFIG "${PROJECT_INCLUDE_DIR}" "${BINARY_INCLUDE_DIR}")

  ## @brief Libraries directories of package configuration of build tree.
  set (LIBRARY_DIR_CONFIG "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

  ## @brief Search path for Python package in build tree.
  set (PYTHON_LIBRARY_DIR_CONFIG "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/python")

  ## @brief Search path for Perl packages in build tree.
  set (PERL_LIBRARY_DIR_CONFIG "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/perl5")

  return ()
endif ()

# ============================================================================
# installation configuration settings
# ============================================================================

## @brief Installation prefix relative to location of configuration file.
file (
  RELATIVE_PATH
    INSTALL_PREFIX_CONFIG
    "${INSTALL_PREFIX}/${INSTALL_CONFIG_DIR}"
    "${INSTALL_PREFIX}"
)
set (INSTALL_PREFIX_CONFIG "\${CMAKE_CURRENT_LIST_DIR}/${INSTALL_PREFIX_CONFIG}")

## @brief Include directories of package configuration of installation.
set (INCLUDE_DIR_CONFIG "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")

## @brief Libraries directories of package configuration of installation.
set (LIBRARY_DIR_CONFIG "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_LIBRARY_DIR}")

## @brief Search path for installed Python package.
set (PYTHON_LIBRARY_DIR_CONFIG "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_PYTHON_LIBRARY_DIR}")

## @brief Search path for installed Perl packages.
set (PERL_LIBRARY_DIR_CONFIG "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_PERL_LIBRARY_DIR}")
