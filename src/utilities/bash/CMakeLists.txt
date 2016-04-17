# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of BASH utilities.
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
