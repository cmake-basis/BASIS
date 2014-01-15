// ============================================================================
// Copyright (c) 2011-2012 University of Pennsylvania
// Copyright (c) 2013-2014 Andreas Schuh
// All rights reserved.
//
// See COPYING file for license information or visit
// http://opensource.andreasschuh.com/cmake-basis/download.html#license
// ============================================================================

/**
 * @file  testdriver.cxx
 * @brief Standalone test driver to run a test as subprocess.
 */

#define BASIS_STANDALONE_TESTDRIVER

#include <basis/testdriver.h>
#include <basis/subprocess.h>


// ---------------------------------------------------------------------------
int main(int argc, char *argv[])
{
    int result = 0;

    // parse command-line arguments
    testdriversetup(&argc, &argv);

    // setup test
    #include <basis/testdriver-before-test.inc>

    // run test subprocess
    if (testcmd.isSet()) {
        if (verbose.getValue() > 0) {
            cout << "$ " << Subprocess::tostring(testcmd.getValue()) << endl;
        }
        result = Subprocess::call(testcmd.getValue());
        if (result == -1) {
            cerr << "Failed to run/terminate test process!" << endl;
        }
    }

    // perform regression tests
    #include <basis/testdriver-after-test.inc>
 
    return result;
}
