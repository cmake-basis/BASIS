/**
 * @file  utilities.h
 * @brief Main module of project-independent BASIS utilities.
 *
 * This module defines project-independent implementations of the BASIS utility
 * functions. They are intended for use outside a BASIS-based project only.
 * Within source code of a BASIS-based project, the overloads declared by
 * the basis.h module should be used instead as these are specifically configured
 * by BASIS for this project during the build of the software.
 *
 * Note that this module includes all other BASIS utility header files.
 * Hence, it is sufficient to include this file only.
 *
 * Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 *
 * @ingroup BasisCxxUtilities
 */

#ifndef _BASIS_UTILITIES_H
#define _BASIS_UTILITIES_H

// standard library
#include <string>
#include <iostream>
#include <vector>

// build configuration - has to be included using full path in case the build
//                       tree of BASIS is used instead of an installation
#include <basis/config.h>

// basic utilities
#include "assert.h"
#include "except.h"
#include "os.h"

// command-line parsing
#include "CmdLine.h"


/// @addtogroup BasisCxxUtilities
/// @{


// the subnamespace is required to avoid conflict with configured
// project-specific utilities of BASIS itself
namespace basis { namespace util {


// ===========================================================================
// executable information
// ===========================================================================

/**
 * @brief Provides information about executable build targets.
 *
 * Within source code of a BASIS project, other SBIA executables are called
 * only indirectly using the build target name which must be fixed and unique
 * within the lab. The name of the output executable file of these targets may
 * however vary and be finally set by BASIS, for example, depending on
 * whether the project is build as part of a superproject or not. Therefore,
 * each BASIS CMake function may adjust the output name in order to resolve
 * name conflicts with other targets or SBIA executables.
 *
 * The idea is that a target name is supposed to be stable and known to the
 * developer as soon as the target is added to a CMakeLists.txt file, while
 * the name of the actual executable file is not known a priori as it is set
 * by the BASIS CMake functions during the configure step. Thus, the developer
 * should not rely on a particular name of the executable file. Instead, they
 * can rely on the name of the corresponding build target which was chosen by
 * themselves when adding the target to the build configuration.
 *
 * In order to get the actual file path of the built executable file, the
 * function get_executable_path() is provided by the stdaux.h module.
 * This function uses the static singleton instance of this class in order to
 * map the given build target name to the name of the built and optionally
 * installed executable. The code which initializes the required maps is
 * generated automatically during the configuration of the build system.
 *
 * @sa exepath()
 */
class IExecutableTargetInfo
{
    // -----------------------------------------------------------------------
    // construction / destruction
protected:

    /// @brief Constructor
    IExecutableTargetInfo() {}

    /// @brief Destructor.
    virtual ~IExecutableTargetInfo() {};

    // -----------------------------------------------------------------------
    // public interface
public:

    /**
     * @brief Get UID of build target.
     *
     * In order to be able to distinguish build targets with identical name
     * but which are built as part of different BASIS projects, the UID of
     * a build target is composed of the build target name as given as
     * argument to the basis_add_* CMake functions and a namespace identifier
     * (i.e., the project name in lowercase letters). If the specified build
     * target name is neither known by this module nor a build target UID yet,
     * this method prepends the namespace identifier corresponding to the
     * project this module was built from, assuming that the caller refers
     * to another target within the same project.
     *
     * @param [in] target Name/UID of build target.
     *
     * @returns UID of build target.
     */
    virtual std::string targetuid(const std::string& target) const = 0;

    /**
     * @brief Determine whether a given build target is known.
     *
     * @param [in] target Name/UID of build target.
     *
     * @returns Whether the given build target is known by this module.
     */
    virtual bool istarget(const std::string& target) const = 0;

    /**
     * @brief Get name of executable file without directory path.
     *
     * @param [in] target Name/UID of build target.
     *
     * @returns Name of built executable file without path.
     */
    virtual std::string basename(const std::string& target) const = 0;

