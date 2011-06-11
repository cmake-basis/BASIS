/*!
 * \file  path.cc
 * \brief Basic file path manipulation and related system functions.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include "path.h"

#if WINDOWS
#  include <direct.h>        // _getcwd
#  include <stdlib.h>        // _splitpath_s
#  include <windows.h>       // GetModuleFileName
#else
#  include <unistd.h>        // getcwd
#  include <sys/stat.h>      // lstat
#endif
#if MACOS
#  include <mach-o/dyld.h>   // _NSGetExecutablePath
#endif


SBIA_BASIS_NAMESPACE_BEGIN


//////////////////////////////////////////////////////////////////////////////
// constants
//////////////////////////////////////////////////////////////////////////////

#if WINDOWS
const char        pathSeparator = '\\';
const std::string pathSeparatorStr ("\\");
#else
const char        pathSeparator = '/';
const std::string pathSeparatorStr ("/");
#endif

//////////////////////////////////////////////////////////////////////////////
// path representations
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
std::string cleanPath (const std::string &path)
{
    std::string cleanedPath;

    std::string::const_iterator prev;
    std::string::const_iterator curr;
    std::string::const_iterator next;

    // remove periods enclosed by slashes (or backslashes)
    prev = path.begin ();
    curr = ++ prev;
    next = ++ curr;

    cleanedPath.reserve (path.size ());
    cleanedPath.push_back (*prev);
    while (curr != path.end ()) {
        if (*curr == '.' && (*prev == '/' || *prev == '\\')) {
            if (next != path.end () && *next != '/' && *next != '\\') {
                cleanedPath.push_back (*curr);
            }
        } else {
            cleanedPath.push_back (*curr);
        }

        ++ prev;
        ++ curr;
        ++ next;
    }

    // remove duplicate slashes (and backslashes)
    std::string tmp;
    cleanedPath.swap (tmp);

    prev = tmp.begin ();
    curr = ++ prev;

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
    std::string ref = "/..";
    size_t      pos = 0;

    for (;;) {
        pos = cleanedPath.find (ref, pos);
        if (pos == std::string::npos) {
            if (ref == "\\..") break;
            ref = "\\..";
            pos = cleanedPath.find (ref, pos);
            if (pos == std::string::npos) break;
        }
        if (pos + 3 >= cleanedPath.size ()
                || cleanedPath [pos + 3] == '/'
                || cleanedPath [pos + 3] == '\\') {
            if (pos == 0) {
                if (cleanedPath.size () == 3) cleanedPath.erase (1, 2);
                else                          cleanedPath.erase (0, 3);
                pos = 0;
            } else {
                size_t start = cleanedPath.find_last_of ("/\\", pos - 1);
                if (start != std::string::npos) {
                    cleanedPath.erase (start + 1, pos + 3 - start);
                    pos = start + 1;
                } else {
                    cleanedPath.erase (0, pos + 3);
                    pos = 0;
                }
            }
        }
    }

    return cleanedPath;
}

/****************************************************************************/
std::string toUnixPath (const std::string &path, bool drive)
{
    std::string unixPath;
    unixPath.reserve (path.size ());

    std::string::const_iterator in  = path.begin ();

    // skip drive specification
    if (!drive && path.size () > 1 && path [1] == ':') in += 2;

    // copy path while replacing backslashes by slashes
    while (in != path.end ()) {
        if (*in == '\\') unixPath.push_back ('/');
        else             unixPath.push_back (*in);
        ++ in;
    }

    return cleanPath (unixPath);
}

/****************************************************************************/
std::string toWindowsPath (const std::string &path)
{
    std::string windowsPath (path.size (), '\0');

    // copy path while replacing slashes by backslashes
    std::string::const_iterator in  = path.begin ();
    std::string::iterator       out = windowsPath.begin ();

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

    return cleanPath (windowsPath);
}

/****************************************************************************/
std::string toNativePath (const std::string &path)
{
#if WINDOWS
    return toWindowsPath (path);
#else
    return toUnixPath (path);
#endif
}

