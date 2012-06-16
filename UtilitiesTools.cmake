##############################################################################
# @file  UtilitiesTools.cmake
# @brief CMake functions related to configuration of BASIS utilities.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

## @addtogroup CMakeUtilities
#  @{


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
# @ingroup BasisBashUtilities
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
# @ingroup BasisBashUtilities
set (BASIS_BASH___DIR__ "$(cd -P -- \"$(dirname -- \"\${BASH_SOURCE}\")\" && pwd -P)")

# ============================================================================
# deprecated BASIS_<LANG>_UTILITIES "macros"
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Include BASIS utilities for Python.
#
# @deprecated This macro should no longer be used. Instead, simply import the
#             sbia.&lt;project&gt;.basis module, e.g.,
#             "from sbia.<project> import basis".
set (BASIS_PYTHON_UTILITIES "\@PROJECT_NAMESPACE_PYTHON\@ import basis")

# ----------------------------------------------------------------------------
## @brief Include BASIS utilities for Perl.
#
# @deprecated This macro should no longer be used. Instead add the code
#             "package Basis; use SBIA::<Project>::Basis qw(:everything); package main;"
#             to your script. The package instructions can be omitted if the
#             BASIS functions shall not be placed in the Basis package.
set (BASIS_PERL_UTILITIES "package Basis; use \@PROJECT_NAMESPACE_PERL\@::Basis qw(:everything); package main;")

# ----------------------------------------------------------------------------
## @brief Include BASIS utilities for BASH.
#
# @deprecated This macro should not be used any longer. Instead, simply add
#             the code "source ${BASIS_MODULE} || exit 1" to your script.
set (BASIS_BASH_UTILITIES ". \${BASIS_BASH_UTILITIES} || exit 1")

