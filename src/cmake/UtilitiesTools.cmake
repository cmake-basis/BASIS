##############################################################################
# @file  UtilitiesTools.cmake
# @brief CMake functions used to configure auxiliary source files.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeUtilities
##############################################################################

## @addtogroup CMakeUtilities
#  @{

# ============================================================================
# C++
# ============================================================================

##############################################################################
# @brief Configure auxiliary C++ source files.
#
# This function configures the following default auxiliary source files
# which can be used by the projects which are making use of BASIS.
#
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b config.h</td>
#     <td>This file is intended to be included by all source files.
#         Hence, other projects will indirectly include this file when
#         they use a library of this project. Therefore, it is
#         important to avoid potential name conflicts.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b config.cc</td>
#     <td>Definition of constants declared in config.h file.
#         In particular, the paths of the installation directories
#         relative to the executables are defined by this file.
#         These constants are used by the auxiliary functions
#         implemented in stdaux.h.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b stdaux.h</td>
#     <td>Auxiliary functions such as functions to get absolute path
#         to the subdirectories of the installation.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b stdaux.cc</td>
#     <td>Definition of auxiliary functions declared in stdaux.h.
#         This source file in particular contains the constructor
#         code which is configured during the finalization of the
#         project's build configuration which maps the build target
#         names to executable file paths.</td>
#   </tr>
# </table>
#
# @note If there exists a *.in file of the corresponding source file in the
#       PROJECT_CONFIG_DIR, it will be used as template. Otherwise, the
#       template file of BASIS is used.
#
# @param [out] SOURCES        Configured auxiliary source files.
# @param [out] HEADERS        Configured auxiliary header files.
# @param [out] PUBLIC_HEADERS Auxiliary headers that should be installed.
#
# @returns Sets the variables specified by the @c [out] parameters.

