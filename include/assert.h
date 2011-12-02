/**
 * @file  assert.h
 * @brief Defines macro used for assertions with custom messages.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup CppUtilities
 */

#pragma once
#ifndef SBIA_BASIS_ASSERT_H_
#define SBIA_BASIS_ASSERT_H_


#include <iostream> // for the output of the error message
#include <cstdlib>  // to terminate the program execution


/**
 * @macro ASSERT
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
            std::cerr << "Assertion `" #condition "` failed in " << __FILE__ \
                      << " line " << __LINE__ << ": " << message << std::endl; \
            std::exit(EXIT_FAILURE); \
        } \
    } while (false)
#else
#   define ASSERT(condition, message) do { } while (false)
#endif


#endif // SBIA_BASIS_ASSERT_H_
