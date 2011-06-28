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

#if UNIX
#  include <stdlib.h> // the system () function is used to create symbolic links
#endif

using namespace SBIA_BASIS_NAMESPACE;
using namespace std;


//////////////////////////////////////////////////////////////////////////////
// path representations
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
// Tests the validation of a path string
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
    for (char letter = 'A'; letter <= 'Z'; ++ letter) {
        std::string path;
        path += letter;
        path += ":/";
        EXPECT_TRUE (IsValidPath (path)) << "Path " << path << " should be valid on Windows";
    }
#endif
    EXPECT_TRUE (IsValidPath ("C:\\..\\"));
    EXPECT_TRUE (IsValidPath ("C:\\WINDOWS"));
    EXPECT_TRUE (IsValidPath ("C:\\WINDOWS\\"));
    EXPECT_TRUE (IsValidPath ("C:\\WINDOWS\\.."));
    EXPECT_TRUE (IsValidPath ("C:\\WINDOWS\\."));

    // test with valid mixed-style paths
    EXPECT_TRUE (IsValidPath ("//\\/..\\../usr/./"));
    EXPECT_TRUE (IsValidPath ("c:/"));
    EXPECT_TRUE (IsValidPath ("c:/WINDOWS"));
    EXPECT_TRUE (IsValidPath ("c:/WINDOWS\\"));

    // test with invalid paths
    EXPECT_FALSE (IsValidPath (""));
    EXPECT_FALSE (IsValidPath (":"));
    EXPECT_FALSE (IsValidPath ("::"));
    EXPECT_FALSE (IsValidPath (":\\"));
    EXPECT_FALSE (IsValidPath (":/"));
    EXPECT_FALSE (IsValidPath ("1:/"));
#if !WINDOWS
    for (char letter = 'A'; letter <= 'Z'; ++ letter) {
        if (letter == 'C') continue;
        std::string path;
        path += letter;
        path += ":/";
        EXPECT_FALSE (IsValidPath (path)) << "Path " << path << " is invalid on Unix systems";
    }
#endif
}

// ***************************************************************************
// Tests the cleaning/simplifying of a path
TEST (Path, CleanPath)
{
    // test with (almost) already clean paths
    EXPECT_STREQ ("/usr",          CleanPath ("/usr").c_str ());
    EXPECT_STREQ ("/usr/",         CleanPath ("/usr/").c_str ());
    EXPECT_STREQ ("/",             CleanPath ("/").c_str ());
    EXPECT_STREQ ("C:/",           CleanPath ("C:/").c_str ());
    EXPECT_STREQ ("C:\\",          CleanPath ("C:\\").c_str ());
    EXPECT_STREQ ("../../",        CleanPath ("../../").c_str ());
    EXPECT_STREQ ("../../../",     CleanPath ("../../../").c_str ());
    EXPECT_STREQ ("../../../usr/", CleanPath ("../../../usr/local/../").c_str ());
    EXPECT_STREQ (".",             CleanPath (".").c_str ());
    EXPECT_STREQ ("./",            CleanPath ("./").c_str ());
    EXPECT_STREQ ("./..",          CleanPath ("./..").c_str ());

    // test some simple cases
    EXPECT_STREQ ("/",          CleanPath ("/").c_str ());
    EXPECT_STREQ ("/",          CleanPath ("/..").c_str ());
    EXPECT_STREQ ("/",          CleanPath ("/../..").c_str ());
    EXPECT_STREQ ("/",          CleanPath ("/../../.").c_str ());
    EXPECT_STREQ ("/",          CleanPath ("/.././../.").c_str ());
    EXPECT_STREQ ("\\",         CleanPath ("\\").c_str ());
    EXPECT_STREQ ("\\",         CleanPath ("\\..\\..").c_str ());
    EXPECT_STREQ ("\\",         CleanPath ("\\..\\..\\.").c_str ());
    EXPECT_STREQ ("\\",         CleanPath ("\\..\\.\\..\\.").c_str ());
    EXPECT_STREQ ("C:/",        CleanPath ("C:/").c_str ());
    EXPECT_STREQ ("C:\\",       CleanPath ("C:\\").c_str ());
    EXPECT_STREQ ("/usr/local", CleanPath ("/usr/local/.").c_str ());
    EXPECT_STREQ ("/usr",       CleanPath ("/usr/local/..").c_str ());

    // test some more complicated cases
    EXPECT_STREQ ("/usr\\",           CleanPath ("/usr/local/.///./\\/\\/\\///\\\\\\///..\\\\.\\./").c_str ());
    EXPECT_STREQ ("..\\../path\\sub", CleanPath ("..\\//../path\\/\\///./.\\sub").c_str ());

    // test with invalid paths
    EXPECT_THROW (CleanPath (""), invalid_argument);
}

