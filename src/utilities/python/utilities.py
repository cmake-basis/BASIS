##############################################################################
# @file  utilities.py
# @brief BASIS utilities.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisPythonUtilities
##############################################################################

"""
BASIS utilities.

This module defines the BASIS Utilities whose implementations are not
project-specific, i.e., do not make use of particular project attributes such
as the name or version of the project. The utility functions defined by this
module are intended for use in Python scripts and modules that are not build
as part of a particular BASIS project. Otherwise, the project-specific
implementations should be used instead, i.e., those defined by the basis.py
module of the project. The basis.py module and the submodules imported by
it are generated from template modules which are customized for the particular
project that is being build.

Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.
See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.

Contact: SBIA Group <sbia-software at uphs.upenn.edu>

"""

# import functions from utilities configured for BASIS itself and redefine
# them below such that their use outside of BASIS is appropriate
from .basis import *
from .basis import __all__

# ============================================================================
# configuration
# ============================================================================

from .basis import CONTACT, COPYRIGHT, LICENSE

PROJECT = ''
VERSION = ''
RELEASE = ''

# ============================================================================
# executable information
# ============================================================================

# ----------------------------------------------------------------------------
def print_contact(contact=None):
    """Print contact information.

    @param [in] contact Name of contact. If None, CONTACT is used.

    """
    if not contact: contact = CONTACT
    from .basis import print_contact as _print_contact
    _print_contact(contact)

# ----------------------------------------------------------------------------
def print_version(name, version, project=None, copyright=None, license=None):
    """Print version information including copyright and license notices.

    Examples:
    @code
    print_version('foo', '1.2.3')
    print_version('foo', '1.2.3', project='BASIS')
    print_version('foo', '1.2.3', project='BASIS', copyright='2012 University of Pennsylvania', license='')
    @endcode
    where the last command will print
    @verbatim
    foo (BASIS) 1.2.3
    Copyright (c) 2012 University of Pennsylvania. All rights reserved.
    @endverbatim

    If you prefer to only output the program version, use the command
    @verbatim
    print_version('foo', '1.2.3', project='', copyright='', license='')
    @endverbatim
    which gives
    @verbatim
    foo 1.2.3
    @endverbatim

    @param [in] name      Name of executable. Should not be set programmatically
                          to the first argument of the @c __main__ module, but
                          a string literal instead.
    @param [in] version   Version of executable, e.g., release of project
                          this executable belongs to. Defaults to RELEASE if
                          set, otherwise this argument is required.
    @param [in] project   Name of project this executable belongs to.
                          Defaults to PROJECT if @c None and this global variable
                          is set. Otherwise or if an empty string is given,
                          no project information is printed.
    @param [in] copyright The copyright notice, excluding the common prefix
                          "Copyright (c) " and suffix ". All rights reserved.".
                          If @c None, COPYRIGHT is used. If an empty string,
                          no copyright notice is printed.
    @param [in] license   Information regarding licensing. If @c None, LICENSE
                          is used. If an empty string, no license information
                          is printed.

    """
    # defaults, must be set here instead of the argument list such that a change
    # of these global variables is possible after the function was defined
    if not version:       version   = RELEASE
    if project   is None: project   = PROJECT
    if copyright is None: copyright = COPYRIGHT
    if license   is None: license   = LICENSE
    if not version: raise Exception("print_version(): Missing version argument")
    # call print_version() of basis.py
    from .basis import print_version as _print_version
    _print_version(name, version, project=project, copyright=copyright, license=license)
