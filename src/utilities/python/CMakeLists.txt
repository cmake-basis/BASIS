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
    "config.py.in"               # configuration of utilities
    "executabletargetinfo.py.in" # information about executable targets
    "stdaux.py.in"               # standard auxiliary functions
    "basis.py.in"                # main module to be imported
  DESTINATION
    "${INSTALL_PYTHON_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# Python modules
basis_add_library (__init__.py)  # package initialization
basis_add_library (argparse.py)  # command-line parsing library
basis_add_library (diff3.py)     # implementation of three-way diff
basis_add_library (utilities.py) # project independent utilities
basis_add_library ("${PROJECT_CODE_DIR}/tools/which.py") # which command

basis_add_dependencies (utilities_py which_py)
