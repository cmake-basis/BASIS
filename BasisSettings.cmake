##############################################################################
# @file  BasisSettings.cmake
# @brief Default project-independent settings.
#
# This module defines global CMake constants and variables which are used
# by the BASIS CMake functions and macros. Hence, these values can be used
# to configure the behavior of these functions to some extent without the
# need to modify the functions themselves.
#
# @note As this file also sets the CMake policies to be used, it has to
#       be included using the @c NO_POLICY_SCOPE in order for these policies
#       to take effect also in the including file and its subdirectories.
#
# @attention Be careful when caching any of the variables. Usually, this
#            file is included in the root CMake configuration file of the
#            project which may also be a module of another project and hence
#            may overwrite this project's settings.
#
# @attention Keep in mind that this file is included before any other
#            BASIS module. Further, project-specific information such as
#            the project name are not defined yet.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisSettings
##############################################################################

## @addtogroup BasisSettings
# @{


# ============================================================================
# required modules
# ============================================================================

include ("${CMAKE_CURRENT_LIST_DIR}/CommonTools.cmake")

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
  # defines CMAKE_USE_PTHREADS_INIT and CMAKE_THREAD_LIBS_INIT
  find_package (Threads)

  if (Threads_FOUND)
    if (CMAKE_USE_PTHREADS_INIT)
      set (HAVE_PTHREAD 1)
    else  ()
      set (HAVE_PTHREAD 0)
    endif ()
  endif ()
endif ()

# ============================================================================
# constants and global settings
# ============================================================================

## @brief List of names used for special purpose targets.
#
# Contains a list of target names that are used by the BASIS functions for
# special purposes and are hence not to be used for project targets.
set (
  BASIS_RESERVED_TARGET_NAMES
    "all"
    "bundle"
    "bundle_source"
    "changelog"
    "clean"
    "depend"
    "doc"
    "headers"
    "headers_check"
    "package"
    "package_source"
    "scripts"
    "test"
    "uninstall"
)

