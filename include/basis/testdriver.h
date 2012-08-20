/**
 * @file  testdriver.h
 * @brief Default test driver include file.
 *
 * This file is specified as INCLUDE argument to the create_test_sourcelist()
 * command of CMake which generates the code of the test driver. Such test
 * driver is used, in particular, to run a test which generates an output image.
 * The resulting image can then be compared by the test driver to one or more
 * baseline images. Note the difference to plain non-image processing based
 * unit tests. These shall make use of the unit testing frameworks included
 * with BASIS instead (see test.h for a C++ unit testing framework).
 *
 * This file in particular declares the functions which are used to parse
 * the command-line arguments of the test driver and those which are used by
 * the code fragments defined in the files testdriver-before-test.inc and
 * testdriver-after-test.inc.
 *
 * Currently available test driver implementations included by this file are:
 * - testdriver.hxx
 * - testdriver-itk.hxx
 *
 * This file is in parts a modified version of the itkTestDriverInclude.h
 * file which is part of the TestKernel module of the ITK 4 project.
 *
 * Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen<br />
 * Copyright Insight Software Consortium.<br />
 * Copyright (c) 2011, 2012 University of Pennsylvania.
 *
 * Portions of this file are subject to the VTK Toolkit Version 3 copyright.
 *
 * For complete copyright, license and disclaimer of warranty information
 * please refer to the COPYRIGHT file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

 /*=========================================================================
 *
 *  Copyright Insight Software Consortium
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0.txt
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *=========================================================================*/
/*=========================================================================
 *
 *  Portions of this file are subject to the VTK Toolkit Version 3 copyright.
 *
 *  Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen
 *
 *  For complete copyright, license and disclaimer of warranty information
 *  please refer to the NOTICE file at the top of the ITK source tree.
 *
 *=========================================================================*/

#pragma once
#ifndef _BASIS_TESTDRIVER_H
#define _BASIS_TESTDRIVER_H


#include <string>
#include <map>
#include <vector>
#include <iostream>
#include <fstream>
#include <cstdio> // remove() - removes a file
#include <limits> // used in basistest-after-test.inc

#include <basis/basis.h>


// acceptable in test driver includes
using namespace std;
using namespace basis;

 
// ===========================================================================
// arguments
// ===========================================================================

/// @brief Maximum dimension of images used for testing.
const unsigned int BASIS_MAX_TEST_IMAGE_DIMENSION = 6;

// ---------------------------------------------------------------------------
// environment
MultiStringArg add_before_libpath(
        "", "add-before-libpath",
        "Add a path to the library path environment. This option takes"
        " care of choosing the right environment variable for your system.",
        false, "<dir>");

MultiStringArg add_before_env(
        "", "add-before-env",
        "Add an environment variable named <name> with the given value."
        " The seperator used is the default one on the system.",
        false, "<name> <value>", 2);

MultiStringArg add_before_env_with_sep(
        "", "add-before-env-with-sep",
        "Add an environment variable named <name> with the given value.",
        false, "<name> <value> <sep>", 3);

// ---------------------------------------------------------------------------
// regression testing

enum TestMethod
{
    METHOD_UNKNOWN,
    COMPARE_IMAGES,
    BINARY_DIFF,
    DIFF_LINES
};

/// @brief Structure holding arguments to regression test options and currently
///        set tolerances to be used for the regression test.
struct RegressionTest {
    string       test_file;
    string       baseline_file;
    double       intensity_tolerance;
    unsigned int max_number_of_differences;
    unsigned int tolerance_radius;
    bool         orientation_insensitive;
    TestMethod   method;
};

/// @brief Container storing added regression tests.
vector<RegressionTest> regression_tests;

/// @brief Visitor used to handle --diff option.
class BinaryDiffVisitor : public TCLAP::Visitor
{
public:
    BinaryDiffVisitor() {}
    ~BinaryDiffVisitor() {}
    void visit();
};

/// @brief Visitor used to handle --diff-lines option.
class LineDiffVisitor : public TCLAP::Visitor
{
public:
    LineDiffVisitor() {}
    ~LineDiffVisitor() {}
    void visit();
};

/// @brief Visitor used to handle --compare option.
class CompareVisitor : public TCLAP::Visitor
{
public:
    CompareVisitor() {}
    ~CompareVisitor() {}
    void visit();
};

