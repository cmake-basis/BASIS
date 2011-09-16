##############################################################################
# @file  ConfigSettings.cmake
# @brief Sets variables used in CMake package configuration of build tree.
#
# It is suggested to use _CONFIG as suffix for variable names that are to be
# substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# @note The default build tree configuration is included prior to this file.
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
    # CMake module path
    set (MODULE_PATH_CONFIG "${PROJECT_CODE_DIR}/cmake")

    # path to templates files
    foreach (U CXX PYTHON PERL BASH)
      string (TOLOWER "${U}" L)
      set (${U}_TEMPLATES_DIR_CONFIG "${PROJECT_CODE_DIR}/utilities/${L}")
    endforeach ()

    # URL of project template
    set (TEMPLATE_URL_CONFIG "${PROJECT_ETC_DIR}/template")

    return ()
endif ()

# ============================================================================
# installation configuration settings
# ============================================================================

# CMake module path
basis_set_config_path (MODULE_PATH_CONFIG "${INSTALL_MODULES_DIR}")

# path to templates files
foreach (U CXX PYTHON PERL BASH)
  basis_set_config_path (${U}_TEMPLATES_DIR_CONFIG  "${INSTALL_${U}_TEMPLATES_DIR}")
endforeach ()

# URL of project template
basis_set_config_path (TEMPLATE_URL_CONFIG "${INSTALL_TEMPLATE_DIR}")

