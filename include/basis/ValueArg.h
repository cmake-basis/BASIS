/**
 * @file  basis/ValueArg.h
 * @brief Extends TCLAP's ValueArg implementation.
 *
 * Instead of throwing an exception if an argument is set more than once,
 * this argument type optionally allows the value to be overwritten.
 *
 * Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */ 

#pragma once
#ifndef _BASIS_VALUEARG_H
#define _BASIS_VALUEARG_H


#include "tclap/ValueArg.h"


namespace basis {


/**
 * @brief An argument that allows multiple values of type T to be specified.
 *
 * Unlike TCLAP::ValueArg, this argument optionally allows the assignement
 * of a value more than once, overwriting the previously set argument value.
 * This is useful when a visitor set on another option consumed the previously
 * set argument already and thus the value can be overwritten before the
 * next appearance of this option. See the basistest-driver executable,
 * for example, where the tolerances are stored in a structure every time
 * a --compare option is encountered and the tolerances can then be overwritten
 * for the next --compare statement.
 *
 * Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * @ingroup CxxCmdLine
 */
template <class T>
class ValueArg : public TCLAP::ValueArg<T>
{
    // -----------------------------------------------------------------------
    // construction / destruction
public:

    /**
     * @brief Constructor.
     *
     * @param [in] flag           The one character flag that identifies this
     *                            argument on the command line.
     * @param [in] name           A one word name for the argument.  Can be
     *                            used as a long flag on the command line.
     * @param [in] desc           A description of what the argument is for or does.
     * @param [in] req            Whether the argument is required on the command-line.
     * @param [in] value          The default value assigned to this argument if it
     *                            is not present on the command line.
     * @param [in] typeDesc       A short, human readable description of the
     *                            type that this object expects.  This is used in
     *                            the generation of the USAGE statement. The goal
     *                            is to be helpful to the end user of the program.
     * @param [in] allowOverwrite Whether value can be overwritten by another
     *                            occurrence of the argument on the command-line.
     * @param [in] v              An optional visitor. You probably should not
     *                            use this unless you have a very good reason.
     */
    ValueArg(const std::string& flag,
             const std::string& name,
             const std::string& desc,
             bool               req,
             T                  value,
             const std::string& typeDesc,
             bool               allowOverwrite = false,
             TCLAP::Visitor*    v              = NULL);
             
    /**
     * @brief Constructor.
     *
     * @param [in] flag           The one character flag that identifies this
     *                            argument on the command line.
     * @param [in] name           A one word name for the argument.  Can be
     *                            used as a long flag on the command line.
     * @param [in] desc           A description of what the argument is for or does.
     * @param [in] req            Whether the argument is required on the command-line.
     * @param [in] value          The default value assigned to this argument if it
     *                            is not present on the command line.
     * @param [in] typeDesc       A short, human readable description of the
     *                            type that this object expects.  This is used in
     *                            the generation of the USAGE statement. The goal
     *                            is to be helpful to the end user of the program.
     * @param [in] parser         A CmdLine parser object to add this Arg to.
     * @param [in] allowOverwrite Whether value can be overwritten by another
     *                            occurrence of the argument on the command-line.
     * @param [in] v              An optional visitor. You probably should not
     *                            use this unless you have a very good reason.
     */
    ValueArg(const std::string&       flag,
             const std::string&       name,
             const std::string&       desc,
             bool                     req,
             T                        value,
             const std::string&       typeDesc,
             TCLAP::CmdLineInterface& parser,
             bool                     allowOverwrite = false,
             TCLAP::Visitor*          v              = NULL);

    /**
     * @brief Constructor.
     *
     * @param [in] flag           The one character flag that identifies this
     *                            argument on the command line.
     * @param [in] name           A one word name for the argument.  Can be
     *                            used as a long flag on the command line.
     * @param [in] desc           A description of what the argument is for or does.
     * @param [in] req            Whether the argument is required on the command-line.
     * @param [in] value          The default value assigned to this argument if it
     *                            is not present on the command line.
     * @param [in] constraint     A pointer to a Constraint object used
     *                            to constrain this Arg.
     * @param [in] parser         A CmdLine parser object to add this Arg to.
     * @param [in] allowOverwrite Whether value can be overwritten by another
     *                            occurrence of the argument on the command-line.
     * @param [in] v              An optional visitor. You probably should not
     *                            use this unless you have a very good reason.
     */
    ValueArg(const std::string&       flag,
             const std::string&       name,
             const std::string&       desc,
             bool                     req,
             T                        value,
             TCLAP::Constraint<T>*    constraint,
             TCLAP::CmdLineInterface& parser,
             bool                     allowOverwrite = false,
             TCLAP::Visitor*          v              = NULL);
  
    /**
     * @brief Constructor.
     *
     * @param [in] flag           The one character flag that identifies this
     *                            argument on the command line.
     * @param [in] name           A one word name for the argument.  Can be
     *                            used as a long flag on the command line.
     * @param [in] desc           A description of what the argument is for or does.
     * @param [in] req            Whether the argument is required on the command-line.
     * @param [in] value          The default value assigned to this argument if it
     *                            is not present on the command line.
     * @param [in] constraint     A pointer to a Constraint object used
     *                            to constrain this Arg.
     * @param [in] allowOverwrite Whether value can be overwritten by another
     *                            occurrence of the argument on the command-line.
     * @param [in] v              An optional visitor. You probably should not
     *                            use this unless you have a very good reason.
     */
    ValueArg(const std::string&    flag,
             const std::string&    name,
             const std::string&    desc,
             bool                  req,
             T                     value,
             TCLAP::Constraint<T>* constraint,
             bool                  allowOverwrite = false,
             TCLAP::Visitor*       v              = NULL);

