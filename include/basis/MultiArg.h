/**
 * @file  basis/MultiArg.h
 * @brief Extends TCLAP's MultiArg implementation.
 *
 * Instead of always only consuming one argument after the argument name or
 * flag, this MultiArg implementation consumes N arguments, where the number
 * of arguments N is set to a fixed number at construction time.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _BASIS_MULTIARG_H
#define _BASIS_MULTIARG_H


#include "tclap/MultiArg.h"


namespace basis {


/**
 * @brief An argument that allows multiple values of type T to be specified.
 *
 * Very similar to a TCLAP::ValueArg, except a vector of values will be returned
 * instead of just one. Unlike TCLAP::MultiArg, this argument will each time
 * its option keyword or flag is encountered process N > 0 argument values,
 * where the number N is specified at construction time. Moreover, this argument
 * can be given several times. Hence, the returned vector of values has length
 * N * M, where M is the number of times the argument was given on the
 * command-line.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * @ingroup CxxCmdLine
 */
template <class T>
class MultiArg : public TCLAP::MultiArg<T>
{
    // -----------------------------------------------------------------------
    // construction / destruction
public:

    /**
     * @brief Constructor.
     *
     * @param [in] flag       The one character flag that identifies this
     *                        argument on the command line.
     * @param [in] name       A one word name for the argument.  Can be
     *                        used as a long flag on the command line.
     * @param [in] desc       A description of what the argument is for or does.
     * @param [in] req        Whether the argument is required on the command-line.
     * @param [in] typeDesc   A short, human readable description of the
     *                        type that this object expects.  This is used in
     *                        the generation of the USAGE statement. The goal
     *                        is to be helpful to the end user of the program.
     * @param [in] n          Number of values per argument occurrence.
     * @param [in] once       Accept argument only once.
     * @param [in] v          An optional visitor. You probably should not
     *                        use this unless you have a very good reason.
     */
    MultiArg(const std::string& flag,
             const std::string& name,
             const std::string& desc,
             bool               req,
             const std::string& typeDesc,
             unsigned int       n    = 1,
             bool               once = false,
             TCLAP::Visitor*    v    = NULL);

    /**
     * @brief Constructor.
     *
     * @param [in] flag       The one character flag that identifies this
     *                        argument on the command line.
     * @param [in] name       A one word name for the argument.  Can be
     *                        used as a long flag on the command line.
     * @param [in] desc       A description of what the argument is for or does.
     * @param [in] req        Whether the argument is required on the command-line.
     * @param [in] typeDesc   A short, human readable description of the
     *                        type that this object expects.  This is used in
     *                        the generation of the USAGE statement. The goal
     *                        is to be helpful to the end user of the program.
     * @param [in] parser     A CmdLine parser object to add this Arg to
     * @param [in] n          Number of values per argument occurrence.
     * @param [in] once       Accept argument only once.
     * @param [in] v          An optional visitor. You probably should not
     *                        use this unless you have a very good reason.
     */
    MultiArg(const std::string&       flag, 
             const std::string&       name,
             const std::string&       desc,
             bool                     req,
             const std::string&       typeDesc,
             TCLAP::CmdLineInterface& parser,
             unsigned int             n    = 1,
             bool                     once = false,
             TCLAP::Visitor*          v    = NULL);

    /**
     * @brief Constructor.
     *
     * @param [in] flag       The one character flag that identifies this
     *                        argument on the command line.
     * @param [in] name       A one word name for the argument.  Can be
     *                        used as a long flag on the command line.
     * @param [in] desc       A description of what the argument is for or does.
     * @param [in] req        Whether the argument is required on the command-line.
     * @param [in] constraint A pointer to a Constraint object used
     *                        to constrain this Arg.
     * @param [in] n          Number of values per argument occurrence.
     * @param [in] once       Accept argument only once.
     * @param [in] v          An optional visitor. You probably should not
     *                        use this unless you have a very good reason.
     */
    MultiArg(const std::string&    flag,
             const std::string&    name,
             const std::string&    desc,
             bool                  req,
             TCLAP::Constraint<T>* constraint,
             unsigned int          n    = 1,
             bool                  once = false,
             TCLAP::Visitor*       v    = NULL);

    /**
     * @brief Constructor.
     *
     * @param [in] flag       The one character flag that identifies this
     *                        argument on the command line.
     * @param [in] name       A one word name for the argument.  Can be
     *                        used as a long flag on the command line.
     * @param [in] desc       A description of what the argument is for or does.
     * @param [in] req        Whether the argument is required on the command-line.
     * @param [in] constraint A pointer to a Constraint object used
     *                        to constrain this Arg.
     * @param [in] parser     A CmdLine parser object to add this Arg to.
     * @param [in] n          Number of values per argument occurrence.
     * @param [in] once       Accept argument only once.
     * @param [in] v          An optional visitor. You probably should not
     *                        use this unless you have a very good reason.
     */
    MultiArg(const std::string&       flag, 
             const std::string&       name,
             const std::string&       desc,
             bool                     req,
             TCLAP::Constraint<T>*    constraint,
             TCLAP::CmdLineInterface& parser,
             unsigned int             n    = 1,
             bool                     once = false,
             TCLAP::Visitor*          v    = NULL);
 
    // -----------------------------------------------------------------------
    // parsing
public:

    /**
     * @brief Handles the processing of the argument.
     *
     * This re-implements the TCLAP::MultiArg version of this method to set
     * the _value of the argument appropriately. It knows the difference
     * between labeled and unlabeled.
     *
     * @param [in, out] i    Pointer to the current argument in the list.
     * @param [in, out] args Mutable list of strings. Passed from main().
     */
    virtual bool processArg(int* i, std::vector<std::string>& args); 

