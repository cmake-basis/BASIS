##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Perl utilities.
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
    StdAux.pm.in               # main utilities module
    ExecutableTargetInfo.pm.in # information about executable targets
    Basis.pm.in                # main module
  DESTINATION
    "${INSTALL_PERL_TEMPLATES_DIR}"
)

