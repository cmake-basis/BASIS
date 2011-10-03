/**
 * @file subprocess.cxx
 * @brief Definition of module used to execute subprocesses.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <iostream>

#include <cstdlib>
#include <cassert>

#include <sbia/basis/config.h>

#if UNIX
#  include <sys/wait.h>
#  include <signal.h>
#endif

#include <sbia/basis/exceptions.h>
#include <sbia/basis/subprocess.h>


using namespace std;


SBIA_BASIS_NAMESPACE_BEGIN


// ===========================================================================
// helpers
// ===========================================================================

static const char* olds[] = {"\\b", "\\\"", "\\'", "\\\\", "\\a", "\\?"};
static const char* news[] = {"\b",  "\"",   "\'",  "\\",   "\a",  "\?"};

/**
 * @brief Function object used to convert special characters in command-line
 *        given as single string.
 */
struct ConvertSpecialChars
{
    string operator ()(const string& str)
    {
        string result(str);
        string::size_type i;
        for (unsigned int n = 0; n < 6; n++) {
            while ((i = result.find(olds[n])) != string::npos) {
                result.replace(i, strlen(olds[n]), news[n]);
            }
        }
        return result;
    }
}; // struct ConvertSpecialChars

// ===========================================================================
// construction / destruction
// ===========================================================================

// ---------------------------------------------------------------------------
Subprocess::Subprocess ()
{
#if WINDOWS
    ZeroMemory(info_);
    stdin_ = INVALID_HANDLE_VALUE;
    stdout_ = INVALID_HANDLE_VALUE;
    stderr_ = INVALID_HANDLE_VALUE;
#else
    info_.pid = -1;
    stdin_ = -1;
    stdout_ = -1;
    stderr_ = -1;
#endif
    status_ = -1;
}

// ---------------------------------------------------------------------------
Subprocess::~Subprocess ()
{
#if WINDOWS
    if (info_.hProcess) {
        terminate();
        CloseHandle(info_.hProcess);
        CloseHandle(info_.hThread);
    }
#else
    if (info_.pid != 0) kill();
#endif
}

// ===========================================================================
// process control
// ===========================================================================

