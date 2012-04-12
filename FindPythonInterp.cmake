##############################################################################
# @file  FindPythonInterp.cmake
# @brief Find Python interpreter.
#
# This module finds an installed Python interpreter and determines where the
# executable is located. This code sets the following variables:
#
# @par Input variables:
# <table border="0">
#   <tr>
#     @tp @b Python_ADDITIONAL_VERSIONS @endtp
#     <td>List of additional Python versions to search for.</td>
#   </tr>
# </table>
#
# @par Output variables:
# <table border="0">
#   <tr>
#     @tp @b PythonInterp_FOUND @endtp
#     <td>Whether a Python interpreter was found.</td>
#   </tr>
#   <tr>
#     @tp @b PYTHONINTERP_FOUND @endtp
#     <td>Compatibility with official FindPythonInterp.cmake module.</td>
#   </tr>
#   <tr>
#     @tp @b PYTHON_EXECUTABLE @endtp
#     <td>Absolute path of the Python interpreter executable.</td>
#   </tr>
# </table>
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# initialization

# 1. Look for explicitly requested version.
if (_PythonInterp_FIND_VERSION)
  list (APPEND _PythonInterp_VERSIONS ${_PythonInterp_FIND_VERSION})
endif ()
# 2. Look for "python" executable without version suffix
list (APPEND _PythonInterp_VERSIONS 0.0)
# 3. Look for "python" executable with version suffix
if (NOT _PythonInterp_FIND_VERSION_EXACT)
  set (_PythonInterp_DEFAULT_VERSIONS 2.7 2.6 2.5 2.4 2.3 2.2 2.1 2.0 1.6 1.5)
  foreach (_PythonInterp_VERSION IN LISTS Python_ADDITIONAL_VERSIONS _PythonInterp_DEFAULT_VERSIONS)
    if (NOT _PythonInterp_FIND_VERSION OR NOT _PythonInterp_VERSION VERSION_LESS _PythonInterp_FIND_VERSION)
      list (APPEND _PythonInterp_VERSIONS ${_PythonInterp_VERSION})
    endif ()
  endforeach ()
endif ()

set (_PythonInterp_DOC "The Python interpreter.")

# ----------------------------------------------------------------------------
# find python interpreter
foreach (_PythonInterp_VERSION IN LISTS _PythonInterp_VERSIONS)
  if (_PythonInterp_VERSION VERSION_EQUAL 0.0)
    find_program (PYTHON_EXECUTABLE NAMES python DOC "${_PythonInterp_DOC}")
    if (PYTHON_EXECUTABLE)
      # get version of found Python interpreter
      execute_process (
        COMMAND "${PYTHON_EXECUTABLE}" --version
        ERROR_VARIABLE _PythonInterp_VERSION
        ERROR_STRIP_TRAILING_WHITESPACE
      )
      if (_PythonInterp_VERSION MATCHES "Python ([1-9][0-9]*\\.[0-9]+)\\.[0-9]")
        set (_PythonInterp_VERSION ${CMAKE_MATCH_1})
      endif ()
      # reset PYTHON_EXECUTABLE if the wrong version was found
      if (_PythonInterp_FIND_VERSION)
        if (_PythonInterp_VERSION VERSION_LESS _PythonInterp_FIND_VERSION)
          set_property (CACHE PYTHON_EXECUTABLE PROPERTY VALUE "PYTHON_EXECUTABLE-NOTFOUND")
        elseif (_PythonInterp_FIND_VERSION_EXACT AND NOT _PythonInterp_VERSION VERSION_EQUAL _PythonInterp_FIND_VERSION)
          set_property (CACHE PYTHON_EXECUTABLE PROPERTY VALUE "PYTHON_EXECUTABLE-NOTFOUND")
        endif ()
      endif ()
    endif ()
  else ()
    set (_PythonInterp_NAMES python${_PythonInterp_VERSION})
    set (_PythonInterp_PATHS)
    if (WIN32)
      list (APPEND _PythonInterp_NAMES python)
      list (APPEND _PythonInterp_PATHS PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Python\\PythonCore\\${_PythonInterp_VERSION}\\InstallPath]")
    endif ()
    find_program (
      PYTHON_EXECUTABLE
        NAMES ${_Python_NAMES}
        ${_PythonInterp_PATHS}
        DOC "${_PythonInterp_DOC}"
    )
  endif ()
  if (PYTHON_EXECUTABLE)
    set (_PythonInterp_FOUND_VERSION ${_PythonInterp_VERSION})
    break ()
  endif ()
endforeach ()

mark_as_advanced (PYTHON_EXECUTABLE)

# ----------------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set PYTHONINTERP_FOUND to TRUE if
# all listed variables are TRUE
include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (
  PythonInterp
  REQUIRED_VARS
    PYTHON_EXECUTABLE
  VERSION_VAR
    _PythonInterp_FOUND_VERSION
)

set (PythonInterp_FOUND "${PYTHONINTERP_FOUND}")