// ***************************************************************************
// Tests the conversion of a path to Unix-style
TEST (Path, ToUnixPath)
{
    EXPECT_STREQ ("/etc",       ToUnixPath ("\\usr/..\\etc").c_str ());
    EXPECT_STREQ ("/etc/",     ToUnixPath ("\\usr/..\\etc\\").c_str ());
    EXPECT_STREQ ("/usr/local", ToUnixPath ("/usr/././//\\\\/./\\.\\local/bin\\..").c_str ());
    EXPECT_STREQ ("/WINDOWS",   ToUnixPath ("C:\\WINDOWS").c_str ());
    EXPECT_STREQ ("/WINDOWS",   ToUnixPath ("C:\\WINDOWS", false).c_str ());
    EXPECT_STREQ ("C:/WINDOWS", ToUnixPath ("C:\\WINDOWS", true).c_str ());
    EXPECT_STREQ ("c:/WINDOWS", ToUnixPath ("c:\\WINDOWS", true).c_str ());

    // test with invalid paths
    EXPECT_THROW (ToUnixPath (""),      invalid_argument);
    EXPECT_THROW (ToUnixPath ("C::\\"), invalid_argument);
#if !WINDOWS
    EXPECT_THROW (ToUnixPath ("D:\\"),  invalid_argument);
#endif
}

// ***************************************************************************
// Tests the conversion of a path to Windows-style
TEST (Path, ToWindowsPath)
{
    EXPECT_STREQ ("C:\\WINDOWS",          ToWindowsPath ("/WINDOWS").c_str ());
    EXPECT_STREQ ("C:\\WINDOWS",          ToWindowsPath ("C:\\WINDOWS").c_str ());
    EXPECT_STREQ ("D:\\",                 ToWindowsPath ("D:\\").c_str ());
    EXPECT_STREQ ("D:\\",                 ToWindowsPath ("D:/").c_str ());
    EXPECT_STREQ ("C:\\Users\\andreas",   ToWindowsPath ("/Users/andreas").c_str ());
    EXPECT_STREQ ("C:\\Users\\andreas\\", ToWindowsPath ("/Users/andreas/").c_str ());

    // test with invalid paths
    EXPECT_THROW (ToWindowsPath (""),      invalid_argument);
    EXPECT_THROW (ToWindowsPath ("C::\\"), invalid_argument);
}

// ***************************************************************************
// Tests the conversion of a path to the native style of the used OS
TEST (Path, ToNativePath)
{
#if WINDOWS
    EXPECT_STREQ ("C:\\tmp", ToNativePath ("/tmp").c_str ());
#else
    EXPECT_STREQ ("/tmp",    ToNativePath ("C:\\tmp").c_str ());
#endif
}

