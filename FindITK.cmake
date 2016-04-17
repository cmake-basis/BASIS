##############################################################################
# @file  FindITK.cmake
# @brief Find an ITK installation or build tree.
#
# When ITK is found, the ITKConfig.cmake file is sourced to setup the
# location and configuration of ITK.  Please read this file, or
# ITKConfig.cmake.in from the ITK source tree for the full list of
# definitions.  Of particular interest is ITK_USE_FILE, a CMake source file
# that can be included to set the include directories, library directories,
# and preprocessor macros.  In addition to the variables read from
# ITKConfig.cmake, this find module also defines
#
# @par Output variables:
# <table border="0">
#   <tr>
#     @tp @b ITK_DIR @endtp
#     <td>The directory containing ITKConfig.cmake.  
#         This is either the root of the build tree, 
#         or the lib/InsightToolkit directory.  
#         This is the only cache entry.</td>
#   </tr>
#   <tr>
#     @tp @b ITK_FOUND @endtp
#     <td>Whether ITK was found.  If this is true, @c ITK_DIR is okay.</td>
#   </tr>
#   <tr>
#     @tp @b USE_ITK_FILE @endtp
#     <td>The full path to the <tt>UseITK.cmake</tt> file.  
#         This is provided for backward 
#         compatability. Use @c ITK_USE_FILE instead.</td>
#   </tr>
# </table>
#
# @ingroup CMakeFindModules
##############################################################################

# ============================================================================
# Copyright 2000-2009 Kitware, Inc., Insight Software Consortium
# All rights reserved.
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

# Use the Config mode of the find_package() command to find ITKConfig.
# If this succeeds (possibly because ITK_DIR is already set), the
# command will have already loaded ITKConfig.cmake and set ITK_FOUND.
IF(NOT ITK_FOUND)
  SET(_ITK_REQUIRED "")
  IF(ITK_FIND_REQUIRED)
    SET(_ITK_REQUIRED REQUIRED)
  ENDIF()
  SET(_ITK_QUIET "")
  IF(ITK_FIND_QUIETLY)
    SET(_ITK_QUIET QUIET)
  ENDIF()
  FIND_PACKAGE(ITK ${ITK_FIND_VERSION} ${_ITK_REQUIRED} ${_ITK_QUIET} NO_MODULE
    NAMES ITK InsightToolkit
    CONFIGS ITKConfig.cmake
    )
ENDIF()

IF(ITK_FOUND)
  # Set USE_ITK_FILE for backward-compatability.
  SET(USE_ITK_FILE ${ITK_USE_FILE})
ENDIF()
