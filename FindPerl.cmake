##############################################################################
# @file  FindPerl.cmake
# @brief Find Perl interpreter.
#
# @par Output variables:
# <table border="0">
#   <tr>
#     @tp @b Perl_FOUND @endtp
#     <td>Was the Python executable found.</td>
#   </tr>
#   <tr>
#     @tp @b PERL_FOUND @endtp
#     <td>Alias for @b Perl_FOUND for backwards compatibility.</td>
#   </tr>
#   <tr>
#     @tp @b PERL_EXECUTABLE @endtp
#     <td>Path to the Perl interpreter.</td>
#   </tr>
#   <tr>
#     @tp @b Perl_DIR @endtp
#     <td>Installation prefix of the Perl interpreter.</td>
#   </tr>
#   <tr>
#     @tp @b PERL_VERSION_STRING @endtp
#     <td>Perl version found e.g. 5.12.4.</td>
#   </tr>
#   <tr>
#     @tp @b PERL_VERSION_MAJOR @endtp
#     <td>Perl major version found e.g. 5.</td>
#   </tr>
#   <tr>
#     @tp @b PERL_VERSION_MINOR @endtp
#     <td>Perl minor version found e.g. 12.</td>
#   </tr>
#   <tr>
#     @tp @b PERL_VERSION_PATCH @endtp
#     <td>Perl patch version found e.g. 4.</td>
#   </tr>
# </table>
#
# @note This module has been copied from CMake 2.8.5 and modified to also
#       obtain the version information of the found Perl interpreter.
#
# @ingroup CMakeFindModules
##############################################################################

#=============================================================================
# Copyright 2001-2009 Kitware, Inc.
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

include ("${CMAKE_ROOT}/Modules/FindCygwin.cmake")

set (PERL_POSSIBLE_BIN_PATHS "${CYGWIN_INSTALL_PATH}/bin")
if (WIN32)
  get_filename_component (
    ActivePerl_CurrentVersion 
      "[HKEY_LOCAL_MACHINE\\SOFTWARE\\ActiveState\\ActivePerl;CurrentVersion]" 
    NAME
  )
  set (PERL_POSSIBLE_BIN_PATHS ${PERL_POSSIBLE_BIN_PATHS}
    "C:/Perl/bin" 
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\ActiveState\\ActivePerl\\${ActivePerl_CurrentVersion}]/bin"
  )
  unset (ActivePerl_CurrentVersion)
endif ()

find_program (PERL_EXECUTABLE NAMES perl PATHS ${PERL_POSSIBLE_BIN_PATHS})
unset (PERL_POSSIBLE_BIN_PATHS)

if (PERL_EXECUTABLE)
  string (REGEX REPLACE "/bin/[pP]erl[^/]*" "" Perl_DIR "${PERL_EXECUTABLE}")
  execute_process (COMMAND "${PERL_EXECUTABLE}" --version OUTPUT_VARIABLE _Perl_STDOUT ERROR_VARIABLE _Perl_STDERR)
  if (_Perl_STDOUT MATCHES "[( ]v([0-9]+)\\.([0-9]+)\\.([0-9]+)[ )]")
    set (PERL_VERSION_MAJOR "${CMAKE_MATCH_1}")
    set (PERL_VERSION_MINOR "${CMAKE_MATCH_2}")
    set (PERL_VERSION_PATCH "${CMAKE_MATCH_3}")
    set (PERL_VERSION_STRING "${PERL_VERSION_MAJOR}.${PERL_VERSION_MINOR}.${PERL_VERSION_PATCH}")
  else ()
    message (WARNING "Failed to determine version of Perl interpreter (${PERL_EXECUTABLE})! Error:\n${_Perl_STDERR}")
  endif ()
  unset (_Perl_STDOUT)
  unset (_Perl_STDERR)
endif ()

include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (
  Perl
  REQUIRED_VARS
    PERL_EXECUTABLE
  VERSION_VAR
    PERL_VERSION_STRING
)

if (NOT DEFINED Perl_FOUND AND DEFINED PERL_FOUND)
  set (Perl_FOUND "${PERL_FOUND}")
endif ()

mark_as_advanced (PERL_EXECUTABLE)
