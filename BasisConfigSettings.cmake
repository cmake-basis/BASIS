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

## @brief Code to set cached &lt;Pkg&gt;_DIR variables in package configuration.
set (DEPENDS_CONFIG)

set (PKGS)
foreach (DEP IN LISTS PROJECT_DEPENDS PROJECT_OPTIONAL_DEPENDS)
  basis_tokenize_dependency ("${DEP}" PKG VER CMPS)
  if (NOT DEFINED ${PKG}_DIR)
    string (TOUPPER "${PKG}" PKG)
  endif ()
  if (DEFINED ${PKG}_DIR)
    list (APPEND PKGS ${PKG})
  endif ()
endforeach ()

if (PKGS)
  list (REMOVE_DUPLICATES PKGS)
endif ()

foreach (PKG IN LISTS PKGS)
  set (DEPENDS_CONFIG "${DEPENDS_CONFIG}# ${PKG}\nset (${PKG}_DIR \"${${PKG}_DIR}\")\n")
endforeach ()

# ============================================================================
# build tree configuration settings
# ============================================================================

if (BUILD_CONFIG_SETTINGS)
  set (INSTALL_PREFIX_CONFIG "${PROJECT_BINARY_DIR}")
  if (BUILD_EXAMPLE)
    set (EXAMPLE_DIR_CONFIG "${PROJECT_EXAMPLE_DIR}")
  else ()
    set (EXAMPLE_DIR_CONFIG)
  endif ()
  set (INCLUDE_DIR_CONFIG "${BINARY_INCLUDE_DIR};${PROJECT_INCLUDE_DIR}")
  set (LIBRARY_DIR_CONFIG "${BINARY_LIBRARY_DIR}")
  set (PYTHONPATH_CONFIG  "${BINARY_PYTHON_LIBRARY_DIR}")
  set (JYTHONPATH_CONFIG  "${BINARY_JYTHON_LIBRARY_DIR}")
  set (PERL5LIB_CONFIG    "${BINARY_PERL_LIBRARY_DIR}")
  set (MATLABPATH_CONFIG  "${BINARY_MATLAB_LIBRARY_DIR}")
  set (BASHPATH_CONFIG    "${BINARY_BASH_LIBRARY_DIR}")
  set (MODULES_DIR_CONFIG "${PROJECT_BINARY_DIR}/modules")
  return ()
endif ()

# ============================================================================
# installation configuration settings
# ============================================================================

basis_get_relative_path (INSTALL_PREFIX_CONFIG "${CMAKE_INSTALL_PREFIX}/${INSTALL_CONFIG_DIR}" "${CMAKE_INSTALL_PREFIX}")

## @brief Installation prefix.
set (INSTALL_PREFIX_CONFIG "\${CMAKE_CURRENT_LIST_DIR}/${INSTALL_PREFIX_CONFIG}")
## @brief Directory of example files.
if (BUILD_EXAMPLE)
  set (EXAMPLE_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_EXAMPLE_DIR}")
else ()
  set (EXAMPLE_DIR_CONFIG)
endif ()
## @brief Include directories.
set (INCLUDE_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")
## @brief Directory where libraries are located.
set (LIBRARY_DIR_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_LIBRARY_DIR}")
## @brief Directory of Python modules.
set (PYTHONPATH_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PYTHON_LIBRARY_DIR}")
## @brief Directory of Jython modules.
set (JYTHONPATH_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_JYTHON_LIBRARY_DIR}")
## @brief Directory of Perl modules.
set (PERL5LIB_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_PERL_LIBRARY_DIR}")
## @brief Directory of MATLAB modules.
set (MATLABPATH_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_MATLAB_LIBRARY_DIR}")
## @brief Directory of Bash modules.
set (BASHPATH_CONFIG "\${\${NS}INSTALL_PREFIX}/${INSTALL_BASH_LIBRARY_DIR}")
## @brief Directory of CMake package configuration files of project modules.
set (MODULES_DIR_CONFIG "${INSTALL_CONFIG_DIR}")
