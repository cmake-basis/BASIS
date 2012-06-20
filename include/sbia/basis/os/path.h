/**
 * @file  path.h
 * @brief File/directory path related functions.
 *
 * The implementations provided by this module are in particular related to the
 * manipulation of and interaction with file (and directory) paths. These
 * implementations are meant to be simple and therefore focus on non-multibyte
 * path strings only.
 *
 * Note that in order to improve portability and because of the main focus
 * on Posix systems such as Unix and Mac OS, slashes (/) are used as path
 * separators. A function to convert a given path to its native representation
 * is provided, however. Further, only relative paths and absolute paths which
 * start with a slash (/) on Posix systems or a slash (/), backslash (\), or
 * drive specification on Windows are supported. Hence, UNC paths, the inclusion
 * of a hostname in the path, etc. are not supported. Also, masking of slashes or
 * backslashes is not supported either. This is just a simple implementation
 * that should work for most of the use cases in software written at SBIA.
 * If not, please contact the maintainer of the BASIS package.
 *
 * @noe While the names of the functions including the use of the given
 *      namespaces are motivated by the os.path module of Python, do the
 *      implementations not necessarily follow exactly the one of the
 *      corresponding functions of this Python module.
 *
 * @attention Instead of "using namespace sbia::basis::os::path;", consider the
 *            use of "path = sbia::basis::os::path;" to avoid the complicated full
 *            namespace specification, while still avoiding name conflicts with
 *            other symbols such as variables (e.g. filename). Note in .h, .hxx,
 *            or .txx files, i.e., files included by other modules, always the
 *            full namespace must be used.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _SBIA_BASIS_OS_PATH_H
#define _SBIA_BASIS_OS_PATH_H


#include <set>
#include <string>


/// @addtogroup BasisCxxUtilities
/// @{


namespace sbia
{

namespace basis
{

namespace os
{

namespace path
{


// ===========================================================================
// path representations
// ===========================================================================

/**
 * @brief Whether a given string is a valid path.
 *
 * @attention This function only checks whether the string is a valid path
 *            identifier. It does <b>not</b> check whether the file exists.
 *
 * @param [in] path   The path string.
 * @param [in] strict Whether to be strict, i.e., whether a drive specification
 *                    other than "C:" is considered invalid on UNIX-based
 *                    systems.
 *
 * @return Whether the given string is a valid path.
 *
 * @sa exists()
 */
bool isvalid(const std::string& path, bool strict = true);

/**
 * @brief Normalize path, i.e., remove occurences of "./", duplicate slashes,...
 *
 * This function removes single periods (.) enclosed by slashes or backslashes,
 * duplicate slashes (/) or backslashes (\), and further tries to reduce the
 * number of parent directory references.
 *
 * For example, "../bla//.//.\bla\\\\\bla/../.." is convert to "../bla".
 *
 * @param [in] path Path.
 *
 * @return Clean ormalized path.
 */
std::string normpath(const std::string& path);

/**
 * @brief Convert path to Posix (e.g., Unix, Mac OS) representation.
 *
 * @param [in] path  Path.
 * @param [in] drive Whether the drive specification should be preserved.
 *
 * @return Path in Posix representation, i.e., with slashes (/) as path
 *         separators and without drive specification if the drive parameter
 *         is set to false.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa nt()
 * @sa native()
 * @sa isvalid()
 */
std::string posix(const std::string& path, bool drive = false);

/**
 * @brief Convert path to Windows representation.
 *
 * @param [in] path Path.
 *
 * @return Path in Windows representation, i.e., with backslashes (\) as path
 *         separators and drive specification. If the input path does not
 *         specify the drive, "C:/" is used as drive specification.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa posix()
 * @sa native()
 * @sa isvalid()
 */
std::string nt(const std::string& path);

/**
 * @brief Convert path to native representation.
 *
 * In general, Posix-style paths should be preferred as these in most cases also
 * work on Windows.
 *
 * @param [in] path Path.
 *
 * @return Path in native representation, i.e., the representation used by
 *         the underlying operating system.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa posix()
 * @sa nt()
 * @sa isvalid()
 */
std::string native(const std::string& path);

// ===========================================================================
// path components
// ===========================================================================

