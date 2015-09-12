##############################################################################
# @file  test_target_properties.cmake
# @brief Test basis_set_target_properites() and basis_get_target_properties().
##############################################################################

cmake_minimum_required (VERSION 2.8.4)

find_package (BASIS REQUIRED)
basis_use_package (BASIS)

function (assert_target_property TARGET PROPERTY EXPECTED_VALUE)
  message ("assert_target_property(${TARGET} ${PROPERTY} ${EXPECTED_VALUE})")
  basis_get_target_property (ACTUAL_VALUE ${TARGET} ${PROPERTY})
  if (NOT "^${ACTUAL_VALUE}$" MATCHES "^${EXPECTED_VALUE}$")
    message (FATAL_ERROR "Property ${PROPERTY} of ${TARGET}:\n\texpected: \"${EXPECTED_VALUE}\"\n\tactual:  \"${ACTUAL_VALUE}\"\n")
  endif ()
endfunction ()

basis_add_executable (foo "${INPUT_DIR}/dummy_command.cxx" NO_BASIS_UTILITIES)

basis_set_target_properties (foo PROPERTIES OUTPUT_NAME bar)
assert_target_property (foo OUTPUT_NAME bar)

basis_set_target_properties (foo PROPERTIES EMPTY_PROPERTY "")
assert_target_property (foo EMPTY_PROPERTY "")

basis_set_target_properties (foo PROPERTIES LIST_PROPERTY "a;b;c;d")
assert_target_property (foo LIST_PROPERTY "a;b;c;d")
