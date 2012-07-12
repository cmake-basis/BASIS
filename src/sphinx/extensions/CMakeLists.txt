##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Sphinx extensions.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

basis_add_library (breathe)
basis_add_library (doxylink)

basis_set_target_properties (breathe doxylink PROPERTIES PREFIX "${SPHINX_EXTENSIONS_PREFIX}")
