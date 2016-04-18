# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Doxygen filters.
##############################################################################

basis_add_library (doxyfilterlib "DoxyFilter.pm" "DoxyFilter/**.pm" USE_BASIS_UTILITIES)

basis_library_prefix (PREFIX PERL)
basis_set_target_properties (
  doxyfilterlib
  PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY  "${BINARY_PERL_LIBRARY_DIR}"
    LIBRARY_INSTALL_DIRECTORY "${INSTALL_PERL_LIBRARY_DIR}"
    PREFIX                    "${PREFIX}"
)

basis_add_executable (doxyfilter.pl LIBEXEC USE_BASIS_UTILITIES)
basis_target_link_libraries (doxyfilter doxyfilterlib)

# TODO Implement BASIS::DoxyFilter::CMake Perl module and remove this executable.
basis_add_executable (doxyfilter-perl.py LIBEXEC)

basis_finalize_targets (doxyfilterlib doxyfilter doxyfilter-perl)
