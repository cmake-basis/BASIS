##############################################################################
# \file  BasisSettings.cmake
# \brief BASIS configuration and default CMake settings used by projects.
#
# This module defines global CMake constants and variables which are used
# by the BASIS CMake functions and macros. Hence, these values can be used
# to configure the behaviour of these functions to some extent without the
# need to modify the functions themselves.
#
# Moreover, this file specifies the common CMake settings such as the build
# configuration used by projects following BASIS.
#
# \attention Be careful when caching any of the variables. Usually, this
#            file is included in the root CMake configuration file of the
#            project. The variables set by this module should only be valid
#            underneath this directory tree, but not propagate to the parent
#            or a sibling.
#
# \note As this file also sets the CMake policies to be used, it has to
#       be included using the NO_POLICY_SCOPE in order for these policies
#       to take effect also in the including file and its subdirectories.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# system checks
# ============================================================================

include (CheckTypeSize)

# check if type long long is supported
CHECK_TYPE_SIZE("long long" LONG_LONG)

# check for presence of sstream header
include (TestForSSTREAM)

if (CMAKE_NO_ANSI_STRING_STREAM)
  set (HAVE_SSTREAM FALSE)
else ()
  set (HAVE_SSTREAM TRUE)
endif ()

# ============================================================================
# common options
# ============================================================================

option (BASIS_VERBOSE "Whether BASIS functions should be verbose." "OFF")
mark_as_advanced (BASIS_VERBOSE)

# ============================================================================
# constants and global settings
# ============================================================================

# \brief List of names used for special purpose targets.
#
# Contains a list of target names that are used by the BASIS functions for
# special purposes and are hence not to be used for project targets.
set (BASIS_RESERVED_TARGET_NAMES "uninstall" "doc" "changelog" "execname")

# \brief Default components used when no component is specified.
#
# The default component a target of the given kind and its auxiliary files
# are associated with if no component was specified, explicitly.
set (BASIS_LIBRARY_COMPONENT "Development")
set (BASIS_RUNTIME_COMPONENT "Runtime")

# \brief Character used to separate namespace and target name to build target UID.
#
# This separator is used to construct a UID for a particular target.
# For example, "<project>@BASIS_NAMESPACE_SEPARATOR@<target>".
set (BASIS_NAMESPACE_SEPARATOR "@")

# \brief Character used to separate version and project name (e.g., in target UID).
#
# This separator is used to construct a UID for a particular target.
# For example, "<project>@BASIS_NAMESPACE_SEPARATOR@<target>@BASIS_VERSION_SEPARATOR@<version>".
# Note that the version need not be included if only a single version of each
# package is supposed to be installed on a target system.
set (BASIS_VERSION_SEPARATOR "#")

# \brief Prefix used for CMake package config files.
#
# This string is used as prefix for the names of the <project>Config.cmake
# et al. files. For example, a value of "SBIA_", results in the CMake package
# configuration file "SBIA_<project>Config.cmake".
set (BASIS_CONFIG_PREFIX "")

# \brief Script used to execute a process in CMake script mode.
#
# In order to be able to assign a timeout to the execution of a custom command
# and to add some error message parsing, this script is used by some build
# rules to actually perform the build step. See for example, the build of
# executables using the MATLAB Compiler.
set (BASIS_SCRIPT_EXECUTE_PROCESS "${CMAKE_CURRENT_LIST_DIR}/ExecuteProcess.cmake")

