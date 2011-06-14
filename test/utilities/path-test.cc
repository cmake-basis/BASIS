/*!
 * \file  path-test.cc
 * \brief Implements unit test for 'path' module.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <sbia/basis/test.h> // the unit testing framework
#include <sbia/basis/path.h> // the testee's declaration


using namespace SBIA_BASIS_NAMESPACE;


// ***************************************************************************
TEST (path, getWorkingDirectory)
{
    // get working directory
    std::string wd;
    ASSERT_NO_THROW (wd = getWorkingDirectory ());

    // path may not be empty
    ASSERT_FALSE (wd.empty ()) << "Working directory may not be empty";

    // path should be absolute
    EXPECT_FALSE (isRelativePath (wd)) << "Working directory must be absolute";

    // path should have only slashes, no backslashes
    EXPECT_EQ (std::string::npos, wd.find ('\\')) << "Working directory may only contain slashes (/) as path separators";

    // path should not have trailing slash
    EXPECT_NE ('/', wd [wd.size () - 1]) << "Working directory must not have trailing slash (/)";
}

