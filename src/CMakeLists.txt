##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of software.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
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
    "cmake/CommonTools.cmake"
    "cmake/DocTools.cmake"
    "cmake/ExternalData.cmake"
    "cmake/ExternalData_config.cmake.in"
    "cmake/InstallationTools.cmake"
    "cmake/MatlabTools.cmake"
    "cmake/Settings.cmake"
    "cmake/SubversionTools.cmake"
    "cmake/TargetTools.cmake"
    "cmake/UtilitiesTools.cmake"
)

# ----------------------------------------------------------------------------
# auxiliary files
set (
  CMAKE_MODULES_AUXILIARY_FILES
    "cmake/ExecuteProcess.cmake"
    "cmake/ScriptConfig.cmake.in"
    "cmake/Config.cmake.in"
    "cmake/ConfigSettings.cmake"
    "cmake/ConfigVersion.cmake.in"
    "cmake/Use.cmake.in"
    "cmake/GenerateConfig.cmake"
    "cmake/updatefile.py"
    "cmake/runmcc.m"
    "cmake/Doxyfile.in"
    "cmake/doxygen-filter.pl"
    "cmake/doxygen-cmake-filter.py"
    "cmake/doxygen-bash-filter.py"
    "cmake/doxygen-matlab-filter.pl"
    "cmake/doxygen-python-filter.py"
    "cmake/doxygen-javascript-filter.pl"
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

install (
  DIRECTORY   "${CMAKE_CURRENT_SOURCE_DIR}/cmake/DoxyGen"
  DESTINATION "${INSTALL_MODULES_DIR}"
  PATTERN     ".svn" EXCLUDE
  PATTERN     ".git" EXCLUDE
  PATTERN     "*~"   EXCLUDE
)

# ============================================================================
# C++ utilities
# ============================================================================

# ----------------------------------------------------------------------------
# utilities template files
set (CPP_UTILITIES_FILES
  "utilities/config.h.in"
  "utilities/config.cc.in"
  "utilities/stdaux.h.in"
  "utilities/stdaux.cc.in"
  "utilities/test_main.cc"
)

install (FILES ${CPP_UTILITIES_FILES} DESTINATION "${INSTALL_UTILITIES_DIR}")

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

