/**
 * @file  foo.cxx
 * @brief Implementation of private utility functions.
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
