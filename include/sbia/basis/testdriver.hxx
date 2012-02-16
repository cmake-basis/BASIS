/**
 * @file  testdriver.hxx
 * @brief Default test driver implementation.
 *
 * Copyright (c) 2011, University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _SBIA_BASIS_TESTDRIVER_HXX
#define _SBIA_BASIS_TESTDRIVER_HXX


#if WINDOWS
#  include <Winsock2.h> // gethostbyname()
#  ifdef max
#    undef max
#  endif
#  pragma comment(lib, "Ws2_32.lib")
#else
#  include <netdb.h> // gethostbyname()
#endif

#ifdef ITK_VERSION
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
        string name;
        #ifdef TESTDRIVER_NAME
            name = TESTDRIVER_NAME;
        #else
            name = "testdriver";
        #endif
        #ifdef ITK_VERSION
            name += " build with ITK ";
            name += ITK_VERSION;
        #endif

        // -------------------------------------------------------------------
        // construct command-line
        CmdLine cmd(
                // program identification
                name, cProjectName,
                // description
                "This program alters the environment, runs a test and "
                "compares the output image to one or more baseline images.",
                // example usage
                "EXECNAME GaussFilter --compare output.nii baseline.nii"
                "\n"
                "Runs the test GaussFilter which presumably writes the"
                " gaussian smoothed image to the image file output.nii."
                " Compares the image produced by the test to the reference"
                " image named baseline.nii with default intensity tolerance.",
                // version information
                cVersionAndRevision,
                "Copyright (c) 2011 University of Pennsylvania."
                " All rights reserved.");

        cmd.add(add_before_libpath);
        cmd.add(add_before_env);
        cmd.add(compare);
        cmd.add(max_number_of_differences);
        cmd.add(intensity_tolerance);
        cmd.add(tolerance_radius);
        cmd.add(redirect_output);
        cmd.add(max_number_of_threads);
        cmd.add(full_output);
        cmd.add(verbose);

        #ifdef BASIS_STANDALONE_TESTDRIVER
        cmd.xorAdd(noprocess, testcmd);
        #else
        cmd.add(testcmd);
        #endif

        // -------------------------------------------------------------------
        // parse command-line
        cmd.parse(*argc, *argv);

        // -------------------------------------------------------------------
        // rearrange argc and argv of main()
        if (testcmd.isSet()) {
            for (unsigned int i = 0; i < testcmd.getValue().size(); i++) {
                for (int j = 1; j < (*argc); j++) {
                    if (testcmd.getValue()[i] == (*argv)[j]) {
                        (*argv)[i + 1] = (*argv)[j];
                        break;
                    }
                }
            }
            *argc = static_cast<int>(testcmd.getValue().size()) + 1;
            (*argv)[*argc] = NULL;
        } else {
            *argc = 1;
            (*argv)[1] = NULL;
        }

        // Reset ignoring flag of TCLAP library. Otherwise, when a test
        // uses the TCLAP library to parse its arguments, the labeled
        // arguments will be immediately ignored.
        // This required the addition of the stopIgnoring() method to TCLAP::Arg.
        TCLAP::Arg::stopIgnoring();

    // -----------------------------------------------------------------------
    // catch specification exceptions - parse errors are already taken care of
    } catch (CmdLineException& e) {
        cerr << e.error() << endl;
        exit(1);
    }

    // -----------------------------------------------------------------------
    // add host name as Dart/CDash measurement
    char hostname[256] = "unknown";
    #if WINDOWS
        WSADATA wsaData;
        WSAStartup(MAKEWORD(2, 2), &wsaData);
        gethostname(hostname, sizeof(hostname));
        WSACleanup();
    #else
        gethostname(hostname, sizeof(hostname));
    #endif
    hostname[255] = '\0';

    cout << "<DartMeasurement name=\"Host Name\" type=\"string\">";
    cout << hostname;
    cout <<  "</DartMeasurement>" << endl;

    #ifdef ITK_VERSION
    cout << "<DartMeasurement name=\"ITK Version\" type=\"string\">";
    cout << ITK_VERSION;
    cout <<  "</DartMeasurement>" << endl;
    #endif

    // -----------------------------------------------------------------------
    // register ITK IO factories
    #ifdef ITK_VERSION
        RegisterRequiredFactories();
    #endif
}

// ===========================================================================
// image regression testing
// ===========================================================================

// ---------------------------------------------------------------------------
void CompareVisitor::visit()
{
    assert(compare.getValue().size() != 0);
    assert((compare.getValue().size() % 2) == 0);

    RegressionTest regression_test;

    regression_test.test_image_file           = compare.getValue()[compare.getValue().size() - 2];
    regression_test.baseline_image_file       = compare.getValue()[compare.getValue().size() - 1];
    regression_test.intensity_tolerance       = intensity_tolerance.getValue();
    regression_test.max_number_of_differences = max_number_of_differences.getValue();
    regression_test.tolerance_radius          = tolerance_radius.getValue();

    regression_tests.push_back(regression_test);
}

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
    #ifdef ITK_VERSION
        return RegressionTestImage(imagefile,
                                   baseline,
                                   report,
                                   intensity_tolerance,
                                   max_number_of_differences,
                                   tolerance_radius);
    #else
        BASIS_THROW(runtime_error,
                    "Not implemented yet! Use ITK implementation instead.");
    #endif
}


#endif // _SBIA_BASIS_TESTDRIVER_HXX
