/**
 * @file  except.h
 * @brief Basic exceptions and related helper macros.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _BASIS_EXCEPT_H
#define _BASIS_EXCEPT_H


#include <sstream>              // used to compose exception messages
#include <stdexcept>            // use standard STL exceptions where possible
#include <string>               // used to store error messages

#include "tclap/ArgException.h" // command-line parsing


namespace basis {


// ===========================================================================
// convenience macros
// ===========================================================================

/**
 * @brief Throw exception with given message.
 *
 * Example:
 * @code
 * void func(int i) {
 *     if (i < 0) BASIS_THROW(std::invalid_argument, "Argument i (= " << i << ") must be positive");
 * }
 * @endcode
 *
 * @param [in] type The type of the exception. Note that this exception
 *                  type has to implement a constructor with one std::string
 *                  as argument, the exception message.
 * @param [in] msg  The exception message. The given argument is streamed
 *                  into a std::ostringstream.
 */
#define BASIS_THROW(type, msg) \
    { \
       ::std::ostringstream oss; \
       oss << msg; \
       throw type(oss.str().c_str()); \
    }

// ===========================================================================
// exceptions
// ===========================================================================

/// @brief Exception thrown by command-line parsing library.
typedef TCLAP::ArgException ArgException;

/// @brief Exception thrown by command-line parsing library to indicate that
///        program should exit with the given exit code.
typedef TCLAP::ExitException ExitException;

/// @brief Exception thrown on command-line argument parsing error.
typedef TCLAP::ArgParseException ArgParseException;

/// @brief Exception thrown on command-line parsing error.
typedef TCLAP::CmdLineParseException CmdLineParseException;

/// @brief Exception thrown when command-line specification is wrong.
typedef TCLAP::SpecificationException CmdLineException;


} // namespace basis


#endif // _BASIS_EXCEPT_H
