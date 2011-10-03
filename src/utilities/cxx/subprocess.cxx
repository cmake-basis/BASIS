/**
 * @file subprocess.cxx
 * @brief Definition of SubProcess.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */


#include <exception>

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

// ***************************************************************************
const char* olds[] = {"\\b", "\\\"", "\\'", "\\\\", "\\a", "\\?"};
const char* news[] = {"\b",  "\"",   "\'",  "\\",   "\a",  "\?"};

// ***************************************************************************
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

// ***************************************************************************
SubProcess
::SubProcess (const Arguments&   args,
              const RedirectMode in,
              const RedirectMode out,
              const RedirectMode err,
              const Environment* env)
:
    env_(NULL)
{
#if WINDOWS
    ZeroMemory (info_, sizeof (info_));
#else
    info_.pid = 0;
#endif

    args_ = args;
    stdin_mode_  = in;
    stdout_mode_ = out;
    stderr_mode_ = err;

    if (env) {
        env_ = new Environment();
        *env_ = *env;
    }
}

// ***************************************************************************
SubProcess
::~SubProcess ()
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
    if (env_) delete env_;
}

// ===========================================================================
// process control
// ===========================================================================

// ***************************************************************************
bool SubProcess::run(bool w)
{
#if WINDOWS
    // TODO
#else

    // create pipes for standard input/output
    int fdsin [2] = {-1, -1};
    int fdsout[2] = {-1, -1};
    int fdserr[2] = {-1, -1};

    if (stdin_mode_ == RM_PIPE && pipe(fdsin) == -1) {
        return false;
    }

    if (stdout_mode_ == RM_PIPE && pipe(fdsout) == -1) {
        if (fdsin[0] != -1) close(fdsin[0]);
        if (fdsin[1] != -1) close(fdsin[1]);
        return false;
    }

    if (stderr_mode_ == RM_PIPE && pipe(fdserr) == -1) {
        if (fdsin [0] != -1) close(fdsin  [0]);
        if (fdsin [1] != -1) close(fdsin  [1]);
        if (fdsout[0] != -1) close(fdsout [0]);
        if (fdsout[1] != -1) close(fdsout [1]);
        return false;
    }

    // fork this process
    if ((info_.pid = fork()) == -1) {
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
        if (stderr_mode_ == RM_STDOUT) {
            dup2(1, 2);
        } else if (fdserr[1] != -1) {
            dup2(fdserr[1], 2);
            close(fdserr[1]);
        }

        // execute command
        char** argv = NULL;
        char** envp = NULL;

        argv = new char*[args_.size() + 1];
        for (unsigned int i = 0; i < args_.size(); i++) {
            argv[i] = const_cast<char*>(args_[i].c_str());
        }
        argv[args_.size()] = NULL;

        if (env_) {
            envp = new char*[env_->size() + 1];
            for (unsigned int i = 0; i < env_->size(); ++ i) {
                envp[i] = const_cast<char*>(env_->at(i).c_str());
            }
            envp[env_->size()] = NULL;

            execve(argv[0], argv, envp);
        } else {
            execv(argv[0], argv);
        }

        // we should have never got here...
        delete [] argv;
        delete [] envp;

        std::terminate();

    } else {

        // close unused ends of pipes
        if (fdsin [0] != -1) close(fdsin [0]);
        if (fdsout[1] != -1) close(fdsout[1]);
        if (fdserr[1] != -1) close(fdserr[1]);

        // store file descriptors of parent side of pipes
        stdin_  = fdsin [1];
        stdout_ = fdsout[0];
        stderr_ = fdserr[0];

    }
#endif

    if (w) return wait();
    else   return true;
}

// ***************************************************************************
bool SubProcess::wait()
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

// ***************************************************************************
bool SubProcess::terminate()
{
#if WINDOWS
    // note: 130 is the exit code used by Unix shells to indicate CTRL + C
    return TerminateProcess(info.hProcess, 130) != 0;
#else
    return ::kill(info_.pid, SIGTERM) == 0;
#endif
}

// ***************************************************************************
bool SubProcess::kill()
{
#if WINDOWS
    terminate();
#else
    return ::kill(info_.pid, SIGKILL) == 0;
#endif
}

// ***************************************************************************
bool SubProcess::terminated() const
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
    return WIFEXITED(status_);
#endif
}

// ***************************************************************************
bool SubProcess::signaled() const
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

// ***************************************************************************
int SubProcess::returncode() const
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

// TODO

// ===========================================================================
// static methods
// ===========================================================================

int SubProcess::call(const string& cmd)
{
    Arguments args;

    // parse command-line
    const char whitespace[] = " \f\n\r\t\v";
    for (string::size_type i = 0, j = 0; (j != string::npos) && (i < cmd.size()); i++) {
        if (cmd[i] == '\"') {
            j = i;
            do {
                j = cmd.find('\"', ++j);
            } while ((j != string::npos) && (cmd[j - 1] == '\\'));
            args.push_back(cmd.substr(i, j - i));
            i = j;
        } else if (isspace(cmd[i])) {
            j = cmd.find_first_not_of(whitespace, i);
            i = j -1;
        } else {
            j = i;
            do {
                j = cmd.find_first_of(whitespace, ++j);
            } while ((j != string::npos) && (cmd[j - 1] == '\\'));
            args.push_back(cmd.substr(i, j - i));
            i = j - 1;
        }
    }

    // replace special characters
    for_each(args.begin(), args.end(), ConvertSpecialChars() );

    // create and run subprocess
    SubProcess p(args);

    if (p.run()) return p.returncode();
    else         return -1;
}


SBIA_BASIS_NAMESPACE_END
