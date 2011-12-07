##############################################################################
# @file  CheckPublicHeaders.cmake
# @brief CMake script used to check whether public headers were added/removed.
#
# This script removes the deprecated public headers from the build tree and
# then throws a fatal error if public header files were added or removed to
# the project.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeUtilities
##############################################################################

# ----------------------------------------------------------------------------
# check arguments
if (NOT OUTPUT_FILE)
  message (FATAL_ERROR "Missing argument OUTPUT_FILE!")
endif ()

if (NOT REFERENCE_FILE)
  message (FATAL_ERROR "Missing argument REFERENCE_FILE!")
endif ()

if (NOT BINARY_INCLUDE_DIR)
  message (FATAL_ERROR "Missing argument BINARY_INCLUDE_DIR!")
endif ()

if (NOT PROJECT_INCLUDE_DIRS)
  message (FATAL_ERROR "Missing argument PROJECT_INCLUDE_DIRS!")
endif ()

if (NOT ERRORMSG)
  set (ERRORMSG "File ${OUTPUT_FILE} differs from ${REFERENCE_FILE}")
endif ()

# ----------------------------------------------------------------------------
# compare files
execute_process (
  COMMAND ${CMAKE_COMMAND} -E compare_files "${OUTPUT_FILE}" "${REFERENCE_FILE}"
  RESULT_VARIABLE EXIT_CODE
  OUTPUT_QUIET
  ERROR_QUIET
)

if (EXIT_CODE EQUAL 0)
  set (OUTPUT_FILE_DIFFERS FALSE)
else ()
  set (OUTPUT_FILE_DIFFERS TRUE)
endif ()

# ----------------------------------------------------------------------------
# remove deprecated public headers
if (OUTPUT_FILE_DIFFERS)
  set (PUBLIC_HEADERS)
  include ("${OUTPUT_FILE}")
  if (NOT PUBLIC_HEADERS)
    message (FATAL_ERROR "Expected PUBLIC_HEADERS to be set by ${OUTPUT_FILE}!")
  endif ()
  set (CURRENT_HEADERS "${PUBLIC_HEADERS}")
  include ("${REFERENCE_FILE}")
  if (NOT PUBLIC_HEADERS)
    message (FATAL_ERROR "Expected PUBLIC_HEADERS to be set by ${REFERENCE_FILE}!")
  endif ()
  foreach (H IN LISTS CURRENT_HEADERS)
    list (FIND PUBLIC_HEADERS "${H}" IDX)
    if (IDX EQUAL -1)
      foreach (D IN LISTS PROJECT_INCLUDE_DIRS)
        if (H MATCHES "^${D}")
          file (RELATIVE_PATH H "${D}" "${H}")
          break ()
        endif ()
      endforeach ()
      file (REMOVE "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}${H}")
    endif ()
  endforeach ()
endif ()

# ----------------------------------------------------------------------------
# fatal error if files added/removed
if (OUTPUT_FILE_DIFFERS)
  message (FATAL_ERROR "${ERRORMSG}")
endif ()
