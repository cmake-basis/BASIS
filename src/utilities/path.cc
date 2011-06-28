/*!
 * \file  path.cc
 * \brief Basic file path manipulation and related system functions.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include "path.h"            // declarations and BASIS configuration

#include <stdlib.h>          // malloc & free, _splitpath_s (WINDOWS)

#if WINDOWS
#  include <direct.h>        // _getcwd
#  include <windows.h>       // GetModuleFileName
#else
#  include <unistd.h>        // getcwd
#  include <sys/stat.h>      // lstat
#endif
#if MACOS
#  include <mach-o/dyld.h>   // _NSGetExecutablePath
#endif

#include "exceptions.h"      // to throw exceptions


using namespace std; // this a .cc file, hence it is ok to do so


SBIA_BASIS_NAMESPACE_BEGIN


//////////////////////////////////////////////////////////////////////////////
// constants
//////////////////////////////////////////////////////////////////////////////

#if WINDOWS
const char   cPathSeparator = '\\';
const string cPathSeparatorStr ("\\");
#else
const char   cPathSeparator = '/';
const string cPathSeparatorStr ("/");
#endif

//////////////////////////////////////////////////////////////////////////////
// path representations
//////////////////////////////////////////////////////////////////////////////

// ***************************************************************************
bool IsValidPath (const string &path, bool strict)
{
    // an empty string is clearly no valid path
    if (path.empty ()) return false;
    // we do not allow a path to start with a colon (:) (also not on Unix!)
    if (path [0] == ':') return false;
    // absolute Windows-style path with drive specification
    if (path.size () > 1 && path [1] == ':') {
        // first character must be a drive letter
        if ((path [0] < 'a' || 'z' < path [0]) &&
            (path [0] < 'A' || 'Z' < path [0])) return false;
        // absolute path must follow the drive specification
        if (path.size () == 2) return false;
        if (path [2] != '/' && path [2] != '\\') return false;
        if (strict) {
#if !WINDOWS
            // on Unix systems, a drive specification is invalid
            // however, to be consistent, the drive C: is just ignored and
            // interpreted as root on Unix
            if (path [0] != 'C' && path [0] != 'c') return false;
#endif
        }
    }
    // otherwise, the path is valid
    return true;
}

// ***************************************************************************
string CleanPath (const string &path)
{
    if (!IsValidPath (path, false)) {
        BASIS_THROW (invalid_argument, "Invalid path: ''");
    }

    string cleanedPath;

    string::const_iterator prev;
    string::const_iterator curr;
    string::const_iterator next;

    // remove periods enclosed by slashes (or backslashes)
    prev = path.begin ();
    if (prev == path.end ()) return "";

    curr = prev + 1;
    next = ((curr == path.end ()) ? curr : (curr + 1));

    cleanedPath.reserve (path.size ());
    cleanedPath.push_back (*prev);
    while (curr != path.end ()) {
        if (*curr == '.' && (*prev == '/' || *prev == '\\')) {
            if (next == path.end ()) {
                // remove the "/" that was added before b/c the
                // final "/." should be removed together
                cleanedPath.erase (cleanedPath.size () - 1);
            }
            else if (*next != '/' && *next != '\\') {
                cleanedPath.push_back (*curr);
            }
        } else {
            cleanedPath.push_back (*curr);
        }

        ++ prev;
        ++ curr;
        if (next != path.end ()) ++ next;
    }

    // remove duplicate slashes (and backslashes)
    string tmp;
    cleanedPath.swap (tmp);

    prev = tmp.begin ();
    curr = prev + 1;

    cleanedPath.reserve (tmp.size ());
    cleanedPath.push_back (*prev);
    while (curr != tmp.end ()) {
        if ((*curr != '/' && *curr != '\\') || (*prev != '/' && *prev != '\\')) {
            cleanedPath.push_back (*curr);
        }

        ++ prev;
        ++ curr;
    }

    // remove references to parent directories
    size_t skip = 0;

    // in case of relative paths like "../../*" we need to skip the first
    // parent directory references
    while (skip + 3 <= cleanedPath.size ()) {
        std::string sub = cleanedPath.substr (skip, 3);
        if (sub != "../" && sub != "..\\") break;
        skip += 3;
    }
    if (skip > 0) skip -= 1; // below, we look for "/.." instead of "../"

    string ref = "/.."; // will be set to "\.." on the "second" run
    size_t pos = skip;  // the starting position of the path "absolute" to
                        // to the root directory given by "../../" or "/",
                        // for example.
    for (;;) {
        pos = cleanedPath.find (ref, pos);
        if (pos == string::npos) {
            if (ref == "\\..") break;
            // no occurrences of "/.." found, now clean up the ones of "\.."
            ref = "\\..";
            pos = cleanedPath.find (ref, pos);
            if (pos == string::npos) break;
        }
        if (pos + 3 == cleanedPath.size ()
                || cleanedPath [pos + 3] == '/'
                || cleanedPath [pos + 3] == '\\') {
            if (pos == 0) {
                if (cleanedPath.size () == 3) cleanedPath.erase (1, 2);
                else                          cleanedPath.erase (0, 3);
                pos = skip;
            } else {
                size_t start = cleanedPath.find_last_of ("/\\", pos - 1);
                if (start != string::npos) {
                    cleanedPath.erase (start, pos - start + 3);
                    pos = start + 1;
                } else if (cleanedPath [0] == '/' || cleanedPath [0] == '\\') {
                    cleanedPath.erase (skip, pos + 3);
                    pos = skip;
                } else {
                    pos += 3;
                }
            }
        } else {
            pos += 3;
        }
    }

    return cleanedPath;
}

/****************************************************************************/
string ToUnixPath (const string &path, bool drive)
{
    if (!IsValidPath (path)) {
        BASIS_THROW (invalid_argument, "Invalid path: '" << path << "'");
    }

    string unixPath;
    unixPath.reserve (path.size ());

    string::const_iterator in = path.begin ();

    // skip drive specification
    if (!drive && path.size () > 1 && path [1] == ':') in += 2;

    // copy path while replacing backslashes by slashes
    while (in != path.end ()) {
        if (*in == '\\') unixPath.push_back ('/');
        else             unixPath.push_back (*in);
        ++ in;
    }

    return CleanPath (unixPath);
}

