##############################################################################
# @file  FindSparseBayes.cmake
# @brief Find SparseBayes package from Vector Anomaly Limited.
#
# @sa http://www.vectoranomaly.com/downloads/downloads.htm
##############################################################################

#=============================================================================
# Copyright 2011-2012 University of Pennsylvania
# Copyright 2013-2016 Andreas Schuh <andreas.schuh.84@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

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
