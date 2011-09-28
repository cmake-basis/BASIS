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
    # Include directories of package configuration of build tree.
    set (
      INCLUDE_DIR_CONFIG
        "${PROJECT_INCLUDE_DIR}"
        "${BINARY_INCLUDE_DIR}"
        "${PROJECT_INCLUDE_DIR}/sbia" # because of TCLAP
    )

    # CMake module path
    set (MODULE_PATH_CONFIG "${PROJECT_CODE_DIR}/cmake")

    # paths to utilities templates files
    foreach (U CXX JAVA PYTHON PERL BASH MATLAB)
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

# Include directories of package configuration of installation.
#
# Note: The 'sbia' subdirectory is added as include path because certain
#       external libraries packaged with BASIS such as TCLAP include other
#       header files via #include <tclap/file.h>.
set (
  INCLUDE_DIR_CONFIG
    "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}"
    "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}/sbia"
)

# CMake module path
set (MODULE_PATH_CONFIG "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_MODULES_DIR}")

# paths to utilities templates files
foreach (U CXX JAVA PYTHON PERL BASH MATLAB)
  set (${U}_TEMPLATES_DIR_CONFIG "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_${U}_TEMPLATES_DIR}")
endforeach ()

# URL of project template
set (TEMPLATE_URL_CONFIG "\${${PACKAGE_NAME}_INSTALL_PREFIX}/${INSTALL_TEMPLATE_DIR}")

