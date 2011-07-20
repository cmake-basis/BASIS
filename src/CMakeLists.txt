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
    "cmake/BasisPack.cmake"
    "cmake/BasisProject.cmake"
    "cmake/BasisTest.cmake"
    "cmake/BasisUpdate.cmake"
    "cmake/CMakeParseArguments.cmake"
    "cmake/CommonTools.cmake"
    "cmake/DocTools.cmake"
    "cmake/ExternalData.cmake"
    "cmake/ExternalData_config.cmake.in"
    "cmake/MatlabTools.cmake"
    "cmake/Settings.cmake"
    "cmake/SubversionTools.cmake"
    "cmake/TargetTools.cmake"
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
    "cmake/stdaux.h.in"
    "cmake/stdaux.cc.in"
    "cmake/test_main.cc"
)

# ----------------------------------------------------------------------------
# Find<Pkg>.cmake modules
set (
  CMAKE_FIND_MODULES
    "cmake/FindGTest.cmake"
    "cmake/FindGMock.cmake"
    "cmake/FindNiftiCLib.cmake"
    "cmake/FindMATLAB.cmake"
    "cmake/FindMatlabNiftiTools.cmake"
    "cmake/FindMOSEK.cmake"
)

# ----------------------------------------------------------------------------
# install files
install (
  FILES       ${CMAKE_MODULES} ${CMAKE_FIND_MODULES} ${CMAKE_MODULES_AUXILIARY_FILES}
  DESTINATION "${INSTALL_MODULES_DIR}"
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
basis_add_script (tools/basistest.ctest MODULE DESTINATION "${INSTALL_MODULES_DIR}")

basis_add_script (tools/basistest-svn.sh)
basis_add_script (tools/basistest-slave.sh)
basis_add_script (tools/basistest-master.sh)
basis_add_script (tools/basistest-cron.sh)

