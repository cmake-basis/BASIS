/**
 * @file  assert.h
 * @brief Defines macros used for assertions.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
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
