/**
 * @file  testdriver.cxx
 * @brief Standalone test driver to run a test as subprocess.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
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
