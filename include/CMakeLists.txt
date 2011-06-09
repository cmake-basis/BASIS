##############################################################################
# \file  CMakeLists.txt
# \brief Buid configuration of public header files.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# basis headers
install (
  DIRECTORY   "sbia/${PROJECT_NAME_LOWER}"
  DESTINATION "${INSTALL_INCLUDE_DIR}/sbia"
  COMPONENT   "${BASIS_LIBRARY_COMPONENT}"
  PATTERN     ".svn" EXCLUDE
  PATTERN     ".git" EXCLUDE
)

# ----------------------------------------------------------------------------
# TCLAP - as an exception, install headers next to BASIS includes subdirectory
install (
  DIRECTORY   "sbia/tclap"
  DESTINATION "${INSTALL_INCLUDE_DIR}/sbia"
  COMPONENT   "${BASIS_LIBRARY_COMPONENT}"
  PATTERN     ".svn" EXCLUDE
  PATTERN     ".git" EXCLUDE
)

