##############################################################################
# @file  Settings.cmake
# @brief BASIS configuration and default CMake settings used by projects.
#
# This module defines global CMake constants and variables which are used
# by the BASIS CMake functions and macros. Hence, these values can be used
# to configure the behaviour of these functions to some extent without the
# need to modify the functions themselves.
#
# Moreover, this file specifies the common CMake settings such as the build
# configuration used by projects following BASIS.
#
# @attention Be careful when caching any of the variables. Usually, this
#            file is included in the root CMake configuration file of the
#            project. The variables set by this module should only be valid
#            underneath this directory tree, but not propagate to the parent
#            or a sibling.
#
# @note As this file also sets the CMake policies to be used, it has to
#       be included using the @c NO_POLICY_SCOPE in order for these policies
#       to take effect also in the including file and its subdirectories.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

# ============================================================================
# system checks
# ============================================================================

include (CheckTypeSize)
include (CheckIncludeFile)

# check if type long long is supported
CHECK_TYPE_SIZE ("long long" LONG_LONG)

if (HAVE_LONG_LONG)
  set (HAVE_LONG_LONG 1)
else ()
  set (HAVE_LONG_LONG 0)
endif ()

# check for presence of sstream header
include (TestForSSTREAM)

if (CMAKE_NO_ANSI_STRING_STREAM)
  set (HAVE_SSTREAM 0)
else ()
  set (HAVE_SSTREAM 1)
endif ()

# check if tr/tuple header file is available
CHECK_INCLUDE_FILE ("tr1/tuple" HAVE_TR1_TUPLE)

if (HAVE_TR1_TUPLE)
  set (HAVE_TR1_TUPLE 1)
else ()
  set (HAVE_TR1_TUPLE 0)
endif ()

# check for availibility of pthreads library
find_package (Threads) # defines CMAKE_USE_PTHREADS_INIT and CMAKE_THREAD_LIBS_INIT

if (Threads_FOUND)
  if (CMAKE_USE_PTHREADS_INIT)
    set (HAVE_PTHREAD 1)
  else  ()
    set (HAVE_PTHREAD 0)
  endif ()
endif ()

# ============================================================================
# common options
# ============================================================================

## @addtogroup CMakeAPI
#  @{

## @brief Enable/Disable verbose messages of BASIS functions.
option (BASIS_VERBOSE "Whether BASIS functions should be verbose." "OFF")
mark_as_advanced (BASIS_VERBOSE)

## @brief Option to enable/disable build/installation of documentation.
#
# This option is only available if the @c PROJECT_DOC_DIR directory exists.
if (EXISTS "${PROJECT_DOC_DIR}")
  option (BUILD_DOCUMENTATION "Whether to build and/or install the documentation." ON)
endif ()

## @brief Option to enable/disable build/installation of example.
#
# This option is only available if the @c PROJECT_EXAMPLE_DIR directory exists.
if (EXISTS ${PROJECT_EXAMPLE_DIR})
  option (BUILD_EXAMPLE "Whether to build and/or install the example." ON)
endif ()

## @}

# ============================================================================
# constants and global settings
# ============================================================================

## @addtogroup CMakeUtilities
#  @{

## @brief List of names used for special purpose targets.
#
# Contains a list of target names that are used by the BASIS functions for
# special purposes and are hence not to be used for project targets.
set (BASIS_RESERVED_TARGET_NAMES
  "test"
  "uninstall"
  "doc"
  "changelog"
  "package"
  "package_source"
  "bundle"
  "bundle_source"
)

## @brief Default component used for library targets when no component is specified.
#
# The default component a library target and its auxiliary files
# are associated with if no component was specified, explicitly.
set (BASIS_LIBRARY_COMPONENT "Development")

## @brief Default component used for executables when no component is specified.
#
# The default component an executable target and its auxiliary files
# are associated with if no component was specified, explicitly.
set (BASIS_RUNTIME_COMPONENT "Runtime")

## @brief Character used to separate namespace and target name in target UID.
#
# This separator is used to construct a UID for a particular target.
# For example, "\<Project\>\@BASIS_NAMESPACE_SEPARATOR\@\<target\>".
# Note that the separator must only contain characters that are valid in
# a file path as only these characters can be used for CMake target names.
# Also the use of '#' in target names must be avoided.
#
# Note: For the mapping of target names to executable files, this separator
#       may for each language be replaced by a more suitable string.
#       For example, it is replaced by "::" for C++. See UtilitiesTools.cmake.
set (BASIS_NAMESPACE_SEPARATOR "@")

