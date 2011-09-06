##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of shell utilities.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# template files
install (
  FILES
    stdaux.sh.in
  DESTINATION
    "${INSTALL_SHELL_UTILITIES_DIR}"
)

# ----------------------------------------------------------------------------
# utilities
basis_add_script (shflags.sh MODULE)
