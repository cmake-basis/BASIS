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
    Basis.pm.in
  DESTINATION
    "${INSTALL_PERL_TEMPLATES_DIR}"
)

# The Perl utilities can be found in <src>/lib/perl5/. Note that the packages
# found in the lib/ directory are automatically configured, build, and installed.


# TODO Remove the following once this idea is implemented.

# ----------------------------------------------------------------------------
# utilities
basis_get_target_name (UTILITIES ${BASIS_PERL_UTILITIES_LIBRARY})
basis_add_library (${UTILITIES} "${PROJECT_LIBRARY_DIR}/perl5")
basis_set_target_properties (${UTILITIES} PROPERTIES SOURCE_DIRECTORY "${PROJECT_LIBRARY_DIR}/perl5" PREFIX "")