## @brief Character used to separate version and project name (e.g., in target UID).
#
# This separator is used to construct a UID for a particular target.
# For example, "\<Project\>\@BASIS_VERSION_SEPARATOR\@\<version\>\@BASIS_NAMESPACE_SEPARATOR\@\<target\>".
# Note that the version need not be included if only a single version of each
# package is supposed to be installed on a target system. The same rules as for
# @c BASIS_NAMESPACE_SEPARATOR regarding character selection apply.
set (BASIS_VERSION_SEPARATOR "-")

## @brief Prefix used for CMake package config files.
#
# This string is used as prefix for the names of the \<Package\>Config.cmake
# et al. files. For example, a value of "SBIA_", results in the CMake package
# configuration file "SBIA_\<Package\>Config.cmake".
set (BASIS_CONFIG_PREFIX "")

## @brief Script used to execute a process in CMake script mode.
#
# In order to be able to assign a timeout to the execution of a custom command
# and to add some error message parsing, this script is used by some build
# rules to actually perform the build step. See for example, the build of
# executables using the MATLAB Compiler.
set (BASIS_SCRIPT_EXECUTE_PROCESS "${CMAKE_CURRENT_LIST_DIR}/ExecuteProcess.cmake")

## @brief Default script configuration template.
#
# This is the default template used by basis_add_script() to configure the
# script during the build step. If the file
# @c PROJECT_CONFIG_DIR/ScriptConfig.cmake.in exists, the value of this variable
# is set to its path by basis_project_initialize().
set (BASIS_SCRIPT_CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/ScriptConfig.cmake.in")

## @brief File used by default as <tt>--authors</tt> file to <tt>svn2cl</tt>.
#
# This file lists all Subversion users at SBIA and is used by default for
# the mapping of Subversion user names to real names during the generation
# of changelogs.
set (BASIS_SVN_USERS_FILE "${CMAKE_CURRENT_LIST_DIR}/SubversionUsers.txt")

## @brief Installation sinfix.
set (BASIS_INSTALL_SINFIX "\@PROJECT_NAME_LOWER\@")

# ============================================================================
# cached variables
# ============================================================================

# The following variables are used across BASIS macros and functions. They
# in particular remember information added by one function or macro and is
# required by another function or macro.
#
# Note: These variables are reset whenever this module is included the first
#       time. The guard directive at the beginning of this file protects
#       these variables to be overwritten each time this module is included.

## @brief Documentation string for @c BASIS_CACHED_INCLUDE_DIRECTORIES.
set (BASIS_CACHED_INCLUDE_DIRECTORIES_DOC "All include directories.")
## @brief Cached include directories added across subdirectories.
set (BASIS_CACHED_INCLUDE_DIRECTORIES "" CACHE INTERNAL "${BASIS_CACHED_INCLUDE_DIRECTORIES_DOC}" FORCE)

## @brief Documentation string for @c BASIS_TARGETS.
set (BASIS_TARGETS_DOC "Names of all targets.")
## @brief Cached UIDs of all build targets.
set (BASIS_TARGETS "" CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE)

## @brief Documentation string for @c BASIS_EXPORT_TARGETS.
set (BASIS_EXPORT_TARGETS_DOC "All non-custom export targets.")
## @brief Cached UIDs of exported non-custom build targets.
set (BASIS_EXPORT_TARGETS "" CACHE INTERNAL "${BASIS_EXPORT_TARGETS_DOC}" FORCE)

## @brief Documentation string for @c BASIS_CUSTOM_EXPORT_TARGETS.
set (BASIS_CUSTOM_EXPORT_TARGETS_DOC "All custom export targets.")
## @brief Cached UIDs of exported custom build targets.
set (BASIS_CUSTOM_EXPORT_TARGETS "" CACHE INTERNAL "${BASIS_CUSTOM_EXPORT_TARGETS_DOC}" FORCE)


## @}

# ============================================================================
# project directory structure
# ============================================================================

## @addtogroup CMakeUtilities
#  @{

# ----------------------------------------------------------------------------
# assertions
# ----------------------------------------------------------------------------

##############################################################################
# @brief Ensure certain requirements on build tree.
#
# @param [in] ARGN Not used.
#
# @returns Nothing.

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

##############################################################################
# @brief Ensure certain requirements on install tree.
#
# @param [in] ARGN Not used.
#
# @returns Nothing.

macro (installtree_asserts)
  # prefix must be an absolute path
  if (NOT IS_ABSOLUTE "${INSTALL_PREFIX}")
    message (FATAL_ERROR "INSTALL_PREFIX must be an absolute path!")
  endif ()

  # install tree must be different from source and build tree
  string (TOLOWER "${CMAKE_SOURCE_DIR}" SOURCE_ROOT)
  string (TOLOWER "${CMAKE_BINARY_DIR}" BUILD_ROOT)
  string (TOLOWER "${INSTALL_PREFIX}"   INSTALL_ROOT)

  if ("${INSTALL_ROOT}" MATCHES "${BUILD_ROOT}|${SOURCE_ROOT}")
    message (FATAL_ERROR "The current INSTALL_PREFIX points at the source or build tree:\n"
                         "  ${INSTALL_PREFIX}\n"
                         "This is not supported. Please choose another installation prefix."
    )
  endif()
endmacro ()

# ----------------------------------------------------------------------------
# instantiation for specific project
# ----------------------------------------------------------------------------

##############################################################################
# @brief Instantiate project directory structure.
#
# This macro is invoked after the CMake project() command to instantiate
# the project directory structure, i.e., turn the directories into absolute
# paths using the CMake variables PROJECT_SOURCE_DIR and PROJECT_BINARY_DIR.
# Moreover, the occurences of \@PROJECT_NAME\@, \@PROJECT_NAME_LOWER\@,
# \@PROJECT_NAME_UPPER\@, \@PROJECT_VERSION\@, \@PROJECT_VERSION_MAJOR\@,
# \@PROJECT_VERSION_MINOR\@, and \@PROJECT_VERSION_PATH\@ are substituted by
# the actual values corresponding to the project name and version.
#
# @param [in] ARGN Not used.
#
# @returns Nothing.

macro (basis_initialize_directories)
  # source tree
  foreach (P CODE CONFIG DATA DOC EXAMPLE INCLUDE TESTING)
    set (VAR PROJECT_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()

  # build tree
  foreach (P CODE CONFIG DATA DOC EXAMPLE INCLUDE TESTING)
    file (RELATIVE_PATH SUBDIR "${PROJECT_SOURCE_DIR}" "${PROJECT_${P}_DIR}")
    set (BINARY_${P}_DIR "${PROJECT_BINARY_DIR}/${SUBDIR}")
  endforeach ()

  foreach (P RUNTIME LIBRARY ARCHIVE)
    set (VAR CMAKE_${P}_OUTPUT_DIRECTORY)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
    set (BINARY_${P}_DIR "${${VAR}}")
  endforeach ()

  # testing tree
  foreach (P RUNTIME LIBRARY OUTPUT)
    set (VAR TESTING_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()

  # install tree
  string (CONFIGURE "${INSTALL_PREFIX}" INSTALL_PREFIX @ONLY)

  set (CMAKE_INSTALL_PREFIX "${INSTALL_PREFIX}" CACHE INTERNAL "" FORCE)

  foreach (P RUNTIME LIBEXEC LIBRARY ARCHIVE INCLUDE SHARE DATA DOC EXAMPLE MAN)
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

## @}

## @addtogroup CMakeAPI
#  @{

# ----------------------------------------------------------------------------
# source tree
# ----------------------------------------------------------------------------

# Note: The project template must follow this directory structure.
#       Ideally, when changing the name of one of these directories,
#       only the directory structure of the tempate needs to be updated.
#       The BASIS CMake functions should not be required to change as they
#       are supposed to use these variables instead of the actual names.

## @brief Absolute path of directory of project sources in source tree.
set (PROJECT_CODE_DIR "@PROJECT_SOURCE_DIR@/src")
## @brief Absolute path of directory of BASIS project configuration in source tree.
set (PROJECT_CONFIG_DIR "@PROJECT_SOURCE_DIR@/config")
## @brief Absolute path of directory of auxiliary data in source tree.
set (PROJECT_DATA_DIR "@PROJECT_SOURCE_DIR@/data")
## @brief Absolute path of directory of documentation files in source tree.
set (PROJECT_DOC_DIR "@PROJECT_SOURCE_DIR@/doc")
## @brief Absolute path of directory of example in source tree.
set (PROJECT_EXAMPLE_DIR "@PROJECT_SOURCE_DIR@/example")
## @brief Absolute path of diretory of public header files in source tree.
set (PROJECT_INCLUDE_DIR "@PROJECT_SOURCE_DIR@/include")
## @brief Absolute path of directory of testing tree in source tree.
set (PROJECT_TESTING_DIR "@PROJECT_SOURCE_DIR@/test")

# ----------------------------------------------------------------------------
# testing tree
# ----------------------------------------------------------------------------

## @brief Absolute path of output directory for tests.
set (TESTING_OUTPUT_DIR "@PROJECT_BINARY_DIR@/Testing/Temporary")
## @brief Absolute path of output directory for built test executables.
set (TESTING_RUNTIME_DIR "@PROJECT_BINARY_DIR@/Testing/bin")
## @brief Absolute path of output directory for testing libraries.
set (TESTING_LIBRARY_DIR "@PROJECT_BINARY_DIR@/Testing/lib")
## @brief Absolute path of output directory for Python modules used for testing.
set (TESTING_PYTHON_LIBRARY_DIR "@PROJECT_BINARY_DIR@/Testing/lib/python")
## @brief Absolute path of output directory for Perl modules used for testing.
set (TESTING_PERL_LIBRARY_DIR "@PROJECT_BINARY_DIR@/Testing/lib/perl5")

# ----------------------------------------------------------------------------
# build tree
# ----------------------------------------------------------------------------

# These directory paths will be made absolute by the initialization functions.

## @brief Absolute path of output directory for built runtime executables.
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "@PROJECT_BINARY_DIR@/bin")
## @brief Absolute path of output directory for built shared libraries and modules.
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "@PROJECT_BINARY_DIR@/lib")
## @brief Absolute path of output directory for built static libraries.
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "@PROJECT_BINARY_DIR@/lib")
## @brief Absolute path of output directory for Python modules.
set (BINARY_PYTHON_LIBRARY_DIR "@PROJECT_BINARY_DIR@/lib/python")
## @brief Absolute path of output directory for Perl modules.
set (BINARY_PERL_LIBRARY_DIR "@PROJECT_BINARY_DIR@/lib/perl5")

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

