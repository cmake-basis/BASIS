# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of auxiliary data files.
##############################################################################

if (BUILD_PROJECT_TOOL AND INSTALL_ALL_TEMPLATES AND INSTALL_TEMPLATE_DIR)
  add_subdirectory (templates)
endif ()
