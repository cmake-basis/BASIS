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
 * @brief Get canonical path of directory containing executable file.
 *
 * @return Canonical path of directory containing executable file.
 *
 * @sa exepath()
 * @sa exename()
 */
std::string exedir();

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


} // namespace os

} // namespace basis

} // namespace sbia


/// @}
// Doxygen group

#endif // _SBIA_BASIS_OS_H
