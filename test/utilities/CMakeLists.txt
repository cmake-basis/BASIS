##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests for utilities.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# test project independent utilities
basis_add_test (test_path.cxx UNITTEST)
basis_add_test (test_core.sh  UNITTEST)
basis_add_test (test_shtap.sh UNITTEST)

# test project-specific utilities
basis_add_test (test_utilities.sh)
