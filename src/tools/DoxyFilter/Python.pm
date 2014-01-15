##############################################################################
# @file  DoxyFilter/Python.pm
# @brief Doxygen filter for Python.
#
# This filter simply converts doc string comments to Doxygen-style
# comments in order to allow the use of Doxygen tags within the
# doc strings which are otherwise ignored by Doxygen.
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
#
# @ingroup BasisTools
##############################################################################

package BASIS::DoxyFilter::Python;
use base BASIS::DoxyFilter;

# ============================================================================
# states
# ============================================================================

use constant {
    MAIN     => 0,
    FUNCTION => 1,
    CLASS    => 2,
    METHOD   => 3
};

# ============================================================================
# transitions
# ============================================================================

use constant TRANSITIONS => [
];

# ============================================================================
# public
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Constructs a Python Doxygen filter.
sub new
{
    shift->SUPER::new(MAIN, TRANSITIONS);
}


1;
