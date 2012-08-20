/**
 * @file  CmdArgs.h
 * @brief Definition of commonly used command-line arguments.
 *
 * This include file mainly redefines the TCLAP command-line argument types
 * in the namespace of BASIS itself. It only defines commonly used argument
 * types without template parameters.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _BASIS_CMDARGS_H
#define _BASIS_CMDARGS_H


#include "tclap/SwitchArg.h"
#include "tclap/MultiSwitchArg.h"
#include "tclap/UnlabeledValueArg.h"
#include "tclap/UnlabeledMultiArg.h"

#include "ValueArg.h"
#include "MultiArg.h"

#include "tclap/Constraint.h"

#include "os/path.h" // isfile(), isdir()


namespace basis {


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

// Note: Use full namespace on the left side to help Doxygen to create
//       the proper references to the BASIS ValueArg class.

/// String argument.
typedef basis::ValueArg<std::string> StringArg;
/// Signed 32-bit integer argument.
typedef basis::ValueArg<int> Int32Arg;
/// Unsigned 32-bit integer argument.
typedef basis::ValueArg<unsigned int> UInt32Arg;
/// Signed 64-bit integer argument.
typedef basis::ValueArg<long> Int64Arg;
/// Unsigned 64-bit integer argument.
typedef basis::ValueArg<unsigned long> UInt64Arg;
/// Alias for Int32Arg.
typedef basis::ValueArg<int> IntArg;
/// Alias for UInt32Arg.
typedef basis::ValueArg<unsigned int> UIntArg;
/// Floating-point argument.
typedef basis::ValueArg<float> FloatArg;
/// Floating-point argument (double precision).
typedef basis::ValueArg<double> DoubleArg;

// ---------------------------------------------------------------------------
// multiple arguments option

// Note: Use full namespace on the left side to help Doxygen to create
//       the proper references to the BASIS MultiArg class.

/// String argument (multiple occurrences allowed).
typedef basis::MultiArg<std::string> MultiStringArg;
/// Signed 32-bit integer argument (multiple occurrences allowed).
typedef basis::MultiArg<int> MultiInt32Arg;
/// Unsigned 32-bit integer argument (multiple occurrences allowed).
typedef basis::MultiArg<unsigned int> MultiUInt32Arg;
/// Signed 64-bit integer argument (multiple occurrences allowed).
typedef basis::MultiArg<long> MultiInt64Arg;
/// Unsigned 64-bit integer argument (multiple occurrences allowed).
typedef basis::MultiArg<unsigned long> MultiUInt64Arg;
/// Floating-point argument (multiple occurrences allowed).
typedef basis::MultiArg<float> MultiFloatArg;
/// Floating-point argument (double precision, multiple occurrences allowed).
typedef basis::MultiArg<double> MultiDoubleArg;
/// Alias for MultiInt32Arg.
typedef basis::MultiArg<int> MultiIntArg;
/// Alias for MultiUInt32Arg.
typedef basis::MultiArg<unsigned int> MultiUIntArg;

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
class NegativeValueConstraint : public TCLAP::Constraint<T>
{
public:
    NegativeValueConstraint(const std::string& typeDesc) : _typeDesc(typeDesc) {}
    virtual ~NegativeValueConstraint() {}
    virtual std::string description() const { return "Value must be negative."; }
    virtual std::string shortID() const { return _typeDesc; }
    virtual bool check(const T& value) const { return value < 0; }
protected:
    std::string _typeDesc;
};

/**
 * @brief Constrain argument values to zero or negative values.
 */
template<typename T>
class ZeroOrNegativeValueConstraint : public TCLAP::Constraint<T>
{
public:
    ZeroOrNegativeValueConstraint(const std::string& typeDesc) : _typeDesc(typeDesc) {}
    virtual ~ZeroOrNegativeValueConstraint() {}
    virtual std::string description() const { return "Value must be less or equal to zero."; }
    virtual std::string shortID() const { return _typeDesc; }
    virtual bool check(const T& value) const { return value <= 0; }
protected:
    std::string _typeDesc;
};

/**
 * @brief Constrain argument values to non-zero values.
 */
template<typename T>
class NonZeroValueConstraint : public TCLAP::Constraint<T>
{
public:
    NonZeroValueConstraint(const std::string& typeDesc) : _typeDesc(typeDesc) {}
    virtual ~NonZeroValueConstraint() {}
    virtual std::string description() const { return "Value must not be zero."; }
    virtual std::string shortID() const { return _typeDesc; }
    virtual bool check(const T& value) const { return value != 0; }
protected:
    std::string _typeDesc;
};

/**
 * @brief Constrain argument values to positive values.
 */
template<typename T>
class PositiveValueConstraint : public TCLAP::Constraint<T>
{
public:
    PositiveValueConstraint(const std::string& typeDesc) : _typeDesc(typeDesc) {}
    virtual ~PositiveValueConstraint() {}
    virtual std::string description() const { return "Value must be positive."; }
    virtual std::string shortID() const { return _typeDesc; }
    virtual bool check(const T& value) const { return value > 0; }
protected:
    std::string _typeDesc;
};

/**
 * @brief Constrain argument values to zero or positive values.
 */
template<typename T>
class ZeroOrPositiveValueConstraint : public TCLAP::Constraint<T>
{
public:
    ZeroOrPositiveValueConstraint(const std::string& typeDesc) : _typeDesc(typeDesc) {}
    virtual ~ZeroOrPositiveValueConstraint() {}
    virtual std::string description() const { return "Value must be greater or equal to zero."; }
    virtual std::string shortID() const { return _typeDesc; }
    virtual bool check(const T& value) const { return value >= 0; }
protected:
    std::string _typeDesc;
};

// ---------------------------------------------------------------------------
// constraints on paths
// ---------------------------------------------------------------------------

/**
 * @brief Constrain argument values to paths of existing files.
 */
class ExistingFileConstraint : public TCLAP::Constraint<std::string>
{
public:
    ExistingFileConstraint(const std::string& typeDesc = "<file>") : _typeDesc(typeDesc) {}
    virtual ~ExistingFileConstraint() {}
    virtual std::string description() const { return "Value must name an existing file."; }
    virtual std::string shortID() const { return _typeDesc; }
    virtual bool check(const std::string& value) const { return os::path::isfile(value); }
protected:
    std::string _typeDesc;
};

/**
 * @brief Constrain argument values to paths of existing directories.
 */
class ExistingDirectoryConstraint : public TCLAP::Constraint<std::string>
{
public:
    ExistingDirectoryConstraint(const std::string& typeDesc = "<dir>") : _typeDesc(typeDesc) {}
    virtual ~ExistingDirectoryConstraint() {}
    virtual std::string description() const { return "Value must name an existing directory."; }
    virtual std::string shortID() const { return _typeDesc; }
    virtual bool check(const std::string& value) const { return os::path::isdir(value); }
protected:
    std::string _typeDesc;
};


/// @}
// end of Doxygen group


} // namespace basis


#endif // _BASIS_CMDARGS_H
