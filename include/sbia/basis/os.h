/**
 * @file  os.h
 * @brief Operating system dependent functions.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _SBIA_BASIS_OS_H
#define _SBIA_BASIS_OS_H


#include <string>

#include "os/path.h"


/// @addtogroup BasisCxxUtilities
/// @{


namespace sbia
{

namespace basis
{

namespace os
{


/**
 * @brief Get absolute path of the (current) working directory.
 *
 * @return Absolute path of working directory or empty string on error.
 */
std::string getcwd();

/**
 * @brief Get canonical path of executable file.
 *
 * @return Canonical path of executable file or empty string on error.
 *
 * @sa exedir()
 * @sa exename()
 */
std::string exepath();

/**
 * @brief Get name of executable.
 *
 * @note The name of the executable may or may not include the file name
 *       extension depending on the executable type and operating system.
 *       Hence, this function is neither an equivalent to
 *       path::basename(exepath()) nor path::filename(exepath()).
 *       In particular, on Windows, the .exe and .com extension is not
 *       included in the returned executable name.
 *
 * @return Name of the executable derived from the executable's file path
 *         or empty string on error.
 *
 * @sa exepath()
 * @sa exedir()
 */
std::string exename();

/**
 * @brief Get canonical path of directory containing executable file.
 *
 * @return Canonical path of directory containing executable file.
 *
 * @sa exepath()
 * @sa exename()
 */
std::string exedir();

/**
 * @brief Read value of symbolic link.
 *
 * @param [in]  link  Path of symbolic link.
 * @param [out] value Value of symbolic link.
 *
 * @return Whether the given path is a symbolic link and its value could be
 *         read and returned successfully.
 *
 * @sa realpath()
 */
bool readlink(const std::string& link, std::string& value);

/**
 * @brief Make directory.
 *
 * @note The parent directory must exist already. See makedirs() for a function
 *       that also creates the parent directories if none-existent.
 *
 * @param path Path of the directory.
 *
 * @returns Whether the directory was created successfully.
 *          Note that on Posix, the created directory will have mode 0755.
 *          On Windows, the default security descriptor is passed on to the
 *          CreateDirectory() function.
 *
 * @sa makedirs()
 */
bool mkdir(const std::string& path);

/**
 * @brief Make directory including parent directories if required.
 *
 * @param path Path of the directory.
 *
 * @returns Whether the directory was created successfully.
 *          Note that on Posix, the created directories will have mode 0755.
 *          On Windows, the default security descriptor is passed on to the
 *          CreateDirectory() function.
 */
bool makedirs(const std::string& path);

/**
 * @brief Remove empty directory.
 *
 * This function removes an empty directory. If the directory is not empty,
 * it will fail. See rmtree() for a function that also removes the files and
 * recursively the directories within the specified directory.
 *
 * @param path Path of the directory.
 *
 * @returns Whether the directory was removed successfully.
 *
 * @sa rmtree()
 */
bool rmdir(const std::string& path);

/**
 * @brief Remove whole directory tree.
 *
 * @param path Path of the directory.
 *
 * @returns Whether the directory was removed successfully.
 */
bool rmtree(const std::string& path);

/**
 * @brief Remove files and directories from directory.
 *
 * @param path Path of the directory.
 *
 * @returns Whether the directory was cleared successfully, i.e., leaving
 *          the directory @p path empty.
 */
bool emptydir(const std::string& path);


} // namespace os

} // namespace basis

} // namespace sbia


/// @}
// Doxygen group

#endif // _SBIA_BASIS_OS_H
