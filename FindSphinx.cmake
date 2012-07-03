##############################################################################
# @file  FindSphinx.cmake
# @brief Find Sphinx documentation build tools.
#
# @par Input variables:
# <table border="0">
#   <tr>
#     @tp @b Sphinx_FIND_COMPONENTS @endtp
#     <td>Sphinx build tools to look for, i.e., 'apidoc' and/or 'build'.</td>
# </table>
#
# @par Output variables:
# <table border="0">
#   <tr>
#     @tp @b Sphinx_FOUND @endtp
#     <td>Whether all or only the requested Sphinx build tools were found.</td>
#   </tr>
#   <tr>
#     @tp @b SPHINX_FOUND @endtp
#     <td>Alias for @c Sphinx_FOUND.<td>
#   </tr>
#   <tr>
#     @tp @b SPHINX_EXECUTABLE @endtp
#     <td>Non-cached alias for @c Sphinx-build_EXECUTABLE.</td>
#   </tr>
#   <tr>
#     @tp @b Sphinx-build_EXECUTABLE @endtp
#     <td>Absolute path of the found sphinx-build tool.</td>
#   </tr>
#   <tr>
#     @tp @b Sphinx-apidoc_EXECUTABLE @endtp
#     <td>Absolute path of the found sphinx-apidoc tool.</td>
#   </tr>
#   <tr>
#     @tp @b Sphinx_VERSION_STRING @endtp
#     <td>Sphinx version found e.g. 1.1.2.</td>
#   </tr>
#   <tr>
#     @tp @b Sphinx_VERSION_MAJOR @endtp
#     <td>Sphinx major version found e.g. 1.</td>
#   </tr>
#   <tr>
#     @tp @b Sphinx_VERSION_MINOR @endtp
#     <td>Sphinx minor version found e.g. 1.</td>
#   </tr>
#   <tr>
#     @tp @b Sphinx_VERSION_PATCH @endtp
#     <td>Sphinx patch version found e.g. 2.</td>
#   </tr>
# </table>
#
# @ingroup CMakeFindModules
##############################################################################

set (_Sphinx_REQUIRED_VARS)

# ----------------------------------------------------------------------------
# default components to look for
if (NOT Sphinx_FIND_COMPONENTS)
  set (Sphinx_FIND_COMPONENTS "build" "apidoc")
endif ()

# ----------------------------------------------------------------------------
# find components, i.e., build tools
foreach (_Sphinx_TOOL IN LISTS Sphinx_FIND_COMPONENTS)
  find_program (Sphinx-${_Sphinx_TOOL}_EXECUTABLE NAMES sphinx-${_Sphinx_TOOL})
  mark_as_advanced (Sphinx-${_Sphinx_TOOL}_EXECUTABLE)
  list (APPEND _Sphinx_REQUIRED_VARS Sphinx-${_Sphinx_TOOL}_EXECUTABLE)
endforeach ()

# ----------------------------------------------------------------------------
# determine Sphinx version
if (Sphinx-build_EXECUTABLE)
  execute_process (
    COMMAND "Sphinx-build_EXECUTABLE" -h
    OUTPUT_VARIABLE _Sphinx_VERSION
    ERROR_QUIET
  )
  if (_Sphinx_VERSION MATCHES "^Sphinx v([0-9]+\\.[0-9]+\\.[0-9]+)")
    set (Sphinx_VERSION_STRING "${CMAKE_MATCH_1}")
    string (REPLACE "." ";" _Sphinx_VERSION "${Sphinx_VERSION}")
    list(GET _Sphinx_VERSION 0 Sphinx_VERSION_MAJOR)
    list(GET _Sphinx_VERSION 1 Sphinx_VERSION_MINOR)
    list(GET _Sphinx_VERSION 2 Sphinx_VERSION_PATCH)
    if (Sphinx_VERSION_PATCH EQUAL 0)
      string (REGEX REPLACE "\\.0$" "" Sphinx_VERSION_STRING "${Sphinx_VERSION_STRING}")
    endif ()
  endif()
endif ()

# ----------------------------------------------------------------------------
# compatibility
set (SPHINX_EXECUTABLE "${Sphinx-build_EXECUTABLE}")

# ----------------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set SPHINX_FOUND to TRUE if
# all listed variables are TRUE
include (FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS (
  Sphinx
  REQUIRED_VARS
    ${_Sphinx_REQUIRED_VARS}
  VERSION_VAR
    Sphinx_VERSION_STRING
)

set (Sphinx_FOUND ${SPHINX_FOUND})

unset (_Sphinx_VERSION)
unset (_Sphinx_REQUIRED_VARS)
