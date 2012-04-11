/**
 * @file  foo.cxx
 * @brief Implementation of private utility functions.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <iostream>

#include "foo.h"


// acceptable in .cxx file
using namespace std;


// ---------------------------------------------------------------------------
void foo()
{
    cout << "Called the private foo() function." << endl;
}
