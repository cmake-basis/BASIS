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
  ## @brief Include directories of package configuration of build tree.
  set (INCLUDE_DIR_CONFIG "${PROJECT_INCLUDE_DIR}")

  ## @brief Libraries directories of package configuration of build tree.
  set (LIBRARY_DIR_CONFIG "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

  return ()
endif ()

# ============================================================================
# installation configuration settings
# ============================================================================

## @brief Include directories of package configuration of installation.
basis_set_config_path (INCLUDE_DIR_CONFIG "${INSTALL_INCLUDE_DIR}")

## @brief Libraries directories of package configuration of installation.
basis_set_config_path (LIBRARY_DIR_CONFIG "${INSTALL_LIBRARY_DIR}")
