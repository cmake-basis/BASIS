/**
 * @file  echo.cxx
 * @brief Example MEX-file used to test build of MEX-files.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://sbia-svn.uphs.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
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
