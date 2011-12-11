/**
 * @file  testdriver.hxx
 * @brief Default test driver implementation.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup CppUtilities
 */

#pragma once
#ifndef _SBIA_BASIS_TESTDRIVER_HXX
#define _SBIA_BASIS_TESTDRIVER_HXX


#if HAVE_ITK
#  include "testdriver-itk.hxx"
#endif


// acceptable in .cxx file of test driver
using namespace sbia::basis;


// ===========================================================================
// initialization
// ===========================================================================

// ---------------------------------------------------------------------------
void testdriversetup(int* argc, char** argv[])
{
    try {
        // -------------------------------------------------------------------
        // define additional command-line arguments

        PositionalArg testname(
                "testname",
                "The name of the test to run. Displays a list of available tests"
                " if this argument is omitted and waits for the user to input"
                " the number of the test to run and exist with error if an"
                " invalid test number was specified.",
                false, "", "<test>");

        // -------------------------------------------------------------------
        // construct command-line
        CmdLine cmd(
                // program identification
                "basistest-driver", cProjectName,
                // description
                "This program alters the environment, runs a test and "
                "compares the output image to one or more baseline images.",
                // example usage
                "EXECNAME GaussFilter --compare output.nii baseline.nii"
                "\n"
                "Runs the test named GaussFilter which presumably writes the"
                " gaussian smoothed image to the image file output.nii."
                " Compares the image produced by the test to the reference"
                " image named baseline.nii with default intensity tolerance.",
                // version information
                cVersionAndRevision,
                "Copyright (c) 2011 University of Pennsylvania. "
                "All rights reserved.");

        cmd.add(add_before_libpath);
        cmd.add(add_before_env);
        cmd.add(compare);
        cmd.add(max_number_of_differences);
        cmd.add(intensity_tolerance);
        cmd.add(tolerance_radius);
        cmd.add(redirect_output);
        cmd.add(max_number_of_threads);
        cmd.add(full_output);
        cmd.add(testname);

        // -------------------------------------------------------------------
        // parse command-line
        cmd.parse(*argc, *argv);

        // -------------------------------------------------------------------
        // leave only test name in argv[]
        if (testname.isSet()) {
            int i = 0;
            while (i < (*argc) && testname.getValue() != (*argv)[i]) i++;
            *argc = 2;
            (*argv)[1] = (*argv)[i];
            (*argv)[2] = NULL;
        } else {
            *argc = 1;
            (*argv)[1] = NULL;
        }

    // -----------------------------------------------------------------------
    // catch unhandled exceptions - parse errors are already taken care of
    } catch (CmdLineException& e) {
        // invalid command-line specification
        cerr << e.error() << endl;
        exit(1);
    }

#if HAVE_ITK
    RegisterRequiredFactories();
#endif
}

// ===========================================================================
// image regression testing
// ===========================================================================

// ---------------------------------------------------------------------------
vector<string> get_baseline_filenames(string filename_template)
{
    vector<string> baselines;

    ifstream ifs(filename_template.c_str());
    if (ifs) baselines.push_back(filename_template);

    int               x   = 0;
    string::size_type pos = filename_template.rfind(".");
    string            suffix;

    if (pos != string::npos) {
        suffix = filename_template.substr(pos);
        filename_template.erase(pos);
    }
    while (++x) {
        ostringstream filename;
        filename << filename_template << '.' << x << suffix;
        ifstream ifs(filename.str().c_str());
        if (!ifs) break;
        ifs.close();
        baselines.push_back(filename.str());
    }
    return baselines;
}

// ---------------------------------------------------------------------------
int image_regression_test(const char*  imagefile,
                          const char*  baseline,
                          double       intensity_tolerance,
                          unsigned int max_number_of_differences,
                          unsigned int tolerance_radius,
                          int          report)
{
#if HAVE_ITK
    return RegressionTestImage(imagefile,
                               baseline,
                               report,
                               intensity_tolerance,
                               max_number_of_differences,
                               tolerance_radius);
#else
    BASIS_THROW(runtime_error, "Not implemented yet! Use ITK implementation instead.");
#endif
}


#endif // _SBIA_BASIS_TESTDRIVER_HXX
