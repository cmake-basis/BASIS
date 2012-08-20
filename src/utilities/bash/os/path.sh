##############################################################################
# @file  os/path.sh
# @brief Path manipulation functions.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

[ "${_BASIS_OS_PATH_INCLUDED}" == 'true' ] || {
_BASIS_OS_PATH_INCLUDED='true'


. "`cd -P -- \`dirname -- "${BASH_SOURCE}"\` && pwd`/../config.sh" || exit 1


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
normpath()
{
    local _basis_cp_path="$1"
    # GNU bash, version 3.00.15(1)-release (x86_64-redhat-linux-gnu)
    # turns the array into a single string value if local is used
    if [ ${BASH_VERSION_MAJOR} -gt 3 ] || [ ${BASH_VERSION_MAJOR} -eq 3 -a ${BASH_VERSION_MINOR} -gt 0 ]; then
        local _basis_cp_dirs=()
    else
        _basis_cp_dirs=()
    fi
    # split path into parts, discarding redundant slashes
    while [ -n "${_basis_cp_path}" ]; do
        if [ ${#_basis_cp_dirs[@]} -eq 0 ]; then
            _basis_cp_dirs=("`basename -- "${_basis_cp_path}"`")
        else
            _basis_cp_dirs=("`basename -- "${_basis_cp_path}"`" "${_basis_cp_dirs[@]}")
        fi
        _basis_cp_path="`dirname -- "${_basis_cp_path}"`"
        if [ "${_basis_cp_path}" == '/' ]; then
            _basis_cp_path=''
        fi
    done
    # build up path again from the beginning,
    # discarding dots ('.') and stepping one level up for each '..' 
    local _basis_cp_i=0
    while [ ${_basis_cp_i} -lt ${#_basis_cp_dirs[@]} ]; do
        if [ "${_basis_cp_dirs[${_basis_cp_i}]}" != '.' ]; then
            if [ "${_basis_cp_dirs[${_basis_cp_i}]}" == '..' ]; then
                _basis_cp_path=`dirname -- "${_basis_cp_path}"`
            else
                _basis_cp_path="${_basis_cp_path}/${_basis_cp_dirs[${_basis_cp_i}]}"
            fi
        fi
        let _basis_cp_i++
    done
    # return
    echo -n "${_basis_cp_path}"
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
abspath()
{
    local _basis_tap_base="$1"
    local _basis_tap_path="$2"
    if [ "${_basis_tap_base:0:1}" != '/' ]; then
        _basis_tap_base="`pwd`/${_basis_tap_base}"
    fi
    if [ "${_basis_tap_path:0:1}" != '/' ]; then
        _basis_tap_path="${_basis_tap_base}/${_basis_tap_path}"
    fi
    normpath "${_basis_tap_path}"
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
realpath()
{
    # make path absolute and resolve '..' references
    local _basis_grp_path=`abspath "$1"`
    if ! [ -e "${_basis_grp_path}" ]; then echo -n "${_basis_grp_path}"; return; fi
    # resolve symbolic links within path
    _basis_grp_path=`cd -P -- $(dirname -- "${_basis_grp_path}") && pwd -P`/`basename -- "${_basis_grp_path}"`
    # if path itself is a symbolic link, follow it
    local _basis_grp_i=0
    local _basis_grp_cur="${_basis_grp_path}"
    while [ -h "${_basis_grp_cur}" ] && [ ${_basis_grp_i} -lt 100 ]; do
        _basis_grp_dir=`dirname -- "${_basis_grp_cur}"`
        _basis_grp_cur=`readlink -- "${_basis_grp_cur}"`
        _basis_grp_cur=`cd "${_basis_grp_dir}" && cd $(dirname -- "${_basis_grp_cur}") && pwd`/`basename -- "${_basis_grp_cur}"`
        let _basis_grp_i++
    done
    # If symbolic link could entirely be resolved in less than 100 iterations,
    # return the obtained canonical file path. Otherwise, return the original
    # link which could not be resolved due to some probable cycle.
    if [ ${_basis_grp_i} -lt 100 ]; then _basis_grp_path="${_basis_grp_cur}"; fi
    # return
    echo -n "${_basis_grp_path}"
}


## @}
# end of Doxygen group


} # _BASIS_PATH_INCLUDED
