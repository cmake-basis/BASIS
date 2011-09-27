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
}
