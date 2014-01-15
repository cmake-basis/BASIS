##############################################################################
# @file  test_basis_target_uid.cmake
# @brief Test basis_target_uid() and related functions.
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

# ----------------------------------------------------------------------------
# include modules
include ("${MODULE_PATH}/CommonTools.cmake")

# ----------------------------------------------------------------------------
# test basis_sanitize_for_regex()
basis_sanitize_for_regex (S "module.py")
if (NOT "${S}" STREQUAL "module\\.py")
  message (FATAL_ERROR "Expected 'module\\.py' got '${S}'.")
endif ()
basis_sanitize_for_regex (S "mo.du+a*")
if (NOT "${S}" STREQUAL "mo\\.du\\+a\\*")
  message (FATAL_ERROR "Expected 'mo\\.du\\+a\\*' got '${S}'.")
endif ()
basis_sanitize_for_regex (S "this is ^not the beginning")
if (NOT "${S}" STREQUAL "this is \\^not the beginning")
  message (FATAL_ERROR "Expected 'this is \\^not the beginning' got '${S}'.")
endif ()
basis_sanitize_for_regex (S "not the end$ yet")
if (NOT "${S}" STREQUAL "not the end\\$ yet")
  message (FATAL_ERROR "Expected 'not the end\\$ yet' got '${S}'.")
endif ()
basis_sanitize_for_regex (S "neither ^start nor end$ match")
if (NOT "${S}" STREQUAL "neither \\^start nor end\\$ match")
  message (FATAL_ERROR "Expected 'neither \\^start nor end\\$ match' got '${S}'.")
endif ()
