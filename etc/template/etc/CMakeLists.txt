##############################################################################
# \file  CMakeLists.txt
# \brief Build configuration of software configuration files.
#
# A "configuration file" is a local file used to control the operation of a
# program; it must be static and cannot be an executable binary.
#
# The data within this folder is required to execute the software tools of
# this project. Example data which is only required for an example run of
# the software are, on the other side, available in the example folder.
#
# By default, all content of this directory is simply installed in the
# 'etc' directory of the installation tree.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

install (
  DIRECTORY   ${CMAKE_CURRENT_SOURCE_DIR}/
  DESTINATION "${INSTALL_ETC_DIR}"
  PATTERN     CMakeLists.txt EXCLUDE
  PATTERN     *~             EXCLUDE
  PATTERN     .svn           EXCLUDE
  PATTERN     .git           EXCLUDE
)

