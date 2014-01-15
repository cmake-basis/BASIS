##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests of CMake modules.
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

if (PythonInterp_FOUND)
  basis_add_test (test_future_statements.py) 
endif ()

# ----------------------------------------------------------------------------
# test use MATLAB Compiler and MEX-script
if (MATLAB_EXECUTABLE AND MATLAB_MEX_EXECUTABLE AND PythonInterp_FOUND)
  basis_add_test (test_matlabtools.py)
  basis_set_tests_properties (test_matlabtools PROPERTIES TIMEOUT 1500)
endif ()
