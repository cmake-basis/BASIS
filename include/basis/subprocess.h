/**
 * @file  subprocess.h
 * @brief Module used to execute subprocesses.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef _BASIS_SUBPROCESS_H
#define _BASIS_SUBPROCESS_H


#include <basis/config.h> // platform macros - must be first

#include <vector>
#include <string>

#if WINDOWS
#  include <windows.h>
#else
#  include <sys/types.h>
#  include <unistd.h>
#endif


namespace basis {


/**
 * @class Subprocess
 * @brief Platform-independent interface to create and control a subprocess.
 */
class Subprocess
{
    // -----------------------------------------------------------------------
    // types
public:

    typedef std::vector<std::string> CommandLine;
    typedef std::vector<std::string> Environment;

private:

    /// Type used for file handles of pipes between processes.
#if WINDOWS
    typedef HANDLE PipeHandle;
#else
    typedef int    PipeHandle;
#endif

    /// Information structure required by system to identify subprocess.
#if WINDOWS
    typedef PROCESS_INFORMATION Information;
#else
    struct Information
    {
        pid_t pid;
    };
#endif

    // -----------------------------------------------------------------------
    // constants
public:

    /**
     * @brief Modes of redirection for standard input/output buffers.
     */
    enum RedirectMode
    {
        RM_NONE,  ///< Do not redirect the input/output.
        RM_PIPE,  ///< Use a pipe to redirect the input/output from/to the parent.
        RM_STDOUT ///< Redirect stderr to stdout.
    };

    // -----------------------------------------------------------------------
    // construction / destruction
public:

    /**
     * @brief Default constructor.
     */
    Subprocess();

    /**
     * @brief Terminate running subprocess and close all related handles.
     */
    ~Subprocess();

    // -----------------------------------------------------------------------
    // helpers
public:

    /**
     * @brief Split double quoted string into arguments.
     *
     * @param [in] cmd Double quoted string. Use '\' to escape double quotes
     *                 within arguments.
     *
     * @returns Argument vector.
     */
    static CommandLine split(const std::string& cmd);

    /**
     * @brief Convert argument vector to double quoted string.
     *
     * @param [in] args Argument vector.
     *
     * @returns Double quoted string.
     */
    static std::string tostring(const CommandLine& args);

    // -----------------------------------------------------------------------
    // process control
public:

    /**
     * @brief Open new subprocess.
     *
     * This method creates the subprocess and returns immediately. In order to
     * wait for the suprocess to finish, the wait() method has to be called
     * explicitly.
     *
     * @param [in] args   Command-line of subprocess. The first argument has to
     *                    be the name/path of the command to be executed.
     * @param [in] rm_in  Mode used for redirection of stdin of subprocess.
     *                    Can be either RM_NONE or RM_PIPE.
     * @param [in] rm_out Mode used for redirection of stdout of subprocess.
     *                    Can be either RM_NONE or RM_PIPE.
     * @param [in] rm_err Mode used for redirection of stderr of subprocess.
     *                    Can be either RM_NONE, RM_PIPE, or RM_STDOUT.
     * @param [in] env    Environment for the subprocess. If NULL is given, the
     *                    environment of the parent process is used.
     *
     * @returns Whether the subprocess was created successfully.
     */
    bool popen(const CommandLine& args,
               // attention: stdin, stdout, and stderr are macros defined by windows.h
               const RedirectMode rm_in  = RM_NONE,
               const RedirectMode rm_out = RM_NONE,
               const RedirectMode rm_err = RM_NONE,
               const Environment* env    = NULL);

    /**
     * @brief Open new subprocess.
     *
     * This method creates the subprocess and returns immediately. In order to
     * wait for the suprocess to finish, the wait() method has to be called
     * explicitly.
     *
     * @param [in] cmd    Command-line given as double quoted string. Arguments
     *                    containing whitespaces have to be quoted using double
     *                    quotes. Use a backslash (\) to escape double quotes
     *                    inside an argument as well as to escape a backslash
     *                    itself (required if backslash at end of double quoted
     *                    argument, e.g., "this argument \\").
     * @param [in] rm_in  Mode used for redirection of stdin of subprocess.
     *                    Can be either RM_NONE or RM_PIPE.
     * @param [in] rm_out Mode used for redirection of stdout of subprocess.
     *                    Can be either RM_NONE or RM_PIPE.
     * @param [in] rm_err Mode used for redirection of stderr of subprocess.
     *                    Can be either RM_NONE, RM_PIPE, or RM_STDOUT.
     * @param [in] env    Environment for the subprocess. If NULL is given, the
     *                    environment of the parent process is used.
     */
    bool popen(const std::string& cmd,
               // attention: stdin, stdout, and stderr are macros defined by windows.h
               const RedirectMode rm_in  = RM_NONE,
               const RedirectMode rm_out = RM_NONE,
               const RedirectMode rm_err = RM_NONE,
               const Environment* env    = NULL)
    {
        return popen(split(cmd), rm_in, rm_out, rm_err, env);
    }

    /**
     * @brief Check if subprocess terminated and update return code.
     *
     * This method returns immediately and does not wait for the subprocess to
     * actually being terminated. For that purpuse, use wait() instead.
     *
     * @returns Whether the subprocess terminated.
     */
    bool poll() const;

    /**
     * @brief Wait for subprocess to terminate.
     *
     * This method also sets the exit code as returned by GetExitCode().
     */
    bool wait();

