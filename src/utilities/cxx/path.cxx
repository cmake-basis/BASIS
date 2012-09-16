/**
 * @file  path.cxx
 * @brief File/directory path related functions.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <vector>

#include <basis/config.h> // platform macros - must be first

#include <stdlib.h>       // malloc(), free(), _splitpath_s() (WINDOWS)
#include <string.h>       // strncmp()
#include <cctype>         // toupper()
#include <algorithm>      // transform()

#if WINDOWS
#  include <windows.h>    // GetFileAttributes()
#else
#  include <sys/stat.h>   // stat(), lstat()
#endif

#include <basis/except.h> // to throw exceptions

#include <basis/os.h>
#include <basis/os/path.h>


// acceptable in .cxx file
using namespace std;


namespace basis { namespace os { namespace path {


// ===========================================================================
// representation
// ===========================================================================

#if WINDOWS
    static const char  cSeparator  = '\\';
    static const char* cSeparators = "\\/";
#else
    static const char  cSeparator  = '/';
    static const char* cSeparators = "/";
#endif

// ---------------------------------------------------------------------------
inline bool issep(char c)
{
    #if WINDOWS
        return c == '/' || c == '\\';
    #else
        return c == '/';
    #endif
}

// ---------------------------------------------------------------------------
static inline string replace(string str, char from, char to)
{
    string res(str.size(), '\0');
    string::const_iterator in  = str.begin();
    string::iterator       out = res.begin();
    while (in != str.end()) {
        if (*in == from) *out = to;
        else             *out = *in;
        in++; out++;
    }
    return res;
}

// ---------------------------------------------------------------------------
string normpath(const string& path)
{
    if (path.empty()) return "";
    char drive[3] = {'\0', ':', '\0'};
    size_t i = 0;
    #if WINDOWS
        if (path.size() > 1 && path[1] == ':') {
            drive[0] = path[0];
            i = 2;
        }
    #endif
    string norm_path = drive;
    bool abs = issep(path[i]);
    if (abs) {
        #if WINDOWS
            while (i <= path.size() && issep(path[i])) {
                norm_path += cSeparator;
                i++;
            }
        #else
            norm_path += cSeparator;
        #endif
    }
    string         current;
    vector<string> parts;
    while (i <= path.size()) {
        if (issep(path[i]) || path[i] == '\0') {
            if (current == "..") {
                if (!abs && (parts.empty() || parts.back() == "..")) {
                    parts.push_back(current);
                } else if (!parts.empty()) {
                    parts.pop_back();
                }
            } else if (current != "" && current != ".") {
                parts.push_back(current);
            }
            current.clear();
        } else {
            current += path[i];
        }
        i++;
    }
    for (i = 0; i < parts.size(); i++) {
        norm_path = join(norm_path, parts[i]);
    }
    return norm_path.empty() ? "." : norm_path;
}

// ---------------------------------------------------------------------------
string posixpath(const string& path)
{
    #if WINDOWS
        string norm_path = path;
    #else
        string norm_path = replace(path, '\\', '/');
    #endif
    norm_path = normpath(norm_path);
    #if WINDOWS
        norm_path = replace(norm_path, '\\', '/');
    #endif
    return norm_path;
}

// ---------------------------------------------------------------------------
string ntpath(const string& path)
{
    #if WINDOWS
        string norm_path = path;
    #else
        string norm_path = replace(path, '\\', '/');
    #endif
    norm_path = normpath(norm_path);
    #if UNIX
        norm_path = replace(norm_path, '/', '\\');
    #endif
    return norm_path;
}

// ===========================================================================
// components
// ===========================================================================

// ---------------------------------------------------------------------------
void split(const string& path, string& head, string& tail)
{
    size_t last = path.find_last_of(cSeparators);
    if (last == string::npos) {
        head = "";
        tail = path;
    } else {
        size_t pos = last;
        if (last > 0) pos  = path.find_last_not_of(cSeparators, last - 1);
        if (pos == string::npos) head = path.substr(0, last + 1);
        else                     head = path.substr(0, pos  + 1);
        tail = path.substr(last + 1);
    }
}

// ---------------------------------------------------------------------------
vector<string> split(const string& path)
{
    vector<string> parts(2, "");
    split(path, parts[0], parts[1]);
    return parts;
}

// ---------------------------------------------------------------------------
void splitdrive(const string& path, string& drive, string& tail)
{
#if WINDOWS
    if (path.size() > 1 && path[1] == ':') {
        tail  = path.substr(2);
        drive = path[0]; drive += ':';
    }
    else
#endif
    {
        tail  = path;
        drive = "";
    }
}

// ---------------------------------------------------------------------------
vector<string> splitdrive(const string& path)
{
    vector<string> parts(2, "");
    splitdrive(path, parts[0], parts[1]);
    return parts;
}

// ---------------------------------------------------------------------------
void splitext(const string& path, string& head, string& ext, const set<string>* exts, bool icase)
{
    size_t pos = string::npos;
    // test user supplied extensions only
    if (exts) {
        for (set<string>::const_iterator i = exts->begin(); i != exts->end(); ++i) {
            if (path.size() < i->size()) continue;
            size_t start = path.size() - i->size();
            if (start < pos) { // longest match
                if (icase) {
                    string str = path.substr(start);
                    string ext = *i;
                    std::transform(str.begin(), str.end(), str.begin(), ::toupper);
                    std::transform(ext.begin(), ext.end(), ext.begin(), ::toupper);
                    if (str == ext) pos = start;
                } else if (path.compare(start, i->size(), *i) == 0) {
                    pos = start;
                }
            }
        }
    // otherwise, get position of last dot
    } else {
        pos = path.find_last_of('.');
        // leading dot of file name in Posix indicates hidden file,
        // not start of file extension
        #if UNIX
            if (pos != string::npos && (pos == 0 || issep(path[pos - 1]))) {
                pos = string::npos;
            }
        #endif
    }
    // split extension
    if (pos == string::npos) {
        head = path;
        ext  = "";
    } else {
        // tmp variable used for the case that head references the same input
        // string as path
        string tmp = path.substr(0, pos);
        ext        = path.substr(pos);
        head       = tmp;
    }
}

// ---------------------------------------------------------------------------
vector<string> splitext(const string& path, const set<string>* exts)
{
    vector<string> parts(2, "");
    splitext(path, parts[0], parts[1], exts);
    return parts;
}

// ---------------------------------------------------------------------------
string dirname(const string& path)
{
    vector<string> parts(2, "");
    split(path, parts[0], parts[1]);
    return parts[0];
}

// ---------------------------------------------------------------------------
string basename(const string& path)
{
    vector<string> parts(2, "");
    split(path, parts[0], parts[1]);
    return parts[1];
}

// ---------------------------------------------------------------------------
bool hasext(const string& path, const set<string>* exts)
{
    string ext = splitext(path, exts)[1];
    return exts ? exts->find(ext) != exts->end() : !ext.empty();
}

// ===========================================================================
// conversion
// ===========================================================================

// ---------------------------------------------------------------------------
bool isabs(const string& path)
{
    size_t i = 0;
    #if WINDOWS
        if (path.size() > 1 && path[1] == ':') i = 2;
    #endif
    return i < path.size() && issep(path[i]);
}

// ---------------------------------------------------------------------------
string abspath(const string& path)
{
    return normpath(join(getcwd(), path));
}

// ---------------------------------------------------------------------------
string relpath(const string& path, const string& base)
{
    // if relative path is given just return it
    if (!isabs(path)) return path;
    // normalize paths
    string norm_path = normpath(path);
    string norm_base = normpath(join(getcwd(), base));
    // check if paths are on same drive
    #if WINDOWS
        string drive      = splitdrive(norm_path)[0];
        string base_drive = splitdrive(norm_base)[0];
        if (drive != base_drive) {
            BASIS_THROW(invalid_argument,
                        "Path is on drive " << drive << ", start is on drive " << base_drive);
        }
    #endif
    // find start of first path component in which paths differ
    string::const_iterator b = norm_base.begin();
    string::const_iterator p = norm_path.begin();
    size_t pos = 0;
    size_t i   = 0;
    while (b != norm_base.end() && p != norm_path.end()) {
        if (issep(*p)) {
            if (!issep(*b)) break;
            pos = i;
        } else if (*b != *p) {
            break;
        }
        b++; p++; i++;
    }
    // set pos to i (in this case, the size of one of the paths) if the end
    // of one path was reached, but the other path has a path separator
    // at this position, this is required below
    if ((b != norm_base.end() && issep(*b)) ||
        (p != norm_path.end() && issep(*p))) pos = i;
    // skip trailing separator of other path if end of one path reached
    if (b == norm_base.end() && p != norm_path.end() && issep(*p)) p++;
    if (p == norm_path.end() && b != norm_base.end() && issep(*b)) b++;
    // if paths are the same, just return a period (.)
    //
    // Thanks to the previous skipping of trailing separators, this condition
    // handles all of the following cases:
    //
    //    base := "/usr/bin"  path := "/usr/bin"
    //    base := "/usr/bin/" path := "/usr/bin/"
    //    base := "/usr/bin"  path := "/usr/bin/"
    //    base := "/usr/bin/" path := "/usr/bin"
    if (b == norm_base.end() && p == norm_path.end()) return ".";
    // otherwise, pos is the index of the last slash for which both paths
    // were identical; hence, everything that comes after in the original
    // path is preserved and for each following component in the base path
    // a "../" is prepended to the relative path
    string rel_path;
    // truncate base path with a separator as for each "*/" path component,
    // a "../" will be prepended to the relative path
    if (b != norm_base.end() && !issep(norm_base[norm_base.size() - 1])) {
        // attention: This operation may invalidate the iterator b!
        //            Therefore, remember position of iterator and get a new one.
        size_t pos = b - norm_base.begin();
        norm_base += cSeparator;
        b = norm_base.begin() + pos;
    }
    while (b != norm_base.end()) {
        if (issep(*b)) {
            rel_path += "..";
            rel_path += cSeparator;
        }
        b++;
    }
    if (pos + 1 < norm_path.size()) rel_path += norm_path.substr(pos + 1);
    // remove trailing path separator
    if (issep(rel_path[rel_path.size() - 1])) {
        rel_path.erase(rel_path.size() - 1);
    }
    return rel_path;
}

