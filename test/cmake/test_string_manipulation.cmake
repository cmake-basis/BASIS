##############################################################################
# @file  test_basis_target_uid.cmake
# @brief Test basis_target_uid() and related functions.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
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
