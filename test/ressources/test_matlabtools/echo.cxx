/**
 * @file  echo.cxx
 * @brief Example MEX-file used to test build of MEX-files.
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

#include <mex.h>

// ---------------------------------------------------------------------------
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    // check arguments
    if (nrhs != 1) {
        mexErrMsgTxt("Missing message argument or too many arguments given.");
    }
    if (nlhs > 0) {
        mexErrMsgTxt("This function does not return anything.");
    }
    if (mxIsChar(prhs[0]) != 1 || mxGetM(prhs[0]) != 1) {
        mexErrMsgTxt("Argument must be a string.");
    }
    // convert argument to string
    char* msg = mxArrayToString(prhs[0]);
    if (!msg) {
        mexErrMsgTxt("Could not convert argument to string.");
    }
    // print message
    mexPrintf(msg);
    mexPrintf("\n");
    // clean up
    mxFree(msg);
}
