##############################################################################
# @file  glob.cmake
# @brief Glob source files and optionally compare to previous glob result.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

include ("${CMAKE_CURRENT_LIST_DIR}/CommonTools.cmake")

if (NOT EXPRESSIONS)
  message (FATAL_ERROR "Missing EXPRESSIONS argument!")
endif ()
if (NOT SOURCES_FILE)
  message (FATAL_ERROR "Missing SOURCES_FILE argument!")
endif ()

set (SOURCES)
foreach (EXPRESSION IN LISTS EXPRESSIONS)
  if (EXPRESSION MATCHES "[*][*]")
    string (REPLACE "**" "*" EXPRESSION "${EXPRESSION}")
    file (GLOB_RECURSE _SOURCES "${EXPRESSION}")
    list (APPEND SOURCES ${_SOURCES})
  elseif (EXPRESSION MATCHES "[*?]|\\[[0-9]+-[0-9]+\\]")
    file (GLOB _SOURCES "${EXPRESSION}")
    list (APPEND SOURCES ${_SOURCES})
  else ()
    list (APPEND SOURCES "${EXPRESSION}")
  endif ()
endforeach ()
if (SOURCES)
  list (REMOVE_DUPLICATES SOURCES)
endif ()

set (_SOURCES)
foreach (SOURCE IN LISTS SOURCES)
  get_filename_component (SOURCE_NAME "${SOURCE}" NAME)
  if (NOT SOURCE MATCHES "(^|/).(svn|git)/" AND NOT SOURCE_NAME MATCHES "^\\.")
    list (APPEND _SOURCES "${SOURCE}")
  endif ()
endforeach ()
set (SOURCES ${_SOURCES})
unset (_SOURCES)

if (INIT)
  basis_write_list ("${SOURCES_FILE}" INITIAL_SOURCES ${SOURCES})
else ()
  include ("${SOURCES_FILE}")
  if (NOT "${SOURCES}" STREQUAL "${INITIAL_SOURCES}")
    # touching this file which is included by basis_add_glob_target()
    # re-triggers CMake upon the next build
    execute_process (COMMAND "${CMAKE_COMMAND}" -E touch "${SOURCES_FILE}")
    message (FATAL_ERROR "${ERRORMSG}")
  endif ()
endif ()