# \brief Default script configuration template.
#
# This is the default template used by basis_add_script () to configure the
# script during the build step. If the file
# PROJECT_CONFIG_DIR/ScriptConfig.cmake.in exists, the value of this variable
# is set to its path by basis_project_initialize ().
set (BASIS_SCRIPT_CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/ScriptConfig.cmake.in")

# ============================================================================
# cached variables
# ============================================================================

# The following variables are used across BASIS macros and functions. They
# in particular remember information added by one function or macro and is
# required by another function or macro.
#
# \note These variables are reset whenever this module is included the first
#       time. The guard directive at the beginning of this file protects
#       these variables to be overwritten each time this module is included.

# Caches all directories given as argument to basis_include_directories ().
set (BASIS_CACHED_INCLUDE_DIRECTORIES_DOC "All include directories.")
set (BASIS_CACHED_INCLUDE_DIRECTORIES "" CACHE INTERNAL "${BASIS_CACHED_INCLUDE_DIRECTORIES_DOC}" FORCE)

# Caches the global names (UIDs) of all project targets.
set (BASIS_TARGETS_DOC "Names of all targets.")
set (BASIS_TARGETS "" CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE)

# ============================================================================
# project directory structure
# ============================================================================

# ----------------------------------------------------------------------------
# assertions
# ----------------------------------------------------------------------------

# ****************************************************************************
# \brief Ensure certain requirements on build tree.

macro (buildtree_asserts)
  # root of build tree must not be root of source tree
  string (TOLOWER "${CMAKE_SOURCE_DIR}" SOURCE_ROOT)
  string (TOLOWER "${CMAKE_BINARY_DIR}" BUILD_ROOT)

  if ("${BUILD_ROOT}" STREQUAL "${SOURCE_ROOT}")
    message(FATAL_ERROR "This project should not be configured & build in the source directory:\n"
                        "  ${CMAKE_SOURCE_DIR}\n"
                        "You must run CMake in a separate build directory.")
  endif()
endmacro ()

# ****************************************************************************
# \brief Ensure certain requirements on install tree.

macro (installtree_asserts)
  # prefix must be an absolute path
  if (NOT IS_ABSOLUTE "${CMAKE_INSTALL_PREFIX}")
    message (FATAL_ERROR "CMAKE_INSTALL_PREFIX must be an absolute path!")
  endif ()

  # install tree must be different from source and build tree
  string (TOLOWER "${CMAKE_SOURCE_DIR}"     SOURCE_ROOT)
  string (TOLOWER "${CMAKE_BINARY_DIR}"     BUILD_ROOT)
  string (TOLOWER "${CMAKE_INSTALL_PREFIX}" INSTALL_ROOT)

  if ("${INSTALL_ROOT}" MATCHES "${BUILD_ROOT}|${SOURCE_ROOT}")
    message (FATAL_ERROR "The current CMAKE_INSTALL_PREFIX points at the source or build tree:\n"
                         "  ${CMAKE_INSTALL_PREFIX}\n"
                         "This is not supported. Please choose another installation prefix."
    )
  endif()
endmacro ()

# ----------------------------------------------------------------------------
# instantiation for specific project
# ----------------------------------------------------------------------------

# ****************************************************************************
# \brief Instantiates the project directory structure.
#
# This macro is invoked after the CMake project () command to instantiate
# the project directory structure, i.e., turn the directories into absolute
# paths using the CMake variables PROJECT_SOURCE_DIR and PROJECT_BINARY_DIR.
# Moreover, the occurences of @PROJECT_NAME@, @PROJECT_NAME_LOWER@,
# @PROJECT_NAME_UPPER@, @PROJECT_VERSION@, @PROJECT_VERSION_MAJOR@,
# @PROJECT_VERSION_MINOR@, and @PROJECT_VERSION_PATH@ are substituted by the
# actual values corresponding to the project name and version.

macro (basis_initialize_directories)
  # source tree
  foreach (P CODE CONFIG DATA DOC EXAMPLE INCLUDE TESTING)
    set (VAR PROJECT_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()

  # build tree
  foreach (P RUNTIME LIBRARY ARCHIVE)
    set (VAR CMAKE_${P}_OUTPUT_DIRECTORY)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()

  # testing tree
  foreach (P RUNTIME OUTPUT)
    set (VAR TESTING_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()

  # install tree
  string (CONFIGURE "${INSTALL_PREFIX}" INSTALL_PREFIX @ONLY)
  string (CONFIGURE "${INSTALL_SINFIX}" INSTALL_SINFIX @ONLY)

  set (CMAKE_INSTALL_PREFIX "${INSTALL_PREFIX}" CACHE INTERNAL "" FORCE)

  foreach (P RUNTIME LIBEXEC LIBRARY ARCHIVE INCLUDE SHARE DOC EXAMPLE MAN)
    set (VAR INSTALL_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
    if ("${${VAR}}" STREQUAL "")
      set (${VAR} ".")
    endif ()
  endforeach ()

  string (CONFIGURE "${INSTALL_CONFIG_DIR}" INSTALL_CONFIG_DIR @ONLY)
  if ("${INSTALL_CONFIG_DIR}" STREQUAL "")
    set (INSTALL_CONFIG_DIR ".")
  endif ()

  # assertions
  buildtree_asserts ()
  installtree_asserts ()
endmacro ()

# ----------------------------------------------------------------------------
# source tree
# ----------------------------------------------------------------------------

# \note The project template must follow this directory structure.
#       Ideally, when changing the name of one of these directories,
#       only the directory structure of the tempate needs to be updated.
#       The BASIS CMake functions should not be required to change as they
#       are supposed to use these variables instead of the actual names.

set (PROJECT_CODE_DIR    "@PROJECT_SOURCE_DIR@/src")
set (PROJECT_CONFIG_DIR  "@PROJECT_SOURCE_DIR@/config")
set (PROJECT_DATA_DIR    "@PROJECT_SOURCE_DIR@/data")
set (PROJECT_DOC_DIR     "@PROJECT_SOURCE_DIR@/doc")
set (PROJECT_EXAMPLE_DIR "@PROJECT_SOURCE_DIR@/example")
set (PROJECT_INCLUDE_DIR "@PROJECT_SOURCE_DIR@/include")
set (PROJECT_TESTING_DIR "@PROJECT_SOURCE_DIR@/test")

# ----------------------------------------------------------------------------
# testing tree
# ----------------------------------------------------------------------------

set (TESTING_OUTPUT_DIR  "@PROJECT_BINARY_DIR@/Testing/Temporary/output")
set (TESTING_RUNTIME_DIR "@PROJECT_BINARY_DIR@/Testing/bin")

# ----------------------------------------------------------------------------
# build tree
# ----------------------------------------------------------------------------

# These directory paths will be made absolute by the initialization functions.

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "@PROJECT_BINARY_DIR@/bin")
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "@PROJECT_BINARY_DIR@/lib")
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "@PROJECT_BINARY_DIR@/lib")

# ----------------------------------------------------------------------------
# install tree
# ----------------------------------------------------------------------------

# In order for CPack to work correctly, the destination paths have to be given
# relative to CMAKE_INSTALL_PREFIX. Therefore, this prefix is excluded from the
# following paths.

# C:/Program Files/Project -> C:/Program Files/SBIA
string (
  REGEX REPLACE
    "/Project$"
    "/SBIA"
  CMAKE_INSTALL_PREFIX
    "${CMAKE_INSTALL_PREFIX}"
)

# prefix/suffix/infix of installation directories
set (
  INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}"
  CACHE PATH "Installation directories prefix."
)

