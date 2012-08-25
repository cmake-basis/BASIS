/**
 * @file  test_subprocess.cxx
 * @brief Test of subprocess.cxx module.
 *
 * @todo Extend this test and make it work on both Unix and Windows.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <basis/test.h>
#include <basis/subprocess.h>

#include <basis/basis.h>


using namespace std;
using namespace basis;


const string cCmd = exepath("basis.dummy_command");

// ---------------------------------------------------------------------------
TEST(Subprocess, Split)
{
    vector<string> args;

    args = Subprocess::split("cmd");
    ASSERT_EQ(1u, args.size());
    EXPECT_STREQ("cmd", args[0].c_str());

    args = Subprocess::split("\"...");
    ASSERT_EQ(1u, args.size());
    EXPECT_STREQ("\"...", args[0].c_str());

    args = Subprocess::split("bar arg \"...");
    ASSERT_EQ(3u, args.size());
    EXPECT_STREQ("bar", args[0].c_str());
    EXPECT_STREQ("arg", args[1].c_str());
    EXPECT_STREQ("\"...", args[2].c_str());

    args = Subprocess::split("foo \"there is a double quote (\\\") inside the argument\" arg2");
    ASSERT_EQ(3u, args.size());
    EXPECT_STREQ("foo", args[0].c_str());
    EXPECT_STREQ("there is a double quote (\") inside the argument", args[1].c_str());
    EXPECT_STREQ("arg2", args[2].c_str());

    args = Subprocess::split("foo \"there is a backslash (\\) inside the argument\" arg2");
    ASSERT_EQ(3u, args.size());
    EXPECT_STREQ("foo", args[0].c_str());
    EXPECT_STREQ("there is a backslash (\\) inside the argument", args[1].c_str());
    EXPECT_STREQ("arg2", args[2].c_str());

    args = Subprocess::split("foo \"there is a backslash (\\\\) inside the argument\" arg2");
    ASSERT_EQ(3u, args.size());
    EXPECT_STREQ("foo", args[0].c_str());
    EXPECT_STREQ("there is a backslash (\\) inside the argument", args[1].c_str());
    EXPECT_STREQ("arg2", args[2].c_str());

    args = Subprocess::split("foo \"there is a backslash followed by a double quote (\\\\\\\") inside the argument\" arg2");
    ASSERT_EQ(3u, args.size());
    EXPECT_STREQ("foo", args[0].c_str());
    EXPECT_STREQ("there is a backslash followed by a double quote (\\\") inside the argument", args[1].c_str());
    EXPECT_STREQ("arg2", args[2].c_str());

    args = Subprocess::split("/bin/foo -la -x \"an argument\" \"\\a\\path with spaces\\\\\" last");
    ASSERT_EQ(6u, args.size());
    EXPECT_STREQ("/bin/foo", args[0].c_str());
    EXPECT_STREQ("-la", args[1].c_str());
    EXPECT_STREQ("-x", args[2].c_str());
    EXPECT_STREQ("an argument", args[3].c_str());
    EXPECT_STREQ("\\a\\path with spaces\\", args[4].c_str());
    EXPECT_STREQ("last", args[5].c_str());
}

// ---------------------------------------------------------------------------
TEST(Subprocess, ToString)
{
    vector<string> args;

    args.clear();
    args.push_back("foo");
    args.push_back("there is a double quote (\") inside the argument");
    args.push_back("arg2");
    EXPECT_STREQ("foo \"there is a double quote (\\\") inside the argument\" arg2",
            Subprocess::tostring(args).c_str());

    args.clear();
    args.push_back("foo");
    args.push_back("there is a backslash (\\) inside the argument");
    args.push_back("arg2");
    EXPECT_STREQ("foo \"there is a backslash (\\\\) inside the argument\" arg2",
            Subprocess::tostring(args).c_str());

    args.clear();
    args.push_back("foo");
    args.push_back("there are backslashes (\\\\) inside the argument");
    args.push_back("arg2");
    EXPECT_STREQ("foo \"there are backslashes (\\\\\\\\) inside the argument\" arg2",
            Subprocess::tostring(args).c_str());

    args.clear();
    args.push_back("foo");
    args.push_back("there is a backslash followed by a double quote (\\\") inside the argument");
    args.push_back("arg2");
    EXPECT_STREQ("foo \"there is a backslash followed by a double quote (\\\\\\\") inside the argument\" arg2",
            Subprocess::tostring(args).c_str());

    args.clear();
    args.push_back("/bin/foo");
    args.push_back("-la");
    args.push_back("-x");
    args.push_back("an argument");
    args.push_back("\\a\\path with spaces\\");
    args.push_back("last");
    EXPECT_STREQ("/bin/foo -la -x \"an argument\" \"\\\\a\\\\path with spaces\\\\\" last",
            Subprocess::tostring(args).c_str());

}

// ---------------------------------------------------------------------------
TEST(Subprocess, Popen)
{
    Subprocess p;

    Subprocess::CommandLine cmd;
    cmd.push_back(cCmd);
    EXPECT_TRUE(p.popen(cmd)) << "Failed to run command: " << cCmd;
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_EQ(0, p.returncode()) << "Return code of " << cCmd << " is not 0";

    EXPECT_TRUE(p.popen(cCmd));
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_EQ(0, p.returncode()) << "Return code of " << cCmd << " is not 0";
}

// ---------------------------------------------------------------------------
TEST(Subprocess, ReturnCode)
{
    Subprocess p;

    EXPECT_TRUE(p.popen(cCmd + " --exit 1")) << "Failed to run command: " << cCmd << " --exit 1";
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_EQ(1, p.returncode()) << "Return code of " << cCmd << " is not 1";

    EXPECT_TRUE(p.popen(cCmd + " --exit 42")) << "Failed to run command: " << cCmd << " --exit 42";
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_EQ(42, p.returncode()) << "Return code of " << cCmd << " is not 42";
}

// ---------------------------------------------------------------------------
TEST(Subprocess, Terminate)
{
    Subprocess p;
    char buf[2];

    EXPECT_TRUE(p.popen(cCmd + " --sleep 10 --greet", Subprocess::RM_NONE, Subprocess::RM_PIPE))
            << "Failed to run command: " << cCmd << " --sleep 10 --greet";
    EXPECT_FALSE(p.poll());
    EXPECT_FALSE(p.signaled());
    EXPECT_TRUE(p.terminate());
    EXPECT_TRUE(p.wait());
    EXPECT_TRUE(p.poll());
#if WINDOWS
    EXPECT_EQ(130, p.returncode());
    EXPECT_TRUE(p.signaled());
    EXPECT_EQ(-1, p.read(buf, 2));
#else
    EXPECT_EQ(0, p.returncode());
    EXPECT_TRUE(p.signaled());
    EXPECT_EQ(0, p.read(buf, 2));
#endif
}

// ---------------------------------------------------------------------------
TEST(Subprocess, Call)
{
    EXPECT_EQ(0, Subprocess::call(cCmd));
}
