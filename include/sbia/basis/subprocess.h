/**
 * @file  subprocess.h
 * @brief Module used to execute subprocesses.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#pragma once
#ifndef SBIA_BASIS_SUBPROCESS_H_
#define SBIA_BASIS_SUBPROCESS_H_


#include <vector>
#include <string>

#if WINDOWS
#  include <windows.h>
#else
#  include <sys/types.h>
#  include <unistd.h>
#endif

#include <sbia/basis/config.h>


SBIA_BASIS_NAMESPACE_BEGIN


/**
 * @class SubProcess
 * @brief Platform-independent interface to create and control a subprocess.
 */
class SubProcess
{
    // =======================================================================
    // enumerations
    // =======================================================================

    /**
     * @brief Modes of redirection for standard input/output buffers.
     */
    enum RedirectMode
    {
        RM_NONE,  ///< Do not redirect the input/output.
        RM_PIPE,  ///< Use a pipe to redirect the input/output from/to the parent.
        RM_STDOUT ///< Redirect stderr to stdout.
    };

    // =======================================================================
    // typedefs
    // =======================================================================

public:

    typedef std::vector<std::string> Arguments;
    typedef std::vector<std::string> Environment;

private:

    /// Type used for file handles of pipes between processes.
#if WINDOWS
    typedef PHANDLE PipeHandle;
#else
    typedef int     PipeHandle;
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

    // =======================================================================
    // construction / destruction
    // =======================================================================

public:

    /**
     * @brief Construct new subprocess instance.
     *
     * This method constructs a new subprocess instance. The process itself is,
     * however, not yet executed after construction. In order to actually run
     * the command, the Run() method has to be called on the just created
     * subprocess instance.
     *
     * @sa Run()
     *
     * @param [in] cmd Command-line of subprocess. The first argument has to
     *                 be the name/path of the command to be executed.
     * @param [in] in  Mode used for redirection of stdin of subprocess.
     *                 Can be either RM_NONE or RM_PIPE.
     * @param [in] out Mode used for redirection of stdout of subprocess.
     *                 Can be either RM_NONE or RM_PIPE.
     * @param [in] err Mode used for redirection of stderr of subprocess.
     *                 Can be either RM_NONE, RM_PIPE, or RM_STDOUT.
     * @param [in] env Environment for the subprocess. If NULL is given, the
     *                 environment of the parent process is used.
     */
    SubProcess(const Arguments&   cmd,
               const RedirectMode in  = RM_NONE,
               const RedirectMode out = RM_NONE,
               const RedirectMode err = RM_NONE,
               const Environment* env = NULL);

    /**
     * @brief Terminate running subprocess and close all related handles.
     */
    ~SubProcess();

    // =======================================================================
    // process control
    // =======================================================================

    /**
     * @brief Run subprocess.
     *
     * @returns Whether the subprocess was created successfully. If @p wait
     *          is true, it also indicates whether Wait() was successful.
     */
    bool run(bool wait = true);

    /**
     * @brief Wait for subprocess to terminate.
     *
     * This method also sets the exit code as returned by GetExitCode().
     */
    bool wait();

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
     * @returns Whether the subprocess terminated.
     */
    bool terminated() const;

    /**
     * @returns Wether the subprocess has been signaled.
     */
    bool signaled() const;

    /**
     * @returns Exit code of subprocess. Only valid if Terminated() is true.
     */
    int returncode() const;

    // =======================================================================
    // inter-process communication
    // =======================================================================

    /**
     * @brief Communicate with subprocess.
     *
     * @note This method returns after the subprocess terminated and sets
     *       the exit code as returned by GetExitCode().
     *
     * @param [in] stdIn  Data send to subprocess via pipe to stdin.
     *                    If no pipe was setup during subprocess creation,
     *                    this function does nothing and returns false.
     * @param [in] stdOut Data read from stdout of subprocess. Can be an empty
     *                    string if no pipe was created for stdout.
     * @param [in] stdErr Data read from stderr of subprocess. Can be an empty
     *                    string if no pipe was created for stderr.
     *
     * @returns Whether the communication with the subprocess was successful.
     */
    bool communicate(const char* stdin, std::string& stdout, std::string& stderr);

    /**
     * @brief Communicate with subprocess.
     *
     * @note This method returns after the subprocess terminated and sets
     *       the exit code as returned by GetExitCode().
     *
     * @param [in] stdOut Data read from stdout of subprocess. Can be an empty
     *                    string if no pipe was created for stdout.
     * @param [in] stdErr Data read from stderr of subprocess. Can be an empty
     *                    string if no pipe was created for stderr.
     *
     * @returns Whether the communication with the subprocess was successful.
     */
    bool communicate(std::string& stdout, std::string& stderr);

    /**
     * @brief Communicate with subprocess.
     *
     * @note This method returns after the subprocess terminated and sets
     *       the exit code as returned by GetExitCode().
     *
     * @param [in] stdOut Data read from stdout of subprocess. Can be an empty
     *                    string if no pipe was created for stdout.
     *
     * @returns Whether the communication with the subprocess was successful.
     */
    bool communicate(std::string& stdout);

    /**
     * @brief Write data to stdin of subprocess.
     */
    bool write();

    /**
     * @brief Read data from stdout and/or stderr of subprocess.
     */
    bool read(bool errors = false);

    // =======================================================================
    // process execution
    // =======================================================================

public:

    /**
     * @brief Execute command as subprocess.
     *
     * This function is a replacement for system() on Unix and is furthermore
     * supposed to be platform independent. The first argument of the given
     * command-line string is mapped to an executable file using GetExecutablePath().
     * If this fails because the first argument is not a known build target name,
     * the given command is executed as given.
     */
    static int call(const std::string& cmd);

    // =======================================================================
    // unsupported operations
    // =======================================================================

private:

    /**
     * @brief Default constructor.
     *
     * @note Intentionally not implemented.
     */
    SubProcess();

    /**
     * @brief Copy constructor.
     *
     * @note Intentionally not implemented.
     */
    SubProcess(const SubProcess&);

    /**
     * @brief Assignment operator.
     *
     * @note Intentionally not implemented.
     */
    void operator= (const SubProcess&);

    // =======================================================================
    // members
    // =======================================================================

private:

    Arguments    args_;        ///< Command-line incl. command.
    Environment* env_;         ///< Environment for subprocess or NULL.
    Information  info_;        ///< Subprocess information.
    RedirectMode stdin_mode_;  ///< Redirection mode used for stdin.
    PipeHandle   stdin_;       ///< Used to write data to stdin of subprocess.
    RedirectMode stdout_mode_; ///< Redireciton mode used for stdout.
    PipeHandle   stdout_;      ///< Used to read data from stdout of subprocess.
    RedirectMode stderr_mode_; ///< Redirection mode used for stderr.
    PipeHandle   stderr_;      ///< Used to read data from stderr of subprocess.
    mutable int  status_;      ///< Status of subprocess.

}; // class SubProcess


SBIA_BASIS_NAMESPACE_END


#endif // SBIA_BASIS_SUBPROCESS_H_
