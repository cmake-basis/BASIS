##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of tests for utilities.
##############################################################################

# ----------------------------------------------------------------------------
# project independent utilities
basis_add_test (test_os.cxx         UNITTEST LINK_DEPENDS basis)
basis_add_test (test_path.cxx       UNITTEST LINK_DEPENDS basis)
basis_add_test (test_subprocess.cxx UNITTEST LINK_DEPENDS basis)

if (BASIS_UTILITIES_ENABLED MATCHES "BASH")
  basis_add_test (test_core.sh        UNITTEST LINK_DEPENDS basis)
  basis_add_test (test_shutilities.sh UNITTEST LINK_DEPENDS basis)
  basis_add_test (test_shtap.sh       UNITTEST LINK_DEPENDS basis)
endif ()

basis_add_executable (parseargs.cxx)
basis_target_link_libraries (parseargs basis)
basis_add_test (parseargs           COMMAND parseargs foo) # to test if there is no memory leak
basis_add_test (parseargs-help      COMMAND parseargs --help)
basis_add_test (parseargs-helpshort COMMAND parseargs --helpshort)
basis_add_test (parseargs-version   COMMAND parseargs --version)

# ----------------------------------------------------------------------------
# project-specific utilities
if (BASIS_UTILITIES_ENABLED MATCHES "PYTHON")
  basis_add_test (test_utilities.py LINK_DEPENDS basis testaux_py)
  basis_set_tests_properties (test_utilities PROPERTIES TIMEOUT 1500)
endif ()
