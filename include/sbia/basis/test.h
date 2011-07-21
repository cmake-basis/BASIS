/*!
 * \file  test.h
 * \brief Main include file for BASIS C++ unit tests.
 *
 * This file should be included by implementations of unit tests.
 * Note that currently, we are simply using Google Test and Google Mock.
 * Likely, this will not change in the future. However, to be prepared,
 * we use this header file. The implementation of the functions and macros
 * provided by the underlying testing frameworks could then potentially
 * be replaced by own implementations.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef SBIA_BASIS_TEST_H_
#define SBIA_BASIS_TEST_H_


#include "config.h"

// let Google use their own tr1/tuple implementation if the compiler
// does not support it; note that HAVE_TR1_TUPLE is set in config.h
#ifdef GTEST_USE_OWN_TR1_TUPLE
#  undef GTEST_USE_OWN_TR1_TUPLE
#endif
#if HAVE_TR1_TUPLE
#  define GTEST_USE_OWN_TR1_TUPLE 0
#else
#  define GTEST_USE_OWN_TR1_TUPLE 1
#endif

// disable use of pthreads library if not available
#ifdef GTEST_HAS_PTHREAD
#  undef GTEST_HAS_PTHREAD
#endif
#if HAVE_PTHREAD
#  define GTEST_HAS_PTHREAD 1
#else
#  define GTEST_HAS_PTHREAD 0
#endif

#include "../gtest/gtest.h"
#include "../gmock/gmock.h"


#endif // SBIA_BASIS_TEST_H_