set (
  INSTALL_SINFIX "\@PROJECT_NAME_LOWER\@"
  CACHE PATH "Installation directories suffix (or infix, respectively)."
)

# option to create (symbolic) links
if (UNIX)
  option (INSTALL_LINKS "Whether to create (symbolic) links." ON)
endif ()

# install tree directories
set (INSTALL_RUNTIME_DIR   "bin")           # main executables and shared libraries (WIN32)
if (WIN32)
  set (INSTALL_LIBEXEC_DIR "bin")           # auxiliary executables
else ()
  set (INSTALL_LIBEXEC_DIR "lib")           # auxiliary executables
endif ()
set (INSTALL_LIBRARY_DIR   "lib")           # shared (UNIX) and module libraries
set (INSTALL_ARCHIVE_DIR   "lib")           # static and import libraries
set (INSTALL_INCLUDE_DIR   "include")       # public header files of libraries
set (INSTALL_SHARE_DIR     "share")         # other shared files

if (INSTALL_SINFIX)
  foreach (P RUNTIME LIBEXEC LIBRARY ARCHIVE SHARE)
    set (VAR "INSTALL_${P}_DIR")
    set (${VAR} "${${VAR}}/${INSTALL_SINFIX}")
  endforeach ()
endif ()

if (WIN32)
  set (INSTALL_CONFIG_DIR  "cmake")   # CMake configuration files
  set (INSTALL_DOC_DIR     "doc")     # documentaton files
  set (INSTALL_EXAMPLE_DIR "example") # package example
  set (INSTALL_MAN_DIR     "man")     # man pages
else ()
  set (INSTALL_CONFIG_DIR  "${INSTALL_LIBRARY_DIR}/cmake") # CMake configuration files
  set (INSTALL_DOC_DIR     "${INSTALL_SHARE_DIR}/doc")     # documentaton files
  set (INSTALL_EXAMPLE_DIR "${INSTALL_SHARE_DIR}/example") # package example
  set (INSTALL_MAN_DIR     "${INSTALL_SHARE_DIR}/man")     # man pages
