##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of auxiliary data files.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

if (BUILD_PROJECT_TOOL AND INSTALL_ALL_TEMPLATES AND INSTALL_TEMPLATE_DIR)
  add_subdirectory (templates)
endif ()