## @brief Names of recognized properties on targets.
#
# Unfortunately, the @c ARGV and @c ARGN arguments of a CMake function()
# or macro() does not preserve values which themselves are lists. Therefore,
# it is not possible to distinguish between property names and their values
# in the arguments passed to set_target_properties() or
# basis_set_target_properties(). To overcome this problem, this list specifies
# all the possible property names. Everything else is considered to be a
# property value except the first argument follwing right after the
# @c PROPERTIES keyword. Alternatively, basis_set_property() can be used
# as here no disambiguity exists.
#
# @note Placeholders such as &lt;CONFIG&gt; are allowed. These are treated
#       as the regular expression "[^ ]+". See basis_list_to_regex().
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#section_PropertiesonTargets
set (BASIS_PROPERTIES_ON_TARGETS
  # CMake
  <CONFIG>_OUTPUT_NAME
  <CONFIG>_POSTFIX
  ARCHIVE_OUTPUT_DIRECTORY
  ARCHIVE_OUTPUT_DIRECTORY_<CONFIG>
  ARCHIVE_OUTPUT_NAME
  ARCHIVE_OUTPUT_NAME_<CONFIG>
  AUTOMOC
  BUILD_WITH_INSTALL_RPATH
  BUNDLE
  BUNDLE_EXTENSION
  COMPILE_DEFINITIONS
  COMPILE_DEFINITIONS_<CONFIG>
  COMPILE_FLAGS
  DEBUG_POSTFIX
  DEFINE_SYMBOL
  ENABLE_EXPORTS
  EXCLUDE_FROM_ALL
  EchoString
  FOLDER
  FRAMEWORK
  Fortran_FORMAT
  Fortran_MODULE_DIRECTORY
  GENERATOR_FILE_NAME
  HAS_CXX
  IMPLICIT_DEPENDS_INCLUDE_TRANSFORM
  IMPORTED
  IMPORTED_CONFIGURATIONS
  IMPORTED_IMPLIB
  IMPORTED_IMPLIB_<CONFIG>
  IMPORTED_LINK_DEPENDENT_LIBRARIES
  IMPORTED_LINK_DEPENDENT_LIBRARIES_<CONFIG>
  IMPORTED_LINK_INTERFACE_LANGUAGES
  IMPORTED_LINK_INTERFACE_LANGUAGES_<CONFIG>
  IMPORTED_LINK_INTERFACE_LIBRARIES
  IMPORTED_LINK_INTERFACE_LIBRARIES_<CONFIG>
  IMPORTED_LINK_INTERFACE_MULTIPLICITY
  IMPORTED_LINK_INTERFACE_MULTIPLICITY_<CONFIG>
  IMPORTED_LOCATION
  IMPORTED_LOCATION_<CONFIG>
  IMPORTED_NO_SONAME
  IMPORTED_NO_SONAME_<CONFIG>
  IMPORTED_SONAME
  IMPORTED_SONAME_<CONFIG>
  IMPORT_PREFIX
  IMPORT_SUFFIX
  INSTALL_NAME_DIR
  INSTALL_RPATH
  INSTALL_RPATH_USE_LINK_PATH
  INTERPROCEDURAL_OPTIMIZATION
  INTERPROCEDURAL_OPTIMIZATION_<CONFIG>
  LABELS
  LIBRARY_OUTPUT_DIRECTORY
  LIBRARY_OUTPUT_DIRECTORY_<CONFIG>
  LIBRARY_OUTPUT_NAME
  LIBRARY_OUTPUT_NAME_<CONFIG>
  LINKER_LANGUAGE
  LINK_DEPENDS
  LINK_FLAGS
  LINK_FLAGS_<CONFIG>
  LINK_INTERFACE_LIBRARIES
  LINK_INTERFACE_LIBRARIES_<CONFIG>
  LINK_INTERFACE_MULTIPLICITY
  LINK_INTERFACE_MULTIPLICITY_<CONFIG>
  LINK_SEARCH_END_STATIC
  LINK_SEARCH_START_STATIC
  LOCATION
  LOCATION_<CONFIG>
  MACOSX_BUNDLE
  MACOSX_BUNDLE_INFO_PLIST
  MACOSX_FRAMEWORK_INFO_PLIST
  MAP_IMPORTED_CONFIG_<CONFIG>
  OSX_ARCHITECTURES
  OSX_ARCHITECTURES_<CONFIG>
  OUTPUT_NAME
  OUTPUT_NAME_<CONFIG>
  POST_INSTALL_SCRIPT
  PREFIX
  PRE_INSTALL_SCRIPT
  PRIVATE_HEADER
  PROJECT_LABEL
  PUBLIC_HEADER
  RESOURCE
  RULE_LAUNCH_COMPILE
  RULE_LAUNCH_CUSTOM
  RULE_LAUNCH_LINK
  RUNTIME_OUTPUT_DIRECTORY
  RUNTIME_OUTPUT_DIRECTORY_<CONFIG>
  RUNTIME_OUTPUT_NAME
  RUNTIME_OUTPUT_NAME_<CONFIG>
  SKIP_BUILD_RPATH
  SOURCES
  SOVERSION
  STATIC_LIBRARY_FLAGS
  STATIC_LIBRARY_FLAGS_<CONFIG>
  SUFFIX
  TYPE
  VERSION
  VS_GLOBAL_<variable>
  VS_KEYWORD
  VS_SCC_LOCALPATH
  VS_SCC_PROJECTNAME
  VS_SCC_PROVIDER
  WIN32_EXECUTABLE
  XCODE_ATTRIBUTE_<an-attribute>
  # BASIS
  BASIS_INCLUDE_DIRECTORIES # include directories
  BASIS_LANGUAGE            # language of source files
  BASIS_LINK_DIRECTORIES    # link directories
  BASIS_TYPE                # BASIS type of target
  COMPILE                   # enable/disable compilation of script
  LIBEXEC                   # whether the target is an auxiliary executable
  ARCHIVE_INSTALL_DIRECTORY # installation directory of library
  LIBRARY_INSTALL_DIRECTORY # installation directory of library
  RUNTIME_INSTALL_DIRECTORY # installation directory of runtime
  LIBRARY_COMPONENT         # package component of the library component
  MFILE                     # documentation file of MEX-file
  NO_EXPORT                 # enable/disable export of target
  RUNTIME_COMPONENT         # package component of the runtime component
  TEST                      # whether the target is a test
)

