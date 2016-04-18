# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of command-line tools.
##############################################################################

add_subdirectory (basisproject)
add_subdirectory (basistest)
add_subdirectory (doxyfilter)

# platform independent "which" command - not required on Unix
if (NOT UNIX)
  basis_add_executable (which "${PROJECT_CODE_DIR}/utilities/python/which.py")
  basis_set_target_properties (which PROPERTIES SYMLINK_NAME NONE)
  basis_finalize_targets (which)
endif ()
