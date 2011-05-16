##############################################################################
# \file  BasisTest.cmake
# \brief CTest configuration. Include this module instead of CTest.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

if (NOT BASIS_TEST_INCLUDED)
set (BASIS_TEST_INCLUDED 1)


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# required modules
# ============================================================================

include ("${CMAKE_CURRENT_LIST_DIR}/BasisSettings.cmake")

# ============================================================================
# directories
# ============================================================================

set (TESTING_BIN_DIR    "test/bin"    CACHE PATH "Output directory for test executables (relative to CMAKE_BINARY_DIR).")
set (TESTING_OUTPUT_DIR "test/output" CACHE PATH "Directory in which tests output generated data (relative to CMAKE_BINARY_DIR).")

# make relative paths absolute and make options advanced
foreach(P BIN OUTPUT)
  set(VAR TESTING_${P}_DIR)
  if(NOT IS_ABSOLUTE "${${VAR}}")
    set(${VAR} "${PROJECT_BINARY_DIR}/${${VAR}}")
  endif()
  mark_as_advanced ("${VAR}")
endforeach()

# ============================================================================
# configuration
# ============================================================================

# include CTest module which enables testing
include (CTest)

mark_as_advanced (DART_TESTING_TIMEOUT)

if (NOT PROJECT_TESTING_DIR)
  set (PROJECT_TESTING_DIR "${CMAKE_CURRENT_SOURCE_DIR}/test")
endif ()

if (NOT EXISTS "${PROJECT_TESTING_DIR}")
  set (BUILD_TESTING "OFF" CACHE INTERNAL "No testing tree to build." FORCE)
else ()
  set (BUILD_TESTING "ON" CACHE BOOL "Build the testing tree.")
endif ()

# configure custom CTest settings and/or copy them to binary tree
# \todo How does this go well with the superproject/subproject concept?
if ("${PROJECT_BINARY_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
  set (CTEST_CUSTOM_FILE "CTestCustom.cmake")
else ()
  set (CTEST_CUSTOM_FILE "CTestCustom-${PROJECT_NAME}.cmake")
endif ()

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/CTestCustom.cmake.in")
  configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/CTestCustom.cmake.in"
    "${CMAKE_BINARY_DIR}/${CTEST_CUSTOM_FILE}"
    @ONLY
  )
elseif (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/CTestCustom.cmake")
  configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/CTestCustom.cmake"
    "${CMAKE_BINARY_DIR}/${CTEST_CUSTOM_FILE}"
    COPYONLY
  )
endif ()

if (
      NOT "${CTEST_CUSTOM_FILE}" STREQUAL "CTestCustom.cmake"
  AND EXISTS "${CMAKE_BINARY_DIR}/${CTEST_CUSTOM_FILE}"
)
  file (
    APPEND "${CMAKE_BINARY_DIR}/CTestCustom.cmake"
      "\ninclude (\"${CMAKE_BINARY_DIR}/${CTEST_CUSTOM_FILE}\")\n")
endif ()

# ============================================================================
# utilities
# ============================================================================

# ****************************************************************************
# \brief Replaces CMake's set_tests_properties () command.

function (basis_set_tests_properties)
  set (UIDS)
  list (GET ARGN 0 ARG)
  while (ARG AND NOT ARG STREQUAL "PROPERTIES")
    basis_test_uid (UID "${ARG}")
    list (APPEND UIDS "${UID}")
    list (REMOVE_AT ARGN 0)
    list (GET ARGN 0 ARG)
  endwhile ()
  set_tests_properties (${UIDS} ${ARGN})
endfunction ()

# ****************************************************************************
# \brief Replaces CMake's get_test_property () command.

function (basis_get_test_property VAR TEST_NAME)
  basis_test_uid (TEST_UID "${TEST_NAME}")
  get_test_property (VALUE "${TEST_UID}" ${ARGN})
  set (${VAR} "${VALUE}" PARENT_SCOPE)
endfunction ()

# ****************************************************************************
# \brief Add test.
#
# \param [in] TEST_NAME Name of the test.
# \param [in] ARGN      Parameters passed to add_test () (excluding test name).

function (basis_add_test TEST_NAME)
  basis_check_test_name ("${TEST_NAME}")
  basis_test_uid (TEST_UID "${TEST_NAME}")

  message (STATUS "Adding test ${TEST_UID}...")

  add_test (${TEST_UID} ${ARGN})

  message (STATUS "Adding test ${TEST_UID}... - done")
endfunction ()

# ****************************************************************************
# \function basis_add_tests_of_default_options
# \brief    Adds tests of default options for given executable (or script).
#
# \param [in] TARGET_NAME Name of executable or script target.

function (basis_add_tests_of_default_options TARGET_NAME)
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  if (BASIS_VERBOSE)
    message (STATUS "Adding tests of default options for ${TARGET_UID}...")
  endif ()

  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown target ${TARGET_UID}.")
  endif ()

  # get executable name
  get_target_property (PREFIX      ${TARGET_UID} "PREFIX")
  get_target_property (OUTPUT_NAME ${TARGET_UID} "OUTPUT_NAME")
  get_target_property (SUFFIX      ${TARGET_UID} "SUFFIX")

  if (NOT OUTPUT_NAME)
    set (EXEC_NAME "${TARGET_UID}")
  endif ()
  if (PREFIX)
    set (EXEC_NAME "${PREFIX}${EXEC_NAME}")
  endif ()
  if (SUFFIX)
    set (EXEC_NAME "${EXEC_NAME}${SUFFIX}")
  endif ()

  # get absolute path to executable
  get_target_property (EXEC_DIR ${TARGET_UID} "RUNTIME_OUTPUT_DIRECTORY")

  # executable command
  set (EXEC_CMD "${EXEC_DIR}/${EXEC_NAME}")

  # test option: -v
  basis_add_test (${EXEC}VersionS "${EXEC_CMD}" "-v")

  set_tests_properties (
    ${EXEC}VersionS
    PROPERTIES
      PASS_REGULAR_EXPRESSION "${EXEC} ${PROJECT_VERSION}"
  )

  # test option: --version
  basis_add_test (${EXEC}VersionL "${EXEC_CMD}" "--version")

  set_tests_properties (
    ${EXEC}VersionL
    PROPERTIES
      PASS_REGULAR_EXPRESSION "${EXEC} ${PROJECT_VERSION}"
  )

  # test option: -h
  basis_add_test (${EXEC}HelpS "${EXEC_CMD}" "-h")

  # test option: --help
  basis_add_test (${EXEC}HelpL "${EXEC_CMD}" "--help")

  # test option: -u
  basis_add_test (${EXEC}UsageS "${EXEC_CMD}" "-u")

  set_tests_properties (
    ${EXEC}UsageS
    PROPERTIES
      PASS_REGULAR_EXPRESSION "[Uu]sage:(\n)( )*${EXEC_NAME}"
  )

  # test option: --usage
  basis_add_test (${EXEC}UsageL "${EXEC_CMD}" "--usage")

  set_tests_properties (
    ${EXEC}UsageL
    PROPERTIES
      PASS_REGULAR_EXPRESSION "[Uu]sage:(\n)( )*${EXEC_NAME}"
  )

  if (BASIS_VERBOSE)
    message (STATUS "Adding tests of default options for ${EXEC}... - done")
  endif ()
endfunction ()


endif (NOT BASIS_TEST_INCLUDED)