    /**
     * @brief Send signal to subprocess.
     *
     * On Windows, SIGTERM is an alias for terminate() and SIGKILL an alias for
     * kill() which in turn is nothing else but a termination of the subprocess.
     * All other signals are only sent to POSIX processes.
     */
    bool send_signal(int signal);

    /**
     * @brief Terminate subprocess.
     *
     * - On POSIX, the SIGTERM signal is send.
     * - On Windows, TerminateProcess() is invoked to terminate the subprocess. 
     */
    bool terminate();

    /**
     * @brief Kill subprocess.
     *
     * - On POSIX, the SIGKILL signal is send.
     * - On Windows, TerminateProcess() is invoked to terminate the subprocess. 
     */
    bool kill();

    /**
     * @returns Wether the subprocess has been signaled, i.e., terminated abnormally.
     */
    bool signaled() const;

    /**
     * @returns ID of subprocess.
     */
    int pid() const;

    /**
     * @returns Exit code of subprocess. Only valid if terminated() is true.
     */
    int returncode() const;

    // -----------------------------------------------------------------------
    // inter-process communication
public:

    /**
     * @brief Communicate with subprocess.
     *
     * @note This method closes the pipes to the subprocess after all data
     *       has been sent and received and returns after the subprocess
     *       terminated. Therefore, the exit code is set upon return.
     *
     * @param [in] in  Data send to subprocess via pipe to stdin.
     *                 If no pipe was setup during subprocess creation,
     *                 this function does nothing and returns false.
     * @param [in] out Data read from stdout of subprocess. Can be an empty
     *                 string if no pipe was created for stdout.
     * @param [in] err Data read from stderr of subprocess. Can be an empty
     *                 string if no pipe was created for stderr.
     *
     * @returns Whether the communication with the subprocess was successful.
     */
    bool communicate(std::istream& in, std::ostream& out, std::ostream& err);

    /**
     * @brief Communicate with subprocess.
     *
     * @note This method closes the pipes to the subprocess after all data
     *       has been received and returns after the subprocess terminated.
     *       Therefore, the exit code is set upon return.
     *
     * @param [in] out Data read from stdout of subprocess. Can be an empty
     *                 string if no pipe was created for stdout.
     * @param [in] err Data read from stderr of subprocess. Can be an empty
     *                 string if no pipe was created for stderr.
     *
     * @returns Whether the communication with the subprocess was successful.
     */
    bool communicate(std::ostream& out, std::ostream& err);

    /**
     * @brief Communicate with subprocess.
     *
     * @note This method closes the pipes to the subprocess after all data
     *       has been received and returns after the subprocess terminated.
     *       Therefore, the exit code is set upon return.
     *
     * @param [in] out Data read from stdout of subprocess. Can be an empty
     *                 string if no pipe was created for stdout.
     *
     * @returns Whether the communication with the subprocess was successful.
     */
    bool communicate(std::ostream& out);

    /**
     * @brief Write data to stdin of subprocess.
     *
     * @param [in] buf  Bytes to write.
     * @param [in] nbuf Number of bytes from @p buf to write.
     *
     * @returns Number of bytes written or -1 on error.
     */
    int write(const void* buf, size_t nbuf);

    /**
     * @brief Read data from stdout or stderr of subprocess.
     *
     * @param [out] buf  Allocated buffer to store read data to.
     * @param [in]  nbuf Number of bytes to read from subprocess.
     * @param [in]  err  If true and the redirection mode of stderr is RM_PIPE,
     *                   the data is read from stderr of the subprocess.
     *                   Otherwise, the data is read from stdout.
     *
     * @returns Number of bytes read or -1 on error.
     */
    int read(void* buf, size_t nbuf, bool err = false);

    // -----------------------------------------------------------------------
    // process execution
public:

    /**
     * @brief Execute command as subprocess.
     *
     * This function is implemented in the same manner as system() on Unix.
     * It simply creates a Subprocess instance, executes the subprocess and
     * waits for its termination.
     *
     * Example:
     * @code
     * Subprocess::CommandLine cmd;
     * cmd.push_back("ls");
     * cmd.push_back("some directory");
     * int status = Subprocess::call(cmd);
     * @endcode
     *
     * @returns Exit code of subprocess or -1 on error.
     */
    static int call(const CommandLine& cmd);

    /**
     * @brief Execute command as subprocess.
     *
     * This function is implemented in the same manner as system() on Unix.
     * It simply creates a Subprocess instance, executes the subprocess and
     * waits for its termination.
     *
     * Example:
     * @code
     * int status = Subprocess::call("ls \"some directory\"");
     * @endcode
     *
     * @param [in] cmd Command-line given as single string. Quote arguments
     *                 containing whitespace characters using ".
     *
     * @returns Exit code of subprocess or -1 on error.
     */
    static int call(const std::string& cmd);

    // -----------------------------------------------------------------------
    // unsupported operations
private:

    /**
     * @brief Copy constructor.
     *
     * @note Intentionally not implemented.
     */
    Subprocess(const Subprocess&);

    /**
     * @brief Assignment operator.
     *
     * @note Intentionally not implemented.
     */
    void operator=(const Subprocess&);

    // -----------------------------------------------------------------------
    // members
private:

    Information _info;   ///< Subprocess information.
    PipeHandle  _stdin;  ///< Used to write data to stdin of subprocess.
    PipeHandle  _stdout; ///< Used to read data from stdout of subprocess.
    PipeHandle  _stderr; ///< Used to read data from stderr of subprocess.
    mutable int _status; ///< Status of subprocess.

}; // class Subprocess


} // namespace basis


#endif // _BASIS_SUBPROCESS_H
