##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests for utilities.
#
# Copyright (c) 2011, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
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

basis_add_executable (parseargs.cxx)
basis_add_test (parseargs-help COMMAND parseargs --help)
basis_add_test (parseargs-helpshort COMMAND parseargs --helpshort)
basis_add_test (parseargs-version COMMAND parseargs --version)

# ----------------------------------------------------------------------------
# project-specific utilities
if (UNIX)
  # TODO Implement basisproject tool in Python such that it can be used
  #      by these tests also on Windows.
  basis_add_test (test_utilities.py)
endif ()
