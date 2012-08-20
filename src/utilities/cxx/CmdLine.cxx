/**
 * @file  CmdLine.cxx
 * @brief Manages command line definition and parsing of arguments.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <set>


#include <basis/tclap/Arg.h>
#include <basis/tclap/ArgException.h>
#include <basis/tclap/StdOutput.h>
#include <basis/tclap/Visitor.h>
#include <basis/tclap/VersionVisitor.h>
#include <basis/tclap/XorHandler.h>

#include <basis/os.h>     // exename()
#include <basis/except.h> // BASIS_THROW, runtime_error
#include <basis/stdio.h>  // get_terminal_columns(), print_wrapped()

#include <basis/CmdLine.h>


// acceptable in .cxx file
using namespace std;


namespace basis {


// ===========================================================================
// class: StdOutput
// ===========================================================================

/**
 * @brief Prints help, version information, and command-line errors.
 */
class StdOutput : public TCLAP::CmdLineOutput
{
    // -----------------------------------------------------------------------
    // construction / destruction
public:

    /**
     * @brief Constructor.
     *
     * @param [in] cmd The command-line with additional attributes
     *                 for which the output is generated.
     */
    StdOutput(CmdLine* cmd);

    // -----------------------------------------------------------------------
    // interface functions
public:

    /**
     * @brief Prints a short help, i.e., usage information.
     */
    virtual void usage(TCLAP::CmdLineInterface&);

    /**
     * @brief Prints the full help.
     */
    virtual void help(TCLAP::CmdLineInterface&);

    /**
     * @brief Prints the version information.
     */
    virtual void version(TCLAP::CmdLineInterface&);

    /**
     * @brief Prints an error message.
     *
     * @param [in] e The exception that caused the failure.
     */
    virtual void failure(TCLAP::CmdLineInterface&, TCLAP::ArgException& e);

    /**
     * @brief Get corresponding command-line object.
     *
     * @returns Command-line with additional attributes for which the
     *          output is generated.
     */
    CmdLine* getCmdLine() { return _cmd; }

    // -----------------------------------------------------------------------
    // helpers
protected:

    /**
     * @brief Update information about terminal size.
     */
    void updateTerminalInfo();

    /**
     * @brief Determine whether an argument has a label or not.
     *
     * @param [in] arg Command-line argument.
     *
     * @returns Whether the given argument is a positional argument.
     */
    bool isUnlabeledArg(TCLAP::Arg* arg) const;

    /**
     * @brief Get string describing type of argument value.
     *
     * @param [in] arg Command-line argument.
     *
     * @returns String describing type of argument value.
     */
    string getTypeDescription(TCLAP::Arg* arg) const;

    /**
     * @brief Get argument usage string.
     *
     * @param [in] arg Command-line argument.
     * @param [in] all Whether to include also optional short flags.
     *
     * @returns Short argument description.
     */
    string getArgumentID(TCLAP::Arg* arg, bool all = false) const;

    /**
     * @brief Prints help of command-line argument.
     *
     * @param [in] os              Output stream.
     * @param [in] arg             Command-line argument.
     * @param [in] indentFirstLine Whether first line should be indented.
     */
    void printArgumentHelp(ostream& os, TCLAP::Arg* arg, bool indentFirstLine = true) const;

    /**
     * Prints usage information, i.e., synopsis.
     *
     * @param [in] os      Output stream.
     * @param [in] heading Enable/disable output of section heading.
     */
    void printUsage(ostream& os, bool heading = true) const;

    /**
     * @brief Prints program description.
     *
     * @param [in] os Output stream.
     */
    void printDescription(ostream& os) const;

    /**
     * @brief Prints command-line arguments.
     *
     * @param [in] os  Output stream.
     * @param [in] all Enable/disable help output of all arguments or only
     *                 the more important arguments.
     */
    void printArguments(ostream& os, bool all) const;

    /**
     * @brief Print example usage.
     *
     * @param [in] os Output stream.
     */
    void printExample(ostream& os) const;

    /**
     * @brief Print contact information.
     *
     * @param [in] os Output stream.
     */
    void printContact(ostream& os) const;

    // -----------------------------------------------------------------------
    // member variables
protected:

