##############################################################################
# @file  BasisTest.cmake
# @brief CTest configuration. Include this module instead of CTest.
#
# @note This module is included by basis_project_initialize().
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeAPI
##############################################################################


# get directory of this file
#
# Note: This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# configuration
# ============================================================================

# include CTest module which enables testing, but prevent it from generating
# any configuration file or adding targets yet as we want to adjust the
# default CTest settings--in particular the site name--before
set (RUN_FROM_DART 1)
include (CTest)

# mark timeout option as advanced
mark_as_advanced (DART_TESTING_TIMEOUT)

# remove ".local" or ".uphs.upenn.edu" suffix from site name
string (REGEX REPLACE "\\.local$|\\.uphs\\.upenn\\.edu$" "" SITE "${SITE}")

set (RUN_FROM_CTEST_OR_DART 1)
include (CTestTargets)
set (RUN_FROM_CTEST_OR_DART)

# disable testing if no testing sources found
if (NOT EXISTS "${PROJECT_TESTING_DIR}")
  set (BUILD_TESTING "OFF" CACHE INTERNAL "No testing tree to build." FORCE)
else ()
  set (BUILD_TESTING "ON" CACHE BOOL "Build the testing tree.")
endif ()

# configure custom CTest settings and/or copy them to binary tree
# TODO How does this go well with the super-build?
if ("${PROJECT_BINARY_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
  set (CTEST_CUSTOM_FILE "CTestCustom.cmake")
else ()
  set (CTEST_CUSTOM_FILE "CTestCustom-${PROJECT_NAME}.cmake")
endif ()

if (EXISTS "${PROJECT_CONFIG_DIR}/CTestCustom.cmake.in")
  configure_file (
    "${PROJECT_CONFIG_DIR}/CTestCustom.cmake.in"
    "${CMAKE_BINARY_DIR}/${CTEST_CUSTOM_FILE}"
    @ONLY
  )
elseif (EXISTS "${PROJECT_CONFIG_DIR}/CTestCustom.cmake")
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

## @addtogroup CMakeAPI
#  @{

##############################################################################
# @brief Replaces CMake's set_tests_properties() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_tests_property
#
# @param [in] ARGN Arguments for set_tests_property().
#
# @returns Sets the given properties of the specified test.

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

##############################################################################
# @brief Replaces CMake's get_test_property() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_test_property
#
# @param [out] VAR       Property value.
# @param [in]  TEST_NAME Name of test.
# @param [in]  ARGN      Remaining arguments of get_test_property().
#
# @returns Sets @p VAR to the value of the requested property.

function (basis_get_test_property VAR TEST_NAME)
  basis_test_uid (TEST_UID "${TEST_NAME}")
  get_test_property (VALUE "${TEST_UID}" ${ARGN})
  set (${VAR} "${VALUE}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Add test.
#
# @todo Make use of ExternalData module to fetch remote test data.
#
# @param [in] TEST_NAME Name of the test.
# @param [in] ARGN      Parameters passed to add_test() (excluding test name).
#
# @returns Adds CTest test.

function (basis_add_test TEST_NAME)
  basis_check_test_name ("${TEST_NAME}")
  basis_test_uid (TEST_UID "${TEST_NAME}")

  message (STATUS "Adding test ${TEST_UID}...")

  add_test (${TEST_UID} ${ARGN})

  message (STATUS "Adding test ${TEST_UID}... - done")
endfunction ()

##############################################################################
# @brief Add unit test.
#
# @param [in] TEST_NAME Name of the test.
# @param [in] ARGN      The following parameters are parsed:
# @par
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b LANGUAGE lang</td>
#     <td>The programming language in which both the module and unit test
#         are implemented. Defaults to CXX (i.e., C++).</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b SOURCES file1 [file2 ...]</td>
#     <td>The source files of the unit test. If this list contains a
#         file named either "*-main.*" or "*_main.*", the default
#         implementation of the main() function is not included.
#         Otherwise, the default implementation of the main() function,
#         i.e., the file test_main.cc of BASIS is added to this list.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b LINK_DEPENDS file1|target1 [file2|target2 ...]</td>
#     <td>Link dependencies.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b ARGS arg1 [arg2 ...]</td>
#     <td>Arguments passed to basis_add_test().</td>
#   </tr>
# </table>
#
# @returns Adds build target for the test executable and a CTest test
#          target which runs the built executable.

function (basis_add_unit_test TEST_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "LANGUAGE" "SOURCES;LINK_DEPENDS;ARGS" ${ARGN})

  if (NOT ARGN_LANGUAGE)
    set (ARGN_LANGUAGE "CXX")
  endif ()
  string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)

  set (DEFAULT_MAIN "1")
  foreach (SOURCE ${ARGN_SOURCES})
    if (SOURCE MATCHES "-main\\.|_main\\.")
      set (DEFAULT_MAIN "0")
    endif ()
  endforeach ()

  # build test
  if ("${ARGN_LANGUAGE}" STREQUAL "CXX")
    if (DEFAULT_MAIN)
      list (APPEND ARGN_SOURCES "${BASIS_MODULE_PATH}/test_main.cc")
    endif ()
    basis_add_executable ("${TEST_NAME}" TEST ${ARGN_SOURCES})
    basis_target_link_libraries (${TEST_NAME} "${BASIS_TEST_LIBRARY}" ${ARGN_LINK_DEPENDS})
  else ()
    message (FATAL_ERROR "Invalid unit test language: \"${ARGN_LANGUAGE}\".")
  endif ()

  # add test
  basis_get_target_property (DIR "${TEST_NAME}" RUNTIME_OUTPUT_DIRECTORY) 
  basis_add_test ("${TEST_NAME}" "${DIR}/${TEST_NAME}" ${ARGN_ARGS})
endfunction ()

##############################################################################
# @brief Add tests of default options for given executable.
#
# @par Default options:
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         <b>-u [ --usage ]</b></td>
#     <td>Usage information. The output has to match the regular expression
#         "[Uu]sage:\n\s*\<executable name\>", where \<executable name\>
#         is the name of the tested executable.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         <b>-h [ --help ]</b></td>
#     <td>Help screen. Simply tests if the option is accepted.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         <b>-V [ --version ]</b></td>
#     <td>Version information. Output has to include the project version string.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         <b>-v [ --verbose ]</b></td>
#     <td>Increase verbosity of output messages. Simply tests if the option is accepted.</td>
#   </tr>
# </table>
#
# @param [in] TARGET_NAME Name of executable or script target.
#
# @returns Adds tests for the default options of the specified executable.

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

## @}