## @brief Installation prefix.
set (
  INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}"
  CACHE PATH "Installation directories prefix."
)

## @brief Whether to use project name as installation sinfix.
option (INSTALL_SINFIX "Whether to use the project name as installation path suffix (or infix, respectively)." ON)

## @brief Enable/Disable installation of symbolic links on Unix-based systems.
if (UNIX)
  option (INSTALL_LINKS "Whether to create (symbolic) links." ON)
endif ()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# executable
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## @brief Path of installation directory for runtime executables and shared
#         libraries on Windows relative to @c INSTALL_PREFIX.
set (INSTALL_RUNTIME_DIR "bin")

## @brief Path of installation directory for auxiliary executables
#         relative to @c INSTALL_PREFIX.
if (WIN32)
  set (INSTALL_LIBEXEC_DIR "bin")
else ()
  set (INSTALL_LIBEXEC_DIR "lib")
endif ()

# prepend INSTALL_SINFIX
if (INSTALL_SINFIX)
  foreach (P RUNTIME LIBEXEC)
    set (VAR "INSTALL_${P}_DIR")
    set (${VAR} "${${VAR}}/${BASIS_INSTALL_SINFIX}")
  endforeach ()
endif ()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# libraries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## @brief Path of installation directory for public header files
#         relative to @c INSTALL_PREFIX.
#
# @note The include path is identical for each project. The directory
#       structure under the @c PROJECT_INCLUDE_DIR is preserved when public
#       header files are installed.
set (INSTALL_INCLUDE_DIR "include")