endif ()

if (WIN32 AND INSTALL_SINFIX)
  foreach (P CONFIG DOC EXAMPLE MAN)
    set (VAR "INSTALL_${P}_DIR")
    set (${VAR} "${${VAR}}/${INSTALL_SINFIX}")
  endforeach ()
endif ()

# ============================================================================
# build configuration(s)
# ============================================================================

# list of all available build configurations
set (
  CMAKE_CONFIGURATION_TYPES
    "Debug"
    "Coverage"
    "Release"
  CACHE STRING "Build configurations." FORCE
)

# list of debug configurations, used by target_link_libraries (), for example,
# to determine whether to link to the optimized or debug libraries
set (DEBUG_CONFIGURATIONS "Debug")

mark_as_advanced (CMAKE_CONFIGURATION_TYPES)
mark_as_advanced (DEBUG_CONFIGURATIONS)

if (NOT CMAKE_BUILD_TYPE MATCHES "^Debug$|^Coverage$|^Release$")
  set (CMAKE_BUILD_TYPE "Release")
endif ()

set (
  CMAKE_BUILD_TYPE
    "${CMAKE_BUILD_TYPE}"
  CACHE STRING
    "Current build configuration. Specify either \"Debug\", \"Coverage\", or \"Release\"."
  FORCE
)

# ----------------------------------------------------------------------------
# common
# ----------------------------------------------------------------------------

# common compiler flags
set (CMAKE_C_FLAGS "" CACHE INTERNAL "" FORCE) # disabled
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

# common linker flags
set (CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    -lm")
set (CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -lm")
set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -lm")

# ----------------------------------------------------------------------------
# MinSizeRel - disabled
# ----------------------------------------------------------------------------

# compiler flags of MinSizeRel configuration
set (CMAKE_C_FLAGS_MINSIZEREL ""   CACHE INTERNAL "" FORCE)
set (CMAKE_CXX_FLAGS_MINSIZEREL "" CACHE INTERNAL "" FORCE)

# linker flags of MinSizeRel configuration
set (CMAKE_EXE_LINKER_FLAGS_MINSIZEREL    "" CACHE INTERNAL "" FORCE)
set (CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL "" CACHE INTERNAL "" FORCE)
set (CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL "" CACHE INTERNAL "" FORCE)

# ----------------------------------------------------------------------------
# RelWithDebInfo - disabled
# ----------------------------------------------------------------------------

# compiler flags of RelWithDebInfo configuration
set (CMAKE_CXX_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "" FORCE)

# linker flags of RelWithDebInfo configuration
set (CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO    "" CACHE INTERNAL "" FORCE)
set (CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "" FORCE)
set (CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "" FORCE)

# ----------------------------------------------------------------------------
# Debug
# ----------------------------------------------------------------------------

# compiler flags of Debug configuration
set (CMAKE_C_FLAGS_DEBUG "" CACHE INTERNAL "" FORCE) # disabled
set (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")

# linker flags of Debug configuration
set (CMAKE_EXE_LINKER_FLAGS_DEBUG    "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
set (CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
set (CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")

# ----------------------------------------------------------------------------
# Release
# ----------------------------------------------------------------------------

# compiler flags of Release configuration
set (CMAKE_C_FLAGS_RELEASE "" CACHE INTERNAL "" FORCE) # disabled
set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")

# linker flags of Release configuration
set (CMAKE_EXE_LINKER_FLAGS_RELEASE    "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set (CMAKE_MODULE_LINKER_FLAGS_RELEASE "${CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
set (CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")

# ----------------------------------------------------------------------------
# Coverage
# ----------------------------------------------------------------------------

# compiler flags for Coverage configuration
set (CMAKE_C_FLAGS_COVERAGE "" CACHE INTERNAL "" FORCE) # disabled
set (CMAKE_CXX_FLAGS_COVERAGE "-g -O0 -Wall -W -fprofile-arcs -ftest-coverage")

# linker flags for Coverage configuration
set (CMAKE_EXE_LINKER_FLAGS_COVERAGE    "-fprofile-arcs -ftest-coverage")
set (CMAKE_MODULE_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage")
set (CMAKE_SHARED_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage")

