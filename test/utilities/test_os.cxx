/**
 * @file  test_os.cxx
 * @brief Test of os.cxx module.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <stdexcept>

#include <basis/config.h> // WINDOWS, UNIX macros
#include <basis/test.h> // unit testing framework
#include <basis/os.h> // testee

#if UNIX
#  include <stdlib.h> // the system() function is used to create symbolic links
#endif


using namespace basis;
using namespace std;


// ---------------------------------------------------------------------------
TEST (os, getcwd)
{
    // get working directory
    string wd;
    ASSERT_NO_THROW (wd = os::getcwd());
    // path may not be empty
    ASSERT_FALSE(wd.empty()) << "Working directory may not be empty";
    // path should be absolute
    EXPECT_TRUE(os::path::isabs(wd)) << "Working directory must be absolute";
    // path should have only slashes, no backslashes
#if UNIX
    EXPECT_EQ(string::npos, wd.find('\\')) << "Working directory may only contain slashes (/) as path separators";
#endif
    // path should not have trailing slash
    EXPECT_NE('/', wd[wd.size() - 1]) << "Working directory must not have trailing slash (/)";
}

// ---------------------------------------------------------------------------
TEST (os, exepath)
{
    string path;
    EXPECT_NO_THROW (path = os::exepath());
    cout << path << endl;
#if WINDOWS
    EXPECT_STREQ("test_os.exe", os::path::basename(path).c_str());
#else
    EXPECT_STREQ("test_os", os::path::basename(path).c_str());
#endif
}

// ---------------------------------------------------------------------------
TEST (os, exename)
{
    string name;
    EXPECT_NO_THROW(name = os::exename());
    EXPECT_STREQ("test_os", name.c_str());
}

// ---------------------------------------------------------------------------
TEST (os, exedir)
{
    string path;
    EXPECT_NO_THROW(path = os::exedir());
    cout << path << endl;
    EXPECT_TRUE(path == os::path::dirname(os::exepath()));
}

// ---------------------------------------------------------------------------
TEST (os, makermdirs)
{
    string dir;
    // already existing directory
    string cwd = os::getcwd();
    EXPECT_TRUE(os::makedirs(cwd)) << "make directory " << cwd;
    // directory without non-existent parents
    dir = os::path::join(cwd, "test_path_directory");
    ASSERT_TRUE(os::mkdir(dir)) << "make directory " << dir;
    EXPECT_TRUE(os::rmdir(dir)) << "remove directory " << dir;
    // directory with non-existent parent
    dir = os::path::join(cwd, "test_path/directory/subdirectory");
    ASSERT_TRUE(os::makedirs(dir)) << "make directory " << dir;
    dir = os::path::join(cwd, "test_path");
    EXPECT_FALSE(os::rmdir(dir))
            << "try to non-recursively remove non-empty directory " << dir;
    EXPECT_TRUE(os::rmtree(dir))
            << "recursively remove non-empty directory " << dir;
}

// ---------------------------------------------------------------------------
TEST (os, readlink)
{
    EXPECT_STREQ("", os::readlink("").c_str());
    #if WINDOWS
        EXPECT_STREQ("", os::readlink("/proc/exe").c_str());
        EXPECT_STREQ("", os::readlink("/does/not/exist").c_str());
    #else
        const string tmpDir = os::getcwd() + "/basis-path-test-read_symlink";
        string cmd, link;
     
        cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
        ASSERT_TRUE(system(cmd.c_str ()) == 0) << cmd << " failed";

        link = tmpDir; link += "/symlink";
        cmd  = "ln -sn \"hello world\" \""; cmd += link; cmd += "\"";
        EXPECT_TRUE(system(cmd.c_str ()) == 0) << cmd << " failed";
        EXPECT_STREQ("hello world", os::readlink(link).c_str()) << "Link: " << link;

        link  = tmpDir; link += "/nolink";
        cmd   = "touch \""; cmd += link; cmd += "\"";
        EXPECT_TRUE(system (cmd.c_str ()) == 0) << cmd << " failed";
        EXPECT_STREQ("", os::readlink(link).c_str()) << "Link: " << link;

        cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
        ASSERT_TRUE(system(cmd.c_str ()) == 0) << cmd << " failed";
        EXPECT_TRUE(system(cmd.c_str ()) == 0);
    #endif
}