## @brief Path of installation directory for shared libraries on Unix-based
#         systems and module libraries relative to @c INSTALL_PREFIX.
set (INSTALL_LIBRARY_DIR "lib")

## @brief Path of installation directory for static and import libraries
#         relative to @c INSTALL_PREFIX.
set (INSTALL_ARCHIVE_DIR "lib")

# prepend INSTALL_SINFIX
if (INSTALL_SINFIX)
  foreach (P LIBRARY ARCHIVE)
    set (VAR "INSTALL_${P}_DIR")
    set (${VAR} "${${VAR}}/${BASIS_INSTALL_SINFIX}")
  endforeach ()
endif ()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# script modules
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Similar to the public header files of C/C++ libraries, the modules written
# in Python or Perl are installed with fixed relative directories which
# correspond to the packages these modules belong to:
#
# Python: sbia.<project>
# Perl:   SBIA::<Project>
#
# As here the project name is already part of the file path and has to
# remain fixed, otherwise the modules would not know how to refer to each
# other in the source  code, the INSTALL_SINFIX is not used here.

## @brief Path of installation directory for Python modules relative to @c INSTALL_PREFIX.
set (INSTALL_PYTHON_LIBRARY_DIR "lib/python")

## @brief Path of installation directory for Perl modules relative to @c INSTALL_PREFIX.
set (INSTALL_PERL_LIBRARY_DIR "lib/perl5")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# build configuration
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## @brief Path of installation directory for CMake package configuration
#         files relative to @c INSTALL_PREFIX.
if (WIN32)
  set (INSTALL_CONFIG_DIR "cmake")
