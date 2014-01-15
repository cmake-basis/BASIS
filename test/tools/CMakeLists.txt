##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests for command-line tools.
##############################################################################

if (PythonInterp_FOUND)
  basis_add_test (test_basisproject.py LINK_DEPENDS testaux_py)
  basis_set_tests_properties (test_basisproject PROPERTIES TIMEOUT 2700)
endif ()
