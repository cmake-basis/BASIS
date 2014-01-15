##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of BASH utilities.
#
# Copyright (c) 2011-2012 University of Pennsylvania. <br />
# Copyright (c) 2013-2014 Andreas Schuh.              <br />
# All rights reserved.                                <br />
#
# See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
# or COPYING file for license information.
#
# Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
#          report issues at https://github.com/schuhschuh/cmake-basis/issues
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
