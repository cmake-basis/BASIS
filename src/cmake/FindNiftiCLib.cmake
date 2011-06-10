##############################################################################
# \file  FindNiftCLib.cmake
# \brief Find nifticlib package.
#
# Input variables:
#
#   NiftiCLib_DIR            The nifticlib package files are searched under the
#                            specified root directory. If they are not found
#                            there, the default search paths are considered.
#                            This variable can also be set as environment variable.
#   NIFTICLIB_DIR            Alternative environment variable for NiftiCLib_DIR.
#   NiftiCLib_USE_STATIC_LIB Forces this module to search for the static
#                            library. Otherwise, the shared library is preferred.
#
# Sets the following CMake variables:
#
#   NiftiCLib_FOUND        Whether the nifticlib package was found and the
#                          following CMake variables are valid.
#   NiftiCLib_INCLUDE_DIR  Cached include directory/ies.
#   NiftiCLib_INCLUDE_DIRS Alias for NiftiCLib_INCLUDE_DIR (not cached).
#   NiftiCLib_INCLUDES     Alias for NiftiCLib_INCLUDE_DIR (not cached).
#   NiftiCLib_LIB          Path of niftiio library.
#   NiftiCLib_LIBRARY      Alias for NiftiCLib_LIB (not cached).
#   NiftiCLib_LIBRARIES    Path of niftiio library and prerequisite libraries.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# initialize search
# ============================================================================

set (NiftiCLib_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})

if (NiftiCLib_USE_STATIC_LIB)
  if (WIN32)
    set (CMAKE_FIND_LIBRARY_SUFFIXES .lib)
  else ()
    set (CMAKE_FIND_LIBRARY_SUFFIXES .a)
  endif()
else ()
  if (WIN32)
    set (CMAKE_FIND_LIBRARY_SUFFIXES .dll .lib)
  else ()
    set (CMAKE_FIND_LIBRARY_SUFFIXES .so .a)
  endif()
endif ()

# ============================================================================
# find paths/files
# ============================================================================

find_path (
  NiftiCLib_INCLUDE_DIR
    NAMES         nifti1_io.h
    HINTS         ${NiftiCLib_DIR} ENV NiftiCLib_DIR ENV NIFTICLIB_DIR
    PATH_SUFFIXES include include/nifti
    DOC           "Path of directory containing nifti1.h"
    NO_DEFAULT_PATH
)

find_path (
  NiftiCLib_INCLUDE_DIR
    NAMES nifti1_io.h
    HINTS ENV C_INCLUDE_PATH ENV CXX_INCLUDE_PATH
    DOC   "Path of directory containing nifti1.h"
)

find_library (
  NiftiCLib_LIB
    NAMES         niftiio
    HINTS         ${NiftiCLib_DIR} ENV NiftiCLib_DIR ENV NIFTICLIB_DIR
    PATH_SUFFIXES lib
    DOC           "Path of niftiio library"
    NO_DEFAULT_PATH
)

find_library (
  NiftiCLib_LIB
    NAMES niftiio
    HINTS ENV LD_LIBRARY_PATH
    DOC   "Path of niftiio library"
)

# ============================================================================
# reset CMake variables
# ============================================================================

set (CMAKE_FIND_LIBRARY_SUFFIXES ${NiftiCLib_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES})

# ============================================================================
# aliases / backwards compatibility
# ============================================================================

if (NiftiCLib_INCLUDE_DIR)
  set (NiftiCLib_INCLUDE_DIRS "${NiftiCLib_INCLUDE_DIR}")
  set (NiftiCLib_INCLUDES     "${NiftiCLib_INCLUDE_DIR}")
endif ()

if (NiftiCLib_LIB)
  set (NiftiCLib_LIBRARY "${NiftiCLib_LIB}")
endif ()

if (NiftiCLib_LIB)
  set (
    NiftiCLib_LIBRARIES
      "${NiftiCLib_LIB}"
  )
endif ()

# ============================================================================
# found ?
# ============================================================================

# handle the QUIETLY and REQUIRED arguments and set *_FOUND to TRUE
# if all listed variables are found or TRUE

include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (
  NiftiCLib
# MESSAGE
    DEFAULT_MSG
# VARIABLES
    NiftiCLib_INCLUDE_DIR
    NiftiCLib_LIB
)
