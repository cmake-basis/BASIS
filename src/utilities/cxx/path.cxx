/**
 * @file  path.cxx
 * @brief Basic file path manipulation and related system functions.
 *
 * Copyright (c) 2011, University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <vector>

#include <sbia/basis/config.h> // platform macros - must be first

#include <stdlib.h>            // malloc() & free(), _splitpath_s() (WINDOWS)
#include <string.h>            // strncmp()

#if WINDOWS
#  include <direct.h>          // _getcwd()
#  include <windows.h>         // GetModuleFileName()
#else
#  include <unistd.h>          // getcwd(), rmdir()
#  include <sys/stat.h>        // stat(), lstat()
#  include <dirent.h>          // opendir()
#endif
#if MACOS
#  include <mach-o/dyld.h>     // _NSGetExecutablePath()
#endif

#include <sbia/basis/except.h> // to throw exceptions
#include <sbia/basis/path.h>   // declarations and BASIS configuration


// acceptable in .cxx file
using namespace std;


namespace sbia
{

namespace basis
{


// ===========================================================================
// constants
// ===========================================================================

#if WINDOWS
const char   cPathSeparator = '\\';
const string cPathSeparatorStr ("\\");
#else
const char   cPathSeparator = '/';
const string cPathSeparatorStr ("/");
#endif

// ===========================================================================
// path representations
// ===========================================================================

// ---------------------------------------------------------------------------
bool is_valid_path(const string& path, bool strict)
{
    // an empty string is clearly no valid path
    if (path.empty()) return false;
    // we do not allow a path to start with a colon (:) (also not on Unix!)
    if (path[0] == ':') return false;
    // absolute Windows-style path with drive specification
    if (path.size() > 1 && path[1] == ':') {
        // first character must be a drive letter
        if ((path[0] < 'a' || 'z' < path[0]) &&
            (path[0] < 'A' || 'Z' < path[0])) return false;
        // absolute path must follow the drive specification
        if (path.size() == 2) return false;
        if (path[2] != '/' && path[2] != '\\') return false;
        if (strict) {
#if !WINDOWS
            // on Unix systems, a drive specification is invalid
            // however, to be consistent, the drive C: is just ignored and
            // interpreted as root on Unix
            if (path[0] != 'C' && path[0] != 'c') return false;
#endif
        }
    }
    // otherwise, the path is valid
    return true;
}

// ---------------------------------------------------------------------------
string clean_path(const string& path)
{
    if (!is_valid_path(path, false)) {
        BASIS_THROW(invalid_argument, "Invalid path: ''");
    }

    string cleaned_path;

    string::const_iterator prev;
    string::const_iterator curr;
    string::const_iterator next;

    // remove periods enclosed by slashes (or backslashes)
    prev = path.begin();
    if (prev == path.end()) return "";

    curr = prev + 1;
    next = ((curr == path.end()) ? curr : (curr + 1));

    cleaned_path.reserve(path.size());
    cleaned_path.push_back(*prev);
    while (curr != path.end()) {
        if (*curr == '.' && (*prev == '/' || *prev == '\\')) {
            if (next == path.end()) {
                // remove the "/" that was added before b/c the
                // final "/." should be removed together
                cleaned_path.erase(cleaned_path.size() - 1);
            }
            else if (*next != '/' && *next != '\\') {
                cleaned_path.push_back(*curr);
            }
        } else {
            cleaned_path.push_back(*curr);
        }

        prev++;
        curr++;
        if (next != path.end()) next++;
    }

    // remove duplicate slashes (and backslashes)
    string tmp;
    cleaned_path.swap(tmp);

    prev = tmp.begin();
    curr = prev + 1;

    cleaned_path.reserve(tmp.size());
    cleaned_path.push_back(*prev);
    while (curr != tmp.end()) {
        if ((*curr != '/' && *curr != '\\') || (*prev != '/' && *prev != '\\')) {
            cleaned_path.push_back(*curr);
        }

        prev++;
        curr++;
    }

    // remove references to parent directories
    size_t skip = 0;

    // in case of relative paths like "../../*" we need to skip the first
    // parent directory references
    while (skip + 3 <= cleaned_path.size()) {
        string sub = cleaned_path.substr(skip, 3);
        if (sub != "../" && sub != "..\\") break;
        skip += 3;
    }
    if (skip > 0) skip -= 1; // below, we look for "/.." instead of "../"

    string ref = "/.."; // will be set to "\.." on the "second" run
    size_t pos = skip;  // the starting position of the path "absolute" to
                        // to the root directory given by "../../" or "/",
                        // for example.
    for (;;) {
        pos = cleaned_path.find(ref, pos);
        if (pos == string::npos) {
            if (ref == "\\..") break;
            // no occurrences of "/.." found, now clean up the ones of "\.."
            ref = "\\..";
            pos = skip;
            pos = cleaned_path.find(ref, pos);
            if (pos == string::npos) break;
        }
        if (pos + 3 == cleaned_path.size()
                || cleaned_path[pos + 3] == '/'
                || cleaned_path[pos + 3] == '\\') {
            if (pos == 0) {
                if (cleaned_path.size() == 3) cleaned_path.erase(1, 2);
                else                          cleaned_path.erase(0, 3);
                pos = skip;
            } else {
                size_t start = cleaned_path.find_last_of("/\\", pos - 1);
                if (start != string::npos) {
                    cleaned_path.erase(start, pos - start + 3);
                    pos = start + 1;
                } else if (cleaned_path[0] == '/' || cleaned_path[0] == '\\') {
                    cleaned_path.erase(skip, pos + 3);
                    pos = skip;
                } else {
                    pos += 3;
                }
            }
        } else {
            pos += 3;
        }
    }

    return cleaned_path;
}

// ---------------------------------------------------------------------------
string to_unix_path(const string& path, bool drive)
{
    if (!is_valid_path(path)) {
        BASIS_THROW(invalid_argument, "Invalid path: '" << path << "'");
    }

    string unix_path;
    unix_path.reserve(path.size());

    string::const_iterator in = path.begin();

    // optional drive specification
	if (path.size() > 1 && path[1] == ':') {
        if (drive) {
            if ('a' <= path[0] && path[0] <= 'z') unix_path += 'A' + (path[0] - 'a');
            else                                  unix_path += path[0];
            unix_path += ":/";
        }
        in += 2;
	}

    // copy path while replacing backslashes by slashes
    while (in != path.end()) {
        if (*in == '\\') unix_path.push_back('/');
        else             unix_path.push_back(*in);
        in++;
    }

    return clean_path(unix_path);
}

// ---------------------------------------------------------------------------
string to_windows_path(const string& path)
{
    if (!is_valid_path(path, false)) {
        BASIS_THROW(invalid_argument, "Invalid path: '" << path << "'");
    }

    string windows_path(path.size(), '\0');

    // copy path while replacing slashes by backslashes
    string::const_iterator in  = path.begin();
    string::iterator       out = windows_path.begin();

    while (in != path.end()) {
        if (*in == '/') *out = '\\';
        else            *out = *in;
        in++;
        out++;
    }

    // prepend drive specification to absolute paths
    if (windows_path[0] == '\\') {
        windows_path.reserve(windows_path.size() + 2);
        windows_path.insert (0, "C:");
    }

    return clean_path(windows_path);
}

// ---------------------------------------------------------------------------
string to_native_path(const string& path)
{
#if WINDOWS
    return to_windows_path(path);
#else
    return to_unix_path(path);
#endif
}

// ===========================================================================
// working directory
// ===========================================================================

// ---------------------------------------------------------------------------
string get_working_directory()
{
    string wd;
#if WINDOWS
    char* buffer = _getcwd(NULL, 0);
#else
    char* buffer = getcwd(NULL, 0);
#endif
    if (buffer) {
        wd = buffer;
        free(buffer);
    }
    if (!wd.empty()) wd = to_unix_path(wd, true);
    return wd;
}

// ===========================================================================
// path components
// ===========================================================================

// ---------------------------------------------------------------------------
void split_path(const string&path, string* root, string* dir, string* fname,
                string* ext, const set<string>* exts)
{
    // file root
    if (root) *root = get_file_root(path);
    // \note No need to validate path here if get_file_root() is executed.
    //       Otherwise, it is necessary as to_unix_path() is not as restrict.
    else if (!is_valid_path(path)) {
        BASIS_THROW(invalid_argument, "Invalid path: '" << path << "'");
    }
    // convert path to clean Unix-style path
    string unix_path = to_unix_path(path);
    // get position of last slash
    size_t last = unix_path.find_last_of('/');
    // file directory without root
    if (dir) {
        if (last == string::npos) {
            *dir = "";
        } else {
            size_t start = 0;

            if (unix_path[0] == '/') {
                start = 1;
            } else if (unix_path.size() > 1 &&
                       unix_path[0] == '.'  &&
                       unix_path[1] == '/') {
                start = 2;
            }

            *dir = unix_path.substr(start, last - start + 1);
        }
    }
    // file name and extension
    if (fname || ext) {
        string name;

        if (last == string::npos) {
            name = unix_path;
        } else {
            name = unix_path.substr(last + 1);
        }

        size_t pos = string::npos;
        
        // first test user supplied extension
        if (exts && exts->size() > 0) {
            for (set<string>::const_iterator i = exts->begin(); i != exts->end(); ++i) {
                size_t start = name.size() - i->size();
                if (start < pos && name.compare(start, i->size(), *i) == 0) {
                    pos = start;
                }
            }
        }
        // otherwise, extract last extension component
        if (pos == string::npos) {
            pos = name.find_last_of('.');
        }

        if (pos == string::npos) {
            if (fname) {
                *fname = name;
            }
            if (ext) {
                *ext = "";
            }
        } else {
            if (fname) {
                *fname = name.substr(0, pos);
            }
            if (ext) {
                *ext = name.substr(pos);
            }
        }
    }
}

// ---------------------------------------------------------------------------
string get_file_root(const string& path)
{
    if (!is_valid_path(path)) {
        BASIS_THROW(invalid_argument, "Invalid path: '" << path << "'");
    }

    // absolute Unix-style input path
    if (path[0] == '/' || path[0] == '\\') {
#if WINDOWS
        return "C:/";
#else
        return "/";
#endif
    }
    // absolute Windows-style input path
    if (path.size() > 1 && path[1] == ':') {
        char letter = path[0];
        if ('a' <= letter && letter <= 'z') {
            letter = 'A' + (letter - 'a');
        }
#if WINDOWS
		string root; root += letter; root += ":/";
        return root;
#else
        return "/";
#endif
    }
    // otherwise, it's a relative path
    return "./";
}

// ---------------------------------------------------------------------------
string get_file_directory(const string& path)
{
    string root;
    string dir;
    split_path(path, &root, &dir, NULL, NULL);
    if (root == "./") {
        if (dir.empty()) return "./";
        else             return dir;
    } else {
        return root + dir.substr(0, dir.size() - 1);
    }
}

// ---------------------------------------------------------------------------
string get_file_name(const string& path)
{
    string fname;
    string ext;
    split_path(path, NULL, NULL, &fname, &ext);
    return fname + ext;
}

// ---------------------------------------------------------------------------
string get_file_name_without_extension(const string& path, const set<string>* exts)
{
    string fname;
    split_path(path, NULL, NULL, &fname, NULL, exts);
    return fname;
}

// ---------------------------------------------------------------------------
string get_file_name_extension(const string& path, const set<string>* exts)
{
    string ext;
    split_path(path, NULL, NULL, NULL, &ext, exts);
    return ext;
}

// ---------------------------------------------------------------------------
bool has_extension(const string& path, const set<string>* exts)
{
    string ext = get_file_name_extension(path, exts);
    return exts ? exts->find(ext) != exts->end() : !ext.empty();
}

// ===========================================================================
// absolute / relative paths
// ===========================================================================

// ---------------------------------------------------------------------------
bool is_absolute(const string& path)
{
    return get_file_root(path) != "./";
}

// ---------------------------------------------------------------------------
bool is_relative(const string& path)
{
    return get_file_root(path) == "./";
}

// ---------------------------------------------------------------------------
string to_absolute_path(const string& path)
{
    return to_absolute_path(get_working_directory(), path);
}

// ---------------------------------------------------------------------------
string to_absolute_path(const string& base, const string& path)
{
    string abs_path(path);
    // make relative path absolute
    if (is_relative(abs_path)) {
        string abs_base(base);
        if (is_relative(abs_base)) {
            abs_base.insert(0, get_working_directory() + '/');
        }
        abs_path.insert(0, abs_base + '/');
    }
    // convert to (clean) Unix-style path with drive specification
    abs_path = to_unix_path(abs_path, true);
    // on Windows, prepend drive letter followed by a colon (:)
#if WINDOWS
    if (abs_path[0] == '/') abs_path.insert(0, "C:");
#endif
    return abs_path;
}

// ---------------------------------------------------------------------------
string to_relative_path(const string& path)
{
    string unix_path = to_unix_path(path, true);
    if (is_relative(unix_path)) return clean_path(unix_path);
    return to_relative_path(get_working_directory(), unix_path);
}

// ---------------------------------------------------------------------------
string to_relative_path(const string& base, const string& path)
{
    string unix_path = to_unix_path(path, true);
    // if relative path is given just return it cleaned
    if (is_relative(unix_path)) return clean_path(path);
    // make base path absolute
    string abs_base = to_unix_path(base, true);
    if (is_relative(abs_base)) {
        abs_base.insert(0, get_working_directory() + '/');
    }
    // path must have same root as base path; this check is intended for
    // Windows, where there is no relative path from one drive to another
    if (get_file_root(abs_base) != get_file_root(unix_path)) return "";
    // find start of first path component in which paths differ
    string::const_iterator b = abs_base .begin();
    string::const_iterator p = unix_path.begin();
    size_t pos = 0;
    size_t i = 0;
    while (b != abs_base.end() && p != unix_path.end() && *b == *p) {
        if (*p == '/') pos = i;
        b++; p++; i++;
    }
    // set pos to i (in this case, the size of one of the paths) if the end
    // of one path was reached, but the other path has a slash (or backslash)
    // at this position, this is required later below
    if ((b != abs_base .end() && (*b == '/' || *b == '\\')) ||
        (p != unix_path.end() && (*p == '/' || *p == '\\'))) pos = i;
    // skip trailing slash of other path if end of one path reached
    if (b == abs_base .end() && p != unix_path.end() && *p == '/') p++;
    if (p == unix_path.end() && b != abs_base .end() && *b == '/') b++;
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
    // Note: The paths have been cleaned before by the to_unix_path() function.
    if (b == abs_base.end() && p == unix_path.end()) return ".";
    // otherwise, pos is the index of the last slash for which both paths
    // were identical; hence, everything that comes after in the original
    // path is preserved and for each following component in the base path
    // a "../" is prepended to the relative path
    string rel_path;
    // truncate base path with a slash (/) as for each "*/" path component,
    // a "../" will be prepended to the relative path
    if (b != abs_base.end() && abs_base[abs_base.size() - 1] != '/') {
        // \attention This operation may invalidate the iterator b!
        //            Therefore, remember position of iterator and get a new one.
        size_t pos = b - abs_base.begin();
        abs_base += '/';
        b = abs_base.begin() + pos;
    }
    while (b != abs_base.end()) {
        if (*b == '/') rel_path += "../";
        b++;
    }
    if (pos + 1 < unix_path.size()) rel_path += unix_path.substr(pos + 1);
    // remove trailing slash (/)
    if (rel_path[rel_path.size() - 1] == '/') {
        rel_path.erase (rel_path.size() - 1);
    }
    return rel_path;
}