/****************************************************************************/
string ToWindowsPath (const string &path)
{
    if (!IsValidPath (path, false)) {
        BASIS_THROW (invalid_argument, "Invalid path: '" << path << "'");
    }

    string windowsPath (path.size (), '\0');

    // copy path while replacing slashes by backslashes
    string::const_iterator in  = path.begin ();
    string::iterator       out = windowsPath.begin ();

    while (in != path.end ()) {
        if (*in == '/') *out = '\\';
        else            *out = *in;
        ++ in;
        ++ out;
    }

    // prepend drive specification to absolute paths
    if (windowsPath [0] == '\\') {
        windowsPath.reserve (windowsPath.size () + 2);
        windowsPath.insert  (0, "C:");
    }

    return CleanPath (windowsPath);
}

/****************************************************************************/
string ToNativePath (const string &path)
{
#if WINDOWS
    return ToWindowsPath (path);
#else
    return ToUnixPath (path);
#endif
}

//////////////////////////////////////////////////////////////////////////////
// working directory
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
string GetWorkingDirectory ()
{
    string wd;
#if WINDOWS
    char *buffer = _getcwd (NULL, 0);
#else
    char *buffer = getcwd (NULL, 0);
#endif
    if (buffer) {
        wd = buffer;
        free (buffer);
    }
    return wd;
}

//////////////////////////////////////////////////////////////////////////////
// path components
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
void SplitPath (const string &path,
                string       *root,
                string       *dir,
                string       *fname,
                string       *ext)
{
    // \note No need to validate path here as this will be done
    //       either by GetFileRoot() or ToUnixPath().

    // file root
    if (root) *root = GetFileRoot (path);
    // convert path to clean Unix-style path
    string unixPath = ToUnixPath (path);
    // get position of last slash
    size_t last = unixPath.find_last_of ('/');
    // file directory without root
    if (dir) {
        if (last == string::npos) {
            *dir = "";
        } else {
            size_t start = 0;

            if (unixPath [0] == '/') {
                start = 1;
            } else if (unixPath.size () > 1 &&
                       unixPath [0] == '.'  &&
                       unixPath [1] == '/') {
                start = 2;
            }

            *dir = unixPath.substr (start, last - start + 1);
        }
    }
    // file name and extension
    if (fname || ext) {
        string name;

        if (last == string::npos) {
            name = unixPath;
        } else {
            name = unixPath.substr (last + 1);
        }

        size_t pos = name.find_last_of ('.');

        if (pos == string::npos) {
            if (fname) {
                *fname = name;
            }
            if (ext) {
                *ext = "";
            }
        } else {
            if (fname) {
                *fname = name.substr (0, pos);
            }
            if (ext) {
                *ext = name.substr (pos);
            }
        }
    }
}

