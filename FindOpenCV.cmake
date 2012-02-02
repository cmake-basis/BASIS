##############################################################################
# @file  FindOpenCV.cmake
# @brief Find OpenCV package.
#
# @par Input variables:
# <table border="0">
#   <tr>
#     @tp @b OpenCV_DIR @endtp
#     <td>Base directory of OpenCV installation.
#         If not set, this module tries to find the OpenCVConfig.cmake file.</td>
#   </tr>
# </tabel>
#
# @par Output variables:
# <table border="0">
#   <tr>
#     @tp @b OpenCV_FOUND @endtp
#     <td>Whether the OpenCV package was found and the following CMake
#         variables are valid.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_VERSION @endtp
#     <td>Version string of the found OpenCV package.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_VERSION_MAJOR @endtp
#     <td>Major version number of the found OpenCV package.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_VERSION_MINOR @endtp
#     <td>Minor version number of the found OpenCV package.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_VERSION_PATCH @endtp
#     <td>Patch number of the found OpenCV package.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_INCLUDE_DIR @endtp
#     <td>Cached include directory/ies.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_INCLUDE_DIRS @endtp
#     <td>Alias for @p OpenCV_INCLUDE_DIR (not cached).</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_INCLUDES @endtp
#     <td>Alias for @p OpenCV_INCLUDE_DIRS (not cached).</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_cxcore_LIBRARY @endtp
#     <td>Path of @c cxcore library of OpenCV.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_cv_LIBRARY @endtp
#     <td>Path of @c cv library of OpenCV.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_ml_LIBRARY @endtp
#     <td>Path of @c ml library of OpenCV.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_highgui_LIBRARY @endtp
#     <td>Path of @c highgui library of OpenCV.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_cvaux_LIBRARY @endtp
#     <td>Path of @c cvaux library of OpenCV.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_LIBRARIES @endtp
#     <td>List of all found OpenCV libraries.</td>
#   </tr>
#   <tr>
#     @tp @b OpenCV_LIBS @endtp
#     <td>Alias for @p OpenCV_LIBRARIES to maintain compatibility
#         with the original FindOpenCV.cmake module.</td>
#   </tr>
# </table>
#
# @par Imported targets:
# <table border="0">
#   <tr>
#     @tp @b opencv.cxcore @endtp
#     <td>The library target of the @c cxcore library.</td>
#   </tr>
#   <tr>
#     @tp @b opencv.cv @endtp
#     <td>The library target of the @c cv library.</td>
#   </tr>
#   <tr>
#     @tp @b opencv.ml @endtp
#     <td>The library target of the @c ml library.</td>
#   </tr>
#   <tr>
#     @tp @b opencv.highgui @endtp
#     <td>The library target of the @c highgui library.</td>
#   </tr>
#   <tr>
#     @tp @b opencv.cvaux @endtp
#     <td>The library target of the @c cvaux library.</td>
#   </tr>
# </table>
#
# @note This file is based on the FindOpenCV.cmake module written by Benoit Rat.
# 
# @par Versions
#
# 2012/01/27 Andreas Schuh, Adopted for use with BASIS.
# 2010/04/07 Benoit Rat,    Correct a bug when OpenCVConfig.cmake is not found.
# 2010/03/24 Benoit Rat,    Add compatibility for when OpenCVConfig.cmake is not found.
# 2010/03/22 Benoit Rat,    Creation of the script.
#
# @par Licence
#
# LGPL 2.1: GNU Lesser General Public License Usage
# Alternatively, this file may be used under the terms of the GNU Lesser
#
# General Public License version 2.1 as published by the Free Software
# Foundation and appearing in the file LICENSE.LGPL included in the
# packaging of this file.  Please review the following information to
# ensure the GNU Lesser General Public License version 2.1 requirements
# will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
#
# @par Contact
# SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeFindModules
##############################################################################

# ----------------------------------------------------------------------------
# initialize search
find_path (
  OpenCV_DIR
    "OpenCVConfig.cmake"
  HINTS
    ENV OpenCV_DIR
    ENV OPENCV_DIR
  PATH_SUFFIXES
    "share/OpenCV"
  DOC "Directory containing OpenCVConfig.cmake file."
)

# components
if (OpenCV_FIND_COMPONENTS)
  set (OpenCV_COMPONENTS)
  foreach (OpenCV_FIND_COMPONENTS)
    string (TOLOWER "" _OpenCV_COMPONENT)
    list (APPEND OpenCV_COMPONENTS ${_OpenCV_COMPONENT})
  endforeach ()
else ()
  set (OpenCV_COMPONENTS cxcore cv ml highgui cvaux)
endif ()

