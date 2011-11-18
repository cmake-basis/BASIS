##############################################################################
# @file  BasisSettings.cmake
# @brief BASIS configuration and default CMake settings used by projects.
#
# This module defines global CMake constants and variables which are used
# by the BASIS CMake functions and macros. Hence, these values can be used
# to configure the behavior of these functions to some extent without the
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
# @note Variables in this file which are only set if not set previously, e.g.,
#       by using basis_set_if_empty(), are set when this file is included
#       the first time by a project, but not changed when it is included by
#       a module of this project. This is important in order to merge the
#       module's output files with the files of the project it is part of.
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
# CMake version and policies
# ============================================================================

cmake_minimum_required (VERSION 2.8.4)

# Add policies introduced with CMake versions newer than the one specified
# above. These policies would otherwise trigger a policy not set warning by
# newer CMake versions.

if (POLICY CMP0016)
  cmake_policy (SET CMP0016 NEW)
endif ()

if (POLICY CMP0017)
  cmake_policy (SET CMP0017 NEW)
endif ()

# ============================================================================
# modules
# ============================================================================

include ("${CMAKE_CURRENT_LIST_DIR}/CommonTools.cmake") # basis_set_if_empty()

# ============================================================================
# system checks
# ============================================================================

# used by tests to disable these checks
if (NOT BASIS_NO_SYSTEM_CHECKS)
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
endif ()

# ============================================================================
# common options
# ============================================================================

## @addtogroup CMakeAPI
#  @{


## @brief Enable/Disable verbose messages of BASIS functions.
option (BASIS_VERBOSE "Whether BASIS functions should be verbose." OFF)
mark_as_advanced (BASIS_VERBOSE)


## @}
# end of Doxygen group

# ============================================================================
# constants and global settings
# ============================================================================

## @addtogroup CMakeUtilities
#  @{


