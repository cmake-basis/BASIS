#! /usr/bin/env bash

##############################################################################
# \file  basistest-svn.sh
# \brief Wrapper script for Subversion svn command.
#
# This script is used as wrapper for the svn command to enable automated
# software testing at our lab. In general, anonymous access to the Subversion
# repositories is not permitted. Only the svnuser is allowed to do so.
# Hence, a wrapper script was implemented which is only readable by the
# svnuser where the password is hard code. Moreover, only the svnuser can
# execute this script. The swtest user on the other side is allowed to run
# this script as svnuser via sudoers list.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# simply call the wrapper script with the password encoded as svnuser
exec sudo -u svnuser /bin/sh /sbia/home/svn/bin/svnwrap $@
