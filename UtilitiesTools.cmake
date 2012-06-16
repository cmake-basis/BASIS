##############################################################################
# @file  UtilitiesTools.cmake
# @brief CMake functions used to configure auxiliary source files.
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
# determine which utilities are used
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Check which BASIS utilities are used within given script.
#
# This function matches the script code against specific import patterns which
# are all valid imports of the BASIS utilities for the respective programming
# language of the specified script file. If the BASIS utilities are used within
# the specified script, the variable @p RETVAL is set to @c TRUE, and @c FALSE
# otherwise.
#
# @param [out] VAR         Whether the BASIS utilites are used by the @p SCRIPT_FILE.
# @param [in]  SCRIPT_FILE Path of script file to check.
function (basis_utilities_check VAR SCRIPT_FILE)
  set (SCRIPT_USES_BASIS_UTILITIES FALSE)
  basis_get_source_language (SCRIPT_LANGUAGE "${SCRIPT_FILE}")
  file (READ "${SCRIPT_FILE}" SCRIPT)
  set (BASIS_UTILITIES_REGEX)
  if (SCRIPT_LANGUAGE MATCHES "PYTHON")
    basis_sanitize_for_regex (PYTHON_PACKAGE "${PROJECT_NAMESPACE_PYTHON}")
    list (APPEND BASIS_UTILITIES_REGEX "import[ \\t]+${PYTHON_PACKAGE}\\.basis([ \\t]*#.*)?")                # e.g., "import sbia.project.basis"
    list (APPEND BASIS_UTILITIES_REGEX "import[ \\t]+\\.\\.?basis")                                          # e.g., "import .basis", "import ..basis"
    list (APPEND BASIS_UTILITIES_REGEX "from[ \\t]+${PYTHON_PACKAGE}[ \\t]+import[ \\t]+basis([ \\t]*#.*)?") # e.g., "from sbia.project import basis"
    list (APPEND BASIS_UTILITIES_REGEX "from[ \\t]+\\.\\.?[ \\t]+import[ \\t]+basis([ \\t]*#.*)?")           # e.g., "from . import basis", "from .. import basis"
    list (APPEND BASIS_UTILITIES_REGEX "from[ \\t]+\\.\\.?basis[ \\t]+import[ \\t].*([ \\t]*#.*)?")          # e.g., "from .basis import which, WhichError", "form ..basis import which"
    # deprecated BASIS_PYTHON_UTILITIES macro
    if (SCRIPT MATCHES "(^|\n|;)[ \t]*\@BASIS_PYTHON_UTILITIES\@")
      message (WARNING "Script ${SCRIPT_FILE} uses the deprecated BASIS macro \@BASIS_PYTHON_UTILITIES\@!"
                       " Replace macro by\nfrom ${PROJECT_NAMESPACE_PYTHON} import basis")
      set (SCRIPT_USES_BASIS_UTILITIES TRUE)
    endif ()
  elseif (SCRIPT_LANGUAGE MATCHES "PERL")
    set (BASIS_UTILITIES_REGEX "use[ \\t]+${PROJECT_NAMESPACE_PERL}::Basis([ \\t]+.*)?([ \\t]*#.*)?")        # e.g., "use SBIA::Project::Basis qw(:everything);"
    # deprecated BASIS_PERL_UTILITIES macro
    if (SCRIPT MATCHES "(^|\n|;)[ \t]*\@BASIS_PERL_UTILITIES\@")
      message (WARNING "Script ${SCRIPT_FILE} uses the deprecated BASIS macro \@BASIS_PERL_UTILITIES\@!"
                       " Replace macro by\npackage Basis; use ${PROJECT_NAMESPACE_PERL}::Basis; package main;")
      set (SCRIPT_USES_BASIS_UTILITIES TRUE)
    endif ()
  elseif (SCRIPT_LANGUAGE MATCHES "BASH")
    set (BASIS_UTILITIES_REGEX "(source|\\.)[ \\t]+\\\${?BASIS_SOURCE}?[ \\t]*(\\|\\|.*|&&.*)?(#.*)?")       # e.g., ". ${BASIS_SOURCE} || exit 1"
    # deprecated BASIS_BASH_UTILITIES macro
    if (SCRIPT MATCHES "(^|\n|;)[ \t]*\@BASIS_BASH_UTILITIES\@")
      message (WARNING "Script ${SCRIPT_FILE} uses the deprecated BASIS macro \@BASIS_BASH_UTILITIES\@!"
                       " Replace macro by\n. \${BASIS_BASH_UTILITIES} || exit 1")
      set (SCRIPT_USES_BASIS_UTILITIES TRUE)
    endif ()
  endif ()
  if (NOT SCRIPT_USES_BASIS_UTILITIES AND BASIS_UTILITIES_REGEX)
    basis_list_to_delimited_string (BASIS_UTILITIES_REGEX "|" NOAUTOQUOTE ${BASIS_UTILITIES_REGEX})
    if (SCRIPT MATCHES "(^|\n|;)[ \t]*(${BASIS_UTILITIES_REGEX})[ \t]*(;|\n|$)")
      set (SCRIPT_USES_BASIS_UTILITIES TRUE)
    endif ()
  endif ()
  # return
  set (${RETVAL} "${SCRIPT_USES_BASIS_UTILITIES}" PARENT_SCOPE)