// ---------------------------------------------------------------------------
string join_paths(const string& base, const string& path)
{
    if (is_absolute(path)) return clean_path(path);
    else return clean_path(base + '/' + path);
}

// ===========================================================================
// file / directory checks
// ===========================================================================

// ---------------------------------------------------------------------------
bool is_file(const std::string path)
{
#if WINDOWS 
    const DWORD info = ::GetFileAttributes(path.c_str());
    return (FILE_ATTRIBUTE_DIRECTORY & info) == 0;
#else
    struct stat info;
    if (stat(path.c_str(), &info) != 0) return false;
    return S_ISREG(info.st_mode);
#endif
    return false;
}

// ---------------------------------------------------------------------------
bool is_dir(const std::string path)
{
#if WINDOWS 
    const DWORD info = ::GetFileAttributes(path.c_str());
    return (FILE_ATTRIBUTE_DIRECTORY & info) != 0;
#else
    struct stat info;
    if (stat(path.c_str(), &info) != 0) return false;
    return S_ISDIR(info.st_mode);
#endif
    return false;
}

// ---------------------------------------------------------------------------
bool exists(const std::string path)
{
#if WINDOWS 
    const DWORD info = ::GetFileAttributes(path.c_str());
    return info != INVALID_FILE_ATTRIBUTES;
#else
    struct stat info;
    if (stat(path.c_str(), &info) == 0) return true;
#endif
    return false;
}