## @brief List of names used for special purpose targets.
#
# Contains a list of target names that are used by the BASIS functions for
# special purposes and are hence not to be used for project targets.
basis_set_if_empty (
  BASIS_RESERVED_TARGET_NAMES
    "test"
    "headers"
    "check_headers"
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
basis_set_if_empty (BASIS_LIBRARY_COMPONENT "Development")

## @brief Default component used for executables when no component is specified.
#
# The default component an executable target and its auxiliary files
# are associated with if no component was specified, explicitly.
basis_set_if_empty (BASIS_RUNTIME_COMPONENT "Runtime")

## @brief Specifies that the BASIS C++ utilities shall by default not be added
#         as dependency of an executable.
basis_set_if_empty (BASIS_NO_BASIS_UTILITIES FALSE)

## @brief Script used to execute a process in CMake script mode.
#
# In order to be able to assign a timeout to the execution of a custom command
# and to add some error message parsing, this script is used by some build
# rules to actually perform the build step. See for example, the build of
# executables using the MATLAB Compiler.
basis_set_if_empty (BASIS_SCRIPT_EXECUTE_PROCESS "${CMAKE_CURRENT_LIST_DIR}/ExecuteProcess.cmake")

## @brief Default script configuration template.
#
# This is the default template used by basis_add_script() to configure the
# script during the build step. If the file
# @c PROJECT_CONFIG_DIR/ScriptConfig.cmake.in exists, the value of this variable
# is set to its path by basis_project_initialize().
basis_set_if_empty (BASIS_SCRIPT_CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/ScriptConfig.cmake.in")

## @brief File used by default as <tt>--authors</tt> file to <tt>svn2cl</tt>.
#
# This file lists all Subversion users at SBIA and is used by default for
# the mapping of Subversion user names to real names during the generation
# of changelogs.
basis_set_if_empty (BASIS_SVN_USERS_FILE "${CMAKE_CURRENT_LIST_DIR}/SubversionUsers.txt")

## @brief Character used to separate namespace and target name in target UID.
#
# This separator is used to construct a UID for a particular target.
# For example, "\@BASIS_NAMESPACE\@\@BASIS_NAMESPACE_SEPARATOR\@&lt;target&gt;".
# Note that the separator must only contain characters that are valid in
# a file path as only these characters can be used for CMake target names.
#
# @attention The use of '#' in target names must be avoided as this
#            starts a comment in CMake. Further, even though '::' is familiar
#            to C++ developers, this is only allowed on Unix, but not on
#            Windows as part of a file or directory name.
basis_set_if_empty (BASIS_NAMESPACE_SEPARATOR ".")

## @brief Character used to separate version and project name (e.g., in target UID).
#
# This separator is used to construct a UID for a particular target. For example,
# "&lt;Project&gt;\@BASIS_VERSION_SEPARATOR\@&lt;version&gt;\@BASIS_NAMESPACE_SEPARATOR\@&lt;target&gt;".
# Note that the version need not be included if only a single version of each
# package is supposed to be installed on a target system. The same rules as for
# @c BASIS_NAMESPACE_SEPARATOR regarding character selection apply.
#
# @note Not used by the current implementation.
basis_set_if_empty (BASIS_VERSION_SEPARATOR "-")

## @brief Namespace used for the current project.
#
# The namespace of a BASIS project is made up of its name as well as the
# names of the projects it is a module of, i.e., the namespace encodes the
# super-/subproject relationship and guarantees uniqueness of target names
# and other identifiers.
#
# This variable is in particular used to convert build target names of
# modules of a project unique in order to avoid name conflicts.
if (PROJECT_IS_MODULE)
  set (BASIS_NAMESPACE "\@PROJECT_NAME_INFIX\@")
else ()
  basis_set_if_empty (BASIS_NAMESPACE "\@PROJECT_NAME_INFIX\@")
endif ()

## @brief Installation prefix for public header files.
#
# The prefix used for the installation of public header files under the
# @c INSTALL_INCLUDE_DIR, i.e., the header files have to be included in a
# source file as:
# @code
# #include <@INCLUDE_PREFIX@config.h>
# @endcode
# This avoids name conflicts among projects in a more reliable way then only
# changing the order of paths in the include search path.
#
# If this project is a module of another project, it appends it's name to the
# already set include prefix. Otherwise, the include prefix is set to the
# common default prefix of BASIS projects first, i.e., "sbia", and then the
# name of the project is appended.
#
# @note The include prefix must end with a slash if it is a subdirectory.
#       BASIS will not use a slash by itself to separate the prefix from
#       the header file name.
basis_set_if_empty (INCLUDE_PREFIX "sbia/\@PROJECT_NAME_INFIX\@/")

## @brief Installation sinfix.
#
# The suffix/infix used for installation directories. If this project is not
# a module of another project, the sinfix is cached during the first
# configuration which enables the user to modify it. Modules, on the other
# side, append their name to the already set sinfix.
if (WIN32)
  basis_set_if_empty (BASIS_INSTALL_SINFIX "\@PROJECT_NAME_INFIX\@" CACHE STRING "Suffix/Infix used for installation paths.")
else ()
  basis_set_if_empty (BASIS_INSTALL_SINFIX "sbia/\@PROJECT_NAME_INFIX\@" CACHE STRING "Suffix/Infix used for installation paths.")
endif ()
mark_as_advanced (BASIS_INSTALL_SINFIX)


## @}
# end of Doxygen group

# ============================================================================
# project directory structure
# ============================================================================

## @addtogroup CMakeAPI
#  @{


# ----------------------------------------------------------------------------
# assertions
# ----------------------------------------------------------------------------

##############################################################################
# @brief Ensure certain requirements on build tree.
#
# Requirements:
# * Root of build tree must not be root of source tree.
#
# @param [in] ARGN Not used.
#
# @returns Nothing.
#
# @ingroup CMakeUtilities

macro (basis_buildtree_asserts)
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
# Requirements:
# * Prefix must be an absolute path.
# * Install tree must be different from source and build tree.
#
# @param [in] ARGN Not used.
#
# @returns Nothing.
#
# @ingroup CMakeUtilities

macro (basis_installtree_asserts)
  if (NOT IS_ABSOLUTE "${INSTALL_PREFIX}")
    message (FATAL_ERROR "INSTALL_PREFIX must be an absolute path!")
  endif ()

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
# source tree
# ----------------------------------------------------------------------------

# Note: The project template must follow this directory structure.
#       Ideally, when changing the name of one of these directories,
#       only the directory structure of the tempate needs to be updated.
#       The BASIS CMake functions should not be required to change as they
#       are supposed to use these variables instead of the actual names.

# Attention: Always reset these variables as they are used by both, the
#            project and its modules.

## @brief Absolute path of directory of project sources in source tree.
set (PROJECT_CODE_DIR "\@PROJECT_SOURCE_DIR\@/src")
## @brief Absolute path of directory of BASIS project configuration in source tree.
set (PROJECT_CONFIG_DIR "\@PROJECT_SOURCE_DIR\@/config")
## @brief Absolute path of directory of auxiliary data in source tree.
set (PROJECT_DATA_DIR "\@PROJECT_SOURCE_DIR\@/data")
## @brief Absolute path of directory of documentation files in source tree.
set (PROJECT_DOC_DIR "\@PROJECT_SOURCE_DIR\@/doc")
## @brief Absolute path of directory of example in source tree.
set (PROJECT_EXAMPLE_DIR "\@PROJECT_SOURCE_DIR\@/example")
## @brief Absolute path of diretory of public header files in source tree.
set (PROJECT_INCLUDE_DIR "\@PROJECT_SOURCE_DIR\@/include")
## @brief Absolute path of directory of project modules.
set (PROJECT_MODULES_DIR "\@PROJECT_SOURCE_DIR\@/modules")
## @brief Absolute path of directory of testing tree in source tree.
set (PROJECT_TESTING_DIR "\@PROJECT_SOURCE_DIR\@/test")

# ----------------------------------------------------------------------------
# testing tree
# ----------------------------------------------------------------------------

## @brief Absolute path of output directory for tests.
basis_set_if_empty (TESTING_OUTPUT_DIR "\@PROJECT_BINARY_DIR\@/Testing/Temporary")
## @brief Absolute path of output directory for built test executables.
basis_set_if_empty (TESTING_RUNTIME_DIR "\@PROJECT_BINARY_DIR\@/Testing/bin")
## @brief Absolute path of output directory for testing libraries.
basis_set_if_empty (TESTING_LIBRARY_DIR "\@PROJECT_BINARY_DIR\@/Testing/lib")
## @brief Absolute path of output directory for Python modules used for testing.
basis_set_if_empty (TESTING_PYTHON_LIBRARY_DIR "\@PROJECT_BINARY_DIR\@/Testing/lib/python")
## @brief Absolute path of output directory for Perl modules used for testing.
basis_set_if_empty (TESTING_PERL_LIBRARY_DIR "\@PROJECT_BINARY_DIR\@/Testing/lib/perl5")

# ----------------------------------------------------------------------------
# build tree
# ----------------------------------------------------------------------------

# These directory paths will be made absolute by the initialization functions.

## @brief Absolute path of output directory for main executables.
basis_set_if_empty (BINARY_RUNTIME_DIR "\@PROJECT_BINARY_DIR\@/bin")
## @brief Absolute path of output directory for auxiliary executables.
basis_set_if_empty (BINARY_LIBEXEC_DIR "\@PROJECT_BINARY_DIR\@/lib")
## @brief Absolute path of output directory for shared libraries and modules.
basis_set_if_empty (BINARY_LIBRARY_DIR "\@PROJECT_BINARY_DIR\@/lib")
## @brief Absolute path of output directory for static and import libraries.
basis_set_if_empty (BINARY_ARCHIVE_DIR "\@PROJECT_BINARY_DIR\@/lib")
## @brief Absolute path of output directory for Python modules.
basis_set_if_empty (BINARY_PYTHON_LIBRARY_DIR "\@PROJECT_BINARY_DIR\@/lib/python")
## @brief Absolute path of output directory for Perl modules.
basis_set_if_empty (BINARY_PERL_LIBRARY_DIR "\@PROJECT_BINARY_DIR\@/lib/perl5")

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

# hide CMAKE_INSTALL_PREFIX
set_property (CACHE CMAKE_INSTALL_PREFIX PROPERTY TYPE INTERNAL)

## @brief Installation prefix.
set (
  INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}"
  CACHE PATH "Prefix used for installation paths."
)

## @brief Whether to use installation sinfix.
option (INSTALL_SINFIX "Whether to use the package-specific installation path suffix/infix." ON)

if (INSTALL_SINFIX)
  set_property (CACHE BASIS_INSTALL_SINFIX PROPERTY TYPE STRING)
else ()
  set_property (CACHE BASIS_INSTALL_SINFIX PROPERTY TYPE INTERNAL)
endif ()

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

# Note: CMake's find_package() command considers certain directories.
#       Hence, the variable BASIS_INSTALL_SINFIX which may not comply to
#       the naming of standard locations this command would look through,
#       cannot be used here.

## @brief Path of installation directory for CMake package configuration
#         files relative to @c INSTALL_PREFIX.
if (WIN32)
  basis_set_if_empty (INSTALL_CONFIG_DIR "cmake")
else ()
  basis_set_if_empty (INSTALL_CONFIG_DIR "lib/cmake/\@PROJECT_NAME_INFIX\@")
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
# initialize settings
# ============================================================================

##############################################################################
# @brief Initialize project settings.
#
# This macro is invoked after the CMake project() command to instantiate
# the project directory structure, i.e., turn the directories into absolute
# paths using the CMake variables PROJECT_SOURCE_DIR and PROJECT_BINARY_DIR.
# Moreover, the occurences of \@PROJECT_NAME\@, \@PROJECT_NAME_LOWER\@,
# \@PROJECT_NAME_UPPER\@, \@PROJECT_VERSION\@, \@PROJECT_VERSION_MAJOR\@,
# \@PROJECT_VERSION_MINOR\@, and \@PROJECT_VERSION_PATH\@ are substituted by
# the actual values corresponding to the project name and version.
#
# Moreover, other constants used by BASIS are configured such that project
# specific strings as the project name are substituted.
#
# @param [in] ARGN Not used.
#
# @returns Nothing.

macro (basis_initialize_settings)
  # --------------------------------------------------------------------------
  # instantiate project directory structure

  # source tree
  foreach (P CODE CONFIG DATA DOC EXAMPLE INCLUDE MODULES TESTING)
    set (VAR PROJECT_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()

  # build tree
  foreach (P CODE CONFIG DATA DOC EXAMPLE INCLUDE MODULES TESTING)
    file (RELATIVE_PATH SUBDIR "${PROJECT_SOURCE_DIR}" "${PROJECT_${P}_DIR}")
    basis_set_if_empty (BINARY_${P}_DIR "${PROJECT_BINARY_DIR}/${SUBDIR}")
  endforeach ()

  foreach (P RUNTIME LIBEXEC LIBRARY ARCHIVE PYTHON_LIBRARY PERL_LIBRARY)
    set (VAR BINARY_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()

  set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${BINARY_RUNTIME_DIR}")
  set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${BINARY_LIBRARY_DIR}")
  set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${BINARY_ARCHIVE_DIR}")

  # testing tree
  foreach (P RUNTIME LIBRARY OUTPUT)
    set (VAR TESTING_${P}_DIR)
    string (CONFIGURE "${${VAR}}" ${VAR} @ONLY)
  endforeach ()

  # install tree
  string (CONFIGURE "${INSTALL_PREFIX}" INSTALL_PREFIX @ONLY)
  string (CONFIGURE "${BASIS_INSTALL_SINFIX}" BASIS_INSTALL_SINFIX @ONLY)
  basis_set_if_empty (INSTALL_PREFIX "${INSTALL_PREFIX}" CACHE PATH "Prefix used for installation paths." FORCE)
  set (CMAKE_INSTALL_PREFIX "${INSTALL_PREFIX}" CACHE INTERNAL "" FORCE)
  basis_set_if_empty (BASIS_INSTALL_SINFIX "${BASIS_INSTALL_SINFIX}" CACHE STRING "Suffix/Infix used for installation paths." FORCE)

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

  # --------------------------------------------------------------------------
  # project properties

  # The following variables are used across BASIS macros and functions. They
  # in particular remember information added by one function or macro which
  # is required by another function or macro.
  #
  # These variables need to be properties such that they can be set in
  # subdirectories. Moreover, they have to be assigned with the project's
  # root source directory such that a super-project's properties are restored
  # after this subproject is finalized such that the super-project itself can
  # be finalized properly.

  # list of all include directories
  basis_set_project_property (PROJECT_INCLUDE_DIRS "")
  # list of all build targets
  basis_set_project_property (TARGETS "")
  # list of all exported targets
  basis_set_project_property (EXPORT_TARGETS "")
  # list of all exported custom targets
  basis_set_project_property (CUSTOM_EXPORT_TARGETS "")

  basis_set_project_property (PROJECT_USES_JAVA_UTILITIES   FALSE)
  basis_set_project_property (PROJECT_USES_PYTHON_UTILITIES FALSE)
  basis_set_project_property (PROJECT_USES_PERL_UTILITIES   FALSE)
  basis_set_project_property (PROJECT_USES_BASH_UTILITIES   FALSE)
  basis_set_project_property (PROJECT_USES_MATLAB_UTILITIES FALSE)

  # --------------------------------------------------------------------------
  # other constants

  string (CONFIGURE "${BASIS_NAMESPACE}" BASIS_NAMESPACE @ONLY)
  string (CONFIGURE "${INCLUDE_PREFIX}"  INCLUDE_PREFIX  @ONLY)

  basis_sanitize_for_regex (PROJECT_NAME_REGEX "${PROJECT_NAME}")
  basis_sanitize_for_regex (BASIS_NAMESPACE_REGEX "${BASIS_NAMESPACE}")
  basis_sanitize_for_regex (BASIS_NAMESPACE_SEPARATOR_REGEX "${BASIS_NAMESPACE_SEPARATOR}")

  # --------------------------------------------------------------------------
  # assertions

  basis_buildtree_asserts ()
  basis_installtree_asserts ()
endmacro ()

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
  if (NOT CMAKE_BUILD_TYPE STREQUAL "")
    message ("Invalid build type ${CMAKE_BUILD_TYPE}! Setting CMAKE_BUILD_TYPE to Release.")
  endif ()
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

# set the possible values of build type for cmake-gui
set_property (CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "Coverage")

# ----------------------------------------------------------------------------
# disabled configurations
# ----------------------------------------------------------------------------

# disable support for MinSizeRel and RelWithDebInfo
foreach (C MINSIZEREL RELWITHDEBINFO)
  # compiler flags
  set_property (CACHE CMAKE_C_FLAGS_${C} PROPERTY TYPE INTERNAL)
  set_property (CACHE CMAKE_CXX_FLAGS_${C} PROPERTY TYPE INTERNAL)

  # linker flags
  set_property (CACHE CMAKE_EXE_LINKER_FLAGS_${C} PROPERTY TYPE INTERNAL)
  set_property (CACHE CMAKE_MODULE_LINKER_FLAGS_${C} PROPERTY TYPE INTERNAL)
  set_property (CACHE CMAKE_SHARED_LINKER_FLAGS_${C} PROPERTY TYPE INTERNAL)
endforeach ()

# disable support for plain C
set_property (CACHE CMAKE_C_FLAGS PROPERTY TYPE INTERNAL)
foreach (C DEBUG RELEASE)
  set_property (CACHE CMAKE_C_FLAGS_${C} PROPERTY TYPE INTERNAL)
endforeach ()

unset (C)

# ----------------------------------------------------------------------------
# common
# ----------------------------------------------------------------------------

# common compiler flags
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

# common linker flags
set (CMAKE_EXE_LINKER_FLAGS    "${CMAKE_LINKER_FLAGS}")
set (CMAKE_MODULE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}")
set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}")

# ----------------------------------------------------------------------------
# Debug
# ----------------------------------------------------------------------------

# compiler flags of Debug configuration
set (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")

# linker flags of Debug configuration
set (CMAKE_EXE_LINKER_FLAGS_DEBUG    "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
set (CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
set (CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")

# ----------------------------------------------------------------------------
# Release
# ----------------------------------------------------------------------------

# compiler flags of Release configuration
set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")

# linker flags of Release configuration
set (CMAKE_EXE_LINKER_FLAGS_RELEASE    "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set (CMAKE_MODULE_LINKER_FLAGS_RELEASE "${CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
set (CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")

# ----------------------------------------------------------------------------
# Coverage
# ----------------------------------------------------------------------------

# compiler flags for Coverage configuration
set (CMAKE_C_FLAGS_COVERAGE "" CACHE INTERNAL "" FORCE)
set (CMAKE_CXX_FLAGS_COVERAGE "-g -O0 -Wall -W -fprofile-arcs -ftest-coverage")

# linker flags for Coverage configuration
set (CMAKE_EXE_LINKER_FLAGS_COVERAGE    "-fprofile-arcs -ftest-coverage")
set (CMAKE_MODULE_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage")
set (CMAKE_SHARED_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage")


## @}
# end of Doxygen group
