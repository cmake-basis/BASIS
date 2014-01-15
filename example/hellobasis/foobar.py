#! /usr/bin/env python

##############################################################################
# @file  foobar.py
# @brief A Python module with utility functions.
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
