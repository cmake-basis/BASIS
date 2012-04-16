##############################################################################
# @file  core.sh
# @brief Core functions for BASH.
#
# This is the core module of the BASIS utilities for BASH. It implements
# fundamental functions for the development in BASH. Therefore, this module
# has to be kept independent of any other modules and shall only make use
# of BASH builtin's and basic commands.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# return if already loaded
[ "${_SBIA_CORE_INCLUDED:-0}" -eq 1 ] && return 0
_SBIA_CORE_INCLUDED=1


## @addtogroup BasisBashUtilities
#  @{


# ============================================================================
# constants
# ============================================================================

BASH_VERSION_MAJOR=${BASH_VERSION%%.*}
BASH_VERSION_MINOR=${BASH_VERSION#*.}
BASH_VERSION_MINOR=${BASH_VERSION_MINOR%%.*}

readonly BASH_VERSION_MAJOR
readonly BASH_VERSION_MINOR

# ============================================================================
# pattern matching
# ============================================================================

# ----------------------------------------------------------------------------
## @brief This function implements a more portable way to do pattern matching.
#
# Unfortunately, there are significant differences in the way patterns have
# to be matched when using different shells. This function considers which
# shell is used (at the moment only BASH), and uses the appropriate syntax
# for the pattern matching.
#
# @param [in] value   The string to match against pattern.
# @param [in] pattern The pattern to match.
#
# @returns Whether the given string matches the given pattern.
#
# @retval 0 On match.
# @retval 1 Otherwise.
function match
{
    [ $# -eq 2 ] || return 1

    local value=$1
    local pattern=$2

    if [ -z "${value}" ]; then
        [ -z "${pattern}" ]
    elif [ -z "${pattern}" ]; then
        [ -z "${value}" ]
    else
        if [ ${BASH_VERSION_MAJOR} -gt 2 ]; then
            # GNU bash, version 3.00.15(1)-release (x86_64-redhat-linux-gnu)
            # throws an error when a regular expression with groups
            # such as in '^(a|b|c)' is used. Here, quotes are required.
            if [ ${BASH_VERSION_MINOR} -eq 0 ]; then
                [[ "${value}" =~ "${pattern}" ]]
            # GNU bash, version 3.2.25(1)-release (x86_64-redhat-linux-gnu)
            # works with either quotes or not. However, on Mac OS Snow Leopard,
            # GNU bash, version 3.2.48(1)-release (x86_64-apple-darwin10.0)
            # requires that no quotes are used. The quotes are otherwise
            # considered to be part of the pattern.
            else
                [[ "${value}" =~ ${pattern} ]]
            fi
        else
            echo "${value}" | egrep -q "${pattern}"
        fi
    fi
}

# ============================================================================
# upvar(s)
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Assign variable one scope above the caller.
#
# This function can be used inside functions to return values by assigning
# them to a variable in the scope of the caller.
#
# @note For assigning multiple variables, use upvars(). Do NOT use multiple
#       upvar() calls, since one upvar() call might reassign a variable to
#       be used by another upvar() call.
#
# Example:
# @code
# foo ()
# {
#     local "$1" && upvar $1 "Hello, World!"
# }
#
# foo greeting
# echo ${greeting}
# @endcode
#
# @param [in] var    Variable name to assign value to
# @param [in] values Value(s) to assign. If multiple values, an array is
#                    assigned, otherwise a single value is assigned.
#
# @returns Nothing.
#
# @retval 0 On success.
# @retval 1 On failure.
#
# @sa upvars()
# @sa http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
function upvar
{
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

# ----------------------------------------------------------------------------
## @brief Assign variables one scope above the caller.
#
# @par Synopsis
# local varname [varname ...] && 
# upvars [-v varname value] | [-aN varname [value ...]] ...
#
# @par Options:
# - -aN  Assign next N values to varname as array
# - -v   Assign single value to varname#
#
# @retval 0 On success.
# @retval 1 On failure.
#
# @sa http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
function upvars
{
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                [[ "$2" ]] && unset -v "$2" && eval $2=\(\"\${@:3:${1#-a}}\"\) && 
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                [[ "$2" ]] && unset -v "$2" && eval $2=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            --help) echo "\
Usage: local varname [varname ...] &&
   ${FUNCNAME[0]} [-v varname value] | [-aN varname [value ...]] ...
Available OPTIONS:
-aN VARNAME [value ...]   assign next N values to varname as array
-v VARNAME value          assign single value to varname
--help                    display this help and exit
--version                 output version information and exit"
                return 0 ;;
            --version) echo "\
${FUNCNAME[0]}-0.9.dev
Copyright (C) 2010 Freddy Vulto
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law."
                return 0 ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}

# ============================================================================
# quoted string <-> array
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
function basis_array_to_quoted_string
{
    local str=''
    local element=''
    local args=("$@")
    local i=1
    while [ $i -lt ${#args[@]} ]; do
        element="${args[$i]}"
        # escape double quotes
        element=`echo -n "${element}" | sed "s/\"/\\\\\\\\\"/g"`
        # surround element by double quotes if it contains single quotes or whitespaces
        match "${element}" "[' ]" && element="\"${element}\""
        # append element
        [ -n "${str}" ] && str="${str} "
        str="${str}${element}"
        # next argument
        (( i++ ))
    done
    local "$1" && upvar $1 "${str}"
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
function basis_split
{
    [ $# -eq 2 ] || return 1
    local _basis_split_str=$2
    # match arguments from left to right
    while match "${_basis_split_str}" "[ ]*('([^']|\\\')*[^\\]'|\"([^\"]|\\\")*[^\\]\"|[^ ]+)(.*)"; do
        # matched element including quotes
        _basis_split_element="${BASH_REMATCH[1]}"
        # remove quotes
        _basis_split_element=`echo "${_basis_split_element}" | sed "s/^['\"]//;s/['\"]$//"`
        # replace quoted quotes within argument by quotes
        _basis_split_element=`echo "${_basis_split_element}" | sed "s/[\\]'/'/g;s/[\\]\"/\"/g"`
        # add to resulting array
        _basis_split_array[${#_basis_split_array[@]}]="${_basis_split_element}"
        # continue with residual command-line
        _basis_split_str="${BASH_REMATCH[4]}"
    done
    # return
    local "$1" && upvar $1 "${_basis_split_array[@]}"
}


## @}
# end of Doxygen group
