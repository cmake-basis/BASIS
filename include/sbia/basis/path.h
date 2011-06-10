/*!
 * \file  path.h
 * \brief Basic file path manipulation and related system functions.
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
 * See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
 *
 * Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
 */

#pragma once
#ifndef SBIA_BASIS_PATH_H_
#define SBIA_BASIS_PATH_H_


#include <string>

#include "config.h"


SBIA_BASIS_NAMESPACE_BEGIN


//////////////////////////////////////////////////////////////////////////////
// constants
//////////////////////////////////////////////////////////////////////////////

/*!
 * \brief Native path separator, i.e., either slash (/) or backslash (\).
 */
extern const char pathSeparator;

/*!
 * \brief Native path separator, i.e., either slash (/) or backslash (\).
 */
extern const std::string pathSeparatorStr;

//////////////////////////////////////////////////////////////////////////////
// path representations
//////////////////////////////////////////////////////////////////////////////

/*!
 * \brief Clean path, i.e., remove occurences of "./", duplicate slashes,...
 *
 * This function removes single periods (.) enclosed by slashes or backslashes,
 * duplicate slashes (/) or backslashes (\), and further tries to reduce the
 * number of parent directory references.
 *
 * For example, "../bla//.//.\bla\\\\\bla/../.." is convert to "../bla".
 *
 * \param [in] path Path.
 *
 * \return Cleaned path.
 */
std::string cleanPath (const std::string &path);

/*!
 * \brief Convert path to Unix representation.
 *
 * \sa toWindowsPath, toNativePath
 *
 * \param [in] path  Path.
 * \param [in] drive Whether the drive specification should be preserved.
 *
 * \return Path in Unix representation, i.e., with slashes (/) as path
 *         separators and without drive specification if the drive parameter
 *         is set to false.
 */
std::string toUnixPath (const std::string &path, bool drive = false);

/*!
 * \brief Convert path to Windows representation.
 *
 * \sa toUnixPath, toNativePath
 *
 * \param [in] path Path.
 *
 * \return Path in Windows representation, i.e., with backslashes (\) as path
 *         separators and drive specification. If the input path does not
 *         specify the drive, "C:/" is used as drive specification.
 */
std::string toWindowsPath (const std::string &path);

/*!
 * \brief Convert path to native representation.
 *
 * In general, Unix-style paths should be preferred as these in most cases also
 * work on Windows.
 *
 * \sa toUnixPath, toWindowsPath
 *
 * \param [in] path Path.
 *
 * \return Path in native representation, i.e., the representation used by
 *         the underlying operating system.
 */
std::string toNativePath (const std::string &path);

//////////////////////////////////////////////////////////////////////////////
// working directory
//////////////////////////////////////////////////////////////////////////////

/*!
 * \brief Get absolute path of the (current) working directory.
 *
 * \return Absolute path of working directory or empty string on error.
 */
std::string getWorkingDirectory ();

//////////////////////////////////////////////////////////////////////////////
// path components
//////////////////////////////////////////////////////////////////////////////

/*!
 * \brief Split path into its components.
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
 *
 * path                     | root   | dir           | fname       | ext
 * -------------------------+--------+---------------+-------------+--------
 * "/usr/bin"               | "/"    | "usr/"        | "bin"       | ""
 * "/home/user/info.txt     | "/"    | "home/user/"  | "info"      | ".txt"
 * "word.doc"               | "./"   | ""            | "word"      | ".doc"
 * "../word.doc"            | "./"   | "../"         | "word"      | ".doc"
 * "C:/WINDOWS/regedit.exe" | "C:/"  | "WINDOWS/"    | "regedit"   | ".exe"
 * "d:\data"                | "D:/"  | ""            | "data"      | ""
 * "/usr/local/"            | "/"    | "usr/local/"  | ""          | ""
 *
 * On Windows, if the path starts with a slash (/) without leading drive letter
 * followed by a colon (:), the returned root component is set to "C:/".
 *
 * The original path (note that the resulting string will, however, not
 * necessarily equal the input path string) can be reassembled as follows:
 *
 * \code
 * std::string path = root + dir + fname + ext;
 * \endcode
 *
 * \param [in]  path  Path.
 * \param [out] root  Root component of the given path. If the given path is
 *                    absolute, the root component is a slash (/) on
 *                    Unix-based systems or the drive letter followed by a
 *                    colon (:) and a trailing slash (/) on Windows. Otherwise,
 *                    the root component is the current working directory and
 *                    hence a period (.) followed by a slash (/) is returned.
 * \param [out] dir   The directory part of the path including trailing slash
 *                    (/). Note that the directory component of the path
 *                    '/bla/bla/' is 'bla/bla/', while the directory component
 *                    of '/bla/bla' is 'bla/'.
 * \param [out] fname The name of the directory or the name of the file
 *                    without extension.
 * \param [out] ext   The file name extension.
 */
void splitPath (const std::string &path,
                std::string       &root,
                std::string       &dir,
                std::string       &fname,
                std::string       &ext);

