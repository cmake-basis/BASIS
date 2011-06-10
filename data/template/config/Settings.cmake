##############################################################################
# \file  Settings.cmake
# \brief General project build configuration.
#
# This file can be used to overwrite the BASIS build configuration as defined
# by the BasisSettings module and to add project specific settings.
#
# This file is included by basis_project_initialize () if found in the
# PROJECT_CONFIG_DIR directory.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# options
# ============================================================================

# add options here using the option () command
#
# \see http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:option

# ============================================================================
# build configuration(s)
# ============================================================================

# set compiler and linker flags for the different supported build configurations
#
# The available build configurations are listed in CMAKE_CONFIGURATION_TYPES.
# For each build configuration, there exist the CMake variables
# CMAKE_C_FLAGS_<config> and CMAKE_CXX_FLAGS_<config> which specify the
# compiler flags, where <config> is the name of the build configuration in
# uppercase letters only. Accordingly, the variables
# CMAKE_EXE_LINKER_FLAGS_<config>, CMAKE_MODULE_LINKER_FLAGS_<config>,
# and CMAKE_SHARED_LINKER_FLAGS_<config> specify the linker flags for
# the corresponding target types.
#
# In order to only add compiler and/or linker flags instead of overwriting
# the default flags, only append the values of the corresponding variables.
#
# Example:
# \code
# set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
# \endcode
#
# \see BasisSettings.cmake


