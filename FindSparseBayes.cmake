##############################################################################
# @file  FindSparseBayes.cmake
# @brief Find SparseBayes package from Vector Anomaly Limited.
#
# @sa http://www.vectoranomaly.com/downloads/downloads.htm
#
# Copyright (c) 2011-2012 University of Pennsylvania. <br />
# Copyright (c) 2013-2014 Andreas Schuh.              <br />
# All rights reserved.                                <br />
#
# See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
# or COPYING file for license information.
#
# Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
#          report issues at https://github.com/schuhschuh/cmake-basis/issues
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
