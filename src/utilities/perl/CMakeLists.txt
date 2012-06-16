##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Perl utilities.
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
    Config.pm.in               # configuration of utilities
    ExecutableTargetInfo.pm.in # information about executable targets
    StdAux.pm.in               # standard auxiliary functions
    Basis.pm.in                # main module to be imported
  DESTINATION
    "${INSTALL_PERL_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# Perl modules
basis_add_library (Utilities.pm) # project independent utilities
basis_add_library (Which.pm)     # which command

basis_add_dependencies (Utilities_pm Which_pm)
