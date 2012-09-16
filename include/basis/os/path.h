/**
 * @file  os/path.h
 * @brief File/directory path related functions.
 *
 * The implementations provided by this module are in particular related to the
 * manipulation of and interaction with file (and directory) paths. These
 * implementations are meant to be simple and therefore focus on non-multibyte
 * path strings only. They were motivated by the os.path module of Python, though,
 * they are no exact replicates of these functions. The path module which is
 * part of the BASIS utilities for Python, on the other side, provides the same
 * extended functionality.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _BASIS_OS_PATH_H
#define _BASIS_OS_PATH_H


#include <set>
#include <vector>
#include <string>


/// @addtogroup BasisCxxUtilities
/// @{


namespace basis { namespace os { namespace path {


// ===========================================================================
// representation
// ===========================================================================

/**
 * @brief Determine if a given character is a path separator.
 *
 * @param [in] c Character.
 *
 * @returns True if @p c is a path separator on this platform and false otherwise.
 */
bool issep(char c);

/**
 * @brief Normalize path, i.e., remove occurences of "./", duplicate slashes,...
 *
 * This function removes single periods enclosed by slashes (or backslashes),
 * duplicate slashes (or backslashes), and further tries to reduce the
 * number of parent directory references. Moreover, on Windows, it replaces
 * slashes with backslashes.
 *
 * For example, on Windows, "../bla//.//.\bla\\\\\bla/../.." is convert to "..\bla".
 * On Unix, it is converted to "..". Note that on Unix, ".\bla\\\\\bla" is a
 * directory name.
 *
 * @param [in] path Path.
 *
 * @returns Normalized path.
 */
std::string normpath(const std::string& path);

/**
 * @brief Convert path to Posix (e.g., Unix, Mac OS) representation.
 *
 * This function first converts backward slashes to forward slashes and then
 * performs the same normalization as normpath() does on Posix systems.
 *
 * @param [in] path Path.
 *
 * @returns Normalized Posix path.
 *
 * @sa normpath()
 * @sa ntpath()
 */
std::string posixpath(const std::string& path);

/**
 * @brief Convert path to Windows representation.
 *
 * This function first converts forward slashes to backward slashes and then
 * performs the same normalization as normpath() does on Windows.
 *
 * @param [in] path Path.
 *
 * @returns Normalized Windows path.
 *
 * @sa normpath)
 * @sa posixpath()
 */
std::string ntpath(const std::string& path);

// ===========================================================================
// components
// ===========================================================================

/**
 * @brief Split path into two parts.
 *
 * This function splits a path into its head and tail. Trailing slashes are
 * stripped from head unless it is the root. See the following table for an
 * illustration:
 @verbatim
   path                     | head          | tail
   -------------------------+-------+---------------+-------------
   "/"                      | "/"           | ""
   "/usr/bin"               | "/usr"        | "bin"
   "/home/user/info.txt"    | "/home/user"  | "info.txt"
   "word.doc"               | ""            | "word.doc"
   "../word.doc"            | ".."          | "word.doc"
   "C:/"                    | "C:/"         | ""
   "C:"                     | "C:"          | ""
   "C:/WINDOWS/regedit.exe" | "C:/WINDOWS"  | "regedit.exe"
   "d:\data"                | "d:/"         | "data"
   "/usr/local/"            | "/usr/local"  | ""
 @endverbatim
 * In all cases, join(head, tail) returns a path to the same location as path
 * (but the strings may differ).
 *
 * @param [in]  path Path.
 * @param [out] head Head part of path.
 * @param [out] tail Tail part of path.
 *
 * @sa splitdrive()
 * @sa splitext()
 * @sa dirname()
 * @sa basename()
 */
void split(const std::string& path, std::string& head, std::string& tail);

/**
 * @brief Split path into two parts.
 *
 * @returns Tuple of (head, tail), i.e., returns always a vector of size 2.
 *
 * @sa split(const std::string&, std::string&, std::string&)
 */
std::vector<std::string> split(const std::string& path);

/**
 * @brief Get drive specification of Windows path.
 *
 * @param [in] path   Path.
 * @param [out] drive Drive on Windows if @p path specifies a drive or empty
 *                    string otherwise.
 * @param [out] tail  Remaining path without drive specification.
 */
void splitdrive(const std::string& path, std::string& drive, std::string& tail);

/**
 * @brief Get drive specification of Windows path.
 *
 * @param [in] path Path.
 *
 * @returns Tuple of (drive, tail), i.e., returns always a vector of size 2.
 */
std::vector<std::string> splitdrive(const std::string& path);

