##############################################################################
# \file  Package.cmake
# \brief Package information.
#
# This file is included by the module BasisPack.cmake before the CPack module.
# It can be used to overwrite or extend the default CPack settings of BASIS.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# package information/general settings
# ============================================================================

# overwrite default package information here.
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

