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

# ============================================================================
# configuration
# ============================================================================

# include CTest module which enables testing, but prevent it from generating
# any configuration file or adding targets yet as we want to adjust the
# default CTest settings--in particular the site name--before
option (BUILD_TESTING "Enable tests." OFF)

set (RUN_FROM_DART 1)
include (CTest)

# mark timeout option as advanced
mark_as_advanced (DART_TESTING_TIMEOUT)

# remove ".local" or ".uphs.upenn.edu" suffix from site name
string (REGEX REPLACE "\\.local$|\\.uphs\\.upenn\\.edu$" "" SITE "${SITE}")

set (RUN_FROM_CTEST_OR_DART 1)
include (CTestTargets)
set (RUN_FROM_CTEST_OR_DART)

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

## @addtogroup CMakeUtilities
#  @{


# ----------------------------------------------------------------------------
## @brief Disable testing if project does not implement any tests.
#
# This function checks if there are test/ subdirectories in the project and
# disables and hides the BUILD_TESTING option if none are found.
function (basis_disable_testing_if_no_tests)
  if (IS_DIRECTORY "${PROJECT_TESTING_DIR}")
    set (DISABLE_TESTING FALSE)
  else ()
    set (DISABLE_TESTING TRUE)
  endif ()
  if (DISABLE_TESTING)
    basis_get_relative_path (TESTING_DIR "${PROJECT_SOURCE_DIR}" "${PROJECT_TESTING_DIR}")
    foreach (M IN LISTS PROJECT_MODULES_ENABLED)
      if (IS_DIRECTORY "${MODULE_${M}_SOURCE_DIR}/${TESTING_DIR}")
        set (DISABLE_TESTING FALSE)
        break ()
      endif ()
    endforeach ()
  endif ()
  if (DISABLE_TESTING)
    set_property (CACHE BUILD_TESTING PROPERTY VALUE OFF)
    set_property (CACHE BUILD_TESTING PROPERTY TYPE  INTERNAL)
  else ()
    set_property (CACHE BUILD_TESTING PROPERTY TYPE BOOL)
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Set a property of the tests.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_tests_property">
# set_tests_properties()</a> command.
#
# @param [in] ARGN List of arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_tests_property">
#                  set_tests_properties()</a>.
#
# @returns Sets the given properties of the specified test.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_tests_property
#
# @ingroup CMakeAPI
function (basis_set_tests_properties)
  set (UIDS)
  list (GET ARGN 0 ARG)
  while (ARG AND NOT ARG MATCHES "^PROPERTIES$")
    basis_get_test_uid (UID "${ARG}")
    list (APPEND UIDS "${UID}")
    list (REMOVE_AT ARGN 0)
    list (GET ARGN 0 ARG)
  endwhile ()
  set_tests_properties (${UIDS} ${ARGN})
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get a property of the test.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_test_property">
# get_test_property()</a> command.
#
# @param [out] VAR       Property value.
# @param [in]  TEST_NAME Name of test.
# @param [in]  ARGN      Remaining arguments of
#                        <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_test_property">
#                        get_test_property()</a>.
#
# @returns Sets @p VAR to the value of the requested property.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_test_property
#
# @ingroup CMakeAPI
function (basis_get_test_property VAR TEST_NAME)
  basis_get_test_uid (TEST_UID "${TEST_NAME}")
  get_test_property (VALUE "${TEST_UID}" ${ARGN})
  set (${VAR} "${VALUE}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add test.
#
# This command is used similar to CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_test">
# add_test()</a> command. It adds a test to the
# <a href="http://www.cmake.org/cmake/help/ctest-2-8-docs.html">CTest</a>-based
# testing system. Unlike CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_test">
# add_test()</a>, this command can, for convenience, implicitly add
# the necessary executable build target to the build system. Therefore,
# instead of the name of the executable command, specify the sources of the
# test implementation. An executable build target is then added by this
# function using basis_add_executable(), and the built executable is used
# as test command. If the @p UNITTEST option is given, the necessary unit
# testing libraries which are part of the BASIS installation are added as
# link dependencies as well as the default implementation of the main()
# function if none of the specified source files has the suffix
# <tt>-main</tt> or <tt>_main</tt> in the file name.
#
# @param [in] TEST_NAME Name of the test. If a source file is given
#                       as first argument, the test name is derived
#                       from the name of this source file and the source
#                       file is added to the list of sources which implement
#                       the test command.
# @param [in] ARGN      The following parameters are parsed:
# @par
# <table border="0">
#   <tr>
#     @tp @b COMMAND cmd [arg1 [arg2 ...]] @tpend
#     <td>The command to execute and optionally its arguments. Alternatively,
#         a test can be build from sources and the build executable
#         used as command. In this case, specify the sources using the
#         @p SOURCES argument. The command name @c cmd if given is used as
#         output name of the built executable. If you do not want to
#         specify the name of the output executable explicitly, but have
#         it derived from the @p TEST_NAME, do not specify the @p COMMAND
#         option and use the @p ARGS option instead to only specify the
#         arguments of the test command.</td>
#   </tr>
#   <tr>
#     @tp @b ARGS arg1 [arg2 ...] @endtp
#     <td>Arguments of the test command. If this option is given, the
#         @p COMMAND option must only have one argument, the name or path
#         of the test command.</td>
#   </tr>
#   <tr>
#     @tp @b WORKING_DIRECTORY dir @endtp
#     <td>The working directory of the test command.</td>
#   </tr>
#   <tr>
#     @tp @b CONFIGURATIONS @endtp
#     <td>If a CONFIGURATIONS option is given then the test will be executed
#         only when testing under one of the named configurations.</td>
#   </tr>
#   <tr>
#     @tp @b SOURCES file1 [file2 ...] @endtp
#     <td>The source files of the test. Use the @p UNITTEST option to specify
#         that the sources are an implementation of a unit test. In this case,
#         the default implementation of the main() function is added to the
#         build of the test executable. However, if this list contains a
#         file with the suffix <tt>-main</tt> or <tt>_main</tt> in the name,
#         the default implementation of the main() function is not used.
#         See the documentation of the @p UNITTEST option for further details.</td>
#   </tr>
#   <tr>
#     @tp @b LINK_DEPENDS file1|target1 [file2|target2 ...] @endtp
#     <td>Link dependencies of test executable build from sources.</td>
#   </tr>
#   <tr>
#     @tp @b NO_DEFAULT_MAIN @endtp
#     <td>Force that the implementation of the default main() function
#         is not added to unit tests even if neither of the given source
#         files has the suffix <tt>-main</tt> or <tt>_main</tt> in the
#         file name.</td>
#   </tr>
#   <tr>
#     @tp @b UNITTEST @endtp
#     <td>Specifies that the test is a unit test. In this case, the test
#         implementation is linked to the default unit testing framework
#         for the used programming language which is part of the BASIS
#         installation.</td>
#   </tr>
#   <tr>
#     @tp @b WITH_EXT @endtp
#     <td>Do not strip extension if test name is derived from source file name.</td>
#   </tr>
#   <tr>
#     @tp @b ARGN @endtp
#     <td>All other arguments are passed on to basis_add_executable() if
#         an executable target for the test is added.</td>
#   </tr>
# </table>
#
# @returns Adds build target for test executable if test source files
#          are given and/or adds a CTest test which executes the given
#          test command.
# 
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_test
#
# @todo Make use of ExternalData module to fetch remote test data.
#
# @ingroup CMakeAPI
function (basis_add_test TEST_NAME)
  basis_sanitize_for_regex (R "${PROJECT_TESTING_DIR}")
  if (NOT CMAKE_CURRENT_SOURCE_DIR MATCHES "^${R}")
    message (FATAL_ERROR "Tests can only be added inside ${PROJECT_TESTING_DIR}!")
  endif ()

  # --------------------------------------------------------------------------
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
    "UNITTEST;NO_DEFAULT_MAIN;WITH_EXT"
    "WORKING_DIRECTORY"
    "CONFIGURATIONS;SOURCES;LINK_DEPENDS;COMMAND;ARGS"
    ${ARGN}
  )

  list (LENGTH ARGN_COMMAND N)
  if (N GREATER 1)
    if (ARGN_ARGS)
      message (FATAL_ERROR "Specify test arguments using either COMMAND or ARGS option, not both!")
    endif ()
    list (GET ARGN_COMMAND 0 CMD)
    list (REMOVE_AT ARGN_COMMAND 0)
    set (ARGN_ARGS ${ARGN_COMMAND})
    set (ARGN_COMMAND "${CMD}")
  endif ()

  # --------------------------------------------------------------------------
  # test name
  if (NOT ARGN_COMMAND AND NOT ARGN_SOURCES)
    get_filename_component (ARGN_SOURCES "${TEST_NAME}" ABSOLUTE)
    if (ARGN_WITH_EXT)
      basis_get_source_target_name (TEST_NAME "${TEST_NAME}" NAME)
      list (APPEND ARGN_UNPARSED_ARGUMENTS WITH_EXT) # pass on to basis_add_executable()
    else ()
      basis_get_source_target_name (TEST_NAME "${TEST_NAME}" NAME_WE)
    endif ()
  endif ()

  basis_check_test_name ("${TEST_NAME}")
  basis_make_test_uid (TEST_UID "${TEST_NAME}")

  if (BASIS_DEBUG)
    message ("** basis_add_test():")
    message ("**   Name:      ${TEST_NAME}")
    message ("**   Command:   ${ARGN_COMMAND}")
    message ("**   Arguments: ${ARGN_ARGS}")
    message ("**   Sources:   ${ARGN_SOURCES}")
  endif ()

  # --------------------------------------------------------------------------
  # build test executable
  if (ARGN_SOURCES)
    if (ARGN_UNITTEST)
      if (BASIS_NAMESPACE)
        list (APPEND ARGN_LINK_DEPENDS "${BASIS_NAMESPACE_LOWER}.basis.testlib")
      else ()
        list (APPEND ARGN_LINK_DEPENDS "basis.testlib")
      endif ()
      list (APPEND ARGN_LINK_DEPENDS "${CMAKE_THREAD_LIBS_INIT}")
      if (NOT ARGN_NO_DEFAULT_MAIN)
        foreach (SOURCE ${ARGN_SOURCES})
          if (SOURCE MATCHES "-main\\.|_main\\.")
            set (ARGN_NO_DEFAULT_MAIN 1)
            break ()
          endif ()
        endforeach ()
      endif ()
      if (NOT ARGN_NO_DEFAULT_MAIN)
        if (BASIS_NAMESPACE)
          list (APPEND ARGN_LINK_DEPENDS "${BASIS_NAMESPACE_LOWER}.basis.testmain")
        else ()
          list (APPEND ARGN_LINK_DEPENDS "basis.testmain")
        endif ()
      endif ()
    endif ()

    basis_add_executable (${TEST_NAME} ${ARGN_SOURCES} ${ARGN_UNPARSED_ARGUMENTS})
    if (ARGN_LINK_DEPENDS)
      basis_target_link_libraries (${TEST_NAME} ${ARGN_LINK_DEPENDS})
    endif ()

    if (ARGN_COMMAND)
      basis_set_target_properties (${TEST_UID} PROPERTIES OUTPUT_NAME ${CMD})
    endif ()
    basis_get_target_location (ARGN_COMMAND "${TEST_UID}" ABSOLUTE)

    if (BASIS_DEBUG)
      message ("** Added test executable ${TEST_UID} (${TEST_NAME})")
      message ("**     Sources:           ${ARGN_SOURCES}")
      message ("**     Link dependencies: ${ARGN_LINK_DEPENDS}")
      message ("**     Options:           ${ARGN_UNPARSED_ARGUMENTS}")
      message ("**     Command:           ${ARGN_COMMAND}")
    endif ()
  endif ()

  # --------------------------------------------------------------------------
  # add test
  if (BASIS_VERBOSE)
    message (STATUS "Adding test ${TEST_UID}...")
  endif ()

  set (OPTS)
  if (ARGN_WORKING_DIRECTORY)
    list (APPEND OPTS "WORKING_DIRECTORY" "${ARGN_WORKING_DIRECTORY}")
  endif ()
  if (ARGN_CONFIGURATIONS)
    list (APPEND OPTS "CONFIGURATIONS")
    foreach (CONFIG ${ARGN_CONFIGURATIONS})
      list (APPEND OPTS "${CONFIG}")
    endforeach ()
  endif ()

  add_test (NAME ${TEST_UID} COMMAND ${ARGN_COMMAND} ${ARGN_ARGS} ${OPTS})

  if (BASIS_DEBUG)
    message ("** Added test ${TEST_UID}")
    message ("**     Command:   ${ARGN_COMMAND}")
    message ("**     Arguments: ${ARGN_ARGS}")
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Adding test ${TEST_UID}... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add tests of default options for given executable.
#
# @par Default options:
# <table border="0">
#   <tr>
#     @tp <b>--helpshort</b> @endtp
#     <td>Short help. The output has to match the regular expression
#         "[Uu]sage:\n\s*\<executable name\>", where \<executable name\>
#         is the name of the tested executable.</td>
#   </tr>
#   <tr>
#     @tp <b>--help, -h</b> @endtp
#     <td>Help screen. Simply tests if the option is accepted.</td>
#   </tr>
#   <tr>
#     @tp <b>--version</b> @endtp
#     <td>Version information. Output has to include the project version string.</td>
#   </tr>
#   <tr>
#     @tp <b>--verbose, -v</b> @endtp
#     <td>Increase verbosity of output messages. Simply tests if the option is accepted.</td>
#   </tr>
# </table>
#
# @param [in] TARGET_NAME Name of executable or script target.
#
# @returns Adds tests for the default options of the specified executable.
function (basis_add_tests_of_default_options TARGET_NAME)
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")

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

  # test option: --helpshort
  basis_add_test (${EXEC}UsageL "${EXEC_CMD}" "--helpshort")

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
# end of Doxygen group
