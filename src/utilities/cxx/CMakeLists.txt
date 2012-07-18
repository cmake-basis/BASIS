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
    "basis.h.in"     # project-specific utility functions
    "basis.cxx.in"
  DESTINATION
    "${INSTALL_CXX_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# utilities
basis_get_target_name (UTILITIES "${BASIS_CXX_UTILITIES_LIBRARY}")
basis_add_library (
  ${UTILITIES} STATIC
    "os.cxx"         # operating system dependent functions
    "path.cxx"       # file/directory path related functions
    "subprocess.cxx" # subprocess execution
    "stdio.cxx"      # standard I/O functions
    "CmdLine.cxx"    # command-line parsing
    "utilities.cxx"  # project-independent utility functions
  NO_BASIS_UTILITIES # this *is* the BASIS utilities library
)
basis_set_target_properties (${UTILITIES} PROPERTIES OUTPUT_NAME utilities)

add_dependencies (${ALL_UTILITIES} ${UTILITIES})

# ----------------------------------------------------------------------------
# unit testing
if (NOT HAVE_TR1_TUPLE)
  basis_add_definitions ("-DGTEST_USE_OWN_TR1_TUPLE=1")
endif ()

basis_get_target_name (TESTLIB  "${BASIS_TEST_LIBRARY}")
basis_add_library (${TESTLIB}  STATIC "test.cxx")
basis_set_target_properties (${TESTLIB}  PROPERTIES OUTPUT_NAME "test")

basis_get_target_name (TESTMAIN "${BASIS_TEST_MAIN_LIBRARY}")
basis_add_library (${TESTMAIN} STATIC "test_main.cxx")
basis_target_link_libraries (${TESTMAIN} ${TESTLIB})
