##############################################################################
# \file  ConfigBuild.cmake
# \brief Sets variables used in CMake package configuration of build tree.
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
file (RELATIVE_PATH CODE_DIR "${PROJECT_SOURCE_DIR}" "${PROJECT_CODE_DIR}")

set (
  INCLUDE_DIR_CONFIG
    "${PROJECT_BINARY_DIR}/${CODE_DIR}"
    "${PROJECT_CODE_DIR}"
)