// ---------------------------------------------------------------------------
bool is_symlink(const string& path)
{
    if (!is_valid_path(path)) {
        BASIS_THROW(invalid_argument, "Invalid path: '" << path << "'");
    }

#if WINDOWS
    return false;
#else
    struct stat info;
    if (lstat(path.c_str(), &info) != 0) return false;
    return S_ISLNK(info.st_mode);
#endif
}

// ===========================================================================
// make/remove directory
// ===========================================================================

// ---------------------------------------------------------------------------
bool make_directory(const string& path, bool parent)
{
    if (path.empty() || is_file(path)) return false;
    vector<string> dirs;
    string         dir(path);
    if (parent) {
        while (!dir.empty() && !exists(dir)) {
            dirs.push_back(dir);
            dir = get_file_directory(dir);
        }
    } else if (!exists(dir)) {
        dirs.push_back(dir);
    }
    for (vector<string>::reverse_iterator it = dirs.rbegin(); it != dirs.rend(); ++it) {
#if WINDOWS
        if (CreateDirectory(it->c_str(), NULL) == FALSE) return false;
#else
        if (mkdir(it->c_str(), 0755) != 0) return false;
#endif
    }
    return true;
}

// ---------------------------------------------------------------------------
bool remove_directory(const string& path, bool recursive)
{
    // remove files and subdirectories - recursive implementation
    if (recursive && !clear_directory(path)) return false;
    // remove this directory
#if WINDOWS
    return (::SetFileAttributes(path.c_str(), FILE_ATTRIBUTE_NORMAL) == TRUE) &&
           (::RemoveDirectory(path.c_str()) == TRUE);
#else
    return rmdir(path.c_str()) == 0;
#endif
}

