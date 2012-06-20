/**
 * @file  test_path.cxx
 * @brief Test of path.cxx module.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <stdexcept>

#include <sbia/basis/config.h> // WINDOWS, UNIX macros
#include <sbia/basis/test.h>   // unit testing framework
#include <sbia/basis/os.h>     // testee

#if UNIX
#  include <stdlib.h> // the system() function is used to create symbolic links
#endif


using namespace sbia::basis;
using namespace std;


// ===========================================================================
// path representations
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the validation of a path string
TEST (Path, IsValidPath)
{
    // test with valid Unix-style paths
    EXPECT_TRUE (os::path::isvalid ("/"));
    EXPECT_TRUE (os::path::isvalid ("/usr"));
    EXPECT_TRUE (os::path::isvalid ("/usr/"));
    EXPECT_TRUE (os::path::isvalid ("////../../usr/./"));
    EXPECT_TRUE (os::path::isvalid ("."));
    EXPECT_TRUE (os::path::isvalid (".."));
    EXPECT_TRUE (os::path::isvalid ("./"));

    // test with valid Windows-style paths
    EXPECT_TRUE (os::path::isvalid ("\\"));
    EXPECT_TRUE (os::path::isvalid (".\\"));
    EXPECT_TRUE (os::path::isvalid ("..\\"));
#if WINDOWS
    for (char letter = 'A'; letter <= 'Z'; ++ letter) {
        std::string path;
        path += letter;
        path += ":/";
        EXPECT_TRUE (os::path::isvalid (path)) << "Path " << path << " should be valid on Windows";
    }
#endif
    EXPECT_TRUE (os::path::isvalid ("C:\\..\\"));
    EXPECT_TRUE (os::path::isvalid ("C:\\WINDOWS"));
    EXPECT_TRUE (os::path::isvalid ("C:\\WINDOWS\\"));
    EXPECT_TRUE (os::path::isvalid ("C:\\WINDOWS\\.."));
    EXPECT_TRUE (os::path::isvalid ("C:\\WINDOWS\\."));

    // test with valid mixed-style paths
    EXPECT_TRUE (os::path::isvalid ("//\\/..\\../usr/./"));
    EXPECT_TRUE (os::path::isvalid ("c:/"));
    EXPECT_TRUE (os::path::isvalid ("c:/WINDOWS"));
    EXPECT_TRUE (os::path::isvalid ("c:/WINDOWS\\"));

    // test with invalid paths
    EXPECT_FALSE (os::path::isvalid (""));
    EXPECT_FALSE (os::path::isvalid (":"));
    EXPECT_FALSE (os::path::isvalid ("::"));
    EXPECT_FALSE (os::path::isvalid (":\\"));
    EXPECT_FALSE (os::path::isvalid (":/"));
    EXPECT_FALSE (os::path::isvalid ("1:/"));
#if !WINDOWS
    for (char letter = 'A'; letter <= 'Z'; ++ letter) {
        if (letter == 'C') continue;
        std::string path;
        path += letter;
        path += ":/";
        EXPECT_FALSE (os::path::isvalid (path)) << "Path " << path << " is invalid on Unix systems";
    }
#endif
}

// ---------------------------------------------------------------------------
// Tests the cleaning/simplifying of a path
TEST (Path, CleanPath)
{
    // test with (almost) already clean paths
    EXPECT_STREQ ("/usr",          os::path::normpath ("/usr").c_str ());
    EXPECT_STREQ ("/usr/",         os::path::normpath ("/usr/").c_str ());
    EXPECT_STREQ ("/",             os::path::normpath ("/").c_str ());
    EXPECT_STREQ ("C:/",           os::path::normpath ("C:/").c_str ());
    EXPECT_STREQ ("C:\\",          os::path::normpath ("C:\\").c_str ());
    EXPECT_STREQ ("../../",        os::path::normpath ("../../").c_str ());
    EXPECT_STREQ ("../../../",     os::path::normpath ("../../../").c_str ());
    EXPECT_STREQ ("../../../usr/", os::path::normpath ("../../../usr/local/../").c_str ());
    EXPECT_STREQ (".",             os::path::normpath (".").c_str ());
    EXPECT_STREQ ("./",            os::path::normpath ("./").c_str ());
    EXPECT_STREQ ("./..",          os::path::normpath ("./..").c_str ());

    // test some simple cases
    EXPECT_STREQ ("/",          os::path::normpath ("/").c_str ());
    EXPECT_STREQ ("/",          os::path::normpath ("/..").c_str ());
    EXPECT_STREQ ("/",          os::path::normpath ("/../..").c_str ());
    EXPECT_STREQ ("/",          os::path::normpath ("/../../.").c_str ());
    EXPECT_STREQ ("/",          os::path::normpath ("/.././../.").c_str ());
    EXPECT_STREQ ("\\",         os::path::normpath ("\\").c_str ());
    EXPECT_STREQ ("\\",         os::path::normpath ("\\..\\..").c_str ());
    EXPECT_STREQ ("\\",         os::path::normpath ("\\..\\..\\.").c_str ());
    EXPECT_STREQ ("\\",         os::path::normpath ("\\..\\.\\..\\.").c_str ());
    EXPECT_STREQ ("C:/",        os::path::normpath ("C:/").c_str ());
    EXPECT_STREQ ("C:\\",       os::path::normpath ("C:\\").c_str ());
    EXPECT_STREQ ("/usr/local", os::path::normpath ("/usr/local/.").c_str ());
    EXPECT_STREQ ("/usr",       os::path::normpath ("/usr/local/..").c_str ());

    // test some more complicated cases
    EXPECT_STREQ ("/usr\\",           os::path::normpath ("/usr/local/.///./\\/\\/\\///\\\\\\///..\\\\.\\./").c_str ());
    EXPECT_STREQ ("..\\../path\\sub", os::path::normpath ("..\\//../path\\/\\///./.\\sub").c_str ());

    // test with invalid paths
    EXPECT_THROW (os::path::normpath (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to Unix-style
TEST (Path, ToPosixPath)
{
    EXPECT_STREQ ("/etc",       os::path::posix ("\\usr/..\\etc").c_str ());
    EXPECT_STREQ ("/etc/",      os::path::posix ("\\usr/..\\etc\\").c_str ());
    EXPECT_STREQ ("/usr/local", os::path::posix ("/usr/././//\\\\/./\\.\\local/bin\\..").c_str ());
    EXPECT_STREQ ("/WINDOWS",   os::path::posix ("C:\\WINDOWS").c_str ());
    EXPECT_STREQ ("/WINDOWS",   os::path::posix ("C:\\WINDOWS", false).c_str ());
    EXPECT_STREQ ("C:/WINDOWS", os::path::posix ("C:\\WINDOWS", true).c_str ());
    EXPECT_STREQ ("C:/WINDOWS", os::path::posix ("c:\\WINDOWS", true).c_str ());

    // test with invalid paths
    EXPECT_THROW (os::path::posix (""),      invalid_argument);
    EXPECT_THROW (os::path::posix ("C::\\"), invalid_argument);
#if !WINDOWS
    EXPECT_THROW (os::path::posix ("D:\\"),  invalid_argument);
#endif
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to Windows-style
TEST (Path, ToWindowsPath)
{
    EXPECT_STREQ ("C:\\WINDOWS",          os::path::nt ("/WINDOWS").c_str ());
    EXPECT_STREQ ("C:\\WINDOWS",          os::path::nt ("C:\\WINDOWS").c_str ());
    EXPECT_STREQ ("D:\\",                 os::path::nt ("D:\\").c_str ());
    EXPECT_STREQ ("D:\\",                 os::path::nt ("D:/").c_str ());
    EXPECT_STREQ ("C:\\Users\\andreas",   os::path::nt ("/Users/andreas").c_str ());
    EXPECT_STREQ ("C:\\Users\\andreas\\", os::path::nt ("/Users/andreas/").c_str ());

    // test with invalid paths
    EXPECT_THROW (os::path::nt (""),      invalid_argument);
    EXPECT_THROW (os::path::nt ("C::\\"), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to the native style of the used OS
TEST (Path, ToNativePath)
{
#if WINDOWS
    EXPECT_STREQ ("C:\\tmp", os::path::native ("/tmp").c_str ());
#else
    EXPECT_STREQ ("/tmp",    os::path::native ("C:\\tmp").c_str ());
#endif
}

// ===========================================================================
// path components
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the splitting of a path into its components
TEST (Path, SplitPath)
{
    string root, dir, fname, ext;

    // test with empty string
    EXPECT_THROW (os::path::split ("", &root, &dir, &fname, &ext), invalid_argument);

    // test with NULL arguments only
    EXPECT_NO_THROW (os::path::split ("/", NULL, NULL, NULL, NULL));

    // test the paths given as example in the documentation
    EXPECT_NO_THROW (os::path::split ("/usr/bin", &root, &dir, &fname, &ext));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/",  root.c_str ());
#endif
    EXPECT_STREQ ("usr/", dir  .c_str ());
    EXPECT_STREQ ("bin",  fname.c_str ());
    EXPECT_STREQ ("",     ext  .c_str ());
 
    EXPECT_NO_THROW (os::path::split ("/home/user/info.txt", &root, &dir, &fname, &ext));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/", root.c_str ());
#endif
    EXPECT_STREQ ("home/user/", dir  .c_str ());
    EXPECT_STREQ ("info",       fname.c_str ());
    EXPECT_STREQ (".txt",       ext  .c_str ());

    EXPECT_NO_THROW (os::path::split ("word.doc", &root, &dir, &fname, &ext));
    EXPECT_STREQ ("./",   root .c_str ());
    EXPECT_STREQ ("",     dir  .c_str ());
    EXPECT_STREQ ("word", fname.c_str ());
    EXPECT_STREQ (".doc", ext  .c_str ());

    EXPECT_NO_THROW (os::path::split ("../word.doc", &root, &dir, &fname, &ext));
    EXPECT_STREQ ("./",   root .c_str ());
    EXPECT_STREQ ("../",  dir  .c_str ());
    EXPECT_STREQ ("word", fname.c_str ());
    EXPECT_STREQ (".doc", ext  .c_str ());

    EXPECT_NO_THROW (os::path::split ("C:/WINDOWS/regedit.exe", &root, &dir, &fname, &ext));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/", root.c_str ());
#endif
    EXPECT_STREQ ("WINDOWS/", dir  .c_str ());
    EXPECT_STREQ ("regedit",  fname.c_str ());
    EXPECT_STREQ (".exe",     ext  .c_str ());
 
#if WINDOWS
    EXPECT_NO_THROW (os::path::split ("d:\\data", &root, &dir, &fname, &ext));
    EXPECT_STREQ ("D:/",  root.c_str ());
    EXPECT_STREQ ("",     dir .c_str ());
    EXPECT_STREQ ("data", fname.c_str ());
    EXPECT_STREQ ("",     ext  .c_str ());
#else
    EXPECT_THROW (os::path::split ("d:\\data", &root, &dir, &fname, &ext), invalid_argument);
#endif
 
    EXPECT_NO_THROW (os::path::split ("/usr/local/", &root, &dir, &fname, &ext));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/", root.c_str ());
#endif
    EXPECT_STREQ ("usr/local/", dir  .c_str ());
    EXPECT_STREQ ("",           fname.c_str ());
    EXPECT_STREQ ("",           ext  .c_str ());

    set<string> exts;
    exts.insert(".nii");
    exts.insert(".gz");
    exts.insert(".hdr");

    EXPECT_NO_THROW (os::path::split ("/home/andreas/brain.nii.gz", &root, &dir, &fname, &ext, &exts));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/", root.c_str ());
#endif
    EXPECT_STREQ ("home/andreas/", dir  .c_str());
    EXPECT_STREQ ("brain.nii",      fname.c_str());
    EXPECT_STREQ (".gz",            ext  .c_str());

    exts.insert(".nii.gz");
    EXPECT_NO_THROW (os::path::split ("/home/andreas/brain.nii.gz", &root, &dir, &fname, &ext, &exts));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/", root.c_str ());
#endif
    EXPECT_STREQ ("home/andreas/", dir  .c_str());
    EXPECT_STREQ ("brain",          fname.c_str());
    EXPECT_STREQ (".nii.gz",        ext  .c_str());
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the file root
TEST (Path, GetFileRoot)
{
    // relative Unix-style path
    EXPECT_STREQ ("./", os::path::rootname ("readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname ("./readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname ("../readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname ("dir/readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname ("../dir/readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname ("./dir/readme.txt").c_str ());

    // relative Windows-style path
    EXPECT_STREQ ("./", os::path::rootname (".\\readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname ("..\\readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname ("dir\\readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname (".\\dir\\readme.txt").c_str ());
    EXPECT_STREQ ("./", os::path::rootname ("..\\dir\\readme.txt").c_str ());

    // absolute Unix-style path
#if WINDOWS
    EXPECT_STREQ ("C:/", os::path::rootname ("/").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("/.").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("/./").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("/..").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("/usr").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("/usr/").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("/usr/..").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("/usr/local").c_str ());
#else
    EXPECT_STREQ ("/", os::path::rootname ("/").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("/.").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("/./").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("/..").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("/usr").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("/usr/").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("/usr/..").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("/usr/local").c_str ());
#endif

    // absolute Windows-style path
#if WINDOWS
    EXPECT_STREQ ("C:/", os::path::rootname ("\\").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("\\WINDOWS").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("c:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("C:/", os::path::rootname ("C:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("D:/", os::path::rootname ("d:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("A:/", os::path::rootname ("a:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("Z:/", os::path::rootname ("z:\\WINDOWS\\").c_str ());
#else
    EXPECT_STREQ ("/", os::path::rootname ("\\").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("\\WINDOWS").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("c:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("/", os::path::rootname ("C:\\WINDOWS\\").c_str ());
    EXPECT_THROW (os::path::rootname ("d:\\WINDOWS\\"), invalid_argument);
    EXPECT_THROW (os::path::rootname ("a:\\WINDOWS\\"), invalid_argument);
    EXPECT_THROW (os::path::rootname ("z:\\WINDOWS\\"), invalid_argument);
#endif

    // test with invalid argument
    EXPECT_THROW (os::path::rootname (""),      invalid_argument);
    EXPECT_THROW (os::path::rootname ("C::/"),  invalid_argument);
    EXPECT_THROW (os::path::rootname ("C::\\"), invalid_argument);
    EXPECT_THROW (os::path::rootname (":/"),    invalid_argument);
    EXPECT_THROW (os::path::rootname (":\\"),   invalid_argument);
    EXPECT_THROW (os::path::rootname ("7:\\"),  invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the directory component - see also os::path::split() test
TEST (Path, GetFileDirectory)
{
#if WINDOWS
	EXPECT_STREQ ("C:/etc", os::path::dirname ("/etc/config").c_str ());
	EXPECT_STREQ ("C:/etc", os::path::dirname ("/etc/").c_str ());
	EXPECT_STREQ ("C:/",    os::path::dirname ("/etc").c_str ());
#else
    EXPECT_STREQ ("/etc", os::path::dirname ("/etc/config").c_str ());
    EXPECT_STREQ ("/etc", os::path::dirname ("/etc/").c_str ());
    EXPECT_STREQ ("/",    os::path::dirname ("/etc").c_str ());
#endif
    EXPECT_STREQ ("./",   os::path::dirname ("./CMakeLists.txt").c_str ());
    EXPECT_STREQ ("../",  os::path::dirname ("../CMakeLists.txt").c_str ());

    // test with invalid argument
    EXPECT_THROW (os::path::dirname (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the file name component - see also os::path::split() test
TEST (Path, GetFileName)
{
    EXPECT_STREQ ("word.doc",      os::path::basename ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("README",        os::path::basename ("doc/README").c_str ());
    EXPECT_STREQ ("Copyright.txt", os::path::basename ("Copyright.txt").c_str ());

    // test with invalid argument
    EXPECT_THROW (os::path::dirname (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the file name component - see also os::path::split() test
TEST (Path, GetFileNameWithoutExtension)
{
    EXPECT_STREQ ("word",      os::path::filename ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("README",    os::path::filename ("doc/README").c_str ());
    EXPECT_STREQ ("Copyright", os::path::filename ("Copyright.txt").c_str ());

    set<string> exts;
    exts.insert(".nii");
    exts.insert(".hdr");
    EXPECT_STREQ ("brain.nii", os::path::filename ("/home/andreas/brain.nii.gz", &exts).c_str());
    exts.insert(".gz");
    EXPECT_STREQ ("brain.nii", os::path::filename ("/home/andreas/brain.nii.gz", &exts).c_str());
    exts.insert(".nii.gz");
    EXPECT_STREQ ("brain", os::path::filename ("/home/andreas/brain.nii.gz", &exts).c_str());

    // test with invalid argument
    EXPECT_THROW (os::path::filename (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the extension component - see also os::path::split() test
TEST (Path, GetFileNameExtension)
{
    EXPECT_STREQ (".doc", os::path::fileext ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("",     os::path::fileext ("doc/README").c_str ());
    EXPECT_STREQ (".txt", os::path::fileext ("Copyright.txt").c_str ());

    set<string> exts;
    exts.insert(".nii");
    exts.insert(".hdr");
    EXPECT_STREQ (".gz", os::path::fileext ("/home/andreas/brain.nii.gz", &exts).c_str());
    exts.insert(".gz");
    EXPECT_STREQ (".gz", os::path::fileext ("/home/andreas/brain.nii.gz", &exts).c_str());
    exts.insert(".nii.gz");
    EXPECT_STREQ (".nii.gz", os::path::fileext ("/home/andreas/brain.nii.gz", &exts).c_str());

    // test with invalid argument
    EXPECT_THROW (os::path::fileext (""), invalid_argument);
}

// ===========================================================================
// absolute / relative paths
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the check whether a path is absolute or not
TEST (Path, IsAbsolute)
{
    // test with Unix-style relative paths
    EXPECT_FALSE (os::path::isabs ("readme.txt"));
    EXPECT_FALSE (os::path::isabs ("./readme.txt"));
    EXPECT_FALSE (os::path::isabs ("../readme.txt"));
    EXPECT_FALSE (os::path::isabs ("dir/readme.txt"));
    EXPECT_FALSE (os::path::isabs ("./dir/readme.txt"));
    EXPECT_FALSE (os::path::isabs ("../dir/readme.txt"));

    // test with Unix-style absolute path
    EXPECT_TRUE (os::path::isabs ("/usr"));
    EXPECT_TRUE (os::path::isabs ("/usr/local"));
    EXPECT_TRUE (os::path::isabs ("/."));
    EXPECT_TRUE (os::path::isabs ("/.."));

    // test with Windows-style relative path
    EXPECT_FALSE (os::path::isabs (".\\readme.txt"));
    EXPECT_FALSE (os::path::isabs ("..\\readme.txt"));
    EXPECT_FALSE (os::path::isabs ("dir\\readme.txt"));
    EXPECT_FALSE (os::path::isabs (".\\dir\\readme.txt"));
    EXPECT_FALSE (os::path::isabs ("..\\dir\\readme.txt"));

    // test with Windows-style absolute path
    EXPECT_TRUE (os::path::isabs ("\\WINDOWS"));
    EXPECT_TRUE (os::path::isabs ("c:\\WINDOWS"));
    EXPECT_TRUE (os::path::isabs ("C:\\WINDOWS"));
    EXPECT_TRUE (os::path::isabs ("C:\\"));
    EXPECT_TRUE (os::path::isabs ("C:\\."));
}

// ---------------------------------------------------------------------------
// Tests the check whether a path is relative or not
TEST (Path, IsRelative)
{
    // test with Unix-style relative paths
    EXPECT_TRUE (os::path::isrel ("readme.txt"));
    EXPECT_TRUE (os::path::isrel ("./readme.txt"));
    EXPECT_TRUE (os::path::isrel ("../readme.txt"));
    EXPECT_TRUE (os::path::isrel ("dir/readme.txt"));
    EXPECT_TRUE (os::path::isrel ("./dir/readme.txt"));
    EXPECT_TRUE (os::path::isrel ("../dir/readme.txt"));

    // test with Unix-style absolute path
    EXPECT_FALSE (os::path::isrel ("/usr"));
    EXPECT_FALSE (os::path::isrel ("/usr/local"));
    EXPECT_FALSE (os::path::isrel ("/."));
    EXPECT_FALSE (os::path::isrel ("/.."));

    // test with Windows-style relative path
    EXPECT_TRUE (os::path::isrel (".\\readme.txt"));
    EXPECT_TRUE (os::path::isrel ("..\\readme.txt"));
    EXPECT_TRUE (os::path::isrel ("dir\\readme.txt"));
    EXPECT_TRUE (os::path::isrel (".\\dir\\readme.txt"));
    EXPECT_TRUE (os::path::isrel ("..\\dir\\readme.txt"));

    // test with Windows-style absolute path
    EXPECT_FALSE (os::path::isrel ("\\WINDOWS"));
    EXPECT_FALSE (os::path::isrel ("c:\\WINDOWS"));
    EXPECT_FALSE (os::path::isrel ("C:\\WINDOWS"));
    EXPECT_FALSE (os::path::isrel ("C:\\"));
    EXPECT_FALSE (os::path::isrel ("C:\\."));
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to an absolute path
TEST (Path, ToAbsolutePath)
{
#if WINDOWS
    EXPECT_STREQ ("C:/usr/local",  os::path::abspath ("/usr",   "local").c_str ());
    EXPECT_STREQ ("C:/usr/local",  os::path::abspath ("/usr/",  "local").c_str ());
    EXPECT_STREQ ("C:/usr/local/", os::path::abspath ("/usr/",  "local/").c_str ());
    EXPECT_STREQ ("C:/usr/local/", os::path::abspath ("\\usr/", "local/").c_str ());
    EXPECT_STREQ ("C:/tmp",        os::path::abspath ("/usr",   "/tmp").c_str ());
    EXPECT_STREQ ("C:/tmp",        os::path::abspath ("/usr",   "\\tmp").c_str ());
    EXPECT_STREQ ("C:/tmp/",       os::path::abspath ("/usr",   "/tmp/").c_str ());
    EXPECT_STREQ ("C:/tmp/",       os::path::abspath ("/usr",   "/tmp\\").c_str ());
#else
    EXPECT_STREQ ("/usr/local",  os::path::abspath ("/usr",   "local").c_str ());
    EXPECT_STREQ ("/usr/local",  os::path::abspath ("/usr/",  "local").c_str ());
    EXPECT_STREQ ("/usr/local/", os::path::abspath ("/usr/",  "local/").c_str ());
    EXPECT_STREQ ("/usr/local/", os::path::abspath ("\\usr/", "local/").c_str ());
    EXPECT_STREQ ("/tmp",        os::path::abspath ("/usr",   "/tmp").c_str ());
    EXPECT_STREQ ("/tmp",        os::path::abspath ("/usr",   "\\tmp").c_str ());
    EXPECT_STREQ ("/tmp/",       os::path::abspath ("/usr",   "/tmp/").c_str ());
    EXPECT_STREQ ("/tmp/",       os::path::abspath ("/usr",   "/tmp\\").c_str ());
#endif

    string wd = os::getcwd();

    EXPECT_TRUE (os::path::abspath ("tmp") == os::path::abspath (wd, "tmp"));

    EXPECT_THROW (os::path::abspath (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to a relative path
TEST (Path, ToRelativePath)
{
    EXPECT_STREQ (".",             os::path::relpath ("/usr", "/usr").c_str ());
    EXPECT_STREQ ("..",            os::path::relpath ("/usr", "/usr/local").c_str ());
    EXPECT_STREQ ("..",            os::path::relpath ("/usr", "/usr/local/").c_str ());
    EXPECT_STREQ ("..",            os::path::relpath ("/usr/", "/usr/local").c_str ());
    EXPECT_STREQ ("../config.txt", os::path::relpath ("/usr/config.txt", "/usr/local").c_str ());
    EXPECT_STREQ ("Testing/bin",   os::path::relpath ("/usr/local/src/build/Testing/bin", "/usr/local/src/build").c_str ());
}

// ---------------------------------------------------------------------------
// Tests the joining of two paths.
TEST (Path, JoinPaths)
{
    EXPECT_STREQ ("./usr",          os::path::join (".", "usr").c_str ());
    EXPECT_STREQ ("/etc",           os::path::join ("/usr/local", "/etc").c_str ());
    EXPECT_STREQ ("\\etc",          os::path::join ("/usr/local", "\\etc").c_str ());
    EXPECT_STREQ ("/usr/local/etc", os::path::join ("/usr/local", "etc").c_str ());
}

// ===========================================================================
// symbolic links
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the check whether a given file is a symbolic link
TEST (Path, IsSymlink)
{
#if WINDOWS
    EXPECT_FALSE (os::path::islink ("/proc/exe"));
#else
    const string tmpDir = os::getcwd() + "/basis-path-test-os::path::islink";
    string cmd, link, value;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    link  = tmpDir; link += "/symlink";
    value = ".";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (os::path::islink (link)) << "Link: " << link;
    link  = tmpDir; link += "/nolink";
    value = "";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_FALSE (os::path::islink (link)) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0);
#endif
}

// ---------------------------------------------------------------------------
// Tests the retrieval of an actual absolute path with symbolic links resolved
TEST (Path, GetRealPath)
{
#if WINDOWS
#else
    const string wd     = os::getcwd();
    const string tmpDir = wd + "/basis-path-test-get_real_path";
    string cmd, link, value;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system(cmd.c_str ()) == 0) << cmd << " failed";
    ASSERT_TRUE (system(cmd.c_str ()) == 0) << cmd << " failed";

    link  = tmpDir; link += "/symlink";
    value = "..";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system(cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_NO_THROW (value = os::path::realpath(link)) << "Link: " << link;
    EXPECT_STREQ (wd.c_str (), value.c_str ()) << "Link: " << link;
    link  = tmpDir; link += "/nolink";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system(cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (os::path::realpath(link) == link) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system(cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (system(cmd.c_str ()) == 0);
#endif
}