//////////////////////////////////////////////////////////////////////////////
// working directory
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
std::string getWorkingDirectory ()
{
    std::string wd;
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
void splitPath (const std::string &path,
                std::string       *root,
                std::string       *dir,
                std::string       *fname,
                std::string       *ext)
{
    // file root
    if (root) *root = getFileRoot (path);
    // convert path to clean Unix-style path
    std::string unixPath = toUnixPath (path);
    // get position of last slash
    size_t last = unixPath.find_last_of ('/');
    // file directory without root
    if (dir) {
        if (last == std::string::npos) {
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
        std::string name;

        if (last == std::string::npos) {
            name = unixPath;
        } else {
            name = unixPath.substr (last + 1);
        }

        size_t pos = unixPath.find_last_of ('.');

        if (pos == std::string::npos) {
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
std::string getFileRoot (const std::string &path)
{
    if (path.empty ()) return "";
    // absolute Unix-style input path
    if (path [0] == '/' || path [0] == '\\') {
#if WINDOWS
        return "C:/";
#else
        return "/";
#endif
    }
    // absolute Windows-style input path
#if WINDOWS
    if (path.size () > 1 && path [1] == ':') {
        char letter = path [0];
        if ('a' <= letter && letter <= 'z') {
            letter = 'A' + (letter - 'a');
        }
        return std::string (letter) + ":/";
    }
#endif
    // otherwise, it's a relative path
    return "./";
}

/****************************************************************************/
std::string getFileDirectory (const std::string &path)
{
    std::string root;
    std::string dir;
    splitPath (path, &root, &dir, NULL, NULL);
    return root + dir.substr (0, dir.size () - 1);
}

/****************************************************************************/
std::string getFileName (const std::string &path)
{
    std::string fname;
    std::string ext;
    splitPath (path, NULL, NULL, &fname, &ext);
    return fname + ext;
}

/****************************************************************************/
std::string getFileNameWithoutExtension (const std::string &path)
{
    std::string fname;
    splitPath (path, NULL, NULL, &fname, NULL);
    return fname;
}

/****************************************************************************/
std::string getFileNameExtension (const std::string &path)
{
    std::string ext;
    splitPath (path, NULL, NULL, NULL, &ext);
    return ext;
}

//////////////////////////////////////////////////////////////////////////////
// absolute / relative paths
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
bool isAbsolutePath (const std::string &path)
{
    return getFileRoot (path) != "./";
}

/****************************************************************************/
bool isRelativePath (const std::string &path)
{
    return getFileRoot (path) == "./";
}

/****************************************************************************/
std::string toAbsolutePath (const std::string &path)
{
    return toAbsolutePath (getWorkingDirectory (), path);
}

/****************************************************************************/
std::string toAbsolutePath (const std::string &base, const std::string &path)
{
    std::string absPath (path);
    // make relative path absolute
    if (isRelativePath (absPath)) {
        std::string absBase (base);
        if (isRelativePath (absBase)) {
            absBase.insert (0, getWorkingDirectory () + '/');
        }
        absPath.insert (0, absBase + '/');
    }
    // clean path
    absPath = cleanPath (absPath);
    // on Windows, prepend drive letter followed by a colon (:)
#if WINDOWS
    if (absPath [0] == '/') absPath.insert (0, "C:");
#endif
    return absPath;
}

/****************************************************************************/
std::string toRelativePath (const std::string &path)
{
    std::string unixPath = toUnixPath (path, true);
    if (isRelativePath (unixPath)) return cleanPath (unixPath);
    return toRelativePath (getWorkingDirectory (), unixPath);
}

/****************************************************************************/
std::string toRelativePath (const std::string &base, const std::string &path)
{
    std::string unixPath = toUnixPath (path, true);
    // if relative path is given just return it cleaned
    if (isRelativePath (unixPath)) return cleanPath (path);
    // make base path absolute
    std::string absBase = toUnixPath (base, true);
    if (isRelativePath (absBase)) {
        absBase.insert (0, getWorkingDirectory () + '/');
    }
    // path must have same root as base path; this check is intended for
    // Windows, where there is no relative path from one drive to another
    if (getFileRoot (absBase) != getFileRoot (unixPath)) return "";
    // find start of first path component in which paths differ
    std::string::const_iterator b   = absBase .begin ();
    std::string::const_iterator p   = unixPath.begin ();
    size_t                      pos = 0;
    size_t                      i   = 0;
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
    std::string relPath;
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
bool isSymbolicLink (const std::string &path)
{
#if WINDOWS
    return false;
#else
    struct stat info;
    if (lstat (path.c_str (), &info) != 0) return false;
    return S_ISLNK (info.st_mode);
#endif
}

/****************************************************************************/
bool readSymbolicLink (const std::string &link, std::string &value)
{
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

        if (n < buflen) {
            if (n < 0) {
                ok = false;
            } else {
                buffer [buflen - 1] = '\0';
                value = buffer;
            }
            break;
        }
        buflen += 256;
    }

    free (buffer);
#endif
    return ok;
}

/****************************************************************************/
std::string getRealPath (const std::string &path)
{
    // make path just absolute if it is no symbolic link
    if (!isSymbolicLink (path)) {
        return toAbsolutePath (path);
    }
    std::string currPath (path);
    std::string nextPath;
    // for safety reasons, restrict the depth of symbolic links followed
    for (unsigned int i = 0; i < 100; ++ i) {
        if (readSymbolicLink (currPath, nextPath)) {
            nextPath = toAbsolutePath (getFileDirectory (currPath), nextPath);
            if (!isSymbolicLink (nextPath)) {
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
    return toAbsolutePath (path);
}

//////////////////////////////////////////////////////////////////////////////
// executable file
//////////////////////////////////////////////////////////////////////////////

/****************************************************************************/
std::string getExecutablePath ()
{
    std::string path;
#if LINUX
    path = getRealPath ("/proc/self/exe");
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
    int      retval = 0;
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
std::string getExecutableName ()
{
    std::string name = getExecutablePath ();
    if (name.empty ()) return "";

#if WINDOWS
    std::string ext = getFileNameExtension (name);
    if (ext == ".exe" || ext == ".com") {
        name = getFileNameWithoutExtension (name);
    } else {
        name = getFileName (name);
    }
#else
    name = getFileName (name);
#endif

    return name;
}


SBIA_BASIS_NAMESPACE_END

