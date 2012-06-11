##############################################################################
# @file  sbia/basis/__init__.py
# @brief Init file for BASIS package.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisPythonUtilities
##############################################################################

"""
Init file for BASIS package.

This __init__.py file imports all BASIS Python utility functions and redefines
those which are project-specific such that they can be used without any
association with a particular project.

Copyright (c) 2012 University of Pennsylvania. All rights reserved.
See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.

Contact: SBIA Group <sbia-software at uphs.upenn.edu>

"""

from sbia.basis.which  import WhichError, which, whichall, whichgen
from sbia.basis.stdaux import execute_process, SubprocessError
from sbia.basis.stdaux import print_version as _print_version
from sbia.basis.stdaux import print_contact

def print_version(name, project=None, copyright=None, license=None):
    _print_version(name, project=None, copyright=copyright, license=license)

from sbia.basis.executabletargetinfo import get_target_uid, \
        is_known_target, get_executable_name, get_executable_directory, \
        get_executable_path
