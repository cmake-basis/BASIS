# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of software.
##############################################################################

# ============================================================================
# library target(s)
# ============================================================================

# Add library target for each library using basis_add_library ().
#
# This command can not only be used to build libraries from C/C++, but also source
# code written in other programming languages such as Java, Python, Perl, BASH,
# and MATLAB. Note that here we consider modules written in a scripting language
# which are no executables but to be included by other scripts written in the
# particular language as libraries.

add_subdirectory (cmake)     # CMake modules
add_subdirectory (utilities) # implementation utilities

if (Sphinx_FOUND)
  add_subdirectory (sphinx)  # Sphinx extensions and themes
endif ()

# ============================================================================
# executable target(s)
# ============================================================================

# Add executable target for each executable program using basis_add_executable().
#
# This command can not only be used to build executables from C/C++, but also
# source code written in other programming languages such as Java, Python, Perl,
# BASH, and MATLAB.

add_subdirectory (tools)
