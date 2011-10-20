/**
 * @file  bar.cxx
 * @brief Implementation of public utility functions.
 *
 * Copyright (c) University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <iostream>

#include <sbia/hellobasis/bar.h>


// acceptable in .cxx file
using namespace std;


// ---------------------------------------------------------------------------
void bar()
{
    cout << "Called the public bar() function." << endl;
}
