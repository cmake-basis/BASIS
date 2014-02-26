# ============================================================================
# Copyright (c) <copyright>
# All rights reserved.
#
# <license>
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Root build configuration file.
##############################################################################

# ----------------------------------------------------------------------------
# minimum required CMake version
cmake_minimum_required (VERSION 2.8.4)

# --------------------------------------------------------------------------
# project()
project ("<project>")

# ----------------------------------------------------------------------------
# include BASIS policies, settings, macros, and functions

# circumvent issue with CMake's find_package() interpreting these variables
# relative to the current binary directory instead of the top-level directory
if (BASIS_DIR AND NOT IS_ABSOLUTE "${BASIS_DIR}")
  set (BASIS_DIR "${CMAKE_BINARY_DIR}/${BASIS_DIR}")
  get_filename_component (BASIS_DIR "${BASIS_DIR}" ABSOLUTE)
endif ()
# moreover, users tend to specify the installation prefix instead of the
# actual directory containing the package configuration file
if (IS_DIRECTORY "${BASIS_DIR}")
  list (INSERT CMAKE_PREFIX_PATH 0 "${BASIS_DIR}")
endif ()
# if BASIS is not found, set CMAKE_INSTALL_PREFIX to invalid value if not
# set explicitly at the command-line such that BASIS will still initialize
# it to its defaults even though already cached
#find_package (BASIS QUIET)
if (BASIS_FOUND)

  # ----------------------------------------------------------------------------
  # configure build system
  basis_project_impl ()
else()

  include (ExternalProject)
  include (CMakeParseArguments)
  
  if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "" CACHE INTERNAL "Installation prefix." FORCE)
  endif ()
  message ("BASIS not found! Automatically downloading and installing BASIS v3.0.0")
  set(BASIS_URL "https://github.com/schuhschuh/cmake-basis/archive/v3.0.0.zip")

  # ============================================================================
  # meta-data
  # ============================================================================

  # ----------------------------------------------------------------------------
  # basis_project() macro to extract desired meta-data from BasisProject.cmake
  macro (basis_project)
    CMAKE_PARSE_ARGUMENTS (ARGN "" "NAME;VERSION" "" ${ARGN})
    set (BUNDLE_NAME    "${ARGN_NAME}")
    set (BUNDLE_VERSION "${ARGN_VERSION}")
    string (TOLOWER "${BUNDLE_NAME}" BUNDLE_NAME_L)
    string (TOUPPER "${BUNDLE_NAME}" BUNDLE_NAME_U)
    unset (ARGN_VERSION)
    unset (ARGN_UNPARSED_ARGUMENTS)
  endmacro ()

  include ("${CMAKE_CURRENT_SOURCE_DIR}/BasisProject.cmake")

  # ============================================================================
  # 1. BASIS
  # ============================================================================

  set (BUNDLE_DEPENDS) # either BASIS or nothing if BASIS already installed

  # circumvent issue with CMake's find_package() interpreting these variables
  # relative to the current binary directory instead of the top-level directory
  if (BASIS_DIR AND NOT IS_ABSOLUTE "${BASIS_DIR}")
    set (BASIS_DIR "${CMAKE_BINARY_DIR}/${BASIS_DIR}")
    get_filename_component (BASIS_DIR "${BASIS_DIR}" ABSOLUTE)
  endif ()
  # moreover, users tend to specify the installation prefix instead of the
  # actual directory containing the package configuration file
  if (IS_DIRECTORY "${BASIS_DIR}")
    list (INSERT CMAKE_PREFIX_PATH 0 "${BASIS_DIR}")
  endif ()

  message(STATUS "BASIS_DIR:${BASIS_DIR}")
  # find BASIS or build it as external project
  if (BASIS_DIR)
    find_package (BASIS REQUIRED)
  else ()
    option (USE_SYSTEM_BASIS "Skip build of BASIS if already installed." OFF)

    if (USE_SYSTEM_BASIS)
      find_package (BASIS QUIET)
    endif ()

    if (NOT BASIS_FOUND)
      set (BASIS_CMAKE_CACHE_ARGS)
      if (NOT BUILD_DOCUMENTATION)
        list (APPEND BASIS_CMAKE_CACHE_ARGS "-DUSE_Sphinx:BOOL=OFF")
      endif ()
      if (TEST_BEFORE_INSTALL)
        find_package (ITK REQUIRED) # the test driver of BASIS yet requires ITK
        list (APPEND BASIS_CMAKE_CACHE_ARGS "-DITK_DIR:PATH=${ITK_DIR}")
      else ()
        list (APPEND BASIS_CMAKE_CACHE_ARGS "-DUSE_ITK:BOOL=OFF")
      endif ()
      ExternalProject_Add (
        BASIS
        PREFIX           bundle
        URL              "${BASIS_URL}"
        CMAKE_CACHE_ARGS "-DBUNDLE_NAME:INTERNAL=${BUNDLE_NAME}"
                         "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
                         "-DBUILD_DOCUMENTATION:BOOL=OFF"
                         "-DBUILD_EXAMPLE:BOOL=OFF"
                         "-DBUILD_TESTING:BOOL=OFF"
                         "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}"
                         "-DBASIS_REGISTER:BOOL=OFF"
                         "-DBUILD_PROJECT_TOOL:BOOL=OFF"
                         "-DUSE_Bash:BOOL=ON"
                         "-DUSE_PythonInterp:BOOL=OFF"
                         "-DUSE_JythonInterp:BOOL=OFF"
                         "-DUSE_Perl:BOOL=OFF"
                         "-DUSE_MATLAB:BOOL=OFF"
                         ${BASIS_CMAKE_CACHE_ARGS}
      )
      list (APPEND BUNDLE_DEPENDS  BASIS)
      list (APPEND BUNDLE_PROJECTS BASIS)
    
      string(REPLACE ";" " " SUPER_BUILD_TARGET_DEPENDENCIES "${SUPER_BUILD_TARGET_DEPENDENCIES}")
      
      ExternalProject_Add(<project>
                          DEPENDS BASIS
                          SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
                          LIST_SEPARATOR "|"
                          CMAKE_ARGS 
                            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> 
                            -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} 
                            -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} 
                            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} 
                            ${${PACKAGE_NAME}_CMAKE_MODULE_PATH}
                            ${BASIS_SUPER_BUILD_ARGS}
                            -DBASIS_DIR=${CMAKE_INSTALL_PREFIX}
                          CMAKE_CHACHE_ARGS
                            -DCMAKE_PREFIX_PATH:STRING=${CMAKE_PREFIX_PATH_PIPE}
                          CMAKE_GENERATOR
                            ${CMAKE_GENERATOR}
                          CMAKE_TOOLSET
                            ${CMAKE_TOOLSET}
                          BINARY_DIR
                            ${CMAKE_BINARY_DIR}
                          INSTALL_DIR
                            ${CMAKE_INSTALL_PREFIX}
                          )
                        
  
      if(BASIS_ALWAYS_RECONFIGURE_SUPER_BUILD)
        ExternalProject_Add_Step(${PACKAGE_NAME} reconfigure
          COMMAND ${CMAKE_COMMAND} -E echo "Force configure of ${PACKAGE_NAME}"
          DEPENDEES update
          DEPENDERS configure
          ALWAYS 1)
      endif()
    endif ()
  endif ()
  
endif ()

