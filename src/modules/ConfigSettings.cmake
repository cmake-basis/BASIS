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
  set (INSTALL_PREFIX_CONFIG "${PROJECT_BINARY_DIR}")
  set (INCLUDE_DIR_CONFIG "${PROJECT_INCLUDE_DIR}" "${BINARY_INCLUDE_DIR}")
  set (LIBRARY_DIR_CONFIG "${BINARY_LIBRARY_DIR}")
  set (PYTHON_LIBRARY_DIR_CONFIG "${BINARY_PYTHON_LIBRARY_DIR}")
  set (PERL_LIBRARY_DIR_CONFIG "${BINARY_PERL_LIBRARY_DIR}")
  return ()
endif ()

# ============================================================================
# installation configuration settings
# ============================================================================

basis_get_relative_path (
  INSTALL_PREFIX_CONFIG
    "${INSTALL_PREFIX}/${INSTALL_CONFIG_DIR}"
    "${INSTALL_PREFIX}"
)

set (INSTALL_PREFIX_CONFIG "\${CMAKE_CURRENT_LIST_DIR}/${INSTALL_PREFIX_CONFIG}")
set (INCLUDE_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")
set (LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_LIBRARY_DIR}")
set (PYTHON_LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PYTHON_LIBRARY_DIR}")
set (PERL_LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PERL_LIBRARY_DIR}")
