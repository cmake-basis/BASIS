# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of command-line tools.
##############################################################################

# ----------------------------------------------------------------------------
# project management
if (BUILD_PROJECT_TOOL AND PythonInterp_FOUND)
  basis_add_executable (basisproject.py USE_BASIS_UTILITIES)
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
  basis_add_library (doxyfilterlib "DoxyFilter.pm" "DoxyFilter/**.pm" USE_BASIS_UTILITIES)
  basis_library_prefix (PREFIX PERL)
  basis_set_target_properties (
    doxyfilterlib
    PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY  "${BINARY_PERL_LIBRARY_DIR}"
      LIBRARY_INSTALL_DIRECTORY "${INSTALL_PERL_LIBRARY_DIR}"
      PREFIX                    "${PREFIX}"
  )
  basis_add_executable (doxyfilter.pl LIBEXEC USE_BASIS_UTILITIES)
  basis_target_link_libraries (doxyfilter doxyfilterlib)
endif ()

# TODO Implement BASIS::DoxyFilter::CMake Perl module and remove this executable.
if (PythonInterp_FOUND)
  basis_add_executable (doxyfilter-perl.py LIBEXEC)
endif ()

# ----------------------------------------------------------------------------
# testing tools
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
