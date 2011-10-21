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
# build options
# ============================================================================

option (BUILD_CXX_UTILITIES    "Whether to build the C++ utilities."    ON)
option (BUILD_PYTHON_UTILITIES "Whether to build the Python utilities." ON)
option (BUILD_PERL_UTILITIES   "Whether to build the Perl utilities."   ON)

if (UNIX)
  option (BUILD_BASH_UTILITIES "Whether to build the BASH utilities." ON)
else ()
  set (BUILD_BASH_UTILITIES OFF)
endif ()

# ============================================================================
# directories
# ============================================================================

# installation directory of CMake modules
set (INSTALL_MODULES_DIR "${INSTALL_SHARE_DIR}/modules")

# installation directory of utilities template files
set (INSTALL_CXX_TEMPLATES_DIR    "${INSTALL_SHARE_DIR}/templates/src")
set (INSTALL_JAVA_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/templates/src")
set (INSTALL_PYTHON_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/templates/src")
set (INSTALL_PERL_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/templates/src")
set (INSTALL_BASH_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/templates/src")
set (INSTALL_MATLAB_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/templates/src")

# installation directory of project template files
set (INSTALL_TEMPLATE_DIR "${INSTALL_SHARE_DIR}/templates/project")
