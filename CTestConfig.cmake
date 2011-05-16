##############################################################################
# \file  CTestConfig.cmake
# \brief CTest configuration file.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# set CTest/CDash project name
set (CTEST_PROJECT_NAME "${PROJECT_NAME}")

# start time of Nightly test model
#
# All Nightly tests which are executed within a time window of 24 hours
# starting at the specified start time, will replace previous submissions
# made within the same time frame such that for each time frame of 24 hours
# only one result of test executions is present on the dashboard.
# The execution of the Nightly tests is usually triggered automatically
# via a scheduled cron job that is run once every 24 hours.
#
# Use the Continuous or Experimental test models if you want to execute
# tests manually.
set (CTEST_NIGHTLY_START_TIME "00:00:00 EST")

# dashboard submission to SBIA CDash server
#
# \note By default, CTest does not support HTTPS as submission method.
#       In order to enable it, CTest (and hence CMake) has to be build
#       manually with the option CMAKE_USE_OPENSSL enabled.
set (CTEST_DROP_METHOD     "http")
set (CTEST_DROP_SITE       "sbia-portal.uphs.upenn.edu")
set (CTEST_DROP_LOCATION   "/cdash/submit.php?project=${CTEST_PROJECT_NAME}")
set (CTEST_DROP_SITE_CDASH TRUE)

# launchers
#
# \see CTest.cmake
set (CTEST_USE_LAUNCHERS 0)

