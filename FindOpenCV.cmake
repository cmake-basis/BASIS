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
# 2012/02/28 Andreas Schuh, Modifications for inclusion in BASIS.
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


find_path(OpenCV_DIR "OpenCVConfig.cmake" DOC "Root directory of OpenCV")

##====================================================
## Find OpenCV libraries
##----------------------------------------------------
if(EXISTS "${OpenCV_DIR}")

        #When its possible to use the Config script use it.
        if(EXISTS "${OpenCV_DIR}/OpenCVConfig.cmake")

                ## Include the standard CMake script
                include("${OpenCV_DIR}/OpenCVConfig.cmake")

                ## Search for a specific version
                set(CVLIB_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")

        #Otherwise it try to guess it.
        else(EXISTS "${OpenCV_DIR}/OpenCVConfig.cmake")

                set(OPENCV_LIB_COMPONENTS cxcore cv ml highgui cvaux)
                find_path(OpenCV_INCLUDE_DIR "cv.h" PATHS "${OpenCV_DIR}" PATH_SUFFIXES "include" "include/opencv" DOC "")
                mark_as_advanced(OpenCV_INCLUDE_DIR)
                if(EXISTS  ${OpenCV_INCLUDE_DIR})
                        include_directories(${OpenCV_INCLUDE_DIR})
                endif(EXISTS  ${OpenCV_INCLUDE_DIR})

                #Find OpenCV version by looking at cvver.h
                if (OpenCV_INCLUDE_DIR)
                    file(STRINGS ${OpenCV_INCLUDE_DIR}/cvver.h OpenCV_VERSIONS_TMP REGEX "^#define CV_[A-Z]+_VERSION[ \t]+[0-9]+$")
                    string(REGEX REPLACE ".*#define CV_MAJOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MAJOR ${OpenCV_VERSIONS_TMP})
                    string(REGEX REPLACE ".*#define CV_MINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_MINOR ${OpenCV_VERSIONS_TMP})
                    string(REGEX REPLACE ".*#define CV_SUBMINOR_VERSION[ \t]+([0-9]+).*" "\\1" OpenCV_VERSION_PATCH ${OpenCV_VERSIONS_TMP})
                    set(OpenCV_VERSION ${OpenCV_VERSION_MAJOR}.${OpenCV_VERSION_MINOR}.${OpenCV_VERSION_PATCH} CACHE STRING "" FORCE)
                    set(CVLIB_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")
                else ()
                    set(OpenCV_VERSION)
                    set(CVLIB_SUFFIX)
                endif ()

        endif(EXISTS "${OpenCV_DIR}/OpenCVConfig.cmake")

        if (OpenCV_COMPONENTS)
          set (OPENCV_LIB_COMPONENTS ${OpenCV_COMPONENTS})
        endif ()

        ## Initiate the variable before the loop
        set(GLOBAL OpenCV_LIBS "")
        set(OpenCV_FOUND_TMP true)

        ## Loop over each components
        foreach(__CVLIB ${OPENCV_LIB_COMPONENTS})
                
                find_library(OpenCV_${__CVLIB}_LIBRARY_DEBUG NAMES "${__CVLIB}${CVLIB_SUFFIX}d" "lib${__CVLIB}${CVLIB_SUFFIX}d" PATHS "${OpenCV_DIR}/lib" NO_DEFAULT_PATH)
                find_library(OpenCV_${__CVLIB}_LIBRARY_RELEASE NAMES "${__CVLIB}${CVLIB_SUFFIX}" "lib${__CVLIB}${CVLIB_SUFFIX}" PATHS "${OpenCV_DIR}/lib" NO_DEFAULT_PATH)
                mark_as_advanced (OpenCV_${__CVLIB}_LIBRARY_DEBUG)
                mark_as_advanced (OpenCV_${__CVLIB}_LIBRARY_RELEASE)
                
                #Remove the cache value
                set(OpenCV_${__CVLIB}_LIBRARY)
                
                #both debug/release
                if(OpenCV_${__CVLIB}_LIBRARY_DEBUG AND OpenCV_${__CVLIB}_LIBRARY_RELEASE)
                        set(OpenCV_${__CVLIB}_LIBRARY debug ${OpenCV_${__CVLIB}_LIBRARY_DEBUG} optimized ${OpenCV_${__CVLIB}_LIBRARY_RELEASE})
                #only debug
                elseif(OpenCV_${__CVLIB}_LIBRARY_DEBUG)
                        set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_DEBUG})
                #only release
                elseif(OpenCV_${__CVLIB}_LIBRARY_RELEASE)
                        set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_RELEASE})
                #no library found
                else()
                        set(OpenCV_FOUND_TMP false)
                endif()
                
                #Add to the general list
                if(OpenCV_${__CVLIB}_LIBRARY)
                        set(OpenCV_LIBS ${OpenCV_LIBS} ${OpenCV_${__CVLIB}_LIBRARY})
                endif(OpenCV_${__CVLIB}_LIBRARY)
                
        endforeach(__CVLIB)

        set(OpenCV_FOUND ${OpenCV_FOUND_TMP})


else(EXISTS "${OpenCV_DIR}")
        set(ERR_MSG "Please specify OpenCV directory using OpenCV_DIR env. variable")
endif(EXISTS "${OpenCV_DIR}")
##====================================================


##====================================================
## Print message
##----------------------------------------------------
if(NOT OpenCV_FOUND)
        # make FIND_PACKAGE friendly
        if(NOT OpenCV_FIND_QUIETLY)
                if(OpenCV_FIND_REQUIRED)
                        message(FATAL_ERROR "OpenCV required but some headers or libs not found. ${ERR_MSG}")
                else(OpenCV_FIND_REQUIRED)
                        message(STATUS "WARNING: OpenCV was not found. ${ERR_MSG}")
                endif(OpenCV_FIND_REQUIRED)
        endif(NOT OpenCV_FIND_QUIETLY)
endif(NOT OpenCV_FOUND)
##====================================================


##====================================================
## Backward compatibility
##----------------------------------------------------
set(OpenCV_INCLUDE_DIRS "${OpenCV_INCLUDE_DIR}")
set(OpenCV_LIBRARIES    "${OpenCV_LIBS}")
##====================================================
