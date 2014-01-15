##############################################################################
# @file  basis/__init__.py
# @brief Initialization file of BASIS Utilities package.
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

__all__ = [] # use of import * is discouraged

# import utilities module
from . import utilities
# further, import main functions into this module's namespace
from .utilities import print_contact, print_version, \
                       exepath, exename, exedir, execute, SubprocessError