endfunction ()

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
# auxiliary sources
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Configure auxiliary C++ source files.
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

# ----------------------------------------------------------------------------
## @brief Add include directories of auxiliary sources to search path.
#
# @param [in] SOURCES_LIST Name of list of source files.
# @param [in] HEADERS_LIST Name of list of header files.
function (basis_use_auxiliary_sources SOURCES_LIST HEADERS_LIST)
  # Attention: BASIS includes public header files which are named the
  #            same as system-wide header files. Therefore, avoid to add
  #            include/sbia/basis/ to the include search path.
  #
  #            For all other projects, this path was already added to the
  #            standard include search path (or not if not desired).
  #            In any case, do not add this path at this point.
  string (REGEX REPLACE "/$" "" EXCLUDE_DIRS "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}")
  # get list of paths to auxiliary header files
  set (INCLUDE_DIRS)
  foreach (H IN LISTS ${HEADERS_LIST})
    get_filename_component (D "${H}" PATH)
    list (FIND EXCLUDE_DIRS "${D}" IDX)
    if (IDX EQUAL -1)
      list (APPEND INCLUDE_DIRS "${D}")
    endif ()
  endforeach ()
  # remove duplicates
  if (INCLUDE_DIRS)
    list (REMOVE_DUPLICATES INCLUDE_DIRS)
  endif ()
  # add include directories
  if (INCLUDE_DIRS)
    basis_include_directories (BEFORE ${INCLUDE_DIRS})
  endif ()
  # define source groups
  if (${HEADERS_LIST})
    source_group ("Default" FILES ${${HEADERS_LIST}})
  endif ()
  if (${SOURCES_LIST})
    source_group ("Default" FILES ${${SOURCES_LIST}})
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Configure auxiliary modules for scripting languages.
function (basis_configure_auxiliary_modules)
  basis_get_project_property (PYTHON PROPERTY PROJECT_USES_PYTHON_UTILITIES)
  basis_get_project_property (PERL   PROPERTY PROJECT_USES_PERL_UTILITIES)
  basis_get_project_property (BASH   PROPERTY PROJECT_USES_BASH_UTILITIES)

  if (NOT PYTHON AND NOT PERL AND NOT BASH)
    return ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring auxiliary modules...")
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
    foreach (MODULE basis stdaux)
      basis_get_source_target_name (PYTHON_UTILITIES_${MODULE} "${MODULE}.py" NAME)
      basis_add_library (
        ${PYTHON_UTILITIES_${MODULE}}
          "${BASIS_PYTHON_TEMPLATES_DIR}/${MODULE}.py"
        MODULE
          BINARY_DIRECTORY "${BINARY_CODE_DIR}"
      )
      basis_set_target_properties (
        ${PYTHON_UTILITIES_${MODULE}}
        PROPERTIES
          OUTPUT_NAME "${MODULE}"
          SUFFIX      ".py"
      )
    endforeach ()
    # dependencies
    foreach (MODULE stdaux executabletargetinfo)
      basis_get_source_target_name (PYTHON_UTILITIES_${MODULE} "${MODULE}.py" NAME)
      basis_add_dependencies (${PYTHON_UTILITIES_basis} ${PYTHON_UTILITIES_${MODULE}})
    endforeach ()
    basis_add_dependencies (${PYTHON_UTILITIES_basis} _initpy)
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
    foreach (MODULE Basis StdAux)
      basis_get_source_target_name (PERL_UTILITIES_${MODULE} "${MODULE}.pm" NAME)
      basis_add_library (
        ${PERL_UTILITIES_${MODULE}}
          "${BASIS_PERL_TEMPLATES_DIR}/${MODULE}.pm"
        MODULE
          BINARY_DIRECTORY "${BINARY_CODE_DIR}"
      )
      basis_set_target_properties (
        ${PERL_UTILITIES_${MODULE}}
        PROPERTIES
          OUTPUT_NAME "${MODULE}"
          SUFFIX      ".pm"
      )
    endforeach ()
    # dependencies
    foreach (MODULE StdAux ExecutableTargetInfo)
      basis_get_source_target_name (PERL_UTILITIES_${MODULE} "${MODULE}.pm" NAME)
      basis_add_dependencies (${PERL_UTILITIES_Basis} ${PERL_UTILITIES_${MODULE}})
    endforeach ()
  endif ()

  # --------------------------------------------------------------------------
  # BASH
  if (BASH)
    # utilities available?
    if (NOT UNIX)
      message (FATAL_ERROR "Package uses BASIS BASH utilities but is build"
                           " on a non-Unix system.")
    endif ()
    # add project-specific utilities
    foreach (MODULE basis stdaux)
      basis_get_source_target_name (BASH_UTILITIES_${MODULE} "${MODULE}.sh" NAME)
      basis_add_library (
        ${BASH_UTILITIES_${MODULE}}
          "${BASIS_BASH_TEMPLATES_DIR}/${MODULE}.sh"
        MODULE
          BINARY_DIRECTORY "${BINARY_CODE_DIR}"
      )
      basis_set_target_properties (
        ${BASH_UTILITIES_${MODULE}}
        PROPERTIES
          OUTPUT_NAME "${MODULE}"
          SUFFIX      ".sh"
      )
    endforeach ()
    # dependencies
    foreach (MODULE stdaux executabletargetinfo)
      basis_get_source_target_name (BASH_UTILITIES_${MODULE} "${MODULE}.sh" NAME)
      basis_add_dependencies (${BASH_UTILITIES_basis} ${BASH_UTILITIES_${MODULE}})
    endforeach ()
    foreach (MODULE core path)
      basis_get_target_uid (BASH_UTILITIES_${MODULE} "${BASIS_NAMESPACE_LOWER}.basis.${MODULE}")
      basis_add_dependencies (${BASH_UTILITIES_basis} ${BASH_UTILITIES_${MODULE}})
    endforeach ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring auxiliary modules... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Configure ExecutibleTargetInfo modules.
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

  set (CXX TRUE)
  foreach (LANG PYTHON PERL BASH)
    basis_get_project_property (${LANG} PROPERTY PROJECT_USES_${LANG}_UTILITIES)
  endforeach ()

  if (NOT CXX AND NOT PYTHON AND NOT PERL AND NOT BASH)
    return ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring ExecutableTargetInfo...")
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
  # generate source code

  set (CC)   # C++    - build tree and install tree version, constructor block
  set (PY_B) # Python - build tree version
  set (PY_I) # Python - install tree version
  set (PL_B) # Perl   - build tree version, hash entries
  set (PL_I) # Perl   - install tree version, hash entries
  set (SH_A) # BASH   - aliases
  set (SH_B) # BASH   - build tree version
  set (SH_I) # BASH   - install tree version

  if (CXX)
    set (CC            "// the following code was automatically generated by the BASIS")
    set (CC "${CC}\n    // CMake function basis_configure_ExecutableTargetInfo()")
  endif ()

  if (PYTHON)
    set (PY_B "${PY_B}    _locations = {\n")
    set (PY_I "${PY_I}    _locations = {\n")
  endif ()

  set (I 0)
  list (LENGTH EXECUTABLE_TARGETS N)
  while (I LESS N)
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

    # C++
    if (CXX)
      get_filename_component (EXEC_NAME   "${BUILD_LOCATION}"   NAME)
      get_filename_component (BUILD_DIR   "${BUILD_LOCATION}"   PATH)
      get_filename_component (INSTALL_DIR "${INSTALL_LOCATION}" PATH)

      set (CC "${CC}\n")
      set (CC "${CC}\n    // ${TARGET_UID}")
      set (CC "${CC}\n    _exec_names  [\"${ALIAS}\"] = \"${EXEC_NAME}\";")
      set (CC "${CC}\n    _build_dirs  [\"${ALIAS}\"] = \"${BUILD_DIR}\";")
      set (CC "${CC}\n    _install_dirs[\"${ALIAS}\"] = \"${INSTALL_DIR}\";")
    endif ()

    # Python
    if (PYTHON)
      set (PY_B "${PY_B}        '${ALIAS}' : '${BUILD_LOCATION_WITH_INTDIR}',\n")
      set (PY_I "${PY_I}        '${ALIAS}' : '../../${INSTALL_LOCATION_REL2PYTHON_LIBRARY}',\n")
    endif ()

    # Perl
    if (PERL)
      if (PL_B)
        set (PL_B "${PL_B},\n")
      endif ()
      set (PL_B "${PL_B}    '${ALIAS}' => '${BUILD_LOCATION_WITH_INTDIR}'")
      if (PL_I)
        set (PL_I "${PL_I},\n")
      endif ()
      set (PL_I "${PL_I}    '${ALIAS}' => '../../${INSTALL_LOCATION_REL2PERL_LIBRARY}'")
    endif ()

    # BASH
    if (BASH)
      # hash entry
      set (SH_B "${SH_B}\n    _executabletargetinfo_add '${ALIAS}' LOCATION '${BUILD_LOCATION}'")
      set (SH_I "${SH_I}\n    _executabletargetinfo_add '${ALIAS}' LOCATION '${INSTALL_LOCATION_REL2LIBRARY}'")
      # alias
      set (SH_A "${SH_A}\nalias '${ALIAS}'=`get_executable_path '${ALIAS}'`")
      # short alias (if target belongs to this project)
      if (TARGET_UID MATCHES "^${PROJECT_NAMESPACE_CMAKE_REGEX}\\.")
        basis_get_target_name (TARGET_NAME "${TARGET_UID}")
        set (SH_S "${SH_S}\nalias '${TARGET_NAME}'='${ALIAS}'")
      endif ()
    endif ()

    # next executable target
    math (EXPR I "${I} + 1")
  endwhile ()

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

  if (CXX)
    set (EXECUTABLE_TARGET_INFO "${CC}")
    configure_file (
      "${BASIS_CXX_TEMPLATES_DIR}/ExecutableTargetInfo.cxx.in"
      "${BINARY_CODE_DIR}/ExecutableTargetInfo.cxx"
      @ONLY
    )
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Python

  if (PYTHON)
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
    basis_set_target_properties (
      ${TARGET_NAME}
      PROPERTIES
        OUTPUT_NAME "executabletargetinfo"
        SUFFIX      ".py"
    )
    # dependencies
    basis_get_target_uid (TARGET_which "${BASIS_NAMESPACE_LOWER}.basis.which_py")
    basis_add_dependencies (${TARGET_NAME} ${TARGET_which})
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Perl

  if (PERL)
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
    basis_set_target_properties (
      ${TARGET_NAME}
      PROPERTIES
        OUTPUT_NAME "ExecutableTargetInfo"
        SUFFIX      ".pm"
    )
    # dependencies
    basis_get_target_uid (TARGET_which "${BASIS_NAMESPACE_LOWER}.basis.Which_pm")
    basis_add_dependencies (${TARGET_NAME} ${TARGET_which})
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # BASH

  if (BASH)
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
    basis_set_target_properties (
      ${TARGET_NAME}
      PROPERTIES
        OUTPUT_NAME "executabletargetinfo"
        SUFFIX      ".sh"
    )
  endif ()

  # --------------------------------------------------------------------------
  # done
  if (BASIS_VERBOSE)
    message (STATUS "Configuring ExecutableTargetInfo... - done")
  endif ()
