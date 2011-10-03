/**
 * @file  test_subprocess.cxx
 * @brief Test of subprocess.cxx module.
 *
 * @todo Extend this test and make it work on both Unix and Windows.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <sbia/basis/test.h>
#include <sbia/basis/subprocess.h>
#include <sbia/basis/path.h>


using namespace std;
using namespace SBIA_BASIS_NAMESPACE;


const string cCmd = get_executable_directory() + "/dummy_command";

// ---------------------------------------------------------------------------
TEST (Subprocess, Popen)
{
    Subprocess p;

    Subprocess::CommandLine cmd;
    cmd.push_back(cCmd);
    EXPECT_TRUE(p.popen(cmd));
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_EQ(0, p.returncode());

    EXPECT_TRUE(p.popen(cCmd));
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_EQ(0, p.returncode());
}

// ---------------------------------------------------------------------------
TEST (Subprocess, ReturnCode)
{
    Subprocess p;

    EXPECT_TRUE(p.popen(cCmd + " --exit 1"));
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_EQ(1, p.returncode());

    EXPECT_TRUE(p.popen(cCmd + " --exit 42"));
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_EQ(42, p.returncode());
}

// ---------------------------------------------------------------------------
TEST (Subprocess, Terminate)
{
    Subprocess p;
    char buf[2];

    EXPECT_TRUE(p.popen(cCmd + " --sleep 60 --greet", Subprocess::RM_NONE, Subprocess::RM_PIPE));
    EXPECT_FALSE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_TRUE(p.terminate());
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_TRUE(p.signaled());
    EXPECT_EQ(0, p.read(buf, 2));
}

// ---------------------------------------------------------------------------
TEST (Subprocess, Call)
{
    EXPECT_EQ(0, Subprocess::call(cCmd));
}

// ---------------------------------------------------------------------------
TEST (Subprocess, Communicate)
{

}
