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
file (
  RELATIVE_PATH
    MODULE_PATH_CONFIG
    "${INSTALL_PREFIX}/${INSTALL_LIB_DIR}"
    "${INSTALL_PREFIX}/${INSTALL_SHARE_DIR}/cmake"
)

set (MODULE_PATH_CONFIG "\${CMAKE_CURRENT_LIST_DIR}/${MODULE_PATH_CONFIG}")

