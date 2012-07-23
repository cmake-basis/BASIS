##############################################################################
# @file  FindPythonModules.cmake
# @brief Find Python modules.
#
# @par Input variables:
# <table border="0">
#   <tr>
#     @tp @b PythonModules_FIND_COMPONENTS @endtp
#     <td>The @c COMPONENTS argument(s) of the find_package() command specifies
#         the names of the Python modules to look for.</td>
#   </tr>
#   <tr>
#     @tp @b PYTHON_EXECUTABLE @endtp
#     <td>Path to the Python interpreter. Should be set by first looking
#         for the Python interpreter, i.e., find_packages(PythonInterp).
#         If set, this module first tries to execute the Python interpreter,
#         import the respective Python module, and then derive the search path
#         from the @c __file__ attribute of the loaded Python module.
#         Otherwise, or if this fails, it looks either for a package
#         @c __init__.py file inside a subdirectory named after the specified
#         Python module or a @c .py module file in each directory listed in
#         the @c PYTHONPATH.</td>
#   </tr>
#   <tr>
#     @tp @b PYTHONPATH @endtp
#     <td>Search path for Python modules. If this CMake variable is undefined,
#         the corresponding environment variable is used instead if set.
#         Only absolute paths in the @c PYTHONPATH are considered.</td>
#   </tr>
# </table>
#
# @par Output variables:
# <table border="0">
#   <tr>
#     @tp @b PythonModules_FOUND @endtp
#     <td>Whether all specified Python modules were found.</td>
#   </tr>
#   <tr>
#     @tp @b PythonModules_&lt;module&gt;_FOUND @endtp
#     <td>Whether the Python module &lt;module%gt; was found.</td>
#   </tr>
#   <tr>
#     @tp @b PythonModules_&lt;module&gt;_PATH @endtp
#     <td>Absolute path of the directory containing the Python module named &lt;module%gt;.</td>
#   </tr>
#   <tr>
#     @tp @b PythonModules_PYTHONPATH @endtp
#     <td>The @c PYTHONPATH setting required for the found Python module(s), i.e.,
#         The directories that have to be added to the Python search path.
#         To support the use of this CMake module more than once with different
#         arguments to the find_package() command, e.g., with and without the
#         @c REQUIRED argument, the directories containing the found Python
#         modules are appended to any existing directories in
#         @c PythonModules_PYTHONPATH if not already listed.</td>
#   </tr>
# </table>
#
# @ingroup CMakeFindModules
##############################################################################

# ----------------------------------------------------------------------------
## @brief Find Python module.
#
# If the @c PYTHON_EXECUTABLE variable is set, this function at first tries
# to launch the Python interpreter, import the named Python module, and then
# determines the search path for the Python module from the @c __file__
# attribute of the loaded module. Otherwise, or if this fails, it looks for
# the Python module in the directories listed in the @c PYTHONPATH variable
# if defined. If this variable is not defined, the @c PYTHONPATH environment
# variable is used instead.
#
# @param [in,out] CACHEVAR Name of CMake cache variable which stores path of
#                          directory of the Python module. If not set or if
#                          the cache entry contains space characters only or
#                          ends in the string NOTFOUND, this function looks for
#                          the specified Python module. Otherwise, it does nothing
#                          and leaves the cache entry unmodified.
# @param [in]     MODULE   Name of the Python module (e.g., os or numpy).
#
# @returns Sets the named cache variable of type @c PATH to the absolute path
#          of the directory containing the specified Python @p MODULE if found,
#          or the string "&lt;MODULE%gt;-NOTFOUND" otherwise.
function (basis_find_python_module CACHEVAR MODULE)
  if (${CACHEVAR} MATCHES "^ *$")
    set (${CACHEVAR} "${MODULE}-NOTFOUND" CACHE PATH "Directory containing ${MODULE} Python module/package." FORCE)
  else ()
    set (${CACHEVAR} "${MODULE}-NOTFOUND" CACHE PATH "Directory containing ${MODULE} Python module/package.")
  endif ()
  if (${CACHEVAR} MATCHES "NOTFOUND$")
    # run Python, import module, and print directory of __file__ attribute
    if (PYTHON_EXECUTABLE)
      # 1. try it with -E option -- the preferred way to run Python
      execute_process (
        COMMAND "${PYTHON_EXECUTABLE}" -E -c "import ${MODULE}; import os; print os.path.dirname(${MODULE}.__file__)"
        RESULT_VARIABLE STATUS
        OUTPUT_VARIABLE P
        ERROR_VARIABLE  ERROR
      )
      # 2. try it without -E option
      if (NOT STATUS EQUAL 0)
        execute_process (
          COMMAND "${PYTHON_EXECUTABLE}" -c "import ${MODULE}; import os; print os.path.dirname(${MODULE}.__file__)"
          RESULT_VARIABLE STATUS
          OUTPUT_VARIABLE P
          ERROR_VARIABLE  ERROR
        )
        if (NOT STATUS EQUAL 0 AND ERROR MATCHES "ImportError: No module named site")
          set (PYTHONHOME "$ENV{PYTHONHOME}")
          unset (ENV{PYTHONHOME})
          execute_process (
            COMMAND "${PYTHON_EXECUTABLE}" -c "import ${MODULE}; import os; print os.path.dirname(${MODULE}.__file__)"
            RESULT_VARIABLE STATUS
            OUTPUT_VARIABLE P
            ERROR_VARIABLE  ERROR
          )
          set (ENV{PYTHONHOME} "${PYTHONHOME}")
        endif ()
      endif ()
      if (STATUS EQUAL 0)
        if (EXISTS "${P}/__init__.py")
          get_filename_component (P "${P}" PATH)
        endif ()
        set_property (CACHE ${CACHEVAR} PROPERTY VALUE "${P}")
      else ()
        message (WARNING "Failed to run Python interpreter ${PYTHON_EXECUTABLE} with or without -E option."
                         " Make sure that the Python interpreter is installed properly and that the PYTHONHOME"
                         " environment variable is either not set (recommended) or at least set correctly for"
                         " this Python installation. Maybe you need to enable this Python version first somehow"
                         " if more than one version of Python is installed on your system?"
                         " Otherwise, set PYTHON_EXECUTABLE to the right Python interpreter executable (python).")
      endif ()
    endif ()
    # search PYTHONPATH
    if (${CACHEVAR} MATCHES "NOTFOUND$")
      if (NOT DEFINED PYTHONPATH)
        string (REPLACE ":" ";" PYTHONPATH "$ENV{PYTHONPATH}")
      endif ()
      foreach (P IN LISTS PYTHONPATH)
        if (IS_ABSOLUTE "${P}")
          if (EXISTS "${P}/${MODULE}.py" OR EXISTS "${P}/${MODULE}/__init__.py")
            set_property (CACHE ${CACHEVAR} PROPERTY VALUE "${P}")
            break ()
          endif ()
        endif ()
      endforeach ()
    endif ()
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
# find Python modules
if (NOT PythonModules_FIND_COMPONENTS)
  message (FATAL_ERROR "PythonModules: No COMPONENTS (i.e., Python module names) specified!")
