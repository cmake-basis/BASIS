##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of BASH utilities.
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
    config.sh.in               # configuration of utilities
    executabletargetinfo.sh.in # information about executable targets
    stdaux.sh.in               # standard auxiliary functions
    basis.sh.in                # main module to be imported
  DESTINATION
    "${INSTALL_BASH_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# modules
basis_add_library (core.sh)      # fundamental core functions
basis_add_library (utilities.sh) # project independent utilities
basis_add_library (shflags.sh)   # command-line parsing library
basis_add_library (shtap.sh)     # unit testing framework

basis_add_dependencies (utilities_sh core_sh)