else ()
  set (INSTALL_CONFIG_DIR "lib/cmake")
endif ()

# prepend INSTALL_SINFIX
if (INSTALL_SINFIX)
  set (INSTALL_CONFIG_DIR "${INSTALL_CONFIG_DIR}/${BASIS_INSTALL_SINFIX}")
endif ()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# shared data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## @brief Path of installation directory for shared files
#         relative to @c INSTALL_PREFIX.
set (INSTALL_SHARE_DIR "share")

# prepend INSTALL_SINFIX
if (INSTALL_SINFIX)
  set (INSTALL_SHARE_DIR "${INSTALL_SHARE_DIR}/${BASIS_INSTALL_SINFIX}")
endif ()

## @brief Path of installation directory for shared data files
#         relative to @c INSTALL_PREFIX.
set (INSTALL_DATA_DIR "${INSTALL_SHARE_DIR}/data")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# documentation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## @brief Path of installation directory for documentation files
#         relative to @c INSTALL_PREFIX.
if (WIN32)
  set (INSTALL_DOC_DIR "doc")
else ()
  set (INSTALL_DOC_DIR "${INSTALL_SHARE_DIR}/doc")
endif ()

## @brief Path of installation directory for example files
#         relative to @c INSTALL_PREFIX.
if (WIN32)
  set (INSTALL_EXAMPLE_DIR "example")
else ()
  set (INSTALL_EXAMPLE_DIR "${INSTALL_SHARE_DIR}/example")
endif ()

## @brief Path of installation directory for man pages
#         relative to @c INSTALL_PREFIX.
if (WIN32)
  set (INSTALL_MAN_DIR "man")
else ()
  set (INSTALL_MAN_DIR "${INSTALL_SHARE_DIR}/man")
endif ()

# prepend INSTALL_SINFIX
if (WIN32 AND INSTALL_SINFIX)
  foreach (P DOC EXAMPLE MAN)
    set (VAR "INSTALL_${P}_DIR")
    set (${VAR} "${${VAR}}/${BASIS_INSTALL_SINFIX}")
  endforeach ()
endif ()

# ============================================================================
# build configuration(s)
# ============================================================================

## @brief List of all available/supported build configurations.
set (
  CMAKE_CONFIGURATION_TYPES
    "Debug"
    "Coverage"
    "Release"
  CACHE STRING "Build configurations." FORCE
)

## @brief List of debug configurations.
#
# Used by the target_link_libraries() CMake command, for example,
# to determine whether to link to the optimized or debug libraries.
set (DEBUG_CONFIGURATIONS "Debug")

mark_as_advanced (CMAKE_CONFIGURATION_TYPES)
mark_as_advanced (DEBUG_CONFIGURATIONS)

if (NOT CMAKE_BUILD_TYPE MATCHES "^Debug$|^Coverage$|^Release$")
  set (CMAKE_BUILD_TYPE "Release")
endif ()

## @brief Current build configuration for GNU Make Makefiles generator.
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
set (CMAKE_EXE_LINKER_FLAGS    "${CMAKE_LINKER_FLAGS}")
set (CMAKE_MODULE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}")
set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}")

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

## @}
