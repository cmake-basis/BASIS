##############################################################################
# \file  CMakeLists.txt
# \brief CMake configuration of auxiliary data files.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# install project template
install (
  DIRECTORY   template/
  DESTINATION "${INSTALL_DATA_DIR}"
  PATTERN     .svn EXCLUDE
  PATTERN     .git EXCLUDE
)

