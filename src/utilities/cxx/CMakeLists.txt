##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of C++ utilities.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
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
basis_add_library (
  utilities STATIC
    "path.cxx"       # utility path functions
    "subprocess.cxx" # subprocess execution
)

basis_set_target_properties (utilities PROPERTIES OUTPUT_NAME "basisutilities")

# ----------------------------------------------------------------------------
# unit testing

if (NOT HAVE_TR1_TUPLE)
  basis_add_definitions ("-DGTEST_USE_OWN_TR1_TUPLE=1")
endif ()

basis_add_library (testlib  STATIC "test.cxx")
basis_add_library (testmain STATIC "test_main.cxx")

basis_set_target_properties (testlib  PROPERTIES OUTPUT_NAME "basistest")
basis_set_target_properties (testmain PROPERTIES OUTPUT_NAME "basistest_main")
