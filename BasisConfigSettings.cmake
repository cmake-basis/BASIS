##############################################################################
# @file  BasisConfigSettings.cmake
# @brief Sets basic variables used in CMake package configuration.
#
# It is suggested to use @c _CONFIG as suffix for variable names that are to be
# substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisSettings
##############################################################################

# ============================================================================
# common configuration settings
# ============================================================================

## @brief Include directories of dependencies.
set (INCLUDE_DIRS_CONFIG)
## @brief Directories of libraries this package depends on.
set (LIBRARY_DIRS_CONFIG)

# ============================================================================
# build tree configuration settings
# ============================================================================

if (BUILD_CONFIG_SETTINGS)
  set (INSTALL_PREFIX_CONFIG "${PROJECT_BINARY_DIR}")
  set (INCLUDE_DIR_CONFIG "${BINARY_INCLUDE_DIR};${PROJECT_INCLUDE_DIR}")
  set (LIBRARY_DIR_CONFIG "${BINARY_LIBRARY_DIR}")
  set (PYTHON_LIBRARY_DIR_CONFIG "${BINARY_PYTHON_LIBRARY_DIR}")
  set (PERL_LIBRARY_DIR_CONFIG "${BINARY_PERL_LIBRARY_DIR}")
  set (MODULES_DIR_CONFIG "${PROJECT_BINARY_DIR}/modules")
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

## @brief Installation prefix.
set (INSTALL_PREFIX_CONFIG "\${CMAKE_CURRENT_LIST_DIR}/${INSTALL_PREFIX_CONFIG}")
## @brief Include directories.
set (INCLUDE_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")
## @brief Directory where libraries are located.
set (LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_LIBRARY_DIR}")
## @brief Directory of Python modules.
set (PYTHON_LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PYTHON_LIBRARY_DIR}")
## @brief Directory of Perl modules.
set (PERL_LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PERL_LIBRARY_DIR}")
## @brief Directory of CMake package configuration files of project modules.
set (MODULES_DIR_CONFIG "${INSTALL_CONFIG_DIR}")
