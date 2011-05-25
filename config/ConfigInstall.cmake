##############################################################################
# \file  ConfigInstall.cmake
# \brief Default configuration of <Project>Config.cmake of install tree.
#
# Use the _CONFIG suffix for variables that are replaced in Config.cmake.in.
#
# \note The default install tree configuration is included prior to this file.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# CMake module path
basis_set_config_path (MODULE_PATH_CONFIG "${INSTALL_MODULES_DIR}")

# URL of project template
basis_set_config_path (TEMPLATE_URL_CONFIG "${INSTALL_TEMPLATE_DIR}")

