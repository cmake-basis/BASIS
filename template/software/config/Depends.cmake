##############################################################################
# \file  Depends.cmake
# \brief Contains find_package () commands to resolve external dependencies.
#
# This file is included by the macro sbia_project () if found in the
# directory specified by PROJECT_CONFIG_DIR which is set in the root
# CMakeLists.txt file. It is supposed to resolve dependencies to external
# packages using the find_package () command of CMake.
#
# If no CMake Find module (i.e., Find<Package>.cmake) for an external package
# is available yet and the package does not provide a <Package>Config.cmake or
# <package>-config.cmake file, write your own Find module and store it in the
# 'CMake' folder of the project or have someone else write one for you.
# Consider also to inform the maintainer of the project template at SBIA to
# integrate your Find module into the collection of lab-wide available CMake
# modules.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# intra-project
# ============================================================================

sbia_include_directories ("${PROJECT_SRC_DIR}")

# ============================================================================
# external
# ============================================================================
