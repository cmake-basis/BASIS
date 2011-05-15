##############################################################################
# \file  BasisDirectories.cmake
# \brief Defines the directory structure of BASIS projects.
#
# This CMake module defines the variables as specified in the Directories
# file which is part of the documentation of the BASIS Core.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

if (NOT BASIS_DIRECTORIES_INCLUDED)
set (BASIS_DIRECTORIES_INCLUDED 1)


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# initialization
# ============================================================================

# ****************************************************************************
# \brief Instantiates the project directory structure.
#
# This macro is invoked after the CMake project () command to instantiate
# the project directory structure, i.e., turn the directories into absolute
# paths using the CMake variables PROJECT_SOURCE_DIR and PROJECT_BINARY_DIR.

macro (basis_initialize_directories)
  # source tree
  foreach (P CONFIG DATA DOC EXAMPLE CODE TESTING)
    set (VAR PROJECT_${P}_DIR)
    if (NOT IS_ABSOLUTE "${${VAR}}")
      set (${VAR} "${PROJECT_SOURCE_DIR}/${${VAR}}")
    endif ()
  endforeach ()

  # build tree
  foreach (P RUNTIME LIBRARY ARCHIVE)
    set (VAR CMAKE_${P}_OUTPUT_DIRECTORY)
    if (NOT IS_ABSOLUTE "${${VAR}}")
      set (${VAR} "${PROJECT_BINARY_DIR}/${${VAR}}")
    endif ()
  endforeach ()

  # install tree
  set (
    CMAKE_INSTALL_PREFIX "${INSTALL_PREFIX}"
    CACHE INTERNAL "Installation directories prefix." FORCE
  )

  foreach (P BIN LIB INCLUDE DOC DATA EXAMPLE MAN)
    set (VAR INSTALL_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()
endmacro ()

# ============================================================================
# source tree
# ============================================================================

# The directories of the source tree are given here relative to the root
# directory of the project or corresponding subtree, respectively.
#
# \note The project template must follow this directory structure.
#       Ideally, when changing the name of one of these directories,
#       only the directory structure of the tempate needs to be updated.
#       The BASIS CMake functions should not be required to change as they
#       are supposed to use these variables instead of the actual names.

set (PROJECT_CODE_DIR    "src")
set (PROJECT_CONFIG_DIR  "config")
set (PROJECT_DATA_DIR    "data")
set (PROJECT_DOC_DIR     "doc")
set (PROJECT_EXAMPLE_DIR "example")
set (PROJECT_TESTING_DIR "test")

set (TESTING_INPUT_DIR    "data")
set (TESTING_EXPECTED_DIR "expected")


# ============================================================================
# build tree
# ============================================================================

# These directory paths will be made absolute by the initialization functions.

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "bin")
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "bin")
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "lib")

# ============================================================================
# install tree
# ============================================================================

# In order for CPack to work correctly, the destination paths have to be given
# relative (to CMAKE_INSTALL_PREFIX). Therefore, the INSTALL_PREFIX prefix is
# excluded from the following paths. Instead, CMAKE_INSTALL_PREFIX is set to
# INSTALL_PREFIX. This has to be done after the project attributes are known.
# Hence, it is done by basis_project (), which configures the variables below.

mark_as_advanced (CMAKE_INSTALL_PREFIX)

if (WIN32)
  set (
    INSTALL_PREFIX "C:\\Program Files\\SBIA\\\${PROJECT_NAME}"
    CACHE PATH "Installation directory prefix."
  )

  set (
    INSTALL_SINFIX ""
    CACHE PATH "Installation directories suffix or infix, respectively."
  )
else ()
  set (
    INSTALL_PREFIX "/usr/local"
    CACHE PATH "Installation directories prefix."
  )

  set (
    INSTALL_SINFIX "sbia/@PROJECT_NAME_LOWER@"
    CACHE PATH "Installation directories suffix or infix, respectively."
  )
endif ()

if (INSTALL_SINFIX)
  set (INSTALL_BIN_DIR     "bin/${INSTALL_SINFIX}")
  set (INSTALL_LIB_DIR     "lib/${INSTALL_SINFIX}")
  set (INSTALL_INCLUDE_DIR "include/${INSTALL_SINFIX}/sbia/@PROJECT_NAME_LOWER@")
  set (INSTALL_DOC_DIR     "share/${INSTALL_SINFIX}/doc")
  set (INSTALL_DATA_DIR    "share/${INSTALL_SINFIX}/data")
  set (INSTALL_EXAMPLE_DIR "share/${INSTALL_SINFIX}/example")
  set (INSTALL_MAN_DIR     "share/${INSTALL_SINFIX}/man")
else ()
  set (INSTALL_BIN_DIR     "bin")
  set (INSTALL_LIB_DIR     "lib")
  set (INSTALL_INCLUDE_DIR "include/sbia/@PROJECT_NAME_LOWER@")
  set (INSTALL_DOC_DIR     "share/doc")
  set (INSTALL_DATA_DIR    "share/data")
  set (INSTALL_EXAMPLE_DIR "share/example")
  set (INSTALL_MAN_DIR     "share/man")
endif ()



endif (NOT BASIS_DIRECTORIES_INCLUDED)

