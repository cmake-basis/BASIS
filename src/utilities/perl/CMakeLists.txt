##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Perl utilities.
#
# The modules within the current source directory are part of the
# @c BASIS_NAMESPACE package.
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
    Basis.pm.in
  DESTINATION
    "${INSTALL_PERL_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# Perl modules
basis_add_library (SBIA DESTINATION "${INSTALL_PERL_LIBRARY_DIR}")
