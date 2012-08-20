##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of BASH utilities.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# template files
basis_install (
  FILES
    basis.sh.in # project-specific utilities
  DESTINATION
    "${INSTALL_BASH_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# utilities
basis_get_target_name (UTILITIES "${BASIS_BASH_UTILITIES_LIBRARY}")

basis_add_library (
  ${UTILITIES}
    "config.sh"    # constants, build configuration
    "core.sh"      # fundamental core functions
    "os/path.sh"   # path manipulation functions
    "utilities.sh" # project independent utilities
    "shflags.sh"   # command-line parsing library
    "shtap.sh"     # unit testing framework
)

add_dependencies (${ALL_UTILITIES} ${UTILITIES})
