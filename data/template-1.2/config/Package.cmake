##############################################################################
# @file  Package.cmake
# @brief Package configuration.
#
# This file is included by the BasisPack module prior to the CPack module.
# It can be used to overwrite or extend the default package configuration.
#
# Copyright (c) <year>, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisSettings
##############################################################################

# ============================================================================
# package information/general settings
# ============================================================================

# overwrite default package information here.
#
# See http://www.vtk.org/Wiki/CMake:Packaging_With_CPack

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