# ============================================================================
# determine which utilities are used
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Check whether the BASIS utilities are used within a given source file.
#
# This function matches the source code against specific import patterns which
# are all valid imports of the BASIS utilities for the respective programming
# language of the specified file. If the BASIS utilities are used within the
# specified source file, the variable named @p VAR is set to @c TRUE.
# Otherwise, it is set to @c FALSE.
#
# @param [out] VAR         Whether the BASIS utilites are used.
# @param [in]  SOURCE_FILE Path of source file to check.
# @param [in]  ARGN        Source code language. If not specified, the
#                          programming language is determined automatically.
function (basis_utilities_check VAR SOURCE_FILE)
  set (UTILITIES_USED FALSE)
  if (ARGC EQUAL 2)
    basis_get_source_language (LANGUAGE "${SOURCE_FILE}")
  elseif (ARGC EQUAL 3)
    set (LANGUAGE "${ARGN}")
  else ()
    message (FATAL_ERROR "Too many arguments given!")
  endif ()
  # --------------------------------------------------------------------------
  # C++
  if (LANGUAGE MATCHES "CXX")
    # read script file
    file (READ "${SOURCE_FILE}" SOURCE)
    # match use/require statements
    if (NOT UTILITIES_USED)
      set (RE "[ \\t]*#[ \\t]*include[ \\t]+[<"](${INCLUDE_PREFIX})?basis.h[">]") # e.g., #include "basis.sh", #include <sbia/project/basis.h>
      set (RE "(^|\\n)[ \\t]*${RE}([ \\t]*//.*|[ \\t]*)(\\n|$)")
      if (SCRIPT MATCHES "${RE}")
        set (UTILITIES_USED TRUE)
        break ()
      endif ()
    endif ()
  # --------------------------------------------------------------------------
  # Python
  elseif (LANGUAGE MATCHES "PYTHON")
    # read script file
    file (READ "${SOURCE_FILE}" SCRIPT)
    # deprecated BASIS_PYTHON_UTILITIES macro
    if (SCRIPT MATCHES "(^|\n|;)[ \t]*\@BASIS_PYTHON_UTILITIES\@")
      message (WARNING "Script ${SCRIPT_FILE} uses the deprecated BASIS macro \@BASIS_PYTHON_UTILITIES\@!"
                       " Replace macro by\nfrom ${PROJECT_NAMESPACE_PYTHON} import basis")
      set (UTILITIES_USED TRUE)
    endif ()
    # match import statements
    if (NOT UTILITIES_USED)
      basis_sanitize_for_regex (PYTHON_PACKAGE "${PROJECT_NAMESPACE_PYTHON}")
      foreach (RE IN ITEMS
        "import[ \\t]+${PYTHON_PACKAGE}\\.basis"                # e.g., import sbia.project.basis
        "import[ \\t]+\\.\\.?basis"                             # e.g., import .basis", "import ..basis
        "from[ \\t]+${PYTHON_PACKAGE}[ \\t]+import[ \\t]+basis" # e.g., from sbia.project import basis
        "from[ \\t]+\\.\\.?[ \\t]+import[ \\t]+basis"           # e.g., from . import basis", "from .. import basis
        "from[ \\t]+\\.\\.?basis[ \\t]+import[ \\t].*"          # e.g., from .basis import which, WhichError", "form ..basis import which
      ) # foreach RE
        set (RE "(^|\\n|;)[ \\t]*${RE}([ \\t]*as[ \\t]+.*)?([ \\t]*#.*|[ \\t]*)(;|\\n|$)")
        if (SCRIPT MATCHES "${RE}")
          set (UTILITIES_USED TRUE)
          break ()
        endif ()
      endforeach ()
    endif ()
  # --------------------------------------------------------------------------
  # Perl
  elseif (LANGUAGE MATCHES "PERL")
    # read script file
    file (READ "${SOURCE_FILE}" SCRIPT)
    # deprecated BASIS_PERL_UTILITIES macro
    if (SCRIPT MATCHES "(^|\n|;)[ \t]*\@BASIS_PERL_UTILITIES\@")
      message (WARNING "Script ${SCRIPT_FILE} uses the deprecated BASIS macro \@BASIS_PERL_UTILITIES\@!"
                       " Replace macro by\nuse ${PROJECT_NAMESPACE_PERL}::Basis")
      set (UTILITIES_USED TRUE)
    endif ()
    # match use/require statements
    if (NOT UTILITIES_USED)
      set (RE "(use|require)[ \\t]+${PROJECT_NAMESPACE_PERL}::Basis([ \\t]+.*)?") # e.g., use SBIA::Project::Basis qw(:everything);
      set (RE "(^|\\n|;)[ \\t]*${RE}([ \\t]*#.*|[ \\t]*)(;|\\n|$)")
      if (SCRIPT MATCHES "${RE}")
        set (UTILITIES_USED TRUE)
        break ()
      endif ()
    endif ()
  # --------------------------------------------------------------------------
  # Bash
  elseif (LANGUAGE MATCHES "BASH")
    # read script file
    file (READ "${SOURCE_FILE}" SCRIPT)
    # deprecated BASIS_BASH_UTILITIES macro
    if (SCRIPT MATCHES "(^|\n|;)[ \t]*\@BASIS_BASH_UTILITIES\@")
      message (WARNING "Script ${SCRIPT_FILE} uses the deprecated BASIS macro \@BASIS_BASH_UTILITIES\@!"
                       " Replace macro by\n. \${BASIS_BASH_UTILITIES} || exit 1")
      set (UTILITIES_USED TRUE)
    endif ()
    # match source/. built-ins
    if (NOT UTILITIES_USED)
      set (RE "(source|\\.)[ \\t]+\\\${?BASIS_BASH_UTILITIES}?[ \\t]*(\\|\\|.*|&&.*)?(#.*)?") # e.g., . ${BASIS_BASH_UTILITIES} || exit 1
      set (RE "(^|\\n|;)[ \\t]*(${RE})[ \\t]*(;|\\n|$)")
      if (SCRIPT MATCHES "${RE}")
        set (UTILITIES_USED TRUE)
      endif ()
    endif ()
  endif ()
  # return
  set (${VAR} "${UTILITIES_USED}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# configuration
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Write dummy source files of BASIS utilities.
#
# The CMake functions add_executable() and add_library() check if the specified
# source code files exist. If a source file is not found, an error is raised
# by these functions. The BASIS utilities can, however, only be configured at
# the end of the configuration step. Therefore, this function simply writes
# dummy files in order to pass the existence check. The actual source files
# are configured by the function basis_configure_utilities().
#
# @sa basis_configure_utilities()
function (basis_write_dummy_utilities)
  foreach (S IN ITEMS basis.h basis.cxx)
    if (S MATCHES "\\.h$")
      set (S "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}/${S}")
    else ()
      set (S "${BINARY_CODE_DIR}/${S}")
    endif ()
    if (NOT EXISTS "${S}")
      file (WRITE "${S}"
        "#error This dummy source file should have been replaced by the"
        " BASIS CMake function basis_configure_utilities()"
      )
    endif ()
  endforeach ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Configure BASIS utilities.
#
# This function configures the following source files which can be used
# within the source code of the project.
#
# <table border="0">
#   <tr>
#     @tp @b basis.h @endtp
#     <td>Header file declaring the BASIS utilities for C++.</td>
#   </tr>
#   <tr>
#     @tp @b basis.cxx @endtp
#     <td>Definitions of the constants and functions declared in basis.h.</td>
#   </tr>
#   <tr>
#     @tp @b basis.py @endtp
#     <td>Module defining the BASIS utilities for Python.</td>
#   </tr>
#   <tr>
#     @tp @b Basis.pm @endtp
#     <td>Module defining the BASIS utilities for Perl.</td>
#   </tr>
#   <tr>
#     @tp @b basis.sh @endtp
#     <td>Module defining the BASIS utilities for Bash.</td>
#   </tr>
# </table>
#
# @note Dummy versions of the C++ source files have been written by the
#       function basis_configure_auxiliary_sources() beforehand. This is
#       necessary because CMake's add_executable() and add_library() commands
#       raise an error if any of the specified source files does not exist.
function (basis_configure_utilities)
  set (CXX TRUE)
  basis_get_project_property (PYTHON PROPERTY PROJECT_USES_PYTHON_UTILITIES)
  basis_get_project_property (PERL   PROPERTY PROJECT_USES_PERL_UTILITIES)
  basis_get_project_property (BASH   PROPERTY PROJECT_USES_BASH_UTILITIES)
  if (NOT CXX AND NOT PYTHON AND NOT PERL AND NOT BASH)
    return ()
  elseif (BASIS_VERBOSE)
    message (STATUS "Configuring BASIS utilities...")
  endif ()
  # --------------------------------------------------------------------------
  # executable target information
  _basis_generate_executable_target_info(${CXX} ${PYTHON} ${PERL} ${BASH})
  # --------------------------------------------------------------------------
  # C++
  if (CXX)
    # paths - build tree
    set (BUILD_ROOT_PATH_CONFIG    "${CMAKE_BINARY_DIR}")
    set (RUNTIME_BUILD_PATH_CONFIG "${BINARY_RUNTIME_DIR}")
    set (LIBEXEC_BUILD_PATH_CONFIG "${BINARY_LIBEXEC_DIR}")
    set (LIBRARY_BUILD_PATH_CONFIG "${BINARY_LIBRARY_DIR}")
    set (DATA_BUILD_PATH_CONFIG    "${PROJECT_DATA_DIR}")
    # paths - installation
    file (RELATIVE_PATH RUNTIME_PATH_PREFIX_CONFIG "${INSTALL_PREFIX}/${INSTALL_RUNTIME_DIR}" "${INSTALL_PREFIX}")
    string (REGEX REPLACE "/$|\\$" "" RUNTIME_PATH_PREFIX_CONFIG "${RUNTIME_PATH_PREFIX_CONFIG}")
    file (RELATIVE_PATH LIBEXEC_PATH_PREFIX_CONFIG "${INSTALL_PREFIX}/${INSTALL_LIBEXEC_DIR}" "${INSTALL_PREFIX}")
    string (REGEX REPLACE "/$|\\$" "" LIBEXEC_PATH_PREFIX_CONFIG "${LIBEXEC_PATH_PREFIX_CONFIG}")
    set (RUNTIME_PATH_CONFIG "${INSTALL_RUNTIME_DIR}")
    set (LIBEXEC_PATH_CONFIG "${INSTALL_LIBEXEC_DIR}")
    set (LIBRARY_PATH_CONFIG "${INSTALL_LIBRARY_DIR}")
    set (DATA_PATH_CONFIG    "${INSTALL_DATA_DIR}")
    # executable target information
    set (EXECUTABLE_TARGET_INFO "${EXECUTABLE_TARGET_INFO_CXX}")
    # configure source files
    configure_file (
      "${BASIS_CXX_TEMPLATES_DIR}/basis.h.in"
      "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}basis.h"
      @ONLY
    )
    configure_file (
      "${BASIS_CXX_TEMPLATES_DIR}/basis.cxx.in"
      "${BINARY_CODE_DIR}/basis.cxx"
      @ONLY
    )
    source_group (BASIS FILES "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}basis.h"
                              "${BINARY_CODE_DIR}/basis.cxx")
  endif ()
  # --------------------------------------------------------------------------
  # Python
  if (PYTHON)
    # utilities available?
    if (NOT BASIS_UTILITIES_ENABLED MATCHES "PYTHON")
      message (FATAL_ERROR "BASIS Python utilities required by this package"
                           " but BASIS was built without Python utilities."
                           " Rebuild BASIS with Python utilities enabled.")
    endif ()
    # add project-specific utilities
    basis_add_library (
      basis_py
        "${BASIS_PYTHON_TEMPLATES_DIR}/basis.py"
      MODULE
        BINARY_DIRECTORY "${BINARY_CODE_DIR}"
        CONFIG "if (BUILD_INSTALL_SCRIPT)
                  set (EXECUTABLE_TARGET_INFO \"${EXECUTABLE_TARGET_INFO_PYTHON_I}\")
                else ()
                  set (EXECUTABLE_TARGET_INFO \"${EXECUTABLE_TARGET_INFO_PYTHON_B}\")
                endif ()"
    )
    basis_set_target_properties (basis_py PROPERTIES OUTPUT_NAME basis)
    # dependencies
    basis_add_dependencies (basis_py _initpy)
    if (PROJECT_NAME MATCHES "^BASIS$")
      basis_add_dependencies (basis_py which_py)
    endif ()
  endif ()
  # --------------------------------------------------------------------------
  # Perl
  if (PERL)
    # utilities available?
    if (NOT BASIS_UTILITIES_ENABLED MATCHES "PERL")
      message (FATAL_ERROR "BASIS Perl utilities required by this package"
                           " but BASIS was built without Perl utilities."
                           " Rebuild BASIS with Perl utilities enabled.")
    endif ()
    # add project-specific utilities
    basis_add_library (
      Basis_pm
        "${BASIS_PERL_TEMPLATES_DIR}/Basis.pm"
      MODULE
        BINARY_DIRECTORY "${BINARY_CODE_DIR}"
        CONFIG "if (BUILD_INSTALL_SCRIPT)
                  set (EXECUTABLE_TARGET_INFO \"${EXECUTABLE_TARGET_INFO_PERL_I}\")
                else ()
                  set (EXECUTABLE_TARGET_INFO \"${EXECUTABLE_TARGET_INFO_PERL_B}\")
                endif ()"
    )
    basis_set_target_properties (Basis_pm PROPERTIES OUTPUT_NAME "Basis")
    # dependencies
    if (PROJECT_NAME MATCHES "^BASIS$")
      basis_add_dependencies (Basis_pm Utilities_pm)
    endif ()
  endif ()
  # --------------------------------------------------------------------------
  # Bash
  if (BASH)
    # utilities available?
    if (NOT UNIX)
      message (WARNING "Package uses BASIS Bash utilities but is build"
                       " on a non-Unix system.")
    endif ()
    # utilities available?
    if (NOT BASIS_UTILITIES_ENABLED MATCHES "BASH")
      message (FATAL_ERROR "BASIS Bash utilities required by this package"
                           " but BASIS was built without Bash utilities."
                           " Rebuild BASIS with Bash utilities enabled.")
    endif ()
    # add project-specific utilities
    basis_add_library (
      basis_sh
        "${BASIS_BASH_TEMPLATES_DIR}/basis.sh"
      MODULE
        BINARY_DIRECTORY "${BINARY_CODE_DIR}"
        CONFIG "if (BUILD_INSTALL_SCRIPT)
                  set (EXECUTABLE_TARGET_INFO \"${EXECUTABLE_TARGET_INFO_BASH_I}\")
                else ()
                  set (EXECUTABLE_TARGET_INFO \"${EXECUTABLE_TARGET_INFO_BASH_B}\")
                endif ()
                set (EXECUTABLE_ALIASES \"${EXECUTABLE_TARGET_INFO_BASH_A}\n\n# define short aliases for this project's targets\n${SH_S}\")"
    )
    basis_set_target_properties (basis_sh PROPERTIES OUTPUT_NAME basis)
    # dependencies
    if (PROJECT_NAME MATCHES "^BASIS$")
      basis_add_dependencies (basis_sh utilities_sh)
    endif ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring BASIS utilities... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Generate code for initialization of executable target information.
#
# This macro generates the initialization code of the executable target
# information dictionaries for different supported programming languages.
# In case of C++, the source file has been configured and copied to the binary
# tree in a first configuration pass such that it could be used in basis_add_*()
# commands which check the existence of the arguments immediately.
# As the generation of the initialization code requires a complete list of
# build targets (cached in @c BASIS_TARGETS), this function has to be called
# after all targets have been added and finalized (in case of custom targets).
#
# @param [in] CXX    Request code for C++.
# @param [in] PYTHON Request code for Python.
# @param [in] PERL   Request code for Perl.
# @param [in] BASH   Request code for Bash.
#
# @returns Sets the following variables for each requested language.
#
# @retval EXECUTABLE_TARGET_INFO_CXX      C++ code for both build tree and installation.
# @retval EXECUTABLE_TARGET_INFO_PYTHON_B Python code for build tree.
# @retval EXECUTABLE_TARGET_INFO_PYTHON_I Python code for installation.
# @retval EXECUTABLE_TARGET_INFO_PERL_B   Perl code for build tree.
# @retval EXECUTABLE_TARGET_INFO_PERL_I   Perl code for installation.
# @retval EXECUTABLE_TARGET_INFO_BASH_B   Bash code for build tree.
# @retval EXECUTABLE_TARGET_INFO_BASH_I   Bash code for installation.
# @retval EXECUTABLE_TARGET_INFO_BASH_A   Bash code to set aliases.
# @retval EXECUTABLE_TARGET_INFO_BASH_S   Bash code to set short aliases.
function (_basis_generate_executable_target_info CXX PYTHON PERL BASH)
  # --------------------------------------------------------------------------
  if (NOT CXX AND NOT PYTHON AND NOT PERL AND NOT BASH)
    return ()
  endif ()
  # --------------------------------------------------------------------------
  # lists of executable targets and their location
  set (EXECUTABLE_TARGETS)
  set (BUILD_LOCATIONS)
  set (INSTALL_LOCATIONS)
  # project targets
  foreach (P IN ITEMS ${PROJECT_NAME} ${PROJECT_MODULES_ENABLED})
    basis_get_project_property (TARGETS ${P})
    foreach (TARGET IN LISTS TARGETS)
      basis_get_target_type (TYPE ${TARGET})
      if (TYPE MATCHES "EXECUTABLE")
        basis_get_target_location (BUILD_LOCATION   ${TARGET} ABSOLUTE)
        basis_get_target_location (INSTALL_LOCATION ${TARGET} POST_INSTALL)
        if (BUILD_LOCATION AND INSTALL_LOCATION)
          list (APPEND EXECUTABLE_TARGETS "${TARGET}")
          list (APPEND BUILD_LOCATIONS    "${BUILD_LOCATION}")
          list (APPEND INSTALL_LOCATIONS  "${INSTALL_LOCATION}")
        else ()
          message (FATAL_ERROR "Failed to determine build or install location of target ${TARGET}!")
        endif ()
      endif ()
    endforeach ()
  endforeach ()
  # imported targets - exclude targets imported from other module
  foreach (P IN ITEMS ${PROJECT_NAME} ${PROJECT_MODULES_ENABLED})
    basis_get_project_property (IMPORTED_TARGETS   ${P})
    basis_get_project_property (IMPORTED_TYPES     ${P})
    basis_get_project_property (IMPORTED_LOCATIONS ${P})
    set (I 0)
    list (LENGTH IMPORTED_TARGETS N)
    while (I LESS N)
      list (GET IMPORTED_TARGETS   ${I} TARGET)
      list (GET IMPORTED_TYPES     ${I} TYPE)
      list (GET IMPORTED_LOCATIONS ${I} LOCATION)
      if (TYPE MATCHES "EXECUTABLE")
        # get corresponding UID to recognize targets imported from other modules
        basis_get_target_uid (UID ${TARGET})
        # skip already considered executables
        list (FIND EXECUTABLE_TARGETS ${UID} IDX)
        if (IDX EQUAL -1)
          if (LOCATION MATCHES "^NOTFOUND$")
            message (WARNING "Imported target ${TARGET} has no location property!")
          else ()
            list (APPEND EXECUTABLE_TARGETS ${TARGET})
            list (APPEND BUILD_LOCATIONS    "${LOCATION}")
            list (APPEND INSTALL_LOCATIONS  "${LOCATION}")
          endif ()
        endif ()
      endif ()
      math (EXPR I "${I} + 1")
    endwhile ()
  endforeach ()
  # --------------------------------------------------------------------------
  # determine maximum length of target alias for prettier output
  set (MAX_ALIAS_LENGTH 0)
  foreach (TARGET_UID IN LISTS EXECUTABLE_TARGETS)
    if (TARGET_UID MATCHES "\\.")
      string (LENGTH "${TARGET_UID}" LENGTH)
    else ()
      string (LENGTH "${PROJECT_NAMESPACE_CMAKE}.${TARGET_UID}" LENGTH)
    endif ()
    if (LENGTH GREATER MAX_ALIAS_LENGTH)
      set (MAX_ALIAS_LENGTH ${LENGTH})
    endif ()
  endforeach ()
  # --------------------------------------------------------------------------
  # generate source code
  set (CC)   # C++    - build tree and install tree version, constructor block
  set (PY_B) # Python - build tree version
  set (PY_I) # Python - install tree version
  set (PL_B) # Perl   - build tree version, hash entries
  set (PL_I) # Perl   - install tree version, hash entries
  set (SH_B) # Bash   - build tree version
  set (SH_I) # Bash   - install tree version
  set (SH_A) # Bash   - aliases
  set (SH_S) # Bash   - short aliases

  if (CXX)
    set (CC            "// the following code was automatically generated by the BASIS")
    set (CC "${CC}\n    // CMake function basis_configure_ExecutableTargetInfo()")
  endif ()

  set (I 0)
  list (LENGTH EXECUTABLE_TARGETS N)
  while (I LESS N)
    # ------------------------------------------------------------------------
    # get executable information
    list (GET EXECUTABLE_TARGETS ${I} TARGET_UID)
    list (GET BUILD_LOCATIONS    ${I} BUILD_LOCATION)
    list (GET INSTALL_LOCATIONS  ${I} INSTALL_LOCATION)
    # insert $(IntDir) for Visual Studio build location
    if (CMAKE_GENERATOR MATCHES "Visual Studio")
      basis_get_target_type (TYPE ${TARGET_UID})
      if (TYPE MATCHES "^EXECUTABLE$")
        get_filename_component (DIRECTORY "${BUILD_LOCATION}" PATH)
        get_filename_component (FILENAME  "${BUILD_LOCATION}" NAME)
        set (BUILD_LOCATION_WITH_INTDIR "${DIRECTORY}/$(IntDir)/${FILENAME}")
      else ()
        set (BUILD_LOCATION_WITH_INTDIR "${BUILD_LOCATION}")
      endif ()
    else ()
      set (BUILD_LOCATION_WITH_INTDIR "${BUILD_LOCATION}")
    endif ()
    # installation path relative to different library paths
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
    # target UID including project namespace
    if (TARGET_UID MATCHES "\\.")
      set (ALIAS "${TARGET_UID}")
    else ()
      set (ALIAS "${PROJECT_NAMESPACE_CMAKE}.${TARGET_UID}")
    endif ()
    # indentation after dictionary key, i.e., alias
    string (LENGTH "${ALIAS}" ALIAS_LENGTH)
    math (EXPR NUM "${MAX_ALIAS_LENGTH} - ${ALIAS_LENGTH} + 1")
    if (NUM GREATER 1)
      string (RANDOM LENGTH ${NUM} ALPHABET " " S)
    else ()
      set (S " ")
    endif ()
    # ------------------------------------------------------------------------
    # C++
    if (CXX)
      get_filename_component (EXEC_NAME   "${BUILD_LOCATION}"   NAME)
      get_filename_component (BUILD_DIR   "${BUILD_LOCATION}"   PATH)
      get_filename_component (INSTALL_DIR "${INSTALL_LOCATION}" PATH)

      set (CC "${CC}\n")
      set (CC "${CC}\n    // ${TARGET_UID}")
      set (CC "${CC}\n    _exec_names  [\"${ALIAS}\"]${S}= \"${EXEC_NAME}\";")
      set (CC "${CC}\n    _build_dirs  [\"${ALIAS}\"]${S}= \"${BUILD_DIR}\";")
      set (CC "${CC}\n    _install_dirs[\"${ALIAS}\"]${S}= \"${INSTALL_DIR}\";")
    endif ()
    # ------------------------------------------------------------------------
    # Python
    if (PYTHON)
      set (PY_B "${PY_B}    '${ALIAS}':${S}'${BUILD_LOCATION_WITH_INTDIR}',\n")
      set (PY_I "${PY_I}    '${ALIAS}':${S}'../../${INSTALL_LOCATION_REL2PYTHON_LIBRARY}',\n")
    endif ()
    # ------------------------------------------------------------------------
    # Perl
    if (PERL)
      if (PL_B)
        set (PL_B "${PL_B},\n")
      endif ()
      set (PL_B "${PL_B}    '${ALIAS}'${S}=> '${BUILD_LOCATION_WITH_INTDIR}'")
      if (PL_I)
        set (PL_I "${PL_I},\n")
      endif ()
      set (PL_I "${PL_I}    '${ALIAS}'${S}=> '../../${INSTALL_LOCATION_REL2PERL_LIBRARY}'")
    endif ()
    # ------------------------------------------------------------------------
    # Bash
    if (BASH)
      # hash entry
      set (SH_B "${SH_B}\n    _executabletargetinfo_add '${ALIAS}'${S}LOCATION '${BUILD_LOCATION}'")
      set (SH_I "${SH_I}\n    _executabletargetinfo_add '${ALIAS}'${S}LOCATION '${INSTALL_LOCATION_REL2LIBRARY}'")
      # alias
      set (SH_A "${SH_A}\nalias '${ALIAS}'=`get_executable_path '${ALIAS}'`")
      # short alias (if target belongs to this project)
      if (TARGET_UID MATCHES "^${PROJECT_NAMESPACE_CMAKE_REGEX}\\.")
        basis_get_target_name (TARGET_NAME "${TARGET_UID}")
        set (SH_S "${SH_S}\nalias '${TARGET_NAME}'='${ALIAS}'")
      endif ()
    endif ()
    # ------------------------------------------------------------------------
    # next executable target
    math (EXPR I "${I} + 1")
  endwhile ()
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
  # return
  set (EXECUTABLE_TARGET_INFO_CXX      "${CC}"   PARENT_SCOPE)
  set (EXECUTABLE_TARGET_INFO_PYTHON_B "${PY_B}" PARENT_SCOPE)
  set (EXECUTABLE_TARGET_INFO_PYTHON_I "${PY_I}" PARENT_SCOPE)
  set (EXECUTABLE_TARGET_INFO_PERL_B   "${PL_B}" PARENT_SCOPE)
  set (EXECUTABLE_TARGET_INFO_PERL_I   "${PL_I}" PARENT_SCOPE)
  set (EXECUTABLE_TARGET_INFO_BASH_B   "${SH_B}" PARENT_SCOPE)
  set (EXECUTABLE_TARGET_INFO_BASH_I   "${SH_I}" PARENT_SCOPE)
  set (EXECUTABLE_TARGET_INFO_BASH_A   "${SH_A}" PARENT_SCOPE)
  set (EXECUTABLE_TARGET_INFO_BASH_S   "${SH_S}" PARENT_SCOPE)
endfunction ()


## @}
# end of Doxygen group
