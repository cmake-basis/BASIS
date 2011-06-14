/*!
 * \file  path-test.cc
 * \brief Implements unit test for path.cc module.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <stdexcept>

#include <sbia/basis/test.h> // the unit testing framework
#include <sbia/basis/path.h> // the testee's declaration


using namespace SBIA_BASIS_NAMESPACE;
using namespace std;


//////////////////////////////////////////////////////////////////////////////
// path representations
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
TEST (Path, IsValidPath)
{
    // test with valid Unix-style paths
    EXPECT_TRUE (IsValidPath ("/"));
    EXPECT_TRUE (IsValidPath ("/usr"));
    EXPECT_TRUE (IsValidPath ("/usr/"));
    EXPECT_TRUE (IsValidPath ("////../../usr/./"));
    EXPECT_TRUE (IsValidPath ("."));
    EXPECT_TRUE (IsValidPath (".."));
    EXPECT_TRUE (IsValidPath ("./"));

    // test with valid Windows-style paths
    EXPECT_TRUE (IsValidPath ("\\"));
    EXPECT_TRUE (IsValidPath (".\\"));
    EXPECT_TRUE (IsValidPath ("..\\"));
#if WINDOWS
    EXPECT_TRUE (IsValidPath ("A:\\"));
    EXPECT_TRUE (IsValidPath ("a:\\"));
    EXPECT_TRUE (IsValidPath ("Z:\\"));
    EXPECT_TRUE (IsValidPath ("z:\\"));
    EXPECT_TRUE (IsValidPath ("C:\\..\\"));
    EXPECT_TRUE (IsValidPath ("C:\\WINDOWS"));
    EXPECT_TRUE (IsValidPath ("C:\\WINDOWS\\"));
    EXPECT_TRUE (IsValidPath ("C:\\WINDOWS\\.."));
    EXPECT_TRUE (IsValidPath ("C:\\WINDOWS\\."));
#else
    EXPECT_FALSE (IsValidPath ("A:\\"));
    EXPECT_FALSE (IsValidPath ("a:\\"));
    EXPECT_FALSE (IsValidPath ("Z:\\"));
    EXPECT_FALSE (IsValidPath ("z:\\"));
    EXPECT_FALSE (IsValidPath ("C:\\..\\"));
    EXPECT_FALSE (IsValidPath ("C:\\WINDOWS"));
    EXPECT_FALSE (IsValidPath ("C:\\WINDOWS\\"));
    EXPECT_FALSE (IsValidPath ("C:\\WINDOWS\\.."));
    EXPECT_FALSE (IsValidPath ("C:\\WINDOWS\\."));
#endif

    // test with valid mixed-style paths
    EXPECT_TRUE (IsValidPath ("//\\/..\\../usr/./"));
#if WINDOWS
    EXPECT_TRUE (IsValidPath ("c:/"));
    EXPECT_TRUE (IsValidPath ("c:/WINDOWS"));
    EXPECT_TRUE (IsValidPath ("c:/WINDOWS\\"));
#else
    EXPECT_FALSE (IsValidPath ("c:/"));
    EXPECT_FALSE (IsValidPath ("c:/WINDOWS"));
    EXPECT_FALSE (IsValidPath ("c:/WINDOWS\\"));
#endif

    // test with invalid paths
    EXPECT_FALSE (IsValidPath (""));
    EXPECT_FALSE (IsValidPath (":"));
    EXPECT_FALSE (IsValidPath ("::"));
    EXPECT_FALSE (IsValidPath (":\\"));
    EXPECT_FALSE (IsValidPath (":/"));
    EXPECT_FALSE (IsValidPath ("1:/"));
}

// ***************************************************************************
TEST (Path, CleanPath)
{
    EXPECT_STREQ ("/", CleanPath ("/").c_str ());
    EXPECT_STREQ ("/", CleanPath ("/..").c_str ());
    EXPECT_STREQ ("/", CleanPath ("/../..").c_str ());
    EXPECT_STREQ ("/", CleanPath ("/../../.").c_str ());
    EXPECT_STREQ ("/", CleanPath ("/.././../.").c_str ());
    EXPECT_STREQ ("/", CleanPath ("\\").c_str ());
    EXPECT_STREQ ("C:/", CleanPath ("C:/").c_str ());
    EXPECT_STREQ ("C:/", CleanPath ("C:\\").c_str ());
    EXPECT_STREQ ("/usr/local", CleanPath ("/usr/local/.").c_str ());
    EXPECT_STREQ ("/usr", CleanPath ("/usr/local/..").c_str ());

    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, ToUnixPath)
{
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, ToWindowsPath)
{
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, ToNativePath)
{
    FAIL () << "Test not implemented";
}

//////////////////////////////////////////////////////////////////////////////
// working directory
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
TEST (Path, GetWorkingDirectory)
{
    // get working directory
    string wd;
    ASSERT_NO_THROW (wd = GetWorkingDirectory ());

    // path may not be empty
    ASSERT_FALSE (wd.empty ()) << "Working directory may not be empty";

    // path should be absolute
    EXPECT_FALSE (IsRelativePath (wd)) << "Working directory must be absolute";

    // path should have only slashes, no backslashes
    EXPECT_EQ (string::npos, wd.find ('\\')) << "Working directory may only contain slashes (/) as path separators";

    // path should not have trailing slash
    EXPECT_NE ('/', wd [wd.size () - 1]) << "Working directory must not have trailing slash (/)";
}

//////////////////////////////////////////////////////////////////////////////
// path components
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
TEST (Path, SplitPath)
{
    string root, dir, fname, ext;

    // test with empty string
    EXPECT_THROW (SplitPath ("", &root, &dir, &fname, &ext), invalid_argument);

    // test with NULL arguments only
    EXPECT_NO_THROW (SplitPath ("/", NULL, NULL, NULL, NULL));

    // test the paths given as example in the documentation
    EXPECT_NO_THROW (SplitPath ("/usr/bin", &root, &dir, &fname, &ext));

/*
     "/usr/bin"               | "/"    | "usr/"        | "bin"       | ""
  "/home/user/info.txt     | "/"    | "home/user/"  | "info"      | ".txt"
  "word.doc"               | "./"   | ""            | "word"      | ".doc"
  "../word.doc"            | "./"   | "../"         | "word"      | ".doc"
  "C:/WINDOWS/regedit.exe" | "C:/"  | "WINDOWS/"    | "regedit"   | ".exe"
  "d:\data"                | "D:/"  | ""            | "data"      | ""
    "/usr/local/"            | "/"    | "usr/local/"  | ""          | ""
*/
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, GetFileRoot)
{
    // relative Unix-style path
    EXPECT_STREQ ("./", GetFileRoot ("readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot ("./readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot ("../readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot ("dir/readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot ("../dir/readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot ("./dir/readme.txt").c_str ());

    // relative Windows-style path
    EXPECT_STREQ ("./", GetFileRoot (".\\readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot ("..\\readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot ("dir\\readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot (".\\dir\\readme.txt").c_str ());
    EXPECT_STREQ ("./", GetFileRoot ("..\\dir\\readme.txt").c_str ());

    // absolute Unix-style path
    EXPECT_STREQ ("/", GetFileRoot ("/").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("/.").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("/./").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("/..").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("/usr").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("/usr/").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("/usr/..").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("/usr/local").c_str ());

    // absolute Windows-style path
    EXPECT_STREQ ("/", GetFileRoot ("\\").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("\\WINDOWS").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("\\WINDOWS\\").c_str ());
#if WINDOWS
    EXPECT_STREQ ("C:/", GetFileRoot ("c:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("C:/", GetFileRoot ("C:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("D:/", GetFileRoot ("d:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("A:/", GetFileRoot ("a:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("Z:/", GetFileRoot ("z:\\WINDOWS\\").c_str ());
#else
    EXPECT_THROW (GetFileRoot ("c:\\WINDOWS\\"), invalid_argument);
    EXPECT_THROW (GetFileRoot ("C:\\WINDOWS\\"), invalid_argument);
#endif

    // test with invalid argument
    EXPECT_THROW (GetFileRoot (""),      invalid_argument);
    EXPECT_THROW (GetFileRoot ("C::/"),  invalid_argument);
    EXPECT_THROW (GetFileRoot ("C::\\"), invalid_argument);
    EXPECT_THROW (GetFileRoot (":/"),    invalid_argument);
    EXPECT_THROW (GetFileRoot (":\\"),   invalid_argument);
    EXPECT_THROW (GetFileRoot ("7:\\"),  invalid_argument);
}

// ***************************************************************************
TEST (Path, GetFileDirectory)
{
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, GetFileName)
{
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, GetFileNameWithoutExtension)
{
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, GetFileNameExtension)
{
    FAIL () << "Test not implemented";
}

//////////////////////////////////////////////////////////////////////////////
// absolute / relative paths
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
TEST (Path, IsAbsolutePath)
{
    // test with Unix-style relative paths
    EXPECT_FALSE (IsAbsolutePath ("readme.txt"));
    EXPECT_FALSE (IsAbsolutePath ("./readme.txt"));
    EXPECT_FALSE (IsAbsolutePath ("../readme.txt"));
    EXPECT_FALSE (IsAbsolutePath ("dir/readme.txt"));
    EXPECT_FALSE (IsAbsolutePath ("./dir/readme.txt"));
    EXPECT_FALSE (IsAbsolutePath ("../dir/readme.txt"));

    // test with Unix-style absolute path
    EXPECT_TRUE (IsAbsolutePath ("/usr"));
    EXPECT_TRUE (IsAbsolutePath ("/usr/local"));
    EXPECT_TRUE (IsAbsolutePath ("/."));
    EXPECT_TRUE (IsAbsolutePath ("/.."));

    // test with Windows-style relative path
    EXPECT_FALSE (IsAbsolutePath (".\\readme.txt"));
    EXPECT_FALSE (IsAbsolutePath ("..\\readme.txt"));
    EXPECT_FALSE (IsAbsolutePath ("dir\\readme.txt"));
    EXPECT_FALSE (IsAbsolutePath (".\\dir\\readme.txt"));
    EXPECT_FALSE (IsAbsolutePath ("..\\dir\\readme.txt"));

    // test with Windows-style absolute path
    EXPECT_TRUE (IsAbsolutePath ("\\WINDOWS"));
    EXPECT_TRUE (IsAbsolutePath ("c:\\WINDOWS"));
    EXPECT_TRUE (IsAbsolutePath ("C:\\WINDOWS"));
    EXPECT_TRUE (IsAbsolutePath ("C:\\"));
    EXPECT_TRUE (IsAbsolutePath ("C:\\."));
}

// ***************************************************************************
TEST (Path, IsRelativePath)
{
    // test with Unix-style relative paths
    EXPECT_TRUE (IsRelativePath ("readme.txt"));
    EXPECT_TRUE (IsRelativePath ("./readme.txt"));
    EXPECT_TRUE (IsRelativePath ("../readme.txt"));
    EXPECT_TRUE (IsRelativePath ("dir/readme.txt"));
    EXPECT_TRUE (IsRelativePath ("./dir/readme.txt"));
    EXPECT_TRUE (IsRelativePath ("../dir/readme.txt"));

    // test with Unix-style absolute path
    EXPECT_FALSE (IsRelativePath ("/usr"));
    EXPECT_FALSE (IsRelativePath ("/usr/local"));
    EXPECT_FALSE (IsRelativePath ("/."));
    EXPECT_FALSE (IsRelativePath ("/.."));

    // test with Windows-style relative path
    EXPECT_TRUE (IsRelativePath (".\\readme.txt"));
    EXPECT_TRUE (IsRelativePath ("..\\readme.txt"));
    EXPECT_TRUE (IsRelativePath ("dir\\readme.txt"));
    EXPECT_TRUE (IsRelativePath (".\\dir\\readme.txt"));
    EXPECT_TRUE (IsRelativePath ("..\\dir\\readme.txt"));

    // test with Windows-style absolute path
    EXPECT_FALSE (IsRelativePath ("\\WINDOWS"));
    EXPECT_FALSE (IsRelativePath ("c:\\WINDOWS"));
    EXPECT_FALSE (IsRelativePath ("C:\\WINDOWS"));
    EXPECT_FALSE (IsRelativePath ("C:\\"));
    EXPECT_FALSE (IsRelativePath ("C:\\."));
}

// ***************************************************************************
TEST (Path, ToAbsolutePath)
{
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, ToRelativePath)
{
    FAIL () << "Test not implemented";
}

//////////////////////////////////////////////////////////////////////////////
// symbolic links
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
TEST (Path, IsSymbolicLink)
{
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, ReadSymbolicLink)
{
    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, GetRealPath)
{
    FAIL () << "Test not implemented";
}

//////////////////////////////////////////////////////////////////////////////
// executable file
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
TEST (Path, GetExecutablePath)
{
    string path;

    EXPECT_NO_THROW (path = GetExecutablePath ());
    cout << "Path of test executable is \"" << path << "\"" << endl;

    FAIL () << "Test not implemented";
}

// ***************************************************************************
TEST (Path, GetExecutableName)
{
    string name;

    //EXPECT_NO_THROW (name = GetExecutableName ());
    EXPECT_STREQ ("test_path", name.c_str ());
}

