##############################################################################
# \file  CMakeLists.txt
# \brief Build configuration of software.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# CMake modules
# ============================================================================

# ----------------------------------------------------------------------------
# modules
set (
  CMAKE_MODULES
    "cmake/CMakeParseArguments.cmake"
    "cmake/BasisCommonTools.cmake"
    "cmake/BasisDocTools.cmake"
    "cmake/BasisMatlabTools.cmake"
    "cmake/BasisPack.cmake"
    "cmake/BasisProject.cmake"
    "cmake/BasisSettings.cmake"
    "cmake/BasisSubversionTools.cmake"
    "cmake/BasisTargetTools.cmake"
    "cmake/BasisTest.cmake"
    "cmake/BasisUpdate.cmake"
    "cmake/ExternalData.cmake"
    "cmake/ExternalData_config.cmake.in"
)

# ----------------------------------------------------------------------------
# auxiliary files
set (
  CMAKE_MODULES_AUXILIARY_FILES
    "cmake/ExecuteProcess.cmake"
    "cmake/ScriptConfig.cmake.in"
    "cmake/Config.cmake.in"
    "cmake/ConfigBuild.cmake"
    "cmake/ConfigInstall.cmake"
    "cmake/ConfigVersion.cmake.in"
    "cmake/Use.cmake.in"
    "cmake/GenerateConfig.cmake"
    "cmake/updatefile.py"
    "cmake/runmcc.m"
    "cmake/bash2cpp.pl"
    "cmake/matlab2cpp.pl"
    "cmake/Doxyfile.in"
    "cmake/config.h.in"
    "cmake/config.cc.in"
    "cmake/mainaux.h.in"
    "cmake/execname.cpp.in"
    "cmake/test_main.cc"
)

# ----------------------------------------------------------------------------
# Find<Pkg>.cmake modules
set (
  CMAKE_FIND_MODULES
    "cmake/FindGTest.cmake"
    "cmake/FindGMock.cmake"
    "cmake/FindNiftiCLib.cmake"
    "cmake/FindMatlabNiftiTools.cmake"
)

# ----------------------------------------------------------------------------
# install files
install (
  FILES       ${CMAKE_MODULES} ${CMAKE_FIND_MODULES} ${CMAKE_MODULES_AUXILIARY_FILES}
  DESTINATION "${INSTALL_MODULES_DIR}"
)

# ============================================================================
# CTest scripts
# ============================================================================

macro (add_ctest_script NAME)
  configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${NAME}.ctest.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake/${NAME}.ctest"
    @ONLY
  )

  install (
    FILES       "${CMAKE_CURRENT_BINARY_DIR}/cmake/${NAME}.ctest"
    DESTINATION "${INSTALL_MODULES_DIR}"
  )
endmacro ()

basis_add_script (
  nightly_ctest
  NOEXEC SCRIPT    "cmake/nightly.ctest"
  OUTPUT_DIRECTORY "cmake"
  DESTINATION      "${INSTALL_MODULES_DIR}"
)

# ============================================================================
# C++ utilities
# ============================================================================

# ----------------------------------------------------------------------------
# basic utilities
basis_add_library (
  basis_utils STATIC
    "utilities/path.cc" # utility path functions
)

# ----------------------------------------------------------------------------
# unit testing

# add include/sbia directory to include search path as the original Google
# Test and Google Mock sources include the headers via
# \code
# #include "gtest/gtest.h"
# \endcode
basis_include_directories ("${PROJECT_INCLUDE_DIR}/sbia") 

if (NOT HAVE_TR1_TUPLE)
  basis_add_definitions ("-DGTEST_USE_OWN_TR1_TUPLE=1")
endif ()

basis_add_library (basis_test STATIC "utilities/gmock-gtest-all.cc")

# ============================================================================
# tools
# ============================================================================

# ----------------------------------------------------------------------------
# project management tool
basis_add_script (tools/basisproject.sh)

# ----------------------------------------------------------------------------
# testing tools
basis_add_script (tools/basistest.sh)
basis_add_script (tools/basistest-sge.sh)
basis_add_script (tools/basistestd.sh)