# ----------------------------------------------------------------------------
# find paths/files
if (EXISTS "${OpenCV_DIR}")

  # --------------------------------------------------------------------------
  # if possible, use the OpenCVConfig.cmake script
  if (EXISTS "${OpenCV_DIR}/OpenCVConfig.cmake")

      # include the standard CMake script
      # TODO Consider use of find_package() in config-mode instead (NO_MODULE)
      include ("${OpenCV_DIR}/OpenCVConfig.cmake")

  # --------------------------------------------------------------------------
  # otherwise
  else ()

    # find include directory
    find_path (
      OpenCV_INCLUDE_DIR "cv.h"
        PATHS         "${OpenCV_DIR}"
        PATH_SUFFIXES "include" "include/opencv"
        DOC ""
    )

    # set library version to look for
    if (NOT OpenCV_FIND_VERSION)
      file (STRINGS "${OpenCV_INCLUDE_DIR}/cvver.h" OpenCV_VERSIONS_TMP REGEX "^#define CV_[A-Z]+_VERSION[ \t]+[0-9]+$")
      string (REGEX REPLACE ".*#define CV_MAJOR_VERSION[ \t]+([0-9]+).*"    "\\1" OpenCV_VERSION_MAJOR ${OpenCV_VERSIONS_TMP})
      string (REGEX REPLACE ".*#define CV_MINOR_VERSION[ \t]+([0-9]+).*"    "\\1" OpenCV_VERSION_MINOR ${OpenCV_VERSIONS_TMP})
      string (REGEX REPLACE ".*#define CV_SUBMINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_PATCH ${OpenCV_VERSIONS_TMP})
    else ()
      set (OpenCV_VERSION_MAJOR ${OpenCV_FIND_VERSION_MAJOR})
      if (OpenCV_VERSION_COUNT GREATER 1)
        set (OpenCV_VERSION_MINOR ${OpenCV_FIND_VERSION_MINOR})
      else ()
        set (OpenCV_VERSION_MINOR 0)
      endif ()
      if (OpenCV_VERSION_COUNT GREATER 2)
        set (OpenCV_VERSION_PATCH ${OpenCV_FIND_VERSION_PATCH})
      else ()
        set (OpenCV_VERSION_PATCH 0)
      endif ()
    endif ()

  endif ()

  # --------------------------------------------------------------------------
  # find libraries

  set (OpenCV_LIBRARY_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")
  set (OpenCV_LIBRARIES "")
  set (OpenCV_FOUND TRUE)

  foreach (_OpenCV_LIB ${OpenCV_COMPONENTS})

    # find debug library
    find_library (
      OpenCV_${_OpenCV_LIB}_LIBRARY_DEBUG
        NAMES         "${_OpenCV_LIB}${OpenCV_LIBRARY_SUFFIX}d"
        PATHS         "${OpenCV_DIR}"
        PATH_SUFFIXES "lib"
        NO_DEFAULT_PATH
    )

    # find release library
    find_library (
      OpenCV_${_OpenCV_LIB}_LIBRARY_RELEASE
        NAMES "${_OpenCV_LIB}${OpenCV_LIBRARY_SUFFIX}"
        PATHS "${OpenCV_DIR}"
        PATH_SUFFIXES "lib"
        NO_DEFAULT_PATH
    )

    # both debug/release
    if (OpenCV_${_OpenCV_LIB}_LIBRARY_DEBUG AND OpenCV_${_OpenCV_LIB}_LIBRARY_RELEASE)
       set (OpenCV_${_OpenCV_LIB}_LIBRARY debug "${OpenCV_${_OpenCV_LIB}_LIBRARY_DEBUG}" optimized "${OpenCV_${_OpenCV_LIB}_LIBRARY_RELEASE}")
       # must be done here using quotes to allow library paths with spaces
       list (APPEND OpenCV_LIBRARIES debug "${OpenCV_${_OpenCV_LIB}_LIBRARY_DEBUG}" optimized "${OpenCV_${_OpenCV_LIB}_LIBRARY_RELEASE}")
    # only debug
    elseif (OpenCV_${_OpenCV_LIB}_LIBRARY_DEBUG)
       set (OpenCV_${_OpenCV_LIB}_LIBRARY "${OpenCV_${_OpenCV_LIB}_LIBRARY_DEBUG}" CACHE STRING "" FORCE)
       list (APPEND OpenCV_LIBRARIES ${OpenCV_${_OpenCV_LIB}_LIBRARY})
    # only release
    elseif (OpenCV_${_OpenCV_LIB}_LIBRARY_RELEASE)
       set (OpenCV_${_OpenCV_LIB}_LIBRARY "${OpenCV_${_OpenCV_LIB}_LIBRARY_RELEASE}" CACHE STRING "" FORCE)
       list (APPEND OpenCV_LIBRARIES ${OpenCV_${_OpenCV_LIB}_LIBRARY})
    # no library found
    else ()
      set (OpenCV_FOUND FALSE)
    endif()

  endforeach ()

else ()
  set (_OpenCV_ERROR_MSG " Please specify OpenCV directory using OpenCV_DIR.")
endif ()

# ----------------------------------------------------------------------------
# import targets
foreach (_OpenCV_LIB ${OpenCV_COMPONENTS})
  if (OpenCV_${_OpenCV_LIB}_LIBRARY_DEBUG OR OpenCV_${_OpenCV_LIB}_LIBRARY_RELEASE)
    add_library (opencv.${_OpenCV_LIB} SHARED IMPORTED)
    foreach (_OpenCV_CONFIG DEBUG RELEASE)
      if (OpenCV_${_OpenCV_LIB}_LIBRARY_${_OpenCV_CONFIG})
        set_property (TARGET opencv.${_OpenCV_LIB} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${_OpenCV_CONFIG})
        set_target_properties (
          opencv.${_OpenCV_LIB}
          PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_${_OpenCV_CONFIG} "CXX"
            IMPORTED_LOCATION_${_OpenCV_CONFIG} "${OpenCV_${_OpenCV_LIB}_LIBRARY_${_OpenCV_CONFIG}}"
        )
      endif ()
    endforeach ()
  endif ()
endforeach ()

# ----------------------------------------------------------------------------
# aliases / backward compatibility
set (OpenCV_LIBS "${OpenCV_LIBRARIES}")

# ----------------------------------------------------------------------------
# make find_package() friendly
if (NOT OpenCV_FOUND)
  if (NOT OpenCV_FIND_QUIETLY)
    if (OpenCV_FIND_REQUIRED)
      message (FATAL_ERROR "OpenCV required but some headers or libs not found.${_OpenCV_ERROR_MSG}")
    else ()
      message (WARNING "OpenCV was not found.${_OpenCV_ERROR_MSG}")
    endif ()
  endif ()
endif ()
