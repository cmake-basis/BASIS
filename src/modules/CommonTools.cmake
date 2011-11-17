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
#
# @todo Replace by PYTHON_EXECUTABLE as set by FindPythonInterp.cmake module.
find_program (BASIS_CMD_PYTHON NAMES python DOC "The Python interpreter (python).")
mark_as_advanced (BASIS_CMD_PYTHON)

## @}
# end of Doxygen group


## @addtogroup CMakeAPI
#  @{


# ============================================================================
# find other packages
# ============================================================================

##############################################################################
# @brief Replaces CMake's find_package() command.
#
# @param [in] PACKAGE Name of other package.
# @param [in] ARGN    Optional arguments to find_package().
#
# @retval <PACKAGE>_FOUND Whether the given package was found.
macro (basis_find_package PACKAGE)
    find_package (${PACKAGE} ${ARGN})
endmacro ()

##############################################################################
# @brief Use found package.
#
# This macro includes the package's use file if the variable @c &lt;Pkg&gt;_USE_FILE
# is defined. Otherwise, it adds the include directories to the search path
# for include paths if possible. Therefore, the corresponding package
# configuration file has to set the proper CMake variables, i.e.,
# either @c &lt;Pkg&gt;_INCLUDES, @c &lt;Pkg&gt;_INCLUDE_DIRS, or @c &lt;Pkg&gt;_INCLUDE_DIR.
#
# @note As some packages still use all captial variables instead of ones
#       prefixed by a string that follows the same capitalization as the
#       package's name, this function also considers these if defined instead.
#       Hence, if @c &lt;PKG&gt;_INCLUDES is defined, but not @c &lt;Pkg&gt;_INCLUDES, it
#       is used in place of the latter.
#
# @note According to an email on the CMake mailing list, it is not a good idea
#       to use basis_link_directories() any more given that the arguments to
#       basis_target_link_libraries() are absolute paths to the library files.
#       Therefore, this code is commented and not used. It remains here as a
#       reminder only.

macro (basis_use_package PACKAGE)
  string (TOUPPER "${PACKAGE}" P)
  if (${PACKAGE}_FOUND OR ${P}_FOUND)
    if (${PACKAGE}_USE_FILE)
      include ("${${PACKAGE}_USE_FILE}")
    elseif (${P}_USE_FILE)
      include ("${${P}_USE_FILE}")
    else ()
      # include directories
      if (${PACKAGE}_INCLUDE_DIRS OR ${P}_INCLUDE_DIRS)
        if (${PACKAGE}_INCLUDE_DIRS)
          basis_include_directories (${${PACKAGE}_INCLUDE_DIRS})
        else ()
          basis_include_directories (${${P}_INCLUDE_DIRS})
        endif ()
      elseif (${PACKAGE}_INCLUDES OR ${P}_INCLUDES)
        if (${PACKAGE}_INCLUDES)
          basis_include_directories (${${PACKAGE}_INCLUDES})
        else ()
          basis_include_directories (${${P}_INCLUDES})
        endif ()
      elseif (${PACKAGE}_INCLUDE_DIR OR ${P}_INCLUDE_DIR)
        if (${PACKAGE}_INCLUDE_DIR)
          basis_include_directories (${${PACKAGE}_INCLUDE_DIR})
        else ()
          basis_include_directories (${${P}_INCLUDE_DIR})
        endif ()
            
      endif ()
    endif ()
  else ()
    message (FATAL_ERROR "Package ${PACKAGE} not found!")
  endif ()
  set (P)
endmacro ()

