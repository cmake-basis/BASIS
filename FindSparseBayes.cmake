##############################################################################
# @file  FindSparseBayes.cmake
# @brief Find SparseBayes package from Vector Anomaly Limited.
#
# @sa http://www.vectoranomaly.com/downloads/downloads.htm
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

include (FindPackageHandleStandardArgs)

find_path (
  SparseBayes_DIR SparseBayes.m
  DOC "The directory containing SparseBayes.m file of the SparseBayes package."
)

set (SparseBayes_INCLUDE_DIR "${SparseBayes_DIR}")

find_package_handle_standard_args (
  SparseBayes
  REQUIRED_ARGS
    SparseBayes_INCLUDE_DIR
)
