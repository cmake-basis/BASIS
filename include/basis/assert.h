/**
 * @file  assert.h
 * @brief Defines macros used for assertions.
 *
 * Copyright (c) 2011-2012 University of Pennsylvania. <br />
 * Copyright (c) 2013-2014 Andreas Schuh.              <br />
 * All rights reserved.                                <br />
 *
 * See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
 * or COPYING file for license information.
 *
 * Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
 *          report issues at https://github.com/schuhschuh/cmake-basis/issues
 */

#pragma once
#ifndef _BASIS_ASSERT_H
#define _BASIS_ASSERT_H


#include <iostream> // for the output of the error message
#include <cstdlib>  // to terminate the program execution


#ifdef assert
#  undef assert
#endif
#ifdef ASSERT
#  undef ASSERT
#endif


/**
 * @def   assert
 * @brief Assertion without custom message.
 *
 * The assertion is only checked if NDEBUG is defined.
 *
 * Example:
 * @code
 * assert(x > 0);
 * @endcode
 */
#ifndef NDEBUG
#   define assert(condition) \
    do { \
        if (!(condition)) { \
            ::std::cerr << "Assertion `" #condition "` failed in " << __FILE__ \
                        << " line " << __LINE__ << ::std::endl; \
            ::std::exit(EXIT_FAILURE); \
        } \
    } while (false)
#else
#   define assert(condition) do { } while (false)
#endif

/**
 * @def   ASSERT
 * @brief Assertion with custom message.
 *
 * The assertion is only checked if NDEBUG is defined.
 *
 * Example:
 * @code
 * ASSERT(x > 0, "Actual value of x is " << x);
 * @endcode
 *
 * @sa http://stackoverflow.com/questions/3767869/adding-message-to-assert
 */
#ifndef NDEBUG
#   define ASSERT(condition, message) \
    do { \
        if (!(condition)) { \
            ::std::cerr << "Assertion `" #condition "` failed in " << __FILE__ \
                        << " line " << __LINE__ << ": " << message << ::std::endl; \
            ::std::exit(EXIT_FAILURE); \
        } \
    } while (false)
#else
#   define ASSERT(condition, message) do { } while (false)
#endif


#endif // _BASIS_ASSERT_H
