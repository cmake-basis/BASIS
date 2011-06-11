##############################################################################
# \file  CMakeLists.txt
# \brief Build configuration of auxiliary data files.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# install project template
install (
  DIRECTORY   template/
  DESTINATION "${INSTALL_TEMPLATE_DIR}"
  PATTERN     .svn EXCLUDE
  PATTERN     .git EXCLUDE
)

