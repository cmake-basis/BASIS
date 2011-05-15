##############################################################################
# \file  CMakeLists.txt
# \brief CMake configuration file of testing tree.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

if (EXISTS "${TESTING_SYSTEMTESTS_DIR}")
  add_subdirectory ("${TESTING_SYSTEMTESTS_DIR}")
endif ()

if (EXISTS "${TESTING_UNITTESTS_DIR}")
  add_subdirectory ("${TESTING_UNITTESTS_DIR}")
endif ()

