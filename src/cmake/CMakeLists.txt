##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of CMake modules and utilities.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# modules
set (
  CMAKE_MODULES
    "BasisPack.cmake"               # packaging, wraps CPack
    "BasisProject.cmake"            # main module
    "BasisTest.cmake"               # testing, wraps CTest
    "BasisUpdate.cmake"             # automatic file update (deprecated)
    "CommonTools.cmake"             # common functions/macros
    "DocTools.cmake"                # documentation generation
    "ExternalData.cmake"            # storing data externally
    "ExternalData_config.cmake.in"  # config of ExternalData.cmake module
    "InstallationTools.cmake"       # software installation
    "MatlabTools.cmake"             # MATLAB support
    "Settings.cmake"                # basic settings
    "SubversionTools.cmake"         # Subversion support
    "TargetTools.cmake"             # addition of build targets
    "UtilitiesTools.cmake"          # generation/configuration of utilities
)

# ----------------------------------------------------------------------------
# auxiliary files
set (
  CMAKE_MODULES_AUXILIARY_FILES
    "ExecuteProcess.cmake"    # wraps CMake's execute_process() function
    "ScriptConfig.cmake.in"   # default script configuration file
    "Config.cmake.in"         # default <Pkg>Config.cmake template
    "ConfigSettings.cmake"    # settings for default <Pkg>Config.cmake
    "ConfigVersion.cmake.in"  # default <Pkg>ConfigVersion.cmake template
    "Use.cmake.in"            # default <Pkg>Use.cmake template
    "GenerateConfig.cmake"    # generation/configuration of <Pkg>Config.cmake et al.
    "updatefile.py"           # helper used by BasisUpdate.cmake module
    "runmcc.m"                # helper used by MatlabTools.cmake module
    "Doxyfile.in"             # default Doxygen configuration template
    "SubversionUsers.txt"     # maps SVN users at SBIA to their real names
)

# ----------------------------------------------------------------------------
# Find<Pkg>.cmake modules
set (
  CMAKE_FIND_MODULES
    "FindGMock.cmake"             # for Google Mock
    "FindGTest.cmake"             # for Google Test
    "FindMATLAB.cmake"            # for MATLAB
    "FindMatlabNiftiTools.cmake"  # for MATLAB Central NIfTI tools
    "FindMOSEK.cmake"             # for MOSEK
    "FindNiftiCLib.cmake"         # for nifticlib
)

# ----------------------------------------------------------------------------
# install files
basis_install (
  FILES       ${CMAKE_MODULES} ${CMAKE_FIND_MODULES} ${CMAKE_MODULES_AUXILIARY_FILES}
  DESTINATION "${INSTALL_MODULES_DIR}"
)