    CmdLine*    _cmd;     ///< The command-line with additional attributes.
    set<string> _stdargs; ///< Names of standard arguments.
    int         _columns; ///< Maximum number of columns to use for output.

}; // class StdOutput

// ---------------------------------------------------------------------------
// construction
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
StdOutput::StdOutput(CmdLine* cmd)
:
    _cmd(cmd),
    _columns(75)
{
    _stdargs.insert("ignore_rest");
    _stdargs.insert("verbose");
    _stdargs.insert("help");
    _stdargs.insert("helpshort");
    _stdargs.insert("helpxml");
    _stdargs.insert("helpman");
    _stdargs.insert("version");
}

// ---------------------------------------------------------------------------
// interface functions
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
void StdOutput::usage(TCLAP::CmdLineInterface&)
{
    updateTerminalInfo();
    cout << endl;
    printUsage(cout, false);
    //printArguments(cout, false);
    cout << endl;
}

// ---------------------------------------------------------------------------
void StdOutput::help(TCLAP::CmdLineInterface&)
{
    updateTerminalInfo();
    cout << endl;
    printUsage(cout);
    printDescription(cout);
    printArguments(cout, true);
    printExample(cout);
    printContact(cout);
    cout << endl;
}

// ---------------------------------------------------------------------------
void StdOutput::version(TCLAP::CmdLineInterface&)
{
    std::string name      = _cmd->getProgramName();
    std::string project   = _cmd->getProjectName();
    std::string version   = _cmd->getVersion();
    std::string copyright = _cmd->getCopyright();
    std::string license   = _cmd->getLicense();

    // print version information
    cout << name;
    if (!project.empty()) cout << " (" << project << ")";
    cout << " " << version;
    cout << endl;
    // print copyright and license information
    if (!copyright.empty()) {
        cout << "Copyright (c) " << copyright << ". All rights reserved." << endl;
    }
    if (!license.empty()) cout << license << endl;
}

