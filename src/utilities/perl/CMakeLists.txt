##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Perl utilities.
#
# Copyright (c) 2011-2012 University of Pennsylvania. <br />
# Copyright (c) 2013-2014 Andreas Schuh.              <br />
# All rights reserved.                                <br />
#
# See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
# or COPYING file for license information.
#
# Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
#          report issues at https://github.com/schuhschuh/cmake-basis/issues
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
