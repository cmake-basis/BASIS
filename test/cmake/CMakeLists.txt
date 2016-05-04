##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests of CMake modules.
##############################################################################

# ============================================================================
# auxiliary functions
# ============================================================================

# ----------------------------------------------------------------------------
# common CMake test command arguments
set (
  BASIS_COMMON_CMAKE_TEST_ARGS
    "-DBASIS_DIR=${TESTING_BASIS_DIR}"
    "-DMODULE_PATH=${BASIS_MODULE_PATH}"
    "-DINPUT_DIR=${PROJECT_TESTING_DIR}/ressources"
    "-DOUTPUT_DIR=${TESTING_OUTPUT_DIR}"
)

# ----------------------------------------------------------------------------
macro (basis_get_cmake_test_arguments)
  set (ARGS "${BASIS_COMMON_CMAKE_TEST_ARGS}")
  while (ARGN)
    list (GET ARGN 0 VAR)
    list (GET ARGN 1 VALUE)
    list (APPEND ARGS "-D${VAR}=${VALUE}")
    list (REMOVE_AT ARGN 0 1)
  endwhile ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Auxiliary command to add a scriptable CMake test command
macro (basis_add_cmake_test_script TEST)
  basis_get_cmake_test_arguments ()
  basis_add_test (${TEST} COMMAND "${CMAKE_COMMAND}" ${ARGS} -P "${CMAKE_CURRENT_SOURCE_DIR}/${TEST}.cmake")
endmacro ()

# ----------------------------------------------------------------------------
## @brief Auxiliary command to add a CMake build configuration test
macro (basis_add_cmake_test TEST)
  basis_get_cmake_test_arguments ()
  configure_file ("${CMAKE_CURRENT_SOURCE_DIR}/${TEST}.cmake" "${TESTING_OUTPUT_DIR}/${TEST}/CMakeLists.txt" COPYONLY)
  basis_add_test (${TEST} COMMAND "${CMAKE_COMMAND}" ${ARGS} WORKING_DIRECTORY "${TESTING_OUTPUT_DIR}/${TEST}")
endmacro ()

# ============================================================================
# tests
# ============================================================================

# ----------------------------------------------------------------------------
# tests of CommonTools.cmake functions
basis_add_cmake_test_script (test_string_manipulation)
basis_add_cmake_test        (test_target_properties)

if (PythonInterp_FOUND)
  basis_add_test (test_future_statements.py) 
endif ()

# ----------------------------------------------------------------------------
# test use MATLAB Compiler and MEX-script
if (MATLAB_EXECUTABLE AND MATLAB_MEX_EXECUTABLE AND PythonInterp_FOUND)
  basis_add_test (test_matlabtools.py LINK_DEPENDS testaux_py)
  basis_set_tests_properties (test_matlabtools PROPERTIES TIMEOUT 1500)
endif ()
