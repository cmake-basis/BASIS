##############################################################################
#! @file  ConfigInstall.cmake
#! @brief Sets variables used in CMake package configuration for install tree.
#!
#! It is suggested to use _CONFIG as suffix for variable names that are to be
#! substituted in the Config.cmake.in template file in order to distinguish
#! these variables from the build configuration.
#!
#! Copyright (c) 2011 University of Pennsylvania. All rights reserved.
#! See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#!
#! Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#!
#! @ingroup CMakeTools
##############################################################################

#! @brief Include directories of package configuration of installation.
basis_set_config_path (INCLUDE_DIR_CONFIG "${INSTALL_INCLUDE_DIR}")