/****************************************************************************/
string GetFileRoot (const string &path)
{
    if (!IsValidPath (path, false)) {
        BASIS_THROW (invalid_argument, "Invalid path: '" << path << "'");
    }

    // absolute Unix-style input path
    if (path [0] == '/' || path [0] == '\\') {
#if WINDOWS
        return "C:/";
#else
        return "/";
#endif
    }
    // absolute Windows-style input path
    if (path.size () > 1 && path [1] == ':') {
        char letter = path [0];
        if ('a' <= letter && letter <= 'z') {
            letter = 'A' + (letter - 'a');
        }
#if WINDOWS
        return string (letter) + ":/";
#else
        return "/";
#endif
    }
    // otherwise, it's a relative path
    return "./";
}

/****************************************************************************/
string GetFileDirectory (const string &path)
{
    string root;
    string dir;
    SplitPath (path, &root, &dir, NULL, NULL);
    return root + dir.substr (0, dir.size () - 1);
}

/****************************************************************************/
string GetFileName (const string &path)
{
    string fname;
    string ext;
    SplitPath (path, NULL, NULL, &fname, &ext);
    return fname + ext;
}

/****************************************************************************/
string GetFileNameWithoutExtension (const string &path)
{
    string fname;
    SplitPath (path, NULL, NULL, &fname, NULL);
    return fname;
}

/****************************************************************************/
string GetFileNameExtension (const string &path)
{
    string ext;
    SplitPath (path, NULL, NULL, NULL, &ext);
    return ext;
}

//////////////////////////////////////////////////////////////////////////////
// absolute / relative paths
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
bool IsAbsolutePath (const string &path)
{
    return GetFileRoot (path) != "./";
}

/****************************************************************************/
bool IsRelativePath (const string &path)
{
    return GetFileRoot (path) == "./";
}

/****************************************************************************/
string ToAbsolutePath (const string &path)
{
    return ToAbsolutePath (GetWorkingDirectory (), path);
}

/****************************************************************************/
string ToAbsolutePath (const string &base, const string &path)
{
    string absPath (path);
    // make relative path absolute
    if (IsRelativePath (absPath)) {
        string absBase (base);
        if (IsRelativePath (absBase)) {
            absBase.insert (0, GetWorkingDirectory () + '/');
        }
        absPath.insert (0, absBase + '/');
    }
    // clean path
    absPath = CleanPath (absPath);
    // on Windows, prepend drive letter followed by a colon (:)
#if WINDOWS
    if (absPath [0] == '/') absPath.insert (0, "C:");
#endif
    return absPath;
}

/****************************************************************************/
string ToRelativePath (const string &path)
{
    string unixPath = ToUnixPath (path, true);
    if (IsRelativePath (unixPath)) return CleanPath (unixPath);
    return ToRelativePath (GetWorkingDirectory (), unixPath);
}

/****************************************************************************/
string ToRelativePath (const string &base, const string &path)
{
    string unixPath = ToUnixPath (path, true);
    // if relative path is given just return it cleaned
    if (IsRelativePath (unixPath)) return CleanPath (path);
    // make base path absolute
    string absBase = ToUnixPath (base, true);
    if (IsRelativePath (absBase)) {
        absBase.insert (0, GetWorkingDirectory () + '/');
    }
    // path must have same root as base path; this check is intended for
    // Windows, where there is no relative path from one drive to another
    if (GetFileRoot (absBase) != GetFileRoot (unixPath)) return "";
    // find start of first path component in which paths differ
    string::const_iterator b   = absBase .begin ();
    string::const_iterator p   = unixPath.begin ();
    size_t                 pos = 0;
    size_t                 i   = 0;
    while (b != absBase.end () && p != unixPath.end () && *b == *p) {
        if (*p == '/') pos = i;
        ++ b; ++ p; ++ i;
    }
    // skip trailing slash of other path if end of one path reached
    if (b == absBase .end () && p != unixPath.end () && *p == '/') ++ p;
    if (p == unixPath.end () && b != absBase .end () && *b == '/') ++ b;
    // if paths are the same, just return a period (.)
    //
    // Thanks to the previous skipping of trailing slashes, this condition
    // handles all of the following cases:
    //
    //    base := "/usr/bin"  path := "/usr/bin"
    //    base := "/usr/bin/" path := "/usr/bin/"
    //    base := "/usr/bin"  path := "/usr/bin/"
    //    base := "/usr/bin/" path := "/usr/bin"
    //
    // Note: The paths have been cleaned before by the toUnixPath function.
    if (b == absBase.end () && p == unixPath.end ()) return ".";
    // otherwise, pos is the index of the last slash for which both paths
    // were identical; hence, everything that comes after in the original
    // path is preserved and for each following component in the base path
    // a "../" is prepended to the relative path
    string relPath;
    if (absBase [absBase.size () - 1] != '/') absBase += '/';
    while (b != absBase.end ()) {
        if (*b == '/') relPath += "../";
    }
    relPath += unixPath.substr (pos + 1);
    return relPath;
}