//////////////////////////////////////////////////////////////////////////////
// working directory
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
// Tests the retrieval of the current working directory
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
// Tests the splitting of a path into its components
TEST (Path, SplitPath)
{
    string root, dir, fname, ext;

    // test with empty string
    EXPECT_THROW (SplitPath ("", &root, &dir, &fname, &ext), invalid_argument);

    // test with NULL arguments only
    EXPECT_NO_THROW (SplitPath ("/", NULL, NULL, NULL, NULL));

    // test the paths given as example in the documentation
    EXPECT_NO_THROW (SplitPath ("/usr/bin", &root, &dir, &fname, &ext));
    EXPECT_TRUE (root  == "/");
    EXPECT_TRUE (dir   == "usr/");
    EXPECT_TRUE (fname == "bin");
    EXPECT_TRUE (ext   == "");
    
    EXPECT_NO_THROW (SplitPath ("/home/user/info.txt", &root, &dir, &fname, &ext));
    EXPECT_TRUE (root  == "/");
    EXPECT_TRUE (dir   == "home/user/");
    EXPECT_TRUE (fname == "info");
    EXPECT_TRUE (ext   == ".txt");
    
    EXPECT_NO_THROW (SplitPath ("word.doc", &root, &dir, &fname, &ext));
    EXPECT_TRUE (root  == "./");
    EXPECT_TRUE (dir   == "");
    EXPECT_TRUE (fname == "word");
    EXPECT_TRUE (ext   == ".doc");
    
    EXPECT_NO_THROW (SplitPath ("../word.doc", &root, &dir, &fname, &ext));
    EXPECT_TRUE (root  == "./");
    EXPECT_TRUE (dir   == "../");
    EXPECT_TRUE (fname == "word");
    EXPECT_TRUE (ext   == ".doc");
    
    EXPECT_NO_THROW (SplitPath ("C:/WINDOWS/regedit.exe", &root, &dir, &fname, &ext));
#if WINDOWS
    EXPECT_TRUE (root  == "C:/");
#else
    EXPECT_TRUE (root  == "/");
#endif
    EXPECT_TRUE (dir   == "WINDOWS/");
    EXPECT_TRUE (fname == "regedit");
    EXPECT_TRUE (ext   == ".exe");
    
#if WINDOWS
    EXPECT_NO_THROW (SplitPath ("d:\\data", &root, &dir, &fname, &ext));
    EXPECT_TRUE (root  == "D:/");
    EXPECT_TRUE (dir   == "");
    EXPECT_TRUE (fname == "data");
    EXPECT_TRUE (ext   == "");
#else
    EXPECT_THROW (SplitPath ("d:\\data", &root, &dir, &fname, &ext), invalid_argument);
#endif
    
    EXPECT_NO_THROW (SplitPath ("/usr/local/", &root, &dir, &fname, &ext));
    EXPECT_TRUE (root  == "/");
    EXPECT_TRUE (dir   == "usr/local/");
    EXPECT_TRUE (fname == "");
    EXPECT_TRUE (ext   == "");
}

