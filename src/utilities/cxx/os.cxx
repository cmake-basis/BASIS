/**
 * @file  os.cxx
 * @brief Operating system dependent functions.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <basis/config.h> // platform macros - must be first
#include <basis/except.h> // to throw exceptions

#include <vector>
#include <stdlib.h>            // malloc(), free()
#include <string.h>            // strncmp()

#if WINDOWS
#  include <direct.h>          // _getcwd()
#  include <windows.h>         // GetModuleFileName()
#else
#  include <unistd.h>          // getcwd(), rmdir()
#  include <dirent.h>          // opendir()
#  include <sys/stat.h>        // mkdir()
#endif
#if MACOS
#  include <mach-o/dyld.h>     // _NSGetExecutablePath()
#endif

#include <basis/os.h>
#include <basis/os/path.h>


// acceptable in .cxx file
using namespace std;


namespace basis { namespace os {


// ---------------------------------------------------------------------------
string getcwd()
{
    string wd;
#if WINDOWS
    char* buffer = _getcwd(NULL, 0);
#else
    char* buffer = ::getcwd(NULL, 0);
#endif
    if (buffer) {
        wd = buffer;
        free(buffer);
    }
    return wd;
}

// ---------------------------------------------------------------------------
string exepath()
{
    string path;
#if LINUX
    path = path::realpath("/proc/self/exe");
#elif WINDOWS
    LPTSTR buffer = NULL;
    LPTSTR newbuf = NULL;
    DWORD buflen = 256;
    DWORD retval = 0;

    for (;;) {
        newbuf = static_cast<LPTSTR>(realloc(buffer, buflen * sizeof(TCHAR)));
        if (!newbuf) break;
		buffer = newbuf;
        retval = GetModuleFileName(NULL, buffer, buflen);
        if (retval == 0 || retval < buflen) break;
        buflen += 256;
        retval = 0;
    }

    if (retval > 0) {
#  ifdef UNICODE
        int n = WideCharToMultiByte(CP_UTF8, 0, buffer, -1, NULL, 0, NULL, NULL);
        char* mbpath = static_cast<char*>(malloc(n));
        if (mbpath) {
            WideCharToMultiByte(CP_UTF8, 0, buffer, -1, mbpath, n, NULL, NULL);
            path = mbpath;
            free(mbpath);
        }
#  else
        path = buffer;
#  endif
    }

    free (buffer);
#elif MACOS
    char* buffer = NULL;
    char* newbuf = NULL;
    uint32_t buflen = 256;

    buffer = reinterpret_cast<char*>(malloc(buflen * sizeof(char)));
    if (buffer) {
        if (_NSGetExecutablePath(buffer, &buflen) == 0) {
            path = buffer;
        } else {
            newbuf = reinterpret_cast<char*>(realloc(buffer, buflen * sizeof(char)));
            if (newbuf)	{
			    buffer = newbuf;
                if (_NSGetExecutablePath(buffer, &buflen) == 0) {
                    path = buffer;
                }
            }
        }
    }

    free(buffer);
#else
    // functionality not supported on this (unknown) platform
#endif
    return path::normpath(path);
}

// ---------------------------------------------------------------------------
string exename()
{
    string exec_path = exepath();
    if (exec_path.empty()) return "";
#if WINDOWS
    string head, ext;
    path::splitext(exec_path, head, ext);
    if (ext == ".exe" || ext == ".com") exec_path = head;
#endif
    return path::basename(exec_path);
}

// ---------------------------------------------------------------------------
string exedir()
{
    string path = exepath();
    return path.empty() ? "" : path::dirname(path);
}

// ---------------------------------------------------------------------------
string readlink(const string& path)
{
    string value;
#if UNIX
    char* buffer = NULL;
    char* newbuf = NULL;
    size_t buflen = 256;
    for (;;) {
        newbuf = reinterpret_cast<char*>(realloc(buffer, buflen * sizeof(char)));
        if (!newbuf) break;
        buffer = newbuf;
        int n = ::readlink(path.c_str(), buffer, buflen);
        if (n < 0) break;
        if (static_cast<size_t>(n) < buflen) {
            buffer[n] = '\0';
            value = buffer;
            break;
        }
        buflen += 256;
    }
    free(buffer);
#endif
    return value;
}

// ---------------------------------------------------------------------------
// common implementation of mkdir() and makedirs()
static inline bool makedir(const string& path, bool parent)
{
    if (path.empty()) return true; // cwd already exists
    if (path::isfile(path)) return false;
    vector<string> dirs;
    string         dir(path);
    if (parent) {
        while (!dir.empty() && !path::exists(dir)) {
            dirs.push_back(dir);
            dir = path::dirname(dir);
        }
    } else if (!path::exists(dir)) {
        dirs.push_back(dir);
    }
    for (vector<string>::reverse_iterator it = dirs.rbegin(); it != dirs.rend(); ++it) {
#if WINDOWS
        if (CreateDirectory(it->c_str(), NULL) == FALSE) return false;
#else
        if (::mkdir(it->c_str(), 0755) != 0) return false;
#endif
    }
    return true;
}

// ---------------------------------------------------------------------------
bool mkdir(const string& path)
{
    return makedir(path, false);
}

// ---------------------------------------------------------------------------
bool makedirs(const string& path)
{
    return makedir(path, true);
}

// ---------------------------------------------------------------------------
// common implementation of rmdir() and rmtree()
static inline bool removedir(const string& path, bool recursive)
{
    // remove files and subdirectories - recursive implementation
    if (recursive && !emptydir(path)) return false;
    // remove this directory
#if WINDOWS
    return (::SetFileAttributes(path.c_str(), FILE_ATTRIBUTE_NORMAL) == TRUE) &&
           (::RemoveDirectory(path.c_str()) == TRUE);
#else
    return ::rmdir(path.c_str()) == 0;
#endif
}

// ---------------------------------------------------------------------------
bool rmdir(const string& path)
{
    return removedir(path, false);
}

// ---------------------------------------------------------------------------
bool rmtree(const string& path)
{
    return removedir(path, true);
}

// ---------------------------------------------------------------------------
bool emptydir(const string& path)
{
    bool ok = true;
    string subpath; // either subdirectory or file path

#if WINDOWS
    WIN32_FIND_DATA info;
    HANDLE hFile = ::FindFirstFile(path::join(path, "*.*").c_str(), &info);
    if (hFile != INVALID_HANDLE_VALUE) {
        do {
            // skip '.' and '..'
            if (strncmp(info.cFileName, ".", 2) == 0 || strncmp(info.cFileName, "..", 3) == 0) {
                continue;
            }
            // remove subdirectory or file, respectively
            subpath = path::join(path, info.cFileName);
            if(info.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                if (!removedir(subpath, true)) ok = false;
            } else {
                if (::SetFileAttributes(subpath.c_str(), FILE_ATTRIBUTE_NORMAL) == FALSE ||
                    ::DeleteFile(subpath.c_str()) == FALSE) ok = false;
            }
        } while (::FindNextFile(hFile, &info) == TRUE);
        ::FindClose(hFile);
    }
#else
    struct dirent *p = NULL;
    DIR *d = opendir(path.c_str());
    if (d != NULL) {
        while ((p = readdir(d)) != NULL) {
            // skip '.' and '..'
            if (strncmp(p->d_name, ".", 2) == 0 || strncmp(p->d_name, "..", 3) == 0) {
                continue;
            }
            // remove subdirectory or file, respectively
            subpath = path::join(path, p->d_name);
            if (path::isdir(subpath)) {
                if (!rmtree(subpath)) ok = false;
            } else {
                if (unlink(subpath.c_str()) != 0) ok = false;
            }
        }
        closedir(d);
    }
#endif
    return ok;
}


} // namespace os

} // namespace basis
