##############################################################################
# \file  ConfigBuild.cmake
# \brief Default configuration of <Project>Config.cmake of build tree.
#
# Use the _CONFIG suffix for variables that are replaced in Config.cmake.in.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################


# include directories
file (RELATIVE_PATH CODE_DIR "${PROJECT_SOURCE_DIR}" "${PROJECT_CODE_DIR}")

set (
  INCLUDE_DIR_CONFIG
    "${PROJECT_BINARY_DIR}/${CODE_DIR}"
    "${PROJECT_CODE_DIR}"
)

