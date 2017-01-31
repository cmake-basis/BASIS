# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of CMake BASIS Modules.
##############################################################################

if (NOT INSTALL_BASIS_MODULES_DIR)
  return ()
endif ()

# ----------------------------------------------------------------------------
# install files
set (CMAKE_FIND_MODULES
  "FindAFNI.cmake"
  "FindARPACK.cmake"
  "FindBASH.cmake"
  "FindBASIS.cmake"
  "FindBLAS.cmake"
  "FindBoostNumericBindings.cmake"
  "FindEigen3.cmake"
  "FindFLANN.cmake"
  "FindGMock.cmake"
  "FindITK.cmake"
  "FindJython.cmake"
  "FindJythonInterp.cmake"
  "FindLIBLINEAR.cmake"
  "FindMATLAB.cmake"
  "FindMatlabNiftiTools.cmake"
  "FindMIRTK.cmake"
  "FindMOSEK.cmake"
  "FindNiftiCLib.cmake"
  "FindPerl.cmake"
  "FindPerlLibs.cmake"
  "FindPython.cmake"
  "FindPythonInterp.cmake"
  "FindPythonModules.cmake"
  "FindSparseBayes.cmake"
  "FindSphinx.cmake"
  "FindSVMTorch.cmake"
  "FindTBB.cmake"
  "FindUMFPACK.cmake"
  "FindWeka.cmake"
)

basis_install (
  FILES        ${CMAKE_FIND_MODULES}
  DESTINATION "${INSTALL_BASIS_MODULES_DIR}"
)

# ----------------------------------------------------------------------------
# make sure that we did not forget to install a file... very easy to forget!
file (GLOB MODULES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" *)
foreach (F IN LISTS MODULES)
  if (NOT F MATCHES "^(COPYING\\.txt|README\\.md|CMakeLists\\.txt|\\..*|.*\\.bak|.*\\.autosave|.*~)$")
    list (FIND CMAKE_FIND_MODULES "${F}" IDX)
    if (IDX EQUAL -1)
      message (WARNING "Seems like ${CMAKE_CURRENT_SOURCE_DIR}/${F} will not be installed!")
    endif ()
  endif ()
endforeach ()
