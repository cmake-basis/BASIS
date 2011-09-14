##############################################################################
# @file  CommonTools.cmake
# @brief Definition of common CMake functions.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_COMMONTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_COMMONTOOLS_INCLUDED TRUE)
endif ()


# ============================================================================
# common commands
# ============================================================================

## @addtogroup CMakeUtilities
#  @{

## @brief The Python interpreter.
find_program (BASIS_CMD_PYTHON NAMES python DOC "The Python interpreter (python).")
mark_as_advanced (BASIS_CMD_PYTHON)

## @}

## @addtogroup CMakeAPI
#  @{

# ============================================================================
# find BASIS projects
# ============================================================================

##############################################################################
# @brief Convenience macro useful to find other BASIS projects.
#
# @param [in] PACKAGE Package/project name.
# @param [in] ARGN    Other arguments as accepted by CMake's find_package().
#
# @returns The package specific variables are either set by the invoked
#          CMake Find module or the package's CMake configuration file.
#
# @retval <PACKAGE>_FOUND Whether the given package was found.

macro (find_basis_package PACKAGE)
  find_package ("${BASIS_CONFIG_PREFIX}${PACKAGE}" ${ARGN})
endmacro ()

# ============================================================================
# get_filename_component
# ============================================================================

##############################################################################
# @brief Replaces CMake's get_filename_component() command to fix a bug.
#
# The get_filename_component() command of CMake returns the entire portion
# after the first period (.) [including the period] as extension. However,
# only the component following the last period (.) [including the period]
# should be considered to be the extension.
#
# @param [in,out] ARGN Arguments as accepted by get_filename_component().
#
# @returns Sets the variable named by the first argument to the requested
#          component of the given file path.

