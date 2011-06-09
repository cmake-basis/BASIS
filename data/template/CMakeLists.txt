##############################################################################
# \file  CMakeLists.txt
# \brief Root build configuration file.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file in project root or 'doc' directory for details.
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

# use invalid template version to indicate that this project is not
# instantiated from a template as this package provides the template
set (TEMPLATE_VERSION "ReplaceByTemplateVersion")

# find BASIS package
find_package (BASIS REQUIRED)

# include BASIS policies, settings, macros, and functions
if (BASIS_FOUND)
  include ("${BASIS_USE_FILE}" NO_POLICY_SCOPE)
else ()
  return ()
endif ()

# initialize project
basis_project_initialize (
  NAME        "ReplaceByProjectName"
  VERSION     "0.0.0"
  DESCRIPTION "ReplaceByProjectDescription"
)

# ============================================================================
# subdirectories
# ============================================================================

# source code of programs
if (EXISTS "${PROJECT_CODE_DIR}")
  add_subdirectory ("${PROJECT_CODE_DIR}")
endif ()

# auxiliary data files
if (EXISTS "${PROJECT_DATA_DIR}")
  add_subdirectory ("${PROJECT_DATA_DIR}")
endif ()

# package documentation
if (EXISTS "${PROJECT_DOC_DIR}")
  add_subdirectory ("${PROJECT_DOC_DIR}")
endif ()

# example application
if (EXISTS "${PROJECT_EXAMPLE_DIR}" AND BUILD_EXAMPLE)
  add_subdirectory ("${PROJECT_EXAMPLE_DIR}")
endif ()

# software testing
if (EXISTS "${PROJECT_TESTING_DIR}" AND BUILD_TESTING)
  add_subdirectory ("${PROJECT_TESTING_DIR}")
endif ()

# ============================================================================
# finalize
# ============================================================================

basis_project_finalize ()

