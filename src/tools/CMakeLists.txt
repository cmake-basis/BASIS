##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of command-line tools.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# project management
if (UNIX)
  basis_add_executable (basisproject.sh)
endif ()

# ----------------------------------------------------------------------------
# basic command-line tools
if (PYTHONINTERP_FOUND)
  basis_add_executable (which which.py)
  basis_set_target_properties (which PROPERTIES SYMLINK_NAME "NONE")
endif ()

# ----------------------------------------------------------------------------
# doxygen filters
if (PERL_FOUND AND PYTHONINTERP_FOUND)
  basis_add_executable (doxyfilter.pl        LIBEXEC)
  basis_add_executable (doxyfilter-bash.py   LIBEXEC)
  basis_add_executable (doxyfilter-cmake.py  LIBEXEC)
  basis_add_executable (doxyfilter-matlab.pl LIBEXEC)
  basis_add_executable (doxyfilter-python.py LIBEXEC)

  basis_add_library ("DoxyGen/Filter.pm"     WITH_PATH)
  basis_add_library ("DoxyGen/PerlFilter.pm" WITH_PATH)
endif ()

# ----------------------------------------------------------------------------
# testing
basis_add_executable (testdriver.cxx)
basis_set_target_properties (testdriver PROPERTIES OUTPUT_NAME "basistest-driver")

basis_add_script (basistest.ctest MODULE DESTINATION "${INSTALL_MODULES_DIR}")

if (UNIX)
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

# ----------------------------------------------------------------------------
# other tools
if (UNIX)
  basis_add_executable (make_html_verbatim.sh)
  basis_set_target_properties (make_html_verbatim PROPERTIES SYMLINK_NAME "NONE")
endif ()
