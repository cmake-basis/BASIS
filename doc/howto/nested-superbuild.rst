.. meta::
    :description: Example of nested CMake superbuild script.

=================================
Nested Superbuild of Dependencies
=================================

The following CMake script is an example of how to implement a nested
superbuild of BASIS and other project dependencies. It is a (edited) copy
of the ``CMakeLists.txt`` file which implements the superbuild of the
`DRAMMS software package <http://www.rad.upenn.edu/sbia/software/dramms/download.html>`__.

.. code-block:: cmake
  :linenos:

  ##############################################################################
  # @file  CMakeLists.txt
  # @brief CMake configuration of bundle.
  #
  # Copyright (c) 2012 University of Pennsylvania. All rights reserved.
  # See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
  #
  # Contact: SBIA Group <sbia-software at uphs.upenn.edu>
  ##############################################################################
  
  cmake_minimum_required (VERSION 2.8.4)
  
  include (ExternalProject)
  include (CMakeParseArguments)
  
  project (DRAMMSBundle)
  
  # ============================================================================
  # bundled packages
  # ============================================================================
  
  if (NOT BUNDLE_SOURCE_DIR)
    set (BUNDLE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  endif ()
  
  # BASIS
  if (EXISTS "${BUNDLE_SOURCE_DIR}/basis-2.1.4-source.tar.gz")
    set (BASIS_URL "${BUNDLE_SOURCE_DIR}/basis-2.1.4-source.tar.gz")
  else ()
    set (BASIS_URL "INSERT DOWNLOAD URL OF PACKAGE HERE")
  endif ()
  set (BASIS_MD5 210be3765dde2c34f20d085ec293bed8)
  # NiftiCLib
  if (EXISTS "${BUNDLE_SOURCE_DIR}/nifticlib-2.0.0.tar.gz")
    set (NiftiCLib_URL "${BUNDLE_SOURCE_DIR}/nifticlib-2.0.0.tar.gz")
  else ()
    set (NiftiCLib_URL "INSERT DOWNLOAD URL OF PACKAGE HERE")
  endif ()
  set (NiftiCLib_MD5 ad9d7dd1ca7c10bf0592a8227c452354)
  # FastPD
  if (EXISTS "${BUNDLE_SOURCE_DIR}/FastPD_DemoVersion.zip")
    set (FastPD_URL "${BUNDLE_SOURCE_DIR}/FastPD_DemoVersion.zip")
  else ()
    set (FastPD_URL "INSERT DOWNLOAD URL OF PACKAGE HERE")
  endif ()
  set (FastPD_MD5 e8b7aa455bad254fe16434f1c601b66e)
  # DRAMMS
  if (NOT DRAMMS_SOURCE_DIR)
    set (DRAMMS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")
  endif ()
  
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
  
  include ("${DRAMMS_SOURCE_DIR}/BasisProject.cmake")
  
  # ============================================================================
  # global settings
  # ============================================================================
  
  if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    if (WIN32)
      get_filename_component (CMAKE_INSTALL_PREFIX "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion;ProgramFilesDir]" ABSOLUTE)
      if (NOT CMAKE_INSTALL_PREFIX OR CMAKE_INSTALL_PREFIX MATCHES "/registry")
        set (CMAKE_INSTALL_PREFIX "C:/Program Files")
      endif ()
      set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/SBIA/DRAMMS")
    else ()
      set (CMAKE_INSTALL_PREFIX "/opt/sbia/dramms")
    endif ()
    if (BUNDLE_VERSION AND NOT BUNDLE_VERSION MATCHES "^0(\\.0)?(\\.0)?$")
      set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}-${BUNDLE_VERSION}")
    endif ()
    set_property (CACHE CMAKE_INSTALL_PREFIX PROPERTY VALUE "${CMAKE_INSTALL_PREFIX}")
  endif ()
  
  option (BUILD_DOCUMENTATION     "Whether to configure and build the documentation."  OFF)
  option (TEST_BEFORE_INSTALL     "Whether to run the tests before installation."      OFF)
  option (USE_SYSTEM_NiftiCLib    "Skip build of NiftiCLib if already installed."      OFF)
  option (USE_SYSTEM_DRAMMSFastPD "Skip build of patched FastPD if already installed." OFF)
  
  if (NOT CMAKE_BUILD_TYPE)
    set_property (CACHE CMAKE_BUILD_TYPE PROPERTY VALUE "Release")
  endif ()
  
  set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
  
  if (NOT BUNDLE_PROJECTS)
    set (BUNDLE_PROJECTS) # tells BASIS which other packages belong to the same build
                          # each package which is build via ExternalProject_Add
                          # shall be added to this list and passed on to CMake
                          # for the configuration of any BASIS-based project
                          # using -DBUNDLE_PROJECTS:INTERNAL=<names>.
  endif ()
  
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
  
  # find BASIS or build it as external project
  if (DEFINED BASIS_DIR)
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
        URL_MD5          ${BASIS_MD5}
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
    endif ()
  endif ()
  
  # ============================================================================
  # 2. other bundle packages
  # ============================================================================
  
  # this is by defaul done even when BASIS was found such that the build of the
  # remaining packages is always the same even if it would not be necessary to
  # have the external "bundle" project. this switch is also used by the "bundle"
  # project to skip the addition of this external project. otherwise, it would
  # be an endless recursion...
  option (BUNDLE_EXTERNAL_PROJECTS "Whether to bundle all external projects even if already installed BASIS is used." ON)
  mark_as_advanced (BUNDLE_EXTERNAL_PROJECTS)
  
  if (BUNDLE_EXTERNAL_PROJECTS)
    # directory of the installed BASISConfig.cmake file
    if (BUNDLE_DEPENDS MATCHES "(^|;)BASIS(;|$)")
      if (BASIS_INSTALL_SCHEME MATCHES "win")
        set (BASIS_DIR "${CMAKE_INSTALL_PREFIX}/CMake/BASIS")
      else ()
        set (BASIS_DIR "${CMAKE_INSTALL_PREFIX}/lib/cmake/${BUNDLE_NAME_L}")
      endif ()
    endif ()
    # build all other packages as external project which itself just builds
    # the following external projects. this is necessary as BASIS has to be
    # build before the other external projects can be even configured.
    # in particular the Find<Pkg>.cmake modules coming with BASIS are required
    # to find any already installed packages
    ExternalProject_Add (
      bundle
      DEPENDS          ${BUNDLE_DEPENDS}
      DOWNLOAD_COMMAND "${CMAKE_COMMAND}" -E copy "${CMAKE_CURRENT_LIST_FILE}" CMakeLists.txt
      PREFIX           bundle
      DOWNLOAD_DIR     bundle
      SOURCE_DIR       bundle
      BINARY_DIR       bundle
      STAMP_DIR        bundle/tmp
      TMP_DIR          bundle/tmp
      CMAKE_CACHE_ARGS "-DBUNDLE_PROJECTS:STRING=${BUNDLE_PROJECTS}"
                       "-DBUILD_DOCUMENTATION:BOOL=${BUILD_DOCUMENTATION}"
                       "-DTEST_BEFORE_INSTALL:BOOL=${TEST_BEFORE_INSTALL}"
                       "-DUSE_SYSTEM_NiftiCLib:BOOL=${USE_SYSTEM_NiftiCLib}"
                       "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
                       "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}"
                       "-DBASIS_DIR:PATH=${BASIS_DIR}"
                       "-DBUNDLE_SOURCE_DIR:PATH=${BUNDLE_SOURCE_DIR}"
                       "-DDRAMMS_SOURCE_DIR:PATH=${DRAMMS_SOURCE_DIR}"
                       "-DBUNDLE_EXTERNAL_PROJECTS:INTERNAL=OFF"
      INSTALL_COMMAND  ""
    )
    # remove all bundle files on "make clean"
    set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/bundle")
    # do not continue... the external "bundle" project will do the rest
    return ()
  endif ()
  
  set_directory_properties (PROPERTY EP_PREFIX "${CMAKE_CURRENT_BINARY_DIR}")
  
  
  
  set (DRAMMS_DEPENDS) # external projects which DRAMMS depends on
                       # note that dependencies may already be installed
  
  # ----------------------------------------------------------------------------
  # NiftiCLib
  if (USE_SYSTEM_NiftiCLib)
    basis_find_package (NiftiCLib QUIET)
  endif ()
  
  if (NOT NiftiCLib_FOUND)
    ExternalProject_Add (
      NiftiCLib
      URL              "${NiftiCLib_URL}"
      URL_MD5          ${NiftiCLib_MD5}
      CMAKE_ARGS       -Wno-dev # suppress missing cmake_minimum_required() warning
      CMAKE_CACHE_ARGS "-DBUILD_SHARED_LIBS:BOOL=OFF"
                       "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
                       "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}"
    )
    set (NiftiCLib_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    list (APPEND BUNDLE_PROJECTS "NiftiCLib")
    list (APPEND DRAMMS_DEPENDS  "NiftiCLib")
  endif ()
  
  # ----------------------------------------------------------------------------
  # FastPD
  if (USE_SYSTEM_DRAMMSFastPD)
    basis_find_package (DRAMMSFastPD QUIET)
  endif ()
  
  if (NOT DRAMMSFastPD_FOUND)
    ExternalProject_Add (
      FastPD
      URL              "${FastPD_URL}"
      URL_MD5          ${FastPD_MD5}
      PATCH_COMMAND    patch -p1 < "${BUNDLE_SOURCE_DIR}/FastPD.patch"
      CMAKE_CACHE_ARGS "-DBUILD_SHARED_LIBS:BOOL=OFF"
                       "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
                       "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}"
    )
    set (DRAMMSFastPD_DIR "${CMAKE_CURRENT_BINARY_DIR}/lib")
    list (APPEND BUNDLE_PROJECTS "FastPD")
    list (APPEND DRAMMS_DEPENDS  "FastPD")
  endif ()
  
  # ----------------------------------------------------------------------------
  # DRAMMS
  ExternalProject_Add (
    DRAMMS
    DEPENDS             ${DRAMMS_DEPENDS}
    SOURCE_DIR          "${DRAMMS_SOURCE_DIR}"
    CMAKE_CACHE_ARGS    "-DBASIS_DIR:PATH=${BASIS_DIR}"
                        "-DNiftiCLib_DIR:PATH=${NiftiCLib_DIR}"
                        "-DDRAMMSFastPD_DIR:PATH=${DRAMMSFastPD_DIR}"
                        "-DBUNDLE_NAME:INTERNAL=${BUNDLE_NAME}"
                        "-DBUNDLE_PROJECTS:INTERNAL=${BUNDLE_PROJECTS}"
                        "-DBASIS_ALL_DOC:BOOL=${BUILD_DOCUMENTATION}"
                        "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
                        "-DBUILD_DOCUMENTATION:BOOL=${BUILD_DOCUMENTATION}"
                        "-DBUILD_TESTING:BOOL=${TEST_BEFORE_INSTALL}"
                        "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}"
    TEST_BEFORE_INSTALL ${TEST_BEFORE_INSTALL}
  )
