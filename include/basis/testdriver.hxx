/**
 * @file  testdriver.hxx
 * @brief Default test driver implementation.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _BASIS_TESTDRIVER_HXX
#define _BASIS_TESTDRIVER_HXX


#include <iterator>

#if WINDOWS
#  include <Winsock2.h> // gethostname()
#  ifdef max
#    undef max
#  endif
#  pragma comment(lib, "Ws2_32.lib")
#else
#  include <unistd.h>   // gethostname()
#endif

#ifdef ITK_VERSION
#  include "testdriver-itk.hxx"
#endif


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
                name, PROJECT,
                // description
                "This program alters the environment, runs a test and "
                "compares the output image to one or more baseline images.",
                // example usage
                "EXENAME GaussFilter --compare output.nii baseline.nii"
                "\n"
                "Runs the test GaussFilter which presumably writes the"
                " gaussian smoothed image to the image file output.nii."
                " Compares the image produced by the test to the reference"
                " image named baseline.nii with default intensity tolerance.",
                // version information
                RELEASE, "2011, 2012 University of Pennsylvania");

        cmd.add(add_before_libpath);
        cmd.add(add_before_env);
        cmd.add(clean_cwd_before_test);
        cmd.add(clean_cwd_after_test);
        cmd.add(diff);
        cmd.add(diff_lines);
        cmd.add(compare);
        cmd.add(max_number_of_differences);
        cmd.add(intensity_tolerance);
        cmd.add(tolerance_radius);
        cmd.add(orientation_insensitive);
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

    cout << "<DartMeasurement name=\"Working Directory\" type=\"string\">";
    cout << os::getcwd();
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
// low-level file comparison
// ===========================================================================

// ---------------------------------------------------------------------------
void BinaryDiffVisitor::visit()
{
    assert(diff.getValue().size() != 0);
    assert((diff.getValue().size() % 2) == 0);

    RegressionTest regression_test;

    regression_test.test_file                 = diff.getValue()[diff.getValue().size() - 2];
    regression_test.baseline_file             = diff.getValue()[diff.getValue().size() - 1];
    regression_test.intensity_tolerance       = 0.0f;
    regression_test.max_number_of_differences = 0;
    regression_test.tolerance_radius          = 0;
    regression_test.orientation_insensitive   = false;
    regression_test.method                    = BINARY_DIFF;

    regression_tests.push_back(regression_test);
}

// ---------------------------------------------------------------------------
int binary_diff(const char* testfile, const char* baseline)
{
    int retval = 0;
    ifstream ift(testfile, ios::binary);
    ifstream ifb(baseline, ios::binary);
    if (!ift) return -1;
    if (!ifb) return -2;
    istream_iterator<unsigned char> eos; // end-of-stream
    istream_iterator<unsigned char> it(ift);
    istream_iterator<unsigned char> ib(ifb);
    while (it != eos && ib != eos) {
        if (*it != *ib) break;
        ++it;
        ++ib;
    }
    if (it != eos || ib != eos) retval = 1;
    ift.close();
    ifb.close();
    return retval;
}

// ---------------------------------------------------------------------------
void LineDiffVisitor::visit()
{
    assert(diff_lines.getValue().size() != 0);
    assert((diff_lines.getValue().size() % 2) == 0);

    RegressionTest regression_test;

    regression_test.test_file                 = diff_lines.getValue()[diff_lines.getValue().size() - 2];
    regression_test.baseline_file             = diff_lines.getValue()[diff_lines.getValue().size() - 1];
    regression_test.intensity_tolerance       = 0.0f;
    regression_test.max_number_of_differences = max_number_of_differences.getValue();
    regression_test.tolerance_radius          = 0;
    regression_test.orientation_insensitive   = false;
    regression_test.method                    = DIFF_LINES;

    regression_tests.push_back(regression_test);
}

// ---------------------------------------------------------------------------
int text_diff_lines(const char* testfile, const char* baseline, unsigned int max_number_of_differences)
{
    int retval = 0;
    ifstream ift(testfile);
    ifstream ifb(baseline);
    if (!ift) return -1;
    if (!ifb) return -2;
    string tline, bline;
    while (getline(ift, tline) && getline(ifb, bline)) {
        if (tline != bline) retval++;
    }
    if (static_cast<unsigned int>(retval) <= max_number_of_differences) retval = 0;
    if (getline(ift, tline) || getline(ifb, bline)) retval = 1000;
    ift.close();
    ifb.close();
    return retval;
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

    regression_test.test_file                 = compare.getValue()[compare.getValue().size() - 2];
    regression_test.baseline_file             = compare.getValue()[compare.getValue().size() - 1];
    regression_test.intensity_tolerance       = intensity_tolerance.getValue();
    regression_test.max_number_of_differences = max_number_of_differences.getValue();
    regression_test.tolerance_radius          = tolerance_radius.getValue();
    regression_test.orientation_insensitive   = orientation_insensitive.getValue();
    regression_test.method                    = COMPARE_IMAGES;

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
                          bool         orientation_insensitive,
                          int          report)
{
    #ifdef ITK_VERSION
        return RegressionTestImage(imagefile,
                                   baseline,
                                   report,
                                   intensity_tolerance,
                                   max_number_of_differences,
                                   tolerance_radius,
                                   orientation_insensitive);
    #else
        BASIS_THROW(runtime_error,
                    "Not implemented yet! Use ITK implementation instead, i.e.,"
                    << " install ITK 3.14 or greater (including versions after 4.0)"
                    << " and reconfigure the build tree of " << PROJECT << ". Ensure that"
                    << " the ITK_DIR variable is set to the directory of the ITKConfig.cmake file"
                    << " and that the variable USE_ITK is set to ON. Then rebuild " << PROJECT
                    << " and optionally install it again.");
    #endif
}


#endif // _BASIS_TESTDRIVER_HXX