CompareVisitor    compare_visitor;
BinaryDiffVisitor diff_visitor;
LineDiffVisitor   diff_lines_visitor;

MultiStringArg diff(
        "", "diff",
        "Compare the <test> file to the <baseline> file byte by byte."
        " Can by used to compare any files including text files."
        " For images, the --compare option should be used instead.",
        false, "<test> <baseline>", 2, false, &diff_visitor);

MultiStringArg diff_lines(
        "", "diff-lines",
        "Compare the <test> file to the <baseline> file line by line."
        " Can by used to compare text files. The current --max-number-of-differences"
        " setting determines the number of lines which may differ between the files."
        " For binary files, consider the --diff option instead.",
        false, "<test> <baseline>", 2, false, &diff_lines_visitor);

MultiStringArg compare(
        "", "compare",
        "Compare the <test> image to the <baseline> image using the"
        " current tolerances. If the test image should be compared to"
        " to more than one baseline image, specify the file name of"
        " the main baseline image and name the other baseline images"
        " similarly with only a numerical suffix appended to the"
        " basename of the image file path using a dot (.) as separator."
        " For example, name your baseline images baseline.nii,"
        " baseline.1.nii, baseline.2.nii,..., and specify baseline.nii"
        " second argument value.",
        false, "<test> <baseline>", 2, false, &compare_visitor);

DoubleArg intensity_tolerance(
        "", "intensity-tolerance",
        "The accepted maximum difference between image intensities"
        " to use for the following regression tests."
        // default should be printed automatically
        " (default: 2.0)",
        false, 2.0, "<float>", true);

UIntArg max_number_of_differences(
        "", "max-number-of-differences",
        "When comparing images specified with the following --compare option(s),"
        " allow the given number of image elements to differ.",
        false, 0, "<n>", true);

UIntArg tolerance_radius(
        "", "tolerance-radius",
        "At most one image element in the neighborhood specified by the"
        " given radius has to fulfill the criteria of the following"
        " regression tests",
        false, 0, "<int>", true);

SwitchArg orientation_insensitive(
        "", "orientation-insensitive",
        "Allow the test and baseline images to have different orientation."
        " When this option is given, the orientation of both images is made"
        " identical before they are compared. It is suitable if the test"
        " and baseline images are simply stored with different orientation,"
        " but with proper orientation information in the file header.");

// ---------------------------------------------------------------------------
// test execution
StringArg redirect_output(
        "", "redirect-output",
        "Redirects the test output to the specified file.",
        false, "", "<file>");

UIntArg max_number_of_threads(
        "", "max-number-of-threads",
        "Use at most <n> threads. Set explicitly to n=1 to disable"
        " multi-threading. Note that the test itself still may use"
        " more threads, but the regression tests will not.",
        false, 0, "<n>");

SwitchArg full_output(
        "", "full-output",
        "Causes the full output of the test to be passed to CDash.",
        false);

MultiSwitchArg verbose(
        "v", "verbose",
        "Increase verbosity of output messages.",
        false);

// ---------------------------------------------------------------------------
// test / test command
SwitchArg clean_cwd_before_test(
        "", "clean-cwd-before",
        "Request the removal of all files and directories from the current"
        " working directory before the execution of the test. This option is"
        " in particular useful if the test writes any results to the current"
        " working directory.",
        false);

SwitchArg clean_cwd_after_test(
        "", "clean-cwd-after",
        "Request the removal of all files and directories from the current"
        " working directory after the successful execution of the test."
        " This option is in particular useful if the test writes any results"
        " to the current working directory.",
        false);

#ifdef BASIS_STANDALONE_TESTDRIVER

PositionalArgs testcmd(
        "testcmd",
        "The external test command and its command-line arguments."
        " This command is executed by the test driver after altering the"
        " environment as subprocess. After the subprocess finished, the"
        " requested regression tests are performed by the test driver."
        " Note that if the -- option is not given before the test command,"
        " labeled arguments following the test command will be considered"
        " to be options of the test driver if known by the test driver.",
        true, "[--] <test command> <arg>...");

SwitchArg noprocess(
        "", "noprocess",
        "Do not run any test subprocess but only perform the regression tests.",
        true);