// ---------------------------------------------------------------------------
bool clear_directory(const string& path)
{
    bool ok = true;
    string subpath; // either subdirectory or file path

#if WINDOWS
    WIN32_FIND_DATA info;
    HANDLE hFile = ::FindFirstFile(join_paths(path, "*.*").c_str(), &info);
    if (hFile != INVALID_HANDLE_VALUE) {
        do {
            // skip '.' and '..'
            if (strncmp(info.cFileName, ".", 2) == 0 || strncmp(info.cFileName, "..", 3) == 0) {
                continue;
            }
            // remove subdirectory or file, respectively
            subpath = join_paths(path, info.cFileName);
            if(info.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                if (!remove_directory(subpath, true)) ok = false;
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
            subpath = join_paths(path, p->d_name);
            if (is_dir(subpath)) {
                if (!remove_directory(subpath, true)) ok = false;
            } else {
                if (unlink(subpath.c_str()) != 0) ok = false;
            }
        }
        closedir(d);
    }
#endif
    return ok;
}

// ===========================================================================
// symbolic links
// ===========================================================================

// ---------------------------------------------------------------------------
bool read_symlink(const string& link, string& value)
{
    if (!is_valid_path(link)) {
        BASIS_THROW(invalid_argument, "Invalid path: '" << link << "'");
    }

    bool ok = true;
#if WINDOWS
    value = link;
#else
    char* buffer = NULL;
    char* newbuf = NULL;
    size_t buflen = 256;

    for (;;) {
        newbuf = reinterpret_cast<char*>(realloc(buffer, buflen * sizeof(char)));
        if (!newbuf) {
            ok = false;
            break;
        }
        buffer = newbuf;

        int n = readlink(link.c_str(), buffer, buflen);

        if (n < 0) {
            ok = false;
            break;
        } else if (static_cast<size_t>(n) < buflen) {
            buffer[n] = '\0';
            value = buffer;
            break;
        }
        buflen += 256;
    }

    free(buffer);
#endif
    return ok;
}

// ---------------------------------------------------------------------------
string get_real_path(const string& path)
{
    // make path just absolute if it is no symbolic link
    if (!is_symlink(path)) {
        return to_absolute_path(path);
    }
    string curr_path(path);
    string next_path;
    // for safety reasons, restrict the depth of symbolic links followed
    for (unsigned int i = 0; i < 100; i++) {
        if (read_symlink(curr_path, next_path)) {
            next_path = to_absolute_path(get_file_directory(curr_path), next_path);
            if (!is_symlink(next_path)) {
                return next_path;
            }
            curr_path = next_path;
        } else {
            // if real path could not be determined because of permissions
            // or invalid path, return the original path
            break;
        }
    }
    // if real path could not be determined with the given maximum number of
    // loop iterations (endless cycle?) or one of the symbolic links could
    // not be read, just return original path as clean absolute path
    return to_absolute_path(path);
}

// ===========================================================================
// executable file
// ===========================================================================

// ---------------------------------------------------------------------------
string get_executable_path()
{
    string path;
#if LINUX
    path = get_real_path("/proc/self/exe");
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
    return clean_path(path);
}

// ---------------------------------------------------------------------------
string get_executable_directory()
{
    string path = get_executable_path();
    return path.empty() ? "" : get_file_directory(path);
}

// ---------------------------------------------------------------------------
string get_executable_name()
{
    string name = get_executable_path();
    if (name.empty()) return "";

#if WINDOWS
    string ext = get_file_name_extension(name);
    if (ext == ".exe" || ext == ".com") {
        name = get_file_name_without_extension(name);
    } else {
        name = get_file_name(name);
    }
#else
    name = get_file_name(name);
#endif

    return name;
}


} // namespace basis

} // namespace sbia