    // -----------------------------------------------------------------------
    // parsing
public:

    /**
     * @brief Handles the processing of the argument.
     *
     * This re-implements the TCLAP::ValueArg version of this method to
     * ignore the _alreadySet flag if _allowOverwrite is true.
     *
     * @param [in, out] i    Pointer to the current argument in the list.
     * @param [in, out] args Mutable list of strings. Passed from main().
     */
    virtual bool processArg(int* i, std::vector<std::string>& args); 

    // -----------------------------------------------------------------------
    // unsupported
private:
    ValueArg<T>(const ValueArg<T>&);            ///< Not implemented.
    ValueArg<T>& operator=(const ValueArg<T>&); ///< Not implemented.

    // -----------------------------------------------------------------------
    // member variables
protected:

    bool _allowOverwrite; ///< Whether argument value can be overwritten by
                          ///< another occurrence of this argument.

}; // class ValueArg


// ===========================================================================
// template definitions
// ===========================================================================

// ---------------------------------------------------------------------------
template <class T>
ValueArg<T>::ValueArg(const std::string& flag, 
                      const std::string& name, 
                      const std::string& desc, 
                      bool req, 
                      T val,
                      const std::string& typeDesc,
                      bool allowOverwrite,
                      TCLAP::Visitor* v)
:
    TCLAP::ValueArg<T>(flag, name, desc, req, val, typeDesc, v),
    _allowOverwrite(allowOverwrite)
{
}

// ---------------------------------------------------------------------------
template <class T>
ValueArg<T>::ValueArg(const std::string& flag, 
                      const std::string& name, 
                      const std::string& desc, 
                      bool req, 
                      T val,
                      const std::string& typeDesc,
                      TCLAP::CmdLineInterface& parser,
                      bool allowOverwrite,
                      TCLAP::Visitor* v)
:
    TCLAP::ValueArg<T>(flag, name, desc, req, val, typeDesc, parser, v),
    _allowOverwrite(allowOverwrite)
{ 
}

// ---------------------------------------------------------------------------
template <class T>
ValueArg<T>::ValueArg(const std::string& flag, 
                      const std::string& name, 
                      const std::string& desc, 
                      bool req, 
                      T val,
                      TCLAP::Constraint<T>* constraint,
                      bool allowOverwrite,
                      TCLAP::Visitor* v)
:
    TCLAP::ValueArg<T>(flag, name, desc, req, val, constraint, v),
    _allowOverwrite(allowOverwrite)
{
}

// ---------------------------------------------------------------------------
template <class T>
ValueArg<T>::ValueArg(const std::string& flag, 
                      const std::string& name, 
                      const std::string& desc, 
                      bool req, 
                      T val,
                      TCLAP::Constraint<T>* constraint,
                      TCLAP::CmdLineInterface& parser,
                      bool allowOverwrite,
                      TCLAP::Visitor* v)
:
    TCLAP::ValueArg<T>(flag, name, desc, req, val, constraint, parser, v),
    _allowOverwrite(allowOverwrite)
{ 
}

// ---------------------------------------------------------------------------
template <class T>
bool ValueArg<T>::processArg(int* i, std::vector<std::string>& args)
{
    if (TCLAP::ValueArg<T>::_ignoreable && TCLAP::ValueArg<T>::ignoreRest()) return false;
    if (TCLAP::ValueArg<T>::_hasBlanks(args[*i])) return false;

    std::string flag = args[*i];

    std::string value = "";
    TCLAP::ValueArg<T>::trimFlag(flag, value);

    if (TCLAP::ValueArg<T>::argMatches(flag)) {
        if (!_allowOverwrite && TCLAP::ValueArg<T>::_alreadySet) {
            if (TCLAP::ValueArg<T>::_xorSet) {
                throw TCLAP::CmdLineParseException("Mutually exclusive argument already set!",
                        TCLAP::ValueArg<T>::toString());
            } else {
                throw TCLAP::CmdLineParseException("Argument already set!",
                        TCLAP::ValueArg<T>::toString());
            }
        }

        if (TCLAP::Arg::delimiter() != ' ' && value == "") {
            throw TCLAP::ArgParseException("Couldn't find delimiter for this argument!",
                    TCLAP::ValueArg<T>::toString());
        }

        if (value == "") {
            (*i)++;
            if (static_cast<unsigned int>(*i) < args.size()) {
                TCLAP::ValueArg<T>::_extractValue(args[*i]);
            } else {
                throw TCLAP::ArgParseException("Missing a value for this argument!",
                        TCLAP::ValueArg<T>::toString());
            }
        } else {
            TCLAP::ValueArg<T>::_extractValue(value);
        }

        TCLAP::ValueArg<T>::_alreadySet = true;
        TCLAP::ValueArg<T>::_checkWithVisitor();
        return true;
    } else {
        return false;
    }
}


} // namespace basis


#endif // _BASIS_VALUEARG_H
