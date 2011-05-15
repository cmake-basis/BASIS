##############################################################################
# \file  ConfigInstall.cmake
# \brief Default configuration of <Project>Config.cmake of install tree.
#
# Use the _CONFIG suffix for variables that are replaced in Config.cmake.in.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################


# include directories
set (INCLUDE_DIR_CONFIG "")

if (INCLUDE_DIR_CONFIG)
  list (REMOVE_DUPLICATES INCLUDE_DIR_CONFIG)
endif ()

