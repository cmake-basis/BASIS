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

# if BASIS is not found, attempt to download and install it locally
find_package (BASIS QUIET)
if (NOT BASIS_FOUND)
  set(DL_BASIS_VERSION 3.0.0)
  message (STATUS "BASIS not found! Attempting to automatically download and install BASIS v${DL_BASIS_VERSION}.\n" 
                  "Consider installing BASIS yourself by following the instructions at:\n"
                  "     http://opensource.andreasschuh.com/cmake-basis/"
  )
  set(BASIS_ZIP "v${DL_BASIS_VERSION}.zip")
  set(BASIS_URL "https://github.com/schuhschuh/cmake-basis/archive/${BASIS_ZIP}")
  set(DOWNLOAD_PATH "${CMAKE_CURRENT_BINARY_DIR}")
  set(MY_EXTRACTED_FILE "path/to/extracted/file")
  set(BASIS_DIR ${DOWNLOAD_PATH}/basis-install)
  set(BASIS_BUILD ${DOWNLOAD_PATH}/basis-build)

  file(DOWNLOAD "${BASIS_URL}" "${DOWNLOAD_PATH}/${BASIS_ZIP}" STATUS DL_STATUS)
  
  if(NOT DL_STATUS)
    message(FATAL_ERROR "Failed to download BASIS, Try again or install manually from: ${BASIS_URL}")
  endif()

  execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar -xvzf ${DOWNLOAD_PATH}/${BASIS_ZIP}
  )
  
  file(MAKE_DIRECTORY ${DOWNLOAD_PATH}/basis-build )

  execute_process(
     # TODO: may need to update this to support more platforms with something like: -G"${CMAKE_GENERATOR}"
      COMMAND ${CMAKE_COMMAND}  -DCMAKE_INSTALL_PREFIX=${BASIS_DIR} ${DOWNLOAD_PATH}/cmake-basis-${DL_BASIS_VERSION}
      WORKING_DIRECTORY ${BASIS_BUILD}
  )


  execute_process(
      # TODO: may need to update this to support more platforms
      COMMAND ${CMAKE_BUILD_TOOL} install
      WORKING_DIRECTORY ${BASIS_BUILD}
  )
  
  find_package (BASIS QUIET)

  if(NOT BASIS_FOUND)
    message(FATAL_ERROR "BASIS setup failed. Please take the following steps:"
                        "    1. Check the BASIS website:"
                        "          http://opensource.andreasschuh.com/cmake-basis/"
                        "    2. Search for an existing issues:"
                        "          https://github.com/schuhschuh/cmake-basis/issues/"
                        "    3. If 1 and 2 didn't help, please report your problem:"
                        "          https://github.com/schuhschuh/cmake-basis/issues/new"
           )
  endif()
endif ()

# ----------------------------------------------------------------------------
# configure build system
basis_project_impl ()