# convert list of property names into regular expression
basis_list_to_regex (BASIS_PROPERTIES_ON_TARGETS_REGEX ${BASIS_PROPERTIES_ON_TARGETS})

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

## @brief Specifies that the BASIS C++ utilities shall by default not be added
#         as dependency of an executable.
set (BASIS_NO_BASIS_UTILITIES FALSE)

## @brief Enable compilation of scripts if supported by the language.
#
# In particular, Python modules are compiled if this option is enabled and
# only the compiled modules are installed.
#
# @sa basis_add_script()
option (BASIS_COMPILE_SCRIPTS FALSE)
mark_as_advanced (BASIS_COMPILE_SCRIPTS)

## @brief Script used to execute a process in CMake script mode.
#
# In order to be able to assign a timeout to the execution of a custom command
# and to add some error message parsing, this script is used by some build
# rules to actually perform the build step. See for example, the build of
# executables using the MATLAB Compiler.
set (BASIS_SCRIPT_EXECUTE_PROCESS "${BASIS_MODULE_PATH}/ExecuteProcess.cmake")

## @brief Default script configuration template.
#
# This is the default template used by basis_add_script() to configure the
# script during the build step. If the file
# @c PROJECT_CONFIG_DIR/ScriptConfig.cmake.in exists, the value of this variable
# is set to its path by basis_project_initialize().
set (BASIS_SCRIPT_CONFIG_FILE "${BASIS_MODULE_PATH}/ScriptConfig.cmake.in")

## @brief File used by default as <tt>--authors</tt> file to <tt>svn2cl</tt>.
#
# This file lists all Subversion users at SBIA and is used by default for
# the mapping of Subversion user names to real names during the generation
# of changelogs.
set (BASIS_SVN_USERS_FILE "${BASIS_MODULE_PATH}/SubversionUsers.txt")

## @brief Force installation of public header files of BASIS C++ utilities.
#
# If this variable is set to FALSE, each header file in the @c PROJECT_INCLUDE_DIR
# is scanned for an include statement which includes one of the public header
# files of the BASIS C++ utilities. If such include statement was found in
# a public header file of the project, the public header files of the BASIS
# C++ utilities are also installed as the project's public header files depend
# on them. You can set this variable to TRUE in the Settings.cmake file of your
# project to force the installation of the public header files of the
# project-specific BASIS C++ utilities.
#
# @sa basis_project_finalize()
basis_set_if_empty (BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES FALSE)

## @brief Enable/Disable configuration of public header files.
#
# By default, BASIS copies the public header files which were found in the
# @c PROJECT_INCLUDE_DIR to the corresponding include directory in the build
# tree using the same relative paths as will be used for the installation.
# Moreover, header files with the .in suffix are configured using CMake's
# configure_file() command with the <tt>\@ONLY</tt> option.
#
# As the copying of header files adds some additional complexity and results
# in the file path reported by the compiler in error messages and warnings which
# will name the corresponding copy of the header file in the build tree, causing
# potential confusion and editing of the copy by mistake, this feature was made
# optional. A project can disable it in the Settings.cmake file by setting the
# CMake variable @c BASIS_CONFIGURE_INCLUDES to FALSE.
#
# If disabled, the relative path of header files is no longer adjusted to match
# the actual installation. Therefore, in this case, the project developer
# themself must maintain the <tt>sbia/&lt:project&gt;</tt> subdirectory structure
# in the @c PROJECT_INCLUDE_DIR directory tree, where &lt;project&gt; is the
# project name in lower case only.
#
# @sa basis_configure_public_headers()
set (BASIS_CONFIGURE_INCLUDES TRUE)

