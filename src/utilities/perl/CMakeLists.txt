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

# The Perl utilities can be found in <src>/lib/perl5/. Note that the packages
# found in the lib/ directory are automatically configured, build, and installed
# by BASIS.


# TODO Remove the following once this idea is implemented.
basis_add_library (cpan_file_which   "${PROJECT_LIBRARY_DIR}/perl5/SBIA/File/Which.pm")
basis_add_library (cpan_readonly     "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Readonly.pm")
basis_add_library (cpan_params_util  "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Params/Util.pm")
basis_add_library (cpan_sub_install  "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Sub/Install.pm")
basis_add_library (cpan_data_optlist "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Data/OptList.pm")
basis_add_library (cpan_sub_exporter "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Sub/Exporter.pm")

basis_add_library (
  cpan_pod_pom
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Constants.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Nodes.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Test.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/View.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Begin.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Code.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Content.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/For.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Head1.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Head2.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Head3.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Head4.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Item.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Over.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Pod.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Sequence.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Text.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/Node/Verbatim.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/View/Doxygen.pm" # BASIS addition
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/View/HTML.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/View/Pod.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/Pod/POM/View/Text.pm"
)

basis_add_library (
  doxyfilter_modules
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/BASIS/DoxyFilter.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/BASIS/DoxyFilter/Bash.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/BASIS/DoxyFilter/CMake.pm"
    "${PROJECT_LIBRARY_DIR}/perl5/SBIA/BASIS/DoxyFilter/Python.pm"
)

basis_target_link_libraries (cpan_data_optlist cpan_params_util cpan_sub_install)
basis_target_link_libraries (cpan_sub_exporter cpan_data_optlist)

# correct source directory of libraries
foreach (T IN ITEMS cpan_file_which cpan_readonly cpan_params_util
                    cpan_sub_install cpan_data_optlist cpan_sub_exporter
                    cpan_pod_pom doxyfilter_modules ${UTILITIES})
  basis_set_target_properties (${T} PROPERTIES SOURCE_DIRECTORY "${PROJECT_LIBRARY_DIR}/perl5")
endforeach ()

# ----------------------------------------------------------------------------
# utilities
basis_get_target_name (UTILITIES ${BASIS_PERL_UTILITIES_LIBRARY})
basis_add_library (${UTILITIES} "${PROJECT_LIBRARY_DIR}/perl5/SBIA/BASIS/Utilities.pm")
basis_target_link_libraries (${UTILITIES} cpan_file_which cpan_sub_exporter)
basis_set_target_properties (${UTILITIES} PROPERTIES SOURCE_DIRECTORY "${PROJECT_LIBRARY_DIR}/perl5")
