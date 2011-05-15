##############################################################################
# \file  Package.cmake
# \brief Contains project specific CPack packaging information.
#
# This file is included by the module SbiaPack.cmake before the CPack
# package is included by this module. It can be used to overwrite the default
# CPack settings used by SbiaPack.cmake.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# package information / general settings
# ============================================================================

# Overwrite default package information set in SbiaPack.cmake here.
#
# \see http://www.vtk.org/Wiki/CMake:Packaging_With_CPack

# ============================================================================
# source package
# ============================================================================

# Pattern of files in the source tree that will not be packaged when building
# a source package. This is a list of patterns, e.g., "/CVS/", "/\\.svn/",
# ".swp$", ".#", "/#", "*~", and "cscope*", which are ignored by default.

set (
  CPACK_SOURCE_IGNORE_FILES
    "${CPACK_SOURCE_IGNORE_FILES}" # default ignore patterns
	# add further ignore patterns here
)