# ============================================================================
# basis_get_filename_component / basis_get_relative_path
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
  if (ARGC GREATER 4)
    message (FATAL_ERROR "(basis_)get_filename_component(): Too many arguments!")
  endif ()

  list (GET ARGN 0 VAR)
  list (GET ARGN 1 STR)
  list (GET ARGN 2 CMD)
  if (${CMD} STREQUAL "EXT")
    _get_filename_component (${VAR} "${STR}" ${CMD})
    string (REGEX MATCHALL "\\.[^.]*" PARTS "${${VAR}}")
    list (LENGTH PARTS LEN)
    if (LEN GREATER 1)
      math (EXPR LEN "${LEN} - 1")
      list (GET PARTS ${LEN} ${VAR})
    endif ()
  elseif (${CMD} STREQUAL "NAME_WE")
    _get_filename_component (${VAR} "${STR}" NAME)
    string (REGEX REPLACE "\\.[^.]*$" "" ${VAR} ${${VAR}})
  else ()
    _get_filename_component (${VAR} "${STR}" ${CMD})
  endif ()
  if (ARGC EQUAL 4)
    if (NOT ARGV3 STREQUAL "CACHE")
      message (FATAL_ERROR "(basis_)get_filename_component(): Invalid fourth argument: ${ARGV3}!")
    else ()
      set (${VAR} "${${VAR}}" CACHE STRING "")
    endif ()
  else ()
    set (${VAR} "${${VAR}}" PARENT_SCOPE)
  endif ()
endfunction ()

##############################################################################
# @brief Alias for the overwritten get_filename_component() function.
#
# @sa get_filename_component()

macro (basis_get_filename_component)
  get_filename_component (${ARGN})
endmacro ()

##############################################################################
# @brief Get path relative to a given base directory.
#
# This function, unless the file(RELATIVE_PATH ...) command of CMake which in
# this case returns an empty string, returns "." if @c PATH and @c BASE are
# the same directory.
#
# @param [out] REL  @c PATH relative to @c BASE.
# @param [in]  BASE Path of base directory. If a relative path is given, it
#                   is made absolute using basis_get_filename_component()
#                   with ABSOLUTE as last argument.
# @param [in]  PATH Absolute or relative path. If a relative path is given
#                   it is made absolute using basis_get_filename_component()
#                   with ABSOLUTE as last argument.
#
# @returns Sets the variable named by the first argument to the relative path.