/**
 * @brief Split path into its components.
 *
 * This function splits a path into the path root, the path directory, the
 * path base name without extension, and the file path extension including
 * the leading period (.). Note that if a directory path is given as input
 * where the name of the last directory in this path includes a period (.),
 * this part is falsely interpreted as file name extension. This is because
 * this function does not query the file system whether a given path exists
 * or is a directory path.
 *
 * Examples:
@verbatim
   path                     | root   | dir           | fname       | ext
   -------------------------+--------+---------------+-------------+--------
   "/usr/bin"               | "/"    | "usr/"        | "bin"       | ""
   "/home/user/info.txt     | "/"    | "home/user/"  | "info"      | ".txt"
   "word.doc"               | "./"   | ""            | "word"      | ".doc"
   "../word.doc"            | "./"   | "../"         | "word"      | ".doc"
   "C:/WINDOWS/regedit.exe" | "C:/"  | "WINDOWS/"    | "regedit"   | ".exe"
   "d:\data"                | "D:/"  | ""            | "data"      | ""
   "/usr/local/"            | "/"    | "usr/local/"  | ""          | ""
@endverbatim
 *
 * On Windows, if the path starts with a slash (/) without leading drive letter
 * followed by a colon (:), the returned root component is set to "C:/".
 * On Posix, if the path starts with a drive specification, a slash (/) is
 * returned as root.
 *
 * The original path (note that the resulting string will, however, not
 * necessarily equal the input path string) can be reassembled as follows:
 *
 * @code
 * std::string path = root + dir + fname + ext;
 * @endcode
 *
 * @param [in]  path  Path.
 * @param [out] root  Root component of the given path. If the given path is
 *                    absolute, the root component is a slash (/) on
 *                    Posix systems or the drive letter followed by a
 *                    colon (:) and a trailing slash (/) on Windows. Otherwise,
 *                    the root component is the current working directory and
 *                    hence a period (.) followed by a slash (/) is returned.
 *                    If NULL is given, the root is not returned.
 * @param [out] dir   The directory part of the path including trailing slash
 *                    (/). Note that the directory component of the path
 *                    '/bla/bla/' is 'bla/bla/', while the directory component
 *                    of '/bla/bla' is 'bla/'. If NULL is given, the
 *                    directory component is not returned.
 * @param [out] fname The name of the directory or the name of the file
 *                    without extension. If NULL is given, the name is not
 *                    returned.
 * @param [out] ext   The file name extension. If NULL is given, the extension
 *                    is not returned.
 * @param [in]  exts  Set of additionally recognized extensions. Note that the
 *                    given set can contain extensions with dots (.) as part of
 *                    the extension, e.g., ".nii.gz". If given, the longest
 *                    extension from the given set which is equal to the end of
 *                    the file path is returned as extension. Otherwise, the part
 *                    after the last dot (including the dot) is considered to be
 *                    the file name extension.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa is_valid_path
 */
void split(const std::string&           path,
           std::string*                 root,
           std::string*                 dir,
           std::string*                 fname,
           std::string*                 ext,
           const std::set<std::string>* exts = NULL);

/**
 * @brief Get drive component of Windows path.
 *
 * @param [in] path Absolute path.
 *
 * @return Drive on Windows if @p path is absolute or empty string otherwise.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa rootname()
 */
std::string drive(const std::string& path);

/**
 * @brief Get file root.
 *
 * @param [in] path Path.
 *
 * @return Root component of file path.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa split()
 * @sa isvalid()
 */
std::string rootname(const std::string& path);

/**
 * @brief Get file directory.
 *
 * @param [in] path Path.
 *
 * @return Root component plus directory component of file path without
 *         leading slash.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa split()
 * @sa isvalid()
 */
std::string dirname(const std::string& path);

/**
 * @brief Get file name with extension.
 *
 * @param [in] path Path.
 *
 * @return File name without directory.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa split()
 * @sa isvalid()
 */
std::string basename(const std::string& path);

/**
 * @brief Get file name without extension.
 *
 * @param [in] path Path.
 * @param [in] exts Set of additionally recognized extensions. Note that the
 *                  given set can contain extensions with dots (.) as part of
 *                  the extension, e.g., ".nii.gz". If given, the longest
 *                  extension from the given set which is equal to the end of
 *                  the file path is removed. Otherwise, the part after the
 *                  last dot (including the dot) is removed.
 *
 * @return File name without directory and extension.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa split()
 * @sa isvalid()
 */
std::string filename(const std::string&           path,
                     const std::set<std::string>* exts = NULL);

