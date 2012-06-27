##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of command-line tools.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# project management
if (PythonInterp_FOUND)
  basis_add_executable (basisproject.py)
  basis_add_dependencies (basisproject diff3_py argparse_py)
endif ()

# ----------------------------------------------------------------------------
# platform independent "which" command
if (PythonInterp_FOUND)
  basis_add_executable ("${PROJECT_CODE_DIR}/utilities/python/sbia/basis/which.py")
  basis_set_target_properties (which PROPERTIES SYMLINK_NAME "NONE")
endif ()

# ----------------------------------------------------------------------------
# doxygen filters
if (Perl_FOUND)
  basis_add_executable (doxyfilter.pl LIBEXEC)
endif ()

# ----------------------------------------------------------------------------
# testing tools
basis_add_executable (testdriver.cxx)
basis_set_target_properties (testdriver PROPERTIES OUTPUT_NAME "basistest-driver")
if (WIN32)
  basis_target_link_libraries (testdriver Ws2_32)
endif ()

if (ITK_FOUND)
  basis_set_target_properties (
    testdriver
    PROPERTIES
      COMPILE_DEFINITIONS
        "TESTDRIVER_NAME=\"basistest-driver\""
        "ITK_VERSION=\"${ITK_VERSION_MAJOR}.${ITK_VERSION_MINOR}.${ITK_VERSION_PATCH}\""
        "ITK_VERSION_MAJOR=${ITK_VERSION_MAJOR}"
  )
  basis_target_link_libraries (testdriver ${ITK_LIBRARIES})
else ()
  basis_set_target_properties (
    testdriver
    PROPERTIES
      COMPILE_DEFINITIONS
        "TESTDRIVER_NAME=\"basistest-driver\""
  )
endif ()

# ----------------------------------------------------------------------------
# automated testing
basis_add_script (basistest.ctest MODULE DESTINATION "${INSTALL_MODULES_DIR}")

if (BASH_FOUND)
  basis_add_executable (basistest-svn.sh)    # wraps svn command
  basis_add_executable (basistest-slave.sh)  # executes test task
  basis_add_executable (basistest-master.sh) # executes scheduled tests
  basis_add_executable (basistest-cron.sh)   # test cron job
  basis_add_executable (basistest.sh)        # main wrapper

  # do not install symbolic links for subcommands
  foreach (C cron master slave svn)
    basis_set_target_properties (basistest-${C} PROPERTIES SYMLINK_NAME "NONE")
  endforeach ()
endif ()
