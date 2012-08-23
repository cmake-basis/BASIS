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
if (BUILD_PROJECT_TOOL AND PythonInterp_FOUND)
  basis_add_executable (basisproject.py)
  basis_target_link_libraries (utilities_python)
endif ()

# ----------------------------------------------------------------------------
# platform independent "which" command - not required on Unix
if (NOT UNIX AND PythonInterp_FOUND)
  basis_add_executable (which "${PROJECT_CODE_DIR}/utilities/python/which.py")
  basis_set_target_properties (which PROPERTIES SYMLINK_NAME NONE)
endif ()

# ----------------------------------------------------------------------------
# doxygen filters
if (Perl_FOUND)
  basis_add_library (doxyfilterlib "DoxyFilter.pm" "DoxyFilter/**.pm")
  basis_library_prefix (PREFIX PERL)
  basis_set_target_properties (
    doxyfilterlib
    PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY  "${BINARY_PERL_LIBRARY_DIR}"
      LIBRARY_INSTALL_DIRECTORY "${INSTALL_PERL_LIBRARY_DIR}"
      PREFIX                    "${PREFIX}"
  )
  basis_add_executable (doxyfilter.pl LIBEXEC)
  basis_target_link_libraries (doxyfilter doxyfilterlib)
endif ()

# TODO Implement BASIS::DoxyFilter::CMake Perl module and remove this executable.
if (PythonInterp_FOUND)
  basis_add_executable (doxyfilter-perl.py LIBEXEC)
endif ()

# ----------------------------------------------------------------------------
# testing tools
basis_add_executable (testdriver.cxx LIBEXEC)
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
  basis_add_executable (basistest-svn.sh    LIBEXEC) # wraps svn command
  basis_add_executable (basistest-slave.sh  LIBEXEC) # executes test task
  basis_add_executable (basistest-master.sh LIBEXEC) # executes scheduled tests
  basis_add_executable (basistest-cron.sh   LIBEXEC) # test cron job
  basis_add_executable (basistest.sh)                # main wrapper
endif ()
