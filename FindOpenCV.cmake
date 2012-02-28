###########################################################
#                  Find OpenCV Library
# See http://sourceforge.net/projects/opencvlibrary/
#----------------------------------------------------------
#
## 1: Setup:
# The following variables are optionally searched for defaults
#  OpenCV_DIR:            Base directory of OpenCv tree to use.
#
## 2: Variable
# The following are set after configuration is done: 
#  
#  OpenCV_FOUND
#  OpenCV_LIBS
#  OpenCV_INCLUDE_DIR
#  OpenCV_VERSION (OpenCV_VERSION_MAJOR, OpenCV_VERSION_MINOR, OpenCV_VERSION_PATCH)
#
#
# Deprecated variable are used to maintain backward compatibility with
# the script of Jan Woetzel (2006/09): www.mip.informatik.uni-kiel.de/~jw
#  OpenCV_INCLUDE_DIRS
#  OpenCV_LIBRARIES
#  OpenCV_LINK_DIRECTORIES
# 
## 3: Version
#
# 2012/02/28 Andreas Schuh, Modified for inclusion in BASIS.
# 2010/04/07 Benoit Rat, Correct a bug when OpenCVConfig.cmake is not found.
# 2010/03/24 Benoit Rat, Add compatibility for when OpenCVConfig.cmake is not found.
# 2010/03/22 Benoit Rat, Creation of the script.
#
#
# tested with:
# - OpenCV 2.1:  MinGW, MSVC2008
# - OpenCV 2.0:  MinGW, MSVC2008, GCC4
#
#
## 4: Licence:
#
# LGPL 2.1 : GNU Lesser General Public License Usage
# Alternatively, this file may be used under the terms of the GNU Lesser

# General Public License version 2.1 as published by the Free Software
# Foundation and appearing in the file LICENSE.LGPL included in the
# packaging of this file.  Please review the following information to
# ensure the GNU Lesser General Public License version 2.1 requirements
# will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
# 
#----------------------------------------------------------

# ----------------------------------------------------------------------------
# initialize search
set (OpenCV_FOUND FALSE)

find_path (
  OpenCV_DIR "OpenCVConfig.cmake"
  DOC "Directory containing OpenCVConfig.cmake file or installation prefix of OpenCV."
)

set (OpenCV_LIBS)                # found libraries
set (OpenCV_COMPONENTS_REQUIRED) # requested components
set (OpenCV_LIB_COMPONENTS)      # found components
set (OpenCV_VERSION)             # found version

