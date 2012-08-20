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
set (TEMPLATE_VERSION "<template-version>")

# ----------------------------------------------------------------------------
# include BASIS policies, settings, macros, and functions

# circumvent issue with CMake's find_package() interpreting these variables
# relative to the current binary directory instead of the top-level directory
if (BASIS_DIR AND NOT IS_ABSOLUTE "${BASIS_DIR}")
  set (BASIS_DIR "${CMAKE_BINARY_DIR}/${BASIS_DIR}")
  get_filename_component (BASIS_DIR "${BASIS_DIR}" ABSOLUTE)
endif ()
# moreover, users tend to specify the installation prefix instead of the
# actual directory containing the package configuration file
if (IS_DIRECTORY "${BASIS_DIR}")
  list (INSERT CMAKE_PREFIX_PATH 0 "${BASIS_DIR}")
endif ()
# if BASIS is not found, set CMAKE_INSTALL_PREFIX to invalid value if not
# set explicitly at the command-line such that BASIS will still initialize
# it to its defaults even though already cached
find_package (BASIS)
if (NOT BASIS_FOUND)
  if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "" CACHE INTERNAL "Installation prefix." FORCE)
  endif ()
  message (FATAL_ERROR "BASIS not found! Please specify installation directory"
                       " of BASIS or the location of the BASISConfig.cmake file"
                       " using the BASIS_DIR variable.")
endif ()

# ----------------------------------------------------------------------------
# configure build system
basis_project_impl ()
