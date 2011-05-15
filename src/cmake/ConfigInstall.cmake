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
file (
  RELATIVE_PATH
    INCLUDE_DIR_CONFIG
    "${INSTALL_PREFIX}/${INSTALL_LIB_DIR}"
    "${INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}"
)

set (INCLUDE_DIR_CONFIG "\${CMAKE_CURRENT_LIST_DIR}/${INCLUDE_DIR_CONFIG}")