/**
 * @brief Get file name extension.
 *
 * @param [in] path Path.
 * @param [in] exts Set of recognized extensions. Note that the given set
 *                  can contain extensions with dots (.) as part of the
 *                  extension, e.g., ".nii.gz". If NULL or an empty set is
 *                  given, the part after the last dot (including the dot)
 *                  is considered to be the file name extension. Otherwise,
 *                  the longest extension from the given set which is equal
 *                  to the end of the file path is returned.
 *
 * @return File name extension including leading period (.).
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa split()
 * @sa isvalid()
 */
std::string fileext(const std::string&           path,
                    const std::set<std::string>* exts = NULL);

/**
 * @brief Test whether a given path has an extension.
 *
 * @param [in] path Path.
 * @param [in] exts Set of recognized extensions or NULL.
 *
 * @return Whether the given path has a file name extension. If @p exts is not
 *         NULL, this function returns true only if the file name ends in one
 *         of the specified extensions (including dot if required). Otherwise,
 *         it only checks if the path has a dot (.) in the file name.
 */
bool hasext(const std::string& path, const std::set<std::string>* exts = NULL);

// ===========================================================================
// absolute / relative paths
// ===========================================================================

/**
 * @brief Test whether a given path is absolute.
 *
 * @param path [in] Absolute or relative path.
 *
 * @return Whether the given path is absolute.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa isvalid()
 */
bool isabs(const std::string& path);

/**
 * @brief Test whether a given path is relative.
 *
 * @param path [in] Absolute or relative path.
 *
 * @return Whether the given path is relative.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa is_valid_path()
 */
bool isrel(const std::string& path);

/**
 * @brief Get absolute path given a relative path.
 *
 * This function converts a relative path to an absolute path. If the given
 * path is already absolute, this path is passed through unchanged.
 *
 * @param [in] path Absolute or relative path.
 *
 * @return Absolute path.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa isvalid()
 */
std::string abspath(const std::string& path);

/**
 * @brief Get absolute path given a relative path and a base path.
 *
 * This function converts a relative path to an absolute path. If the given
 * path is already absolute, this path is passed through unchanged.
 *
 * @param [in] base Base path used for relative path.
 * @param [in] path Absolute or relative path.
 *
 * @return Absolute path.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa isvalid()
 */
std::string abspath(const std::string& base, const std::string& path);

/**
 * @brief Get path relative to current working directory.
 *
 * This function converts a path to a path relative to a the current working
 * directory. If the input path is relative, it is first made absolute using
 * the current working directory and then made relative to the given base path.
 *
 * @param [in] path Absolute or relative path.
 *
 * @return Path relative to current working directory.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa isvalid()
 */
std::string relpath(const std::string& path);

/**
 * @brief Get path relative to given absolute path.
 *
 * This function converts a path to a path relative to a given base path.
 * If the input path is relative, it is first made absolute using the
 * current working directory and then made relative to the given base path.
 *
 * @param [in] base Base path used for relative path.
 * @param [in] path Absolute or relative path.
 *
 * @return Path relative to base path.
 *
 * @throw std::invalid_argument if the given path is not valid.
 *
 * @sa isvalid()
 */
std::string relpath(const std::string& base, const std::string& path);

/**
 * @brief Get canonical file path.
 *
 * This function resolves symbolic links and returns a cleaned path.
 *
 * @param [in] path Path.
 *
 * @return Canonical file path without duplicate slashes, ".", "..",
 *         and symbolic links.
 *
 * @sa os::readlink()
 * @sa normpath()
 */
std::string realpath(const std::string& path);

/**
 * @brief Join two paths, e.g., base path and relative path.
 *
 * This function joins two paths. If the second path is an absolute path,
 * this cleaned absolute path is returned. Otherwise, the base path is
 * prepended to the relative path and the resulting relative or absolute
 * path returned.
 *
 * @param [in] base Base path.
 * @param [in] path Relative or absolute path.
 *
 * @return Joined path.
 */
std::string join(const std::string& base, const std::string& path);

// ===========================================================================
// file / directory checks
// ===========================================================================

/**
 * @brief Test the existance of a file or directory.
 *
 * @param [in] path File or directory path.
 *
 * @return Whether the given file or directory is an exists.
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

} // namespace sbia


/// @}
// Doxygen group

#endif // _SBIA_BASIS_OS_H
