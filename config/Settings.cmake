##############################################################################
# \file  Settings.cmake
# \brief General project build configuration.
#
# This file can be used to overwrite the BASIS build configuration as defined
# by the BasisSettings module and to add project specific settings.
#
# This file is included by basis_project_initialize () if found in the
# PROJECT_CONFIG_DIR directory.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################


# ============================================================================
# directories
# ============================================================================

# installation directory of project template files
set (
  INSTALL_TEMPLATE_DIR
    "\@INSTALL_SHARE_DIR\@/template"
  CACHE PATH
    "Installation directory of project template (relative to INSTALL_PREFIX)."
)

mark_as_advanced (INSTALL_TEMPLATE_DIR)
string (CONFIGURE "${INSTALL_TEMPLATE_DIR}" INSTALL_TEMPLATE_DIR @ONLY)

# installation directory of CMake modules
set (
  INSTALL_MODULES_DIR
    "\@INSTALL_SHARE_DIR\@/modules"
  CACHE PATH
    "Installation directory of CMake modules (relative to INSTALL_PREFIX)."
)

mark_as_advanced (INSTALL_MODULES_DIR)
string (CONFIGURE "${INSTALL_MODULES_DIR}" INSTALL_MODULES_DIR @ONLY)

