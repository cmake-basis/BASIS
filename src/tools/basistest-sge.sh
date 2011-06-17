#! /bin/bash

##############################################################################
# \file  basistest-sge.sh
# \brief Test job submission script for SGE (SBIA).
#
# This shell script can be used as a wrapper for the basistest script.
# It can be used together with the basistestd master script as follows:
#
#   $ basistestd --testcmd 'qsub basistest-sge'
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# SGE options
# ============================================================================

#$ -S /bin/bash
#$ -cwd
#$ -o /sbia/home/swtest/sge_job_output/$JOB_ID.stdout
#$ -e /sbia/home/swtest/sge_job_output/$JOB_ID.stderr
#$ -M sbia-admin@uphs.upenn.edu
#$ -m b
#$ -m e
#$ -m a

# at the moment, testing seems only to work on tesla; the other centos5
# machines may not have set the sudoers permission correctly and the
# centos4 machines cannot be used for coverage analysis
#$ -l tesla

# ============================================================================
# main
# ============================================================================

# \note do not use getProgDir here as SGE copies this script to a different
#       location then where the original one is located
exec basistest $@
