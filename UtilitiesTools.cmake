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
# Python utilities
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Include BASIS utilities for Python.
#
# The substituted Python code appends the root directory of the build or
# installed Python modules to the search path and then imports the 'basis'
# module of this project. Note that every BASIS project has its own 'basis'
# module, which belong to different packages, however.
#
# Example:
# @code
# #! /usr/bin/env python
# @BASIS_PYTHON_UTILITIES@
# ...
# @endcode
#
# @ingroup PythonUtilities

set (BASIS_PYTHON_UTILITIES "
def _basis_init_sys_path():
    import os
    import sys
    module_dir  = os.path.dirname(os.path.realpath(__file__))
    sitelib_dir = os.path.normpath(os.path.join(module_dir, '%PYTHON_LIBRARY_DIR%'))
    if sitelib_dir not in sys.path:
        sys.path.append(sitelib_dir)
    sitelib_dir = os.path.normpath(os.path.join(module_dir, '%BASIS_PYTHON_LIBRARY_DIR%'))
    if sitelib_dir not in sys.path:
        sys.path.append(sitelib_dir)

_basis_init_sys_path()
from sbia.%PROJECT_NAME_LOWER% import basis
"
)

# ============================================================================
# Perl utilities
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Include BASIS utilities for Perl.
#
# Example:
# @code
# #! /usr/bin/env perl
# @BASIS_PERL_UTILITIES@
# ...
# @endcode
#
# @ingroup PerlUtilities

set (BASIS_PERL_UTILITIES "
use File::Basename;
use lib dirname (__FILE__) . '/%BASIS_PERL_LIBRARY_DIR%';
use lib dirname (__FILE__) . '/%PERL_LIBRARY_DIR%';
use lib dirname (__FILE__);

package Basis;
use SBIA::%PROJECT_NAME%::Basis qw(:everything);
package main;
"
)

# ============================================================================
# BASH utilities
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Absolute path of current BASH file.
#
# @note Does not resolve symbolic links.
#
# Example:
# @code
# readonly __MYMODULE=@BASIS_BASH___FILE__@
# @endcode
#
# @ingroup BashUtilities
set (BASIS_BASH___FILE__ "$(cd -P -- \"$(dirname -- \"\${BASH_SOURCE}\")\" && pwd -P)/$(basename -- \"$BASH_SOURCE\")")

# ----------------------------------------------------------------------------
## @brief Absolute path of directory of current BASH file.
#
# @note Does not resolve symbolic links.
#
# Example:
# @code
# readonly __MYMODULE_dir=@BASIS_BASH___DIR__@
# @endcode
#
# @ingroup BashUtilities
set (BASIS_BASH___DIR__ "$(cd -P -- \"$(dirname -- \"\${BASH_SOURCE}\")\" && pwd -P)")

