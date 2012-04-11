#! /usr/bin/env python

##############################################################################
# @file  foobar.py
# @brief A Python module with utility functions.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# private functions
# ============================================================================

# ----------------------------------------------------------------------------
def _foo(arg):
    """
    This is a private utility function.
    
    @param [in] arg Some argument.
    
    @returns Nothing.
    
    """
    print "Called private foo() function with argument: " + str(arg)

# ============================================================================
# public functions
# ============================================================================

# ----------------------------------------------------------------------------
def bar():
    """This is a public utility function."""
    print "Called public bar() function."
    _foo(42)
