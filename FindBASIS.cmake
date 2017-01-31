#.rst:
# FindBASIS
# ---------
#
# Find CMake Build system And Software Implementation Standard (BASIS)
# installation using the find_package command in CONFIG mode.
# 
# Result variables::
#
#   BASIS_FOUND            - True if CMake BASIS was found.
#   BASIS_VERSION          - Version of found CMake BASIS installation.
#   BASIS_VERSION_MAJOR    - Major version number of found CMake BASIS installation.
#   BASIS_VERSION_MINOR    - Minor version number of found CMake BASIS installation.
#   BASIS_VERSION_PATCH    - Patch number of found CMake BASIS installation.
#   BASIS_INCLUDE_DIRS     - CMake BASIS Utilities include directories.
#   BASIS_LIBRARY_DIRS     - Link directories for CMake BASIS Utilities.
#
# By default, this module reads hints about search paths from variables::
#
#   DEPENDS_BASIS_DIR - Either installation root or BASISConfig.cmake directory.
#   BASIS_DIR         - Directory containing the BASISConfig.cmake file.
#   BASIS_ROOT        - Root directory of CMake BASIS installation.
#
# This module considers the common ``BASIS_DIR`` and ``BASIS_ROOT`` CMake or environment
# variables to initialize the ``DEPENDS_BASIS_DIR`` cache entry. The ``DEPENDS_BASIS_DIR``
# is the non-internal cache entry visible in the CMake GUI. This variable can be set
# to either the installation prefix of CMake BASIS, i.e., the top-level directory,
# or the directory containing the ``BASISConfig.cmake`` file. It therefore is a hybrid
# of ``BASIS_ROOT`` and ``BASIS_DIR`` and replaces these. The common DEPENDS prefix
# for cache entries used to set the location of dependencies allows the grouping
# of these variables in the CMake GUI. This is a feature of basis_find_package.
# As this command is not available without having found a CMake BASIS installation before,
# this module can be used to replicate a subset of its functionality for finding BASIS.

#=============================================================================
# Copyright 2016 Andreas Schuh
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

# Set BASISConfig.cmake directory from installation prefix path
function (_basis_root_to_config_dir OUT IN)
  if (IN)
    if (WIN32)
      set(${OUT} "${IN}/CMake" PARENT_SCOPE)
    else ()
      set(${OUT} "${IN}/lib/cmake/basis" PARENT_SCOPE)
    endif ()
  else ()
    set(${OUT} "NOTFOUND" PARENT_SCOPE)
  endif ()
endfunction ()

# Set installation prefix path from BASISConfig.cmake directory
function (_basis_config_to_root_dir OUT IN)
  if (IN)
    if (WIN32)
      string(REGEX REPLACE "/+CMake/*$" "" _prefix "${IN}")
    else ()
      string(REGEX REPLACE "/+lib/+cmake/+basis/*$" "" _prefix "${IN}")
    endif ()
  else ()
    set(_prefix "NOTFOUND")
  endif ()
  set(${OUT} "${_prefix}" PARENT_SCOPE)
endfunction ()

# Use more user friendly hybrid DEPENDS_BASIS_DIR cache variable which allows grouping
# of DEPENDS paths or custom named cache entry, but still consider BASIS_ROOT and
# BASIS_DIR as more common alternatives set in the user shell environment or on the
# CMake command line. The DEPENDS_<Package>_DIR is what CMake BASIS uses by default.
set (DEPENDS_BASIS_DIR "${DEPENDS_BASIS_DIR}" CACHE PATH
  "Installation prefix of CMake BASIS or directory containing BASISConfig.cmake file."
)

# Override DEPENDS_BASIS_DIR by alternative search path variable value if these
# were specified on the command line using the -D option. Note that these variables
# cannot be set in the CMake GUI because their type is changed here to INTERNAL.
# This has two reasons, firstly to not have duplicate variables with different
# names for the same purpose, and secondly to be able to recognize when their
# value is changed using the -D command line option of the cmake command.
if (BASIS_DIR AND (NOT DEFINED _BASIS_DIR OR (DEFINED _BASIS_DIR AND NOT "^${BASIS_DIR}$" STREQUAL "^${_BASIS_DIR}$")))
  _basis_config_to_root_dir(_prefix "${BASIS_DIR}")
  set_property(CACHE DEPENDS_BASIS_DIR PROPERTY VALUE "${_prefix}")
endif ()
if (BASIS_ROOT AND (NOT DEFINED _BASIS_ROOT OR (DEFINED _BASIS_ROOT AND NOT "^${BASIS_ROOT}$" STREQUAL "^${_BASIS_ROOT}$")))
  set_property(CACHE DEPENDS_BASIS_DIR PROPERTY VALUE "${BASIS_ROOT}")
endif ()

# Mark alternatives as internal cache entries
foreach (_var IN ITEMS BASIS_DIR BASIS_ROOT)
  get_property(_cached CACHE ${_var} PROPERTY TYPE SET)
  if (_cached)
    set_property(CACHE ${_var} PROPERTY TYPE INTERNAL)
  endif ()
endforeach ()

