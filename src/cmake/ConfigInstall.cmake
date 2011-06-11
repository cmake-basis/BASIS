##############################################################################
# \file  ConfigInstall.cmake
# \brief Sets variables used in CMake package configuration for install tree.
#
# It is suggested to use _CONFIG as suffix for variable names that are to be
# substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# include directories
basis_set_config_path (INCLUDE_DIR_CONFIG "${INSTALL_INCLUDE_DIR}")

