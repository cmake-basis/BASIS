##############################################################################
# \file  BasisCommon.cmake
# \brief Definition of common CMake functions and variables.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

if (NOT BASIS_COMMON_INCLUDED)
set (BASIS_COMMON_INCLUDED 1)


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# common CMake modules
# ============================================================================

# The CMakeParseArguments.cmake CMake module was added to CMake since version
# 2.8.4 which just recenlty was released when the following macros and
# functions were first implemented. In order to support also previous CMake
# versions, a copy of the CMakeParseArguments.cmake module was added to the
# BASIS Core CMake modules.

include ("${CMAKE_CURRENT_LIST_DIR}/CMakeParseArguments.cmake")

# ============================================================================
# common commands
# ============================================================================

find_program (BASIS_CMD_PYTHON NAMES python DOC "The Python interpreter (python).")
mark_as_advanced (BASIS_CMD_PYTHON)

# ============================================================================
# find BASIS projects
# ============================================================================

# ****************************************************************************
# \brief Convenience macro useful to find other BASIS projects.
#
# \param [in] PACKAGE Package/project name.
# \param [in] ARGN    Other arguments as accepted by CMake's find_package ().

macro (find_sbia_package PACKAGE)
  find_package ("${BASIS_CONFIG_PREFIX}${PACKAGE}" ${ARGN})
endmacro ()

# ============================================================================
# version
# ============================================================================

# *****************************************************************************
# \brief Extract version numbers from version string.
#
# \param [in]  VERSION Version string in the format "MAJOR[.MINOR[.PATCH]]".
# \param [out] MAJOR   Major version number if given or 0.
# \param [out] MINOR   Minor version number if given or 0.
# \param [out] PATCH   Patch number if given or 0.

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
# list / string manipulations
# ============================================================================

# ****************************************************************************
# \brief Concatenates all list elements into a single string.
#
# \param [out] STR  Output string.
# \param [in]  ARGN Input list.