#else // defined(BASIS_STANDALONE_TESTDRIVER)

PositionalArgs testcmd(
        "testcmd",
        "The name of the test to run and optional arguments."
        " Displays a list of available tests if this argument is omitted"
        " and waits for the user to input the number of the test to run."
        " Exist with error if an invalid test was specified."
        " Note that if the -- option is not given before the test name,"
        " labeled arguments following the test name will be considered"
        " to be options of the test driver if known by the test driver."
        " Otherwise, if the option is unknown to the test driver or the"
        " -- option has been given before the test name, the remaining"
        " arguments are passed on to the test.",
        false, "", "[--] [<test name> [<arg>...]]");

#endif // defined(BASIS_STANDALONE_TESTDRIVER)

// ===========================================================================
// initialization
// ===========================================================================

/**
 * @brief Parse command-line arguments and initialize test driver.
 *
 *
 * @param [in] argc Number of arguments.
 * @param [in] argv Command-line arguments.
 */
void testdriversetup(int* argc, char** argv[]);

// ===========================================================================
// low-level file comparison
// ===========================================================================

/**
 * @brief Compare two files byte by byte.
 *
 * @param [in] testfile File generated by test.
 * @param [in] baseline Baseline file.
 *
 * @retval -1 if the test file could not be read
 * @retval -2 if the baseline file could not be read
 * @retval  0 if the two files are identical
 * @retval  1 if the two files differ
 */
int binary_diff(const char* testfile, const char* baseline);

/**
 * @brief Compare two text files line by line.
 *
 * @param [in] testfile                  File generated by test.
 * @param [in] baseline                  Baseline file.
 * @param [in] max_number_of_differences Number of lines that may differ at most.
 *
 * @retval -1 if the test file could not be read
 * @retval -2 if the baseline file could not be read
 * @retval  0 if the two files differ in no more than @p max_number_of_differences lines
 * @retval  1 if the two files differ in more than the allowed number of lines
 */
int text_diff_lines(const char* testfile, const char* baseline, unsigned int max_number_of_differences = 0);

// ===========================================================================
// image regression testing
// ===========================================================================

/**
 * @brief Generate list of names of baseline files from a given template filename.
 *
 * The list of baseline file names is generated from the template filename using
 * the following algorithm:
 * -# Strip the file name suffix.
 * -# Append a suffix containing of a dot (.) and a digit, i.e., .x
 * -# Append the original file name suffix.
 * It the file exists, increment x and continue.
 *
 * Additionally, if a file @p filename_template exists, it is the first
 * element in the resulting list.
 *
 * @param [in] filename_template File path template.
 *
 * @return List of baseline filenames or empty list if no such files exist.
 */
vector<string> get_baseline_filenames(string filename_template);

/**
 * @brief Compare output image to baseline image.
 *
 * This function compares a given image to a baseline image and returns a
 * regression test result depending on how well the output image matches the
 * baseline image given the provided tolerance arguments.
 *
 * @param [in] imagefile                 Output image file of test run.
 * @param [in] baseline                  Baseline image file.
 * @param [in] intensity_tolerance       Maximum tolerable intensity difference.
 * @param [in] max_number_of_differences Maximum number of differing pixels.
 * @param [in] tolerance_radius          Tolerance radius.
 * @param [in] orientation_insensitive   Change orientation of both images to
 *                                       a common coordinate orientation before
 *                                       comparing them.
 * @param [in] report                    Level of test report to generate.
 *                                       If zero, no report is generated.
 *                                       If greater than zero, a report is
 *                                       generated. Similar to the verbosity of
 *                                       a program, is this parameter used to
 *                                       set the verbosity of the report. Most
 *                                       implementations yet only either
 *                                       generate a (full) report or none.
 *
 * @returns Number of voxels with a difference above the set @p intensity_tolerance.
 */
int image_regression_test(const char*  imagefile,
                          const char*  baseline,
                          double       intensity_tolerance = 2.0,
                          unsigned int max_number_of_differences = 0,
                          unsigned int tolerance_radius = 0,
                          bool         orientation_insensitive = false,
                          int          report = 0);


// inline definitions
#include "testdriver.hxx"


#endif // _BASIS_TESTDRIVER_H
