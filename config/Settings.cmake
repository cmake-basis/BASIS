##############################################################################
# @file  Settings.cmake
# @brief General project build configuration.
#
# This file can be used to overwrite the BASIS build configuration as defined
# by the BasisSettings module and to add project specific settings.
#
# This file is included by basis_project_initialize() if found in the
# PROJECT_CONFIG_DIR directory.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# directories
# ============================================================================

# installation directory of project template files
set (
  INSTALL_TEMPLATE_DIR
    "\@INSTALL_SHARE_DIR\@/project"
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

# installation directory of template files
set (
  INSTALL_CXX_TEMPLATES_DIR
    "\@INSTALL_SHARE_DIR\@/templates"
  CACHE PATH
    "Installation directory of C++ template files (relative to INSTALL_PREFIX)."
)

mark_as_advanced (INSTALL_CXX_TEMPLATES_DIR)
string (CONFIGURE "${INSTALL_CXX_TEMPLATES_DIR}" INSTALL_CXX_TEMPLATES_DIR @ONLY)

set (
  INSTALL_BASH_TEMPLATES_DIR
    "\@INSTALL_SHARE_DIR\@/templates"
  CACHE PATH
    "Installation directory of BASH template files (relative to INSTALL_PREFIX)."
)

mark_as_advanced (INSTALL_BASH_TEMPLATES_DIR)
string (CONFIGURE "${INSTALL_BASH_TEMPLATES_DIR}" INSTALL_BASH_TEMPLATES_DIR @ONLY)
