#.rst
# FindJython
# ----------
#
# Find Jython components such as the interpreter.
#
# This module uses find_package to look for these components using the
# specialized Find modules named FindJythonInterp.cmake.

#=============================================================================
# Copyright 2016 Andreas Schuh <andreas.schuh.84@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

# ------------------------------------------------------------------------------
# Components to look for
set (_Jython_FIND_Interp FALSE)

if (NOT Jython_FIND_COMPONENTS)
  set (Jython_FIND_COMPONENTS Interp)
endif ()

foreach (_Jython_COMPONENT IN LISTS Jython_FIND_COMPONENTS)
  if (NOT _Jython_COMPONENT MATCHES "^(Interp)$")
    message (FATAL_ERROR "Invalid Jython COMPONENTS argument: ${_Jython_COMPONENT}")
  endif ()
  set (_Jython_FIND_${_Jython_COMPONENT} TRUE)
endforeach ()

# ------------------------------------------------------------------------------
# Verbose message
if (NOT Jython_FIND_QUIETLY)
  set(_Jython_FIND_STATUS "Looking for Jython [${Jython_FIND_COMPONENTS}]")
  if (NOT Jython_FIND_REQUIRED)
    set(_Jython_FIND_STATUS "${_Jython_FIND_STATUS} (optional)")
  endif ()
  message(STATUS "${_Jython_FIND_STATUS}...")
endif ()

# ------------------------------------------------------------------------------
# Look for Jython components
set (_Jython_REQUIRED_VARS)

if (_Jython_FIND_Interp)
  find_package (JythonInterp QUIET MODULE)
  set (Jython_Interp_FOUND ${JythonInterp_FOUND})
  list (APPEND _Jython_REQUIRED_VARS JYTHON_EXECUTABLE)
endif ()

# ------------------------------------------------------------------------------
# Handle QUIET, REQUIRED, and [EXACT] VERSION arguments and set Jython_FOUND
if (_Jython_REQUIRED_VARS)
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(Jython
    REQUIRED_VARS ${_Jython_REQUIRED_VARS}
    VERSION_VAR   JYTHON_VERSION_STRING
    HANDLE_COMPONENTS
  )
else ()
  set (Jython_FOUND 1)
  set (JYTHON_FOUND 1)
endif ()

# ------------------------------------------------------------------------------
# Verbose message
if (NOT Jython_FIND_QUIETLY)
  if (Jython_FOUND)
    if (JYTHON_VERSION_STRING)
      message(STATUS "${_Jython_FIND_STATUS}... - found v${JYTHON_VERSION_STRING}")
    else ()
      message(STATUS "${_Jython_FIND_STATUS}... - found")
    endif ()
  else ()
    message(STATUS "${_Jython_FIND_STATUS}... - not found")
  endif ()
endif ()

# ------------------------------------------------------------------------------
# Unset local variables
unset (_Jython_FIND_Interp)
unset (_Jython_FIND_STATUS)
unset (_Jython_COMPONENT)
unset (_Jython_REQUIRED_VARS)