function (basis_get_relative_path REL BASE PATH)
  basis_get_filename_component (PATH "${PATH}" ABSOLUTE)
  basis_get_filename_component (BASE "${BASE}" ABSOLUTE)
  if (NOT PATH)
    message (FATAL_ERROR "basis_get_relative_path(): No PATH given!")
  endif ()
  if (NOT BASE)
    message (FATAL_ERROR "basis_get_relative_path(): No BASE given!")
  endif ()
  file (RELATIVE_PATH P "${BASE}" "${PATH}")
  if ("${P}" STREQUAL "")
    set (P ".")
  endif ()
  set (${REL} "${P}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# name / version
# ============================================================================

##############################################################################
# @brief Convert string to lowercase only or mixed case.
#
# Strings in all uppercase or all lowercase are converted to all lowercase
# letters because these are usually used for acronymns. All other strings
# are returned unmodified with the one exception that the first letter has
# to be uppercase for mixed case strings.
#
# This function is in particular used to normalize the project name for use
# in installation directory paths and namespaces.
#
# @param [out] OUT String in CamelCase.
# @param [in]  STR String.

function (basis_normalize_name OUT STR)
  # strings in all uppercase or all lowercase such as acronymns are an
  # exception and shall be converted to all lowercase instead
  string (TOLOWER "${STR}" L)
  string (TOUPPER "${STR}" U)
  if (STR STREQUAL L OR STR STREQUAL U)
    set (${OUT} "${L}" PARENT_SCOPE)
  # change first letter to uppercase
  else ()
    string (SUBSTRING "${U}"   0  1 A)
    string (SUBSTRING "${STR}" 1 -1 B)
    set (${OUT} "${A}${B}" PARENT_SCOPE)
  endif ()
endfunction ()

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

macro (basis_set_if_empty VAR)
  if (NOT "${VAR}")
    set ("${VAR}" ${ARGN})
  endif ()
endmacro ()

##############################################################################
# @brief Set path relative to script file.
#
# This function can be used in script configurations. It takes a variable
# name and a path as input arguments. If the given path is relative, it makes
# it first absolute using @c PROJECT_SOURCE_DIR. Then the path is made
# relative to the directory of the built script file. A CMake variable of the
# given name is set to the specified relative path. Optionally, a third
# argument, the path used for building the script for the install tree
# can be passed as well. If a relative path is given as this argument,
# it is made absolute by prefixing it with @c INSTALL_PREFIX instead.
#
# @note This function can only be used in script configurations such as
#       in particular the ScriptConfig.cmake.in file. The actual definition
#       of the function is generated by basis_add_script_finalize() and added
#       to the top of the build script. The definition in CommonTools.cmake
#       is only used to include the function in the API documentation.
#
# @param [out] VAR  Name of the variable.
# @param [in]  PATH Path to directory or file.
# @param [in]  ARG3 Path to directory or file inside install tree.
#                   If this argument is not given, PATH is used for both
#                   the build and install tree version of the script.

function (basis_set_script_path VAR PATH)
  message (FATAL_ERROR "This function can only be used in ScriptConfig.cmake.in!")
endfunction ()

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

##############################################################################
# @brief Set project-global property.
#
# Set property associated with current project/module. The property is in
# fact just a cached variable whose name is prefixed by the project's name.

function (basis_set_project_property PROPERTY)
  if (ARGC GREATER 1 AND "${ARGV1}" STREQUAL "APPEND")
    basis_get_project_property (CURRENT ${PROPERTY})
    set (CURRENT "${CURRENT};")
    list (REMOVE_AT ARGN 0)
  else ()
    set (CURRENT "")
  endif ()
  if (ARGC LESS 2)
    message (FATAL_ERROR "basis_set_project_property(): Too few arguments!")
  endif ()
  set (${PROJECT_NAME}_${PROPERTY} "${CURRENT}${ARGN}" CACHE INTERNAL "" FORCE)
endfunction ()

##############################################################################
# @brief Get project-global property value.

function (basis_get_project_property PROPERTY)
  if (ARGC GREATER 2)
    message (FATAL_ERROR "basis_get_project_property(): Too many arguments!")
  endif ()
  if (ARGC EQUAL 2)
    set (VAR      ${ARGV0})
    set (PROPERTY ${ARGV1})
  else ()
    set (VAR ${PROPERTY})
  endif ()
  set (${VAR} "${${PROJECT_NAME}_${PROPERTY}}" PARENT_SCOPE)
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
# @sa BASIS_USE_TARGET_UIDS
#
# @param [out] TARGET_UID  "Global" target name, i.e., actual CMake target name.
# @param [in]  TARGET_NAME Target name used as argument to BASIS CMake functions.
#
# @returns Sets @p TARGET_UID to the UID of the build target @p TARGET_NAME.

function (basis_target_uid TARGET_UID TARGET_NAME)
  if (BASIS_USE_TARGET_UIDS)
    if (TARGET "${TARGET_NAME}" OR TARGET_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
      set ("${TARGET_UID}" "${TARGET_NAME}" PARENT_SCOPE)
    else ()
      set ("${TARGET_UID}" "${BASIS_NAMESPACE}${BASIS_NAMESPACE_SEPARATOR}${TARGET_NAME}" PARENT_SCOPE)
    endif ()
  else ()
    basis_target_namespace (TARGET_NS "${TARGET_NAME}")
    if ("${TARGET_NS}" STREQUAL "${BASIS_NAMESPACE}")
      basis_target_name (TARGET_NAME "${TARGET_NAME}")
    endif ()
    set ("${TARGET_UID}" "${TARGET_NAME}" PARENT_SCOPE)
  endif ()
endfunction ()

##############################################################################
# @brief Get namespace of build target.
#
# @param [out] TARGET_NS  Namespace part of target UID. If @p TARGET_UID is
#                         no UID, i.e., does not contain a namespace part,
#                         the namespace of this project is returned.
# @param [in]  TARGET_UID Target UID/name.
function (basis_target_namespace TARGET_NS TARGET_UID)
  if (${TARGET_UID} MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    string (REGEX REPLACE "${BASIS_NAMESPACE_SEPARATOR}.*$" "" TMP "${TARGET_UID}")
    set ("${TARGET_NS}" "${TMP}" PARENT_SCOPE)
  else ()
    set ("${TARGET_NS}" "${BASIS_NAMESPACE}" PARENT_SCOPE)
  endif ()
endfunction ()

##############################################################################
# @brief Get "local" target name, i.e., BASIS target name.
#
# @sa basis_target_uid()
# @sa BASIS_USE_TARGET_UIDS
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

  # invalid target name ?
  if (NOT TARGET_NAME MATCHES "^[a-zA-Z]([a-zA-Z0-9._+]|-)*$")
    message (FATAL_ERROR "Target name ${TARGET_NAME} is invalid.\nChoose a target name "
                         " which only contains alphanumeric characters, "
                         "'_', '-', '+', or '.', and starts with a letter.\n")
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
# @sa BASIS_USE_TARGET_UIDS
#
# @param [out] TEST_UID  "Global" test name, i.e., actual CTest test name.
# @param [in]  TEST_NAME Test name used as argument to BASIS CMake functions.
#
# @returns Sets @p TEST_UID to the UID of the test @p TEST_NAME.

function (basis_test_uid TEST_UID TEST_NAME)
  if (BASIS_USE_TARGET_UIDS)
    if (TEST_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
      set ("${TEST_UID}" "${TEST_NAME}" PARENT_SCOPE)
    else ()
      set ("${TEST_UID}" "${BASIS_NAMESPACE}${BASIS_NAMESPACE_SEPARATOR}${TEST_NAME}" PARENT_SCOPE)
    endif ()
  else ()
    basis_test_namespace (TEST_NS "${TEST_NAME}")
    if ("${TEST_NS}" STREQUAL "${BASIS_NAMESPACE}")
      basis_test_name (TEST_NAME "${TEST_NAME}")
    endif ()
    set ("${TEST_UID}" "${TEST_NAME}" PARENT_SCOPE)
  endif ()
endfunction ()

##############################################################################
# @brief Get namespace of test.
#
# @param [out] TEST_NS  Namespace part of test UID. If @p TEST_UID is
#                       no UID, i.e., does not contain a namespace part,
#                       the namespace of this project is returned.
# @param [in]  TEST_UID Test UID/name.
function (basis_test_namespace TEST_NS TEST_UID)
  if (${TEST_UID} MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    string (REGEX REPLACE "${BASIS_NAMESPACE_SEPARATOR}.*$" "" TMP "${TEST_UID}")
    set ("${TEST_NS}" "${TMP}" PARENT_SCOPE)
  else ()
    set ("${TEST_NS}" "${BASIS_NAMESPACE}" PARENT_SCOPE)
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

  if (NOT TEST_NAME MATCHES "^[a-zA-Z]([a-zA-Z0-9_+.]|-)*$")
    message (FATAL_ERROR "Test name ${TEST_NAME} is invalid.\nChoose a test name "
                         " which only contains alphanumeric characters, "
                         "'_', '-', '+', or '.', and starts with a letter.\n")
  endif ()

  if (TEST_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    message (FATAL_ERROR "Test name ${TEST_NAME} is invalid. Test names cannot"
                         " contain string '${BASIS_NAMESPACE_SEPARATOR}'.")
  endif ()
endfunction ()

# ============================================================================
# common target tools
# ============================================================================

##############################################################################
# @brief Detect programming language of given source code files.
#
# This function determines the programming language in which the given source
# code files are written. If no common programming language could be determined,
# "AMBIGUOUS" is returned. If none of the following programming languages
# could be determined, "UNKNOWN" is returned: CXX (i.e., C++), JAVA,
# JAVASCRIPT, PYTHON, PERL, BASH, MATLAB.
#
# @param [out] LANGUAGE Detected programming language.
# @param [in]  ARGN     List of source code files.
#
# @ingroup CMakeUtilities

function (basis_get_source_language LANGUAGE)
  set (LANGUAGE_OUT)
  # iterate over source files
  foreach (SOURCE_FILE ${ARGN})
    # C++
    if (SOURCE_FILE MATCHES "\\.c$|\\.cc$|\\.cpp$|\\.cxx$")
      set (LANG "CXX")
    # Java
    elseif (SOURCE_FILE MATCHES "\\.java$|\\.java\\.in$")
      set (LANG "JAVA")
    # JavaScript
    elseif (SOURCE_FILE MATCHES "\\.js$|\\.js\\.in$")
      set (LANG "JAVASCRIPT")
    # Python
    elseif (SOURCE_FILE MATCHES "\\.py$|\\.py\\.in$")
      set (LANG "PYTHON")
    # Perl
    elseif (SOURCE_FILE MATCHES "\\.pl$|\\.pl\\.in$|\\.pm$|\\.pm\\.in$|\\.t$|\\.t\\.in$")
      set (LANG "PERL")
    # BASH
    elseif (SOURCE_FILE MATCHES "\\.sh$|\\.sh\\.in$")
      set (LANG "BASH")
    # MATLAB
    elseif (SOURCE_FILE MATCHES "\\.m$")
      set (LANG "MATLAB")
    # unknown
    else ()
      set (LANGUAGE_OUT "UNKNOWN")
      break ()
    endif ()
    # detect ambiguity
    if (LANGUAGE_OUT AND NOT "${LANG}" STREQUAL "${LANGUAGE_OUT}")
      if (LANGUAGE_OUT STREQUAL "CXX" AND LANG STREQUAL "MATLAB")
        # MATLAB Compiler can handle this...
      elseif (LANGUAGE_OUT STREQUAL "MATLAB" AND LANG STREQUAL "CXX")
        # language stays MATLAB
        set (LANG "MATLAB")
      else ()
        # ambiguity
        set (LANGUAGE_OUT "AMBIGUOUS")
        break ()
      endif ()
    endif ()
    # update current language
    set (LANGUAGE_OUT "${LANG}")
  endforeach ()
  # return
  set (${LANGUAGE} "${LANGUAGE_OUT}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Configure .in source files.
#
# This function configures each source file in the given argument list with
# a .in file name suffix and stores the configured file in the build tree
# with the same relative directory as the template source file itself.
# The first argument names the CMake variable of the list of configured
# source files where each list item is the absolute file path of the
# corresponding (configured) source file.
#
# @param [out] LIST_NAME Name of output list.
# @param [in]  ARGN      These arguments are parsed and the following
#                        options recognized. All remaining arguments are
#                        considered to be source file paths.
# @par
# <table border="0">
#   <tr>
#     @tp @b BINARY_DIRECTORY @endtp
#     <td>Explicitly specify directory in build tree where configured
#         source files should be written to.</td>
#   </tr>
#   <tr>
#     @tp @b KEEP_DOT_IN_SUFFIX @endtp
#     <td>By default, after a source file with the .in extension has been
#         configured, the .in suffix is removed from the file name.
#         This can be omitted by giving this option.</td>
#   </tr>
# </table>
#
# @returns Nothing.
function (basis_configure_sources LIST_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "KEEP_DOT_IN_SUFFIX" "BINARY_DIRECTORY" "" ${ARGN})

  if (ARGN_BINARY_DIRECTORY AND NOT ARGN_BINARY_DIRECTORY MATCHES "^${PROJECT_BINARY_DIR}")
    message (FATAL_ERROR "Specified BINARY_DIRECTORY must be inside the build tree!")
  endif ()

  # configure source files
  set (CONFIGURED_SOURCES)
  foreach (SOURCE ${ARGN_UNPARSED_ARGUMENTS})
    if (SOURCE MATCHES "\\.in$")
      if (ARGN_BINARY_DIRECTORY)
        get_filename_component (SOURCE_NAME "${SOURCE}" NAME)
        set (CONFIGURED_SOURCE "${ARGN_BINARY_DIRECTORY}/${SOURCE_NAME}")
      elseif (NOT SOURCE MATCHES "^${PROJECT_SOURCE_DIR}")
        get_filename_component (SOURCE_NAME "${SOURCE}" NAME)
        set (CONFIGURED_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE_NAME}")
      else ()
        basis_get_relative_path (CONFIGURED_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}" "${SOURCE}")
        get_filename_component (CONFIGURED_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${CONFIGURED_SOURCE}" ABSOLUTE)
      endif ()
      if (NOT ARGN_KEEP_DOT_IN_SUFFIX)
        get_filename_component (CONFIGURED_SOURCE "${CONFIGURED_SOURCE}" NAME_WE)
      endif ()
      configure_file ("${SOURCE}" "${CONFIGURED_SOURCE}" @ONLY)
    else ()
      # if the source file path is relative, prefer possibly already
      # configured sources in build tree such as the test driver source file
      # created by create_test_sourcelist() or a manual use of configure_file()
      if (IS_ABSOLUTE "${SOURCE}")
        set (CONFIGURED_SOURCE "${SOURCE}")
      else ()
        if (EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}")
          set (CONFIGURED_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}")
        else ()
          get_filename_component (CONFIGURED_SOURCE "${SOURCE}" ABSOLUTE)
        endif ()
      endif ()
    endif ()
    list (APPEND CONFIGURED_SOURCES "${CONFIGURED_SOURCE}")
  endforeach ()
  # return
  set (${LIST_NAME} "${CONFIGURED_SOURCES}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Get type name of target.
#
# @param [out] TYPE        The target's type name or NOTFOUND.
# @param [in]  TARGET_NAME The name of the target.

function (basis_target_type TYPE TARGET_NAME)
  basis_target_uid (TARGET_UID "${TARGET_NAME}")
  if (TARGET ${TARGET_UID})
    get_target_property (TYPE_OUT ${TARGET_UID} "BASIS_TYPE")
    if (NOT TYPE_OUT)
      # in particular imported targets may not have a BASIS_TYPE property
      get_target_property (TYPE_OUT ${TARGET_UID} "TYPE")
    endif ()
  else ()
    message (FATAL_ERROR "basis_target_type(): Unknown target: ${TARGET_UID}!")
  endif ()
  set ("${TYPE}" "${TYPE_OUT}" PARENT_SCOPE)
endfunction ()

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
# @param [in]  PART        Which file name component of the @c LOCATION
#                          property to return. See get_filename_component().
#                          If POST_INSTALL_RELATIVE is given as argument,
#                          @p VAR is set to the path of the installed file
#                          relative to the installation prefix. Similarly,
#                          POST_INSTALL sets @p VAR to the absolute path
#                          of the installed file post installation.
#
# @returns Path of output file similar to @c LOCATION property of CMake targets.

function (basis_get_target_location VAR TARGET_NAME PART)
  basis_target_uid (TARGET_UID "${TARGET_NAME}")
  if (TARGET "${TARGET_UID}")
    basis_target_name (TARGET_NAME "${TARGET_UID}")
    basis_target_type (TYPE "${TARGET_UID}")
    get_target_property (IMPORTED ${TARGET_UID} "IMPORTED")

    # ------------------------------------------------------------------------
    # imported custom targets
    #
    # Note: This might not be required though as even custom executable
    #       and library targets can be imported using CMake's
    #       add_executable(<NAME> IMPORTED) and add_library(<NAME> <TYPE> IMPORTED)
    #       commands. Such executable can, for example, also be a BASH
    #       script built by basis_add_script().

    if (IMPORTED)

      # 1. Try IMPORTED_LOCATION_<CMAKE_BUILD_TYPE>
      string (TOUPPER "${CMAKE_BUILD_TYPE}" U)
      get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION_${U}")

      # 2. Try IMPORTED_LOCATION
      if (NOT LOCATION)
        get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION")
      endif ()

      # 3. Prefer Release over all other configurations
      if (NOT LOCATION)
        get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION_RELEASE")
      endif ()

      # 4. Try any of the IMPORTED_LOCATION_<CONFIG> where <CONFIG> in list of
      #    BASIS supported configurations
      if (NOT LOCATION)
        foreach (C ${CMAKE_CONFIGURATION_TYPES})
          string (TOUPPER "${C}" U)
          get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION_${U}")
          if (LOCATION)
            break ()
          endif ()
        endforeach ()
      endif ()

      # Make path relative to INSTALL_PREFIX if POST_INSTALL_PREFIX given
      if (LOCATION AND "${ARGV2}" STREQUAL "POST_INSTALL_RELATIVE")
        file (RELATIVE_PATH LOCATION "${INSTALL_PREFIX}" "${LOCATION}")
      endif ()

    # ------------------------------------------------------------------------
    # non-imported custom targets

    else ()

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # libraries

      if (TYPE MATCHES "LIBRARY|MEX")

        if (TYPE MATCHES "STATIC")
          if (PART MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
            get_target_property (DIRECTORY "${TARGET_UID}" "ARCHIVE_INSTALL_DIRECTORY")
          endif ()
          if (NOT DIRECTORY)
            get_target_property (DIRECTORY "${TARGET_UID}" "ARCHIVE_OUTPUT_DIRECTORY")
          endif ()
          get_target_property (FNAME     "${TARGET_UID}" "ARCHIVE_OUTPUT_NAME")
        else ()
          if (PART MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
            get_target_property (DIRECTORY "${TARGET_UID}" "LIBRARY_INSTALL_DIRECTORY")
          endif ()
          if (NOT DIRECTORY)
            get_target_property (DIRECTORY "${TARGET_UID}" "LIBRARY_OUTPUT_DIRECTORY")
          endif ()
          get_target_property (FNAME "${TARGET_UID}" "LIBRARY_OUTPUT_NAME")
        endif ()

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # executables

      else ()

        if (PART MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
          get_target_property (DIRECTORY "${TARGET_UID}" "RUNTIME_INSTALL_DIRECTORY")
        endif ()
        if (NOT DIRECTORY)
          get_target_property (DIRECTORY "${TARGET_UID}" "RUNTIME_OUTPUT_DIRECTORY")
        endif ()
        get_target_property (FNAME "${TARGET_UID}" "RUNTIME_OUTPUT_NAME")
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

      if ("${PART}" STREQUAL "POST_INSTALL")
        if (NOT IS_ABSOLUTE "${DIRECTORY}")
          set (DIRECTORY "${INSTALL_PREFIX}/${DIRECTORY}")
        endif ()
      elseif ("${PART}" STREQUAL "POST_INSTALL_RELATIVE")
        if (IS_ABSOLUTE "${DIRECTORY}")
          file (RELATIVE_PATH DIRECTORY "${INSTALL_PREFIX}" "${DIRECTORY}")
          if (NOT DIRECTORY)
            set (DIRECTORY ".")
          endif ()
        endif ()
      endif ()

      set (LOCATION "${DIRECTORY}/${TARGET_FILE}")

    endif ()

    # get filename component
    if (NOT PART MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
      get_filename_component (LOCATION "${LOCATION}" "${PART}")
    endif ()

  else ()
    message (FATAL_ERROR "basis_get_target_location(): Unknown target ${TARGET_UID}")
  endif ()

  # return
  set ("${VAR}" "${LOCATION}" PARENT_SCOPE)
endfunction ()


## @}
# end of Doxygen group
