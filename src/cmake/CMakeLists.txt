##############################################################################
# \file  CMakeLists.txt
# \brief Configure and install CMake modules.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

set (
  MODULES
    CMakeParseArguments.cmake
    BasisCommonTools.cmake
    BasisDocTools.cmake
    BasisMatlabTools.cmake
    BasisPack.cmake
    BasisProject.cmake
    BasisSettings.cmake
    BasisSubversionTools.cmake
    BasisTargetTools.cmake
    BasisTest.cmake
    BasisUpdate.cmake
    ExternalData.cmake
    ExternalData_config.cmake.in
)

set (
  FIND_MODULES
    FindNiftiCLib.cmake
    FindMatlabNiftiTools.cmake
)

set (
  AUXILIARY_FILES
    ExecuteProcess.cmake
    ScriptConfig.cmake.in
    Config.cmake.in
    ConfigBuild.cmake
    ConfigInstall.cmake
    ConfigVersion.cmake.in
    Use.cmake.in
    GenerateConfig.cmake
    updatefile.py
    runmcc.m
    config.h.in
    mainaux.h.in
    execname.cpp.in
)

install (
  FILES       ${MODULES} ${FIND_MODULES} ${AUXILIARY_FILES}
  DESTINATION "${INSTALL_SHARE_DIR}/cmake"
)

