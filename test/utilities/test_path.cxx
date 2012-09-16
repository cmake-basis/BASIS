/**
 * @file  test_path.cxx
 * @brief Test of path.cxx module.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <stdexcept>

#include <basis/config.h> // WINDOWS, UNIX macros
#include <basis/test.h>   // unit testing framework
#include <basis/os.h>     // testee

#if UNIX
#  include <stdlib.h> // the system() function is used to create symbolic links
#endif


using namespace basis;
using namespace std;


// ===========================================================================
// path representations
// ===========================================================================

// ---------------------------------------------------------------------------
TEST (Path, normpath)
{
    EXPECT_STREQ ("", os::path::normpath("").c_str());

    // test with (almost) already clean paths
    #if WINDOWS
        EXPECT_STREQ ("\\\\\\",          os::path::normpath("\\\\\\").c_str());
        EXPECT_STREQ ("\\usr",           os::path::normpath("/usr").c_str());
        EXPECT_STREQ ("\\usr",           os::path::normpath("/usr/").c_str());
        EXPECT_STREQ ("\\",              os::path::normpath("/").c_str());
        EXPECT_STREQ ("C:\\",            os::path::normpath("C:/").c_str());
        EXPECT_STREQ ("C:\\",            os::path::normpath("C:\\").c_str());
        EXPECT_STREQ ("..\\..",          os::path::normpath("../../").c_str());
        EXPECT_STREQ ("..\\..\\..",      os::path::normpath("../../../").c_str());
        EXPECT_STREQ ("..\\..\\..\\usr", os::path::normpath("../../../usr/local/../").c_str());
        EXPECT_STREQ (".",               os::path::normpath(".").c_str());
        EXPECT_STREQ (".",               os::path::normpath("./").c_str());
        EXPECT_STREQ ("..",              os::path::normpath("./..").c_str());
    #else
        EXPECT_STREQ ("/",               os::path::normpath("///").c_str());
        EXPECT_STREQ ("/usr",            os::path::normpath("/usr").c_str());
        EXPECT_STREQ ("/usr",            os::path::normpath("/usr/").c_str());
        EXPECT_STREQ ("/",               os::path::normpath("/").c_str());
        EXPECT_STREQ ("C:",              os::path::normpath("C:/").c_str());
        EXPECT_STREQ ("C:\\",            os::path::normpath("C:\\").c_str());
        EXPECT_STREQ ("../..",           os::path::normpath("../../").c_str());
        EXPECT_STREQ ("../../..",        os::path::normpath("../../../").c_str());
        EXPECT_STREQ ("../../../usr",    os::path::normpath("../../../usr/local/../").c_str());
        EXPECT_STREQ (".",               os::path::normpath(".").c_str());
        EXPECT_STREQ (".",               os::path::normpath("./").c_str());
        EXPECT_STREQ ("..",              os::path::normpath("./..").c_str());
    #endif

    // test some simple cases
    #if WINDOWS
        EXPECT_STREQ ("\\",             os::path::normpath("/").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("/..").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("/../..").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("/../../.").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("/.././../.").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("\\").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("\\..\\..").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("\\..\\..\\.").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("\\..\\.\\..\\.").c_str());
        EXPECT_STREQ ("\\usr\\local",   os::path::normpath("/usr/local/.").c_str());
        EXPECT_STREQ ("\\usr",          os::path::normpath("/usr/local/..").c_str());
    #else
        EXPECT_STREQ ("/",              os::path::normpath("/").c_str());
        EXPECT_STREQ ("/",              os::path::normpath("/..").c_str());
        EXPECT_STREQ ("/",              os::path::normpath("/../..").c_str());
        EXPECT_STREQ ("/",              os::path::normpath("/../../.").c_str());
        EXPECT_STREQ ("/",              os::path::normpath("/.././../.").c_str());
        EXPECT_STREQ ("\\",             os::path::normpath("\\").c_str());
        EXPECT_STREQ ("\\..\\..",       os::path::normpath("\\..\\..").c_str());
        EXPECT_STREQ ("\\..\\..\\.",    os::path::normpath("\\..\\..\\.").c_str());
        EXPECT_STREQ ("\\..\\.\\..\\.", os::path::normpath("\\..\\.\\..\\.").c_str());
        EXPECT_STREQ ("/usr/local",     os::path::normpath("/usr/local/.").c_str());
        EXPECT_STREQ ("/usr",           os::path::normpath("/usr/local/..").c_str());
    #endif

    // test some more complicated cases
    #if WINDOWS
        EXPECT_STREQ ("\\usr",             os::path::normpath("/usr/local/.///./\\/\\/\\///\\\\\\///..\\\\.\\./").c_str());
        EXPECT_STREQ ("..\\..\\path\\sub", os::path::normpath("..\\//../path\\/\\///./.\\sub").c_str());
    #else
        EXPECT_STREQ ("/usr/local/\\/\\/\\/\\\\\\/..\\\\.\\.", os::path::normpath("/usr/local/.///./\\/\\/\\///\\\\\\///..\\\\.\\./").c_str());
        EXPECT_STREQ ("path\\/\\/.\\sub", os::path::normpath("..\\//../path\\/\\///./.\\sub").c_str());
    #endif
}

// ---------------------------------------------------------------------------
TEST (Path, posixpath)
{
    EXPECT_STREQ ("",           os::path::posixpath("").c_str());
    EXPECT_STREQ ("/etc",       os::path::posixpath("\\usr/..\\etc").c_str());
    EXPECT_STREQ ("/etc",       os::path::posixpath("\\usr/..\\etc\\").c_str());
    EXPECT_STREQ ("/usr/local", os::path::posixpath("/usr/././//\\\\/./\\.\\local/bin\\..").c_str());
    EXPECT_STREQ ("C:/WINDOWS", os::path::posixpath("C:\\WINDOWS").c_str());
}

// ---------------------------------------------------------------------------
TEST (Path, ntpath)
{
    EXPECT_STREQ ("",             os::path::ntpath("").c_str());
    EXPECT_STREQ ("\\etc",        os::path::ntpath("\\usr/..\\etc").c_str());
    EXPECT_STREQ ("\\etc",        os::path::ntpath("\\usr/..\\etc\\").c_str());
    EXPECT_STREQ ("\\usr\\local", os::path::ntpath("/usr/././//\\\\/./\\.\\local/bin\\..").c_str());
    EXPECT_STREQ ("C:\\WINDOWS",  os::path::ntpath("C:\\WINDOWS").c_str());
}

// ===========================================================================
// path components
// ===========================================================================

// ---------------------------------------------------------------------------
TEST (Path, split)
{
    vector<string> parts;

    parts = os::path::split("");
    EXPECT_STREQ("", parts[0].c_str());
    EXPECT_STREQ("", parts[1].c_str());

    EXPECT_STREQ("/usr/local/share", os::path::split("/usr/local/share/readme.txt")[0].c_str());
    EXPECT_STREQ("readme.txt",       os::path::split("/usr/local/share/readme.txt")[1].c_str());
}

// ---------------------------------------------------------------------------
TEST (Path, splitdrive)
{
    string drive, tail;

    os::path::splitdrive("", drive, tail);
    EXPECT_STREQ("", drive.c_str());
    EXPECT_STREQ("", tail .c_str());

    os::path::splitdrive("/", drive, tail);
    EXPECT_STREQ("",  drive.c_str());
    EXPECT_STREQ("/", tail .c_str());

    os::path::splitdrive("c:", drive, tail);
    #if WINDOWS
        EXPECT_STREQ("c:", drive.c_str());
        EXPECT_STREQ("",   tail .c_str());
    #else
        EXPECT_STREQ("",   drive.c_str());
        EXPECT_STREQ("c:", tail .c_str());
    #endif

    os::path::splitdrive("C:/", drive, tail);
    #if WINDOWS
        EXPECT_STREQ("C:", drive.c_str());
        EXPECT_STREQ("/",  tail .c_str());
    #else
        EXPECT_STREQ("",    drive.c_str());
        EXPECT_STREQ("C:/", tail .c_str());
    #endif

    os::path::splitdrive("-:bar", drive, tail);
    #if WINDOWS
        EXPECT_STREQ("-:",  drive.c_str());
        EXPECT_STREQ("bar", tail .c_str());
    #else
        EXPECT_STREQ("",      drive.c_str());
        EXPECT_STREQ("-:bar", tail .c_str());
    #endif
}

// ---------------------------------------------------------------------------
TEST (Path, splitext)
{
    string head, ext;

    os::path::splitext("", head, ext);
    EXPECT_STREQ("", head.c_str());
    EXPECT_STREQ("", ext.c_str());

    EXPECT_STREQ(".doc",      os::path::splitext("/Users/andreas/word.doc")[1].c_str());
    EXPECT_STREQ("",          os::path::splitext("doc/README")[1].c_str());
    EXPECT_STREQ("Copyright", os::path::splitext("Copyright")[0].c_str());
    EXPECT_STREQ(".txt",      os::path::splitext("Copyright.txt")[1].c_str());

    set<string> exts;
    exts.insert(".nii");
    exts.insert(".hdr");

    os::path::splitext("/home/andreas/brain.nii.gz", head, ext, &exts);
    EXPECT_STREQ("/home/andreas/brain.nii.gz", head.c_str());
    EXPECT_STREQ("", ext.c_str());

    exts.insert(".gz");

    os::path::splitext("/home/andreas/brain.nii.gz", head, ext, &exts);
    EXPECT_STREQ("/home/andreas/brain.nii", head.c_str());
    EXPECT_STREQ(".gz", ext.c_str());

    exts.insert(".nii.GZ");

    os::path::splitext("/home/andreas/brain.nii.gz", head, ext, &exts);
    EXPECT_STREQ("/home/andreas/brain.nii", head.c_str());
    EXPECT_STREQ(".gz", ext.c_str());

    os::path::splitext("/home/andreas/brain.nii.gz", head, ext, &exts, true);
    EXPECT_STREQ("/home/andreas/brain", head.c_str());
    EXPECT_STREQ(".nii.gz", ext.c_str());

    #if WINDOWS
        EXPECT_STREQ("/this/file/is/",        os::path::splitext("/this/file/is/.hidden")[0].c_str());
        EXPECT_STREQ(".hidden",               os::path::splitext("/this/file/is/.hidden")[1].c_str());
    #else
        EXPECT_STREQ("/this/file/is/.hidden", os::path::splitext("/this/file/is/.hidden")[0].c_str());
        EXPECT_STREQ("",                      os::path::splitext("/this/file/is/.hidden")[1].c_str());
    #endif
}

// ---------------------------------------------------------------------------
TEST (Path, dirname)
{
    EXPECT_STREQ("", os::path::dirname("").c_str());
	EXPECT_STREQ("/etc", os::path::dirname("/etc/config").c_str());
	EXPECT_STREQ("/etc", os::path::dirname("/etc/").c_str());
	EXPECT_STREQ("/",    os::path::dirname("/etc").c_str());
    EXPECT_STREQ(".",    os::path::dirname("./CMakeLists.txt").c_str());
    EXPECT_STREQ("..",   os::path::dirname("../CMakeLists.txt").c_str());
}

// ---------------------------------------------------------------------------
TEST (Path, basename)
{
    EXPECT_STREQ("", os::path::basename("").c_str());
    EXPECT_STREQ("word.doc",      os::path::basename("/Users/andreas/word.doc").c_str());
    EXPECT_STREQ("README",        os::path::basename("doc/README").c_str());
    EXPECT_STREQ("Copyright.txt", os::path::basename("Copyright.txt").c_str());
    #if WINDOWS
        EXPECT_STREQ("word.doc", os::path::basename("C:\\word.doc").c_str());
    #else
        EXPECT_STREQ("C:\\word.doc", os::path::basename("C:\\word.doc").c_str());
    #endif
}

// ===========================================================================
// absolute / relative paths
// ===========================================================================

// ---------------------------------------------------------------------------
TEST (Path, isabs)
{
    // test with Unix-style relative paths
    EXPECT_FALSE(os::path::isabs("readme.txt"));
    EXPECT_FALSE(os::path::isabs("./readme.txt"));
    EXPECT_FALSE(os::path::isabs("../readme.txt"));
    EXPECT_FALSE(os::path::isabs("dir/readme.txt"));
    EXPECT_FALSE(os::path::isabs("./dir/readme.txt"));
    EXPECT_FALSE(os::path::isabs("../dir/readme.txt"));

    // test with Unix-style absolute path
    EXPECT_TRUE(os::path::isabs("/usr"));
    EXPECT_TRUE(os::path::isabs("/usr/local"));
    EXPECT_TRUE(os::path::isabs("/."));
    EXPECT_TRUE(os::path::isabs("/.."));

    // test with Windows-style relative path
    EXPECT_FALSE(os::path::isabs(".\\readme.txt"));
    EXPECT_FALSE(os::path::isabs("..\\readme.txt"));
    EXPECT_FALSE(os::path::isabs("dir\\readme.txt"));
    EXPECT_FALSE(os::path::isabs(".\\dir\\readme.txt"));
    EXPECT_FALSE(os::path::isabs("..\\dir\\readme.txt"));

    // test with Windows-style absolute path
    #if WINDOWS
        EXPECT_TRUE(os::path::isabs("\\WINDOWS"));
        EXPECT_TRUE(os::path::isabs("c:\\WINDOWS"));
        EXPECT_TRUE(os::path::isabs("C:\\WINDOWS"));
        EXPECT_TRUE(os::path::isabs("C:\\"));
        EXPECT_TRUE(os::path::isabs("C:\\."));
    #else
        EXPECT_FALSE(os::path::isabs("\\WINDOWS"));
        EXPECT_FALSE(os::path::isabs("c:\\WINDOWS"));
        EXPECT_FALSE(os::path::isabs("C:\\WINDOWS"));
        EXPECT_FALSE(os::path::isabs("C:\\"));
        EXPECT_FALSE(os::path::isabs("C:\\."));
    #endif
}

// ---------------------------------------------------------------------------
TEST (Path, abspath)
{
    string wd = os::getcwd();
    EXPECT_STREQ(wd.c_str(), os::path::abspath("").c_str());
    EXPECT_STREQ(os::path::abspath("tmp").c_str(), os::path::join(wd, "tmp").c_str());
}

// ---------------------------------------------------------------------------
TEST (Path, relpath)
{
    EXPECT_STREQ(".",             os::path::relpath("/usr", "/usr").c_str());
    EXPECT_STREQ("..",            os::path::relpath("/usr", "/usr/local").c_str());
    EXPECT_STREQ("..",            os::path::relpath("/usr", "/usr/local/").c_str());
    EXPECT_STREQ("..",            os::path::relpath("/usr/", "/usr/local").c_str());
	#if WINDOWS
	    EXPECT_STREQ("..\\config.txt", os::path::relpath("/usr/config.txt", "/usr/local").c_str());
        EXPECT_STREQ("Testing\\bin",   os::path::relpath("/usr/local/src/build/Testing/bin", "/usr/local/src/build").c_str());
	#else
        EXPECT_STREQ("../config.txt", os::path::relpath("/usr/config.txt", "/usr/local").c_str());
        EXPECT_STREQ("Testing/bin",   os::path::relpath("/usr/local/src/build/Testing/bin", "/usr/local/src/build").c_str());
	#endif
}

// ---------------------------------------------------------------------------
TEST (Path, join)
{
    #if WINDOWS
        EXPECT_STREQ(".\\usr",          os::path::join(".", "usr").c_str());
        EXPECT_STREQ("/etc",           os::path::join("/usr/local", "/etc").c_str());
        EXPECT_STREQ("\\etc",           os::path::join("/usr/local", "\\etc").c_str());
        EXPECT_STREQ("/usr/local\\etc", os::path::join("/usr/local", "etc").c_str());
    #else
        EXPECT_STREQ("./usr",            os::path::join(".", "usr").c_str());
        EXPECT_STREQ("/etc",             os::path::join("/usr/local", "/etc").c_str());
        EXPECT_STREQ("/usr/local/\\etc", os::path::join("/usr/local", "\\etc").c_str());
        EXPECT_STREQ("/usr/local/etc",   os::path::join("/usr/local", "etc").c_str());
    #endif
}

// ===========================================================================
// symbolic links
// ===========================================================================

// ---------------------------------------------------------------------------
TEST (Path, islink)
{
#if WINDOWS
    EXPECT_FALSE (os::path::islink ("/proc/exe"));
#else
    const string tmpDir = os::getcwd() + "/basis-path-test-os::path::islink";
    string cmd, link, value;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE(system (cmd.c_str()) == 0) << cmd << " failed";
    link  = tmpDir; link += "/symlink";
    value = ".";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE(system (cmd.c_str()) == 0) << cmd << " failed";
    EXPECT_TRUE(os::path::islink (link)) << "Link: " << link;
    link  = tmpDir; link += "/nolink";
    value = "";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE(system (cmd.c_str()) == 0) << cmd << " failed";
    EXPECT_FALSE(os::path::islink (link)) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    EXPECT_TRUE(system (cmd.c_str()) == 0);
#endif
}

// ---------------------------------------------------------------------------
TEST (Path, realpath)
{
#if WINDOWS
#else
    const string wd     = os::getcwd();
    const string tmpDir = wd + "/basis-path-test-get_real_path";
    string cmd, link, value;
 
    cmd = "mkdir -p \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE(system(cmd.c_str()) == 0) << cmd << " failed";
    ASSERT_TRUE(system(cmd.c_str()) == 0) << cmd << " failed";

    link  = tmpDir; link += "/symlink";
    value = "..";
    cmd   = "ln -sn \""; cmd += value; cmd += "\" \""; cmd += link; cmd += "\"";
    EXPECT_TRUE(system(cmd.c_str()) == 0) << cmd << " failed";
    EXPECT_NO_THROW(value = os::path::realpath(link)) << "Link: " << link;
    EXPECT_STREQ(wd.c_str(), value.c_str()) << "Link: " << link;
    link  = tmpDir; link += "/nolink";
    cmd   = "touch \""; cmd += link; cmd += "\"";
    EXPECT_TRUE(system(cmd.c_str()) == 0) << cmd << " failed";
    EXPECT_TRUE(os::path::realpath(link) == link) << "Link: " << link;

    cmd = "rm -rf \""; cmd += tmpDir; cmd += "\"";
    ASSERT_TRUE(system(cmd.c_str()) == 0) << cmd << " failed";
    EXPECT_TRUE(system(cmd.c_str()) == 0);
#endif
}
