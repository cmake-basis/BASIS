##############################################################################
# @file  Settings.cmake
# @brief General project build configuration.
#
# This file can be used to overwrite the BASIS build configuration as defined
# by the BasisSettings module and to add project specific settings.
#
# This file is included by basis_project_initialize() if found in the
# PROJECT_CONFIG_DIR directory.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# options
# ============================================================================

option (BUILD_UTILITIES_FOR_CXX "Whether to build the C++ utilities." ON)
option (BUILD_UTILITIES_FOR_PYTHON "Whether to build the Python utilities." ON)
option (BUILD_UTILITIES_FOR_PERL "Whether to build the Perl utilities." ON)

if (UNIX)
  option (BUILD_UTILITIES_FOR_BASH "Whether to build the BASH utilities." ON)
else ()
  set (BUILD_UTILITIES_FOR_BASH OFF)
endif ()

# ============================================================================
# directories
# ============================================================================

# installation directory of CMake modules
set (INSTALL_MODULES_DIR "${INSTALL_SHARE_DIR}/cmake")

# installation directory of utilities template files
set (INSTALL_CXX_TEMPLATES_DIR    "${INSTALL_SHARE_DIR}/utilities/cxx")
set (INSTALL_JAVA_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities/java")
set (INSTALL_PYTHON_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/utilities/python")
set (INSTALL_PERL_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities/perl")
set (INSTALL_BASH_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities/bash")
set (INSTALL_MATLAB_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/utilities/matlab")

# installation directory of project template files
set (INSTALL_TEMPLATE_DIR "${INSTALL_SHARE_DIR}/template")

# ============================================================================
# utilities
# ============================================================================

# configure all BASIS utilities such that they are included in API
# documentation even if BASIS does not use them itself
basis_set_project_property (PROJECT_USES_JAVA_UTILITIES   TRUE)
basis_set_project_property (PROJECT_USES_PYTHON_UTILITIES TRUE)
basis_set_project_property (PROJECT_USES_PERL_UTILITIES   TRUE)
basis_set_project_property (PROJECT_USES_BASH_UTILITIES   TRUE)
basis_set_project_property (PROJECT_USES_MATLAB_UTILITIES TRUE)

# target UIDs of BASIS libraries; these would be set by the package configuration
# file if this BASIS project would not be BASIS itself
if (BASIS_USE_FULLY_QUALIFIED_UIDS)
  set (BASIS_UTILITIES_LIBRARY "sbia.basis.utilities")
  set (BASIS_TEST_LIBRARY      "sbia.basis.testlib")
  set (BASIS_TEST_MAIN_LIBRARY "sbia.basis.testmain")
else ()
  set (BASIS_UTILITIES_LIBRARY "utilities")
  set (BASIS_TEST_LIBRARY      "testlib")
  set (BASIS_TEST_MAIN_LIBRARY "testmain")
endif ()