// ***************************************************************************
// Tests the retrieval of the file root
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
    EXPECT_STREQ ("/", GetFileRoot ("c:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("/", GetFileRoot ("C:\\WINDOWS\\").c_str ());
    EXPECT_THROW (GetFileRoot ("d:\\WINDOWS\\"), invalid_argument);
    EXPECT_THROW (GetFileRoot ("a:\\WINDOWS\\"), invalid_argument);
    EXPECT_THROW (GetFileRoot ("z:\\WINDOWS\\"), invalid_argument);
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
// Tests the retrieval of the directory component - see also SplitPath() test
TEST (Path, GetFileDirectory)
{
    EXPECT_STREQ ("/etc", GetFileDirectory ("/etc/config").c_str ());
    EXPECT_STREQ ("/etc", GetFileDirectory ("/etc/").c_str ());
    EXPECT_STREQ ("/",    GetFileDirectory ("/etc").c_str ());
    EXPECT_STREQ ("./",   GetFileDirectory ("./CMakeLists.txt").c_str ());
    EXPECT_STREQ ("../",  GetFileDirectory ("../CMakeLists.txt").c_str ());

    // test with invalid argument
    EXPECT_THROW (GetFileDirectory (""), invalid_argument);
}

// ***************************************************************************
// Tests the retrieval of the file name component - see also SplitPath() test
TEST (Path, GetFileName)
{
    EXPECT_STREQ ("word.doc",      GetFileName ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("README",        GetFileName ("doc/README").c_str ());
    EXPECT_STREQ ("Copyright.txt", GetFileName ("Copyright.txt").c_str ());

    // test with invalid argument
    EXPECT_THROW (GetFileDirectory (""), invalid_argument);
}

// ***************************************************************************
// Tests the retrieval of the file name component - see also SplitPath() test
TEST (Path, GetFileNameWithoutExtension)
{
    EXPECT_STREQ ("word",      GetFileNameWithoutExtension ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("README",    GetFileNameWithoutExtension ("doc/README").c_str ());
    EXPECT_STREQ ("Copyright", GetFileNameWithoutExtension ("Copyright.txt").c_str ());

    // test with invalid argument
    EXPECT_THROW (GetFileNameWithoutExtension (""), invalid_argument);
}

// ***************************************************************************
// Tests the retrieval of the extension component - see also SplitPath() test
TEST (Path, GetFileNameExtension)
{
    EXPECT_STREQ (".doc", GetFileNameExtension ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("",     GetFileNameExtension ("doc/README").c_str ());
    EXPECT_STREQ (".txt", GetFileNameExtension ("Copyright.txt").c_str ());

    // test with invalid argument
    EXPECT_THROW (GetFileNameExtension (""), invalid_argument);
}

//////////////////////////////////////////////////////////////////////////////
// absolute / relative paths
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
// Tests the check whether a path is absolute or not
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
// Tests the check whether a path is relative or not
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
// Tests the conversion of a path to an absolute path
TEST (Path, ToAbsolutePath)
{
#if WINDOWS
    EXPECT_STREQ ("C:/usr/local",  ToAbsolutePath ("/usr",   "local").c_str ());
    EXPECT_STREQ ("C:/usr/local",  ToAbsolutePath ("/usr/",  "local").c_str ());
    EXPECT_STREQ ("C:/usr/local/", ToAbsolutePath ("/usr/",  "local/").c_str ());
    EXPECT_STREQ ("C:/usr/local/", ToAbsolutePath ("\\usr/", "local/").c_str ());
    EXPECT_STREQ ("C:/tmp",        ToAbsolutePath ("/usr",   "/tmp").c_str ());
    EXPECT_STREQ ("C:/tmp",        ToAbsolutePath ("/usr",   "\\tmp").c_str ());
    EXPECT_STREQ ("C:/tmp/",       ToAbsolutePath ("/usr",   "/tmp/").c_str ());
    EXPECT_STREQ ("C:/tmp/",       ToAbsolutePath ("/usr",   "/tmp\\").c_str ());
#else
    EXPECT_STREQ ("/usr/local",  ToAbsolutePath ("/usr",   "local").c_str ());
    EXPECT_STREQ ("/usr/local",  ToAbsolutePath ("/usr/",  "local").c_str ());
    EXPECT_STREQ ("/usr/local/", ToAbsolutePath ("/usr/",  "local/").c_str ());
    EXPECT_STREQ ("/usr/local/", ToAbsolutePath ("\\usr/", "local/").c_str ());
    EXPECT_STREQ ("/tmp",        ToAbsolutePath ("/usr",   "/tmp").c_str ());
    EXPECT_STREQ ("/tmp",        ToAbsolutePath ("/usr",   "\\tmp").c_str ());
    EXPECT_STREQ ("/tmp/",       ToAbsolutePath ("/usr",   "/tmp/").c_str ());
    EXPECT_STREQ ("/tmp/",       ToAbsolutePath ("/usr",   "/tmp\\").c_str ());
#endif

    string wd = GetWorkingDirectory ();

    EXPECT_TRUE (ToAbsolutePath ("tmp") == ToAbsolutePath (wd, "tmp"));

    EXPECT_THROW (ToAbsolutePath (""), invalid_argument);
}

// ***************************************************************************
// Tests the conversion of a path to a relative path
TEST (Path, ToRelativePath)
{
    EXPECT_STREQ (".",             ToRelativePath ("/usr",        "/usr").c_str ());
    EXPECT_STREQ ("..",            ToRelativePath ("/usr/local",  "/usr").c_str ());
    EXPECT_STREQ ("..",            ToRelativePath ("/usr/local/", "/usr").c_str ());
    EXPECT_STREQ ("../",           ToRelativePath ("/usr/local",  "/usr/").c_str ());
    EXPECT_STREQ ("../config.txt", ToRelativePath ("/usr/local",  "/usr/config.txt").c_str ());
}

//////////////////////////////////////////////////////////////////////////////
// symbolic links
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
// Tests the check whether a given file is a symbolic link
TEST (Path, IsSymbolicLink)
{
#if WINDOWS
    EXPECT_FALSE (IsSymbolicLink ("/proc/exe"))
#else
    const string tmpDir = GetWorkingDirectory () + "/basis-path-test-IsSymbolicLink";
    string cmd, link, value;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    link  = tmpDir; link += "/symlink";
    value = ".";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (IsSymbolicLink (link)) << "Link: " << link;
    link  = tmpDir; link += "/nolink";
    value = "";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_FALSE (IsSymbolicLink (link)) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0);
#endif
}

// ***************************************************************************
// Tests the reading of a symbolic link's value
TEST (Path, ReadSymbolicLink)
{
    std::string value;
#if WINDOWS
    EXPECT_TRUE (ReadSymbolicLink ("/proc/exe", value));
    EXPECT_TRUE (value == "/proc/exe");
    EXPECT_TRUE (ReadSymbolicLink ("/does/not/exist", value));
    EXPECT_TRUE (value == "/does/not/exist");
#else
    const string tmpDir = GetWorkingDirectory () + "/basis-path-test-ReadSymbolicLink";
    string cmd, link;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";

    link  = tmpDir; link += "/symlink";
    value = "hello world";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    value = "";
    EXPECT_TRUE (ReadSymbolicLink (link, value)) << "Link: " << link;
    EXPECT_STREQ ("hello world", value.c_str ());
    link  = tmpDir; link += "/nolink";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_FALSE (ReadSymbolicLink (link, value)) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (system (cmd.c_str ()) == 0);
#endif

    EXPECT_THROW (ReadSymbolicLink ("",     value), invalid_argument);
    EXPECT_THROW (ReadSymbolicLink ("C::/", value), invalid_argument);
}

// ***************************************************************************
// Tests the retrieval of an actual absolute path with symbolic links resolved
TEST (Path, GetRealPath)
{
#if WINDOWS
#else
    const string wd     = GetWorkingDirectory ();
    const string tmpDir = wd + "/basis-path-test-GetRealPath";
    string cmd, link, value;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";

    link  = tmpDir; link += "/symlink";
    value = "..";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_NO_THROW (value = GetRealPath (link)) << "Link: " << link;
    EXPECT_STREQ (wd.c_str (), value.c_str ()) << "Link: " << link;
    link  = tmpDir; link += "/nolink";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (GetRealPath (link) == link) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (system (cmd.c_str ()) == 0);
#endif
}

//////////////////////////////////////////////////////////////////////////////
// executable file
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
// Tests the retrieval of the current executable's path
TEST (Path, GetExecutablePath)
{
    string path;
    EXPECT_NO_THROW (path = GetExecutablePath ());
    cout << path << endl;
    EXPECT_STREQ ("test_path", GetFileNameWithoutExtension (path).c_str ());
}

// ***************************************************************************
// Tests the retrieval of the current executable's name
TEST (Path, GetExecutableName)
{
    string name;
    EXPECT_NO_THROW (name = GetExecutableName ());
    EXPECT_STREQ ("test_path", name.c_str ());
}

