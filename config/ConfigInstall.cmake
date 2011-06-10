##############################################################################
# \file  ConfigInstall.cmake
# \brief Sets variables used in CMake package configuration of install tree.
#
# It is suggested to use _CONFIG as suffix for variable names that are to be
# substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# \note The default install tree configuration is included prior to this file.
#       Hence, the variables are valid even if a custom configuration is used
#       and default values can be overwritten in this file.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# CMake module path
basis_set_config_path (MODULE_PATH_CONFIG "${INSTALL_MODULES_DIR}")

# URL of project template
basis_set_config_path (TEMPLATE_URL_CONFIG "${INSTALL_TEMPLATE_DIR}")

