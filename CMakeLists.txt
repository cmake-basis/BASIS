##############################################################################
# \file  CMakeLists.txt
# \brief Root CMake configuration file of BASIS Core.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# CMake version
# ============================================================================

cmake_minimum_required (VERSION "2.8.2")

# ============================================================================
# initialize
# ============================================================================

# set CMake module path
set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/software/src/cmake")

# use invalid template version to indicate that this project is not
# instantiated from a template as it is even the basis of any template
set (TEMPLATE_VERSION "0.0")

# include BASIS settings
include (BasisSettings NO_POLICY_SCOPE)
include (BasisDirectories)

set (PROJECT_SOFTWARE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_SOFTWARE_DIR}")
set (PROJECT_EXAMPLE_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_EXAMPLE_DIR}")
set (PROJECT_TESTING_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_TESTING_DIR}")

# include BASIS functions
include (BasisProjectTools)

# ============================================================================
# major components
# ============================================================================

add_subdirectory (${PROJECT_SOFTWARE_DIR})

if (EXISTS "${PROJECT_EXAMPLE_DIR}")
  add_subdirectory ("${PROJECT_EXAMPLE_DIR}")
endif ()

if (EXISTS "${PROJECT_TESTING_DIR}")
  add_subdirectory ("${PROJECT_TESTING_DIR}")
endif ()

