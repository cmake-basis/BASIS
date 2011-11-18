##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests of CMake modules.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# helper
function (cmake_test TEST)
  set (ARGS)
  list (APPEND ARGS "-D" "OUTPUT_DIR=${TESTING_OUTPUT_DIR}")
  list (APPEND ARGS "-D" "MODULE_PATH=${BASIS_MODULE_PATH}")
  while (ARGN)
    list (GET ARGN 0 VAR)
    list (GET ARGN 1 VALUE)
    list (ARGS APPEND "-D" "${VAR}=${VALUE}")
    list (REMOVE_AT ARGN 0 1)
  endwhile ()
  basis_add_test (
    ${TEST}
    COMMAND
      "${CMAKE_COMMAND}" ${ARGS}
      -P "${CMAKE_CURRENT_SOURCE_DIR}/${TEST}.cmake"
  )
endfunction ()

# ----------------------------------------------------------------------------
# tests of CommonTools.cmake functions
cmake_test (test_string_manipulation)
cmake_test (test_basis_target_uid)
