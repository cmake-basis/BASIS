##############################################################################
# \file  ConfigBuild.cmake
# \brief Sets variables used in CMake package configuration of build tree.
#
# It is suggested to use _CONFIG as suffix for variable names that are to be
# substituted in the Config.cmake.in template file in order to distinguish
# these variables from the build configuration.
#
# \note The default build tree configuration is included prior to this file.
#       Hence, the variables are valid even if a custom configuration is used
#       and default values can be overwritten in this file.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# CMake module path
set (MODULE_PATH_CONFIG "${PROJECT_CODE_DIR}/cmake")

# libraries
basis_get_target_property (OUTPUT_NAME "basis_utils" OUTPUT_NAME)
basis_get_target_property (PREFIX      "basis_utils" PREFIX)
basis_get_target_property (SUFFIX      "basis_utils" SUFFIX)

if (OUTPUT_NAME)
  set (UTILS_LIBRARY_CONFIG "${OUTPUT_NAME}")
else ()
  set (UTILS_LIBRARY_CONFIG "basis_utils")
endif ()
if (PREFIX)
  set (UTILS_LIBRARY_CONFIG "${PREFIX}${UTILS_LIBRARY_CONFIG}")
endif ()
if (SUFFIX)
  set (UTILS_LIBRARY_CONFIG "${UTILS_LIBRARY_CONFIG}${SUFFIX}")
endif ()

set (UTILS_LIBRARY_CONFIG "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/lib/${UTILS_LIBRARY_CONFIG}")

# URL of project template
set (TEMPLATE_URL_CONFIG "${PROJECT_ETC_DIR}/template")

