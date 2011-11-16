##############################################################################
# @file  CMakeLists.txt
# @brief Root build configuration file.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# required CMake version
# ============================================================================

cmake_minimum_required (VERSION 2.8.4)

# ============================================================================
# project template version
# ============================================================================

# the version of the BASIS template this project was instantiated from
set (TEMPLATE_VERSION "ReplaceByTemplateVersion")

# ============================================================================
# initialize
# ============================================================================

# find BASIS package
find_package (BASIS REQUIRED)

# include BASIS policies, settings, macros, and functions
if (BASIS_FOUND)
  include ("${BASIS_USE_FILE}" NO_POLICY_SCOPE)
else ()
  return ()
endif ()

# ============================================================================
# main
# ============================================================================

basis_project_impl ()
