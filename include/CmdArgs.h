/**
 * @file  CmdArgs.h
 * @brief Definition of commonly used command-line arguments.
 *
 * This include file mainly redefines the TCLAP command-line argument types
 * in the namespace of BASIS itself. It only defines commonly used argument
 * types without template parameters.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup CppUtilities
 */

#pragma once
#ifndef _SBIA_BASIS_CMDARGS_H
#define _SBIA_BASIS_CMDARGS_H


#include <sbia/basis/tclap/SwitchArg.h>
#include <sbia/basis/tclap/MultiSwitchArg.h>
#include <sbia/basis/tclap/ValueArg.h>
#include <sbia/basis/tclap/UnlabeledValueArg.h>
#include <sbia/basis/tclap/UnlabeledMultiArg.h>

#include <sbia/basis/MultiArg.h>


namespace sbia
{

namespace basis
{


// ---------------------------------------------------------------------------
// common
/// Base type of command-line arguments.
typedef TCLAP::Arg Arg;

// ---------------------------------------------------------------------------
// option switches

/// Switch to enable/disable option.
typedef TCLAP::SwitchArg SwitchArg;
/// Counts occurrences of option switch.
typedef TCLAP::MultiSwitchArg MultiSwitchArg;

// ---------------------------------------------------------------------------
// single argument option

/// String argument.
typedef TCLAP::ValueArg<std::string> StringArg;
/// Signed 32-bit integer argument.
typedef TCLAP::ValueArg<int> Int32Arg;
/// Unsigned 32-bit integer argument.
typedef TCLAP::ValueArg<unsigned int> UInt32Arg;
/// Signed 64-bit integer argument.
typedef TCLAP::ValueArg<long> Int64Arg;
/// Unsigned 64-bit integer argument.
typedef TCLAP::ValueArg<unsigned long> UInt64Arg;
/// Alias for Int32Arg.
typedef Int32Arg IntArg;
/// Alias for UInt32Arg.
typedef UInt32Arg UIntArg;
/// Floating-point argument.
typedef TCLAP::ValueArg<float> FloatArg;
/// Floating-point argument (double precision).
typedef TCLAP::ValueArg<double> DoubleArg;

// ---------------------------------------------------------------------------
// multiple arguments option

/// String argument (multiple occurrences allowed).
typedef MultiArg<std::string> MultiStringArg;
/// Signed 32-bit integer argument (multiple occurrences allowed).
typedef MultiArg<int> MultiInt32Arg;
/// Unsigned 32-bit integer argument (multiple occurrences allowed).
typedef MultiArg<unsigned int> MultiUInt32Arg;
/// Signed 64-bit integer argument (multiple occurrences allowed).
typedef MultiArg<long> MultiInt64Arg;
/// Unsigned 64-bit integer argument (multiple occurrences allowed).
typedef MultiArg<unsigned long> MultiUInt64Arg;
/// Floating-point argument (multiple occurrences allowed).
typedef MultiArg<float> MultiFloatArg;
/// Floating-point argument (double precision, multiple occurrences allowed).
typedef MultiArg<double> MultiDoubleArg;
/// Alias for MultiInt32Arg.
typedef MultiInt32Arg MultiIntArg;
/// Alias for MultiUInt32Arg.
typedef MultiUInt32Arg MultiUIntArg;

// ---------------------------------------------------------------------------
// positional arguments

/**
 * @brief Positional argument.
 *
 * Processes only one positional argument. Add the positional arguments in
 * the right order to the command-line.
 *
 * @note The other unlabeled arguments as supported by TCLAP are intentionally
 *       not available through BASIS itself. Any non-string argument should
 *       more likely be a labeled argument, i.e., one with an option flag.
 */
typedef TCLAP::UnlabeledValueArg<std::string> PositionalArg;

/**
 * @brief Positional arguments.
 *
 * Use only one positional argument per command-line. Must be the last argument
 * added to the command-line as it is greedy and will aggregate all remaining
 * command-line arguments.
 *
 * @note The other unlabeled arguments as supported by TCLAP are intentionally
 *       not available through BASIS itself. Any non-string argument should
 *       more likely be a labeled argument, i.e., one with an option flag.
 */
typedef TCLAP::UnlabeledMultiArg<std::string> PositionalArgs;


} // namespace basis

} // namespace sbia


#endif // _SBIA_BASIS_CMDARGS_H
