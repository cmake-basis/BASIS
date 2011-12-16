/**
 * @file  test_path.cxx
 * @brief Test of path.cxx module.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <stdexcept>

#include <sbia/basis/config.h> // WINDOWS, UNIX macros
#include <sbia/basis/test.h> // unit testing framework
#include <sbia/basis/path.h> // testee

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
TEST (Path, is_valid_path)
{
    // test with valid Unix-style paths
    EXPECT_TRUE (is_valid_path ("/"));
    EXPECT_TRUE (is_valid_path ("/usr"));
    EXPECT_TRUE (is_valid_path ("/usr/"));
    EXPECT_TRUE (is_valid_path ("////../../usr/./"));
    EXPECT_TRUE (is_valid_path ("."));
    EXPECT_TRUE (is_valid_path (".."));
    EXPECT_TRUE (is_valid_path ("./"));

    // test with valid Windows-style paths
    EXPECT_TRUE (is_valid_path ("\\"));
    EXPECT_TRUE (is_valid_path (".\\"));
    EXPECT_TRUE (is_valid_path ("..\\"));
#if WINDOWS
    for (char letter = 'A'; letter <= 'Z'; ++ letter) {
        std::string path;
        path += letter;
        path += ":/";
        EXPECT_TRUE (is_valid_path (path)) << "Path " << path << " should be valid on Windows";
    }
#endif
    EXPECT_TRUE (is_valid_path ("C:\\..\\"));
    EXPECT_TRUE (is_valid_path ("C:\\WINDOWS"));
    EXPECT_TRUE (is_valid_path ("C:\\WINDOWS\\"));
    EXPECT_TRUE (is_valid_path ("C:\\WINDOWS\\.."));
    EXPECT_TRUE (is_valid_path ("C:\\WINDOWS\\."));

    // test with valid mixed-style paths
    EXPECT_TRUE (is_valid_path ("//\\/..\\../usr/./"));
    EXPECT_TRUE (is_valid_path ("c:/"));
    EXPECT_TRUE (is_valid_path ("c:/WINDOWS"));
    EXPECT_TRUE (is_valid_path ("c:/WINDOWS\\"));

    // test with invalid paths
    EXPECT_FALSE (is_valid_path (""));
    EXPECT_FALSE (is_valid_path (":"));
    EXPECT_FALSE (is_valid_path ("::"));
    EXPECT_FALSE (is_valid_path (":\\"));
    EXPECT_FALSE (is_valid_path (":/"));
    EXPECT_FALSE (is_valid_path ("1:/"));
#if !WINDOWS
    for (char letter = 'A'; letter <= 'Z'; ++ letter) {
        if (letter == 'C') continue;
        std::string path;
        path += letter;
        path += ":/";
        EXPECT_FALSE (is_valid_path (path)) << "Path " << path << " is invalid on Unix systems";
    }
#endif
}

// ---------------------------------------------------------------------------
// Tests the cleaning/simplifying of a path
TEST (Path, clean_path)
{
    // test with (almost) already clean paths
    EXPECT_STREQ ("/usr",          clean_path ("/usr").c_str ());
    EXPECT_STREQ ("/usr/",         clean_path ("/usr/").c_str ());
    EXPECT_STREQ ("/",             clean_path ("/").c_str ());
    EXPECT_STREQ ("C:/",           clean_path ("C:/").c_str ());
    EXPECT_STREQ ("C:\\",          clean_path ("C:\\").c_str ());
    EXPECT_STREQ ("../../",        clean_path ("../../").c_str ());
    EXPECT_STREQ ("../../../",     clean_path ("../../../").c_str ());
    EXPECT_STREQ ("../../../usr/", clean_path ("../../../usr/local/../").c_str ());
    EXPECT_STREQ (".",             clean_path (".").c_str ());
    EXPECT_STREQ ("./",            clean_path ("./").c_str ());
    EXPECT_STREQ ("./..",          clean_path ("./..").c_str ());

    // test some simple cases
    EXPECT_STREQ ("/",          clean_path ("/").c_str ());
    EXPECT_STREQ ("/",          clean_path ("/..").c_str ());
    EXPECT_STREQ ("/",          clean_path ("/../..").c_str ());
    EXPECT_STREQ ("/",          clean_path ("/../../.").c_str ());
    EXPECT_STREQ ("/",          clean_path ("/.././../.").c_str ());
    EXPECT_STREQ ("\\",         clean_path ("\\").c_str ());
    EXPECT_STREQ ("\\",         clean_path ("\\..\\..").c_str ());
    EXPECT_STREQ ("\\",         clean_path ("\\..\\..\\.").c_str ());
    EXPECT_STREQ ("\\",         clean_path ("\\..\\.\\..\\.").c_str ());
    EXPECT_STREQ ("C:/",        clean_path ("C:/").c_str ());
    EXPECT_STREQ ("C:\\",       clean_path ("C:\\").c_str ());
    EXPECT_STREQ ("/usr/local", clean_path ("/usr/local/.").c_str ());
    EXPECT_STREQ ("/usr",       clean_path ("/usr/local/..").c_str ());

    // test some more complicated cases
    EXPECT_STREQ ("/usr\\",           clean_path ("/usr/local/.///./\\/\\/\\///\\\\\\///..\\\\.\\./").c_str ());
    EXPECT_STREQ ("..\\../path\\sub", clean_path ("..\\//../path\\/\\///./.\\sub").c_str ());

    // test with invalid paths
    EXPECT_THROW (clean_path (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to Unix-style
TEST (Path, to_unix_path)
{
    EXPECT_STREQ ("/etc",       to_unix_path ("\\usr/..\\etc").c_str ());
    EXPECT_STREQ ("/etc/",      to_unix_path ("\\usr/..\\etc\\").c_str ());
    EXPECT_STREQ ("/usr/local", to_unix_path ("/usr/././//\\\\/./\\.\\local/bin\\..").c_str ());
    EXPECT_STREQ ("/WINDOWS",   to_unix_path ("C:\\WINDOWS").c_str ());
    EXPECT_STREQ ("/WINDOWS",   to_unix_path ("C:\\WINDOWS", false).c_str ());
    EXPECT_STREQ ("C:/WINDOWS", to_unix_path ("C:\\WINDOWS", true).c_str ());
    EXPECT_STREQ ("C:/WINDOWS", to_unix_path ("c:\\WINDOWS", true).c_str ());

    // test with invalid paths
    EXPECT_THROW (to_unix_path (""),      invalid_argument);
    EXPECT_THROW (to_unix_path ("C::\\"), invalid_argument);
#if !WINDOWS
    EXPECT_THROW (to_unix_path ("D:\\"),  invalid_argument);
#endif
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to Windows-style
TEST (Path, to_windows_path)
{
    EXPECT_STREQ ("C:\\WINDOWS",          to_windows_path ("/WINDOWS").c_str ());
    EXPECT_STREQ ("C:\\WINDOWS",          to_windows_path ("C:\\WINDOWS").c_str ());
    EXPECT_STREQ ("D:\\",                 to_windows_path ("D:\\").c_str ());
    EXPECT_STREQ ("D:\\",                 to_windows_path ("D:/").c_str ());
    EXPECT_STREQ ("C:\\Users\\andreas",   to_windows_path ("/Users/andreas").c_str ());
    EXPECT_STREQ ("C:\\Users\\andreas\\", to_windows_path ("/Users/andreas/").c_str ());

    // test with invalid paths
    EXPECT_THROW (to_windows_path (""),      invalid_argument);
    EXPECT_THROW (to_windows_path ("C::\\"), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to the native style of the used OS
TEST (Path, to_native_path)
{
#if WINDOWS
    EXPECT_STREQ ("C:\\tmp", to_native_path ("/tmp").c_str ());
#else
    EXPECT_STREQ ("/tmp",    to_native_path ("C:\\tmp").c_str ());
#endif
}

// ===========================================================================
// working directory
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the retrieval of the current working directory
TEST (Path, get_working_directory)
{
    // get working directory
    string wd;
    ASSERT_NO_THROW (wd = get_working_directory ());

    // path may not be empty
    ASSERT_FALSE (wd.empty ()) << "Working directory may not be empty";

    // path should be absolute
    EXPECT_FALSE (is_relative (wd)) << "Working directory must be absolute";

    // path should have only slashes, no backslashes
    EXPECT_EQ (string::npos, wd.find ('\\')) << "Working directory may only contain slashes (/) as path separators";

    // path should not have trailing slash
    EXPECT_NE ('/', wd [wd.size () - 1]) << "Working directory must not have trailing slash (/)";
}

// ===========================================================================
// path components
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the splitting of a path into its components
TEST (Path, split_path)
{
    string root, dir, fname, ext;

    // test with empty string
    EXPECT_THROW (split_path ("", &root, &dir, &fname, &ext), invalid_argument);

    // test with NULL arguments only
    EXPECT_NO_THROW (split_path ("/", NULL, NULL, NULL, NULL));

    // test the paths given as example in the documentation
    EXPECT_NO_THROW (split_path ("/usr/bin", &root, &dir, &fname, &ext));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/",  root.c_str ());
#endif
    EXPECT_STREQ ("usr/", dir  .c_str ());
    EXPECT_STREQ ("bin",  fname.c_str ());
    EXPECT_STREQ ("",     ext  .c_str ());
 
    EXPECT_NO_THROW (split_path ("/home/user/info.txt", &root, &dir, &fname, &ext));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/", root.c_str ());
#endif
    EXPECT_STREQ ("home/user/", dir  .c_str ());
    EXPECT_STREQ ("info",       fname.c_str ());
    EXPECT_STREQ (".txt",       ext  .c_str ());

    EXPECT_NO_THROW (split_path ("word.doc", &root, &dir, &fname, &ext));
    EXPECT_STREQ ("./",   root .c_str ());
    EXPECT_STREQ ("",     dir  .c_str ());
    EXPECT_STREQ ("word", fname.c_str ());
    EXPECT_STREQ (".doc", ext  .c_str ());

    EXPECT_NO_THROW (split_path ("../word.doc", &root, &dir, &fname, &ext));
    EXPECT_STREQ ("./",   root .c_str ());
    EXPECT_STREQ ("../",  dir  .c_str ());
    EXPECT_STREQ ("word", fname.c_str ());
    EXPECT_STREQ (".doc", ext  .c_str ());

    EXPECT_NO_THROW (split_path ("C:/WINDOWS/regedit.exe", &root, &dir, &fname, &ext));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/", root.c_str ());
#endif
    EXPECT_STREQ ("WINDOWS/", dir  .c_str ());
    EXPECT_STREQ ("regedit",  fname.c_str ());
    EXPECT_STREQ (".exe",     ext  .c_str ());
 
#if WINDOWS
    EXPECT_NO_THROW (split_path ("d:\\data", &root, &dir, &fname, &ext));
    EXPECT_STREQ ("D:/",  root.c_str ());
    EXPECT_STREQ ("",     dir .c_str ());
    EXPECT_STREQ ("data", fname.c_str ());
    EXPECT_STREQ ("",     ext  .c_str ());
#else
    EXPECT_THROW (split_path ("d:\\data", &root, &dir, &fname, &ext), invalid_argument);
#endif
 
    EXPECT_NO_THROW (split_path ("/usr/local/", &root, &dir, &fname, &ext));
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

    EXPECT_NO_THROW (split_path ("/home/andreas/brain.nii.gz", &root, &dir, &fname, &ext, &exts));
#if WINDOWS
    EXPECT_STREQ ("C:/", root.c_str ());
#else
    EXPECT_STREQ ("/", root.c_str ());
#endif
    EXPECT_STREQ ("home/andreas/", dir  .c_str());
    EXPECT_STREQ ("brain.nii",      fname.c_str());
    EXPECT_STREQ (".gz",            ext  .c_str());

    exts.insert(".nii.gz");
    EXPECT_NO_THROW (split_path ("/home/andreas/brain.nii.gz", &root, &dir, &fname, &ext, &exts));
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
TEST (Path, get_file_root)
{
    // relative Unix-style path
    EXPECT_STREQ ("./", get_file_root ("readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root ("./readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root ("../readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root ("dir/readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root ("../dir/readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root ("./dir/readme.txt").c_str ());

    // relative Windows-style path
    EXPECT_STREQ ("./", get_file_root (".\\readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root ("..\\readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root ("dir\\readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root (".\\dir\\readme.txt").c_str ());
    EXPECT_STREQ ("./", get_file_root ("..\\dir\\readme.txt").c_str ());

    // absolute Unix-style path
#if WINDOWS
    EXPECT_STREQ ("C:/", get_file_root ("/").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("/.").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("/./").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("/..").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("/usr").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("/usr/").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("/usr/..").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("/usr/local").c_str ());
#else
    EXPECT_STREQ ("/", get_file_root ("/").c_str ());
    EXPECT_STREQ ("/", get_file_root ("/.").c_str ());
    EXPECT_STREQ ("/", get_file_root ("/./").c_str ());
    EXPECT_STREQ ("/", get_file_root ("/..").c_str ());
    EXPECT_STREQ ("/", get_file_root ("/usr").c_str ());
    EXPECT_STREQ ("/", get_file_root ("/usr/").c_str ());
    EXPECT_STREQ ("/", get_file_root ("/usr/..").c_str ());
    EXPECT_STREQ ("/", get_file_root ("/usr/local").c_str ());
#endif

    // absolute Windows-style path
#if WINDOWS
    EXPECT_STREQ ("C:/", get_file_root ("\\").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("\\WINDOWS").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("c:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("C:/", get_file_root ("C:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("D:/", get_file_root ("d:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("A:/", get_file_root ("a:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("Z:/", get_file_root ("z:\\WINDOWS\\").c_str ());
#else
    EXPECT_STREQ ("/", get_file_root ("\\").c_str ());
    EXPECT_STREQ ("/", get_file_root ("\\WINDOWS").c_str ());
    EXPECT_STREQ ("/", get_file_root ("\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("/", get_file_root ("c:\\WINDOWS\\").c_str ());
    EXPECT_STREQ ("/", get_file_root ("C:\\WINDOWS\\").c_str ());
    EXPECT_THROW (get_file_root ("d:\\WINDOWS\\"), invalid_argument);
    EXPECT_THROW (get_file_root ("a:\\WINDOWS\\"), invalid_argument);
    EXPECT_THROW (get_file_root ("z:\\WINDOWS\\"), invalid_argument);
#endif

    // test with invalid argument
    EXPECT_THROW (get_file_root (""),      invalid_argument);
    EXPECT_THROW (get_file_root ("C::/"),  invalid_argument);
    EXPECT_THROW (get_file_root ("C::\\"), invalid_argument);
    EXPECT_THROW (get_file_root (":/"),    invalid_argument);
    EXPECT_THROW (get_file_root (":\\"),   invalid_argument);
    EXPECT_THROW (get_file_root ("7:\\"),  invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the directory component - see also split_path() test
TEST (Path, get_file_directory)
{
#if WINDOWS
	EXPECT_STREQ ("C:/etc", get_file_directory ("/etc/config").c_str ());
	EXPECT_STREQ ("C:/etc", get_file_directory ("/etc/").c_str ());
	EXPECT_STREQ ("C:/",    get_file_directory ("/etc").c_str ());
#else
    EXPECT_STREQ ("/etc", get_file_directory ("/etc/config").c_str ());
    EXPECT_STREQ ("/etc", get_file_directory ("/etc/").c_str ());
    EXPECT_STREQ ("/",    get_file_directory ("/etc").c_str ());
#endif
    EXPECT_STREQ ("./",   get_file_directory ("./CMakeLists.txt").c_str ());
    EXPECT_STREQ ("../",  get_file_directory ("../CMakeLists.txt").c_str ());

    // test with invalid argument
    EXPECT_THROW (get_file_directory (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the file name component - see also split_path() test
TEST (Path, get_file_name)
{
    EXPECT_STREQ ("word.doc",      get_file_name ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("README",        get_file_name ("doc/README").c_str ());
    EXPECT_STREQ ("Copyright.txt", get_file_name ("Copyright.txt").c_str ());

    // test with invalid argument
    EXPECT_THROW (get_file_directory (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the file name component - see also split_path() test
TEST (Path, get_file_name_without_extension)
{
    EXPECT_STREQ ("word",      get_file_name_without_extension ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("README",    get_file_name_without_extension ("doc/README").c_str ());
    EXPECT_STREQ ("Copyright", get_file_name_without_extension ("Copyright.txt").c_str ());

    set<string> exts;
    exts.insert(".nii");
    exts.insert(".hdr");
    EXPECT_STREQ ("brain.nii", get_file_name_without_extension ("/home/andreas/brain.nii.gz", &exts).c_str());
    exts.insert(".gz");
    EXPECT_STREQ ("brain.nii", get_file_name_without_extension ("/home/andreas/brain.nii.gz", &exts).c_str());
    exts.insert(".nii.gz");
    EXPECT_STREQ ("brain", get_file_name_without_extension ("/home/andreas/brain.nii.gz", &exts).c_str());

    // test with invalid argument
    EXPECT_THROW (get_file_name_without_extension (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the extension component - see also split_path() test
TEST (Path, get_file_name_extension)
{
    EXPECT_STREQ (".doc", get_file_name_extension ("/Users/andreas/word.doc").c_str ());
    EXPECT_STREQ ("",     get_file_name_extension ("doc/README").c_str ());
    EXPECT_STREQ (".txt", get_file_name_extension ("Copyright.txt").c_str ());

    set<string> exts;
    exts.insert(".nii");
    exts.insert(".hdr");
    EXPECT_STREQ (".gz", get_file_name_extension ("/home/andreas/brain.nii.gz", &exts).c_str());
    exts.insert(".gz");
    EXPECT_STREQ (".gz", get_file_name_extension ("/home/andreas/brain.nii.gz", &exts).c_str());
    exts.insert(".nii.gz");
    EXPECT_STREQ (".nii.gz", get_file_name_extension ("/home/andreas/brain.nii.gz", &exts).c_str());

    // test with invalid argument
    EXPECT_THROW (get_file_name_extension (""), invalid_argument);
}

// ===========================================================================
// absolute / relative paths
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the check whether a path is absolute or not
TEST (Path, is_absolute)
{
    // test with Unix-style relative paths
    EXPECT_FALSE (is_absolute ("readme.txt"));
    EXPECT_FALSE (is_absolute ("./readme.txt"));
    EXPECT_FALSE (is_absolute ("../readme.txt"));
    EXPECT_FALSE (is_absolute ("dir/readme.txt"));
    EXPECT_FALSE (is_absolute ("./dir/readme.txt"));
    EXPECT_FALSE (is_absolute ("../dir/readme.txt"));

    // test with Unix-style absolute path
    EXPECT_TRUE (is_absolute ("/usr"));
    EXPECT_TRUE (is_absolute ("/usr/local"));
    EXPECT_TRUE (is_absolute ("/."));
    EXPECT_TRUE (is_absolute ("/.."));

    // test with Windows-style relative path
    EXPECT_FALSE (is_absolute (".\\readme.txt"));
    EXPECT_FALSE (is_absolute ("..\\readme.txt"));
    EXPECT_FALSE (is_absolute ("dir\\readme.txt"));
    EXPECT_FALSE (is_absolute (".\\dir\\readme.txt"));
    EXPECT_FALSE (is_absolute ("..\\dir\\readme.txt"));

    // test with Windows-style absolute path
    EXPECT_TRUE (is_absolute ("\\WINDOWS"));
    EXPECT_TRUE (is_absolute ("c:\\WINDOWS"));
    EXPECT_TRUE (is_absolute ("C:\\WINDOWS"));
    EXPECT_TRUE (is_absolute ("C:\\"));
    EXPECT_TRUE (is_absolute ("C:\\."));
}

// ---------------------------------------------------------------------------
// Tests the check whether a path is relative or not
TEST (Path, is_relative)
{
    // test with Unix-style relative paths
    EXPECT_TRUE (is_relative ("readme.txt"));
    EXPECT_TRUE (is_relative ("./readme.txt"));
    EXPECT_TRUE (is_relative ("../readme.txt"));
    EXPECT_TRUE (is_relative ("dir/readme.txt"));
    EXPECT_TRUE (is_relative ("./dir/readme.txt"));
    EXPECT_TRUE (is_relative ("../dir/readme.txt"));

    // test with Unix-style absolute path
    EXPECT_FALSE (is_relative ("/usr"));
    EXPECT_FALSE (is_relative ("/usr/local"));
    EXPECT_FALSE (is_relative ("/."));
    EXPECT_FALSE (is_relative ("/.."));

    // test with Windows-style relative path
    EXPECT_TRUE (is_relative (".\\readme.txt"));
    EXPECT_TRUE (is_relative ("..\\readme.txt"));
    EXPECT_TRUE (is_relative ("dir\\readme.txt"));
    EXPECT_TRUE (is_relative (".\\dir\\readme.txt"));
    EXPECT_TRUE (is_relative ("..\\dir\\readme.txt"));

    // test with Windows-style absolute path
    EXPECT_FALSE (is_relative ("\\WINDOWS"));
    EXPECT_FALSE (is_relative ("c:\\WINDOWS"));
    EXPECT_FALSE (is_relative ("C:\\WINDOWS"));
    EXPECT_FALSE (is_relative ("C:\\"));
    EXPECT_FALSE (is_relative ("C:\\."));
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to an absolute path
TEST (Path, to_absolute_path)
{
#if WINDOWS
    EXPECT_STREQ ("C:/usr/local",  to_absolute_path ("/usr",   "local").c_str ());
    EXPECT_STREQ ("C:/usr/local",  to_absolute_path ("/usr/",  "local").c_str ());
    EXPECT_STREQ ("C:/usr/local/", to_absolute_path ("/usr/",  "local/").c_str ());
    EXPECT_STREQ ("C:/usr/local/", to_absolute_path ("\\usr/", "local/").c_str ());
    EXPECT_STREQ ("C:/tmp",        to_absolute_path ("/usr",   "/tmp").c_str ());
    EXPECT_STREQ ("C:/tmp",        to_absolute_path ("/usr",   "\\tmp").c_str ());
    EXPECT_STREQ ("C:/tmp/",       to_absolute_path ("/usr",   "/tmp/").c_str ());
    EXPECT_STREQ ("C:/tmp/",       to_absolute_path ("/usr",   "/tmp\\").c_str ());
#else
    EXPECT_STREQ ("/usr/local",  to_absolute_path ("/usr",   "local").c_str ());
    EXPECT_STREQ ("/usr/local",  to_absolute_path ("/usr/",  "local").c_str ());
    EXPECT_STREQ ("/usr/local/", to_absolute_path ("/usr/",  "local/").c_str ());
    EXPECT_STREQ ("/usr/local/", to_absolute_path ("\\usr/", "local/").c_str ());
    EXPECT_STREQ ("/tmp",        to_absolute_path ("/usr",   "/tmp").c_str ());
    EXPECT_STREQ ("/tmp",        to_absolute_path ("/usr",   "\\tmp").c_str ());
    EXPECT_STREQ ("/tmp/",       to_absolute_path ("/usr",   "/tmp/").c_str ());
    EXPECT_STREQ ("/tmp/",       to_absolute_path ("/usr",   "/tmp\\").c_str ());
#endif

    string wd = get_working_directory ();

    EXPECT_TRUE (to_absolute_path ("tmp") == to_absolute_path (wd, "tmp"));

    EXPECT_THROW (to_absolute_path (""), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the conversion of a path to a relative path
TEST (Path, to_relative_path)
{
    EXPECT_STREQ (".",             to_relative_path ("/usr",        "/usr").c_str ());
    EXPECT_STREQ ("..",            to_relative_path ("/usr/local",  "/usr").c_str ());
    EXPECT_STREQ ("..",            to_relative_path ("/usr/local/", "/usr").c_str ());
    EXPECT_STREQ ("..",            to_relative_path ("/usr/local",  "/usr/").c_str ());
    EXPECT_STREQ ("../config.txt", to_relative_path ("/usr/local",  "/usr/config.txt").c_str ());
    EXPECT_STREQ ("Testing/bin",   to_relative_path ("/usr/local/src/build", "/usr/local/src/build/Testing/bin").c_str ());
}

// ---------------------------------------------------------------------------
// Tests the joining of two paths.
TEST (Path, join_paths)
{
    EXPECT_STREQ ("./usr",          join_paths (".", "usr").c_str ());
    EXPECT_STREQ ("/etc",           join_paths ("/usr/local", "/etc").c_str ());
    EXPECT_STREQ ("\\etc",          join_paths ("/usr/local", "\\etc").c_str ());
    EXPECT_STREQ ("/usr/local/etc", join_paths ("/usr/local", "etc").c_str ());
}

// ===========================================================================
// symbolic links
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the check whether a given file is a symbolic link
TEST (Path, is_symlink)
{
#if WINDOWS
    EXPECT_FALSE (is_symlink ("/proc/exe"));
#else
    const string tmpDir = get_working_directory () + "/basis-path-test-is_symlink";
    string cmd, link, value;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    link  = tmpDir; link += "/symlink";
    value = ".";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (is_symlink (link)) << "Link: " << link;
    link  = tmpDir; link += "/nolink";
    value = "";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_FALSE (is_symlink (link)) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0);
#endif
}

// ---------------------------------------------------------------------------
// Tests the reading of a symbolic link's value
TEST (Path, read_symlink)
{
    std::string value;
#if WINDOWS
    EXPECT_TRUE (read_symlink ("/proc/exe", value));
    EXPECT_TRUE (value == "/proc/exe");
    EXPECT_TRUE (read_symlink ("/does/not/exist", value));
    EXPECT_TRUE (value == "/does/not/exist");
#else
    const string tmpDir = get_working_directory () + "/basis-path-test-read_symlink";
    string cmd, link;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";

    link  = tmpDir; link += "/symlink";
    value = "hello world";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    value = "";
    EXPECT_TRUE (read_symlink (link, value)) << "Link: " << link;
    EXPECT_STREQ ("hello world", value.c_str ());
    link  = tmpDir; link += "/nolink";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_FALSE (read_symlink (link, value)) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (system (cmd.c_str ()) == 0);
#endif

    EXPECT_THROW (read_symlink ("",     value), invalid_argument);
    EXPECT_THROW (read_symlink ("C::/", value), invalid_argument);
}

// ---------------------------------------------------------------------------
// Tests the retrieval of an actual absolute path with symbolic links resolved
TEST (Path, get_real_path)
{
#if WINDOWS
#else
    const string wd     = get_working_directory ();
    const string tmpDir = wd + "/basis-path-test-get_real_path";
    string cmd, link, value;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";

    link  = tmpDir; link += "/symlink";
    value = "..";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_NO_THROW (value = get_real_path (link)) << "Link: " << link;
    EXPECT_STREQ (wd.c_str (), value.c_str ()) << "Link: " << link;
    link  = tmpDir; link += "/nolink";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (get_real_path (link) == link) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE (system (cmd.c_str ()) == 0) << cmd << " failed";
    EXPECT_TRUE (system (cmd.c_str ()) == 0);
#endif
}

// ===========================================================================
// executable file
// ===========================================================================

// ---------------------------------------------------------------------------
// Tests the retrieval of the current executable's path
TEST (Path, get_executable_path)
{
    string path;
    EXPECT_NO_THROW (path = get_executable_path ());
    cout << path << endl;
    EXPECT_STREQ ("test_path", get_file_name_without_extension (path).c_str ());
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the current executable's directory
TEST (Path, get_executable_directory)
{
    string path;
    EXPECT_NO_THROW (path = get_executable_directory ());
    cout << path << endl;
    EXPECT_TRUE (path == get_file_directory (get_executable_path ()));
}

// ---------------------------------------------------------------------------
// Tests the retrieval of the current executable's name
TEST (Path, get_executable_name)
{
    string name;
    EXPECT_NO_THROW (name = get_executable_name ());
    EXPECT_STREQ ("test_path", name.c_str ());
}

