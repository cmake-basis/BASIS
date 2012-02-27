##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of CMake modules and utilities.
#
# Copyright (c) 2011-2012, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# modules
set (
  CMAKE_MODULES
    # main modules
    "BasisPack.cmake"               # packaging, wraps CPack
    "BasisTools.cmake"              # definition of macros and functions
    "BasisTest.cmake"               # testing, wraps CTest
    "BasisUpdate.cmake"             # automatic file update (deprecated)
    "BasisSettings.cmake"           # default project-independent settings
    # submodules included by BasisTools.cmake
    "CommonTools.cmake"             # common functions/macros
    "DocTools.cmake"                # documentation generation
    "ExportTools.cmake"             # exporting targets
    "ExternalData.cmake"            # storing data externally
    "ExternalData_config.cmake.in"  # config of ExternalData.cmake module
    "ImportTools.cmake"             # importing targets
    "InstallationTools.cmake"       # software installation
    "MatlabTools.cmake"             # MATLAB support
    "ProjectTools.cmake"            # main project/module helpers
    "RevisionTools.cmake"           # revision control system support
    "TargetTools.cmake"             # addition of build targets
    "TopologicalSort.cmake"         # topological sorting of build dependencies
    "UtilitiesTools.cmake"          # generation/configuration of utilities
)

# ----------------------------------------------------------------------------
# auxiliary files
set (
  CMAKE_MODULES_AUXILIARY_FILES
    # API documentation
    "Doxyfile.in"                 # default Doxygen configuration template
    "Modules.dox.in"              # documentation of BASIS modules groups
    "Utilities.dox"               # documentation of BASIS Utilities group
    "CxxUtilities.dox"            # documentation of C++ Utilities group
    "JavaUtilities.dox"           # documentation of Java Utilities group
    "PythonUtilities.dox"         # documentation of Python Utilities group
    "PerlUtilities.dox"           # documentation of Perl Utilities group
    "BashUtilities.dox"           # documentation of BASH Utilities group
    "MatlabUtilities.dox"         # documentation of MATLAB Utilities group
    # package configuration
    "Config.cmake.in"             # default <Pkg>Config.cmake template
    "BasisConfigSettings.cmake"   # settings for default <Pkg>Config.cmake
    "ConfigVersion.cmake.in"      # default <Pkg>ConfigVersion.cmake template
    "ConfigUse.cmake.in"          # default <Pkg>Use.cmake template
    "GenerateConfig.cmake"        # generation/configuration of <Pkg>Config.cmake et al.
    # other
    "buildtimestamp.cmd"          # get build timestamp on Windows
    "CheckPublicHeaders.cmake"    # check if header files were added/removed
    "cmake_uninstall.cmake.in"    # uninstall script
    "ConfigureIncludeFiles.cmake" # used to configure public header files
    "Directories.cmake.in"        # project directory structure
    "ExecuteProcess.cmake"        # wraps CMake's execute_process() function
    "runmcc.m"                    # helper used by MatlabTools.cmake module
    "ScriptConfig.cmake.in"       # default script configuration file
    "PostprocessChangeLog.cmake"  # used to postprocess generated ChangeLog
    "ProjectSettings.cmake.in"    # default project-dependent settings
    "updatefile.py"               # helper used by BasisUpdate.cmake module
    "doxygen_sbia.css"            # stylesheet for Doxygen documentation
    "doxygen_header.html"         # header of Doxygen documentation
    "doxygen_footer.html"         # footer of Doxygen documentation
    "logo_sbia.png"               # the logo of SBIA
    "logo_penn.gif"               # the logo of UPenn
)

# ----------------------------------------------------------------------------
# Find<Pkg>.cmake modules
set (
  CMAKE_FIND_MODULES
    "FindBASH.cmake"
    "FindBLAS.cmake"
    "FindBoostNumericBindings.cmake"
    "FindGMock.cmake"
    "FindGTest.cmake"
    "FindITK.cmake"
    "FindLIBLINEAR.cmake"
    "FindMATLAB.cmake"
    "FindMatlabNiftiTools.cmake"
    "FindMOSEK.cmake"
    "FindNiftiCLib.cmake"
    "FindPerlLibs.cmake"
)

# ----------------------------------------------------------------------------
# install files
basis_install (
  FILES       ${CMAKE_MODULES} ${CMAKE_FIND_MODULES} ${CMAKE_MODULES_AUXILIARY_FILES}
  DESTINATION "${INSTALL_MODULES_DIR}"
)

# Attention: DO NOT add the uninstall subdirectory here! Instead, the
#            CMakeLists.txt file is installed in a separate directory.
#            This directory is added to the build configuration of each
#            BASIS project (including BASIS) at the end of basis_project_impl().
basis_install (
  FILES       "uninstall/CMakeLists.txt"
  DESTINATION "${INSTALL_MODULES_DIR}/uninstall"
)

# ----------------------------------------------------------------------------
# make sure that we did not forget to install a file... very easy to forget!
file (GLOB MODULES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" *)

foreach (F IN LISTS MODULES)
  if (NOT F MATCHES "^(CMakeLists\\.txt|\\..*|.*\\.bak|.*~|uninstall)$")
    list (FIND CMAKE_MODULES "${F}" IDX)
    if (IDX EQUAL -1)
      list (FIND CMAKE_MODULES_AUXILIARY_FILES "${F}" IDX)
    endif ()
    if (IDX EQUAL -1)
      list (FIND CMAKE_FIND_MODULES "${F}" IDX)
    endif ()
    if (IDX EQUAL -1)
      message (WARNING "Seems like ${CMAKE_CURRENT_SOURCE_DIR}/${F} will not be installed!")
    endif ()
  endif ()
endforeach ()
