##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of BASH utilities.
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
    Core.sh                    # core utilities
    StdAux.sh.in               # higher-level utilities
    ExecutableTargetInfo.sh.in # information about executable targets
    Flags.sh                   # command-line parsing library
    Basis.sh.in                # main module to be sourced
  DESTINATION
    "${INSTALL_BASH_TEMPLATES_DIR}"
)
