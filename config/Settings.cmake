##############################################################################
# \file  Settings.cmake
# \brief Project settings.
#
# This file can be used to overwrite default settings which are set by
# SbiaSettings.cmake which is part of the SBIA CMake Modules package and to
# setup further project settings. This file further specifies the project's
# attributes such as in particular the project name and version.
#
# This file is included by the SBIA CMake command sbia_project ().
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# project attributes
# ============================================================================

# ----------------------------------------------------------------------------
# Update package version whenever a new release of the project is published
# and/or the project is tagged.
#
# The version number consists of three components: the major version number,
# the minor version number, and the patch number. The format of the version
# string is "Major.Minor.Patch", where the minor version number and patch
# number default to 0 if not given. Only digits are allowed except of the
# two separating dots.
#
# * A change of the major version number indicates changes of the softwares
#   API (and ABI) and/or its behavior and/or the change or addition of major
#   features.
# * A change of the minor version number indicates changes that are not only
#   bug fixes and no major changes. Hence, changes of the API but not the ABI.
# * A change of the patch number indicates changes only related to bug fixes
#   which did not change the softwares API. It is the least important component
#   of the version number.

set (PROJECT_VERSION "1.0.0")

# ----------------------------------------------------------------------------
# The name of the vendor of the project's package. This variable is mainly
# used for the packaging via CPack, i.e., as value of CPACK_PACKAGE_VENDOR.

set (PROJECT_PACKAGE_VENDOR "SBIA Group at University of Pennsylvania")

# ----------------------------------------------------------------------------
# Give a brief description of the project in the following. This description
# is in particular used as value of CPACK_PACKAGE_DESCRIPTION_SUMMARY for
# the package creation via CPack (see SbiaPackage module).

set (PROJECT_DESCRIPTION "This package implements and supports the development"
                         " of software projects which follow the SBIA Build"
                         " And Software Implementation Standard (BASIS).")

# ============================================================================
# common files, e.g., readme and license files
# ============================================================================

# ----------------------------------------------------------------------------
# Template files of CMake project configuration and version files.

set (PROJECT_CONFIG_TEMPLATE  "${SOFTWARE_CONFIG_DIR}/Config.cmake.in")
set (PROJECT_VERSION_TEMPLATE "${SOFTWARE_CONFIG_DIR}/ConfigVersion.cmake.in")
set (PROJECT_USE_TEMPLATE     "${SOFTWARE_CONFIG_DIR}/Use.cmake.in")

# ----------------------------------------------------------------------------
# Output names of CMake project configuration and version files.
#
# \note These strings are configured by GenerateConfig.cmake.
# \see GenerateConfig.cmake

set (PROJECT_CONFIG_FILE  "@PROJECT_NAME@Config.cmake.in")
set (PROJECT_VERSION_FILE "@PROJECT_NAME@ConfigVersion.cmake.in")
set (PROJECT_USE_FILE     "@PROJECT_NAME@Use.cmake.in")

# ============================================================================
# options
# ============================================================================

# Add build options here using the CMake command option () or set () with the
# CACHE argument.
#
# \see http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:option
# \see http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set

# \todo Change BASIS_TEMPLATE_ROOT to ${PROJECT_NAME}_DIR or similar.

# root directory of project templates
set (
  BASIS_TEMPLATE_ROOT
    ""
  CACHE PATH
    "Root directory of project templates, e.g., \"SVN_ROOT_URL/tags\"."
)

# make root directory a valid URL
if (BASIS_TEMPLATE_ROOT)
  if (NOT BASIS_TEMPLATE_ROOT MATCHES "^http://")
    if (NOT BASIS_TEMPLATE_ROOT MATCHES "^file://")
      set (BASIS_TEMPLATE_ROOT "file://${BASIS_TEMPLATE_ROOT}")
    endif ()
  endif ()
endif ()

# ============================================================================
# build configuration(s)
# ============================================================================

# Set common compiler and linker flags for the different supported build
# configurations here. The available build configurations are listed in
# CMAKE_CONFIGURATION_TYPES. For each build configuration, there exist the
# CMake variables CMAKE_C_FLAGS_<CONFIG> and CMAKE_CXX_FLAGS_<CONFIG>
# which specify the compiler flags, where <CONFIG> is the name of the build
# configuration in uppercase letters only. Accordingly, the variables
# CMAKE_EXE_LINKER_FLAGS_<CONFIG>, CMAKE_MODULE_LINKER_FLAGS_<CONFIG>,
# and CMAKE_SHARED_LINKER_FLAGS_<CONFIG> specify the linker flags for
# the corresponding target types.
#
# In order to only add compiler and/or linker flags, only append the values of
# the corresponding variables.
#
# Example:
# \code
# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
# \endcode
#
# \see SbiaSettings.cmake

# ============================================================================
# update
# ============================================================================

# ----------------------------------------------------------------------------
# exclude certain project files from (automatic) file update
#
# \note File paths have to be specified relative to the project source
#       directory such as "doc/Doxyfile.in" or "config/Config.cmake.in".
set (
  BASIS_UPDATE_EXCLUDE
)