// ---------------------------------------------------------------------------
bool Subprocess::popen(const CommandLine& args,
                       const RedirectMode stdin,
                       const RedirectMode stdout,
                       const RedirectMode stderr,
                       const Environment* env)
{
#if WINDOWS
    if (info_.hProcess != 0 && !poll()) {
        cerr << "Subprocess::popen(): Previously opened process not terminated yet!" << endl;
        return false;
    }

    ZeroMemory(info_, sizeof(info_));
    stdin_ = INVALID_HANDLE_VALUE;
    stdout_ = INVALID_HANDLE_VALUE;
    stderr_ = INVALID_HANDLE_VALUE;
    status_ = -1;

    // TODO
#  pragma error "not implemented yet for Windows"
#else
    if (info_.pid != -1 && !poll()) {
        cerr << "Subprocess::popen(): Previously opened process not terminated yet!" << endl;
        return false;
    }

    info_.pid = -1;
    stdin_ = -1;
    stdout_ = -1;
    stderr_ = -1;
    status_ = -1;

    // create pipes for standard input/output
    int fdsin [2] = {-1, -1};
    int fdsout[2] = {-1, -1};
    int fdserr[2] = {-1, -1};

    if (stdin == RM_PIPE && pipe(fdsin) == -1) {
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    if (stdout == RM_PIPE && pipe(fdsout) == -1) {
        if (fdsin[0] != -1) close(fdsin[0]);
        if (fdsin[1] != -1) close(fdsin[1]);
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    if (stderr == RM_PIPE && pipe(fdserr) == -1) {
        if (fdsin [0] != -1) close(fdsin  [0]);
        if (fdsin [1] != -1) close(fdsin  [1]);
        if (fdsout[0] != -1) close(fdsout [0]);
        if (fdsout[1] != -1) close(fdsout [1]);
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    // fork this process
    if ((info_.pid = fork()) == -1) {
        cerr << "Subprocess::popen(): Failed to fork process!" << endl;
        return false;
    }

    if (info_.pid == 0) {

        // close unused ends of pipes
        if (fdsin [1] != -1) close(fdsin [1]);
        if (fdsout[0] != -1) close(fdsout[0]);
        if (fdserr[0] != -1) close(fdserr[0]);

        // redirect standard input/output
        //
        // TODO
        // See http://www.unixwiz.net/techtips/remap-pipe-fds.html for details
        // on why it could happen that the created pipes use file descriptors
        // which are already either one of the three standard file descriptors.

        if (fdsin[0] != -1) {
            dup2(fdsin[0], 0);
            close(fdsin[0]);
        }
        if (fdsout[1] != -1) {
            dup2(fdsout[1], 1);
            close(fdsout[1]);
        }
        if (stderr == RM_STDOUT) {
            dup2(1, 2);
        } else if (fdserr[1] != -1) {
            dup2(fdserr[1], 2);
            close(fdserr[1]);
        }

        // redirect standard input/output
        // execute command
        char** argv = NULL;

        argv = new char*[args.size() + 1];
        for (unsigned int i = 0; i < args.size(); i++) {
            argv[i] = const_cast<char*>(args[i].c_str());
        }
        argv[args.size()] = NULL;

        if (env) {
            // TODO: Reset environment first
            for (unsigned int i = 0; i < env->size(); ++ i) {
                putenv(const_cast<char*>(env->at(i).c_str()));
            }
        }
        execvp(argv[0], argv);

        cerr << "Subprocess::popen(): Failed to execute command!" << endl;

        // we should have never got here...
        delete [] argv;

        exit(EXIT_FAILURE);

    } else {

        // close unused ends of pipes
        if (fdsin [0] != -1) close(fdsin [0]);
        if (fdsout[1] != -1) close(fdsout[1]);
        if (fdserr[1] != -1) close(fdserr[1]);

        // store file descriptors of parent side of pipes
        stdin_  = fdsin [1];
        stdout_ = fdsout[0];
        stderr_ = fdserr[0];

        return true;
    }
#endif
}

// ---------------------------------------------------------------------------
bool Subprocess::popen(const string&      cmd,
                       const RedirectMode stdin,
                       const RedirectMode stdout,
                       const RedirectMode stderr,
                       const Environment* env)
{
    CommandLine cmdline;

    // parse command-line
    const char whitespace[] = " \f\n\r\t\v";
    for (string::size_type i = 0, j = 0; (j != string::npos) && (i < cmd.size()); i++) {
        if (cmd[i] == '\"') {
            j = i;
            do {
                j = cmd.find('\"', ++j);
            } while ((j != string::npos) && (cmd[j - 1] == '\\'));
            if (j == string::npos) cmdline.push_back(cmd.substr(i));
            else cmdline.push_back(cmd.substr(i + 1, j - i - 1));
            i = j;
        } else if (isspace(cmd[i])) {
            j = cmd.find_first_not_of(whitespace, i);
            i = j - 1;
        } else {
            j = i;
            do {
                j = cmd.find_first_of(whitespace, ++j);
            } while ((j != string::npos) && (cmd[j - 1] == '\\'));
            cmdline.push_back(cmd.substr(i, j - i));
            i = j - 1;
        }
    }

    // replace special characters
    for_each(cmdline.begin(), cmdline.end(), ConvertSpecialChars());

    // create subprocess
    return popen(cmdline, stdin, stdout, stderr, env);
}

// ---------------------------------------------------------------------------
bool Subprocess::poll() const
{
#if WINDOWS
    if (GetExitCodeProcess(info_.hProcess, status_)) {
        return status_ != STILL_ACTIVE;
    }
    BASIS_THROW(runtime_error, "GetExitCodeProcess() failed");
#else
    if (waitpid(info_.pid, &status_, WNOHANG | WUNTRACED | WCONTINUED) == info_.pid) {
        BASIS_THROW(runtime_error, "waitpid() failed");
    }
    return WIFEXITED(status_) || WIFSIGNALED(status_);
#endif
}

// ---------------------------------------------------------------------------
bool Subprocess::wait()
{
#if WINDOWS
    if (WaitForSingleObject(info_.hProcess, INFINITE) == WAIT_FAIL) {
        return false;
    }

    return GetExitCodeProcess(info_.hProcess, status_);
#else
    return waitpid(info_.pid, &status_, 0) == info_.pid;
#endif
}

// ---------------------------------------------------------------------------
bool Subprocess::send_signal(int signal)
{
#if WINDOWS
    if (signal == 9)  return kill();
    if (signal == 15) return terminate();
    return false;
#else
    return ::kill(info_.pid, signal) == 0;
#endif
}

// ---------------------------------------------------------------------------
bool Subprocess::terminate()
{
#if WINDOWS
    // note: 130 is the exit code used by Unix shells to indicate CTRL + C
    return TerminateProcess(info.hProcess, 130) != 0;
#else
    return ::kill(info_.pid, SIGTERM) == 0;
#endif
}

// ---------------------------------------------------------------------------
bool Subprocess::kill()
{
#if WINDOWS
    terminate();
#else
    return ::kill(info_.pid, SIGKILL) == 0;
#endif
}


// ---------------------------------------------------------------------------
bool Subprocess::signaled() const
{
#if WINDOWS
    if (GetExitCodeProcess(info_.hProcess, status_)) {
        return status_ == 130;
    }
    BASIS_THROW(runtime_error, "GetExitCodeProcess() failed");
#else
    if (waitpid(info_.pid, &status_, WNOHANG | WUNTRACED | WCONTINUED) == info_.pid) {
        BASIS_THROW(runtime_error, "waitpid() failed");
    }
    return WIFSIGNALED(status_);
#endif
}

// ---------------------------------------------------------------------------
int Subprocess::pid() const
{
#if WINDOWS
    return info_.dwProcessId;
#else
    return info_.pid;
#endif
}

// ---------------------------------------------------------------------------
int Subprocess::returncode() const
{
#if WINDOWS
    return status_;
#else
    return WEXITSTATUS(status_);
#endif
}

// ===========================================================================
// inter-process communication
// ===========================================================================

// ---------------------------------------------------------------------------
bool Subprocess::communicate(std::istream& in, std::ostream& out, std::ostream& err)
{
    const size_t nbuf = 1024;
    char buf[nbuf];

    // write stdin data and close pipe afterwards
#if WINDOWS
    if (stdin_ != INVALID_HANDLE_VALUE) {
#else
    if (stdin_ != -1) {
#endif
        while (!in.eof()) {
            in.read(buf, nbuf);
            if(in.bad()) return false;
            write(buf, in.gcount());
        }
#if WINDOWS
        CloseHandle(stdin_);
        stdin_ = INVALID_HANconst CommandLine& cmd,
                        const RedirectMode in,
                        const RedirectMode out,
                        const RedirectMode err,
                        const Environment* envDLE_VALUE;
#else
        close(stdin_);
        stdin_ = -1;
#endif
    }
    // read stdout data and close pipe afterwards
#if WINDOWS
    if (stdout_ != INVALID_HANDLE_VALUE) {
#else
    if (stdout_ != -1) {
#endif
        while (out.good()) {
            int n = read(buf, nbuf);
            if (n == -1) return false;
            if (n == 0) break;
            out.write(buf, n);
            if (out.bad()) return false;
        }
#if WINDOWS
        CloseHandle(stdout_);
        stdout_ = INVALID_HANDLE_VALUE;
#else
        close(stdout_);
        stdout_ = -1;
#endif
    }
    // read stdout data and close pipe afterwards
#if WINDOWS
    if (stderr_ != INVALID_HANDLE_VALUE) {
#else
    if (stderr_ != -1) {
#endif
        while (err.good()) {
            int n = read(buf, nbuf, true);
            if (n == -1) return false;
            if (n == 0) break;
            err.write(buf, n);
            if (err.bad()) return false;
        }
#if WINDOWS
        CloseHandle(stderr_);
        stderr_ = INVALID_HANDLE_VALUE;
#else
        close(stderr_);
        stderr_ = -1;
#endif
    }
    // wait for subprocess
    return wait();
}

// ---------------------------------------------------------------------------
bool Subprocess::communicate(std::ostream& out, std::ostream& err)
{
    std::istringstream in;
#if WINDOWS
    CloseHandle(stdin_);
    stdin_ = INVALID_HANDLE_VALUE;
#else
    close(stdin_);
    stdin_ = -1;
#endif
    return communicate(in, out, err);
}

// ---------------------------------------------------------------------------
bool Subprocess::communicate(std::ostream& out)
{
    std::istringstream in;
    std::ostringstream err;
#if WINDOWS
    CloseHandle(stdin_);
    stdin_ = INVALID_HANDLE_VALUE;
    CloseHandle(stderr_);
    stderr_ = INVALID_HANDLE_VALUE;
#else
    close(stdin_);
    stdin_ = -1;
    close(stderr_);
    stderr_ = -1;
#endif
    return communicate(in, out, err);
}

// ---------------------------------------------------------------------------
int Subprocess::write(const void* buf, size_t nbuf)
{
#if WINDOWS
    // TODO
#  pragma error "not implemented yet for Windows"
#else
    return stdin_ != -1 ? ::write(stdin_, buf, nbuf) : -1;
#endif
}

// ---------------------------------------------------------------------------
int Subprocess::read(void* buf, size_t nbuf, bool err)
{
#if WINDOWS
    // TODO
#  pragma error "not implemented yet for Windows"
#else
    int fds = stdout_;
    if (err && stderr_ != -1) fds = stderr_;
    return ::read(fds, buf, nbuf);
#endif
}

// ===========================================================================
// static methods
// ===========================================================================

// ---------------------------------------------------------------------------
int Subprocess::call(const CommandLine& cmd)
{
    Subprocess p;
    if (p.popen(cmd) && p.wait()) return p.returncode();
    return -1;
}

// ---------------------------------------------------------------------------
int Subprocess::call(const string& cmd)
{
    Subprocess p;
    if (p.popen(cmd) && p.wait()) return p.returncode();
    return -1;
}


SBIA_BASIS_NAMESPACE_END
