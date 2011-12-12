/**
 * @file  basis/CmdLine.h
 * @brief Manages command line definition and parsing of arguments.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup CxxCmdLine
 */

#pragma once
#ifndef _SBIA_BASIS_CMDLINE_H
#define _SBIA_BASIS_CMDLINE_H


#include <sbia/basis/tclap/CmdLine.h> // TCLAP implementation
#include <sbia/basis/CmdArgs.h>       // commonly used arguments


namespace sbia
{

namespace basis
{


/**
 * @brief Manages command line definition and parsing of arguments.
 *
 * See @ref CxxCmdLineParsing for an example use of this class.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * @ingroup CxxCmdLine
 */
class CmdLine : public TCLAP::CmdLine
{
    // -----------------------------------------------------------------------
    // construction / destruction
public:

    /**
     * @brief Constructor.
     *
     * @param [in] name        Program name. Should be a constant string which
     *                         helps to identify the program, not the name of
     *                         the executable as determined at runtime.
     * @param [in] project     Name of project this program belongs to.
     * @param [in] description Program description.
     * @param [in] example     Usage example.
     * @param [in] version     Program version.
     * @param [in] copyright   Copyright notice.
     * @param [in] license     License information.
     * @param [in] contact     Contact information.
     */
    CmdLine(const std::string& name,
            const std::string& project,
            const std::string& description,
            const std::string& example,
            const std::string& version,
            const std::string& copyright =
                    "Copyright (c) University of Pennsylvania."
                    " All rights reserved.",
            const std::string& license =
                    "See http://www.rad.upenn.edu/sbia/software/license.html"
                    " or COPYING file.",
            const std::string& contact =
                    "SBIA Group <sbia-software at uphs.upenn.edu>");

    /**
     * @brief Constructor.
     *
     * @param [in] name        Program name. Should be a constant string which
     *                         helps to identify the program, not the name of
     *                         the executable as determined at runtime.
     * @param [in] project     Name of project this program belongs to.
     * @param [in] description Program description.
     * @param [in] examples    Usage examples.
     * @param [in] version     Program version.
     * @param [in] copyright   Copyright notice.
     * @param [in] license     License information.
     * @param [in] contact     Contact information.
     */
    CmdLine(const std::string&              name,
            const std::string&              project,
            const std::string&              description,
            const std::vector<std::string>& examples,
            const std::string&              version,
            const std::string&              copyright =
                    "Copyright (c) University of Pennsylvania."
                    " All rights reserved.",
            const std::string&              license =
                    "See http://www.rad.upenn.edu/sbia/software/license.html"
                    " or COPYING file.",
            const std::string&              contact =
                    "SBIA Group <sbia-software at uphs.upenn.edu>");

    /**
     * @brief Destructor.
     */
    virtual ~CmdLine() { }

    // -----------------------------------------------------------------------
    // command arguments
public:

    /**
     * @brief Adds an argument to the list of arguments to be parsed.
     *
     * @param [in] a Argument to be added. 
     */
    void add(Arg& a);

    /**
     * @brief An alternative add. Functionally identical.
     *
     * @param [in] a Argument to be added. 
     */
    void add(Arg* a);

    /**
     * @brief Add two Args that will be xor'd.  
     *
     * If this method is used, add does not need to be called.
     *
     * @param [in] a Argument to be added and xor'd. 
     * @param [in] b Argument to be added and xor'd. 
     */
    void xorAdd(Arg& a, Arg& b);

    /**
     * @brief Add a list of arguments that will be xor'd.
     *
     * If this method is used, add does not need to be called.
     *
     * @param [in] xors List of Args to be added and xor'd.
     */
    void xorAdd(std::vector<Arg*>& xors);

    // -----------------------------------------------------------------------
    // parse command-line arguments
public:

    /**
     * @brief Parses the command line.
     *
     * @param [in] argc Number of arguments.
     * @param [in] argv Array of arguments.
     */
    void parse(int argc, const char* const* argv);

    /**
     * @brief Parses the command line.
     *
     * @param [in] args A vector of strings representing the args. 
     *                  args[0] is still the program name.
     */
    void parse(std::vector<std::string>& args);

    // -----------------------------------------------------------------------
    // accessors
public:

    /**
     * @brief Get name of program.
     *
     * @returns Name of program this command-line object belongs to.
     */
    std::string& getProgramName() { return _name; }

    /**
     * @brief Get name of project the program belongs to.
     *
     * @returns Name of project this program belongs to.
     */
    std::string& getProjectName() { return _project; }

    /**
     * @brief Get program description.
     *
     * @returns Description of program this command-line object belongs to.
     */
    std::string& getDescription() { return _message; }

    /**
     * @brief Get usage example.
     *
     * @returns Example command-line usage.
     */
    std::vector<std::string>& getExamples() { return _examples; }

    /**
     * @brief Get copyright notice.
     *
     * @return Copyright information of program.
     */
    std::string& getCopyright() { return _copyright; }

    /**
     * @brief Get license information.
     *
     * @returns License information of program.
     */
    std::string& getLicense() { return _license; }

    /**
     * @brief Get contact information.
     *
     * @returns Contact information.
     */
    std::string& getContact() { return _contact; }

    // -----------------------------------------------------------------------
    // helpers
protected:

    /**
     * @brief Set up command-line object.
     */
    void setup();

    // -----------------------------------------------------------------------
    // unsupported
private:

    CmdLine(const CmdLine&);            ///< Intentionally not implemented.
    CmdLine& operator=(const CmdLine&); ///< Intentionally not implemented.

    // -----------------------------------------------------------------------
    // member variables
protected:

    std::string              _name;      ///< Program name.
    std::string              _project;   ///< Name of project.
    std::vector<std::string> _examples;  ///< Program usage example.
    std::string              _copyright; ///< Program copyright.
    std::string              _license;   ///< Program license.
    std::string              _contact;   ///< Contact information.

}; // class CmdLine


} // namespace basis

} // namespace sbia


#endif // _SBIA_BASIS_CMDLINE_H
