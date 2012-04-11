##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of C++ utilities.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# template files
basis_install (
  FILES
    "config.h.in"                # build configuration and other macros
    "config.cxx.in"
    "ExecutableTargetInfo.h.in"  # information about executable build targets
    "ExecutableTargetInfo.cxx.in"
    "stdaux.h.in"                # standard auxiliary functions
    "stdaux.cxx.in"
    "basis.h.in"                 # main include file
  DESTINATION
    "${INSTALL_CXX_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# utilities
basis_get_target_name (UTILITIES "${BASIS_UTILITIES_LIBRARY}")

basis_add_library (
  ${UTILITIES} STATIC
    "path.cxx"       # utility path functions
    "subprocess.cxx" # subprocess execution
    "CmdLine.cxx"    # command-line parsing
)

# ----------------------------------------------------------------------------
# unit testing

if (NOT HAVE_TR1_TUPLE)
  basis_add_definitions ("-DGTEST_USE_OWN_TR1_TUPLE=1")
endif ()

basis_get_target_name (TESTLIB  "${BASIS_TEST_LIBRARY}")
basis_get_target_name (TESTMAIN "${BASIS_TEST_MAIN_LIBRARY}")

basis_add_library (${TESTLIB}  STATIC "test.cxx")
basis_add_library (${TESTMAIN} STATIC "test_main.cxx")

basis_set_target_properties (${TESTLIB}  PROPERTIES OUTPUT_NAME "test")
