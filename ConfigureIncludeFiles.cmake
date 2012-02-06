##############################################################################
# @file  ConfigureIncludeFiles.cmake
# @brief CMake script used to configure and copy the public header files.
#
# Besides configuring the files, this script optionally copies the header
# files to the build tree using the final relative path as used for the
# installation. This could be done directly during the configure step of
# CMake by code executed as part of the CMakeLists.txt files, but then
# whenever a header file is modified, CMake reconfigures the build system.
# Instead, this script is executed using execute_process() during the
# configure step of CMake and a custom build target is added which rebuilds
# whenever a header file was modified. Thus, only this script is re-executed,
# but not the entire build system re-configured.
#
# The relative path of each configured input header file in the source tree
# is appended to the output log file. This file can be used to determine
# whether a new header was added to the source tree and thus this script has
# to be re-executed.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeUtilities
##############################################################################

# ----------------------------------------------------------------------------
# requires bug fixed get_filename_component() of BASIS tools
include ("${CMAKE_CURRENT_LIST_DIR}/CommonTools.cmake")

# ----------------------------------------------------------------------------
# check arguments
if (NOT PROJECT_INCLUDE_DIRS)
  message (FATAL_ERROR "Missing argument PROJECT_INCLUDE_DIR!")
endif ()

if (NOT BINARY_INCLUDE_DIR)
  message (FATAL_ERROR "Missing argument BINARY_INCLUDE_DIR!")
endif ()

if (NOT EXTENSIONS)
  message (FATAL_ERROR "Missing argument EXTENSIONS!")
endif ()

if (NOT INCLUDE_PREFIX)
  set (INCLUDE_PREFIX "")
endif ()

if (NOT VARIABLE_NAME)
  set (VARIABLE_NAME "PUBLIC_HEADERS")
endif ()

# ----------------------------------------------------------------------------
# include file which defines CMake variables for use in .h.in files
if (INCLUDE_FILE)
  include ("${INCLUDE_FILE}")
endif ()

# ----------------------------------------------------------------------------
# configure header files
set (_CONFIGURED_HEADERS)
get_filename_component (INCLUDE_PREFIX_DIR "${INCLUDE_PREFIX}" PATH)
basis_sanitize_for_regex (INCLUDE_PREFIX_REGEX "${INCLUDE_PREFIX}")
basis_sanitize_for_regex (INCLUDE_PREFIX_DIR_REGEX "${INCLUDE_PREFIX_DIR}")
foreach (INCLUDE_DIR IN LISTS PROJECT_INCLUDE_DIRS)
  # glob header files
  set (GLOB_EXPR)
  foreach (E IN LISTS EXTENSIONS)
    list (APPEND GLOB_EXPR "${INCLUDE_DIR}/*${E}.in")
  endforeach ()
  foreach (E IN LISTS EXTENSIONS)
    list (APPEND GLOB_EXPR "${INCLUDE_DIR}/*${E}")
  endforeach ()
  file (GLOB_RECURSE _HEADERS RELATIVE "${INCLUDE_DIR}" ${GLOB_EXPR})
  # configure file if not run in PREVIEW mode which is used to determine
  # whether or not files were added/removed from the source directory
  if (NOT PREVIEW)
    foreach (HEADER IN LISTS _HEADERS)
      get_filename_component (TEMPLATE "${INCLUDE_DIR}/${HEADER}" ABSOLUTE)
      if (AUTO_PREFIX_INCLUDES)
        if (HEADER MATCHES "^${INCLUDE_PREFIX_REGEX}")
          if (HEADER MATCHES "\\.in$")
            string (REGEX REPLACE "\\.in$" "" HEADER "${HEADER}")
            set (MODE "@ONLY")
          else ()
            set (MODE "COPYONLY")
          endif ()
          configure_file (
            "${TEMPLATE}"
            "${BINARY_INCLUDE_DIR}/${HEADER}"
            ${MODE}
          )
        else ()
          get_filename_component (DIR "${HEADER}" PATH)
          if (HEADER MATCHES "\\.in$")
            get_filename_component (NAME "${HEADER}" NAME_WE)
            set (MODE "@ONLY")
          else ()
            get_filename_component (NAME "${HEADER}" NAME)
            set (MODE "COPYONLY")
          endif ()
          if (INCLUDE_PREFIX MATCHES "/$")
            configure_file (
              "${TEMPLATE}"
              "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}${DIR}/${NAME}"
              ${MODE}
            )
          else ()
            configure_file (
              "${TEMPLATE}"
              "${BINARY_INCLUDE_DIR}/${DIR}/${INCLUDE_PREFIX}${NAME}"
              ${MODE}
            )
          endif ()
        endif ()
        list (APPEND _CONFIGURED_HEADERS "${TEMPLATE}")
      else ()
        if (NOT HEADER MATCHES "^${INCLUDE_PREFIX_REGEX}")
          set (WARN TRUE)
          if (INCLUDES_CHECK_EXCLUDE)
            foreach (REGEX IN LISTS INCLUDES_CHECK_EXCLUDE)
              if (HEADER MATCHES "${REGEX}")
                set (WARN FALSE)
                break ()
              endif ()
            endforeach ()
          endif ()
          if (WARN)
            message (WARNING "Public header file ${HEADER} should have"
                             " the path prefix\n"
                             "\t${INCLUDE_DIR}/${INCLUDE_PREFIX}\n"
                             "to avoid conflicts with other projects!\n"
                             "If you were using a pre-release version of BASIS"
                             " or want BASIS to auto-prefix the path of public"
                             " header files, which requires copying them to the"
                             " build tree with the modified file path,"
                             " set BASIS_AUTO_PREFIX_INCLUDES to"
                             " TRUE in the project's Settings.cmake file.")
          endif ()
        endif ()
        if (HEADER MATCHES "\\.in$")
          string (REGEX REPLACE "\\.in$" "" HEADER "${HEADER}")
          configure_file (
            "${TEMPLATE}"
            "${BINARY_INCLUDE_DIR}/${HEADER}"
            @ONLY
          )
          list (APPEND _CONFIGURED_HEADERS "${TEMPLATE}")
        endif ()
      endif ()
    endforeach ()
  else ()
    # accumulate header files for output in ascending order later on
    foreach (HEADER IN LISTS _HEADERS)
      if (AUTO_PREFIX_INCLUDES OR HEADER MATCHES "\\.in$")
        get_filename_component (TEMPLATE "${INCLUDE_DIR}/${HEADER}" ABSOLUTE)
        list (APPEND _CONFIGURED_HEADERS "${TEMPLATE}")
      endif ()
    endforeach ()
  endif ()
endforeach ()

# ----------------------------------------------------------------------------
# write CMake script with list of public header files
if (CMAKE_FILE)
  if (_CONFIGURED_HEADERS)
    list (SORT _CONFIGURED_HEADERS) # deterministic order
  endif ()
  file (WRITE "${CMAKE_FILE}" "# Automatically generated by BASIS. Do not edit this file!\nset (${VARIABLE_NAME}\n")
  foreach (HEADER IN LISTS _CONFIGURED_HEADERS)
    file (APPEND "${CMAKE_FILE}" "  \"${HEADER}\"\n")
  endforeach ()
  file (APPEND "${CMAKE_FILE}" ")\n")
endif ()
