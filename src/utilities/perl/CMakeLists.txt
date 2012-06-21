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
# CPAN modules
set (CPAN_MODULES
  "Sub::Exporter"
  "Sub::Install"
  "Data::OptList"
  "Params::Util"
  "File::Which"
  "Pod::POM"
  "Pod::POM::Constants"
  "Pod::POM::Node"
  "Pod::POM::Node::Begin"
  "Pod::POM::Node::Code"
  "Pod::POM::Node::Content"
  "Pod::POM::Node::For"
  "Pod::POM::Node::Head1"
  "Pod::POM::Node::Head2"
  "Pod::POM::Node::Head3"
  "Pod::POM::Node::Head4"
  "Pod::POM::Node::Item"
  "Pod::POM::Node::Over"
  "Pod::POM::Node::Pod"
  "Pod::POM::Node::Sequence"
  "Pod::POM::Node::Text"
  "Pod::POM::Node::Verbatim"
  "Pod::POM::Nodes"
  "Pod::POM::Test"
  "Pod::POM::View"
  "Pod::POM::View::HTML"
  "Pod::POM::View::Pod"
  "Pod::POM::View::Text"
  "Pod::POM::View::Doxygen"
)

foreach (MODULE IN LISTS CPAN_MODULES)
  string (REPLACE "::" "/" MODULE_FILE "${MODULE}.pm")
  basis_add_library (${MODULE_FILE} DESTINATION "${INSTALL_PERL_LIBRARY_DIR}/${BASIS_NAMESPACE}" WITH_PATH)
endforeach ()

# ----------------------------------------------------------------------------
# Perl modules
basis_add_library (BASIS/Utilities.pm)

basis_add_dependencies (Utilities_pm File_Which_pm)
