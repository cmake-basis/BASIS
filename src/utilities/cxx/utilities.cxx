/**
 * @file  utilities.cxx
 * @brief Main module of project-independent BASIS utilities.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <basis/subprocess.h>
#include <basis/utilities.h>


// acceptable in .cxx file
using namespace std;


namespace basis { namespace util {


// ===========================================================================
// executable information
// ===========================================================================

// ---------------------------------------------------------------------------
void print_contact(const char* contact)
{
    cout << "Contact:\n  " << contact << endl;
}

// ---------------------------------------------------------------------------
void print_version(const char* name, const char* version, const char* project,
                   const char* copyright, const char* license)
{
    assert(name    != NULL);
    assert(version != NULL);
    cout << name;
    if (project && *project) cout << " (" << project << ")";
    cout << " " << version << endl;
    if (copyright && *copyright) cout << "Copyright (c) " << copyright << ". All rights reserved." << endl;
    if (license && *license) cout << license << endl;
}

// ---------------------------------------------------------------------------
string targetuid(const string& name, const IExecutableTargetInfo* targets)
{
    return targets != NULL ? targets->targetuid(name) : "";
}

// ---------------------------------------------------------------------------
bool istarget(const string& name, const IExecutableTargetInfo* targets)
{
    return targets != NULL && targets->istarget(name);
}

// ---------------------------------------------------------------------------
string exepath(const string& name, const IExecutableTargetInfo* targets)
{
    // return path of this executable if no name given
    if (name.empty()) return os::exepath();
    // get name of executable and check if target name is known
    string exec_name = targets != NULL ? targets->basename(name) : "";
    // if target is not known
    if (exec_name.empty()) {
        // return input argument assuming that it is already the path of
        // an executable file
        exec_name = name;
        // try to get absolute path using the which command if path is relative
        // TODO Replace use of external which command by C++ implementation
        //      of which() even though BASIS includes a Python implementation
        //      that can also be used on Windows. Still, a native C++
        //      implementation is desireable.
        if (!os::path::isabs(exec_name) && targets->istarget("basis.which")) {
            vector<string> which(2);
            which[0] = "basis.which";
            which[1] = name;
            ostringstream oss;
            // attention: this includes a "recursive" call of this function!
            if (execute(which, true, &oss, true, 0, false, targets) == 0) {
                exec_name = oss.str();
                const string::size_type end = exec_name.find_last_not_of(" \t\n\r");
                if (end == string::npos) {
                    exec_name = "";
                } else {
                    exec_name.erase(end + 1);
                }
            }
        }
        return exec_name;
    }
    return os::path::join(targets->dirname(name), exec_name);
}

// ---------------------------------------------------------------------------
string exename(const std::string& name, const IExecutableTargetInfo* targets)
{
    string exec_path = exepath(name, targets);
    if (exec_path.empty()) return "";
#if WINDOWS
    string fname, ext;
    os::path::splitext(exec_path, fname, ext);
    if (ext == ".exe" || ext == ".com") exec_path = fname;
#endif
    return os::path::basename(exec_path);
}

// ---------------------------------------------------------------------------
string exedir(const std::string& name, const IExecutableTargetInfo* targets)
{
    string exec_path = exepath(name, targets);
    return exec_path.empty() ? "" : os::path::dirname(exec_path);
}

// ===========================================================================
// command execution
// ===========================================================================

// ---------------------------------------------------------------------------
string tostring(const vector<string>& args)
{
    return Subprocess::tostring(args);
}

// ---------------------------------------------------------------------------
vector<string> qsplit(const string& args)
{
    return Subprocess::split(args);
}

// ---------------------------------------------------------------------------
int execute(const string& cmd, bool quiet, ostream* out,
            bool allow_fail, int verbose, bool simulate,
            const IExecutableTargetInfo* targets)
{
    vector<string> args = Subprocess::split(cmd);
    return execute(args, quiet, out, allow_fail, verbose, simulate, targets);
}

// ---------------------------------------------------------------------------
int execute(vector<string> args, bool quiet, ostream* out,
            bool allow_fail, int verbose, bool simulate,
            const IExecutableTargetInfo* targets)
{
    if (args.empty() || args[0].empty()) {
        BASIS_THROW(SubprocessError, "execute_process(): No command specified");
    }
    // map build target name to executable file path
    string exec_path = exepath(args[0], targets);
    // prepend absolute path of found executable
    if (!exec_path.empty()) args[0] = exec_path;
    // some verbose output
    if (verbose > 0 || simulate) {
        cout << "$ " << Subprocess::tostring(args);
        if (simulate) cout << " (simulated)";
        cout << endl;
    }
    // execute command
    char buf[1024];
    int  n;
    int status = 0;
    Subprocess p;
    if (!p.popen(args, Subprocess::RM_NONE, Subprocess::RM_PIPE, Subprocess::RM_PIPE)) {
        BASIS_THROW(SubprocessError, "execute_process(): Failed to create subprocess");
    }
    // read child's stdout (blocking)
    if (!quiet || out != NULL) {
        while ((n = p.read(buf, 1023)) > 0) {
            buf[n] = '\0';
            if (!quiet) {
                cout << buf;
                cout.flush();
            }
            if (out) *out << buf;
        }
    }
    // wait for child process
    if (!p.wait()) {
        BASIS_THROW(SubprocessError, "execute_process(): Failed to wait for subprocess");
    }
    // write error messages to stderr of parent process
    while ((n = p.read(buf, 1023, true)) > 0) {
        buf[n] = '\0';
        cerr << buf;
    }
    // get exit code
    status = p.returncode();
    // if command failed, throw an exception
    if (status != 0 && !allow_fail) {
        BASIS_THROW(SubprocessError, "Command " << Subprocess::tostring(args) << " failed");
    }
    return status;
}


} } // end of namespaces
