/*!
 * \file  exceptions.h
 * \brief Common exceptions and helper macros.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef SBIA_BASIS_EXCEPTIONS_H_
#define SBIA_BASIS_EXCEPTIONS_H_


#include <sstream>   // used to compose exception messages
#include <stdexcept> // use standard STL exceptions where possible

#include "config.h"  // the BASIS configuration


SBIA_BASIS_NAMESPACE_BEGIN


/*!
 * \brief Throw exception with given message.
 *
 * Example:
 * \code
 * void Func (int i) {
 *     if (i < 0) BASIS_THROW (std::invalid_argument, "Argument i (= " << i << ") must be positive");
 * }
 * \endcode
 *
 * \param [in] type The type of the exception. Note that this exception
 *                  type has to implement a constructor with one std::string
 *                  as argument, the exception message.
 * \param [in] msg  The exception message. The given argument is streamed
 *                  into a std::ostringstream.
 */
#define BASIS_THROW( type, msg ) \
    { \
       std::ostringstream oss; \
       oss << msg; \
       throw type (oss.str ()); \
    }


SBIA_BASIS_NAMESPACE_END


#endif // SBIA_BASIS_EXCEPTIONS_H_

