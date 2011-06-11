##############################################################################
# \file  CMakeLists.txt
# \brief Build configuration of auxiliary data files.
#
# The data within this folder is required to execute the software tools of
# this project. Example data which is only required for an example run of
# the software are, on the other side, available in the example folder.
#
# By default, all content of this directory is simply installed in the
# INSTALL_SHARE_DIR of the installation tree. To group data files, place
# them in proper subdirectories which will be copied to the
# INSTALL_SHARE_DIR.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

install (
  DIRECTORY   ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION "${INSTALL_SHARE_DIR}"
  PATTERN     CMakeLists.txt EXCLUDE
  PATTERN     *~             EXCLUDE
  PATTERN     .svn           EXCLUDE
  PATTERN     .git           EXCLUDE
)

