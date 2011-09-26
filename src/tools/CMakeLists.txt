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
basis_add_executable (basisproject.sh)

# ----------------------------------------------------------------------------
# doxygen filters
basis_add_executable (doxygen-filter.pl            LIBEXEC)
basis_add_executable (doxygen-bash-filter.py       LIBEXEC)
basis_add_executable (doxygen-cmake-filter.py      LIBEXEC)
basis_add_executable (doxygen-javascript-filter.pl LIBEXEC)
basis_add_executable (doxygen-matlab-filter.pl     LIBEXEC)
basis_add_executable (doxygen-python-filter.py     LIBEXEC)

basis_add_library ("DoxyGen/Filter.pm" WITH_PATH)
basis_add_library ("DoxyGen/PerlFilter.pm" WITH_PATH)
basis_add_library ("DoxyGen/SQLFilter.pm" WITH_PATH)

# ----------------------------------------------------------------------------
# automated testing
basis_add_script (basistest.ctest MODULE DESTINATION "${INSTALL_MODULES_DIR}")

basis_add_executable (basistest-svn.sh)
basis_add_executable (basistest-slave.sh)
basis_add_executable (basistest-master.sh)
basis_add_executable (basistest-cron.sh)
