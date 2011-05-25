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
    "${INSTALL_ETC_DIR}/template"
  CACHE PATH
    "Installation directory of project template (relative to INSTALL_PREFIX)."
)

# installation directory of CMake modules
set (
  INSTALL_MODULES_DIR
    "share/cmake/${PROJECT_NAME_LOWER}"
  CACHE PATH
    "Installation directory of CMake modules (relative to INSTALL_PREFIX)."
)

