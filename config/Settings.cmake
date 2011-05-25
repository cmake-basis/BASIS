##############################################################################
# \file  Settings.cmake
# \brief Project settings.
#
# This file is included by basis_project_initialize ().
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################


# ============================================================================
# directories
# ============================================================================

# installation directory of project template files
set (
  INSTALL_TEMPLATE_DIR
    "\@INSTALL_ETC_DIR\@/template"
  CACHE PATH
    "Installation directory of project template (relative to INSTALL_PREFIX)."
)

mark_as_advanced (INSTALL_TEMPLATE_DIR)
string (CONFIGURE "${INSTALL_TEMPLATE_DIR}" INSTALL_TEMPLATE_DIR @ONLY)

# installation directory of CMake modules
set (
  INSTALL_MODULES_DIR
    "\@INSTALL_CONFIG_DIR\@"
  CACHE PATH
    "Installation directory of CMake modules (relative to INSTALL_PREFIX)."
)

mark_as_advanced (INSTALL_MODULES_DIR)
string (CONFIGURE "${INSTALL_MODULES_DIR}" INSTALL_MODULES_DIR @ONLY)

