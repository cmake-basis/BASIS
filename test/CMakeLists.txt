##############################################################################
# \file  CMakeLists.txt
# \brief Build configuration of software testing.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# output directories
# ============================================================================

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")

# ============================================================================
# subdirectories
# ============================================================================

if (EXISTS "${TESTING_SYSTEM_DIR}")
  add_subdirectory ("${TESTING_SYSTEM_DIR}")
endif ()

if (EXISTS "${TESTING_UNIT_DIR}")
  add_subdirectory ("${TESTING_UNIT_DIR}")
endif ()

