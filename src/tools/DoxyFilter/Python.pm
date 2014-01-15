# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  DoxyFilter/Python.pm
# @brief Doxygen filter for Python.
#
# This filter simply converts doc string comments to Doxygen-style
# comments in order to allow the use of Doxygen tags within the
# doc strings which are otherwise ignored by Doxygen.
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