endif ()

set (PythonModules_FOUND TRUE) # set to false if at least one not found
set (PythonModules_PYTHONPATH) # PYTHONPATH of all found modules

foreach (_PythonModules_MODULE IN LISTS PythonModules_FIND_COMPONENTS)
  set (_PythonModules_VAR "PythonModules_${_PythonModules_MODULE}_PATH")
  basis_find_python_module (${_PythonModules_VAR} "${_PythonModules_MODULE}")
  mark_as_advanced (${_PythonModules_VAR})
  if (${_PythonModules_VAR} MATCHES "(^ *|NOTFOUND)$")
    set (PythonModules_FOUND           FALSE)
    set (PythonModules_${MODULE}_FOUND FALSE)
  else ()
    set (PythonModules_${MODULE}_FOUND TRUE)
    list (APPEND PythonModules_PYTHONPATH "${${_PythonModules_VAR}}")
  endif ()
endforeach ()

if (PythonModules_PYTHONPATH)
  list (REMOVE_DUPLICATES PythonModules_PYTHONPATH)
endif ()

# ----------------------------------------------------------------------------
# handle standard QUIET and REQUIRED arguments
if (PythonModules_FIND_REQUIRED AND NOT PythonModules_FOUND)
  # list of modules that were not found
  list (_PythonModules_MISSING)
  foreach (_PythonModules_MODULE IN LISTS PythonModules_FIND_COMPONENTS)
    if (NOT PythonModules_${_PythonModules_MODULE}_FOUND)
      list (APPEND _PythonModules_MISSING "${_PythonModules_MODULE}")
    endif ()
  endforeach ()
  # hint on how to help finding the Python modules
  set (_PythonModules_HINT)
  if (PYTHON_EXECUTABLE)
    set (_PythonModules_HINT "Check if executing ${PYTHON_EXECUTABLE} -c \"import <module>\" works")
  else ()
    set (_PythonModules_HINT "Set PYTHON_EXECUTABLE, e.g., by searching for Python interpreter first")
  endif ()
  if (_PythonModules_HINT)
    set (_PythonModules_HINT "${_PythonModules_HINT} or set")
  else ()
    set (_PythonModules_HINT "Set")
  endif ()
  set (_PythonModules_HINT "${_PythonModules_HINT} the PYTHONPATH environment/CMake variable")
  set (_PythonModules_HINT "${_PythonModules_HINT} or set the PythonModules_<module>_PATH variable(s).")
  # error message
  message (FATAL_ERROR "Could NOT find the following Python modules:\n${_PythonModules_MISSING}\n${_PythonModules_HINT}")
endif ()

# ----------------------------------------------------------------------------
# clean up
unset (_PythonModules_MODULE)
unset (_PythonModules_VAR)
unset (_PythonModules_VARS)
