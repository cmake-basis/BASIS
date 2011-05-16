##############################################################################
# \file  CMakeLists.txt
# \brief CMakeLists.txt file of source code directory.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# configure and install CMake modules
add_subdirectory (cmake)

# install TCLAP header files
install (
  DIRECTORY   tclap
  DESTINATION "${INSTALL_INCLUDE_DIR}/${BASIS_INCLUDE_PREFIX}"
  COMPONENT   "${BASIS_LIBRARY_COMPONENT}"
  PATTERN     .svn EXCLUDE
  PATTERN     .git EXCLUDE
)

# add script used to instantiate the project template
basis_add_script (createbasisproject.sh)

