##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests of CMake modules.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
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
    list (APPEND ARGS "-D" "${VAR}=${VALUE}")
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

# ----------------------------------------------------------------------------
# test use MATLAB Compiler and MEX-script
if (MATLAB_EXECUTABLE AND MATLAB_MEX_EXECUTABLE AND PythonInterp_FOUND)
  basis_add_test (test_matlabtools.py)
  basis_set_tests_properties (test_matlabtools PROPERTIES TIMEOUT 1500)
endif ()