# If still not set, use common environment variables to set DEPENDS_BASIS_DIR
if (NOT DEPENDS_BASIS_DIR)
  foreach (_dir IN ITEMS "$ENV{BASIS_DIR}" "$ENV{BASIS_ROOT}")
    if (_dir)
      set_property(CACHE DEPENDS_BASIS_DIR PROPERTY VALUE "${_dir}")
      break()
    endif ()
  endforeach ()
endif ()

# Convert path to CMake style with forward slashes
file (TO_CMAKE_PATH "${DEPENDS_BASIS_DIR}" DEPENDS_BASIS_DIR)

# Circumvent issue with CMake's find_package() interpreting these variables
# relative to the current binary directory instead of the top-level directory
if (DEPENDS_BASIS_DIR AND NOT IS_ABSOLUTE "${DEPENDS_BASIS_DIR}")
  set (DEPENDS_BASIS_DIR "${CMAKE_BINARY_DIR}/${DEPENDS_BASIS_DIR}")
endif ()

# Allow DEPENDS_BASIS_DIR to be set to either the root directory...
if (DEPENDS_BASIS_DIR)
  list (INSERT CMAKE_PREFIX_PATH 0 "${DEPENDS_BASIS_DIR}")
endif ()    
# ...or the directory containing the BASISConfig.cmake file
set(BASIS_DIR "${DEPENDS_BASIS_DIR}" CACHE INTERNAL "Directory containing BASISConfig.cmake file." FORCE)

# Look for CMake BASIS installation
if (NOT BASIS_FIND_QUIETLY)
  set(_msg "Looking for BASIS")
  if (BASIS_FIND_VERSION)
    set(_msg "${_msg} ${BASIS_FIND_VERSION}")
  endif ()
  if (BASIS_FIND_COMPONENTS)
    set(_msg "${_msg} [${BASIS_FIND_COMPONENTS}]")
  endif ()
  message(STATUS "${_msg}...")
endif ()

set(_argv)
if (BASIS_FIND_VERSION)
  list(APPEND _argv ${BASIS_FIND_VERSION})
endif ()
if (BASIS_FIND_VERSION_EXACT)
  list(APPEND _argv EXACT)
endif ()
set(_comps)
set(_comps_opt)
foreach (_comp IN LISTS BASIS_FIND_COMPONENTS)
  if (BASIS_FIND_REQUIRED_${_component})
    list(APPEND _comps ${_component})
  else ()
    list(APPEND _comps_opt ${_component})
  endif ()
endforeach ()
if (_comps)
  list(APPEND _argv COMPONENTS ${_comps})
endif ()
if (_comps_opt)
  list(APPEND _argv OPTIONAL_COMPONENTS ${_comps_opt})
endif ()

find_package(BASIS ${_argv} CONFIG QUIET)

if (NOT BASIS_FIND_QUIETLY)
  if (BASIS_FOUND)
    if (BASIS_VERSION AND NOT BASIS_VERSION STREQUAL "0.0.0")
      message(STATUS "Looking for BASIS... - found v${BASIS_VERSION}")
    else ()
      message(STATUS "Looking for BASIS... - found")
    endif ()
  else ()
    message(STATUS "Looking for BASIS... - not found")
  endif ()
endif ()

# Make internal search path cache entries consistent with non-internal cache entry
if (BASIS_FOUND)
  _basis_config_to_root_dir(_prefix "${BASIS_DIR}")
else ()
  set(_prefix NOTFOUND)
endif ()
if (NOT "^DEPENDS_BASIS_DIR$" STREQUAL "^BASIS_DIR$")
  set_property(CACHE BASIS_DIR PROPERTY TYPE INTERNAL)
  set(_BASIS_DIR "${BASIS_DIR}" CACHE INTERNAL "Previous BASIS_DIR value" FORCE)
endif ()
get_property(_cached CACHE BASIS_ROOT PROPERTY TYPE SET)
if (_cached)
  set_property(CACHE BASIS_ROOT PROPERTY VALUE "${_prefix}")
else ()
  set(BASIS_ROOT "${_prefix}")
endif ()
if (NOT _cache MATCHES "^BASIS_(DIR|ROOT)$")
  set_property(CACHE DEPENDS_BASIS_DIR PROPERTY VALUE "${_prefix}")
endif ()

# Make internal cache copies of alternative search path variables
# so we can detect when a new value was specified using -D option
foreach (_var IN ITEMS BASIS_DIR BASIS_ROOT)
  if (NOT "^DEPENDS_BASIS_DIR$" STREQUAL "^${_var}$")
    get_property(_cached CACHE ${_var} PROPERTY TYPE SET)
    if (_cached)
      set(_${_var} "${${_var}}" CACHE INTERNAL "Previous value of ${_var} after last find_package(BASIS)" FORCE)
    endif ()
  endif ()
endforeach ()

# Raise fatal error when CMake BASIS required but not found
if (BASIS_FIND_REQUIRED AND NOT BASIS_FOUND)
  message(FATAL_ERROR "Could not find CMake BASIS! Please ensure that it is installed"
                      " in a standard system location or set DEPENDS_BASIS_DIR either"
                      " to the installation prefix of BASIS, i.e., the root directory,"
                      " or the directory containing the BASISConfig.cmake file.")
endif ()

# Unset local variables
unset(_prefix)
unset(_argv)
unset(_comp)
unset(_comps)
unset(_comps_opt)
unset(_cached)
unset(_dir)
unset(_var)
unset(_msg)
