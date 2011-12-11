##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests for utilities.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# project independent utilities
basis_add_test (test_path.cxx UNITTEST)
basis_add_test (test_subprocess.cxx UNITTEST)
if (UNIX)
  basis_add_test (test_core.sh UNITTEST)
  basis_add_test (test_shtap.sh UNITTEST)
endif ()

basis_add_executable (test_CmdLine.cxx)
basis_add_test (test_CmdLine-help COMMAND test_CmdLine --help)
basis_add_test (test_CmdLine-helpshort COMMAND test_CmdLine --helpshort)
basis_add_test (test_CmdLine-version COMMAND test_CmdLine --version)

# ----------------------------------------------------------------------------
# project-specific utilities
basis_add_test (test_utilities.py)
