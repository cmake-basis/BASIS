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
# Copyright (c) 2011, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisSettings
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
    # project template
    set (TEMPLATE_DIR_CONFIG "${PROJECT_DATA_DIR}/template-${TEMPLATE_VERSION}")
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
# project template
set (TEMPLATE_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_TEMPLATE_DIR}-${TEMPLATE_VERSION}")
# paths to utilities templates files
foreach (U CXX JAVA PYTHON PERL BASH MATLAB)
  set (${U}_TEMPLATES_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_${U}_TEMPLATES_DIR}")
endforeach ()
