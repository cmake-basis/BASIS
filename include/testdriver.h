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
 * Copyright (c) 2011 University of Pennsylvania.
 *
 * Portions of this file are subject to the VTK Toolkit Version 3 copyright.
 *
 * For complete copyright, license and disclaimer of warranty information
 * please refer to the COPYRIGHT file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup CppUtilities
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
#ifndef _SBIA_BASIS_TESTDRIVER_H
#define _SBIA_BASIS_TESTDRIVER_H


#include <string>
#include <map>
#include <vector>
#include <iostream>
#include <fstream>

#include <sbia/basis/config.h>
#include <sbia/basis/except.h>


// acceptable in test driver includes
using namespace std;
using namespace sbia::basis;

 

// ===========================================================================
// types
// ===========================================================================

/// @brief Type used to store a pair of filenames.
typedef pair<const char*, const char*> FilenamePair;

// ===========================================================================
// arguments
// ===========================================================================

/// @brief Maximum dimension of images used for testing.
const unsigned int MAX_TEST_IMAGE_DIMENSION = 6;

/**
 * @brief Structure holding parsed command-line arguments.
 */
struct Arguments
{
    bool                 redirect;
    string               redirect_filename;
    vector<FilenamePair> compare_imagepairs;
    double               compare_intensity_tolerance;
    unsigned int         compare_max_number_of_differences;
    unsigned int         compare_tolerance_radius;
} arguments;

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
 * @param [in] imagefile           Output image file of test run.
 * @param [in] baseline            Baseline image file.
 * @param [in] intensity_tolerance Maximum tolerable intensity difference.
 * @param [in] max_number_of_diffs Maximum number of differing image elements.
 * @param [in] tolerance_radius    Tolerance radius.
 */
int image_regression_test(const char*  imagefile,
                          const char*  baseline,
                          double       intensity_tolerance,
                          unsigned int number_of_pixels_tolerance = 0,
                          unsigned int tolerance_radius = 0,
                          bool         generate_report = false);

// ===========================================================================
// implementation
// ===========================================================================

#include "testdriver.hxx"

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


#endif // _SBIA_BASIS_TESTDRIVER_H
