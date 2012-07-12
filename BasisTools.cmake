##############################################################################
# @file  BasisTools.cmake
# @brief Definition of functions and macros used by BASIS project.
#
# This is the main module that is included by BASIS projects. Most of the other
# BASIS CMake modules are included by this main module and hence do not need
# to be included separately. In particular, all CMake modules which are part
# of BASIS and whose name does not include the prefix "Basis" are not
# supposed to be included directly by a project that makes use of BASIS.
# Only the modules with the prefix "Basis" should be included directly.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeAPI
##############################################################################

# ----------------------------------------------------------------------------
# include guard
if (__BASIS_TOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_TOOLS_INCLUDED TRUE)
endif ()

# ----------------------------------------------------------------------------
# append CMake module path of BASIS to CMAKE_MODULE_PATH
set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}" ${CMAKE_MODULE_PATH})

# ----------------------------------------------------------------------------
# externally developed modules

# ExternalData.cmake module - yet only part of ITK, not CMake
include ("${CMAKE_CURRENT_LIST_DIR}/ExternalData.cmake")

# the module for the topological sort of modules according to their
# inter-dependencies was copied from the ITK v4 project
include ("${CMAKE_CURRENT_LIST_DIR}/TopologicalSort.cmake")

# ----------------------------------------------------------------------------
# BASIS modules
include ("${CMAKE_CURRENT_LIST_DIR}/CommonTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/DocTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/InterpTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/InstallationTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/MatlabTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/ProjectTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/RevisionTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/SlicerTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/TargetTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/ExportTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/ImportTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/UtilitiesTools.cmake")
