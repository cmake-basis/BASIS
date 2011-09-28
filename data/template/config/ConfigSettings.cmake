##############################################################################
# @file  ConfigSettings.cmake
# @brief Sets variables used in package configuration file.
#
# It is suggested to use _CONFIG as suffix for variable names that are to be
# substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# @note The default configuration settings file is included prior to this file.
#       Hence, the variables are valid even if a custom configuration is used
#       and default values can be overwritten in this file.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# build tree configuration settings
# ============================================================================

if (BUILD_CONFIG_SETTINGS)
  set (DATA_DIR_CONFIG "${PROJECT_DATA_DIR}")

  return ()
endif ()

# ============================================================================
# installation configuration settings
# ============================================================================

set (DATA_DIR_CONFIG "${INSTALL_DATA_DIR}")

