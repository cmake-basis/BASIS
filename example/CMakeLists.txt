# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of example application of software.
#
# By default, all content of the example folder is simply copied to the
# example directory of the installation tree.
##############################################################################

basis_install_directory ("." "${INSTALL_EXAMPLE_DIR}")