    /**
	 * @brief Whether the argument is required or not.
     *
     * Once we've matched the first value, then the arg is no longer required,
     * except if the argument is only accepted once with multiple values.
	 */
	virtual bool isRequired() const;

    // -----------------------------------------------------------------------
    // unsupported
private:

    MultiArg<T>(const MultiArg<T>&);            ///< Not implemented.
    MultiArg<T>& operator=(const MultiArg<T>&); ///< Not implemented.

    // -----------------------------------------------------------------------
    // member variables
protected:

    unsigned int _numberOfArguments; ///< Number of values to process each time.

}; // class MultiArg


// ===========================================================================
// template definitions
// ===========================================================================

// ---------------------------------------------------------------------------
template <class T>
MultiArg<T>::MultiArg(const std::string& flag, 
                      const std::string& name,
                      const std::string& desc,
                      bool req,
                      const std::string& typeDesc,
                      unsigned int n,
                      bool once,
                      TCLAP::Visitor* v)
:
   TCLAP::MultiArg<T>(flag, name, desc, req, typeDesc, v),
   _numberOfArguments(n)
{
    if (once) TCLAP::MultiArg<T>::_acceptsMultipleValues = false;
}

// ---------------------------------------------------------------------------
template <class T>
MultiArg<T>::MultiArg(const std::string& flag, 
                      const std::string& name,
                      const std::string& desc,
                      bool req,
                      const std::string& typeDesc,
                      TCLAP::CmdLineInterface& parser,
                      unsigned int n,
                      bool once,
                      TCLAP::Visitor* v)
:
    TCLAP::MultiArg<T>(flag, name, desc, req, typeDesc, parser, v),
    _numberOfArguments(n)
{ 
    if (once) TCLAP::MultiArg<T>::_acceptsMultipleValues = false;
}

// ---------------------------------------------------------------------------
template <class T>
MultiArg<T>::MultiArg(const std::string& flag, 
                      const std::string& name,
                      const std::string& desc,
                      bool req,
                      TCLAP::Constraint<T>* constraint,
                      unsigned int n,
                      bool once,
                      TCLAP::Visitor* v)
:
    TCLAP::MultiArg<T>(flag, name, desc, req, constraint, v),
    _numberOfArguments(n)
{ 
    if (once) TCLAP::MultiArg<T>::_acceptsMultipleValues = false;
}

// ---------------------------------------------------------------------------
template <class T>
MultiArg<T>::MultiArg(const std::string& flag, 
                      const std::string& name,
                      const std::string& desc,
                      bool req,
                      TCLAP::Constraint<T>* constraint,
                      TCLAP::CmdLineInterface& parser,
                      unsigned int n,
                      bool once,
                      TCLAP::Visitor* v)
:
    TCLAP::MultiArg<T>(flag, name, desc, req, constraint, parser, v),
    _numberOfArguments(n)
{ 
    if (once) TCLAP::MultiArg<T>::_acceptsMultipleValues = false;
}

// ---------------------------------------------------------------------------
template <class T>
bool MultiArg<T>::processArg(int *i, std::vector<std::string>& args) 
{
    if (TCLAP::MultiArg<T>::_ignoreable && TCLAP::Arg::ignoreRest()) {
        return false;
    }
    if (TCLAP::MultiArg<T>::_hasBlanks( args[*i] )) return false;
    // separate flag and value if delimiter is not ' '
    std::string flag = args[*i];
    std::string value = "";
    TCLAP::MultiArg<T>::trimFlag(flag, value);
    if (!TCLAP::MultiArg<T>::argMatches(flag)) return false;
    // check if delimiter was found
    if (TCLAP::Arg::delimiter() != ' ' && value == "") {
        throw TCLAP::ArgParseException( 
                "Couldn't find delimiter for this argument!",
                TCLAP::MultiArg<T>::toString());
    }
    // always take the first one, regardless of number of arguments
    if (value == "")
    {
        if (TCLAP::MultiArg<T>::_alreadySet &&
                !TCLAP::MultiArg<T>::_acceptsMultipleValues) {
            throw TCLAP::CmdLineParseException("Argument already set!",
                                               TCLAP::MultiArg<T>::toString());
        }
        (*i)++;
        if (static_cast<unsigned int>(*i) < args.size()) {
            TCLAP::MultiArg<T>::_extractValue(args[*i]);
        } else {
            throw TCLAP::ArgParseException(
                    "Missing a value for this argument!",
                    TCLAP::MultiArg<T>::toString());
        }
    } else {
        TCLAP::MultiArg<T>::_extractValue(value);
    }
    // continue extracting values until number of arguments processed
    for (unsigned int n = 1; n < _numberOfArguments; n++) {
        (*i)++;
        if (static_cast<unsigned int>(*i) < args.size()) {
            TCLAP::MultiArg<T>::_extractValue(args[*i]);
        } else {
            throw TCLAP::ArgParseException(
                    "Too few values for this argument!",
                    TCLAP::MultiArg<T>::toString());
        }
    }
    TCLAP::MultiArg<T>::_alreadySet = true;
    TCLAP::MultiArg<T>::_allowMore  = false;
    TCLAP::MultiArg<T>::_checkWithVisitor();
    return true;
}

template <class T>
bool MultiArg<T>::isRequired() const
{
    if (TCLAP::MultiArg<T>::_required) {
        if (TCLAP::MultiArg<T>::_acceptsMultipleValues
                && TCLAP::MultiArg<T>::_values.size() > 1) {
            return false;
        } else {
            return true;
        }
    } else {
        return false;
    }
}


} // namespace basis


#endif // _BASIS_MULTIARG_H