# ============================================================================
# build configuration(s)
# ============================================================================

## @brief List of all available/supported build configurations.
if (UNIX)
  set (
    CMAKE_CONFIGURATION_TYPES
      "Debug"
      "Coverage"
      "MemCheck"
      "Release"
    CACHE INTERNAL "Build configurations." FORCE
  )
else ()
  set (
    CMAKE_CONFIGURATION_TYPES
      "Debug"
      "Release"
    CACHE INTERNAL "Build configurations." FORCE
  )
endif ()

## @brief List of debug configurations.
#
# Used by the target_link_libraries() CMake command, for example,
# to determine whether to link to the optimized or debug libraries.
set (DEBUG_CONFIGURATIONS "Debug")

mark_as_advanced (CMAKE_CONFIGURATION_TYPES)
mark_as_advanced (DEBUG_CONFIGURATIONS)

list (FIND CMAKE_CONFIGURATION_TYPES "${CMAKE_BUILD_TYPE}" IDX)
if (IDX EQUAL -1)
  if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "")
    message ("Invalid build type ${CMAKE_BUILD_TYPE}! Setting CMAKE_BUILD_TYPE to Release.")
  endif ()
  set (CMAKE_BUILD_TYPE "Release")
endif ()

## @brief Current build configuration for GNU Make Makefiles generator.
set (
  CMAKE_BUILD_TYPE
    "${CMAKE_BUILD_TYPE}"
  CACHE STRING
    "Current build configuration. Specify either one of ${CMAKE_CONFIGURATION_TYPES}."
  FORCE
)

# set the possible values of build type for cmake-gui
set_property (CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CMAKE_CONFIGURATION_TYPES})

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

unset (C)

# ----------------------------------------------------------------------------
# common
# ----------------------------------------------------------------------------

# common compiler flags
set (CMAKE_C_FLAGS "" CACHE INTERNAL "" FORCE)

set (
  CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}"
  CACHE STRING "Flags used by the compiler for all builds."
)

# common linker flags
set (
  CMAKE_EXE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}"
  CACHE STRING "Flags used by the linker."
)
set (
  CMAKE_MODULE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}"
  CACHE STRING "Flags used by the linker for the creation of modules."
)
set (
  CMAKE_SHARED_LINKER_FLAGS "${CMAKE_LINKER_FLAGS}"
  CACHE STRING "Flags used by the linker for the creation of dll's."
)

# ----------------------------------------------------------------------------
# Debug
# ----------------------------------------------------------------------------

# This build configuration is suitable for debugging programs.

# compiler flags
set (CMAKE_C_FLAGS_DEBUG "" CACHE INTERNAL "" FORCE)

set (
  CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}"
  CACHE STRING "Flags used by the compiler for debug builds."
)

# linker flags
set (
  CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}"
  CACHE STRING "Flags used by the linker for the debug builds."
)
set (
  CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}"
  CACHE STRING "Flags used by the linker for the debug builds."
)
set (
  CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}"
  CACHE STRING "Flags used by the linker for the debug builds."
)

# ----------------------------------------------------------------------------
# Release
# ----------------------------------------------------------------------------

# This build configuration produces binaries for deployment of the software.

# compiler flags
set (CMAKE_C_FLAGS_RELEASE "" CACHE INTERNAL "" FORCE)

set (
  CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}"
  CACHE STRING "Flags used by the compiler for release builds."
)

# linker flags
set (
  CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}"
  CACHE STRING "Flags used by the linker for the release builds."
)
set (
  CMAKE_MODULE_LINKER_FLAGS_RELEASE "${CMAKE_MODULE_LINKER_FLAGS_RELEASE}"
  CACHE STRING "Flags used by the linker for the release builds."
)
set (
  CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}"
  CACHE STRING "Flags used by the linker for the release builds."
)

