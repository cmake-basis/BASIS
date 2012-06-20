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

#include <sbia/basis/config.h> // WINDOWS, UNIX macros
#include <sbia/basis/test.h> // unit testing framework
#include <sbia/basis/os.h> // testee

#if UNIX
#  include <stdlib.h> // the system() function is used to create symbolic links
#endif


using namespace sbia::basis;
using namespace std;


// ---------------------------------------------------------------------------
// Tests the retrieval of the current working directory
TEST (Path, GetWorkingDirectory)
{
    // get working directory
    string wd;
    ASSERT_NO_THROW (wd = os::getcwd());

    // path may not be empty
    ASSERT_FALSE (wd.empty()) << "Working directory may not be empty";

    // path should be absolute
    EXPECT_FALSE (os::path::isrel(wd)) << "Working directory must be absolute";

    // path should have only slashes, no backslashes
    EXPECT_EQ (string::npos, wd.find('\\')) << "Working directory may only contain slashes (/) as path separators";

    // path should not have trailing slash
    EXPECT_NE ('/', wd[wd.size() - 1]) << "Working directory must not have trailing slash (/)";
}

// ---------------------------------------------------------------------------
// Tests the creation of new directories and their removal.
TEST (Path, MakeRemoveDirectory)
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
// Tests the reading of a symbolic link's value
TEST (Path, ReadLink)
{
    std::string value;
#if WINDOWS
    EXPECT_TRUE (os::readlink("/proc/exe", value));
    EXPECT_TRUE (value == "/proc/exe");
    EXPECT_TRUE (os::readlink("/does/not/exist", value));
    EXPECT_TRUE (value == "/does/not/exist");
#else
    const string tmpDir = os::getcwd() + "/basis-path-test-read_symlink";
    string cmd, link;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system(cmd.c_str ()) == 0) << cmd << " failed";

    link  = tmpDir; link += "/symlink";
    value = "hello world";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system(cmd.c_str ()) == 0) << cmd << " failed";
    value = "";
    EXPECT_TRUE (os::readlink(link, value)) << "Link: " << link;
    EXPECT_STREQ ("hello world", value.c_str ());
    link  = tmpDir; link += "/nolink";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_FALSE (os::readlink(link, value)) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system(cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (system(cmd.c_str ()) == 0);
#endif

    EXPECT_THROW (os::readlink("",     value), invalid_argument);
    EXPECT_THROW (os::readlink("C::/", value), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the current executable's path
TEST (Path, GetExecutablePath)
{
    string path;
    EXPECT_NO_THROW (path = os::exepath());
    cout << path << endl;
    EXPECT_STREQ ("test_path", os::path::filename(path).c_str ());
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the current executable's directory
TEST (Path, GetExecutableDirectory)
{
    string path;
    EXPECT_NO_THROW (path = os::exedir());
    cout << path << endl;
    EXPECT_TRUE (path == os::path::dirname(os::exepath()));
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the current executable's name
TEST (Path, GetExecutableName)
{
    string name;
    EXPECT_NO_THROW (name = os::exename());
    EXPECT_STREQ ("test_path", name.c_str ());
}