function (get_filename_component)
  _get_filename_component (${ARGN})
  list (GET ARGN 0 VAR)
  list (GET ARGN 2 CMD)
  if (${CMD} STREQUAL "EXT")
    string (REGEX MATCHALL "\\.[^.]*" PARTS "${${VAR}}")
    list (LENGTH PARTS LEN)
    if (LEN GREATER 1)
      math (EXPR LEN "${LEN} - 1")
      list (GET PARTS ${LEN} ${VAR})
    endif ()
  else ()
  endif ()
  set (${VAR} "${${VAR}}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# version
# ============================================================================

##############################################################################
# @brief Extract version numbers from version string.
#
# @param [in]  VERSION Version string in the format "MAJOR[.MINOR[.PATCH]]".
# @param [out] MAJOR   Major version number if given or 0.
# @param [out] MINOR   Minor version number if given or 0.
# @param [out] PATCH   Patch number if given or 0.
#
# @returns See @c [out] parameters.

function (basis_version_numbers VERSION MAJOR MINOR PATCH)
  string (REGEX MATCHALL "[0-9]+" VERSION_PARTS "${VERSION}")
  list (LENGTH VERSION_PARTS VERSION_COUNT)

  if (VERSION_COUNT GREATER 0)
    list (GET VERSION_PARTS 0 VERSION_MAJOR)
  else ()
    set (VERSION_MAJOR "0")
  endif ()
  if (VERSION_COUNT GREATER 1)
    list (GET VERSION_PARTS 1 VERSION_MINOR)
  else ()
    set (VERSION_MINOR "0")
  endif ()
  if (VERSION_COUNT GREATER 2)
    list (GET VERSION_PARTS 2 VERSION_PATCH)
  else ()
    set (VERSION_PATCH "0")
  endif ()

  set ("${MAJOR}" "${VERSION_MAJOR}" PARENT_SCOPE)
  set ("${MINOR}" "${VERSION_MINOR}" PARENT_SCOPE)
  set ("${PATCH}" "${VERSION_PATCH}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# set
# ============================================================================

##############################################################################
# @brief Set value of variable only if variable is not set already.
#
# @param [out] VAR  Name of variable.
# @param [in]  ARGN Arguments to set() command excluding variable name.
#
# @returns Sets @p VAR if it's value was not valid before.

function (basis_set_if_empty VAR)
  if (NOT ${VAR})
    set (${VAR} ${ARGN})
  endif ()
endfunction ()

##############################################################################
# @brief Set value of variable used in \<project\>Config.cmake of install tree.
#
# This function sets the value of a variable VAR to
# "\${CMAKE_CURRENT_LIST_DIR}/\<path\>", where \<path\> is the relative path
# to the file or directory specified by INSTALL_PATH relative to
# INSTALL_CONFIG_DIR.
#
# @param [out] VAR  Name of variable. Used in template of
#                   \<package\>Config.cmake as \@VAR\@.
# @param [in]  PATH Path of variable relative to CMAKE_INSTALL_PREFIX.
#
# @returns Sets @p VAR to the determined relative path.

function (basis_set_config_path VAR PATH)
  file (
    RELATIVE_PATH
      ${VAR}
      "${CMAKE_INSTALL_PREFIX}/${INSTALL_CONFIG_DIR}"
      "${CMAKE_INSTALL_PREFIX}/${PATH}"
  )
  string (REGEX REPLACE "/$" "" ${VAR} "${${VAR}}")

  set (${VAR} "\${CMAKE_CURRENT_LIST_DIR}/${${VAR}}" PARENT_SCOPE)
endfunction ()
 
##############################################################################
# @brief Generate definition of the basis_set_script_path() function.
#
# This macro generates the definition of the basis_set_script_path()
# function, the definition of which is evaluated during the build step of
# scripts before the inclusion of the script configuration. Hence,
# basis_set_script_path() can be used in script configuration files. This
# function takes a variable name and a path as input arguments. If the given
# path is relative, it makes it first absolute using PROJECT_SOURCE_DIR. Then
# the path is made relative to the directory of the built script file. A CMake
# variable of the given name is set to the specified relative path. Optionally,
# a third argument, the path used for building the script for the install tree
# can be passed as well. If a relative path is given as this argument, it is
# made absolute by prefixing it with CMAKE_INSTALL_PREFIX instead.
#
# @param [out] FUNC The generated basis_set_script_path() function definition.
#
# @returns Sets @p FUNC to the definition of the function basis_set_script_path().
#
# @par Parameters of function basis_set_script_path():
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b VAR</td>
#     <td>Name of the variable.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b PATH</td>
#     <td>Path to directory or file.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b ARG3</td>
#     <td>Path to directory or file inside install tree.
#         If this argument is not given, PATH is used for both
#         the build and install tree version of the script.</td>
#   </tr>
# </table>

macro (basis_set_script_path_definition FUNC)
  set (${FUNC} "function (basis_set_script_path VAR PATH)
  if (ARGC GREATER 3)
    message (FATAL_ERROR \"Too many arguments given for function basis_set_script_path ()\")
  endif ()

  if (ARGC EQUAL 3 AND BUILD_INSTALL_SCRIPT)
    set (PREFIX \"@CMAKE_INSTALL_PREFIX@\")
    set (PATH   \"\${ARGV2}\")
  else ()
    set (PREFIX \"@PROJECT_SOURCE_DIR@\")
  endif ()

  if (NOT IS_ABSOLUTE \"\${PATH}\")
    set (PATH \"\${PREFIX}/\${PATH}\")
  endif ()

  file (RELATIVE_PATH PATH \"\${SCRIPT_DIR}\" \"\${PATH}\")

  if (NOT PATH)
    set (PATH \".\")
  endif ()

  set (\${VAR} \"\${PATH}\" PARENT_SCOPE)
endfunction ()")
endmacro ()

# ============================================================================
# set/get any property
# ============================================================================

##############################################################################
# @brief Replaces CMake's set_property() command.
#
# @param [in] SCOPE The argument for the @p SCOPE parameter of set_property().
# @param [in] ARGN  Arguments as accepted by set_property().
#
# @returns Sets the specified property.

function (basis_set_property SCOPE)
  if (SCOPE MATCHES "^TARGET$|^TEST$")
    set (IDX 0)
    foreach (ARG ${ARGN})
      if (ARG MATCHES "^APPEND$|^PROPERTY$")
        break ()
      endif ()
      if (SCOPE STREQUAL "TEST")
        basis_test_uid (UID "${ARG}")
      else ()
        basis_target_uid (UID "${ARG}")
      endif ()
      list (REMOVE_AT ARGN ${IDX})
      list (INSERT ARGN ${IDX} "${UID}")
      math (EXPR IDX "${IDX} + 1")
    endforeach ()
  endif ()
  set_property (${ARGN})
endfunction ()

##############################################################################
# @brief Replaces CMake's get_property() command.
#
# @param [out] VAR     Property value.
# @param [in]  SCOPE   The argument for the @p SCOPE argument of get_property().
# @param [in]  ELEMENT The argument for the @p ELEMENT argument of get_property().
# @param [in]  ARGN    Arguments as accepted by get_property().
#
# @returns Sets @p VAR to the value of the requested property.

function (basis_get_property VAR SCOPE ELEMENT)
  if (SCOPE STREQUAL "TARGET")
    basis_target_uid (ELEMENT "${ELEMENT}")
  elseif (SCOPE STREQUAL "TEST")
    basis_test_uid (ELEMENT "${ELEMENT}")
  endif ()
  get_property (VALUE ${SCOPE} ${ELEMENT} ${ARGN})
  set ("${VAR}" "${VALUE}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# list / string manipulations
# ============================================================================

##############################################################################
# @brief Concatenates all list elements into a single string.
#
# The list elements are concatenated without any delimiter in between.
# Use basis_list_to_delimited_string() to specify a delimiter such as a
# whitespace character or comma (,) as delimiter.
#
# @sa basis_list_to_delimited_string()
#
# @param [out] STR  Output string.
# @param [in]  ARGN Input list.
#
# @returns Sets @p STR to the resulting string.

function (basis_list_to_string STR)
  set (OUT)
  foreach (ELEM ${ARGN})
    set (OUT "${OUT}${ELEM}")
  endforeach ()
  set ("${STR}" "${OUT}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Concatenates all list elements into a single delimited string.
#
# @param [out] STR   Output string.
# @param [in]  DELIM Delimiter used to separate list elements.
#                    Each element which contains the delimiter as substring
#                    is surrounded by double quotes (") in the output string.
# @param [in]  ARGN  Input list.
#
# @returns Sets @p STR to the resulting string.

function (basis_list_to_delimited_string STR DELIM)
  set (OUT)
  foreach (ELEM ${ARGN})
    if (OUT)
      set (OUT "${OUT}${DELIM}")
    endif ()
    if (ELEM MATCHES "${DELIM}")
      set (OUT "${OUT}\"${ELEM}\"")
    else ()
      set (OUT "${OUT}${ELEM}")
    endif ()
  endforeach ()
  set ("${STR}" "${OUT}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Splits a string at space characters into a list.
#
# @todo Probably this can be done in a better way...
#       Difficulty is, that string (REPLACE) does always replace all
#       occurrences. Therefore, we need a regular expression which matches
#       the entire string. More sophisticated regular expressions should do
#       a better job, though.
#
# @param [out] LST  Output list.
# @param [in]  STR  Input string.
#
# @returns Sets @p LST to the resulting CMake list.

function (basis_string_to_list LST STR)
  set (TMP "${STR}")
  set (OUT)
  # 1. extract elements such as "a string with spaces"
  while (TMP MATCHES "\"[^\"]*\"")
    string (REGEX REPLACE "^(.*)\"([^\"]*)\"(.*)$" "\\1\\3" TMP "${TMP}")
    if (OUT)
      set (OUT "${CMAKE_MATCH_2};${OUT}")
    else (OUT)
      set (OUT "${CMAKE_MATCH_2}")
    endif ()
  endwhile ()
  # 2. extract other elements separated by spaces (excluding first and last)
  while (TMP MATCHES " [^\" ]+ ")
    string (REGEX REPLACE "^(.*) ([^\" ]+) (.*)$" "\\1\\3" TMP "${TMP}")
    if (OUT)
      set (OUT "${CMAKE_MATCH_2};${OUT}")
    else (OUT)
      set (OUT "${CMAKE_MATCH_2}")
    endif ()
  endwhile ()
  # 3. extract first and last elements (if not done yet)
  if (TMP MATCHES "^[^\" ]+")
    set (OUT "${CMAKE_MATCH_0};${OUT}")
  endif ()
  if (NOT CMAKE_MATCH_0 STREQUAL "${TMP}" AND TMP MATCHES "[^\" ]+$")
    set (OUT "${OUT};${CMAKE_MATCH_0}")
  endif ()
  # return resulting list
  set (${LST} "${OUT}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# name <=> UID
# ============================================================================

# ----------------------------------------------------------------------------
# target name <=> target UID
# ----------------------------------------------------------------------------

##############################################################################
# @brief Get "global" target name, i.e., actual CMake target name.
#
# In order to ensure that CMake target names are unique across BASIS projects,
# the target name used by a developer of a BASIS project is converted by this
# function into another target name which is used as acutal CMake target name.
#
# The function basis_target_name() can be used to convert the unique target
# name, the target UID, back to the original target name passed to this
# function.
#
# @sa basis_target_name()
#
# @param [out] TARGET_UID  "Global" target name, i.e., actual CMake target name.
# @param [in]  TARGET_NAME Target name used as argument to BASIS CMake functions.
#
# @returns Sets @p TARGET_UID to the UID of the build target @p TARGET_NAME.

function (basis_target_uid TARGET_UID TARGET_NAME)
  if (TARGET TARGET_NAME OR TARGET_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    set ("${TARGET_UID}" "${TARGET_NAME}" PARENT_SCOPE)
  else ()
    set ("${TARGET_UID}" "${PROJECT_NAME_LOWER}${BASIS_NAMESPACE_SEPARATOR}${TARGET_NAME}" PARENT_SCOPE)
  endif ()
endfunction ()

##############################################################################
# @brief Get "local" target name, i.e., BASIS target name.
#
# @sa basis_target_uid()
#
# @param [out] TARGET_NAME Target name used as argument to BASIS functions.
# @param [in]  TARGET_UID  "Global" target name, i.e., actual CMake target name.
#
# @returns Sets @p TARGET_NAME to the name of the build target with UID @p TARGET_UID.

function (basis_target_name TARGET_NAME TARGET_UID)
  string (REGEX REPLACE "^.*${BASIS_NAMESPACE_SEPARATOR}" "" TMP "${TARGET_UID}")
  set ("${TARGET_NAME}" "${TMP}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Checks whether a given name is a valid target name.
#
# Displays fatal error message when target name is invalid.
#
# @param [in] TARGET_NAME Desired target name.
#
# @returns Nothing.
#
# @ingroup CMakeUtilities

function (basis_check_target_name TARGET_NAME)
  # reserved target name ?
  list (FIND BASIS_RESERVED_TARGET_NAMES "${TARGET_NAME}" IDX)
  if (NOT IDX EQUAL -1)
    message (FATAL_ERROR "Target name \"${TARGET_NAME}\" is reserved and cannot be used.")
  endif ()

  if (TARGET_NAME MATCHES "\\+$")
    message (FATAL_ERROR "Target names may not end with + as these special"
                         " targets are used internally by the BASIS CMake functions.")
  endif ()

  # invalid target name ?
  if (TARGET_NAME MATCHES " ")
    message (FATAL_ERROR "Target name ${TARGET_NAME} is invalid. Target names cannot contain whitespaces.")
  endif ()

  if (TARGET_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    message (FATAL_ERROR "Target name ${TARGET_NAME} is invalid. Target names cannot"
                         " contain string '${BASIS_NAMESPACE_SEPARATOR}'.")
  endif ()

  # unique ?
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  if (TARGET "${TARGET_UID}")
    message (FATAL_ERROR "There exists already a target named ${TARGET_UID}."
                         " Target names must be unique.")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
# test name <=> test UID
# ----------------------------------------------------------------------------

##############################################################################
# @brief Get "global" test name, i.e., actual CTest test name.
#
# In order to ensure that CTest test names are unique across BASIS projects,
# the test name used by a developer of a BASIS project is converted by this
# function into another test name which is used as acutal CTest test name.
#
# The function basis_test_name() can be used to convert the unique test
# name, the test UID, back to the original test name passed to this function.
#
# @sa basis_test_name()
#
# @param [out] TEST_UID  "Global" test name, i.e., actual CTest test name.
# @param [in]  TEST_NAME Test name used as argument to BASIS CMake functions.
#
# @returns Sets @p TEST_UID to the UID of the test @p TEST_NAME.

function (basis_test_uid TEST_UID TEST_NAME)
  if (TEST_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    set ("${TEST_UID}" "${TEST_NAME}" PARENT_SCOPE)
  else ()
    set ("${TEST_UID}" "${PROJECT_NAME_LOWER}${BASIS_NAMESPACE_SEPARATOR}${TEST_NAME}" PARENT_SCOPE)
  endif ()
endfunction ()

##############################################################################
# @brief Get "local" test name, i.e., BASIS test name.
#
# @sa basis_test_uid()
#
# @param [out] TEST_NAME Test name used as argument to BASIS functions.
# @param [in]  TEST_UID  "Global" test name, i.e., actual CTest test name.
#
# @returns Sets @p TEST_NAME to the name of the test with UID @p TEST_UID.

function (basis_test_name TEST_NAME TEST_UID)
  string (REGEX REPLACE "^.*${BASIS_NAMESPACE_SEPARATOR}" "" TMP "${TEST_UID}")
  set ("${TEST_NAME}" "${TMP}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Checks whether a given name is a valid test name.
#
# Displays fatal error message when test name is invalid.
#
# @param [in] TEST_NAME Desired test name.
#
# @returns Nothing.
#
# @ingroup CMakeUtilities

function (basis_check_test_name TEST_NAME)
  list (FIND BASIS_RESERVED_TEST_NAMES "${TEST_NAME}" IDX)
  if (NOT IDX EQUAL -1)
    message (FATAL_ERROR "Test name \"${TEST_NAME}\" is reserved and cannot be used.")
  endif ()

  if (TEST_NAME MATCHES " ")
    message (FATAL_ERROR "Test name \"${TEST_NAME}\" is invalid. Test names cannot contain whitespaces.")
  endif ()

  if (TARGET_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    message (FATAL_ERROR "Target name ${TARGET_NAME} is invalid. Target names cannot"
                         " contain string '${BASIS_NAMESPACE_SEPARATOR}'.")
  endif ()
endfunction ()

# ============================================================================
# common target tools
# ============================================================================

##############################################################################
# @brief Get location of build target output file.
#
# This convenience function can be used to get the full path of the output
# file generated by a given build target. It is similar to the read-only
# @c LOCATION property of CMake targets and should be used instead of
# reading this porperty.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#prop_tgt:LOCATION
#
# @param [out] VAR         Path of build target output file.
# @param [in]  TARGET_NAME Name of build target.
# @param [in]  ARGV2       Which file name component of the @c LOCATION
#                          property to return. See get_filename_component().
#                          By default, the entire absolute path is returned.
#                          If POST_INSTALL_RELATIVE is given as argument,
#                          @p VAR is set to the path of the installed file
#                          relative to the installation prefix. Similarly,
#                          POST_INSTALL sets @p VAR to the absolute path
#                          of the installed file post installation.
#
# @returns Path of output file similar to @c LOCATION property of CMake targets.

function (basis_get_target_location VAR TARGET_NAME)
  basis_target_uid (TARGET_UID "${TARGET_NAME}")
  if (TARGET "${TARGET_UID}")
    get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")
    # ------------------------------------------------------------------------
    # non-custom targets
    if (BASIS_TYPE MATCHES "^(STATIC|SHARED|MODULE)_LIBRARY$|^EXECUTABLE$")
      get_target_property (LOCATION ${TARGET_UID} "LOCATION")
    # ------------------------------------------------------------------------
    # custom targets
    else ()
      get_target_property (IMPORTED ${TARGET_UID} "IMPORTED")
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # imported custom targets
      #
      # Note: This might not be required though as even custom executable
      #       and library targets can be imported using CMake's
      #       add_executable(<NAME> IMPORTED) and add_library(<NAME> <TYPE> IMPORTED)
      #       commands. Such executable can, for example, also be a BASH
      #       script built by basis_add_script().
      if (IMPORTED)
        # 1. Try IMPORTED_LOCATION_<CMAKE_BUILD_TYPE>
        string (TOUPPER "${CMAKE_BUILD_TYPE}" CONFIG)
        get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION_${CONFIG}")
        # 2. Try IMPORTED_LOCATION
        if (NOT LOCATION)
          get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION")
        endif ()
        # 3. Try any of the IMPORTED_LOCATION_<CONFIG> where <CONFIG> in list of
        #    BASIS supported configurations
        if (NOT LOCATION)
          foreach (CONFIG ${CMAKE_BUILD_CONFIGURATIONS})
            get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION_${CONFIG}")
          endforeach ()
        endif ()
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # non-imported custom targets
      else ()
        # libraries
        if (BASIS_TYPE MATCHES "LIBRARY|MEX")
          if (BASIS_TYPE MATCHES "STATIC")
            if (ARGV2 MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
              get_target_property (DIRECTORY "${TARGET_UID}" "ARCHIVE_INSTALL_DIRECTORY")
            else ()
              get_target_property (DIRECTORY "${TARGET_UID}" "ARCHIVE_OUTPUT_DIRECTORY")
            endif ()
            get_target_property (FNAME     "${TARGET_UID}" "ARCHIVE_OUTPUT_NAME")
          else ()
            if (ARGV2 MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
              get_target_property (DIRECTORY "${TARGET_UID}" "LIBRARY_INSTALL_DIRECTORY")
            else ()
              get_target_property (DIRECTORY "${TARGET_UID}" "LIBRARY_OUTPUT_DIRECTORY")
            endif ()
            get_target_property (FNAME     "${TARGET_UID}" "LIBRARY_OUTPUT_NAME")
          endif ()
        # executables
        else ()
          if (ARGV2 MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
            get_target_property (DIRECTORY "${TARGET_UID}" "RUNTIME_INSTALL_DIRECTORY")
          else ()
            get_target_property (DIRECTORY "${TARGET_UID}" "RUNTIME_OUTPUT_DIRECTORY")
          endif ()
          get_target_property (FNAME     "${TARGET_UID}" "RUNTIME_OUTPUT_NAME")
        endif ()
        if (NOT FNAME)
          get_target_property (FNAME "${TARGET_UID}" "OUTPUT_NAME")
        endif ()
        get_target_property (PREFIX "${TARGET_UID}" "PREFIX")
        get_target_property (SUFFIX "${TARGET_UID}" "SUFFIX")

        if (FNAME)
          set (TARGET_FILE "${FNAME}")
        else ()
          set (TARGET_FILE "${TARGET_NAME}")
        endif ()
        if (PREFIX)
          set (TARGET_FILE "${PREFIX}${TARGET_FILE}")
        endif ()
        if (SUFFIX)
          set (TARGET_FILE "${TARGET_FILE}${SUFFIX}")
        endif ()

        if (ARGV2 STREQUAL "POST_INSTALL")
          set (DIRECTORY "${INSTALL_PREFIX}/${DIRECTORY}")
        endif ()

        set (LOCATION "${DIRECTORY}/${TARGET_FILE}")
      endif ()
    endif ()

    if (ARGV2 AND NOT ARGV2 MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
      get_filename_component (LOCATION "${LOCATION}" "${ARGV2}")
    endif ()
  else ()
    set (LOCATION "NOTFOUND")
  endif ()
  set ("${VAR}" "${LOCATION}" PARENT_SCOPE)
endfunction ()


## @}