endfunction ()

# ============================================================================
# deprecated "macros"
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
# @deprecated This macro should no longer be used. Instead, simply import the
#             sbia.&lt;project&gt;.basis module, e.g.,
#             "from sbia.<project> import basis".
set (BASIS_PYTHON_UTILITIES
"import os, sys
sys.path.insert(0, os.path.normpath(os.path.join(os.path.dirname(os.path.realpath(__file__)), '\@_BASIS_PYTHON_LIBRARY_DIR\@')))
sys.path.insert(0, os.path.normpath(os.path.join(os.path.dirname(os.path.realpath(__file__)), '\@PYTHON_LIBRARY_DIR\@')))
from \@PROJECT_NAMESPACE_PYTHON\@ import basis"
)

# Reduce BASIS_PYTHON_UTILITIES to single line such that resulting script
# files do not increase in line numbers. Otherwise, error messages are misleading.
string (REPLACE "\n" "; " BASIS_PYTHON_UTILITIES "${BASIS_PYTHON_UTILITIES}")

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
# @deprecated This macro should no longer be used. Instead add the code
#             "package Basis; use SBIA::<Project>::Basis qw(:everything); package main;"
#             to your script. The package instructions can be omitted if the
#             BASIS functions shall not be placed in the Basis package.
set (BASIS_PERL_UTILITIES
"use Cwd qw(realpath);
use File::Basename;
use lib realpath(dirname(realpath(__FILE__)) . '/\@_BASIS_PERL_LIBRARY_DIR\@');
use lib realpath(dirname(realpath(__FILE__)) . '/\@PERL_LIBRARY_DIR\@');
use lib dirname(realpath(__FILE__));
package Basis;
use \@PROJECT_NAMESPACE_PERL\@::Basis qw(:everything);
package main;"
)

