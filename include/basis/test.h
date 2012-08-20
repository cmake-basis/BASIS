/**
 * @file  test.h
 * @brief Main include file of C++ unit testing framework.
 *
 * This file should be included by implementations of unit tests.
 * Note that currently we are simply using Google Test and Google Mock.
 * Likely, this will not change soon. However, we use this header file
 * to be prepared for this case. The implementation of the functions
 * and macros provided by the underlying testing frameworks could then
 * potentially be replaced by another implementations if desired.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup CxxTesting
 */

#pragma once
#ifndef _BASIS_TEST_H
#define _BASIS_TEST_H


#include <basis/config.h>


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


#include <basis/gtest/gtest.h>
#include <basis/gmock/gmock.h>


#endif // _BASIS_TEST_H
