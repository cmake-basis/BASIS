##############################################################################
# @file  utilities.sh
# @brief Default implementation of BASIS Bash Utilities plus core functions.
#
# This module defines the default BASIS utility functions. These default
# implementations are not project-specific, i.e., do not make use of particular
# project attributes such as the name or version of the project. The utility
# functions defined by this module are intended for use in Bash scripts that
# are not build as part of a particular BASIS project. Otherwise, the
# project-specific implementations should be used instead, i.e., those defined
# by the basis.sh module of the project which is automatically added to the
# project during the configuration of the build tree. This basis.sh module and
# the submodules used by it are generated from template modules which are
# customized for the particular project that is being build.
#
# Besides the utility functions which are common to all implementations for
# the different programming languages, does this module further provide
# fundamental functions for the development in Bash.
#
# @note In Bash, there is no concept of namespaces. Hence, the utility functions
#       are all defined by the utilities.sh module which is part of the BASIS
#       installation. By simply setting the constants to the project specific
#       values, these utility functions are customized for this particular
#       package. This, however, also means that the BASIS utilities of two
#       different packages cannot be used within a Bash script at the same
#       time in general. The order in which the basis.sh modules are sourced
#       matters. Therefore, in Bash, care must be taken which modules of a
#       BASIS-based package are being sourced and whether these in turn
#       source either the utilities.sh module of BASIS or the basis.sh module
#       which has been configured/customized for this particular package.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

