# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  basis/__init__.py
# @brief Initialization file of BASIS Utilities package.
##############################################################################

__all__ = [] # use of import * is discouraged

# import utilities module
from . import utilities
# further, import main functions into this module's namespace
from .utilities import print_contact, print_version, \
                       exepath, exename, exedir, execute, SubprocessError
