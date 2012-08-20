##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests for command-line tools.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

if (PythonInterp_FOUND)
  basis_add_test (test_basisproject.py LINK_DEPENDS testaux_py)
  basis_set_tests_properties (test_basisproject PROPERTIES TIMEOUT 2700)
endif ()
