##############################################################################
# @file  CMakeLists.txt
# @brief Root build configuration file.
#
# Copyright (c) <year> University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# minimum required CMake version
cmake_minimum_required (VERSION 2.8.4)

# ----------------------------------------------------------------------------
# version of BASIS template used by this project
set (TEMPLATE_VERSION <template-version>)

# ----------------------------------------------------------------------------
# include BASIS policies, settings, macros, and functions

# circumvent issue with CMake's find_package() interpreting these variables
# relative to the current binary directory instead of the top-level directory
if (BASIS_DIR AND NOT IS_ABSOLUTE "${BASIS_DIR}")
  set (BASIS_DIR "${CMAKE_BINARY_DIR}/${BASIS_DIR}")
  get_filename_component (BASIS_DIR "${BASIS_DIR}" ABSOLUTE)
endif ()

find_package (BASIS REQUIRED)

# ----------------------------------------------------------------------------
# configure build system
basis_project_impl ()
