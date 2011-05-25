##############################################################################
# \file  CMakeLists.txt
# \brief Build configuration of software configuration files.
#
# A "configuration file" is a local file used to control the operation of a
# program; it must be static and cannot be an executable binary.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# install project template
install (
  DIRECTORY   template/
  DESTINATION "${INSTALL_TEMPLATE_DIR}"
  PATTERN     .svn EXCLUDE
  PATTERN     .git EXCLUDE
)

