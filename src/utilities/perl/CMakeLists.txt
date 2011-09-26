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

# ----------------------------------------------------------------------------
# modules
set (PERL_MODULES
  Test::Class
  Test::Class::Load
  Test::Class::MethodInfo
)

foreach (MODULE ${PERL_MODULES})
  string (REGEX REPLACE "::" "/" MODULE_FILE "${MODULE}")
  set (MODULE_FILE "${MODULE_FILE}.pm")
  basis_get_filename_component (DIR "${MODULE_FILE}" PATH)
  basis_script_target_name (MODULE_TARGET "${MODULE_FILE}")
  basis_add_script (${MODULE_TARGET} TEST MODULE "${MODULE_FILE}")
  basis_set_target_properties (
    ${MODULE_TARGET}
    PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "${TESTING_LIBRARY_DIR}/${DIR}"
  )
endforeach ()