/*!
 * \brief Get file root.
 *
 * \sa splitPath
 *
 * \param [in] path Path.
 *
 * \return Root component of file path (see splitPath ()).
 */
std::string getFileRoot (const std::string &path);

/*!
 * \brief Get file directory.
 *
 * \sa splitPath
 *
 * \param [in] path Path.
 *
 * \return Root component plus directory component of file path without
 *         leading slash (see splitPath ()).
 */
std::string getFileDirectory (const std::string &path);

/*!
 * \brief Get file name with extension.
 *
 * \sa splitPath
 *
 * \param [in] path Path.
 *
 * \return File name without directory (see splitPath ()).
 */
std::string getFileName (const std::string &path);

/*!
 * \brief Get file name without extension.
 *
 * \sa splitPath
 *
 * \param [in] path Path.
 *
 * \return File name without directory and extension (see splitPath ()).
 */
std::string getFileNameWithoutExtension (const std::string &path);

/*!
 * \brief Get file name extension.
 *
 * \sa splitPath
 *
 * \param [in] path Path.
 *
 * \return File name extension including leading period (.) (see splitPath ()).
 */
std::string getFileNameExtension (const std::string &path);

//////////////////////////////////////////////////////////////////////////////
// absolute / relative paths
//////////////////////////////////////////////////////////////////////////////

/*!
 * \brief Test whether a given path is absolute.
 *
 * \param path [in] Absolute or relative path.
 *
 * \return Whether the given path is absolute.
 */
bool isAbsolutePath (const std::string &path);

/*!
 * \brief Test whether a given path is relative.
 *
 * \param path [in] Absolute or relative path.
 *
 * \return Whether the given path is relative.
 */
bool isRelativePath (const std::string &path);

/*!
 * \brief Get absolute path given a relative path.
 *
 * This function converts a relative path to an absolute path. If the given
 * path is already absolute, this path is passed through unchanged.
 *
 * \param [in] path Absolute or relative path.
 * \param [in] base Base
 *
 * \return Absolute path.
 */
std::string toAbsolutePath (const std::string &path);

/*!
 * \brief Get absolute path given a relative path and a base path.
 *
 * This function converts a relative path to an absolute path. If the given
 * path is already absolute, this path is passed through unchanged.
 *
 * \param [in] base Base path used for relative path.
 * \param [in] path Absolute or relative path.
 *
 * \return Absolute path.
 */
std::string toAbsolutePath (const std::string &base, const std::string &path);

/*!
 * \brief Get path relative to current working directory.
 *
 * This function converts a path to a path relative to a the current working
 * directory. If the input path is relative, it is first made absolute using
 * the current working directory and then made relative to the given base path.
 *
 * \param [in] path Absolute or relative path.
 *
 * \return Path relative to current working directory.
 */
std::string toRelativePath (const std::string &path);

/*!
 * \brief Get path relative to given absolute path.
 *
 * This function converts a path to a path relative to a given base path.
 * If the input path is relative, it is first made absolute using the
 * current working directory and then made relative to the given base path.
 *
 * \param [in] path Absolute or relative path.
 * \param [in] base Base path used for relative path.
 *
 * \return Path relative to base path.
 */
std::string toRelativePath (const std::string &base, const std::string &path);

//////////////////////////////////////////////////////////////////////////////
// symbolic links
//////////////////////////////////////////////////////////////////////////////

/*!
 * \brief Whether a given path is a symbolic link.
 *
 * \param [in] path Path.
 *
 * \return Whether the given path denotes a symbolic link.
 */
bool isSymbolicLink (const std::string &path);

/*!
 * \brief Read value of symbolic link.
 *
 * \param [in]  link  Path of symbolic link.
 * \param [out] vlaue Value of symbolic link.
 *
 * \return Whether the given path is a symbolic link and its value could be
 *         read and returned successfully.
 */
bool readSymbolicLink (const std::string &link, std::string &value);

/*!
 * \brief Get canonical file path.
 *
 * This function resolves symbolic links and returns a cleaned path.
 *
 * \sa readSymbolicLink, cleanPath
 *
 * \param [in] path Path.
 *
 * \return Canonical file path without duplicate slashes, ".", "..", and
 *         symbolic links.
 */
std::string getRealPath (const std::string &path);

//////////////////////////////////////////////////////////////////////////////
// executable file
//////////////////////////////////////////////////////////////////////////////

/*!
 * \brief Get absolute path of executable file.
 *
 * \return Canonical path of executable file or empty string on error.
 */
std::string getExecutablePath ();

/*!
 * \brief Get name of executable.
 *
 * \note The name of the executable may or may not include the file name
 *       extension depending on the executable type and operating system.
 *       Hence, this function is neither an equivalent to
 *       getFileName (getExecutablePath ()) nor
 *       getFileNameWithoutExtension (getExecutablePath ()).
 *
 * \return Name of the executable derived from the executable's file path
 *         or empty string on error.
 */
std::string getExecutableName ();


SBIA_BASIS_NAMESPACE_END


#endif // SBIA_BASIS_PATH_H_

