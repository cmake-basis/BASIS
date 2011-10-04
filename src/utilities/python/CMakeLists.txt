##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Python utilities.
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
    "executabletargetinfo.py.in" # information about executable targets
    "stdaux.py.in"               # standard auxiliary functions
    "basis.py.in"                # main module
  DESTINATION
    "${INSTALL_PYTHON_TEMPLATES_DIR}"
)
