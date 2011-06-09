##############################################################################
# \file  CMakeLists.txt
# \brief Build configuration of basic utility library.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

set (BASIS_SOURCES
    "path.h"
    "path.cc"
)

basis_add_library (basis STATIC ${BASIS_SOURCES})

