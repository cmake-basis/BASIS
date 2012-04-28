##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of BASH utilities.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# template files
basis_install (
  FILES
    stdaux.sh.in               # higher-level utilities
    executabletargetinfo.sh.in # information about executable targets
    basis.sh.in                # main module to be sourced
  DESTINATION
    "${INSTALL_BASH_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# modules
basis_add_library (core.sh)    # core utilities
basis_add_library (path.sh)    # path manipulation functions
basis_add_library (shflags.sh) # command-line parsing library
basis_add_library (shtap.sh)   # unit testing framework
