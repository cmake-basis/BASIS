# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of testing tools.
##############################################################################

# ----------------------------------------------------------------------------
# standalone test driver
basis_add_executable (testdriver.cxx USE_BASIS_UTILITIES LIBEXEC)
if (WIN32)
  basis_target_link_libraries (testdriver Ws2_32)
endif ()

if (ITK_FOUND)
  basis_set_target_properties (
    testdriver
    PROPERTIES
      COMPILE_DEFINITIONS
        "ITK_VERSION=\"${ITK_VERSION_MAJOR}.${ITK_VERSION_MINOR}.${ITK_VERSION_PATCH}\""
        "ITK_VERSION_MAJOR=${ITK_VERSION_MAJOR}"
  )
  basis_target_link_libraries (testdriver ${ITK_LIBRARIES})
endif ()

# ----------------------------------------------------------------------------
# automated testing
basis_add_script (basistest.ctest DESTINATION "${INSTALL_MODULES_DIR}")

if (BASH_FOUND)
  basis_add_executable (basistest-svn.sh    USE_BASIS_UTILITIES LIBEXEC) # wraps svn command
  basis_add_executable (basistest-slave.sh  USE_BASIS_UTILITIES LIBEXEC) # executes test task
  basis_add_executable (basistest-master.sh USE_BASIS_UTILITIES LIBEXEC) # executes scheduled tests
  basis_add_executable (basistest-cron.sh   USE_BASIS_UTILITIES LIBEXEC) # test cron job
  basis_add_executable (basistest.sh        USE_BASIS_UTILITIES)         # main wrapper
endif ()