[ "${_SBIA_BASIS_UTILITIES_INCLUDED}" == 'true' ] || {
_SBIA_BASIS_UTILITIES_INCLUDED='true'


## @addtogroup BasisBashUtilities
#  @{


# ============================================================================
# constants
# ============================================================================

readonly _BASIS_UTILITIES_DIR="`cd -P -- "\`dirname -- "${BASH_SOURCE}"\`" && pwd -P`"

# ============================================================================
# modules
# ============================================================================

. "${_BASIS_UTILITIES_DIR}/@_BASIS_LIBRARY_DIR@/core.sh"    || exit 1 # core utilities
. "${_BASIS_UTILITIES_DIR}/@_BASIS_LIBRARY_DIR@/path.sh"    || exit 1 # file path manipulation
. "${_BASIS_UTILITIES_DIR}/@_BASIS_LIBRARY_DIR@/shflags.sh" || exit 1 # command-line parsing library

# ============================================================================
# configuration
# ============================================================================

## @brief Project name.
PROJECT=''
## @brief Project version.
VERSION=''
## @brief Project release.
RELEASE=''
## @brief Default copyright of executables.
COPYRIGHT="University of Pennsylvania"
## @brief Default license of executables.
LICENSE="See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file."
## @brief Default contact to use for help output of executables.
CONTACT="SBIA Group <sbia-software at uphs.upenn.edu>"

# ============================================================================
# executable information
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Print contact information.
#
# @param [in] contact Name of contact. Defaults to <tt>${CONTACT}</tt>.
#
# @returns Nothing.
print_contact()
{
    [ -n "$1" ] && echo -e "Contact:\n  $1" || echo -e "Contact:\n  ${CONTACT}"
}

# ----------------------------------------------------------------------------
## @brief Print version information including copyright and license notices.
#
# @param [in] options   Function options as documented below.
# @param [in] name      Name of executable. Should not be set programmatically
#                       to the first argument of the main script, but a string
#                       literal instead.
# @param [in] version   Version of executable. Defaults to <tt>${RELEASE}</tt>
#                       if defined, otherwise this argument is required.
# @par Options:
# <table border="0">
#   <tr>
#     @tp @b -p,  @b --project &lt;name&gt; @endtp
#     <td>Name of project this executable belongs to.
#         Defaults to <tt>${PROJECT}</tt> if defined.
#         If 'none', no project information is printed.</td>
#   </tr>
#   <tr>
#     @tp @b -c  @b --copyright &lt;copyright&gt; @endtp
#     <td>The copyright notice. Defaults to <tt>${COPYRIGHT}</tt>.
#         If 'none', no copyright notice is printed.</td>
#   </tr>
#   <tr>
#     @tp @b -l  @b --license &lt;license&gt; @endtp
#     <td>Information regarding licensing. Defaults to <tt>${LICENSE}</tt>.
#         If 'none', no license information is printed.</td>
#   </tr>
# </table>
#
# @returns Nothing.
print_version()
{
    local _basis_pv_name=''
    local _basis_pv_version="${RELEASE}"
    local _basis_pv_project="${PROJECT}"
    local _basis_pv_copyright="${COPYRIGHT:-}"
    local _basis_pv_license="${LICENSE:-}"
    while [ $# -gt 0 ]; do
        case "$1" in
            -p|--project)
                if [ $# -gt 1 ]; then
                    _basis_pv_project="$2"
                else
                    echo "print_version(): Option -p, --project is missing an argument!" 1>&2
                fi
                shift
                ;;
            -c|--copyright)
                if [ $# -gt 1 ]; then
                    _basis_pv_copyright="$2"
                else
                    echo "print_version(): Option -c, --copyright is missing an argument!" 1>&2
                fi
                shift
                ;;
            -l|--license)
                if [ $# -gt 1 ]; then
                    _basis_pv_license="$2"
                else
                    echo "print_version(): Option -l, --license is missing an argument!" 1>&2
                fi
                shift
                ;;
            *)
                if   [ -z "${_basis_pv_name}" ]; then
                    _basis_pv_name=$1
                elif [ -z "${_basis_pv_version}" ]; then
                    _basis_pv_version=$1
                else
                    echo "print_version(): Too many arguments or invalid option: $1" 1>&2
                fi
                ;;
        esac
        shift
    done
    [ -n "${_basis_pv_name}"    ] || { echo "print_version(): Missing name argument"    1>&2; return 1; }
    [ -n "${_basis_pv_version}" ] || { echo "print_version(): Missing version argument" 1>&2; return 1; }
    echo -n "${_basis_pv_name}"
    [ -n "${_basis_pv_project}" ] && [ "${_basis_pv_project}" != 'none' ] && {
        echo -n " (${_basis_pv_project})"
    }
    echo " ${_basis_pv_version}"
    [ -n "${_basis_pv_copyright}" ] && [ "${_basis_pv_copyright}" != 'none' ] && {
        echo -e "Copyright (c) ${_basis_pv_copyright}. All rights reserved."
    }
    [ -n "${_basis_pv_license}"   ] && [ "${_basis_pv_license}"   != 'none' ] && {
        echo -e "${_basis_pv_license}"
    }
}

# ----------------------------------------------------------------------------
## @brief Get UID of build target.
#
# The UID of a build target is its name prepended by a namespace identifier
# which should be unique for each project.
#
# This function further initializes the dictionaries storing the information
# about the executable targets upon the first invocation. Reason to do it
# here is that every access to the dictionaries first calls this function
# to get the UID of a build target. Moreover, also this function needs to
# have the already initialized dictionaries to ensure that an already valid
# target identifier is not modified.
#
# @param [out] uid  UID of named build target.
# @param [in]  name Name of build target.
#
# @returns Nothing.
#
# @retval 0 On success.
# @retval 1 On failure.
get_target_uid()
{
    [ -n "$1" ] && [ $# -eq 2 ] || return 1
    local _basis_gtu_target="$2"
    # initialize module if not done yet - this is only done here because
    # whenever information is looked up about an executable target, this
    # function is invoked first
    if [ "${_EXECUTABLETARGETINFO_INITIALIZED}" != 'true' ]; then
        _executabletargetinfo_initialize || return 1
    fi
    # empty string as input remains unchanged
    [ -z "${_basis_gtu_target}" ] && local "$1" && upvar $1 '' && return 0
    # in case of a leading namespace separator, do not modify target name
    [ "${_basis_gtu_target:0:1}" == '.' ] && local "$1" && upvar $1 "${_basis_gtu_target}" && return 0
    # project namespace
    local _basis_gtu_prefix="@PROJECT_NAMESPACE_CMAKE@.DUMMY"
    # try prepending namespace or parts of it until target is known
    local _basis_gtu_path=''
    while [ "${_basis_gtu_prefix/\.*/}" != "${_basis_gtu_prefix}" ]; do
        _basis_gtu_prefix="${_basis_gtu_prefix%\.*}"
        _executabletargetinfo_get _basis_gtu_path "${_basis_gtu_prefix}.${_basis_gtu_target}" LOCATION
        if [ -n "${_basis_gtu_path}" ]; then
            local "$1" && upvar $1 "${_basis_gtu_prefix}.${_basis_gtu_target}"
            return 0
        fi
    done
    # otherwise, return target name unchanged
    local "$1" && upvar $1 "${_basis_gtu_target}"
}

# ----------------------------------------------------------------------------
## @brief Determine whether a given build target is known.
#
# @param [in] target Name of build target.
#
# @returns Whether the named target is a known executable target.
is_known_target()
{
    local _basis_ikt_uid && get_target_uid _basis_ikt_uid "$1"
    [ -n "${_basis_ikt_uid}" ] || return 1
    local _basis_ikt_path && _executabletargetinfo_get _basis_ikt_path "${_basis_ikt_uid}" LOCATION
    [ -n "${_basis_ikt_path}" ]
}

# ----------------------------------------------------------------------------
## @brief Get absolute path of executable file.
#
# This function determines the absolute file path of an executable. If no
# arguments are given, the absolute path of this executable is returned.
# If the given argument is a known build target name, the absolute path
# of the executable built by this target is returned. Otherwise, the named
# command is searched in the system PATH and it's absolute path returned
# if found. If the given argument is neither the name of a known build target
# nor an executable found on the PATH, an empty string is returned and
# the return value is 1.
#
# @param [out] path   Absolute path of executable file.
# @param [in]  target Name/UID of build target. If no argument is given,
#                     the file path of the calling executable is returned.
#
# @returns Nothing.
#
# @retval 0 On success.
# @retval 1 On failure.
get_executable_path()
{
    [ -n "$1" ] && [ $# -eq 1 -o $# -eq 2 ] || return 1
    local _basis_gep_path=''
    # if no target name given, get path of this executable
    if [ $# -lt 2 ]; then
        _basis_gep_path="`get_real_path "$0"`"
    # otherwise, get path of executable built by named target
    else
        # get UID of target
        local _basis_gep_uid && get_target_uid _basis_gep_uid "$2"
        [ "${_basis_gep_uid:0:1}" == '.' ] && _basis_gep_uid=${_basis_gep_uid:1}
        if [ -n "${_basis_gep_uid}" ]; then
            # get path relative to this module
            _executabletargetinfo_get _basis_gep_path "${_basis_gep_uid}" LOCATION
            if [ -n "${_basis_gep_path}" ]; then
                # make path absolute
                _basis_gep_path=`to_absolute_path "${_BASIS_DIR}" "${path}"`
                [ $? -eq 0 ] || return 1
            else
                _basis_gep_path=`/usr/bin/which "$2" 2> /dev/null`
            fi
        else
            _basis_gep_path=`/usr/bin/which "$2" 2> /dev/null`
        fi
    fi
    # return path
    local "$1" && upvar $1 "${_basis_gep_path}"
    [ $? -eq 0 ] && [ -n "${_basis_gep_path}" ]
}

# ----------------------------------------------------------------------------
## @brief Get name of executable file.
#
# @param [out] file Name of executable file or an empty string if not found.
#                   If @p name is not given, the name of this executable is returned.
# @param [in]  name Name of command or an empty string.
#
# @returns Whether or not the command was found.
#
# @retval 0 On success.
# @retval 1 On failure.
get_executable_name()
{
    [ -n "$1" ] && [ $# -eq 1 -o $# -eq 2 ] || return 1
    local _basis_gen_path && get_executable_path _basis_gen_path
    [ $? -eq 0 ] || return 1
    local _basis_gen_name="`basename "${_basis_gen_path}"`"
    local "$1" && upvar $1 "${_basis_gen_name}"
}

# ----------------------------------------------------------------------------
## @brief Get directory of executable file.
#
# @param [out] dir  Directory of executable file or an empty string if not found.
#                   If @p name is not given, the directory of this executable is returned.
# @param [in]  name Name of command or an empty string.
#
# @returns Whether or not the command was found.
#
# @retval 0 On success.
# @retval 1 On failure.
get_executable_directory()
{
    [ -n "$1" ] && [ $# -eq 1 -o $# -eq 2 ] || return 1
    local _basis_ged_path && get_executable_path _basis_ged_path
    [ $? -eq 0 ] || return 1
    local _basis_ged_dir="`dirname "${_basis_ged_path}"`"
    local "$1" && upvar $1 "${_basis_ged_dir}"
}

# ============================================================================
# command execution
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Build quoted string from array.
#
# Example:
# @code
# basis_array_to_quoted_string str 'this' "isn't" a 'simple example of "a quoted"' 'string'
# echo "${str}"
# @endcode
#
# @param [out] var      Name of result variable for quoted string.
# @param [in]  elements All remaining arguments are considered to be the
#                       elements of the array to convert.
#
# @returns Nothing.
to_quoted_string()
{
    local _basis_tqs_str=''
    local _basis_tqs_element=''
    # GNU bash, version 3.00.15(1)-release (x86_64-redhat-linux-gnu)
    # turns the array into a single string value if local is used
    if [ ${BASH_VERSION_MAJOR} -gt 3 ] || [ ${BASH_VERSION_MAJOR} -eq 3 -a ${BASH_VERSION_MINOR} -gt 0 ]; then
        local _basis_tqs_args=("$@")
    else
        _basis_tqs_args=("$@")
    fi
    local _basis_tqs_i=1
    while [ $_basis_tqs_i -lt ${#_basis_tqs_args[@]} ]; do
        _basis_tqs_element="${_basis_tqs_args[$_basis_tqs_i]}"
        # escape double quotes
        _basis_tqs_element=`echo -n "${_basis_tqs_element}" | sed "s/\"/\\\\\\\\\"/g"`
        # surround element by double quotes if it contains single quotes or whitespaces
        match "${_basis_tqs_element}" "[' ]" && _basis_tqs_element="\"${_basis_tqs_element}\""
        # append element
        [ -n "${_basis_tqs_str}" ] && _basis_tqs_str="${_basis_tqs_str} "
        _basis_tqs_str="${_basis_tqs_str}${_basis_tqs_element}"
        # next argument
        let _basis_tqs_i++
    done
    local "$1" && upvar $1 "${_basis_tqs_str}"
}

# ----------------------------------------------------------------------------
## @brief Split (quoted) string.
#
# This function can be used to split a (quoted) string into its elements.
#
# Example:
# @code
# str="'this' 'isn\'t' a \"simple example of \\\"a quoted\\\"\" 'string'"
# basis_split array "${str}"
# echo ${#array[@]}  # 5
# echo "${array[3]}" # simple example of "a quoted"
# @endcode
#
# @param [out] var Result variable for array.
# @param [in]  str Quoted string.
#
# @returns Nothing.
split_quoted_string()
{
    [ $# -eq 2 ] || return 1
    # GNU bash, version 3.00.15(1)-release (x86_64-redhat-linux-gnu)
    # turns the array into a single string value if local is used
    if [ ${BASH_VERSION_MAJOR} -gt 3 ] || [ ${BASH_VERSION_MAJOR} -eq 3 -a ${BASH_VERSION_MINOR} -gt 0 ]; then
        local _basis_sqs_array=()
    else
        _basis_sqs_array=()
    fi
    local _basis_sqs_str=$2
    # match arguments from left to right
    while match "${_basis_sqs_str}" "[ ]*('([^']|\\\')*[^\\]'|\"([^\"]|\\\")*[^\\]\"|[^ ]+)(.*)"; do
        # matched element including quotes
        _basis_sqs_element="${BASH_REMATCH[1]}"
        # remove quotes
        _basis_sqs_element=`echo "${_basis_sqs_element}" | sed "s/^['\"]//;s/(^|[^\\])['\"]$//"`
        # replace quoted quotes within argument by quotes
        _basis_sqs_element=`echo "${_basis_sqs_element}" | sed "s/[\\]'/'/g;s/[\\]\"/\"/g"`
        # add to resulting array
        _basis_sqs_array[${#_basis_sqs_array[@]}]="${_basis_sqs_element}"
        # continue with residual command-line
        _basis_sqs_str="${BASH_REMATCH[4]}"
    done
    # return
    local "$1" && upvar $1 "${_basis_sqs_array[@]}"
}

# ----------------------------------------------------------------------------
## @brief Execute command as subprocess.
#
# This function is used to execute a subprocess within a Bash script.
#
# Example:
# @code
# # the next command will exit the current shell if it fails
# execute_process ls /not/existing
# # to prevent this, provide the --allow_fail option
# execute_process --allow_fail ls /not/existing
# # to make it explicit where the command-line to execute starts, use --
# execute_process --allow_fail -- ls /not/existing
# @endcode
#
# Note that the output of the command is not redirected by this function.
# In order to execute the command quietly, use this function as follows:
# @code
# execute_process ls / &> /dev/null
# @endcode
# Or to store the command output in a variable including error messages
# use it as follows:
# @code
# output=`execute_process ls / 2>&1`
# @endcode
# Note that in this case, the option --allow_fail has no effect as the
# calling shell will never be terminated. Only the subshell in which the
# command is executed will be terminated. Checking the exit code $? is
# in this case required.
#
# @param [in] options Function options as documented below.
# @param [in] cmd     Executable of command to run or corresponding build
#                     target name. This is assumed to be the first
#                     non-option argument or the argument that follows the
#                     special '--' argument.
# @param [in] args    All remaining arguments are passed as arguments to
#                     the given command.
# @par Options:
# <table border="0">
#   <tr>
#     @tp <b>-f, --allow_fail</b> @endtp
#     <td>Allows the command to fail. By default, if the command
#         returns a non-zero exit code, the exit() function is
#         called to terminate the current shell.</td>
#   </tr>
#   <tr>
#     @tp <b>-v, --verbose</b> [int] @endtp
#     <td>Print command-line to stdout before execution. Optionally, as it is
#         sometimes more convenient to pass in the value of another variable
#         which controls the verbosity of the parent process itself, a verbosity
#         value can be specified following the option flag. If this verbosity
#         less or equal to zero, the command-line of the subprocess is not
#         printed to stdout, otherwise it is.</td>
#   </tr>
#   <tr>
#     @tp <b>-s, --simulate</b> @endtp
#     <td>If this option is given, the command is not actually
#         executed, but the command-line printed to stdout only.</td>
#   </tr>
# </table>
#
# @returns Exit code of subprocess.
execute_process()
{
    # parse arguments
    local _basis_ep_allow_fail='false'
    local _basis_ep_simulate='false'
    local _basis_ep_verbose=0
    local _basis_ep_args=''
    while [ $# -gt 0 ]; do
        case "$1" in
            -f|--allow_fail) _basis_ep_allow_fail='true'; ;;
            -s|--simulate)   _basis_ep_simulate='true';   ;;
            -v|--verbose)
                if [ `match "$2" '^-?[0-9]+$'` ]; then
                    _basis_ep_verbose=$2
                    shift
                else
                    let _basis_ep_verbose++
                fi
                ;;
            --)              shift; break; ;;
            *)               break; ;;
        esac
        shift
    done
    # command to execute and its arguments
    local _basis_ep_command="$1"; shift
    [ -n "${_basis_ep_command}" ] || echo "execute_process(): No command specified to execute" 1>&2; return 1
    # get absolute path of executable
    local _basis_ep_exec && get_executable_path _basis_ep_exec "${_basis_ep_command}"
    [ -n "${_basis_ep_exec}" ] || echo "${_basis_ep_command}: Command not found" 1>&2; exit 1
    # some verbose output
    [ ${verbose} -lt 1 ] || {
        to_quoted_string _basis_ep_args "$@"
        echo "\$ ${_basis_ep_exec} ${_basis_ep_args}"
    }
    # execute command
    [ "${_basis_ep_simulate}" == 'true' ] || "${_basis_ep_exec}" "$@"
    local _basis_ep_status=$?
    # if command failed, exit
    [ ${_basis_ep_status} -eq 0 -o "${_basis_ep_allow_fail}" == 'true' ] || {
        [ -n "${_basis_ep_args}" ] || to_quoted_string _basis_ep_args "$@"
        echo
        echo "Command ${_basis_ep_exec} ${_basis_ep_args} failed" 1>&2
        exit 1
    }
    # return exit code
    return ${_basis_ep_status}
}


## @}
# end of Doxygen group

# ============================================================================
# private
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Sanitize string for use in variable name.
#
# @param [out] out Sanitized string.
# @param [in]  str String to be sanitized.
#
# @returns Nothing.
#
# @retval 0 On success.
# @retval 1 On failure.
_executabletargetinfo_sanitize()
{
    [ $# -eq 2 ] || return 1
    [ -n "$2" ] || {
        upvar $1 ''
        return 0
    }
    local sane="`echo -n "$2" | tr [:space:] '_' | tr -c [:alnum:] '_'`"
    [ -n "${sane}" ] || {
        echo "_executabletargetinfo_sanitize(): Failed to sanitize string '$2'" 1>&2
        exit 1
    }
    local "$1" && upvar $1 "${sane}"
}

# ----------------------------------------------------------------------------
## @brief Add (key, value) pair to executable target info "hash".
#
# @param [in] key   Hash key.
# @param [in] name  Name of the hash table.
# @param [in] value Value associated with the given hash key.
#
# @returns Sets a readonly variable that represents the (key, value) entry.
#
# @sa _executabletargetinfo_get()
_executabletargetinfo_add()
{
    [ $# -eq 3 ] || return 1

    local key  && _executabletargetinfo_sanitize key  "$1"
    local name && _executabletargetinfo_sanitize name "$2"
    [ -n "${key}" ] && [ -n "${name}" ] || {
        if [ -z "${key}" ] && [ -z "${name}" ]; then
            echo "_executabletargetinfo_add(): Neither lookup table nor key specified" 1>&2
        elif [ -z "${key}" ]; then
            echo "_executabletargetinfo_add(): No key specified for addition to hash table '${name}'" 1>&2
        else
            echo "_executabletargetinfo_add(): No lookup table given for addition of key '${key}'" 1>&2
        fi
        exit 1
    }
    eval "readonly __EXECUTABLETARGETINFO_${name}_${key}='$3'"
    if [ $? -ne 0 ]; then
        echo "Failed to add ${name} of key ${key} to executable target info map!" 1>&2
        echo "This may be caused by two CMake build target names being converted to the same key." 1>&2
        exit 1
    fi
}

# ----------------------------------------------------------------------------
## @brief Get value from executable target info "hash".
#
# @param [out] value Value corresponding to given @p key
#                    or an empty string if key is unknown.
# @param [in]  key   Hash key.
# @param [in]  name  Name of the hash table.
#
# @returns Nothing.
#
# @retval 0 On success.
# @retval 1 On failure.
#
# @sa _executabletargetinfo_add()
_executabletargetinfo_get()
{
    [ $# -eq 3 ] || return 1

    local key  && _executabletargetinfo_sanitize key  "$2"
    local name && _executabletargetinfo_sanitize name "$3"
    [ -n "${key}" ] && [ -n "${name}" ] || {
        if [ -z "${key}" ] && [ -z "${name}" ]; then
            echo "_executabletargetinfo_get(): Neither lookup table nor key specified" 1>&2
        elif [ -z "${key}" ]; then
            echo "_executabletargetinfo_get(): No key specified for lookup in hash table '${name}'" 1>&2
        else
            echo "_executabletargetinfo_get(): No lookup table given for lookup of key '${key}'" 1>&2
        fi
        exit 1
    }
    eval "local value=\${__EXECUTABLETARGETINFO_${name}_${key}}"

    local "$1" && upvar $1 "${value}"
}

_executabletargetinfo_initialize()
{
    [ $# -eq 0 ] || return 1
    _EXECUTABLETARGETINFO_INITIALIZED='true'
    return 0
}

# used to make relative paths in get_executable_path() absolute
# attention: only set if not set already by the basis.sh module
[ -z "${_BASIS_DIR}" ] && _BASIS_DIR="${_BASIS_UTILITIES_DIR}"


} # _SBIA_BASIS_UTILITIES_INCLUDED