function (basis_list_to_string STR)
  set (OUT)
  foreach (ELEM ${ARGN})
    set (OUT "${OUT}${ELEM}")
  endforeach ()
  set ("${STR}" "${OUT}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# name <=> UID
# ============================================================================

# ----------------------------------------------------------------------------
# target name <=> target UID
# ----------------------------------------------------------------------------

# ****************************************************************************
# \brief Get "global" target name, i.e., actual CMake target name.
#
# In order to ensure that CMake target names are unique across BASIS projects,
# the target name used by a developer of a BASIS project is converted by this
# function into another target name which is used as acutal CMake target name.
#
# The function basis_target_name () can be used to convert the unique target
# name, the target UID, back to the original target name passed to this
# function.
#
# \see basis_target_name ()
#
# \param [out] TARGET_UID  "Global" target name, i.e., actual CMake target name.
# \param [in]  TARGET_NAME Target name used as argument to BASIS CMake functions.

function (basis_target_uid TARGET_UID TARGET_NAME)
  if (NOT IS_SUBPROJECT OR TARGET_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    set ("${TARGET_UID}" "${TARGET_NAME}" PARENT_SCOPE)
  else ()
    set ("${TARGET_UID}" "${PROJECT_NAME}${BASIS_NAMESPACE_SEPARATOR}${TARGET_NAME}" PARENT_SCOPE)
  endif ()
endfunction ()

# ****************************************************************************
# \brief Get "local" target name, i.e., BASIS target name.
#
# \see basis_target_uid ()
#
# \param [out] TARGET_NAME Target name used as argument to BASIS functions.
# \param [in]  TARGET_UID  "Global" target name, i.e., actual CMake target name.

function (basis_target_name TARGET_NAME TARGET_UID)
  string (REGEX REPLACE "^.*${BASIS_NAMESPACE_SEPARATOR}" "" TMP "${TARGET_UID}")
  set ("${TARGET_NAME}" "${TMP}" PARENT_SCOPE)
endfunction ()

# ****************************************************************************
# \brief Checks whether a given name is a valid target name.
#
# Displays fatal error message when target name is invalid.
#
# \param [in] TARGET_NAME Desired target name.

function (basis_check_target_name TARGET_NAME)
  # reserved target name ?
  list (FIND BASIS_RESERVED_TARGET_NAMES "${TARGET_NAME}" IDX)
  if (NOT IDX EQUAL -1)
    message (FATAL_ERROR "Target name ${TARGET_NAME} is reserved and cannot be used.")
  endif ()

  if (TARGET_NAME MATCHES "\\+$")
    message (FATAL_ERROR "Target names may not end with + as these special"
                         " targets are used internally by the BASIS CMake functions.")
  endif ()

  # invalid target name ?
  if (TARGET_NAME MATCHES " ")
    message (FATAL_ERROR "Target name ${TARGET_NAME} is invalid. Target names cannot contain whitespaces.")
  endif ()

  if (TARGET_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}|${BASIS_VERSION_SEPARATOR}")
    message (FATAL_ERROR "Target name ${TARGET_NAME} is invalid. Target names cannot"
                         " contain special characters '${BASIS_NAMESPACE_SEPARATOR}'"
                         " and '${BASIS_VERSION_SEPARATOR}'.")
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

# ****************************************************************************
# \brief Get "global" test name, i.e., actual CTest test name.
#
# In order to ensure that CTest test names are unique across BASIS projects,
# the test name used by a developer of a BASIS project is converted by this
# function into another test name which is used as acutal CTest test name.
#
# The function basis_test_name () can be used to convert the unique test
# name, the test UID, back to the original test name passed to this function.
#
# \see basis_test_name ()
#
# \param [out] TEST_UID  "Global" test name, i.e., actual CTest test name.
# \param [in]  TEST_NAME Test name used as argument to BASIS CMake functions.

function (basis_test_uid TEST_UID TEST_NAME)
  if (NOT IS_SUBPROJECT OR TEST_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}")
    set ("${TEST_UID}" "${TEST_NAME}" PARENT_SCOPE)
  else ()
    set ("${TEST_UID}" "${PROJECT_NAME}${BASIS_NAMESPACE_SEPARATOR}${TEST_NAME}" PARENT_SCOPE)
  endif ()
endfunction ()

# ****************************************************************************
# \brief Get "local" test name, i.e., BASIS test name.
#
# \see basis_test_uid ()
#
# \param [out] TEST_NAME Test name used as argument to BASIS functions.
# \param [in]  TEST_UID  "Global" test name, i.e., actual CTest test name.

function (basis_test_name TEST_NAME TEST_UID)
  string (REGEX REPLACE "^.*${BASIS_NAMESPACE_SEPARATOR}" "" TMP "${TEST_UID}")
  set ("${TEST_NAME}" "${TMP}" PARENT_SCOPE)
endfunction ()

# ****************************************************************************
# \brief Checks whether a given name is a valid test name.
#
# Displays fatal error message when test name is invalid.
#
# \param [in] TEST_NAME Desired test name.

function (basis_check_test_name TEST_NAME)
  list (FIND BASIS_RESERVED_TEST_NAMES "${TEST_NAME}" IDX)
  if (NOT IDX EQUAL -1)
    message (FATAL_ERROR "Test name ${TEST_NAME} is reserved and cannot be used.")
  endif ()

  if (TEST_NAME MATCHES " ")
    message (FATAL_ERROR "Test name ${TEST_NAME} is invalid. Test names cannot contain whitespaces.")
  endif ()

  if (TEST_NAME MATCHES "${BASIS_NAMESPACE_SEPARATOR}|${BASIS_VERSION_SEPARATOR}")
    message (FATAL_ERROR "Test name ${TEST_NAME} is invalid. Test names cannot"
                         " contain special characters '${BASIS_NAMESPACE_SEPARATOR}'"
                         " and '${BASIS_VERSION_SEPARATOR}'.")
  endif ()
endfunction ()


endif (NOT BASIS_COMMON_INCLUDED)