# ----------------------------------------------------------------------------
## @brief Definition of realpath() function.
#
# Example:
# @code
# #! /usr/bin/env bash
# @BASIS_BASH_FUNCTION_realpath@
# exec_dir=$(realpath $0)
# @endcode
#
# @sa http://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
#
# @ingroup BashUtilities
set (BASIS_BASH_FUNCTION_realpath "
# ----------------------------------------------------------------------------
## @brief Get real path of given file or directory.
#
# @note This function was substituted by BASIS either for the string
#       \\\@BASIS_BASH_UTILITIES\\\@ or \\\@BASIS_BASH_realpath\\\@.
#
# Example:
# @code
# exec_dir=`realpath $0`
# @endcode
#
# @sa http://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
#
# @param [in] path File or directory path.
#
# @returns Canonical path.
function realpath
{
    local path=$1

    local linkdir=''
    local symlink=''

    while [ -h \${path} ]; do
        # 1) change to directory of the symbolic link
        # 2) change to directory where the symbolic link points to
        # 3) get the current working directory
        # 4) append the basename
        linkdir=$(dirname -- \"\${path}\")
        symlink=$(readlink \${path})
        path=$(cd \"\${linkdir}\" && cd $(dirname -- \"\${symlink}\") && pwd)/$(basename -- \"\${symlink}\")
    done

    echo -n \"$(cd -P -- \"$(dirname \"\${path}\")\" && pwd -P)/$(basename -- \"\${path}\")\"
}
"
)

# ----------------------------------------------------------------------------
## @brief Include BASIS utilities for BASH.
#
# Example:
# @code
# #! /usr/bin/env bash
# @BASIS_BASH_UTILITIES@
# get_executable_directory exec_dir
# get_executable_name      exec_name
#
# echo "The executable ${exec_name} is located in ${exec_dir}."
# @endcode
#
# @ingroup BashUtilities
set (BASIS_BASH_UTILITIES "
# constants used by the shflags.sh module
HELP_COMMAND='%NAME% (%PROJECT_NAME%)'
HELP_CONTACT='SBIA Group <sbia-software at uphs.upenn.edu>'
HELP_VERSION='%PROJECT_VERSION_AND_REVISION%'
HELP_COPYRIGHT='Copyright (c) University of Pennsylvania. All rights reserved.
See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.'

${BASIS_BASH_FUNCTION_realpath}
readonly _%NAMESPACE_UPPER%_DIR=\"$(dirname -- \"$(realpath \"${BASIS_BASH___FILE__}\")\")\"
source \"\${_%NAMESPACE_UPPER%_DIR}/%LIBRARY_DIR%/basis.sh\" || exit 1
"
)

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
#     @tp @b basis.h @endtp
#     <td>Main include file which includes all the header files of the
#         BASIS utilities including both, non-project specific utilities
#         which are installed as part of BASIS, and project specific
#         utilities configured by this function.</td>
#   </tr>
#   <tr>
#     @tp @b config.h @endtp
#     <td>This file is intended to be included by all source files.
#         Hence, other projects will indirectly include this file when
#         they use a library of this project. Therefore, it is
#         important to avoid potential name conflicts.</td>
#   </tr>
#   <tr>
#     @tp @b config.cxx @endtp
#     <td>Definition of constants declared in config.h file.
#         In particular, the paths of the installation directories
#         relative to the executables are defined by this file.
#         These constants are used by the auxiliary functions
#         implemented in stdaux.h.</td>
#   </tr>
#   <tr>
#     @tp @b stdaux.h @endtp
#     <td>Declares auxiliary functions such as functions to get absolute path
#         to the subdirectories of the installation.</td>
#   </tr>
#   <tr>
#     @tp @b stdaux.cxx @endtp
#     <td>Definition of auxiliary functions declared in stdaux.h.</td>
#   </tr>
#   <tr>
#     @tp @b ExecutableTargetInfo.h @endtp
#     <td>Declares ExecutableTargetInfo class which can be used at runtime
#         to obtain information about an executable using the name of the
#         corresponding BASIS/CMake build target.</td>
#   </tr>
#   <tr>
#     @tp @b ExecutableTargetInfo.cxx @endtp
#     <td>Definition of ExecutableTargetInfo class. The constructor of
#         this singleton class is created during the configuration step of
#         CMake by the function basis_configure_ExecutableTargetInfo().</td>
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
  set (RUNTIME_BUILD_PATH_CONFIG "${BINARY_RUNTIME_DIR}")
  set (LIBEXEC_BUILD_PATH_CONFIG "${BINARY_LIBEXEC_DIR}")
  set (LIBRARY_BUILD_PATH_CONFIG "${BINARY_LIBRARY_DIR}")
  set (DATA_BUILD_PATH_CONFIG    "${PROJECT_DATA_DIR}")

  file (RELATIVE_PATH RUNTIME_PATH_PREFIX_CONFIG "${INSTALL_PREFIX}/${INSTALL_RUNTIME_DIR}" "${INSTALL_PREFIX}")
  file (RELATIVE_PATH LIBEXEC_PATH_PREFIX_CONFIG "${INSTALL_PREFIX}/${INSTALL_LIBEXEC_DIR}" "${INSTALL_PREFIX}")

  string (REGEX REPLACE "/$|\\$" "" RUNTIME_PATH_PREFIX_CONFIG "${RUNTIME_PATH_PREFIX_CONFIG}")
  string (REGEX REPLACE "/$|\\$" "" LIBEXEC_PATH_PREFIX_CONFIG "${LIBEXEC_PATH_PREFIX_CONFIG}")

  set (RUNTIME_PATH_CONFIG "${INSTALL_RUNTIME_DIR}")
  set (LIBEXEC_PATH_CONFIG "${INSTALL_LIBEXEC_DIR}")
  set (LIBRARY_PATH_CONFIG "${INSTALL_LIBRARY_DIR}")
  set (DATA_PATH_CONFIG    "${INSTALL_DATA_DIR}")

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
      "basis.h"
      "config.cxx"
      "stdaux.h"
      "stdaux.cxx"
      "ExecutableTargetInfo.h"
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

  # ExecutableTargetInfo.cxx
  #
  # Create here only if non-existent as otherwise a build target
  # using it cannot be added because CMake checks for the existence
  # of the source files at this moment. The actual configuration of
  # the ExecutableTargetInfo.cxx source file is done by
  # basis_configure_ExecutableTargetInfo().
  set (SOURCE_OUT "${BINARY_CODE_DIR}/ExecutableTargetInfo.cxx")
  if (NOT EXISTS "${SOURCE_OUT}")
    file (WRITE "${SOURCE_OUT}"
      "#error Should have been replaced by the CMake function "
      "basis_configure_ExecutableTargetInfo()"
    )
  endif ()
  list (APPEND SOURCES_OUT "${SOURCE_OUT}")

  # return
  set (${SOURCES}        "${SOURCES_OUT}"        PARENT_SCOPE)
  set (${HEADERS}        "${HEADERS_OUT}"        PARENT_SCOPE)
  set (${PUBLIC_HEADERS} "${PUBLIC_HEADERS_OUT}" PARENT_SCOPE)

  if (BASIS_VERBOSE)
    message (STATUS "Configuring auxiliary sources... - done")
  endif ()
endfunction ()

##############################################################################
# @brief Add include directories of auxiliary sources to search path.
#
# @param [in] SOURCES_LIST Name of list of source files.
# @param [in] HEADERS_LIST Name of list of header files.

function (basis_use_auxiliary_sources SOURCES_LIST HEADERS_LIST)
  set (INCLUDE_DIRS)
  foreach (H IN LISTS ${HEADERS_LIST})
    get_filename_component (D "${H}" PATH)
    list (APPEND INCLUDE_DIRS "${D}")
  endforeach ()
  if (INCLUDE_DIRS)
    list (REMOVE_DUPLICATES INCLUDE_DIRS)
  endif ()
  if (INCLUDE_DIRS)
    basis_include_directories (BEFORE ${INCLUDE_DIRS})
  endif ()
  if (${HEADERS_LIST})
    source_group ("Default" FILES ${${HEADERS_LIST}})
  endif ()
  if (${SOURCES_LIST})
    source_group ("Default" FILES ${${SOURCES_LIST}})
  endif ()
endfunction ()

##############################################################################
# @brief Configure auxiliary modules for scripting languages.

function (basis_configure_auxiliary_modules)
  basis_get_project_property (PROJECT_USES_PYTHON_UTILITIES)
  basis_get_project_property (PROJECT_USES_PERL_UTILITIES)
  basis_get_project_property (PROJECT_USES_BASH_UTILITIES)

  if (NOT PROJECT_USES_PYTHON_UTILITIES AND
      NOT PROJECT_USES_PERL_UTILITIES   AND
      NOT PROJECT_USES_BASH_UTILITIES)
    return ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring auxiliary modules...")
  endif ()

  # --------------------------------------------------------------------------
  # Python
  if (PROJECT_USES_PYTHON_UTILITIES)
    foreach (MODULE basis stdaux)
      basis_get_source_target_name (TARGET_NAME "${MODULE}.py" NAME)
      basis_add_library (
        ${TARGET_NAME} "${BASIS_PYTHON_TEMPLATES_DIR}/${MODULE}.py"
        MODULE
          BINARY_DIRECTORY "${BINARY_CODE_DIR}"
      )
    endforeach ()
  endif ()

  # --------------------------------------------------------------------------
  # Perl
  if (PROJECT_USES_PERL_UTILITIES)
    foreach (MODULE Basis StdAux)
      basis_get_source_target_name (TARGET_NAME "${MODULE}.pm" NAME)
      basis_add_library (
        ${TARGET_NAME} "${BASIS_PERL_TEMPLATES_DIR}/${MODULE}.pm"
        MODULE
          BINARY_DIRECTORY "${BINARY_CODE_DIR}"
      )
    endforeach ()
  endif ()

  # --------------------------------------------------------------------------
  # BASH
  if (PROJECT_USES_BASH_UTILITIES)
    foreach (MODULE basis stdaux)
      basis_get_source_target_name (TARGET_NAME "${MODULE}.sh" NAME)
      basis_add_library (
        ${TARGET_NAME} "${BASIS_BASH_TEMPLATES_DIR}/${MODULE}.sh"
        MODULE
          BINARY_DIRECTORY "${BINARY_CODE_DIR}"
      )
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

  set (PROJECT_USES_CXX_UTILITIES TRUE)
  basis_get_project_property (PROJECT_USES_PYTHON_UTILITIES)
  basis_get_project_property (PROJECT_USES_PERL_UTILITIES)
  basis_get_project_property (PROJECT_USES_BASH_UTILITIES)

  if (NOT PROJECT_USES_CXX_UTILITIES    AND
      NOT PROJECT_USES_PYTHON_UTILITIES AND
      NOT PROJECT_USES_PERL_UTILITIES   AND
      NOT PROJECT_USES_BASH_UTILITIES)
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
  set (SH_A) # BASH   - aliases
  set (SH_B) # BASH   - build tree version
  set (SH_I) # BASH   - install tree version

  if (PROJECT_USES_CXX_UTILITIES)
    set (CC            "// the following code was automatically generated by the BASIS")
    set (CC "${CC}\n    // CMake function basis_configure_ExecutableTargetInfo()")
  endif ()

  if (PROJECT_USES_PYTHON_UTILITIES)
    set (PY_B "${PY_B}    _locations = {\n")
    set (PY_I "${PY_I}    _locations = {\n")
  endif ()

  basis_get_project_property (TARGETS)
  foreach (TARGET_UID IN LISTS TARGETS)
    if (NOT TARGET_UID)
      message (WARNING "There is an empty entry in the TARGETS project property!")
    endif ()

    basis_target_type   (TYPE ${TARGET_UID})
    get_target_property (TEST ${TARGET_UID} "TEST")
 
    if (TYPE MATCHES "EXECUTABLE" AND NOT TEST)
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # get target properties
      basis_get_target_location (BUILD_LOCATION   "${TARGET_UID}" ABSOLUTE)
      basis_get_target_location (INSTALL_LOCATION "${TARGET_UID}" POST_INSTALL)

      if (NOT BUILD_LOCATION)
        message (WARNING "Failed to determine build location of ${TARGET_UID}")
      endif ()
      if (NOT INSTALL_LOCATION)
        message (WARNING "Failed to determine installation location of ${TARGET_UID}")
      endif ()

      if (BUILD_LOCATION AND INSTALL_LOCATION)

        foreach (L LIBRARY PYTHON_LIBRARY PERL_LIBRARY)
          file (
            RELATIVE_PATH INSTALL_LOCATION_REL2${L}
              "${INSTALL_PREFIX}/${INSTALL_${L}_DIR}"
              "${INSTALL_LOCATION}"
          )
          if (NOT INSTALL_LOCATION_REL2${L})
            set (INSTALL_LOCATION_REL2${L} ".")
          endif ()
        endforeach ()

        set (ALIAS "${TARGET_UID}")
        if (NOT ALIAS MATCHES "${BASIS_NAMESPACE_SEPARATOR_REGEX}")
          set (ALIAS "${BASIS_NAMESPACE}${BASIS_NAMESPACE_SEPARATOR}${ALIAS}")
        endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # C++

        if (PROJECT_USES_CXX_UTILITIES)
          get_filename_component (EXEC_NAME   "${BUILD_LOCATION}"   NAME)
          get_filename_component (BUILD_DIR   "${BUILD_LOCATION}"   PATH)
          get_filename_component (INSTALL_DIR "${INSTALL_LOCATION}" PATH)

          set (CC "${CC}\n")
          set (CC "${CC}\n    // ${TARGET_UID}")
          set (CC "${CC}\n    exec_names_  [\"${ALIAS}\"] = \"${EXEC_NAME}\";")
          set (CC "${CC}\n    build_dirs_  [\"${ALIAS}\"] = \"${BUILD_DIR}\";")
          set (CC "${CC}\n    install_dirs_[\"${ALIAS}\"] = \"${INSTALL_DIR}\";")
        endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Python

        if (PROJECT_USES_PYTHON_UTILITIES)
          set (PY_B "${PY_B}        '${ALIAS}' : '${BUILD_LOCATION}',\n")
          set (PY_I "${PY_I}        '${ALIAS}' : '../../${INSTALL_LOCATION_REL2PYTHON_LIBRARY}',\n")
        endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # Perl

        if (PROJECT_USES_PERL_UTILITIES)
          if (PL_B)
            set (PL_B "${PL_B},\n")
          endif ()
          set (PL_B "${PL_B}    '${ALIAS}' => '${BUILD_LOCATION}'")
          if (PL_I)
            set (PL_I "${PL_I},\n")
          endif ()
          set (PL_I "${PL_I}    '${ALIAS}' => '../../${INSTALL_LOCATION_REL2PERL_LIBRARY}'")
        endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # BASH

        if (PROJECT_USES_BASH_UTILITIES)
          # hash entry
          set (SH_B "${SH_B}\n    _executabletargetinfo_add '${ALIAS}' LOCATION '${BUILD_LOCATION}'")
          set (SH_I "${SH_I}\n    _executabletargetinfo_add '${ALIAS}' LOCATION '${INSTALL_LOCATION_REL2LIBRARY}'")

          # alias
          set (SH_A "${SH_A}\nalias '${ALIAS}'=`get_executable_path '${ALIAS}'`")

          # short alias (if target belongs to this project)
          if (TARGET_UID MATCHES "^${BASIS_NAMESPACE_REGEX}${BASIS_NAMESPACE_SEPARATOR_REGEX}")
            basis_target_name (TARGET_NAME "${TARGET_UID}")
            set (SH_S "${SH_S}\nalias '${TARGET_NAME}'='${ALIAS}'")
          endif ()
        endif ()
      endif ()

    endif ()
  endforeach ()

  set (PY_B "${PY_B}    }")
  set (PY_I "${PY_I}    }")

  # --------------------------------------------------------------------------
  # remove unnecessary leading newlines

  string (STRIP "${CC}"   CC)
  string (STRIP "${PY_B}" PY_B)
  string (STRIP "${PY_I}" PY_I)
  string (STRIP "${PL_B}" PL_B)
  string (STRIP "${PL_I}" PL_I)
  string (STRIP "${SH_B}" SH_B)
  string (STRIP "${SH_A}" SH_A)
  string (STRIP "${SH_B}" SH_B)
  string (STRIP "${SH_I}" SH_I)

  # --------------------------------------------------------------------------
  # configure source files

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # C++

  if (PROJECT_USES_CXX_UTILITIES)
    set (EXECUTABLE_TARGET_INFO "${CC}")
    configure_file (
      "${BASIS_CXX_TEMPLATES_DIR}/ExecutableTargetInfo.cxx.in"
      "${BINARY_CODE_DIR}/ExecutableTargetInfo.cxx"
      @ONLY
    )
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Python

  if (PROJECT_USES_PYTHON_UTILITIES)
    # script configuration
    set (CONFIG "${CONFIG}if (BUILD_INSTALL_SCRIPT)\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${PY_I}\")\n")
    set (CONFIG "${CONFIG}else ()\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${PY_B}\")\n")
    set (CONFIG "${CONFIG}endif ()\n")

    # add module
    set (TEMPLATE_FILE "${BASIS_PYTHON_TEMPLATES_DIR}/executabletargetinfo.py")
    basis_get_source_target_name (TARGET_NAME "${TEMPLATE_FILE}" NAME)
    basis_add_library (
      ${TARGET_NAME}
        "${TEMPLATE_FILE}"
      MODULE
        BINARY_DIRECTORY "${BINARY_CODE_DIR}"
        CONFIG "${CONFIG}"
    )
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Perl

  if (PROJECT_USES_PERL_UTILITIES)
    # script configuration
    set (CONFIG "${CONFIG}if (BUILD_INSTALL_SCRIPT)\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${PL_I}\")\n")
    set (CONFIG "${CONFIG}else ()\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${PL_B}\")\n")
    set (CONFIG "${CONFIG}endif ()\n")

    # add module
    set (TEMPLATE_FILE "${BASIS_PERL_TEMPLATES_DIR}/ExecutableTargetInfo.pm")
    basis_get_source_target_name (TARGET_NAME "${TEMPLATE_FILE}" NAME)
    basis_add_library (
      ${TARGET_NAME}
        "${TEMPLATE_FILE}"
      MODULE
        BINARY_DIRECTORY "${BINARY_CODE_DIR}"
        CONFIG "${CONFIG}"
    )
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # BASH

  if (PROJECT_USES_BASH_UTILITIES)
    # script configuration
    set (CONFIG "${CONFIG}if (BUILD_INSTALL_SCRIPT)\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${SH_I}\")\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_ALIASES \"${SH_A}\n\n# define short aliases for this project's targets\n${SH_S}\")\n")
    set (CONFIG "${CONFIG}else ()\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_TARGET_INFO \"${SH_B}\")\n")
    set (CONFIG "${CONFIG}  set (EXECUTABLE_ALIASES \"${SH_A}\n\n# define short aliases for this project's targets\n${SH_S}\")\n")
    set (CONFIG "${CONFIG}endif ()\n")

    # add module
    set (TEMPLATE_FILE "${BASIS_BASH_TEMPLATES_DIR}/executabletargetinfo.sh")
    basis_get_source_target_name (TARGET_NAME "${TEMPLATE_FILE}" NAME)
    basis_add_library (
      ${TARGET_NAME}
        "${TEMPLATE_FILE}"
      MODULE
        BINARY_DIRECTORY "${BINARY_CODE_DIR}"
        CONFIG "${CONFIG}"
    )
  endif ()

  # --------------------------------------------------------------------------
  # done
  if (BASIS_VERBOSE)
    message (STATUS "Configuring ExecutableTargetInfo... - done")
  endif ()
endfunction ()


## @}
# End Doxygen group
