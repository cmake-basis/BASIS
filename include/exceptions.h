/**
 * @file  exceptions.h
 * @brief Common exceptions and helper macros.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup CppUtilities
 */

#pragma once
#ifndef SBIA_BASIS_EXCEPTIONS_H_
#define SBIA_BASIS_EXCEPTIONS_H_


#include <sstream>   // used to compose exception messages
#include <stdexcept> // use standard STL exceptions where possible
#include <string>    // used to store error messages

#include <sbia/basis/config.h>


SBIA_BASIS_NAMESPACE_BEGIN


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
       std::ostringstream oss; \
       oss << msg; \
       throw type(oss.str()); \
    }

// ===========================================================================
// exceptions
// ===========================================================================

/**
 * @class SubprocessException
 * @brief Exception type thrown by execute_process().
 */
class SubprocessException : public std::exception
{
public:
    SubprocessException(const std::string& msg) : msg_(msg) {}
    ~SubprocessException() throw () {}

private:
    std::string msg_; ///< Error message.
}; // class SubprocessException


SBIA_BASIS_NAMESPACE_END


#endif // SBIA_BASIS_EXCEPTIONS_H_