function (basis_configure_auxiliary_sources SOURCES HEADERS PUBLIC_HEADERS)
  set (SOURCES_OUT        "")
  set (HEADERS_OUT        "")
  set (PUBLIC_HEADERS_OUT "")

  # set variables to be substituted within auxiliary source files
  set (BUILD_ROOT_PATH_CONFIG    "${CMAKE_BINARY_DIR}")
  set (RUNTIME_BUILD_PATH_CONFIG "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
  set (LIBEXEC_BUILD_PATH_CONFIG "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
  set (LIBRARY_BUILD_PATH_CONFIG "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
  set (DATA_BUILD_PATH_CONFIG    "${PROJECT_DATA_DIR}")

  file (RELATIVE_PATH RUNTIME_PATH_PREFIX_CONFIG "${INSTALL_PREFIX}/${INSTALL_RUNTIME_DIR}" "${INSTALL_PREFIX}")
  file (RELATIVE_PATH LIBEXEC_PATH_PREFIX_CONFIG "${INSTALL_PREFIX}/${INSTALL_LIBEXEC_DIR}" "${INSTALL_PREFIX}")

  string (REGEX REPLACE "/$|\\$" "" RUNTIME_PATH_PREFIX_CONFIG "${RUNTIME_PATH_PREFIX_CONFIG}")
  string (REGEX REPLACE "/$|\\$" "" LIBEXEC_PATH_PREFIX_CONFIG "${LIBEXEC_PATH_PREFIX_CONFIG}")

  set (RUNTIME_PATH_CONFIG "${INSTALL_RUNTIME_DIR}")
  set (LIBEXEC_PATH_CONFIG "${INSTALL_LIBEXEC_DIR}")
  set (LIBRARY_PATH_CONFIG "${INSTALL_LIBRARY_DIR}")
  set (DATA_PATH_CONFIG    "${INSTALL_SHARE_DIR}")

  if (IS_SUBPROJECT)
    set (IS_SUBPROJECT_CONFIG "true")
  else ()
    set (IS_SUBPROJECT_CONFIG "false")
  endif ()

  set (EXECUTABLE_TARGET_INFO_CONFIG "\@EXECUTABLE_TARGET_INFO_CONFIG\@")

  # configure public auxiliary header files
  set (
    SOURCES_NAMES
      "config.h"
  )

  foreach (SOURCE ${SOURCES_NAMES})
    set (TEMPLATE "${PROJECT_INCLUDE_DIR}/sbia/${PROJECT_NAME_LOWER}/${SOURCE}.in")
    if (NOT EXISTS "${TEMPLATE}")
      set (TEMPLATE "${BASIS_CXX_TEMPLATES_DIR}/${SOURCE}.in")
    endif ()
    set  (SOURCE_OUT "${BINARY_INCLUDE_DIR}/sbia/${PROJECT_NAME_LOWER}/${SOURCE}")
    configure_file ("${TEMPLATE}" "${SOURCE_OUT}" @ONLY)
    list (APPEND PUBLIC_HEADERS_OUT "${SOURCE_OUT}")
  endforeach ()

  list (APPEND HEADERS ${PUBLIC_HEADERS_OUT})

  # configure private auxiliary source files
  set (
    SOURCES_NAMES
      "config.cc"
      "stdaux.h"
      "stdaux.cc"
  )

  foreach (SOURCE ${SOURCES_NAMES})
    set (TEMPLATE "${PROJECT_CODE_DIR}/${SOURCE}")
    if (NOT EXISTS "${TEMPLATE}")
      set (TEMPLATE "${BASIS_CXX_TEMPLATES_DIR}/${SOURCE}.in")
    endif ()
    set  (SOURCE_OUT "${BINARY_CODE_DIR}/${SOURCE}")
    configure_file ("${TEMPLATE}" "${SOURCE_OUT}" @ONLY)
    if (SOURCE MATCHES ".h$")
      list (APPEND HEADERS_OUT "${SOURCE_OUT}")
    else ()
      list (APPEND SOURCES_OUT "${SOURCE_OUT}")
    endif ()
  endforeach ()

  # return
  set (${SOURCES}        "${SOURCES_OUT}"        PARENT_SCOPE)
  set (${HEADERS}        "${HEADERS_OUT}"        PARENT_SCOPE)
  set (${PUBLIC_HEADERS} "${PUBLIC_HEADERS_OUT}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Configure constructor definition of ExecutableTargetInfo class.
#
# The previously configured source file stdaux.cc (such that it can be used
# within add_executable() statements), is configured a second time by this
# function in order to add the missing implementation of the ExecutableTargetInfo
# constructor. Therefore, the BASIS_TARGETS variable and the target properties
# of these targets are used. Note that only during the finalization of the
# build configuration all build targets are known. Hence, this function is
# called by the finalization routine.
#
# @sa ExecutableTargetInfo
#
# @returns Configures the file @p BINARY_CODE_DIR/stdaux.cc in-place if it exists.

function (basis_configure_ExecutableTargetInfo)
  set (SOURCE_FILE "${BINARY_CODE_DIR}/stdaux.cc")

  if (NOT EXISTS "${SOURCE_FILE}")
    return ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring constructor of ExecutableTargetInfo...")
  endif ()

  # generate source code
  set (C)
  set (N 0)
  foreach (TARGET_UID ${BASIS_TARGETS})
    get_target_property (BASIS_TYPE "${TARGET_UID}" "BASIS_TYPE")
 
    if (BASIS_TYPE MATCHES "EXEC|SCRIPT" AND NOT BASIS_TYPE MATCHES "NOEXEC")
      basis_get_target_location (LOCATION "${TARGET_UID}")
      get_filename_component (BUILD_DIR "${LOCATION}" PATH)
      get_filename_component (EXEC_NAME "${LOCATION}" NAME)

      if (BASIS_TYPE MATCHES "LIBEXEC")
        set (INSTALL_DIR "${INSTALL_LIBEXEC_DIR}")
      else ()
        set (INSTALL_DIR "${INSTALL_RUNTIME_DIR}")
      endif ()

      set (C "${C}\n")
      set (C "${C}    // ${TARGET_UID}\n")
      set (C "${C}    _execNames   [\"${TARGET_UID}\"] = \"${EXEC_NAME}\";\n")
      set (C "${C}    _buildDirs   [\"${TARGET_UID}\"] = \"${BUILD_DIR}\";\n")
      set (C "${C}    _installDirs [\"${TARGET_UID}\"] = \"${INSTALL_DIR}\";\n")

      math (EXPR N "${N} + 1")
    endif ()
  endforeach ()

  # configure source file
  set (EXECUTABLE_TARGET_INFO_CONFIG "${C}")

  configure_file ("${SOURCE_FILE}" "${SOURCE_FILE}" @ONLY)

  if (BASIS_VERBOSE)
    message (STATUS "Added ${N} entries to ExecutableTargetInfo maps")
    message (STATUS "Configuring constructor of ExecutableTargetInfo... - done")
  endif ()
endfunction ()

# ============================================================================
# BASH
# ============================================================================

##############################################################################
# @brief Add stdaux.sh BASH module.
#
# This function adds the stdaux.sh BASH module. This module in particular
# defines aliases for executable build targets. Hence, it has to be called
# during the finalization of the build configuration.
#
# @sa basis_project_finalize()

function (basis_add_stdaux_bash_script)
  # generate definition of init_executable_aliases()
  set (C)
  foreach (TARGET_UID ${BASIS_TARGETS})
    get_target_property (BASIS_TYPE "${TARGET_UID}" "BASIS_TYPE")
 
    if (BASIS_TYPE MATCHES "EXEC|SCRIPT" AND NOT BASIS_TYPE MATCHES "NOEXEC")
      basis_get_target_location (LOCATION "${TARGET_UID}")
      get_filename_component (BUILD_DIR "${LOCATION}" PATH)
      get_filename_component (EXEC_NAME "${LOCATION}" NAME)
 
      if (BASIS_TYPE MATCHES "LIBEXEC")
        set (EXEC_DIR "\${LIBEXEC_DIR}")
      else ()
        set (EXEC_DIR "\${RUNTIME_DIR}")
      endif ()

      string (REGEX REPLACE "${BASIS_NAMESPACE_SEPARATOR}" "::" ALIAS "${TARGET_UID}")

      if (C)
        set (C "${C}\n")
      endif ()
      set (C "${C}alias '${ALIAS}'=$(to_absolute_path \\\"${EXEC_DIR}/${EXEC_NAME}\\\" \$stdaux_dir)")
    endif ()
  endforeach ()

  # script configuration
  set (CONFIG "@BASIS_SCRIPT_CONFIG@\n\n")
  set (CONFIG "${CONFIG}set (EXECUTABLE_ALIASES \"${C}\")\n")

  # add BASH modules
  basis_add_script (
    "${BASIS_BASH_TEMPLATES_DIR}/stdaux.sh.in"
    MODULE
      BINARY_DIRECTORY "${BINARY_CODE_DIR}"
      CONFIG "${CONFIG}"
  )
endfunction ()

## @}