// ---------------------------------------------------------------------------
string realpath(const string& path)
{
    string curr_path = join(getcwd(), path);
    #if UNIX
        // use stringstream and std::getline() to split absolute path at slashes (/)
        stringstream ss(curr_path);
        curr_path.clear();
        string fname;
        string prev_path;
        string next_path;
        char slash;
        ss >> slash; // root slash
        while (getline(ss, fname, '/')) {
            // current absolute path
            curr_path += '/';
            curr_path += fname;
            // if current path is a symbolic link, follow it
            if (islink(curr_path)) {
                // for safety reasons, restrict the depth of symbolic links followed
                for (unsigned int i = 0; i < 100; i++) {
                    next_path = os::readlink(curr_path);
                    if (next_path.empty()) {
                        // if real path could not be determined because of permissions
                        // or invalid path, return the original path
                        break;
                    } else {
                        curr_path = join(prev_path, next_path);
                        if (!islink(next_path)) break;
                    }
                }
                // if real path could not be determined with the given maximum number
                // of loop iterations (endless cycle?) or one of the symbolic links
                // could not be read, just return original path as absolute path
                if (islink(next_path)) {
                    return abspath(path);
                }
            }
            // memorize previous path used as base for abspath()
            prev_path = curr_path;
        }
    #endif
    // normalize path after all symbolic links were resolved
    return normpath(curr_path);
}

// ---------------------------------------------------------------------------
string join(const string& base, const string& path)
{
    if (base.empty() || isabs(path))  return path;
    if (issep(base[base.size() - 1])) return base + path;
    #if WINDOWS
        return base + '\\' + path;
    #else
        return base + '/' + path;
    #endif
}

// ===========================================================================
// file status
// ===========================================================================

// ---------------------------------------------------------------------------
bool isfile(const std::string path)
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
bool isdir(const std::string path)
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
bool islink(const string& path)
{
    #if WINDOWS
        return false;
    #else
        struct stat info;
        if (lstat(path.c_str(), &info) != 0) return false;
        return S_ISLNK(info.st_mode);
    #endif
}


} // namespace path

} // namespace os

} // namespace basis