# Reduce BASIS_PERL_UTILITIES to single line such that resulting script
# files do not increase in line numbers. Otherwise, error messages are misleading.
string (REPLACE "\n" " " BASIS_PERL_UTILITIES "${BASIS_PERL_UTILITIES}")

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
# @deprecated This macro should not be used any longer. Instead, simply add
#             the code "source ${BASIS_MODULE} || exit 1" to your script.
set (BASIS_BASH_UTILITIES
"HELP_COMMAND='\@NAME\@ (\@PROJECT_NAME\@)'
HELP_CONTACT='SBIA Group <sbia-software at uphs.upenn.edu>'
HELP_VERSION='\@PROJECT_RELEASE\@'
HELP_COPYRIGHT='Copyright (c) University of Pennsylvania. All rights reserved.\\nSee http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.'
path=\"${BASIS_BASH___FILE__}\"
i=0
cur=\"\${path}\"
while [ -h \"\${cur}\" ] && [ \$i -lt 100 ]
do  dir=`dirname -- \"\${cur}\"`
    cur=`readlink -- \"\${cur}\"`
    cur=`cd \"\${dir}\" && cd $(dirname -- \"\${cur}\") && pwd`/`basename -- \"\${cur}\"`
    (( i++ ))
done
if [ \$i -lt 100 ]; then path=\"\${cur}\"; fi
source \"$(dirname -- \"\${path}\")/\@LIBRARY_DIR\@/basis.sh\" || exit 1
unset -v i path dir cur"
)

# Reduce BASIS_BASH_UTILITIES to single line such that resulting script
# files do not increase in line numbers. Otherwise, error messages are misleading.
string (REPLACE "\n" "; " BASIS_BASH_UTILITIES "${BASIS_BASH_UTILITIES}")


## @}
# end of Doxygen group
