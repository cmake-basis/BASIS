##############################################################################
# \file  CMakeLists.txt
# \brief Root CMakeLists.txt file of BASIS bundle.
#
# The BASIS bundle is an example application of the superproject template
# which is part of the BASIS Core component. It includes all other BASIS
# components using CMake's ExternalProject module. Which BASIS components
# should actually be downloaded, build, and installed is configured during
# CMake's configure step. The sources of the selected BASIS components are
# downloaded and build during the build step of the BASIS bundle. The final
# installation of the selected and build BASIS components is done during the
# installation step of the BASIS bundle.
#
# Hence, initially only the BASIS bundle should be downloaded manually.
# All other BASIS components will be downloaded on demand.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# CMake version
# ============================================================================

# minimum required CMake version
cmake_minimum_required (VERSION 2.8.4)

# ============================================================================
# template version
# ============================================================================

# use invalid template version to indicate that this project is not
# instantiated from any template as it in fact provides the template
set (TEMPLATE_VERSION "0.0")

# ============================================================================
# CMake modules
# ============================================================================

include (ExternalProject)

# ============================================================================
# own CMake modules
# ============================================================================

# set CMake module path
set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Core/src/cmake")

# ============================================================================
# project
# ============================================================================

project ("BASIS")

# ============================================================================
# configuration
# ============================================================================

set (PROJECT_VERSION "1.0.0")

set (
  CLI_URL
    "http://www.codesynthesis.com/download/cli/1.1/cli-1.1.0+dep.tar.bz2"
  CACHE STRING
  "Download URL of Command Line Interface (CLI) compiler developed by CodeSynthesis."
)

set (
  BASIS_URL
    "https://sbia-svn.uphs.upenn.edu/projects/BASIS/trunk"
  CACHE STRING
  "Download URL of BASIS, e.g., \"https://sbia-svn/projects/BASIS/trunk\""
)

option (BUILD_CLI   "Whether to build the CLI command-line tool." ON)
option (BUILD_Boost "Whether to build the BASIS Boost component." ON)

set_property (DIRECTORY PROPERTY EP_BASE "${PROJECT_BINARY_DIR}")

# ============================================================================
# tools
# ============================================================================

# ----------------------------------------------------------------------------
# CLI

if (BUILD_CLI)
  ExternalProject_Add (
    CLI
    URL               "http://www.codesynthesis.com/download/cli/1.1/cli-1.1.0+dep.tar.bz2"
    URL_MD5           "528ea79ea5ee3843597ffac766233884"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND     "make"
    BUILD_IN_SOURCE   1
  )
endif ()

# ============================================================================
# components
# ============================================================================

# ----------------------------------------------------------------------------
# Core

ExternalProject_Add (
  Core
  SVN_REPOSITORY "${URL_BASE}/Core"
)

# ----------------------------------------------------------------------------
# Boost

if (BUILD_BOOST)
endif ()
