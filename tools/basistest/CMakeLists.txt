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
basis_add_script (basistest.ctest DESTINATION "${INSTALL_MODULES_DIR}" FINAL)

if (BASH_FOUND)
  basis_add_executable (basistest.sh        USE_BASIS_UTILITIES)         # main wrapper
  basis_add_executable (basistest-master.sh USE_BASIS_UTILITIES LIBEXEC) # executes scheduled tests
  basis_add_executable (basistest-slave.sh  USE_BASIS_UTILITIES LIBEXEC) # executes test task
  basis_add_executable (basistest-cron.sh   USE_BASIS_UTILITIES LIBEXEC) # cron job which triggers tests
  basis_add_executable (basistest-svn.sh    USE_BASIS_UTILITIES LIBEXEC) # wraps svn command

  basis_set_target_properties (basistest-cron PROPERTIES SCRIPT_DEFINITIONS
    "basis_set_script_path (MODULES_DIR \"${PROJECT_CODE_DIR}/cmake\" \"${INSTALL_MODULES_DIR}\")"
  )

  basis_set_target_properties (basistest-slave PROPERTIES SCRIPT_DEFINITIONS
    "basis_set_script_path (BASISTEST_CTEST_SCRIPT_DIR \"${BINARY_LIBEXEC_DIR}\" \"${INSTALL_MODULES_DIR}\")"
  )

  basis_finalize_targets (basistest basistest-master basistest-slave basistest-cron basistest-svn)
endif ()
