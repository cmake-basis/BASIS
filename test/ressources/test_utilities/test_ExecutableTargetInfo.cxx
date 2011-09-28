/**
 * @file  test_ExecutableTargetInfo.cxx
 * @brief Test ExecutableTargetInfo.cxx module.
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
        << "Returned instance is NULL";
    // make sure that second call gives same instance
    ASSERT_EQ (info, &ExecutableTargetInfo::GetInstance ())
        << "Second call returned another instance";
}

// ***************************************************************************
// Tests GetTargetUID().
TEST (ExecutableTargetInfo, GetTargetUID)
{
    const ExecutableTargetInfo &info = ExecutableTargetInfo::GetInstance ();
    EXPECT_STREQ ("testutilities::basisproject.sh", info.GetTargetUID ("basisproject.sh").c_str ())
        << "this project's namespace was not prepended to known target";
    EXPECT_STREQ ("testutilities::unknown", info.GetTargetUID ("unknown").c_str ())
        << "this project's namespace was not prepended to unknown target";
    EXPECT_STREQ (info.GetTargetUID ("helloworld").c_str (), info.GetTargetUID ("testutilities::helloworld").c_str ())
        << "using either target name or target UID does not give the same for own executable";
    EXPECT_STREQ ("basis::basisproject.sh", info.GetTargetUID ("basis::basisproject.sh").c_str ())
        << "UID changed";
    EXPECT_STREQ ("hammer::hammer", info.GetTargetUID ("hammer::hammer").c_str ())
        << "UID changed";
    EXPECT_STREQ ("::hello", info.GetTargetUID ("::hello").c_str ())
        << "namespace prepended even though global namespace specified";
    EXPECT_STREQ ("", info.GetTargetUID ("").c_str ())
        << "empty string resulted in non-empty string";
}

// ***************************************************************************
// Tests IsKnownTarget().
TEST (ExecutableTargetInfo, IsKnownTarget)
{
    const ExecutableTargetInfo &info = ExecutableTargetInfo::GetInstance ();
    EXPECT_FALSE (info.IsKnownTarget ("basisproject.sh"))
        << "basisproject.sh is part of TestUtilities though it should not";
    EXPECT_TRUE  (info.IsKnownTarget ("basis::basisproject.sh"))
        << "basis::basisproject.sh is not a known target";
    EXPECT_FALSE (info.IsKnownTarget (""))
        << "empty target string is not identified as unknown target";
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
        << "name of basis::basisproject.sh executable is not basisproject(.sh)";
}

// ***************************************************************************
// Tests GetBuildDirectory().
TEST (ExecutableTargetInfo, GetBuildDirectory)
{
    const ExecutableTargetInfo &info = ExecutableTargetInfo::GetInstance ();

    string dir;
    size_t idx;

    dir = info.GetBuildDirectory ("basis::basisproject.sh");
    cout << "Build directory of basis::basisproject.sh is '" << dir << "'" << endl;
    EXPECT_TRUE (dir != "") << "returned string is empty";
    EXPECT_NE   (string::npos, idx = dir.rfind ("/"))
        << "returned directory does not contain a slash (/)";
    EXPECT_STREQ ("/bin", dir.substr (idx).c_str ())
        << "basis::basisproject.sh does not live in a 'bin' directory";

    EXPECT_STREQ ("", info.GetBuildDirectory ("unknonw").c_str ())
        << "returned value is not an empty string for unknown targets";
    EXPECT_STREQ ("", info.GetBuildDirectory ("").c_str ())
        << "returned value is not an empty string for '' target";
}

// ***************************************************************************
// Tests GetInstallationDirectory().
TEST (ExecutableTargetInfo, GetInstallationDirectory)
{
    const ExecutableTargetInfo &info = ExecutableTargetInfo::GetInstance ();

    string dir;
    size_t idx;

    dir = info.GetInstallationDirectory ("basis::basisproject.sh");
    cout << "Installation directory of basis::basisproject.sh is '" << dir << "'" << endl;
    EXPECT_TRUE (dir != "") << "returned string is empty";
    EXPECT_STREQ (dir.c_str (), info.GetBuildDirectory ("basis::basisproject.sh").c_str ())
        << "build and installation directory are not the same for external executable";

    dir = info.GetInstallationDirectory ("helloworld");
    cout << "Installation directory of helloworld is '" << dir << "'" << endl;
    EXPECT_TRUE (dir != "") << "returned string is empty";
#if WINDOWS
    EXPECT_STREQ ("C:/Program Files/SBIA/bin/testutilities", dir.c_str ())
#else
    EXPECT_STREQ ("/usr/local/bin/testutilities", dir.c_str ())
#endif
        << "installation directory of helloworld is not the expected default";
    EXPECT_STRNE (dir.c_str (), info.GetBuildDirectory ("helloworld").c_str ())
        << "build and installation directory are the same for own executable";

    EXPECT_STREQ ("", info.GetInstallationDirectory ("unknown").c_str ())
        << "returned value is not an empty string for unknown targets";
    EXPECT_STREQ ("", info.GetInstallationDirectory ("").c_str ())
        << "returned value is not an empty string for '' target";
}
