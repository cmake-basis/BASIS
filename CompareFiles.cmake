##############################################################################
# @file  CompareFiles.cmake
# @brief CMake script used to compare two files and delete either one they differ.
#
# A custom build command will produce an output file and is rebuild whenever
# one of its output files does not exist. Hence, we use this script to
# compare two files, in particular the list of previously configured header
# files, and if they differ, we delete the output file of a build command
# such that it regenerates the file which is out-of-date.
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

if (NOT ACTION)
  set (ACTION "none")
endif ()
if (NOT ACTION MATCHES "^(none|remove_if_different|move_if_different|copy_if_different|remove_and_error_if_different|error_if_different)$")
  message (FATAL_ERROR "Invalid action: ${ACTION}!")
endif ()
if (NOT PREFIX)
  set (PREFIX ".bak")
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
# perform action

if (ACTION MATCHES "^(copy_if_different|move_if_different)$" )
  if (OUTPUT_FILE_DIFFERS)
    execute_process (
      COMMAND "${CMAKE_COMMAND}" -E copy
        "${OUTPUT_FILE}" "${OUTPUT_FILE}${PREFIX}"
      OUTPUT_QUIET
    )
  endif ()
endif ()
if (ACTION MATCHES "move")
  if (ACTION MATCHES "if_different")
    if (OUTPUT_FILE_DIFFERS)
      file (REMOVE "${OUTPUT_FILE}")
    endif ()
  endif ()
endif ()
if (ACTION MATCHES "error")
  if (ACTION MATCHES "if_different")
    if (OUTPUT_FILE_DIFFERS)
      message (FATAL_ERROR "${ERRORMSG}")
    endif ()
  endif ()
endif ()
