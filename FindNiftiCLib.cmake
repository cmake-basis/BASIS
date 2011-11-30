##############################################################################
# @file  FindNiftiCLib.cmake
# @brief Find nifticlib package.
#
# @par Input variables:
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_DIR</td>
#     <td>The nifticlib package files are searched under the specified root
#         directory. If they are not found there, the default search paths
#         are considered. This variable can also be set as environment variable.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NIFTICLIB_DIR</td>
#     <td>Alternative environment variable for @p NiftiCLib_DIR.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_USE_STATIC_LIB</td>
#     <td>Forces this module to search for the static library. Otherwise,
#         the shared library is preferred.</td>
#   </tr>
# </table>
#
# @par Output variables:
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_FOUND</td>
#     <td>Whether the nifticlib package was found and the following CMake
#         variables are valid.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_INCLUDE_DIR</td>
#     <td>Cached include directory/ies.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_INCLUDE_DIRS</td>
#     <td>Alias for @p NiftiCLib_INCLUDE_DIR (not cached).</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_INCLUDES</td>
#     <td>Alias for @p NiftiCLib_INCLUDE_DIR (not cached).</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_LIBRARY</td>
#     <td>Path of @c niftiio library.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_LIB</td>
#     <td>Alias for @p NiftiCLib_LIBRARY (not cached).</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NiftiCLib_LIBRARIES</td>
#     <td>Path of @c niftiio library and prerequisite libraries.</td>
#   </tr>
# </table>
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeFindModules
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
  elseif(APPLE)
    set (CMAKE_FIND_LIBRARY_SUFFIXES .dylib)
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
    NAMES         nifti1_io.h
    HINTS         ENV C_INCLUDE_PATH ENV CXX_INCLUDE_PATH
    PATH_SUFFIXES nifti
    DOC           "Path of directory containing nifti1.h"
)

find_library (
  NiftiCLib_LIBRARY
    NAMES         niftiio
    HINTS         ${NiftiCLib_DIR} ENV NiftiCLib_DIR ENV NIFTICLIB_DIR
    PATH_SUFFIXES lib
    DOC           "Path of niftiio library"
    NO_DEFAULT_PATH
)

find_library (
  NiftiCLib_LIBRARY
    NAMES niftiio
    HINTS ENV LD_LIBRARY_PATH
    DOC   "Path of niftiio library"
)

mark_as_advanced (NiftiCLib_INCLUDE_DIR)
mark_as_advanced (NiftiCLib_LIBRARY)

# ============================================================================
# import targets
# ============================================================================

if (NiftiCLib_LIBRARY)
  if (NiftiCLib_USE_STATIC_LIB)
    add_library (niftiio STATIC IMPORTED)
  else ()
    add_library (niftiio SHARED IMPORTED)
  endif ()

  set_target_properties (
    niftiio
    PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
      IMPORTED_LOCATION "${NiftiCLib_LIBRARY}"
  )
endif ()

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

if (NiftiCLib_LIBRARY)
  set (NiftiCLib_LIB "${NiftiCLib_LIBRARY}")
endif ()

if (NiftiCLib_LIBRARY)
  set (
    NiftiCLib_LIBRARIES
      "${NiftiCLib_LIBRARY}"
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
  REQUIRED_VARS
    NiftiCLib_INCLUDE_DIR
    NiftiCLib_LIBRARY
)

set (NiftiCLib_FOUND ${NIFTICLIB_FOUND})