# ----------------------------------------------------------------------------
# Coverage
# ----------------------------------------------------------------------------

# This build configuration enables coverage analysis.
#
# Note: The option -DNDEBUG disables assertions.
#
# TODO How can we do code coverage analysis on Windows?

if (UNIX)

# compiler flags
set (CMAKE_C_FLAGS_COVERAGE "" CACHE INTERNAL "" FORCE)

set (
  CMAKE_CXX_FLAGS_COVERAGE "-DNDEBUG -fprofile-arcs -ftest-coverage"
  CACHE STRING "Flags used by the compiler during coverage builds."
)

# linker flags
set (
  CMAKE_EXE_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage"
  CACHE STRING "Flags used by the linker during coverage builds."
)
set (
  CMAKE_MODULE_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage"
  CACHE STRING "Flags used by the linker during coverage builds."
)
set (
  CMAKE_SHARED_LINKER_FLAGS_COVERAGE "-fprofile-arcs -ftest-coverage"
  CACHE STRING "Flags used by the linker during coverage builds."
)

endif ()

# ----------------------------------------------------------------------------
# MemCheck
# ----------------------------------------------------------------------------

# This build configuration enables memory checks using, for example, valgrind.
#
# Note: The use of -O1 results in better performance while line numbers are yet
#       reasonably close to the actual line. Higher optimization should never
#       be used. The -g option is required such that line numbers can be reported.
#
# To debug detected memory leaks, consider the use of the Debug build
# configuration instead.
#
# TODO How can we do memory checks on Windows?

if (UNIX)

# compiler flags for  configuration
set (CMAKE_C_FLAGS_MEMCHECK "" CACHE INTERNAL "" FORCE)

set (
  CMAKE_CXX_FLAGS_MEMCHECK "-g -O1"
  CACHE STRING "Flags used by the compiler during memcheck builds."
)

# linker flags for Coverage configuration
set (
  CMAKE_EXE_LINKER_FLAGS_MEMCHECK ""
  CACHE STRING "Flags used by the linker during memcheck builds."
)
set (
  CMAKE_MODULE_LINKER_FLAGS_MEMCHECK ""
  CACHE STRING "Flags used by the linker during memcheck builds."
)
set (
  CMAKE_SHARED_LINKER_FLAGS_MEMCHECK ""
  CACHE STRING "Flags used by the linker during memcheck builds."
)

endif ()

# ----------------------------------------------------------------------------
# mark variables as advanced
# ----------------------------------------------------------------------------

foreach (C IN LISTS CMAKE_CONFIGURATION_TYPES)
  string (TOUPPER "${C}" U)
  mark_as_advanced (CMAKE_CXX_FLAGS_${U})
  mark_as_advanced (CMAKE_EXE_LINKER_FLAGS_${U})
  mark_as_advanced (CMAKE_MODULE_LINKER_FLAGS_${U})
  mark_as_advanced (CMAKE_SHARED_LINKER_FLAGS_${U})
endforeach ()
unset (C)
unset (U)

# ============================================================================
# common options
# ============================================================================

## @brief Request verbose messages from BASIS functions.
option (BASIS_VERBOSE "Request BASIS functions to output verbose messages." OFF)
mark_as_advanced (BASIS_VERBOSE)

## @brief Request debugging messages from BASIS functions.
option (BASIS_DEBUG "Request BASIS functions to help debugging." OFF)
mark_as_advanced (BASIS_DEBUG)

## @brief Request installation of symbolic links.
#
# @note This option is not available on Windows.
if (UNIX)
  option (INSTALL_LINKS "Request installation of (symbolic) links." ON)
else ()
  set (INSTALL_LINKS OFF)
endif ()


## @}
# end of Doxygen group
