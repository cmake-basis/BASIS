#! /usr/bin/env bash

##############################################################################
# @file  make_html_verbatim.sh
# @brief Auxiliary script used to convert plain text file such that the
#        content can be pasted into the body of a HTML &lt;verbatim&gt; tag.
#
# Copyright (c) 2011, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

if [ $# -eq 0 -o "$1" == "--help" -o "$1" == "--helpshort" -o "$1" == "-h" ]; then
    echo "Usage: make_html_verbatim <text file>"
    exit 1
fi

sed 's/</\&lt;/g;s/>/\&gt;/g' "$1"
