# ============================================================================
# Copyright (c) <copyright>
# All rights reserved.
#
# <license>
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Root build configuration file.
#
# @note This package utilizes <a href="http://opensource.andreasschuh.com/cmake-basis">CMake BASIS</a>.
#
##############################################################################

# ----------------------------------------------------------------------------
# minimum required CMake version
cmake_minimum_required (VERSION 2.8.4)

# ----------------------------------------------------------------------------
# auxiliary function used to bootstrap CMake BASIS if not available
function (basis_bootstrap OPTION_NAME BASIS_VERSION)
  if (NOT OPTION_NAME STREQUAL "VERSION")
    message ("Expected VERSION as first argument of basis_bootstrap")
  endif ()

  set (DOWNLOAD_PATH    "${CMAKE_CURRENT_BINARY_DIR}")
  if (WIN32)
    set (BASIS_ARCHIVE "cmake-basis-${BASIS_VERSION}.zip")
  else ()
    set (BASIS_ARCHIVE "cmake-basis-${BASIS_VERSION}.tar.gz")
  endif ()
  set (BASIS_URL        "http://opensource.andreasschuh.com/cmake-basis/_downloads/${BASIS_ARCHIVE}")
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
        file (DOWNLOAD "${BASIS_URL}" "${DOWNLOAD_PATH}/${BASIS_ARCHIVE}" STATUS RETVAL)
        list (GET RETVAL 1 ERRMSG)
        list (GET RETVAL 0 RETVAL)
        if (NOT RETVAL EQUAL 0)
          message (FATAL_ERROR "Failed to download CMake BASIS v${BASIS_VERSION} from\n"
                               "\t${BASIS_URL}\n"
                               "Error: ${ERRMSG}\n"
                               "Either try again or follow the instructions at\n"
                               "\thttp://opensource.andreasschuh.com/cmake-basis/\n"
                               "to download and install it manually before configuring this project.")
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
    execute_process (
      COMMAND "${CMAKE_COMMAND}"
                  -DCMAKE_INSTALL_PREFIX=${BASIS_INSTALL_PREFIX}
                  "${BASIS_SOURCE_DIR}"
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

# ----------------------------------------------------------------------------
# include BASIS policies, settings, macros, and functions

# circumvent issue with CMake's find_package() interpreting these variables
# relative to the current binary directory instead of the top-level directory
if (BASIS_DIR AND NOT IS_ABSOLUTE "${BASIS_DIR}")
  set (BASIS_DIR "${CMAKE_BINARY_DIR}/${BASIS_DIR}")
  get_filename_component (BASIS_DIR "${BASIS_DIR}" ABSOLUTE)
endif ()

# users tend to specify the directory where BASIS was installed
# rather than the directory containing a BASISConfig.cmake,
# so add a workaround to allow that to work as well
if (IS_DIRECTORY "${BASIS_DIR}")
  list (INSERT CMAKE_PREFIX_PATH 0 "${BASIS_DIR}")
endif ()

# look for an existing CMake BASIS installation and use it if found
# otherwise, attempt to download and install it locally
find_package (BASIS QUIET)
if (NOT BASIS_FOUND)
  # download and install BASIS in build tree of project
  basis_bootstrap (VERSION 3.0.0)
  # look for local installation
  find_package (BASIS QUIET)
  if (NOT BASIS_FOUND)
    message (FATAL_ERROR "CMake BASIS setup failed. Please take the following steps:\n"
                         "\t1. Clear the CMake cache and try from scratch\n"
                         "\t2. Check the CMake BASIS website:\n"
                         "\t\thttp://opensource.andreasschuh.com/cmake-basis/\n"
                         "\t3. Search for an existing issue:\n"
                         "\t\thttps://github.com/schuhschuh/cmake-basis/issues/\n"
                         "\t4. If this did not resolve the issue, please report your problem:\n"
                         "\t\thttps://github.com/schuhschuh/cmake-basis/issues/new\n"
                         "\t5. Try a manual build of CMake BASIS following the instructions at:\n"
                         "\t\thttp://opensource.andreasschuh.com/cmake-basis/quickstart.html"
    )
  endif ()
else ()
  set (BASIS_INSTALL_PREFIX "${BASIS_DIR}")
endif ()

# ----------------------------------------------------------------------------
# configure build system
basis_project_impl ()

# raise error if project uses the BASIS Utilities,
# but BASIS was not installed as part of the bootstrapping
if (NOT BASIS_INSTALL_PREFIX)
  basis_get_project_uses_utilities (PROJECT_USES_BASIS_UTILITIES)
  if (PROJECT_USES_BASIS_UTILITIES)
    set (BASIS_INSTALL_PREFIX "" CACHE PATH "Installation prefix for CMake BASIS." FORCE)
    message (FATAL_ERROR "This project uses the BASIS Utilities. Therefore CMake BASIS"
                         " must be installed permanently. Please specify the location"
                         " where to install BASIS using the BASIS_INSTALL_PREFIX"
                         " variable and re-run CMake in order to first install BASIS"
                         " and then re-configure this project to use this installation.")
  endif ()
endif ()
