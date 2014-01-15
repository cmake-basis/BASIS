# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Perl utilities.
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
# utilities
basis_get_target_name (UTILITIES ${BASIS_PERL_UTILITIES_LIBRARY})

basis_add_library (
  ${UTILITIES}
    "Utilities.pm"
    # CPAN modules
    "Readonly.pm"
    "Data/**.pm"
    "File/**.pm"
    "Params/**.pm"
    "Pod/**.pm"
    "Sub/**.pm"
)

basis_library_prefix (PREFIX PERL)
basis_set_target_properties (
  ${UTILITIES}
  PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY  "${BINARY_PERL_LIBRARY_DIR}"
    LIBRARY_INSTALL_DIRECTORY "${INSTALL_PERL_LIBRARY_DIR}"
    PREFIX                    "${PREFIX}"
)

add_dependencies (${ALL_UTILITIES} ${UTILITIES})