//////////////////////////////////////////////////////////////////////////////
// symbolic links
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
bool IsSymbolicLink (const string &path)
{
    if (!IsValidPath (path)) {
        BASIS_THROW (invalid_argument, "Invalid path: '" << path << "'");
    }

#if WINDOWS
    return false;
#else
    struct stat info;
    if (lstat (path.c_str (), &info) != 0) return false;
    return S_ISLNK (info.st_mode);
#endif
}

/****************************************************************************/
bool ReadSymbolicLink (const string &link, string &value)
{
    if (!IsValidPath (link)) {
        BASIS_THROW (invalid_argument, "Invalid path: '" << link << "'");
    }

    bool ok = true;
#if !WINDOWS
    char   *buffer = NULL;
    char   *newbuf = NULL;
    size_t  buflen = 256;

    for (;;) {
        newbuf = (char *)realloc (buffer, buflen * sizeof (char));
        if (!newbuf) {
            ok = false;
            break;
        }
        buffer = newbuf;

        int n = readlink (link.c_str (), buffer, buflen);

        if (n < 0) {
            ok = false;
            break;
        } else if (static_cast<size_t> (n) < buflen) {
            buffer [buflen - 1] = '\0';
            value = buffer;
            break;
        }
        buflen += 256;
    }

    free (buffer);
#endif
    return ok;
}

/****************************************************************************/
string GetRealPath (const string &path)
{
    // make path just absolute if it is no symbolic link
    if (!IsSymbolicLink (path)) {
        return ToAbsolutePath (path);
    }
    string currPath (path);
    string nextPath;
    // for safety reasons, restrict the depth of symbolic links followed
    for (unsigned int i = 0; i < 100; ++ i) {
        if (ReadSymbolicLink (currPath, nextPath)) {
            nextPath = ToAbsolutePath (GetFileDirectory (currPath), nextPath);
            if (!IsSymbolicLink (nextPath)) {
                return nextPath;
            }
            currPath = nextPath;
        } else {
            // if real path could not be determined because of permissions
            // or invalid path, return the original path
            break;
        }
    }
    // if real path could not be determined with the given maximum number of
    // loop iterations (endless cycle?) or one of the symbolic links could
    // not be read, just return original path as clean absolute path
    return ToAbsolutePath (path);
}

//////////////////////////////////////////////////////////////////////////////
// executable file
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
string GetExecutablePath ()
{
    string path;
#if LINUX
    path = GetRealPath ("/proc/self/exe");
#elif WINDOWS
    LPTSTR buffer = NULL;
    LPTSTR newbuf = NULL;
    DWORD  buflen = 256;
    DWORD  retval = 0;

    for (;;) {
        newbuf = (LPTSTR)realloc (buffer, buflen * sizeof (TCHAR));
        if (!newbuf) break;
		buffer = newbuf;
        retval = GetModuleFileName (NULL, buffer, buflen);
        if (retval == 0 || retval < buflen) break;
        buflen += 256;
        retval = 0;
    }

    if (retval > 0) {
#  ifdef UNICODE
        int n = WideCharToMultiByte (CP_UTF8, 0, buffer, -1, NULL, 0, NULL, NULL);
        char *mbpath = (char *)malloc (n);
        if (mbpath) {
            WideCharToMultiByte (CP_UTF8, 0, buffer, -1, mbpath, n, NULL, NULL);
            path = mbpath;
            free (mbpath);
        }
#  else
        path = buffer;
#  endif
    }

    free (buffer);
#elif MACOS
    char    *buffer = NULL;
    char    *newbuf = NULL;
    uint32_t buflen = 256;

    buffer = reinterpret_cast <char *> (malloc (buflen * sizeof (char)));
    if (buffer) {
        if (_NSGetExecutablePath (buffer, &buflen) == 0) {
            path = buffer;
        } else {
            newbuf = reinterpret_cast <char *> (realloc (buffer, buflen * sizeof (char)));
            if (newbuf)	{
			    buffer = newbuf;
                if (_NSGetExecutablePath (buffer, &buflen) == 0) {
                    path = buffer;
                }
            }
        }
    }

    free (buffer);
#else
    // functionality not supported on this (unknown) platform
#endif
    return path;
}

/****************************************************************************/
string GetExecutableName ()
{
    string name = GetExecutablePath ();
    if (name.empty ()) return "";

#if WINDOWS
    string ext = GetFileNameExtension (name);
    if (ext == ".exe" || ext == ".com") {
        name = GetFileNameWithoutExtension (name);
    } else {
        name = GetFileName (name);
    }
#else
    name = GetFileName (name);
#endif

    return name;
}


SBIA_BASIS_NAMESPACE_END

