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
basis_add_script (basisproject.sh)

# ----------------------------------------------------------------------------
# doxygen filters
basis_add_script (doxygen-filter.pl            LIBEXEC)
basis_add_script (doxygen-bash-filter.py       LIBEXEC)
basis_add_script (doxygen-cmake-filter.py      LIBEXEC)
basis_add_script (doxygen-javascript-filter.pl LIBEXEC)
basis_add_script (doxygen-matlab-filter.pl     LIBEXEC)
basis_add_script (doxygen-python-filter.py     LIBEXEC)

# ----------------------------------------------------------------------------
# automated testing
basis_add_script (basistest.ctest MODULE DESTINATION "${INSTALL_MODULES_DIR}")

basis_add_script (basistest-svn.sh)
basis_add_script (basistest-slave.sh)
basis_add_script (basistest-master.sh)
basis_add_script (basistest-cron.sh)
