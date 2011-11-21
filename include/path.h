/**
 * @file  path.h
 * @brief Basic file path manipulation and related system functions.
 *
 * The implementations provided by this module are related to the manipulation
 * of file paths. These implementations are meant to be simple and therefore
 * focus on non-multibyte path strings only.
 *
 * Note that in order to improve portability and because of the main focus
 * on Unix-based systems, slashes (/) are used as path separators. A function
 * to convert a given path to its native representation is provided, however.
 * Further, only relative paths and absolute paths which start with a slash (/)
 * on Unix-based systems or a slash (/), backslash (\), or drive specification
 * on Windows are supported. Hence, UNC paths, the inclusion of a hostname
 * in the path,... are not supported. Also, masking of slashes or backslashes
 * is not supported either. This is just a simple implementation that should
 * work for most of the use cases in software written at SBIA. If not, please
 * contact the maintainer of the BASIS package.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup CppUtilities
 */

#pragma once
#ifndef SBIA_BASIS_PATH_H_
#define SBIA_BASIS_PATH_H_


#include <string>
#include <set>

#include <sbia/basis/config.h>


SBIA_BASIS_NAMESPACE_BEGIN


// ===========================================================================
// constants
// ===========================================================================

/**
 * @brief Native path separator, i.e., either slash (/) or backslash (\).
 */
extern const char cPathSeparator;

/**
 * @brief Native path separator as string, i.e., either slash (/) or backslash (\).
 */
extern const std::string cPathSeparatorStr;

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
 */
bool is_valid_path(const std::string& path, bool strict = true);

/**
 * @brief Clean path, i.e., remove occurences of "./", duplicate slashes,...
 *
 * This function removes single periods (.) enclosed by slashes or backslashes,
 * duplicate slashes (/) or backslashes (\), and further tries to reduce the
 * number of parent directory references.
 *
 * For example, "../bla//.//.\bla\\\\\bla/../.." is convert to "../bla".
 *
 * @param [in] path Path.
 *
 * @return Cleaned path.
 */
std::string clean_path(const std::string& path);

/**
 * @brief Convert path to Unix representation.
 *
 * @sa to_windows_path()
 * @sa to_native_path()
 * @sa is_valid_path()
 *
 * @param [in] path  Path.
 * @param [in] drive Whether the drive specification should be preserved.
 *
 * @return Path in Unix representation, i.e., with slashes (/) as path
 *         separators and without drive specification if the drive parameter
 *         is set to false.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string to_unix_path(const std::string& path, bool drive = false);

/**
 * @brief Convert path to Windows representation.
 *
 * @sa to_unix_path()
 * @sa to_native_path()
 * @sa is_valid_path()
 *
 * @param [in] path Path.
 *
 * @return Path in Windows representation, i.e., with backslashes (\) as path
 *         separators and drive specification. If the input path does not
 *         specify the drive, "C:/" is used as drive specification.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string to_windows_path(const std::string& path);

/**
 * @brief Convert path to native representation.
 *
 * In general, Unix-style paths should be preferred as these in most cases also
 * work on Windows.
 *
 * @sa to_unix_path()
 * @sa to_windows_path()
 * @sa is_valid_path()
 *
 * @param [in] path Path.
 *
 * @return Path in native representation, i.e., the representation used by
 *         the underlying operating system.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string to_native_path(const std::string& path);

// ===========================================================================
// working directory
// ===========================================================================

/**
 * @brief Get absolute path of the (current) working directory.
 *
 * @return Absolute path of working directory or empty string on error.
 */
std::string get_working_directory();

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
 * On Unix, if the path starts with a drive specification, a slash (/) is
 * returned as root.
 *
 * The original path (note that the resulting string will, however, not
 * necessarily equal the input path string) can be reassembled as follows:
 *
 * @code
 * std::string path = root + dir + fname + ext;
 * @endcode
 *
 * @sa is_valid_path
 *
 * @param [in]  path  Path.
 * @param [out] root  Root component of the given path. If the given path is
 *                    absolute, the root component is a slash (/) on
 *                    Unix-based systems or the drive letter followed by a
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
 * @param [in]  exts  Set of recognized extensions. Note that the given set
 *                    can contain extensions with dots (.) as part of the
 *                    extension, e.g., ".nii.gz". If NULL or an empty set is
 *                    given, the part after the last dot (including the dot)
 *                    is considered to be the file name extension. Otherwise,
 *                    the longest extension from the given set which is equal
 *                    to the end of the file path is returned as extension.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
void split_path(const std::string&           path,
                std::string*                 root,
                std::string*                 dir,
                std::string*                 fname,
                std::string*                 ext,
                const std::set<std::string>* exts = NULL);

