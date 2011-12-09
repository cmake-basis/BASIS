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


#include "basis.h"

#if HAVE_ITK
#  if ITK_VERSION_MAJOR >= 4
#    include "testdriver-itk4.hxx"
#  else
#    include "testdriver-itk.hxx"
#  endif
#endif


// ===========================================================================
// help
// ===========================================================================

// ---------------------------------------------------------------------------
void print_usage()
{
    string exec_name = get_executable_name();
    cout << "Usage:" << endl;
    cout << "  " << exec_name << " [options] <command> [arguments]" << endl;
    cout << "  " << exec_name << " [options] --no-process" << endl;
}

// ---------------------------------------------------------------------------
void print_options()
{
    cout << "Required arguments:" << endl;
    cout << "  <command>   The test command to execute. This argument is not required" << endl;
    cout << "              if the --noprocess option is given." << endl;
    cout << endl;
    cout << "Environment arguments:" << endl;
    cout << "  --add-before-libpath <dir>" << endl;
    cout << "      Add a path to the library path environment. This option take care of" << endl;
    cout << "      choosing the right environment variable for your system." << endl;
    cout << "      This option can be used several times." << endl;
    cout << endl;
    cout << "  --add-before-env <name> <value" << endl;
    cout << "      Add an environment variable named <name> with the given value." << endl;
    cout << "      The seperator used is the default one on the system." << endl;
    cout << "      This option can be used several times." << endl;
    cout << endl;
    cout << "  --add-before-env-with-sep <name> <value> <sep>" << endl;
    cout << "      Add an environment variable named <name> with the given value." << endl;
    cout << "      The seperator used is the provided as third argument." << endl;
    cout << "      This option can be used several times." << endl;
    cout << endl;
    cout << "Test arguments:" << endl;
    cout << "  --compare <test> <baseline>" << endl;
    cout << "      Compare the <test> image to the <baseline> image(s)." << endl;
    cout << "      This option can be used several times." << endl;
    cout << endl;
    cout << "  --compare-max-number-of-differences <int>" << endl;
    cout << "      When comparing images with --compare, allow the given number" << endl;
    cout << "      of image elements to differ. (default: 0)" << endl;
    cout << endl;
    cout << "  --compare-tolerance-radius <int>" << endl;
    cout << "      At most one image element in the neighborhood specified by the" << endl;
    cout << "      given radius has to fulfill the test criteria. (default: 0)" << endl;
    cout << endl;
    cout << "  --compare-intensity-tolerance <float>" << endl;
    cout << "      The accepted maximum difference between image intensities. (default: 2.0)" << endl;
    cout << endl;
    cout << "Optional arguments:" << endl;
    cout << "  --[no]process" << endl;
    cout << "      The test driver will not invoke any process." << endl;
    cout << endl;
    cout << "  --with-threads THREADS" << endl;
    cout << "      Use at most THREADS threads." << endl;
    cout << endl;
    cout << "  --without-threads" << endl;
    cout << "      Use at most one thread." << endl;
    cout << endl;
    cout << "  --full-output" << endl;
    cout << "      Causes the full output of the test to be passed to CDash." << endl;
    cout << endl;
    cout << "  --redirect-output <file>" << endl;
    cout << "      Redirects the test output to the specified file." << endl;
    cout << endl;
    cout << "  --" << endl;
    cout << "      The options after -- are not interpreted by this program and passed" << endl;
    cout << "      directly to the test program." << endl;
    cout << endl;
    cout << "Standard arguments:" << endl;
    cout << "  --verbose, -v" << endl;
    cout << "      Increase verbosity of output messages." << endl;
    cout << "      This option can be used several times." << endl;
    cout << endl;
    cout << "  --help, -h" << endl;
    cout << "      Print help and exit." << endl;
    cout << endl;
    cout << "  --helpshort" << endl;
    cout << "      Print short help and exit." << endl;
    cout << endl;
    cout << "  --version" << endl;
    cout << "      Print version information and exit." << endl;
}

// ---------------------------------------------------------------------------
void print_help()
{
    print_usage();
    cout << endl;
    cout << "Description:" << endl;
    cout << "  This command alters the environment, runs a test program and " << endl;
    cout << "  compares the output image to one or more baseline images." << endl;
    cout << endl;
    print_options();
    cout << endl;
    print_contact();
}

// ---------------------------------------------------------------------------
void print_helpshort()
{
    print_usage();
    cout << endl;
    print_options();
}

// ===========================================================================
// initialization
// ===========================================================================

// ---------------------------------------------------------------------------
void testdriversetup(int* argc, char** argv[])
{
    cerr << "This test driver is not yet implemented! Use the ITK implementation in the meantime." << endl;
    BASIS_THROW(runtime_error, "Not implemented yet");
}

// ===========================================================================
// image regression testing
// ===========================================================================

#if !HAVE_ITK
// ---------------------------------------------------------------------------
int image_regression_test(const char*  imagefile,
                          const char*  baseline,
                          double       intensity_tolerance,
                          unsigned int max_number_of_differences,
                          unsigned int tolerance_radius,
                          bool         generate_report)
{
    BASIS_THROW(runtime_error, "Not implemented yet! Use ITK implementation instead.");
}
#endif


#endif // _SBIA_BASIS_TESTDRIVER_HXX
