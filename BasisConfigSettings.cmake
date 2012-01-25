##############################################################################
# @file  BasisConfigSettings.cmake
# @brief Sets basic variables used in CMake package configuration.
#
# It is suggested to use @c _CONFIG as suffix for variable names that are to be
# substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisSettings
##############################################################################

# ============================================================================
# common configuration settings
# ============================================================================

basis_sanitize_for_regex (RS "${CMAKE_SOURCE_DIR}")
basis_sanitize_for_regex (RB "${CMAKE_BINARY_DIR}")

# include directories of dependencies
get_directory_property (INCLUDE_DIRS INCLUDE_DIRECTORIES)
if (INCLUDE_DIRS)
  list (REMOVE_DUPLICATES INCLUDE_DIRS)
endif ()

set (INCLUDE_DIRS_CONFIG "\${\${NS}INCLUDE_DIR}")
foreach (D IN LISTS INCLUDE_DIRS)
  # exclude project own directories
  if (NOT D MATCHES "^${RS}|^${RB}")
    list (APPEND INCLUDE_DIRS_CONFIG "${D}")
  endif ()
endforeach ()

# link directories of dependencies
get_directory_property (LIBRARY_DIRS LINK_DIRECTORIES)
if (LIBRARY_DIRS)
  list (REMOVE_DUPLICATES LIBRARY_DIRS)
endif ()

set (LIBRARY_DIRS_CONFIG "\${\${NS}LIBRARY_DIR}")
foreach (D IN LISTS LIBRARY_DIRS)
  # exclude project own directories
  if (NOT D MATCHES "^${RS}|^${RB}")
    list (APPEND LIBRARY_DIRS_CONFIG "${D}")
  endif ()
endforeach ()

unset (RS)
unset (RB)

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

set (INSTALL_PREFIX_CONFIG "\${CMAKE_CURRENT_LIST_DIR}/${INSTALL_PREFIX_CONFIG}")
set (INCLUDE_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")
set (LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_LIBRARY_DIR}")
set (PYTHON_LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PYTHON_LIBRARY_DIR}")
set (PERL_LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PERL_LIBRARY_DIR}")
set (MODULES_DIR_CONFIG "${INSTALL_CONFIG_DIR}")
