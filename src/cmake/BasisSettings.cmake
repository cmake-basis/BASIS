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
# \note As this file also sets the CMake policies to be used, it has to
#       be included using the NO_POLICY_SCOPE in order for these policies
#       to take effect also in the including file and its subdirectories.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

if (NOT BASIS_SETTINGS_INCLUDED)
set (BASIS_SETTINGS_INCLUDED 1)


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# CMake version and policies
# ============================================================================

cmake_minimum_required (VERSION 2.8.2)

# Add policies introduced with CMake versions newer than the one specified
# above. These policies would otherwise trigger a polciy not set warning by
# newer CMake versions.

# CMake >= 2.8.3
if (CMAKE_VERSION_PATCH GREATER 2)
  cmake_policy (SET CMP0016 NEW)
endif ()

# CMake >= 2.8.4
if (CMAKE_VERSION_PATCH GREATER 3)
  cmake_policy (SET CMP0017 NEW)
endif ()

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
set (BASIS_DEFAULT_ARCHIVE_COMPONENT   "Development")
set (BASIS_DEFAULT_BUNDLE_COMPONENT    "Runtime")
set (BASIS_DEFAULT_FRAMEWORK_COMPONENT "Development")
set (BASIS_DEFAULT_LIBRARY_COMPONENT   "Runtime")
set (BASIS_DEFAULT_RUNTIME_COMPONENT   "Runtime")

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

# \brief Suffix used for installation of header files.
#
# This variable has to be configured during the project initialization when
# the project name and version are known to substitute for these. The resulting
# string is the prefix required by other packages to include the header files
# of the installed project.
#
# For example, the header file utilities.h is installed as follows:
# \code
# install (FILES utilities.h DESTINATION "${INSTALL_INCLUDE_DIR}/${BASIS_INCLUDE_PREFIX}")
# \endcode
#
# Users of this header file have to include it using the specified prefix:
# \code
# #include <@BASIS_INCLUDE_PREFIX@/utilities.h>
# \endcode
set (BASIS_INCLUDE_PREFIX "sbia/@PROJECT_NAME_LOWER@")

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
# script during the build step.
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

include ("${CMAKE_CURRENT_LIST_DIR}/BasisDirectories.cmake")

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

# default script configuration file \see basis_add_script ()
set (BASIS_SCRIPT_CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/BasisScriptConfig.cmake.in")

# ----------------------------------------------------------------------------
# common
# ----------------------------------------------------------------------------

# common compiler flags
set (CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

# common linker flags
set (CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    -lm")
set (CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -lm")
set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -lm")

# ----------------------------------------------------------------------------
# MinSizeRel - disabled
# ----------------------------------------------------------------------------

# compiler flags of MinSizeRel configuration
set (CMAKE_C_FLAGS_MINSIZEREL   "" CACHE INTERNAL "" FORCE)
set (CMAKE_CXX_FLAGS_MINSIZEREL "" CACHE INTERNAL "" FORCE)

# linker flags of MinSizeRel configuration
set (CMAKE_EXE_LINKER_FLAGS_MINSIZEREL    "" CACHE INTERNAL "" FORCE)
set (CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL "" CACHE INTERNAL "" FORCE)
set (CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL "" CACHE INTERNAL "" FORCE)

# ----------------------------------------------------------------------------
# RelWithDebInfo - disabled
# ----------------------------------------------------------------------------

# compiler flags of RelWithDebInfo configuration
set (CMAKE_C_FLAGS_RELWITHDEBINFO   "" CACHE INTERNAL "" FORCE)
set (CMAKE_CXX_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "" FORCE)

# linker flags of RelWithDebInfo configuration
set (CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO    "" CACHE INTERNAL "" FORCE)
set (CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "" FORCE)
set (CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "" CACHE INTERNAL "" FORCE)

# ----------------------------------------------------------------------------
# Coverage
# ----------------------------------------------------------------------------

# compiler flags for Coverage configuration
set (CMAKE_C_FLAGS_COVERAGE   "-g -O0 -Wall -W -fprofile-arcs -ftest-coverage")
set (CMAKE_CXX_FLAGS_COVERAGE "-g -O0 -Wall -W -fprofile-arcs -ftest-coverage")

# linker flags for Coverage configuration
set (CMAKE_EXE_LINKER_FLAGS_COVERAGE    "-fprofile-arcs -ftest-coverage")
set (CMAKE_MODULE_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage")
set (CMAKE_SHARED_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage")


endif (NOT BASIS_SETTINGS_INCLUDED)

