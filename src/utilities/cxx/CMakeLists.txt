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
    "config.cc.in"
    "ExecutableTargetInfo.h.in"  # information about executable build targets
    "ExecutableTargetInfo.cc.in"
    "stdaux.h.in"                # standard auxiliary functions
    "stdaux.cc.in"
  DESTINATION
    "${INSTALL_CXX_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# utilities
basis_add_library (
  utils STATIC
    "path.cc" # utility path functions
)

basis_set_target_properties (utils PROPERTIES OUTPUT_NAME "basis-utils")

# ----------------------------------------------------------------------------
# unit testing

# add include/sbia directory to include search path as the original Google
# Test and Google Mock sources include the headers via
# @code
# #include "gtest/gtest.h"
# @endcode
basis_include_directories ("${PROJECT_INCLUDE_DIR}/sbia") 

if (NOT HAVE_TR1_TUPLE)
  basis_add_definitions ("-DGTEST_USE_OWN_TR1_TUPLE=1")
endif ()

basis_add_library (test-all  STATIC "gmock-gtest-all.cc")
basis_add_library (test-main STATIC "test_main.cc")

basis_set_target_properties (test-all  PROPERTIES OUTPUT_NAME "basis-test")
basis_set_target_properties (test-main PROPERTIES OUTPUT_NAME "basis-test-main")
