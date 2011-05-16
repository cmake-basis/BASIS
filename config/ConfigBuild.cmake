##############################################################################
# \file  ConfigBuild.cmake
# \brief Default configuration of <Project>Config.cmake of build tree.
#
# Use the _CONFIG suffix for variables that are replaced in Config.cmake.in.
#
# \note The default build tree configurtion is included prior to this file.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# CMake module path
set (MODULE_PATH_CONFIG "${PROJECT_CODE_DIR}/cmake")

# URL of project template
set (TEMPLATE_URL_CONFIG "${PROJECT_DATA_DIR}/template")

