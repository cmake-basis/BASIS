##############################################################################
# \file  BasisGlobals.cmake
# \brief Definition of global CMake constants and variables.
#
# This CMake module defines global CMake constants (variables whose value must
# not be modified), and global CMake variables used across the BASIS CMake
# functions and macros.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

if (NOT BASIS_GLOBALS_INCLUDED)
set (BASIS_GLOBALS_INCLUDED 1)


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# options
# ============================================================================

option (BASIS_VERBOSE "Whether BASIS functions should be verbose." "OFF")
mark_as_advanced (BASIS_VERBOSE)

# ============================================================================
# constants
# ============================================================================

# List of names used for special purpose targets.
set (BASIS_RESERVED_TARGET_NAMES "uninstall" "doc" "changelog" "execname")

# Default component used when no component is specified.
set (BASIS_DEFAULT_COMPONENT "Runtime")

# Character used to separated namespace and target name to build target UID.
set (BASIS_NAMESPACE_SEPARATOR "@")

# Character used to separated version and project name (e.g., in target UID).
set (BASIS_VERSION_SEPARATOR "#")

# Prefix used for CMake package config files.
set (BASIS_CONFIG_PREFIX "")

# Script used to execute a process in CMake script mode.
set (BASIS_SCRIPT_EXECUTE_PROCESS "${CMAKE_CURRENT_LIST_DIR}/ExecuteProcess.cmake")

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


endif (NOT BASIS_GLOBALS_INCLUDED)

