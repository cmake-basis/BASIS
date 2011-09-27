##############################################################################
# @file  UtilitiesTools.cmake
# @brief CMake functions used to configure auxiliary source files.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

## @addtogroup CMakeUtilities
#  @{


# ============================================================================
# auxiliary sources
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
  if (BASIS_VERBOSE)
    message (STATUS "Configuring auxiliary sources...")
  endif ()

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

  set (EXECUTABLE_TARGET_INFO "\@EXECUTABLE_TARGET_INFO\@")

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
      "ExecutableTargetInfo.h"
      "ExecutableTargetInfo.cc"
      "stdaux.h"
      "stdaux.cc"
      "basis.h"
  )

  foreach (SOURCE ${SOURCES_NAMES})
    set (TEMPLATE "${PROJECT_CODE_DIR}/${SOURCE}.in")
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

  if (BASIS_VERBOSE)
    message (STATUS "Configuring auxiliary sources... - done")
  endif ()
endfunction ()

##############################################################################
# @brief Configure auxiliary modules for scripting languages.

function (basis_configure_auxiliary_modules)

  if (BASIS_VERBOSE)
    message (STATUS "Configuring auxiliary modules...")
  endif ()

  # --------------------------------------------------------------------------
  # Python
  if (BASIS_PROJECT_USES_PYTHON)
    # TODO
  endif ()

  # --------------------------------------------------------------------------
  # Perl
  if (BASIS_PROJECT_USES_PERL)
    foreach (MODULE StdAux Basis)
      basis_add_script ("${BASIS_PERL_TEMPLATES_DIR}/${MODULE}.pm" MODULE)
      basis_script_target_name (TARGET_NAME "${BASIS_PERL_TEMPLATES_DIR}/${MODULE}.pm")
      basis_set_target_properties (${TARGET_NAME} PROPERTIES BINARY_DIRECTORY "${BINARY_CODE_DIR}")
    endforeach ()
  endif ()

  # --------------------------------------------------------------------------
  # BASH
  if (BASIS_PROJECT_USES_BASH)
    foreach (MODULE StdAux Basis)
      basis_add_script ("${BASIS_BASH_TEMPLATES_DIR}/${MODULE}.sh" MODULE)
      basis_script_target_name (TARGET_NAME "${BASIS_BASH_TEMPLATES_DIR}/${MODULE}.sh")
      basis_set_target_properties (${TARGET_NAME} PROPERTIES BINARY_DIRECTORY "${BINARY_CODE_DIR}")
    endforeach ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring auxiliary modules... - done")
  endif ()
endfunction ()

##############################################################################
# @brief Configure ExecutibleTargetInfo modules.
#
# This function generates the initialization code of the ExecutableTargetInfo
# module for different supported programming languages. In case of C++, the
# source file has been configured and copied to the binary tree in a first
# configuration pass such that it could be used in basis_add_*() commands
# which check the existence of the arguments immediately.
# As the generation of the initialization code requires a complete list of
# build targets (cached in @c BASIS_TARGETS), this function has to be called
# after all targets have been added and finalized (in case of custom targets).
#
# @returns Nothing.

