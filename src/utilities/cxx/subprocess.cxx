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
#include <cassert>   // assert
#include <cstring>   // strlen
#include <algorithm> // for_each

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

// ---------------------------------------------------------------------------
// Attention: Order matters! First, escaped backslashes are converted to
//            the unused ASCII character 255 and finally these characters are
//            replaced by single backslashes.
static const char* olds[] = {"\\\\", "\\\"", "\xFF"};
static const char* news[] = {"\xFF", "\"",   "\\"};

/**
 * @brief Function object used to convert special characters in command-line
 *        given as single string.
 */
struct ConvertSpecialChars
{
    void operator ()(string& str)
    {
        string::size_type i;
        for (unsigned int n = 0; n < 3; n++) {
            while ((i = str.find(olds[n])) != string::npos) {
                str.replace(i, strlen(olds[n]), news[n]);
            }
        }
    }
}; // struct ConvertSpecialChars

// ---------------------------------------------------------------------------
Subprocess::CommandLine Subprocess::split(const string& cmd)
{
    const char whitespace[] = " \f\n\r\t\v";

    CommandLine args;
    string::size_type j;
    string::size_type k;
    unsigned int      n;

    for (string::size_type i = 0; i < cmd.size(); i++) {
        if (cmd[i] == '\"') {
            j = i;
            do {
                j = cmd.find('\"', ++j);
                if (j == string::npos) break;
                // count number of backslashes to determine whether this
                // double quote is escaped or not
                k = j;
                n = 0;
                // Note: There is at least the leading double quote (").
                //       Hence, k will always be > 0 here.
                while (cmd[--k] == '\\') n++;
                // continue while found double quote is escaped
            } while (n % 2);
            // if trailing double quote is missing, consider leading
            // double quote to be part of argument which extends to the
            // end of the entire string
            if (j == string::npos) {
                args.push_back(cmd.substr(i));
                break;
            } else {
                args.push_back(cmd.substr(i + 1, j - i - 1));
                i = j;
            }
        } else if (isspace(cmd[i])) {
            j = cmd.find_first_not_of(whitespace, i);
            i = j - 1;
        } else {
            j = i;
            do {
                j = cmd.find_first_of(whitespace, ++j);
                if (j == string::npos) break;
                // count number of backslashes to determine whether this
                // whitespace character is escaped or not
                k = j;
                n = 0;
                if (cmd[j] == ' ') {
                    // Note: The previous else block handles whitespaces
                    //       in between arguments including leading whitespaces.
                    //       Hence, k will always be > 0 here.
                    while (cmd[--k] == '\\') n++;
                }
                // continue while found whitespace is escaped
            } while (n % 2);
            if (j == string::npos) {
                args.push_back(cmd.substr(i));
                break;
            } else {
                args.push_back(cmd.substr(i, j - i));
                i = j - 1;
            }
        }
    }

    for_each(args.begin(), args.end(), ConvertSpecialChars());

    return args;
}

// ---------------------------------------------------------------------------
string Subprocess::to_string(const CommandLine& args)
{
    const char whitespace[] = " \f\n\r\t\v";

    string cmd;
    string arg;
    string::size_type j;

    for (CommandLine::const_iterator i = args.begin(); i != args.end(); ++i) {
        if (!cmd.empty()) cmd.push_back(' ');
        if (i->find_first_of(whitespace) != string::npos) {
            arg = *i;
            // escape backslashes (\) and double quotes (")
            j = arg.find_first_of("\\\"");
            while (j != string::npos) {
                arg.insert(j, 1, '\\');
                j = arg.find_first_of("\\\"", j + 2);
            }
            // surround argument by double quotes
            cmd.push_back('\"');
            cmd.append(arg);
            cmd.push_back('\"');
        } else {
            cmd.append(*i);
        }
    }
    return cmd;
}

// ===========================================================================
// construction / destruction
// ===========================================================================

// ---------------------------------------------------------------------------
Subprocess::Subprocess ()
{
#if WINDOWS
    ZeroMemory(&info_, sizeof(info_));
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
        if (stdin_) CloseHandle(stdin_);
        if (stdout_) CloseHandle(stdout_);
        if (stderr_) CloseHandle(stderr_);
        CloseHandle(info_.hProcess);
        CloseHandle(info_.hThread);
    }
#else
    if (info_.pid != 0) kill();
    if (stdin_  != -1) close(stdin_);
    if (stdout_ != -1) close(stdout_);
    if (stderr_ != -1) close(stderr_);
#endif
}

// ===========================================================================
// process control
// ===========================================================================

