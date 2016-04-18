# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of CMake modules.
##############################################################################

set (INSTALL_BASIS_MODULES_DIR "${INSTALL_MODULES_DIR}")
add_subdirectory (modules)

set (INSTALL_BASIS_MODULES_DIR "${INSTALL_FIND_MODULES_DIR}")
add_subdirectory (find)