function (basis_configure_ExecutableTargetInfo)
  # --------------------------------------------------------------------------
  # ExecutableTargetInfo not used?

  set (CXX    ${BASIS_PROJECT_USES_CXX})
  set (PYTHON ${BASIS_PROJECT_USES_PYTHON})
  set (PERL   ${BASIS_PROJECT_USES_PERL})
  set (BASH   ${BASIS_PROJECT_USES_BASH})

  if (NOT CXX AND NOT PYTHON AND NOT PERL AND NOT BASH)
    return ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring ExecutableTargetInfo...")
  endif ()

  # --------------------------------------------------------------------------
  # generate source code

  set (CC)   # C++    - build tree and install tree version, constructor block
  set (PY_B) # Python - build tree version
  set (PY_I) # Python - install tree version
  set (PL_B) # Perl   - build tree version, hash entries
  set (PL_I) # Perl   - install tree version, hash entries
  set (SH_B) # BASH   - build tree version
  set (SH_I) # BASH   - install tree version
  set (SH_A) # BASH   - aliases
  set (SH_S) # BASH   - short aliases

  if (CXX)
    set (CC            "// the following code was automatically generated by the BASIS")
    set (CC "${CC}\n    // CMake function basis_configure_ExecutableTargetInfo()")
  endif ()

  foreach (TARGET_UID ${BASIS_TARGETS})
    basis_target_type   (TYPE ${TARGET_UID})
    get_target_property (TEST ${TARGET_UID} "TEST")
 
    if (TYPE MATCHES "EXECUTABLE" AND NOT TEST)
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # get target properties
      basis_get_target_location (BUILD_LOCATION   "${TARGET_UID}" ABSOLUTE)
      basis_get_target_location (INSTALL_LOCATION "${TARGET_UID}" POST_INSTALL_RELATIVE)

      if (NOT BUILD_LOCATION)
        message (WARNING "Failed to determine build location of ${TARGET_UID}")
      endif ()
      if (NOT INSTALL_LOCATION)
        message (WARNING "Failed to determine installation location of ${TARGET_UID}")
      endif ()

      if (BUILD_LOCATION AND INSTALL_LOCATION)

        # installation directory relative to installed modules
        file (
          RELATIVE_PATH INSTALL_LOCATION_REL2MOD
            "${INSTALL_PREFIX}/${INSTALL_LIBRARY_DIR}"
            "${INSTALL_PREFIX}/${INSTALL_LOCATION}"
        )
        if (NOT INSTALL_DIR)
          set (INSTALL_DIR ".")
        endif ()

        string (REGEX REPLACE "${BASIS_NAMESPACE_SEPARATOR}" "::" ALIAS "${TARGET_UID}")

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # C++

        if (CXX)
          get_filename_component (EXEC_NAME   "${BUILD_LOCATION}"   NAME)
          get_filename_component (BUILD_DIR   "${BUILD_LOCATION}"   PATH)
          get_filename_component (INSTALL_DIR "${INSTALL_LOCATION}" PATH)

          set (CC "${CC}\n")
          set (CC "${CC}\n    // ${TARGET_UID}")
          set (CC "${CC}\n    _execNames   [\"${ALIAS}\"] = \"${EXEC_NAME}\";")
          set (CC "${CC}\n    _buildDirs   [\"${ALIAS}\"] = \"${BUILD_DIR}\";")
          set (CC "${CC}\n    _installDirs [\"${ALIAS}\"] = \"${INSTALL_LOCATION}\";")
        endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Python

        if (PYTHON)
          # TODO
        endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Perl

        if (PERL)
          if (PL_B)
            set (PL_B "${PL_B},\n")
          endif ()
          set (PL_B "${PL_B}    '${ALIAS}' => '${BUILD_LOCATION}'")
          if (PL_I)
            set (PL_I "${PL_I},\n")
          endif ()
          set (PL_I "${PL_I}    '${ALIAS}' => '${INSTALL_LOCATION_REL2MOD}'")
        endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # BASH

        if (BASH)
          # hash entry
          set (SH_B "${SH_B}\n    _executabletargetinfo_add '${ALIAS}' LOCATION '${BUILD_LOCATION}'")
          set (SH_I "${SH_I}\n    _executabletargetinfo_add '${ALIAS}' LOCATION '${INSTALL_LOCATION_REL2MOD}'")

          # alias
          set (SH_A "${SH_A}\nalias '${ALIAS}'=$(get_executable_path '${ALIAS}')")

          # short alias (if target belongs to this project)
          string (REGEX REPLACE "::.*" "" NS "${ALIAS}")
          if ("${NS}" STREQUAL "${PROJECT_NAME_LOWER}")
            basis_target_name (TARGET_NAME "${TARGET_UID}")
            set (SH_S "${SH_S}\nalias '${TARGET_NAME}'='${ALIAS}'")
          endif ()
        endif ()
      endif ()

    endif ()
  endforeach ()

  # --------------------------------------------------------------------------
  # remove unnecessary leading newlines

  string (STRIP "${CC}"   CC)
  string (STRIP "${PY_B}" PY_B)
  string (STRIP "${PY_I}" PY_I)
  string (STRIP "${PL_B}" PL_B)
  string (STRIP "${PL_I}" PL_I)
  string (STRIP "${SH_B}" SH_B)
  string (STRIP "${SH_I}" SH_I)
  string (STRIP "${SH_A}" SH_A)
  string (STRIP "${SH_S}" SH_S)

  # --------------------------------------------------------------------------
  # configure source files

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # C++

  if (CXX)
    # configure source file
    set (EXECUTABLE_TARGET_INFO "${CC}")
    configure_file ("${BINARY_CODE_DIR}/ExecutableTargetInfo.cc" "${BINARY_CODE_DIR}/ExecutableTargetInfo.cc" @ONLY)
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Python

  if (PYTHON)
    # TODO
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Perl

  if (PERL)
    # script configuration
    set (CONFIG "@BASIS_SCRIPT_CONFIG@\n\n")
    set (CONFIG "${CONFIG}if (BUILD_INSTALL_SCRIPT)\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${PL_I}\")\n")
    set (CONFIG "${CONFIG}else ()\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${PL_B}\")\n")
    set (CONFIG "${CONFIG}endif ()\n")

    # add module
    basis_add_script ("${BASIS_PERL_TEMPLATES_DIR}/ExecutableTargetInfo.pm" MODULE CONFIG "${CONFIG}")
    basis_script_target_name (TARGET_NAME "${BASIS_PERL_TEMPLATES_DIR}/ExecutableTargetInfo.pm")
    basis_set_target_properties (${TARGET_NAME} PROPERTIES BINARY_DIRECTORY "${BINARY_CODE_DIR}")
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # BASH

  if (BASH)
    # script configuration
    set (CONFIG "@BASIS_SCRIPT_CONFIG@\n\n")
    set (CONFIG "${CONFIG}if (BUILD_INSTALL_SCRIPT)\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${SH_I}\")\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_ALIASES \"${SH_A}\n\n# define short aliases for this project's targets\n${SH_S}\")\n")
    set (CONFIG "${CONFIG}else ()\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${SH_B}\")\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_ALIASES \"${SH_A}\n\n# define short aliases for this project's targets\n${SH_S}\")\n")
    set (CONFIG "${CONFIG}endif ()\n")

    # add module
    basis_add_script ("${BASIS_BASH_TEMPLATES_DIR}/ExecutableTargetInfo.sh" MODULE CONFIG "${CONFIG}")
    basis_script_target_name (TARGET_NAME "${BASIS_BASH_TEMPLATES_DIR}/ExecutableTargetInfo.sh")
    basis_set_target_properties (${TARGET_NAME} PROPERTIES BINARY_DIRECTORY "${BINARY_CODE_DIR}")
  endif ()

  # --------------------------------------------------------------------------
  # done
  if (BASIS_VERBOSE)
    message (STATUS "Configuring ExecutableTargetInfo... - done")
  endif ()
endfunction ()


## @}
