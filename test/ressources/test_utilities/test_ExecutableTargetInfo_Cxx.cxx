/**
 * @file  test_ExecutableTargetInfo_C++.cxx
 * @brief Test ExecutableTargetInfo module for C++.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <sbia/basis/test.h>      // unit testing framework
#include "ExecutableTargetInfo.h" // testee


using namespace SBIA_TESTUTILITIES_NAMESPACE;
using namespace std;


// ***************************************************************************
// Tests GetInstance().
TEST (ExecutableTargetInfo, GetInstance)
{
    // get singleton instance
    const ExecutableTargetInfo *info = NULL;
    info = &ExecutableTargetInfo::GetInstance ();
    ASSERT_TRUE (info != NULL)
        << "Returned instance is not NULL";
    // make sure that second call gives same instance
    ASSERT_EQ (info, &ExecutableTargetInfo::GetInstance ())
        << "Second call returns same instance";
}

// ***************************************************************************
// Tests GetTargetUID().
TEST (ExecutableTargetInfo, GetTargetUID)
{
    const ExecutableTargetInfo &info = ExecutableTargetInfo::GetInstance ();
    EXPECT_STREQ ("testutilities::basisproject.sh", info.GetTargetUID ("basisproject.sh").c_str ())
        << "this project's namespace prepended to known target";
    EXPECT_STREQ ("testutilities::unknown", info.GetTargetUID ("unknown").c_str ())
        << "this project's namespace prepended to unknown target";
    EXPECT_STREQ ("basis::basisproject.sh", info.GetTargetUID ("basis::basisproject.sh").c_str ())
        << "UID remains unchanged";
    EXPECT_STREQ ("hammer::hammer", info.GetTargetUID ("hammer::hammer").c_str ())
        << "UID remains unchanged";
    EXPECT_STREQ ("::hello", info.GetTargetUID ("::hello").c_str ())
        << "global namespace remains unchanged";
    EXPECT_STREQ ("", info.GetTargetUID ("").c_str ())
        << "empty string remains unchanged";
}

// ***************************************************************************
// Tests IsKnownTarget().
TEST (ExecutableTargetInfo, IsKnownTarget)
{
    const ExecutableTargetInfo &info = ExecutableTargetInfo::GetInstance ();
    EXPECT_FALSE (info.IsKnownTarget ("basisproject.sh"))
        << "basisproject.sh not part of TestUtilities";
    EXPECT_TRUE  (info.IsKnownTarget ("basis::basisproject.sh"))
        << "basis::basisproject.sh is a known target";
    EXPECT_FALSE (info.IsKnownTarget (""))
        << "empty target string is unknown target";
    EXPECT_FALSE (info.IsKnownTarget ("hammer::hammer"))
        << "some unknown target";
}

// ***************************************************************************
// Tests GetExecutableName().
TEST (ExecutableTargetInfo, GetExecutableName)
{
    const ExecutableTargetInfo &info = ExecutableTargetInfo::GetInstance ();
#if WINDOWS
    EXPECT_STREQ ("basisproject.sh", info.GetExecutableName ("basis::basisproject.sh").c_str ())
#else
    EXPECT_STREQ ("basisproject", info.GetExecutableName ("basis::basisproject.sh").c_str ())
#endif
        << "name of basis::basisproject.sh executable";
}