/**
 * @brief Get file root.
 *
 * @sa split_path()
 * @sa is_valid_path()
 *
 * @param [in] path Path.
 *
 * @return Root component of file path.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string get_file_root(const std::string& path);

/**
 * @brief Get file directory.
 *
 * @sa split_path()
 * @sa is_valid_path()
 *
 * @param [in] path Path.
 *
 * @return Root component plus directory component of file path without
 *         leading slash.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string get_file_directory(const std::string& path);

/**
 * @brief Get file name with extension.
 *
 * @sa split_path()
 * @sa is_valid_path()
 *
 * @param [in] path Path.
 *
 * @return File name without directory.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string get_file_name(const std::string& path);

/**
 * @brief Get file name without extension.
 *
 * @sa split_path()
 * @sa is_valid_path()
 *
 * @param [in] path Path.
 * @param [in] exts Set of recognized extensions. Note that the given set
 *                  can contain extensions with dots (.) as part of the
 *                  extension, e.g., ".nii.gz". If NULL or an empty set is
 *                  given, the part after the last dot (including the dot)
 *                  is considered to be the file name extension. Otherwise,
 *                  the longest extension from the given set which is equal
 *                  to the end of the file path is removed.
 *
 * @return File name without directory and extension.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string get_file_name_without_extension(const std::string&           path,
                                            const std::set<std::string>* exts = NULL);

/**
 * @brief Get file name extension.
 *
 * @sa split_path()
 * @sa is_valid_path()
 *
 * @param [in] path Path.
 * @param [in] exts Set of recognized extensions. Note that the given set
 *                  can contain extensions with dots (.) as part of the
 *                  extension, e.g., ".nii.gz". If NULL or an empty set is
 *                  given, the part after the last dot (including the dot)
 *                  is considered to be the file name extension. Otherwise,
 *                  the longest extension from the given set which is equal
 *                  to the end of the file path is returned as extension.
 *
 * @return File name extension including leading period (.).
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string get_file_name_extension(const std::string&           path,
                                    const std::set<std::string>* exts = NULL);

// ===========================================================================
// absolute / relative paths
// ===========================================================================

/**
 * @brief Test whether a given path is absolute.
 *
 * @sa is_valid_path()
 *
 * @param path [in] Absolute or relative path.
 *
 * @return Whether the given path is absolute.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
bool is_absolute(const std::string& path);

/**
 * @brief Test whether a given path is relative.
 *
 * @sa is_valid_path()
 *
 * @param path [in] Absolute or relative path.
 *
 * @return Whether the given path is relative.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
bool is_relative(const std::string& path);

/**
 * @brief Get absolute path given a relative path.
 *
 * This function converts a relative path to an absolute path. If the given
 * path is already absolute, this path is passed through unchanged.
 *
 * @sa is_valid_path()
 *
 * @param [in] path Absolute or relative path.
 *
 * @return Absolute path.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string to_absolute_path(const std::string& path);

/**
 * @brief Get absolute path given a relative path and a base path.
 *
 * This function converts a relative path to an absolute path. If the given
 * path is already absolute, this path is passed through unchanged.
 *
 * @sa is_valid_path()
 *
 * @param [in] base Base path used for relative path.
 * @param [in] path Absolute or relative path.
 *
 * @return Absolute path.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string to_absolute_path(const std::string& base, const std::string& path);

/**
 * @brief Get path relative to current working directory.
 *
 * This function converts a path to a path relative to a the current working
 * directory. If the input path is relative, it is first made absolute using
 * the current working directory and then made relative to the given base path.
 *
 * @sa is_valid_path()
 *
 * @param [in] path Absolute or relative path.
 *
 * @return Path relative to current working directory.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string to_relative_path(const std::string& path);

/**
 * @brief Get path relative to given absolute path.
 *
 * This function converts a path to a path relative to a given base path.
 * If the input path is relative, it is first made absolute using the
 * current working directory and then made relative to the given base path.
 *
 * @sa is_valid_path()
 *
 * @param [in] base Base path used for relative path.
 * @param [in] path Absolute or relative path.
 *
 * @return Path relative to base path.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
std::string to_relative_path(const std::string& base, const std::string& path);

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
std::string join_paths(const std::string& base, const std::string& path);

// ===========================================================================
// symbolic links
// ===========================================================================

/**
 * @brief Whether a given path is a symbolic link.
 *
 * @sa is_valid_path()
 *
 * @param [in] path Path.
 *
 * @return Whether the given path denotes a symbolic link.
 *
 * @throw std::invalid_argument if the given path is not valid.
 */
bool is_symlink(const std::string& path);

/**
 * @brief Read value of symbolic link.
 *
 * @param [in]  link  Path of symbolic link.
 * @param [out] value Value of symbolic link.
 *
 * @return Whether the given path is a symbolic link and its value could be
 *         read and returned successfully.
 */
bool read_symlink(const std::string& link, std::string& value);

/**
 * @brief Get canonical file path.
 *
 * This function resolves symbolic links and returns a cleaned path.
 *
 * @sa read_symlink()
 * @sa clean_path()
 *
 * @param [in] path Path.
 *
 * @return Canonical file path without duplicate slashes, ".", "..", and
 *         symbolic links.
 */
std::string get_real_path(const std::string& path);

// ===========================================================================
// executable file
// ===========================================================================

/**
 * @brief Get canonical path of executable file.
 *
 * @sa get_executable_directory()
 * @sa get_executable_name()
 *
 * @return Canonical path of executable file or empty string on error.
 */
std::string get_executable_path();

/**
 * @brief Get canonical path of directory containing executable file.
 *
 * @sa get_executable_path()
 * @sa get_executable_name()
 *
 * @return Canonical path of directory containing executable file.
 */
std::string get_executable_directory();

/**
 * @brief Get name of executable.
 *
 * @note The name of the executable may or may not include the file name
 *       extension depending on the executable type and operating system.
 *       Hence, this function is neither an equivalent to
 *       get_file_name(get_executable_path()) nor
 *       get_file_name_without_extension(get_executable_path()).
 *
 * @sa get_executable_path()
 * @sa get_executable_directory()
 *
 * @return Name of the executable derived from the executable's file path
 *         or empty string on error.
 */
std::string get_executable_name();


SBIA_BASIS_NAMESPACE_END


#endif // SBIA_BASIS_PATH_H_

