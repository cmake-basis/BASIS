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

# ----------------------------------------------------------------------------
# CPAN
basis_add_library (
  cpan_modules
    "Readonly.pm"
    "Data/**.pm"
    "File/**.pm"
    "Params/**.pm"
    "Pod/**.pm"
    "Sub/**.pm"
)

basis_set_target_properties (cpan_modules PROPERTIES PREFIX "${BASIS_NAMESPACE}")

# ----------------------------------------------------------------------------
# utilities
basis_get_target_name (UTILITIES ${BASIS_PERL_UTILITIES_LIBRARY})
basis_add_library (${UTILITIES} "Utilities.pm")
basis_target_link_libraries (${UTILITIES} cpan_modules)
