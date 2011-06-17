#! /usr/bin/env bash

##############################################################################
# \file  basistest-cron
# \brief This script is setup as a cron job to perform the automated tests.
#
# This script sets up the environment for the actual master script which
# handles the automated testing. Further, it uses qsub to submit testing jobs
# to the configured SGE queue, with the SGE options as set in this script.
#
# Edit this script to change the settings of the automated testing.
# The default settings are the ones used for the cron job running on the
# cluster of our lab as the 'swtest' user.
#
# The configuration of automated tests is done in the configuration file
# for the basistest-master. See value of conf variable below.
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

# output file for test log; used for -o and -e option of qsub
log='/sbia/home/swtest/var/log/basistest.$JOB_ID.log'

# configurtion file; configure the automated tests here, see basistestd -h
conf='/sbia/home/swtest/etc/basistest.conf'

# schedule file; note that this file is created/updated by the testing daemon
schedule='/sbia/home/swtest/var/run/basistest.schedule'

# test execution command
cmd='/sbia/home/swtest/basis/bin/basistest-slave -V'

# ============================================================================
# main
# ============================================================================

# source environment settings of test user
source /sbia/home/swtest/.bashrc

# prepend test command by qsub command
if [ $SGE -ne 0 ]; then
    submit='qsub -S /bin/bash -cwd'
    if [ ! -z "$queue" ]; then submit="$submit -l $queue"; fi
    if [ ! -z "$mail" ]; then submit="$submit -M $mail -m b -m e -m a"; fi
    if [ ! -z "$log" ]; then submit="$submit -o $log -e $log"; fi
    cmd="$submit $cmd"
fi

# run actual testing master
exec /sbia/home/swtest/basis/bin/basistest-master -c "$conf" -s "$schedule" -t "$cmd"
