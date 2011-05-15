##############################################################################
# \file  CMakeLists.txt
# \brief Root CMake configuration file of example component.
#
# By default, all content of the example folder is simply copied to the
# directory INSTALL_EXAMPLE_DIR.
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
# initialize
# ============================================================================

# The TEMPLATE_VERSION variable specifies the version of the BASIS Template
# which this project was instantiated from. This information is required by
# the automatic update of template files (see BASIS documentation).
# Further, the BASIS CMake functions might make use of this variable to ensure
# backwards compatibility with previous template versions.

set (TEMPLATE_VERSION "0.0")

find_package (BASIS REQUIRED)

if (NOT BASIS_FOUND)
  return ()
endif ()

include ("${BASIS_USE_FILE}" NO_POLICY_SCOPE)

# The following macro call replaces the CMake command project ().
#
# \see basis_example ()

basis_example_initialize ("BASIS")

# ============================================================================
# install example files
# ============================================================================

install (
  DIRECTORY   "${CMAKE_CURRENT_SOURCE_DIR}/"
  DESTINATION "${INSTALL_EXAMPLE_DIR}"
  PATTERN     CMakeLists.txt EXCLUDE
  PATTERN     *~             EXCLUDE
  PATTERN     .svn           EXCLUDE
  PATTERN     .git           EXCLUDE
)

# ============================================================================
# finalize
# ============================================================================

basis_example_finalize ()

