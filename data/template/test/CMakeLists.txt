##############################################################################
# \file  CMakeLists.txt
# \brief CMake configuration file of test targets.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")

if (EXISTS "${TESTING_SYSTEMTESTS_DIR}")
  add_subdirectory ("${TESTING_SYSTEMTESTS_DIR}")
endif ()

if (EXISTS "${TESTING_UNITTESTS_DIR}")
  add_subdirectory ("${TESTING_UNITTESTS_DIR}")
endif ()