/**
 * @brief Get file name extension.
 *
 * @param [in]  path  Path.
 * @param [out] head  Remaining path without extension.
 * @param [out] ext   Extension (including leading dot).
 * @param [in]  exts  Set of recognized extensions. Note that the given set
 *                    can contain extensions with dots (.) as part of the
 *                    extension, e.g., ".nii.gz". If NULL is given, the part
 *                    after the last dot (including the dot) is considered to
 *                    be the file name extension. Otherwise, the longest extension
 *                    from the given set which is equal to the end of the file
 *                    path is returned. If no specified extension matched, an
 *                    empty string is returned as extension.
 * @param [in]  icase Whether to ignore the case of the extensions.
 */
void splitext(const std::string& path, std::string& head, std::string& ext,
              const std::set<std::string>* exts = NULL, bool icase = false);

/**
 * @brief Get file name extension.
 *
 * @param [in] path Path.
 * @param [in] exts Set of recognized extensions.
 *
 * @sa splitext(const std::string&, std::string&, std::string&, const std::set<std::string>*)
 */
std::vector<std::string> splitext(const std::string& path, const std::set<std::string>* exts = NULL);

/**
 * @brief Get file directory.
 *
 * @param [in] path Path.
 *
 * @returns The head part returned by split().
 *
 * @sa split()
 */
std::string dirname(const std::string& path);

/**
 * @brief Get file name.
 *
 * @param [in] path Path.
 *
 * @returns The tail part returned by split(), i.e., the file/directory name.
 *
 * @sa split()
 */
std::string basename(const std::string& path);

/**
 * @brief Test whether a given path has an extension.
 *
 * @param [in] path Path.
 * @param [in] exts Set of recognized extensions or NULL.
 *
 * @returns Whether the given path has a file name extension. If @p exts is not
 *          NULL, this function returns true only if the file name ends in one
 *          of the specified extensions (including dot if required). Otherwise,
 *          it only checks if the path has a dot (.) in the file name.
 */
bool hasext(const std::string& path, const std::set<std::string>* exts = NULL);

// ===========================================================================
// conversion
// ===========================================================================

/**
 * @brief Test whether a given path is absolute.
 *
 * @param path [in] Absolute or relative path.
 *
 * @return Whether the given path is absolute.
 */
bool isabs(const std::string& path);

/**
 * @brief Make path absolute.
 *
 * @param [in] path Absolute or relative path.
 *
 * @return Absolute path. If @p path is already absolute, it is returned
 *         unchanged. Otherwise, it is made absolute using the current
 *         working directory.
 */
std::string abspath(const std::string& path);

/**
 * @brief Make path relative.
 *
 * @param [in] path Absolute or relative path.
 * @param [in] base Base path used to make absolute path relative.
 *                  Defaults to current working directory if no path is
 *                  given. If a relative path is given as base path, it
 *                  is made absolute using the current working directory.
 *
 * @return Path relative to @p base.
 *
 * @throws std::invalid_argument on Windows, if @p path and @p base are paths
 *                               on different drives.
 */
std::string relpath(const std::string& path, const std::string& base = std::string());

/**
 * @brief Get canonical file path.
 *
 * This function resolves symbolic links and returns a normalized path.
 *
 * @param [in] path Path.
 *
 * @return Canonical file path.
 */
std::string realpath(const std::string& path);

/**
 * @brief Join two paths, e.g., base path and relative path.
 *
 * This function joins two paths. If the second path is an absolute path,
 * this normalized absolute path is returned. Otherwise, the base path is
 * prepended to the relative path and the resulting relative or absolute
 * path returned after normalizing it.
 *
 * @param [in] base Base path.
 * @param [in] path Relative or absolute path.
 *
 * @return Joined path.
 */
std::string join(const std::string& base, const std::string& path);

// ===========================================================================
// file status
// ===========================================================================

/**
 * @brief Test the existance of a file or directory.
 *
 * @param [in] path File or directory path.
 *
 * @return Whether the given file or directory exists.
 */
bool exists(const std::string path);

/**
 * @brief Test whether a given path is the path of an existent file.
 *
 * @note This function follows symbolic links.
 *
 * @param [in] path File path.
 *
 * @return Whether the given path is an existent file.
 */
bool isfile(const std::string path);

/**
 * @brief Test whether a given path is the path of an existent directory.
 *
 * @note This function follows symbolic links.
 *
 * @param [in] path Directory path.
 *
 * @return Whether the given path is an existent directory.
 */
bool isdir(const std::string path);

/**
 * @brief Whether a given path is a symbolic link.
 *
 * @param [in] path Path.
 *
 * @return Whether the given path denotes a symbolic link.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa isvalid()
 */
bool islink(const std::string& path);


} // namespace path

} // namespace os

} // namespace basis


/// @}
// Doxygen group

#endif // _BASIS_OS_PATH_H