# ----------------------------------------------------------------------------
# find headers and libraries
if (EXISTS "${OpenCV_DIR}")

  # --------------------------------------------------------------------------
  # OpenCV 2
  if (EXISTS "${OpenCV_DIR}/OpenCVConfig.cmake")

    include ("${OpenCV_DIR}/OpenCVConfig.cmake")

    foreach (__CVLIB IN LISTS OpenCV_COMPONENTS)
      if (NOT __CVLIB MATCHES "^opencv_")
        set (__CVLIB "opencv_${__CVLIB}")
      endif ()
      list (APPEND OpenCV_COMPONENTS_REQUIRED "${__CVLIB}")
    endforeach ()

  # --------------------------------------------------------------------------
  # OpenCV 1
  else ()

    # library components
    set (OpenCV_LIB_COMPONENTS cxcore cv ml highgui cvaux)

    if (OpenCV_COMPONENTS)
      foreach (__CVLIB IN LISTS OpenCV_COMPONENTS)
        string (REGEX REPLACE "^opencv_" "" __CVLIB__ "${__CVLIB}")
        list (FIND OpenCV_LIB_COMPONENTS ${__CVLIB__} IDX)
        if (IDX EQUAL -1)
          message (FATAL_ERROR "Unknown OpenCV library component: ${__CVLIB}"
                               " Are you looking for OpenCV 2.0.0 or greater?"
                               " In this case, please set OpenCV_DIR to the"
                               " directory containing the OpenCVConfig.cmake file.")
        endif ()
        list (APPEND OpenCV_COMPONENTS_REQUIRED "${__CVLIB__}")
      endforeach ()
    else ()
      set (OpenCV_COMPONENTS_REQUIRED ${OpenCV_LIB_COMPONENTS})
    endif ()

    # find include directory
    find_path (
      OpenCV_INCLUDE_DIR "cv.h"
      PATHS "${OpenCV_DIR}"
      PATH_SUFFIXES "include" "include/opencv"
      DOC "Directory of cv.h header file."
      NO_DEFAULT_PATH
    )

    mark_as_advanced (OpenCV_INCLUDE_DIR)

    if (EXISTS ${OpenCV_INCLUDE_DIR})
      # should not be done by Find module, but OpenCVConfig.cmake does it
      # as well, unfortunately...
      include_directories (${OpenCV_INCLUDE_DIR})
      # extract version information from cvver.h
      file (STRINGS "${OpenCV_INCLUDE_DIR}/cvver.h" OpenCV_VERSIONS_TMP REGEX "^#define CV_[A-Z]+_VERSION[ \t]+[0-9]+$")
      string (REGEX REPLACE ".*#define CV_MAJOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MAJOR ${OpenCV_VERSIONS_TMP})
      string (REGEX REPLACE ".*#define CV_MINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MINOR ${OpenCV_VERSIONS_TMP})
      string (REGEX REPLACE ".*#define CV_SUBMINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_PATCH ${OpenCV_VERSIONS_TMP})
      set (OpenCV_VERSION "${OpenCV_VERSION_MAJOR}.${OpenCV_VERSION_MINOR}.${OpenCV_VERSION_PATCH}")
      set (OpenCV_CVLIB_NAME_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")
    endif ()

    # find libraries of components
    set (OpenCV_LIB_COMPONENTS)
    foreach (__CVLIB IN LISTS OpenCV_COMPONENTS_REQUIRED)

      # debug build
      find_library (
        OpenCV_${__CVLIB}_LIBRARY_DEBUG
        NAMES "${__CVLIB}${OpenCV_CVLIB_NAME_SUFFIX}d"
        PATHS "${OpenCV_DIR}/lib"
        NO_DEFAULT_PATH
      )

      # release build
      find_library (
        OpenCV_${__CVLIB}_LIBRARY_RELEASE
        NAMES "${__CVLIB}${OpenCV_CVLIB_NAME_SUFFIX}"
        PATHS "${OpenCV_DIR}/lib"
        NO_DEFAULT_PATH
      )

      mark_as_advanced (OpenCV_${__CVLIB}_LIBRARY_DEBUG)
      mark_as_advanced (OpenCV_${__CVLIB}_LIBRARY_RELEASE)

      # both debug/release
      if (OpenCV_${__CVLIB}_LIBRARY_DEBUG AND OpenCV_${__CVLIB}_LIBRARY_RELEASE)
        set (OpenCV_${__CVLIB}_LIBRARY debug ${OpenCV_${__CVLIB}_LIBRARY_DEBUG} optimized ${OpenCV_${__CVLIB}_LIBRARY_RELEASE})
      # only debug
      elseif (OpenCV_${__CVLIB}_LIBRARY_DEBUG)
        set (OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_DEBUG})
      # only release
      elseif (OpenCV_${__CVLIB}_LIBRARY_RELEASE)
        set (OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_RELEASE})
      # not found
      else ()
        set (OpenCV_${__CVLIB}_LIBRARY)
      endif()

      # add to list of found libraries
      if (OpenCV_${__CVLIB}_LIBRARY)
        list (APPEND OpenCV_LIB_COMPONENTS ${__CVLIB})
        list (APPEND OpenCV_LIBS "${OpenCV_${__CVLIB}_LIBRARY}")
      endif ()

    endforeach ()

  endif ()

  # --------------------------------------------------------------------------
  # handle the QUIETLY and REQUIRED arguments and set *_FOUND to TRUE
  # if all listed variables are found or TRUE
  include (FindPackageHandleStandardArgs)

  set (OpenCV_REQUIRED_COMPONENTS_FOUND TRUE)
  set (OpenCV_COMPONENTS_NOT_FOUND)
  foreach (__CVLIB IN LISTS OpenCV_COMPONENTS_REQUIRED)
    list (FIND OpenCV_LIB_COMPONENTS ${__CVLIB} IDX)
    if (IDX EQUAL -1)
      set (OpenCV_REQUIRED_COMPONENTS_FOUND FALSE)
      list (APPEND OpenCV_COMPONENTS_NOT_FOUND ${__CVLIB})
    endif ()
  endforeach ()

  if (NOT OpenCV_REQUIRED_COMPONENTS_FOUND)
    if (NOT OpenCV_FIND_QUIET AND OpenCV_FIND_REQUIRED)
      message (FATAL_ERROR "The following required OpenCV components"
                           " were not found: ${OpenCV_COMPONENTS_NOT_FOUND}")
    endif ()
  endif ()

  find_package_handle_standard_args (
    OpenCV
    REQUIRED_VARS
      OpenCV_INCLUDE_DIR
      OpenCV_LIBS
      OpenCV_REQUIRED_COMPONENTS_FOUND
    VERSION_VAR
      OpenCV_VERSION
  )

  set (OpenCV_FOUND "${OPENCV_FOUND}")

  # --------------------------------------------------------------------------
  # (backward) compatibility
  if (OpenCV_FOUND)
    set (OpenCV_INCLUDE_DIRS "${OpenCV_INCLUDE_DIR}")
    set (OpenCV_LIBRARIES    "${OpenCV_LIBS}")
  endif ()

elseif (NOT OpenCV_FIND_QUIET AND OpenCV_FIND_REQUIRED)
  message (FATAL_ERROR "Please specify the OpenCV directory using OpenCV_DIR (environment) variable.")
endif ()