// ---------------------------------------------------------------------------
void StdOutput::failure(TCLAP::CmdLineInterface&, TCLAP::ArgException& e)
{
    if (!e.argId().empty() && e.argId() != " ") cerr << e.argId() << ", ";
    cerr << e.error() << endl;
    cerr << "See --help for a list of available and required arguments." << endl;
    throw TCLAP::ExitException(1);
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
inline void StdOutput::updateTerminalInfo()
{
    // get maximum number of columns
    int columns = get_terminal_columns();
    // update member variable, but maintain minimum number of columns
    if (columns > 40) _columns = columns;
}

// ---------------------------------------------------------------------------
inline bool StdOutput::isUnlabeledArg(TCLAP::Arg* arg) const
{
    const string id = arg->longID();
    string::size_type pos = id.find(TCLAP::Arg::nameStartString() + arg->getName());
    return pos == string::npos;
}

// ---------------------------------------------------------------------------
inline string StdOutput::getTypeDescription(TCLAP::Arg* arg) const
{
    string typedesc = arg->shortID();
    string::size_type start = typedesc.find ('<');
    string::size_type end   = typedesc.rfind('>');
    if (start != string::npos && end != string::npos) {
        return typedesc.substr(start + 1, end - start - 1);
    } else {
        return "";
    }
}

// ---------------------------------------------------------------------------
inline string StdOutput::getArgumentID(TCLAP::Arg* arg, bool all) const
{
    string id;
    const bool option = !isUnlabeledArg(arg);
    if (option) {
        if (all && arg->getFlag() != "") {
            id += TCLAP::Arg::flagStartString() + arg->getFlag();
            id += "  ";
        }
        id += TCLAP::Arg::nameStartString() + arg->getName();
    }
    if (arg->isValueRequired()) {
        if (option) id += TCLAP::Arg::delimiter();
        id += getTypeDescription(arg);
    }
    return id;
}

// ---------------------------------------------------------------------------
inline
void StdOutput::printArgumentHelp(ostream& os, TCLAP::Arg* arg, bool indentFirstLine) const
{
    string id   = getArgumentID(arg, true);
    string desc = arg->getDescription();
    if (desc.compare (0, 12, "(required)  ")    == 0) desc.erase(0, 12);
    if (desc.compare (0, 15, "(OR required)  ") == 0) desc.erase(0, 15);
    if (indentFirstLine) print_wrapped(os, id, _columns, 8, 0);
    else                 print_wrapped(os, id, _columns, 0, 8);
    if (!desc.empty()) {
        print_wrapped(os, desc, _columns, 15, 0);
    }
}

// ---------------------------------------------------------------------------
void StdOutput::printUsage(ostream& os, bool heading) const
{
    string                        exec_name  = os::exename();
    list<TCLAP::Arg*>             args       = _cmd->getArgList();
    TCLAP::XorHandler&            xorhandler = _cmd->getXorHandler();
    vector< vector<TCLAP::Arg*> > xors       = xorhandler.getXorList();

    // separate into argument groups
    vector< vector<TCLAP::Arg*> > reqxors;
    vector< vector<TCLAP::Arg*> > optxors;
    for (int i = 0; static_cast<unsigned int>(i) < xors.size(); i++) {
        if (xors[i].size() > 0) {
            if (xors[i][0]->isRequired()) reqxors.push_back(xors[i]);
            else                          optxors.push_back(xors[i]);
        }
    }
    list<TCLAP::Arg*> reqargs, reqposargs;
    list<TCLAP::Arg*> optargs, optposargs;
    for (TCLAP::ArgListIterator it = args.begin(); it != args.end(); it++) {
        if (_stdargs.find((*it)->getName()) == _stdargs.end()
                && !xorhandler.contains((*it))) {
            if (isUnlabeledArg(*it)) {
                if ((*it)->isRequired()) {
                    (*it)->addToList(reqposargs);
                } else {
                    (*it)->addToList(optposargs);
                }
            } else {
                if ((*it)->isRequired()) {
                    (*it)->addToList(reqargs);
                } else {
                    (*it)->addToList(optargs);
                }
            }
        }
    }

    // executable name
    string s = exec_name;
    string id;
    // optional arguments with flags
    for (int i = 0; static_cast<unsigned int>(i) < optxors.size(); i++) {
        s += " [";
        for (TCLAP::ArgVectorIterator it = optxors[i].begin();
                it != optxors[i].end(); it++) {
            id = getArgumentID(*it);
            s += id;
            if ((*it)->acceptsMultipleValues() && id.find("...") == string::npos) {
                s += "...";
            }
            s += "|";
        }
        s[s.length() - 1] = ']';
    }
    for (TCLAP::ArgListIterator it = optargs.begin(); it != optargs.end(); it++) {
        id = getArgumentID(*it);
        s += " [";
        s += id;
        s += "]";
        if ((*it)->acceptsMultipleValues() && id.find("...") == string::npos) {
            s += "...";
        }
    }
    // required arguments with flags
    for (int i = 0; static_cast<unsigned int>(i) < reqxors.size(); i++) {
        s += " (";
        for (TCLAP::ArgVectorIterator it = reqxors[i].begin();
                it != reqxors[i].end(); it++) {
            id = getArgumentID(*it);
            s += id;
            if ((*it)->acceptsMultipleValues() && id.find("...") == string::npos) {
                s += "...";
            }
            s += "|";
        }
        s[s.length() - 1] = ')';
    }
    for (TCLAP::ArgListIterator it = reqargs.begin(); it != reqargs.end(); it++) {
        id = getArgumentID(*it);
        s += " ";
        s += id;
        if ((*it)->acceptsMultipleValues() && id.find("...") == string::npos) {
            s += "...";
        }
    }
    // required positional arguments
    for (TCLAP::ArgListIterator it = reqposargs.begin(); it != reqposargs.end(); it++) {
        id = getArgumentID(*it);
        s += " ";
        s += id;
        if ((*it)->acceptsMultipleValues() && id.find("...") == string::npos) {
            s += "...";
        }
    }
    // optional positional arguments
    for (TCLAP::ArgListIterator it = optposargs.begin(); it != optposargs.end(); it++) {
        id = getArgumentID(*it);
        s += " [";
        s += id;
        s += "]";
        if ((*it)->acceptsMultipleValues() && id.find("...") == string::npos) {
            s += "...";
        }
    }

    // print usage with proper number of columns
    // if the program name is too long, then adjust the second line offset 
    if (heading) {
        os << "SYNOPSIS" << endl;
    }
    int offset = static_cast<int>(exec_name.length()) + 1;
    if (offset > _columns / 2) offset = 8;
    print_wrapped(os, s, _columns, 4, offset);
    print_wrapped(os, exec_name + " [-h|--help|--helpshort|--helpxml|--helpman|--version]", _columns, 4, offset);
}

// ---------------------------------------------------------------------------
void StdOutput::printDescription(ostream& os) const
{
    if (_cmd->getMessage() != "") {
        os << endl;
        os << "DESCRIPTION" << endl;
        print_wrapped(os, _cmd->getMessage(), _columns, 4, 0);
    }
}

// ---------------------------------------------------------------------------
void StdOutput::printArguments(ostream& os, bool all) const
{
    list<TCLAP::Arg*>             args       = _cmd->getArgList();
    TCLAP::XorHandler&            xorhandler = _cmd->getXorHandler();
    vector< vector<TCLAP::Arg*> > xors       = xorhandler.getXorList();

    // separate into argument groups
    vector< vector<TCLAP::Arg*> > reqxors;
    vector< vector<TCLAP::Arg*> > optxors;
    for (int i = 0; static_cast<unsigned int>(i) < xors.size(); i++) {
        if (xors[i].size() > 0) {
            if (xors[i][0]->isRequired()) reqxors.push_back(xors[i]);
            else                          optxors.push_back(xors[i]);
        }
    }
    list<TCLAP::Arg*> reqargs, reqposargs;
    list<TCLAP::Arg*> optargs, optposargs;
    list<TCLAP::Arg*> stdargs;
    for (TCLAP::ArgListIterator it = args.begin(); it != args.end(); it++) {
        if (_stdargs.find((*it)->getName()) != _stdargs.end()) {
            (*it)->addToList(stdargs);
        } else if (!xorhandler.contains((*it))) {
            if (isUnlabeledArg(*it)) {
                if ((*it)->isRequired()) {
                    (*it)->addToList(reqposargs);
                } else {
                    (*it)->addToList(optposargs);
                }
            } else {
                if ((*it)->isRequired()) {
                    (*it)->addToList(reqargs);
                } else {
                    (*it)->addToList(optargs);
                }
            }
        }
    }

    // return if command has no arguments
    if (xors.empty() && reqargs.empty() && optargs.empty()) {
        return;
    }

    os << endl;
    os << "OPTIONS" << endl;

    // required arguments
    if (!reqxors.empty() || !reqargs.empty() || !reqposargs.empty()) {
        os << "    Required arguments:" << endl;
        for (TCLAP::ArgListIterator it = reqposargs.begin(); it != reqposargs.end(); it++) {
            if (it != reqposargs.begin()) os << endl;
            printArgumentHelp(os, *it);
        }
        for (int i = 0; static_cast<unsigned int>(i) < reqxors.size(); i++) {
            if (i > 0 || !reqposargs.empty()) os << endl;
            for (TCLAP::ArgVectorIterator it = reqxors[i].begin();
                    it != reqxors[i].end(); it++) {
                if (it != reqxors[i].begin()) {
                    os << "     or ";
                    printArgumentHelp(os, *it, false);
                } else {
                    printArgumentHelp(os, *it);
                }
            }
        }
        for (TCLAP::ArgListIterator it = reqargs.begin(); it != reqargs.end(); it++) {
            if (!reqxors.empty() || it != reqargs.begin()) os << endl;
            printArgumentHelp(os, *it);
        }
    }

    // optional arguments
    if (!optxors.empty() || !optargs.empty()) {
        if (!reqxors.empty() || !reqargs.empty() || !reqposargs.empty()) {
            os << endl;
        }
        os << "    Optional arguments:" << endl;
        for (TCLAP::ArgListIterator it = optposargs.begin(); it != optposargs.end(); it++) {
            if (it != optposargs.begin()) os << endl;
            printArgumentHelp(os, *it);
        }
        for (int i = 0; static_cast<unsigned int>(i) < optxors.size(); i++) {
            if (i > 0 || !optposargs.empty()) os << endl;
            for (TCLAP::ArgVectorIterator it = optxors[i].begin();
                    it != optxors[i].end(); it++) {
                if (it != optxors[i].begin()) {
                    os << "     or ";
                    printArgumentHelp(os, *it, false);
                } else {
                    printArgumentHelp(os, *it);
                }
            }
        }
        for (TCLAP::ArgListIterator it = optargs.begin(); it != optargs.end(); it++) {
            if (!optxors.empty() || it != optargs.begin()) os << endl;
            printArgumentHelp(os, *it);
        }
    }

    // standard arguments
    if (all && !stdargs.empty()) {
        if (!xors.empty() || !reqargs.empty() || !optargs.empty()) {
            os << endl;
        }
        os << "    Standard arguments:" << endl;
        for (TCLAP::ArgListIterator it = stdargs.begin(); it != stdargs.end(); it++) {
            if (it != stdargs.begin()) os << endl;
            printArgumentHelp(os, *it);
        }
    }
}

// ---------------------------------------------------------------------------
void StdOutput::printExample(ostream& os) const
{
    const string exec_name = os::exename();
    const vector<string>& examples = _cmd->getExamples();

    if (!examples.empty()) {
        os << endl;
        os << "EXAMPLE" << endl;
        for (vector<string>::const_iterator it = examples.begin();
                it != examples.end(); ++it) {
            if (it != examples.begin()) os << endl;
            string example = *it;
            string::size_type pos;
            // backwards compatibility
            pos = 0;
            while ((pos = example.find("EXECNAME", pos)) != string::npos) {
                example.replace(pos, 8, exec_name);
            }
            // desired placeholder as it relates to the exename() function
            pos = 0;
            while ((pos = example.find("EXENAME", pos)) != string::npos) {
                example.replace(pos, 7, exec_name);
            }
            print_wrapped(os, example, _columns, 4, 4);
        }
    }
}

// ---------------------------------------------------------------------------
void StdOutput::printContact(ostream& os) const
{
    if (_cmd->getContact() != "") {
        os << endl;
        os << "CONTACT" << endl;
        print_wrapped(os, _cmd->getContact(), _columns, 4, 0);
    }
}

// ===========================================================================
// class: HelpVisitor
// ===========================================================================

/**
 * @brief Displays either full help or usage only.
 */
class HelpVisitor: public TCLAP::Visitor
{
    // -----------------------------------------------------------------------
    // construction / destruction
public:

    /**
     * @brief Constructor.
     *
     * @param [in] out The object which handles the output.
     * @param [in] all Enable/disable full help output.
     */
    HelpVisitor(StdOutput* out, bool all = true)
    :
        Visitor(),
        _out(out),
        _all(all)
    { }

    // -----------------------------------------------------------------------
    // interface function
public:

    /**
     * @brief Print help.
     */
    void visit()
    {
        if (_all) _out->help (*(_out->getCmdLine()));
        else      _out->usage(*(_out->getCmdLine()));
        // exit
        throw TCLAP::ExitException(0); 
    }

    // -----------------------------------------------------------------------
    // member variables
protected:

    StdOutput* _out; ///< Object handling the output.
    bool       _all; ///< Enable/disable full help output.

    // -----------------------------------------------------------------------
    // unsupported
private:

    HelpVisitor(const HelpVisitor&);            ///< Not implemented.
    HelpVisitor& operator=(const HelpVisitor&); ///< Not implemented.

}; // class HelpVisitor

// ===========================================================================
// class: XmlVisitor
// ===========================================================================

/**
 * @brief Outputs the command-line interface in XML format.
 */
class XmlVisitor: public TCLAP::Visitor
{
    // -----------------------------------------------------------------------
    // construction / destruction
public:

    /**
     * @brief Constructor.
     */
    XmlVisitor()
    :
        Visitor()
    { }

    // -----------------------------------------------------------------------
    // interface function
public:

    /**
     * @brief Print help.
     */
    void visit()
    {
        cerr << "Not implemented yet! Use --help instead." << endl;
        // exit
        throw TCLAP::ExitException(0); 
    }

    // -----------------------------------------------------------------------
    // member variables
protected:


    // -----------------------------------------------------------------------
    // unsupported
private:

    XmlVisitor(const XmlVisitor&);            ///< Not implemented.
    XmlVisitor& operator=(const XmlVisitor&); ///< Not implemented.

}; // class XmlVisitor

// ===========================================================================
// class: ManPageVisitor
// ===========================================================================

/**
 * @brief Displays man page and exits.
 */
class ManPageVisitor: public TCLAP::Visitor
{
    // -----------------------------------------------------------------------
    // construction / destruction
public:

    /**
     * @brief Constructor.
     */
    ManPageVisitor()
    :
        Visitor()
    { }

    // -----------------------------------------------------------------------
    // interface function
public:

    /**
     * @brief Print help.
     */
    void visit()
    {
        cerr << "Not implemented yet! Use --help instead." << endl;
        // exit
        throw TCLAP::ExitException(0);
    }

    // -----------------------------------------------------------------------
    // member variables
protected:


    // -----------------------------------------------------------------------
    // unsupported
private:

    ManPageVisitor(const ManPageVisitor&);            ///< Not implemented.
    ManPageVisitor& operator=(const ManPageVisitor&); ///< Not implemented.

}; // class ManPageVisitor

// ===========================================================================
// class: CmdLine
// ===========================================================================

// ---------------------------------------------------------------------------
CmdLine::CmdLine(const std::string& name,
                 const std::string& project,
                 const std::string& description,
                 const std::string& example,
                 const std::string& version,
                 const std::string& copyright,
                 const std::string& license,
                 const std::string& contact,
                 bool               stdargs)
:
    TCLAP::CmdLine(description, ' ', version, false),
    _xorHandler(XorHandler()),
    _name(name),
    _project(project),
    _copyright(copyright),
    _license(license),
    _contact(contact)
{
    if (example != "") _examples.push_back(example);
    setup(stdargs);
}

// ---------------------------------------------------------------------------
CmdLine::CmdLine(const std::string&              name,
                 const std::string&              project,
                 const std::string&              description,
                 const std::vector<std::string>& examples,
                 const std::string&              version,
                 const std::string&              copyright,
                 const std::string&              license,
                 const std::string&              contact,
                 bool                            stdargs)
:
    TCLAP::CmdLine(description, ' ', version, false),
    _xorHandler(XorHandler()),
    _name(name),
    _project(project),
    _examples(examples),
    _copyright(copyright),
    _license(license),
    _contact(contact)
{
    setup(stdargs);
}

// ---------------------------------------------------------------------------
void CmdLine::setup(bool stdargs)
{
    // replace output handler
    StdOutput* output = new StdOutput(this);
    if (_output) delete _output;
    _output = output;

    // remove arguments added by TCLAP::CmdLine (ignore)
    ClearContainer(_argDeleteOnExitList);
    ClearContainer(_visitorDeleteOnExitList);
    TCLAP::CmdLine::_argList.clear();

    // add standard arguments
    TCLAP::Visitor* v;

    v = new TCLAP::IgnoreRestVisitor();
    SwitchArg* ignore  = new SwitchArg(
              TCLAP::Arg::flagStartString(), TCLAP::Arg::ignoreNameString(),
              "Ignores the rest of the labeled arguments.",
              false, v);
    add(ignore);
    deleteOnExit(ignore);
    deleteOnExit(v);

    if (stdargs) {
        v = new HelpVisitor(output, true);
        TCLAP::SwitchArg* help = new TCLAP::SwitchArg(
                "h", "help", "Display help and exit.", false, v);
        add(help);
        deleteOnExit(help);
        deleteOnExit(v);

        v = new HelpVisitor(output, false);
        TCLAP::SwitchArg* helpshort = new TCLAP::SwitchArg(
                "", "helpshort", "Display short help and exit.", false, v);
        add(helpshort);
        deleteOnExit(helpshort);
        deleteOnExit(v);

        v = new XmlVisitor();
        TCLAP::SwitchArg* helpxml = new TCLAP::SwitchArg(
                "", "helpxml", "Display help in XML format and exit.", false, v);
        add(helpxml);
        deleteOnExit(helpxml);
        deleteOnExit(v);

        v = new ManPageVisitor();
        TCLAP::SwitchArg* helpman = new TCLAP::SwitchArg(
                "", "helpman", "Display help as man page and exit.", false, v);
        add(helpman);
        deleteOnExit(helpman);
        deleteOnExit(v);

        v = new TCLAP::VersionVisitor(this, &_output);
        TCLAP::SwitchArg* vers = new TCLAP::SwitchArg(
                "", "version", "Display version information and exit.", false, v);
        add(vers);
        deleteOnExit(vers);
        deleteOnExit(v);
    }
}

// -----------------------------------------------------------------------
void CmdLine::add(Arg& a)
{
    TCLAP::CmdLine::add(a);
}

// -----------------------------------------------------------------------
void CmdLine::add(Arg* a)
{
    TCLAP::CmdLine::add(a);
}

// -----------------------------------------------------------------------
void CmdLine::xorAdd(Arg& a, Arg& b)
{
    vector<TCLAP::Arg*> xors;
    xors.push_back(&a);
    xors.push_back(&b);
    xorAdd(xors);
}

// -----------------------------------------------------------------------
void CmdLine::print_usage() const
{
    _output->usage(*const_cast<CmdLine*>(this));
}

// -----------------------------------------------------------------------
void CmdLine::print_help() const
{
    StdOutput* output = dynamic_cast<StdOutput*>(_output);
    if (output) output ->help (*const_cast<CmdLine*>(this));
    else        _output->usage(*const_cast<CmdLine*>(this));
}

// -----------------------------------------------------------------------
void CmdLine::print_version() const
{
    _output->version(*const_cast<CmdLine*>(this));
}

// -----------------------------------------------------------------------
void CmdLine::xorAdd(vector<Arg*>& xors)
{
    _xorHandler.add(xors);
    bool required = false;
    for (TCLAP::ArgVectorIterator it = xors.begin(); it != xors.end(); ++it) {
        if ((*it)->isRequired()) required = true;
    }
    for (TCLAP::ArgVectorIterator it = xors.begin(); it != xors.end(); ++it) {
        if (required) (*it)->forceRequired();
        (*it)->setRequireLabel("OR required");
        add(*it);
    }
}

// -----------------------------------------------------------------------
void CmdLine::parse(int argc, const char * const * argv)
{
    vector<string> args(argc);
    for (int i = 0; i < argc; i++) args[i] = argv[i];
    parse(args);
}

// -----------------------------------------------------------------------
void CmdLine::parse(vector<string>& args)
{
    bool shouldExit = false;
    int estat = 0;

    try {
        _progName = os::exename();
        args.erase(args.begin());

        int requiredCount = 0;
        for (int i = 0; static_cast<unsigned int>(i) < args.size(); i++) {
            bool matched = false;
            for (TCLAP::ArgListIterator it = _argList.begin(); it != _argList.end(); it++) {
                if ((*it)->processArg(&i, args)) {
                    requiredCount += _xorHandler.check(*it);
                    matched = true;
                    break;
                }
            }
            if (!matched && _emptyCombined(args[i])) matched = true;
            if (!matched && !TCLAP::Arg::ignoreRest()) {
                throw TCLAP::CmdLineParseException("Couldn't find match for argument", args[i]);
            }
        }

        if (requiredCount < _numRequired) {
            string args;
            for (TCLAP::ArgListIterator it = _argList.begin(); it != _argList.end(); it++) {
                if ((*it)->isRequired() && !(*it)->isSet()) {
                    args += (*it)->getName();
                    args += ", ";
                }
            }
            args = args.substr(0, args.length() - 2);
            string msg = string("Not all required arguments specified, missing: ") + args;
            throw CmdLineParseException(msg);
        }
        if (requiredCount > _numRequired) {
            throw TCLAP::CmdLineParseException("Too many arguments given!");
        }

    } catch (TCLAP::ArgException& e) {
        if (!_handleExceptions) throw;
        try {
            _output->failure(*this, e);
        } catch (TCLAP::ExitException& ee) {
            estat = ee.getExitStatus();
            shouldExit = true;
        }
    } catch (TCLAP::ExitException& ee) {
        if (!_handleExceptions) throw;
        estat = ee.getExitStatus();
        shouldExit = true;
    }

    if (shouldExit) exit(estat);
}


} // namespace basis