// ---------------------------------------------------------------------------
bool Subprocess::popen(const CommandLine& args,
                       const RedirectMode rm_in,
                       const RedirectMode rm_out,
                       const RedirectMode rm_err,
                       const Environment* env)
{
#if WINDOWS
    if (info_.hProcess != 0 && !poll()) {
        cerr << "Subprocess::popen(): Previously opened process not terminated yet!" << endl;
        return false;
    }

    ZeroMemory(&info_, sizeof(info_));
    if (stdin_)  CloseHandle(stdin_);
    if (stdout_) CloseHandle(stdout_);
    if (stderr_) CloseHandle(stderr_);
    stdin_  = INVALID_HANDLE_VALUE;
    stdout_ = INVALID_HANDLE_VALUE;
    stderr_ = INVALID_HANDLE_VALUE;
    status_ = -1;

    SECURITY_ATTRIBUTES saAttr; 
    HANDLE hStdIn[2]  = {INVALID_HANDLE_VALUE, INVALID_HANDLE_VALUE}; // read, write
    HANDLE hStdOut[2] = {INVALID_HANDLE_VALUE, INVALID_HANDLE_VALUE};
    HANDLE hStdErr[2] = {INVALID_HANDLE_VALUE, INVALID_HANDLE_VALUE};
 
    // set the bInheritHandle flag so pipe handles are inherited
    saAttr.nLength              = sizeof(SECURITY_ATTRIBUTES); 
    saAttr.bInheritHandle       = TRUE; 
    saAttr.lpSecurityDescriptor = NULL;

    // create pipes for standard input/output
    if (rm_in == RM_PIPE && CreatePipe(&hStdIn[0], &hStdIn[1], &saAttr, 0) == 0) {
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    if (rm_out == RM_PIPE && CreatePipe(&hStdOut[0], &hStdOut[1], &saAttr, 0) == 0) {
        CloseHandle(hStdIn[0]);
        CloseHandle(hStdIn[1]);
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    if (rm_err == RM_PIPE && CreatePipe(&hStdErr[0], &hStdErr[1], &saAttr, 0) == 0) {
        CloseHandle(hStdIn[0]);
        CloseHandle(hStdIn[1]);
        CloseHandle(hStdOut[0]);
        CloseHandle(hStdOut[1]);
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    // ensure that handles not required by subprocess are not inherited
    if ((hStdIn[1] != INVALID_HANDLE_VALUE && !SetHandleInformation(hStdIn[1], HANDLE_FLAG_INHERIT, 0)) ||
            (hStdOut[0] != INVALID_HANDLE_VALUE && !SetHandleInformation(hStdOut[0], HANDLE_FLAG_INHERIT, 0)) ||
            (hStdErr[0] != INVALID_HANDLE_VALUE && !SetHandleInformation(hStdErr[0], HANDLE_FLAG_INHERIT, 0))) {
        CloseHandle(hStdIn[0]);
        CloseHandle(hStdIn[1]);
        CloseHandle(hStdOut[0]);
        CloseHandle(hStdOut[1]);
        CloseHandle(hStdErr[0]);
        CloseHandle(hStdErr[1]);
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    // create subprocess
    STARTUPINFO siStartInfo;
    ZeroMemory(&siStartInfo, sizeof(STARTUPINFO));
    siStartInfo.cb          = sizeof(STARTUPINFO); 
    siStartInfo.hStdError   = hStdErr[1];
    siStartInfo.hStdOutput  = hStdOut[1];
    siStartInfo.hStdInput   = hStdIn[0];
    siStartInfo.dwFlags    |= STARTF_USESTDHANDLES;

    string cmd = to_string(args);

    LPTSTR szCmdline = NULL;
#ifdef UNICODE
    int n = MultiByteToWideChar(CP_UTF8, 0, cmd.c_str(), -1, NULL, 0);
    szCmdline = new TCHAR[n];
    if (szCmdline) {
        MultiByteToWideChar(CP_UTF8, 0, cmd.c_str(), -1, szCmdline, n);
    } else {
        CloseHandle(hStdIn[0]);
        CloseHandle(hStdIn[1]);
        CloseHandle(hStdOut[0]);
        CloseHandle(hStdOut[1]);
        CloseHandle(hStdErr[0]);
        CloseHandle(hStdErr[1]);
        cerr << "Subprocess::popen(): Failed to allocate memory!" << endl;
        return false;
    }
#else
    szCmdline = new TCHAR[cmd.size() + 1];
    strncpy_s(szCmdline, cmd.size() + 1, cmd.c_str(), _TRUNCATE);
#endif

    if (!CreateProcess(NULL, 
                       szCmdline,    // command line 
                       NULL,         // process security attributes 
                       NULL,         // primary thread security attributes 
                       TRUE,         // handles are inherited 
                       0,            // creation flags 
                       NULL,         // use parent's environment 
                       NULL,         // use parent's current directory 
                       &siStartInfo, // STARTUPINFO pointer 
                       &info_)) {    // receives PROCESS_INFORMATION
        CloseHandle(hStdIn[0]);
        CloseHandle(hStdIn[1]);
        CloseHandle(hStdOut[0]);
        CloseHandle(hStdOut[1]);
        CloseHandle(hStdErr[0]);
        CloseHandle(hStdErr[1]);
        cerr << "Subprocess::popen(): Failed to fork process!" << endl;
        return false;
    }
 
    delete [] szCmdline;

    // close unused ends of pipes
    if (hStdIn[0]  != INVALID_HANDLE_VALUE) CloseHandle(hStdIn[0]);
    if (hStdOut[1] != INVALID_HANDLE_VALUE) CloseHandle(hStdOut[1]);
    if (hStdErr[1] != INVALID_HANDLE_VALUE) CloseHandle(hStdErr[1]);

    // store handles of parent side of pipes
    stdin_  = hStdIn[1];
    stdout_ = hStdOut[0];
    stderr_ = hStdErr[0];

    return true;
#else
    if (info_.pid != -1 && !poll()) {
        cerr << "Subprocess::popen(): Previously opened process not terminated yet!" << endl;
        return false;
    }

    info_.pid = -1;
    if (stdin_  != -1) close(stdin_);
    if (stdout_ != -1) close(stdout_);
    if (stderr_ != -1) close(stderr_);
    stdin_ = -1;
    stdout_ = -1;
    stderr_ = -1;
    status_ = -1;

    // create pipes for standard input/output
    int fdsin [2] = {-1, -1}; // read, write
    int fdsout[2] = {-1, -1};
    int fdserr[2] = {-1, -1};

    if (rm_in == RM_PIPE && pipe(fdsin) == -1) {
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    if (rm_out == RM_PIPE && pipe(fdsout) == -1) {
        if (fdsin[0] != -1) close(fdsin[0]);
        if (fdsin[1] != -1) close(fdsin[1]);
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    if (rm_err == RM_PIPE && pipe(fdserr) == -1) {
        if (fdsin[0]  != -1) close(fdsin[0]);
        if (fdsin[1]  != -1) close(fdsin[1]);
        if (fdsout[0] != -1) close(fdsout[0]);
        if (fdsout[1] != -1) close(fdsout[1]);
        cerr << "Subprocess::popen(): Failed to create pipe!" << endl;
        return false;
    }

    // fork this process
    if ((info_.pid = fork()) == -1) {
        if (fdsin[0]  != -1) close(fdsin[0]);
        if (fdsin[1]  != -1) close(fdsin[1]);
        if (fdsout[0] != -1) close(fdsout[0]);
        if (fdsout[1] != -1) close(fdsout[1]);
        if (fdserr[0] != -1) close(fdserr[0]);
        if (fdserr[1] != -1) close(fdserr[1]);
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
        if (rm_err == RM_STDOUT) {
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
bool Subprocess::poll() const
{
#if WINDOWS
    DWORD dwStatus = 0;
    if (GetExitCodeProcess(info_.hProcess, &dwStatus)) {
        status_ = static_cast<int>(dwStatus);
        return status_ != STILL_ACTIVE;
/*
        This should have been more save in case 259 is used as exit code
        by the process. However, it did not seem to work as expected.

        if (status_ == STILL_ACTIVE) {
            // if the process is terminated, this would return WAIT_OBJECT_0
            return WaitForSingleObject(info_.hProcess, 0) != WAIT_TIMEOUT;
        } else {
            return false;
        }
*/
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
    if (WaitForSingleObject(info_.hProcess, INFINITE) == WAIT_FAILED) {
        return false;
    }
    DWORD dwStatus = 0;
    BOOL bSuccess = GetExitCodeProcess(info_.hProcess, &dwStatus);
    if (bSuccess) {
        status_ = static_cast<int>(dwStatus);
        return true;
    } else return false;
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
    return TerminateProcess(info_.hProcess, 130) != 0;
#else
    return ::kill(info_.pid, SIGTERM) == 0;
#endif
}

// ---------------------------------------------------------------------------
bool Subprocess::kill()
{
#if WINDOWS
    return terminate();
#else
    return ::kill(info_.pid, SIGKILL) == 0;
#endif
}

// ---------------------------------------------------------------------------
bool Subprocess::signaled() const
{
#if WINDOWS
    DWORD dwStatus = 0;
    if (GetExitCodeProcess(info_.hProcess, &dwStatus)) {
        status_ = static_cast<int>(dwStatus);
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
        stdin_ = INVALID_HANDLE_VALUE;
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
    DWORD n;
    if (stdin_ == INVALID_HANDLE_VALUE) return -1;
    return WriteFile(stdin_, static_cast<const char*>(buf), nbuf, &n, NULL);
#else
    if (stdin_ == -1) return -1;
    return ::write(stdin_, buf, nbuf);
#endif
}

// ---------------------------------------------------------------------------
int Subprocess::read(void* buf, size_t nbuf, bool err)
{
#if WINDOWS
    DWORD n;
    HANDLE h = stdout_;
    if (err && stderr_ != INVALID_HANDLE_VALUE) h = stderr_;
    return ReadFile(h, static_cast<char*>(buf), nbuf, &n, NULL) && n > 0;
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
