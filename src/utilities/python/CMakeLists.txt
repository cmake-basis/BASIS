##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Python utilities.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# template files
basis_install (
  FILES
    "__init__.py.in"             # default package configuration file
    "executabletargetinfo.py.in" # information about executable targets
    "stdaux.py.in"               # standard auxiliary functions
    "basis.py.in"                # main module to be imported by developers
  DESTINATION
    "${INSTALL_PYTHON_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# Python modules
basis_add_library (__init__.py)
basis_add_library (utilities.py)
basis_add_library (argparse.py)
basis_add_library (diff3.py)
basis_add_library ("${PROJECT_CODE_DIR}/tools/which.py")
