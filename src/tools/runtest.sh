#! /usr/bin/env bash

##############################################################################
# @file  runtest.sh
# @brief Helper script for execution of test command.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# auxiliary functions
# ============================================================================

# ----------------------------------------------------------------------------
## Remove all files and directories from the current working directory.
clean()
{
    local root="$1"
    find "${root}" -delete
    if [ $? -ne 0 ]; then
        echo "Failed to clean directory ${root}" 1>&2
    fi
}

# ----------------------------------------------------------------------------
## Output special information for inclusion in submission to CDash.
print_dart_measurements()
{
    echo -n "<DartMeasurement name=\"Host Name\" type=\"string\">"
    echo -n `hostname`
    echo "</DartMeasurement>"
    echo -n "<DartMeasurement name=\"Working Directory\" type=\"string\">"
    echo -n `pwd`
    echo "</DartMeasurement>"
}

# ============================================================================
# main
# ============================================================================

clean_before='false'
clean_after='false'
dart='true'
cmd=()

while [ $# -gt 0 ]; do
    case "$1" in
        '--clean-before') clean_before='true';             ;;
        '--clean-after')  clean_after='true';              ;;
        '--nodart')       dart='false';                    ;;
        '--')             shift; cmd=("${cmd[@]}" "$@");   ;;
        *)                cmd=("${cmd[@]}" "$1")           ;;
    esac
    shift
done

if [ ${#cmd[@]} -eq 0 ]; then
    echo "Missing test command!" 1>&2
    exit 1
fi

cwd=`pwd`
if [ $dart == 'true' ]; then
    print_dart_measurements
fi
if [ $clean_before == 'true' ]; then
    clean "${cwd}"
fi
"${cmd[@]}"
retval=$?
if [ $clean_after == 'true' ]; then
    clean "${cwd}"
fi

exit ${retval}
