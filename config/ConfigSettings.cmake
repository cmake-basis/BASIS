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
# common settings
# ============================================================================

basis_get_fully_qualified_target_uid (UTILITIES_LIBRARY_CONFIG "${BASIS_UTILITIES_LIBRARY}")
basis_get_fully_qualified_target_uid (TEST_LIBRARY_CONFIG      "${BASIS_TEST_LIBRARY}")
basis_get_fully_qualified_target_uid (TEST_MAIN_LIBRARY_CONFIG "${BASIS_TEST_MAIN_LIBRARY}")

# ============================================================================
# build tree configuration settings
# ============================================================================

if (BUILD_CONFIG_SETTINGS)
    # CMake module path
    set (MODULE_PATH_CONFIG "${PROJECT_CODE_DIR}/cmake")
    # paths to utilities templates files
    foreach (U CXX JAVA PYTHON PERL BASH MATLAB)
      string (TOLOWER "${U}" L)
      set (${U}_TEMPLATES_DIR_CONFIG "${PROJECT_CODE_DIR}/utilities/${L}")
    endforeach ()

    return ()
endif ()

# ============================================================================
# installation configuration settings
# ============================================================================

# CMake module path
set (MODULE_PATH_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_MODULES_DIR}")
# paths to utilities templates files
foreach (U CXX JAVA PYTHON PERL BASH MATLAB)
  set (${U}_TEMPLATES_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_${U}_TEMPLATES_DIR}")
endforeach ()
