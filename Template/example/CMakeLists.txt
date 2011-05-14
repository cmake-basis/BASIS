##############################################################################
# \file  CMakeLists.txt
# \brief CMake file to configure build system of example component.
#
# By default, all content of the example folder is simply installed in the
# example subdirectory of the installation tree.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# CMake version
# ============================================================================

cmake_minimum_required (VERSION 2.8.2)

# ============================================================================
# template version
# ============================================================================

# Specifies the tagged project template which this project was instantiated
# from. This information is required by the automatic update of template
# files from the project template repository or working copy, respectively.
# Further, the BASIS CMake modules can make use of this variable for the
# purpose of backwards compatibility with previous template versions.

set (TEMPLATE_VERSION "0.0")

# ============================================================================
# BASIS
# ============================================================================

find_package (BASIS REQUIRED)

if (BASIS_FOUND)
  include ("${BASIS_USE_FILE}")
else ()
  return ()
endif ()

# ============================================================================
# start
# ============================================================================

basis_example ("ReplaceByProjectName")

# ============================================================================
# install example files
# ============================================================================

install (
  DIRECTORY   ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION "${INSTALL_EXAMPLE_DIR}"
  PATTERN     CMakeLists.txt EXCLUDE
  PATTERN     *~             EXCLUDE
  PATTERN     .svn           EXCLUDE
  PATTERN     .git           EXCLUDE
)

