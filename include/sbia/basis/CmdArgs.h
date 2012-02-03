/**
 * @file  CmdArgs.h
 * @brief Definition of commonly used command-line arguments.
 *
 * This include file mainly redefines the TCLAP command-line argument types
 * in the namespace of BASIS itself. It only defines commonly used argument
 * types without template parameters.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _SBIA_BASIS_CMDARGS_H
#define _SBIA_BASIS_CMDARGS_H


#include <sbia/tclap/SwitchArg.h>
#include <sbia/tclap/MultiSwitchArg.h>
#include <sbia/tclap/ValueArg.h>
#include <sbia/tclap/UnlabeledValueArg.h>
#include <sbia/tclap/UnlabeledMultiArg.h>

#include <sbia/basis/MultiArg.h>

#include <sbia/basis/path.h> // exists()


namespace sbia
{

namespace basis
{


/// @addtogroup CxxCmdLine
/// @{


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
typedef TCLAP::ValueArg<int> IntArg;
/// Alias for UInt32Arg.
typedef TCLAP::ValueArg<unsigned int> UIntArg;
/// Floating-point argument.
typedef TCLAP::ValueArg<float> FloatArg;
/// Floating-point argument (double precision).
typedef TCLAP::ValueArg<double> DoubleArg;

// ---------------------------------------------------------------------------
// multiple arguments option

// Note: Use full namespace on the left side to help Doxygen to create
//       the proper references to the BASIS MultiArg class.

/// String argument (multiple occurrences allowed).
typedef sbia::basis::MultiArg<std::string> MultiStringArg;
/// Signed 32-bit integer argument (multiple occurrences allowed).
typedef sbia::basis::MultiArg<int> MultiInt32Arg;
/// Unsigned 32-bit integer argument (multiple occurrences allowed).
typedef sbia::basis::MultiArg<unsigned int> MultiUInt32Arg;
/// Signed 64-bit integer argument (multiple occurrences allowed).
typedef sbia::basis::MultiArg<long> MultiInt64Arg;
/// Unsigned 64-bit integer argument (multiple occurrences allowed).
typedef sbia::basis::MultiArg<unsigned long> MultiUInt64Arg;
/// Floating-point argument (multiple occurrences allowed).
typedef sbia::basis::MultiArg<float> MultiFloatArg;
/// Floating-point argument (double precision, multiple occurrences allowed).
typedef sbia::basis::MultiArg<double> MultiDoubleArg;
/// Alias for MultiInt32Arg.
typedef sbia::basis::MultiArg<int> MultiIntArg;
/// Alias for MultiUInt32Arg.
typedef sbia::basis::MultiArg<unsigned int> MultiUIntArg;

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

// ===========================================================================
// constraints
// ===========================================================================

// ---------------------------------------------------------------------------
// constraints on enumerations
// ---------------------------------------------------------------------------

/**
 * @brief Constrains string arguments to allow only predefined values.
 */
typedef TCLAP::ValuesConstraint<std::string> StringValuesConstraint;

// ---------------------------------------------------------------------------
// constraints on numbers
// ---------------------------------------------------------------------------

/**
 * @brief Constrain argument values to negative values.
 */
template<typename T>
class NegativeValueConstraint : TCLAP::Constraint<T>
{
public:
    NegativeValueConstraint() {}
    virtual ~NegativeValueConstraint() {}
    virtual std::string description() const { return "< 0"; }
    virtual std::string shortID() const { return "< 0"; }
    virtual bool check(const T& value) const { return value < 0; }
};

/**
 * @brief Constrain argument values to non-zero values.
 */
template<typename T>
class NonZeroValueConstraint : TCLAP::Constraint<T>
{
public:
    NonZeroValueConstraint() {}
    virtual ~NonZeroValueConstraint() {}
    virtual std::string description() const { return "!= 0"; }
    virtual std::string shortID() const { return "!= 0"; }
    virtual bool check(const T& value) const { return value != 0; }
};

/**
 * @brief Constrain argument values to positive values.
 */
template<typename T>
class PositiveValueConstraint : TCLAP::Constraint<T>
{
public:
    PositiveValueConstraint() {}
    virtual ~PositiveValueConstraint() {}
    virtual std::string description() const { return "> 0"; }
    virtual std::string shortID() const { return "> 0"; }
    virtual bool check(const T& value) const { return value > 0; }
};

// ---------------------------------------------------------------------------
// constraints on paths
// ---------------------------------------------------------------------------

/**
 * @brief Constrain argument values to paths of existing files.
 */
class ExistentFileConstraint : TCLAP::Constraint<std::string>
{
public:
    ExistentFileConstraint() {}
    virtual ~ExistentFileConstraint() {}
    virtual std::string description() const { return "file exists"; }
    virtual std::string shortID() const { return "file exists"; }
    virtual bool check(const std::string& value) const { return is_file(value); }
};

/**
 * @brief Constrain argument values to paths of existing directories.
 */
class ExistentDirectoryConstraint : TCLAP::Constraint<std::string>
{
public:
    ExistentDirectoryConstraint() {}
    virtual ~ExistentDirectoryConstraint() {}
    virtual std::string description() const { return "directory exists"; }
    virtual std::string shortID() const { return "dir exists"; }
    virtual bool check(const std::string& value) const { return is_dir(value); }
};


/// @}
// end of Doxygen group


} // namespace basis

} // namespace sbia


#endif // _SBIA_BASIS_CMDARGS_H
