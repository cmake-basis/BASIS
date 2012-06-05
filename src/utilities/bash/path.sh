##############################################################################
# @file  path.sh
# @brief Basic file path manipulation functions.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# return if already loaded
[ "${_SBIA_BASIS_PATH_INCLUDED:-0}" -eq 1 ] && return 0
_SBIA_BASIS_PATH_INCLUDED=1


# use local definitions instead of those in core.sh to keep module independent
_PATH_BASH_VERSION_MAJOR=${BASH_VERSION%%.*}
_PATH_BASH_VERSION_MINOR=${BASH_VERSION#*.}
_PATH_BASH_VERSION_MINOR=${_PATH_BASH_VERSION_MINOR%%.*}

readonly _PATH_BASH_VERSION_MAJOR
readonly _PATH_BASH_VERSION_MINOR



## @addtogroup BasisBashUtilities
#  @{


# ----------------------------------------------------------------------------
## @brief Clean path, i.e., remove occurences of "./", duplicate slashes,...
#
# This function removes single periods (.) enclosed by slashes or backslashes,
# duplicate slashes (/) or backslashes (\), and further tries to reduce the
# number of parent directory references.
#
# For example, "../bla//.//.\bla\\\\\bla/../.." is convert to "../bla".
#
# @param [in] path Path.
#
# @return Cleaned path.
function clean_path
{
    local path="$1"
    # GNU bash, version 3.00.15(1)-release (x86_64-redhat-linux-gnu)
    # turns the array into a single string value if local is used
    if [ ${_PATH_BASH_VERSION_MAJOR} -gt 3 ] || [ ${_PATH_BASH_VERSION_MAJOR} -eq 3 -a ${_PATH_BASH_VERSION_MINOR} -gt 0 ]; then
        local dirs=()
    else
        dirs=()
    fi
    # split path into parts, discarding redundant slashes
    while [ -n "${path}" ]; do
        if [ ${#dirs[@]} -eq 0 ]; then
            dirs=("`basename -- "${path}"`")
        else
            dirs=("`basename -- "${path}"`" "${dirs[@]}")
        fi
        path="`dirname -- "${path}"`"
        if [ "${path}" == '/' ]; then
            path=''
        fi
    done
    # build up path again from the beginning,
    # discarding dots ('.') and stepping one level up for each '..' 
    local i=0
    while [ $i -lt ${#dirs[@]} ]; do
        if [ "${dirs[$i]}" != '.' ]; then
            if [ "${dirs[$i]}" == '..' ]; then
                path=`dirname -- "${path}"`
            else
                path="${path}/${dirs[$i]}"
            fi
        fi
        let i++
    done
    # return
    echo -n "${path}"
}

# ----------------------------------------------------------------------------
## @brief Get absolute path given a relative path.
#
# This function converts a relative path to an absolute path. If the given
# path is already absolute, this path is passed through unchanged.
#
# @param [in] path Absolute or relative path.
#
# @return Absolute path.
function to_absolute_path
{
    local base="$1"
    local path="$2"
    if [ "${base:0:1}" != '/' ]; then
        base="`pwd`/${base}"
    fi
    if [ "${path:0:1}" != '/' ]; then
        path="${base}/${path}"
    fi
    clean_path "${path}"
}

# ----------------------------------------------------------------------------
## @brief Get canonical file path.
#
# This function resolves symbolic links and returns a cleaned path.
#
# @param [in] path Path.
#
# @return Canonical file path without duplicate slashes, ".", "..",
#         and symbolic links.
function get_real_path
{
    # make path absolute and resolve '..' references
    local path=`to_absolute_path "$1"`
    if ! [ -e "${path}" ]; then echo -n "${path}"; return; fi
    # resolve symbolic links within path
    path=`cd -P -- $(dirname -- "${path}") && pwd -P`/`basename -- "${path}"`
    # if path itself is a symbolic link, follow it
    local i=0
    local cur="${path}"
    while [ -h "${cur}" ] && [ $i -lt 100 ]; do
        dir=`dirname -- "${cur}"`
        cur=`readlink -- "${cur}"`
        cur=`cd "${dir}" && cd $(dirname -- "${cur}") && pwd`/`basename -- "${cur}"`
        (( i++ ))
    done
    # If symbolic link could entirely be resolved in less than 100 iterations,
    # return the obtained canonical file path. Otherwise, return the original
    # link which could not be resolved due to some probable cycle.
    if [ $i -lt 100 ]; then path="${cur}"; fi
    # return
    echo -n "${path}"
}


## @}
# end of Doxygen group
