/**
 * @file  testdriver.cxx
 * @brief Standalone test driver to run a test as subprocess.
 *
 * Copyright (c) 2011-2012 University of Pennsylvania. <br />
 * Copyright (c) 2013-2014 Andreas Schuh.              <br />
 * All rights reserved.                                <br />
 *
 * See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
 * or COPYING file for license information.
 *
 * Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
 *          report issues at https://github.com/schuhschuh/cmake-basis/issues
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