    /**
     * @brief Get absolute path of directory containing executable.
     *
     * @param [in] target Name/UID of build target.
     *
     * @returns Absolute path of directory containing executable file.
     */
    virtual std::string dirname(const std::string& target) const = 0;

}; // class IExecutableTargetInfo


/**
 * @brief Print contact information.
 *
 * @param [in] contact Name of contact.
 */
void print_contact(const char* contact);

/**
 * @brief Print version information including copyright and license notices.
 *
 * @param [in] name      Name of executable. Should not be set programmatically
 *                       to the first argument of the @c main() function, but
 *                       a string literal instead.
 * @param [in] version   Version of executable, e.g., release of project
 *                       this executable belongs to.
 * @param [in] project   Name of project this executable belongs to.
 *                       If @c NULL or an empty string, no project information
 *                       is printed.
 * @param [in] copyright The copyright notice, excluding the common prefix
 *                       "Copyright (c) " and suffix ". All rights reserved.".
 *                       If @c NULL or an empty string, no copyright notice
 *                       is printed.
 * @param [in] license   Information regarding licensing. If @c NULL or an empty
 *                       string, no license information is printed.
 */
void print_version(const char* name,
                   const char* version,
                   const char* project   = NULL,
                   const char* copyright = NULL,
                   const char* license   = NULL);

/**
 * @brief Get UID of build target.
 *
 * The UID of a build target is its name prepended by a namespace identifier
 * which should be unique for each project.
 *
 * @param [in] name    Name of build target.
 * @param [in] targets Structure providing information about executable targets.
 *
 * @returns UID of named build target.
 */
std::string targetuid(const std::string& name, const IExecutableTargetInfo* targets = NULL);

/**
 * @brief Determine whether a given build target is known.
 *
 * @param [in] name    Name of build target.
 * @param [in] targets Structure providing information about executable targets.
 *
 * @returns Whether the named target is a known executable target.
 */
bool istarget(const std::string& name, const IExecutableTargetInfo* targets = NULL);

/**
 * @brief Get absolute path of executable file.
 *
 * This function determines the absolute file path of an executable. If no
 * arguments are given, the absolute path of this executable is returned.
 * If the command names a known executable build target, the absolute path to
 * the corresonding built (and installed) executable file is returned.
 * Otherwise, the named command is searched in the system @c PATH and its
 * absolute path returned if found. If the executable is not found, an
 * empty string is returned.
 *
 * @todo This function currently makes use of the which command implemented
 *       in Python and called as subprocess in order to search a command
 *       in the system @c PATH. This which command is part of BASIS and
 *       can also be used on Windows. However, a native C++ implementation
 *       would be desireable.
 *
 * @param [in] name    Name of command or @c NULL.
 * @param [in] targets Structure providing information about executable targets.
 *
 * @returns Absolute path of executable or an empty string if not found.
 *          If @p name is @c NULL, the path of this executable is returned.
 *
 * @sa exename()
 * @sa exedir()
 */
std::string exepath(const std::string&           name    = std::string(),
                    const IExecutableTargetInfo* targets = NULL);

/**
 * @brief Get name of executable file.
 *
 * The name of the executable may or may not include the file name extension
 * depending on the executable type and operating system. Hence, this function
 * is neither an equivalent to os::path::basename(exepath()) nor
 * os::path::filename(exepath()). In particular, on Windows, the .exe and .com
 * extension is not included in the returned executable name.
 *
 * @param [in] name    Name of command or @c NULL.
 * @param [in] targets Structure providing information about executable targets.
 *
 * @returns Name of executable file or an empty string if not found.
 *          If @p name is @c NULL, the name of this executable is returned.
 *
 * @sa exepath()
 */
std::string exename(const std::string&           name    = std::string(),
                    const IExecutableTargetInfo* targets = NULL);

/**
 * @brief Get directory of executable file.
 *
 * @param [in] name    Name of command or @c NULL.
 * @param [in] targets Structure providing information about executable targets.
 *
 * @returns Absolute path of directory containing executable or an empty string if not found.
 *          If @p name is @c NULL, the directory of this executable is returned.
 *
 * @sa exepath()
 */
std::string exedir(const std::string&           name    = std::string(),
                   const IExecutableTargetInfo* targets = NULL);

// ===========================================================================
// command execution
// ===========================================================================

/**
 * @class SubprocessError
 * @brief Exception type thrown by execute().
 */
class SubprocessError : public std::exception
{
public:
    SubprocessError(const std::string& msg) : msg_(msg) {}
    ~SubprocessError() throw () {}

private:
    std::string msg_; ///< Error message.
}; // class SubprocessError

/**
 * @brief Convert array of arguments to quoted string.
 *
 * @param [in] args Array of arguments.
 *
 * @returns Double quoted string, i.e., string where arguments are separated
 *          by a space character and surrounded by double quotes if necessary.
 *          Double quotes within an argument are escaped with a backslash.
 *
 * @sa split()
 */
std::string tostring(const std::vector<std::string>& args);

/**
 * @brief Split quoted string.
 *
 * @param [in] args Quoted string of arguments.
 *
 * @returns Array of arguments.
 *
 * @sa tostring()
 */
std::vector<std::string> qsplit(const std::string& args);

/**
 * @brief Execute command as subprocess.
 *
 * This function is a replacement for system() on Unix and is furthermore
 * less platform dependent. The first argument of the given command-line string
 * is mapped to an absolute executable file using exepath() if the given first
 * argument is a know build target name. Otherwise, the command-line is used
 * unmodified.
 *
 * @param [in] cmd         Command-line given as double quoted string. Arguments
 *                         containing whitespaces have to be quoted using double
 *                         quotes. Use a backslash (\\) to escape double quotes
 *                         inside an argument as well as to escape a backslash
 *                         itself (required if backslash at end of double quoted
 *                         argument, e.g., "this argument \\").
 * @param [in]  quiet      Turns off output of stdout of child process to stdout
 *                         of parent process.
 * @param [out] out        Output stream where command output is written to.
 * @param [in]  allow_fail If true, no exception is thrown if the exit code
 *                         of the child process is non-zero. Otherwise,
 *                         a SubprocessException object is thrown in that case.
 * @param [in]  verbose    Verbosity of output messages. Does not affect
 *                         verbosity of executed command.
 * @param [in]  simulate   Whether to simulate command execution only.
 * @param [in]  targets    Structure providing information about executable targets.
 *
 * @returns Exit code of command or -1 if subprocess creation failed.
 *
 * @throws SubprocessError If subprocess creation failed or command returned
 *                         a non-zero exit code while @p allow_fail is false.
 */
int execute(const std::string&           cmd,
            bool                         quiet      = false,
            // attention: stdout is a macro defined by windows.h
            std::ostream*                out        = NULL,
            bool                         allow_fail = false,
            int                          verbose    = 0,
            bool                         simulate   = false,
            const IExecutableTargetInfo* targets    = NULL);

/**
 * @brief Execute command as subprocess.
 *
 * This function is a replacement for system() on Unix and is furthermore
 * less platform dependent. The first argument of the given command-line string
 * is mapped to an absolute executable file using exepath() if the given first
 * argument is a know build target name. Otherwise, the command-line is used
 * unmodified.
 *
 * @param [in]  args       Command-line given as argument vector. The first
 *                         argument has to be either a build target name or the
 *                         name/path of the command to execute. Note that as a
 *                         side effect, the first argument of the input vector
 *                         is replaced by the absolute path of the actual
 *                         executable file if applicable.
 * @param [in]  quiet      Turns off output of stdout of child process to
 *                         stdout of parent process.
 * @param [out] out        Output stream where command output is written to.
 * @param [in]  allow_fail If true, no exception is thrown if the exit code
 *                         of the child process is non-zero. Otherwise,
 *                         a SubprocessException object is thrown in that case.
 * @param [in]  verbose    Verbosity of output messages. Does not affect
 *                         verbosity of executed command.
 * @param [in]  simulate   Whether to simulate command execution only.
 * @param [in]  targets    Structure providing information about executable targets.
 *
 * @returns Exit code of command or -1 if subprocess creation failed.
 *
 * @throws SubprocessError If subprocess creation failed or command returned
 *                         a non-zero exit code while @p allow_fail is false.
 */
int execute(std::vector<std::string>        args,
            bool                            quiet      = false,
            // attention: stdout is a macro defined by windows.h
            std::ostream*                   out        = NULL,
            bool                            allow_fail = false,
            int                             verbose    = 0,
            bool                            simulate   = false,
            const IExecutableTargetInfo*    targets    = NULL);


} } // end of namespaces


/// @}
// end of Doxygen group

#endif // _BASIS_UTILITIES_H
