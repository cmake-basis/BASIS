# ============================================================================
# Copyright (c) 2014 Carnegie Mellon University
# Copyright (c) 2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  BasisBootstrapping.cmake
# @brief Auxiliary function to bootstrap the build of CMake BASIS.
##############################################################################

include (CMakeParseArguments)

# ----------------------------------------------------------------------------
function (basis_bootstrap)
  # parse arguments -- unparsed arguments are passed on to CMake using -D
  CMAKE_PARSE_ARGUMENTS (BASIS "INFORM_USER" "VERSION;DOWNLOAD_URL" "" ${ARGN})
  if (NOT BASIS_VERSION)
    message (FATAL_ERROR "No CMake BASIS version specified! Use 'VERSION 3.0.0', for example.")
  endif ()
  # abort the first time to give users a chance to specify where their
  # CMake BASIS installation is located by setting BASIS_DIR in the GUI
  if (BASIS_INFORM_USER)
    if (DEFINED BASIS_DIR AND NOT DEFINED BASIS_INSTALL_PREFIX)
      set (BASIS_INSTALL_PREFIX "" CACHE PATH "Installation prefix for CMake BASIS.")
      message (FATAL_ERROR "Could not find an existing CMake BASIS installation!\n"
                           "This project uses the CMake BASIS package for the build configuration."
                           " Next time you configure this build by running CMake again,"
                           " BASIS version ${BASIS_VERSION} will be automatically downloaded"
                           " and build as part of the build configuration of this project."
                           " If you want to install this version permanently,"
                           " specify an installation prefix for CMake BASIS using"
                           " BASIS_INSTALL_PREFIX. Otherwise, leave it blank.\n"
                           "If you installed CMake BASIS already on your system, please"
                           " specify its location by setting the BASIS_DIR variable"
                           " before you re-configure the build system of this project.\n"
                           "Visit http://opensource.andreasschuh.com/cmake-basis for"
                           " more information about the CMake BASIS package.\n")
    endif ()
  endif ()

  set (DOWNLOAD_PATH    "${CMAKE_CURRENT_BINARY_DIR}")
  if (WIN32)
    set (BASIS_ARCHIVE "cmake-basis-${BASIS_VERSION}.zip")
  else ()
    set (BASIS_ARCHIVE "cmake-basis-${BASIS_VERSION}.tar.gz")
  endif ()
  if (NOT BASIS_DOWNLOAD_URL)
    set (BASIS_DOWNLOAD_URL "http://opensource.andreasschuh.com/cmake-basis/_downloads")
  endif ()
  if (NOT BASIS_DOWNLOAD_URL MATCHES "\\.(zip|tar\\.gz)$")
    set (BASIS_DOWNLOAD_URL "${BASIS_DOWNLOAD_URL}/${BASIS_ARCHIVE}")
  endif ()
  set (BASIS_SOURCE_DIR "${DOWNLOAD_PATH}/cmake-basis-${BASIS_VERSION}")
  set (BASIS_BINARY_DIR "${DOWNLOAD_PATH}/cmake-basis-${BASIS_VERSION}/build")

  # bootstrap BASIS build/installation only if not done before
  # or when BASIS_INSTALL_PREFIX has changed
  if (   NOT IS_DIRECTORY "${BASIS_BINARY_DIR}"
      OR NOT DEFINED BASIS_INSTALL_PREFIX_CONFIGURED
      OR NOT BASIS_INSTALL_PREFIX_CONFIGURED STREQUAL "${BASIS_INSTALL_PREFIX}")

    # download and extract source code if not done before
    if (NOT EXISTS "${BASIS_SOURCE_DIR}/BasisProject.cmake")
      # download source code distribution package
      if (NOT EXISTS "${DOWNLOAD_PATH}/${BASIS_ARCHIVE}")
        message (STATUS "Downloading CMake BASIS v${BASIS_VERSION}...")
        file (DOWNLOAD "${BASIS_DOWNLOAD_URL}" "${DOWNLOAD_PATH}/${BASIS_ARCHIVE}" STATUS RETVAL)
        list (GET RETVAL 1 ERRMSG)
        list (GET RETVAL 0 RETVAL)
        if (NOT RETVAL EQUAL 0)
          message (FATAL_ERROR "Failed to download CMake BASIS v${BASIS_VERSION} from\n"
                               "\t${BASIS_DOWNLOAD_URL}\n"
                               "Error: ${ERRMSG}\n"
                               "Either try again or follow the instructions at\n"
                               "\thttp://opensource.andreasschuh.com/cmake-basis/\n"
                               "to download and install it manually before configuring this project.\n")
        endif ()
        message (STATUS "Downloading CMake BASIS v${BASIS_VERSION}... - done")
      endif ()
      # extract source package
      message (STATUS "Extracting CMake BASIS...")
      execute_process (COMMAND ${CMAKE_COMMAND} -E tar -xvzf "${DOWNLOAD_PATH}/${BASIS_ARCHIVE}" RESULT_VARIABLE RETVAL)
      if (NOT RETVAL EQUAL 0)
        file (REMOVE_RECURSE "${BASIS_SOURCE_DIR}")
        message (FATAL_ERROR "Failed to extract the downloaded archive file ${DOWNLOAD_PATH}/${BASIS_ARCHIVE}!")
      endif ()
      message (STATUS "Extracting CMake BASIS... - done")
    endif ()

    # configure
    # TODO: Does this work on Windows as well ? Do we need "-G${CMAKE_GENERATOR}" ?
    file (MAKE_DIRECTORY "${BASIS_BINARY_DIR}")

    set (CMAKE_ARGUMENTS)
    if (BASIS_INSTALL_PREFIX)
      list (APPEND CMAKE_ARGUMENTS "-DCMAKE_INSTALL_PREFIX=${BASIS_INSTALL_PREFIX}")
    endif ()
    list (LENGTH BASIS_UNPARSED_ARGUMENTS N)
    while (N GREATER 0)
      list (GET BASIS_UNPARSED_ARGUMENTS 0 VARIABLE_NAME)
      list (GET BASIS_UNPARSED_ARGUMENTS 1 VARIABLE_VALUE)
      list (APPEND CMAKE_ARGUMENTS "-D${VARIABLE_NAME}=${VARIABLE_VALUE}")
      list (REMOVE_AT BASIS_UNPARSED_ARGUMENTS 0 1)
      math (EXPR N "${N} - 2")
    endwhile ()
    execute_process (
      COMMAND "${CMAKE_COMMAND}" ${CMAKE_ARGUMENTS} "${BASIS_SOURCE_DIR}"
      WORKING_DIRECTORY "${BASIS_BINARY_DIR}"
    )
    # build
    execute_process (COMMAND "${CMAKE_BUILD_TOOL}" all WORKING_DIRECTORY "${BASIS_BINARY_DIR}")
    # install
    if (BASIS_INSTALL_PREFIX)
      execute_process (COMMAND "${CMAKE_BUILD_TOOL}" install WORKING_DIRECTORY "${BASIS_BINARY_DIR}")
      set (BASIS_DIR "${BASIS_INSTALL_PREFIX}" PARENT_SCOPE)
    else ()
      set (BASIS_DIR "${BASIS_BINARY_DIR}" PARENT_SCOPE)
    endif ()

    # remember in which directory BASIS was installed to avoid re-running
    # the bootstrapping every time the project needs to be re-configured
    set (BASIS_INSTALL_PREFIX_CONFIGURED "${BASIS_INSTALL_PREFIX}" CACHE INTERNAL "" FORCE)

  elseif (BASIS_INSTALL_PREFIX_CONFIGURED)
    set (BASIS_DIR "${BASIS_INSTALL_PREFIX_CONFIGURED}" PARENT_SCOPE)
  else ()
    set (BASIS_DIR "${BASIS_BINARY_DIR}" PARENT_SCOPE)
  endif ()

endfunction (basis_bootstrap)
