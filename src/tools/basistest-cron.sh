#! /bin/bash

##############################################################################
# \file  basistest-cron
# \brief This script is setup as a cron job to perform the automated tests.
#
# This script sets up the environment for the actual daemon which handles
# the automated testing. Further, it uses qsub to submit testing jobs to the
# configured SGE queue, with the SGE options as set in this script.
#
# Edit this script to change the settings of the automated testing.
# The configuration of automated tests is done in the configuration file
# for the basistestd daemon. See value of conf variable below.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html for details.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# settings
# ============================================================================

# whether to use SGE or not
SGE=1

# SGE queue; set to '' to not specify any
queue='tesla'

# mail address for SGE notifications; set to '' to disable notifications
mail='sbia-admin@uphs.upenn.edu'

# configurtion file; configure the automated tests here, see basistestd -h
conf='/sbia/home/swtest/etc/basistestd.conf'

# schedule file; note that this file is created/updated by the testing daemon
schedule='/sbia/home/swtest/var/run/basistestd.schedule'

# test execution command
cmd='/sbia/home/swtest/basis/bin/basistest -V'

# ============================================================================
# main
# ============================================================================

# adjust test command
if [ $SGE -ne 0 ]; then
    submit='qsub -S /bin/bash -cwd'
    if [ ! -z "$queue" ]; then submitCmd="$submit -l $queue"; fi
    if [ ! -z "$mail" ]; then submitCmd="$submit -M $mail -m b -m e -m a"; fi
    cmd="$submit $cmd"
fi

# run actual testing daemon
source /sbia/home/swtest/.bashrc
exec /sbia/home/swtest/basis/bin/basistestd -c "$conf" -s "$schedule" -t "$cmd"
