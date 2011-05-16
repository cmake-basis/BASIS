##############################################################################
# \file  BasisTargetTools.cmake
# \brief Functions and macros to add executable and library targets.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

if (NOT BASIS_TARGETTOOLS_INCLUDED)
set (BASIS_TARGETTOOLS_INCLUDED 1)


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# required modules
# ============================================================================

include ("${CMAKE_CURRENT_LIST_DIR}/BasisSettings.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/BasisCommonTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/BasisMatlabTools.cmake")

# ============================================================================
# properties
# ============================================================================

# ****************************************************************************
# \brief Replaces CMake's set_target_properties () command.

function (basis_set_target_properties TARGET_NAME)
  set (UIDS)
  list (GET ARGN 0 ARG)
  while (ARG AND NOT ARG STREQUAL "PROPERTIES")
    basis_target_uid (UID "${ARG}")
    list (APPEND UIDS "${UID}")
    list (REMOVE_AT ARGN 0)
    list (GET ARGN 0 ARG)
  endwhile ()
  set_target_properties (${UIDS} ${ARGN})
endfunction ()

# ****************************************************************************
# \brief Replaces CMake's get_target_property () command.

function (basis_get_target_property VAR TARGET_NAME)
  basis_target_uid (TARGET_UID "${TARGET_NAME}")
  get_target_property (VALUE "${TARGET_UID}" ${ARGN})
  set (${VAR} "${VALUE}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# definitions
# ============================================================================

# ****************************************************************************
# \brief Replaces CMake's add_definitions () command.

function (basis_add_definitions)
  add_definitions (${ARGN})
endfunction ()

# ****************************************************************************
# \brief Replaces CMake's remove_definitions () command.

function (basis_remove_definitions)
  remove_definitions (${ARGN})
endfunction ()

# ============================================================================
# directories
# ============================================================================

# ****************************************************************************
# \brief Replaces CMake's include_directories () command.
#
# All arguments are passed on to CMake's include_directories () command.
# Additionally, the list of include directories is stored in the cached CMake
# variable BASIS_INCLUDE_DIRECTORIES. This variable can be used by custom
# commands for the build process, e.g., it is used as argument for the -I
# option of the MATLAB Compiler.
#
# Additionally, a list of all include directories added is cached. Hence,
# this list is extended even across subdirectories. Directories are always
# appended ignoring the BEFORE argument. The value of this internal cache
# variabel is cleared by basis_project ().
#
# \param ARGN Argument list passed on to CMake's include_directories command.

function (basis_include_directories)
  # CMake's include_directories ()
  include_directories (${ARGN})

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "AFTER;BEFORE;SYSTEM" "" "" ${ARGN})

  # current include directories
  if (BASIS_INCLUDE_DIRECTORIES)
    if (ARGN_BEFORE)
      set (
        BASIS_INCLUDE_DIRECTORIES
          "${ARGN_UNPARSED_ARGUMENTS};${BASIS_INCLUDE_DIRECTORIES}"
      )
    else ()
      set (
        BASIS_INCLUDE_DIRECTORIES
          "${BASIS_INCLUDE_DIRECTORIES};${ARGN_UNPARSED_ARGUMENTS}"
      )
    endif ()
  else ()
    set (BASIS_INCLUDE_DIRECTORIES "${ARGN_UNPARSED_ARGUMENTS}")
  endif ()

  if (BASIS_INCLUDE_DIRECTORIES)
    list (REMOVE_DUPLICATES BASIS_INCLUDE_DIRECTORIES)
  endif ()

  # cached include directories
  if (BASIS_CACHED_INCLUDE_DIRECTORIES)
    set (
      BASIS_CACHED_INCLUDE_DIRECTORIES
        "${BASIS_INCLUDE_DIRECTORIES};${ARGN_UNPARSED_ARGUMENTS}"
    )
  else ()
    set (BASIS_CACHED_INCLUDE_DIRECTORIES "${ARGN_UNPARSED_ARGUMENTS}")
  endif ()

  if (BASIS_CACHED_INCLUDE_DIRECTORIES)
    list (REMOVE_DUPLICATES BASIS_CACHED_INCLUDE_DIRECTORIES)
  endif ()

  set (
    BASIS_CACHED_INCLUDE_DIRECTORIES "${BASIS_CACHED_INCLUDE_DIRECTORIES}"
    CACHE INTERNAL "${BASIS_CACHED_INCLUDE_DIRECTORIES_DOC}" FORCE
  )
endfunction ()

# ****************************************************************************
# \brief Replaces CMake's link_directories () command.

function (basis_link_directories)
  link_directories (${ARGN})
endfunction ()



# ============================================================================
# dependencies
# ============================================================================

# ****************************************************************************
# \brief Replaces CMake's add_dependencies () command.

function (basis_add_dependencies)
  set (UIDS)
  foreach (ARG ${ARGN})
    basis_target_uid (UID "${ARG}")
    list (APPEND UIDS "${UID}")
  endforeach ()
  add_dependencies (${UIDS})
endfunction ()

# ****************************************************************************
# \brief Replaces CMake's target_link_libraries () command.
#
# The main reason for replacing this function is to treat libraries such as
# MEX-files which are supposed to be compiled into a MATLAB executable added
# by basis_add_executable () special. In this case, these libraries are added
# to the LINK_DEPENDS property of the given MATLAB Compiler target.
#
# Example:
# \code
# basis_add_library (MyMEXFunc MEX myfunc.c)
# basis_add_executable (MyMATLABApp main.m)
# basis_target_link_libraries (MyMATLABApp MyMEXFunc OtherMEXFunc.mexa64)
# \endcode
#
# \param [in] TARGET_NAME Name of the target.
# \param [in] ARGN        Link libraries.

function (basis_target_link_libraries TARGET_NAME)
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "basis_target_link_libraries (): Unknown target ${TARGET_UID}.")
  endif ()

  get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")

  # MATLAB Compiler target
  if (BASIS_TYPE MATCHES "^MCC_")
    get_target_property (DEPENDS ${TARGET_UID} "LINK_DEPENDS")

    if (NOT DEPENDS)
      set (DEPENDS)
    endif ()

    foreach (ARG ${ARGN})
      basis_target_uid (UID "${ARG}")
      if (TARGET "${UID}")
        list (APPEND DEPENDS ${UID})
      else ()
        list (APPEND DEPENDS "${ARG}")
      endif ()
    endforeach ()
 
    set_target_properties (${TARGET_UID} PROPERTIES LINK_DEPENDS ${DEPENDS})
  # other
  else ()
    target_link_libraries (${TARGET_UID} ${ARGN})
  endif ()
endfunction ()

# ============================================================================
# add targets
# ============================================================================

# ****************************************************************************
# \brief Replacement for CMake's add_executable () command.
#
# This function adds an executable target.
#
# An install command for the added executable target is added by this function
# as well. The executable will be installed as part of the component COMPONENT
# in the directory INSTALL_BIN_DIR.
#
# Besides adding usual executable targets build by the set C/CXX language
# compiler, this function inspects the list of source files given and detects
# whether this list contains sources which need to be build using a different
# compiler. In particular, it supports the following languages:
#
# CXX    - The default behavior, adding an executable target build from C/C++
#          source code. The target is added via CMake's add_executable () command.
# MATLAB - Standalone application build from MATLAB sources using the
#          MATLAB Compiler (mcc). This option is used when the list of source
#          files contains one or more *.m files. A custom target is added which
#          depends on custom command(s) that build the executable.
#
#          \attention The *.m file with the entry point / main function of the
#                     executable has to be given before any other *.m file.
#
# \param [in] TARGET_NAME Name of the executable target.
# \param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted, all other arguments are passed
#                         on to add_executable () or the respective custom commands
#                         used to build the executable.
#
#   COMPONENT Name of the component. Defaults to BASIS_DEFAULT_COMPONENT.
#   LANGUAGE  Source code language. By default determined from the extensions of
#             of the given source files, where CXX is assumed if no other
#             language is detected.

function (basis_add_executable TARGET_NAME)
  basis_check_target_name (${TARGET_NAME})
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  message (STATUS "Adding executable ${TARGET_UID}...")

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "COMPONENT;LANGUAGE" "" ${ARGN})

  # if no component is specified, use default
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_DEFAULT_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  # if the language is not explicitly selected, determine it from the
  # extensions of the source files
  if (NOT ARGN_LANGUAGE)
    foreach (ARG ${ARGN})
      if (ARG MATCHES "\\.m$")
        set (ARGN_LANGUAGE "MATLAB")
      endif ()
    endforeach ()
  endif ()

  # by default, consider source files as CXX language
  # (i.e., defaults to behavior of CMake's add_executable ())
  if (NOT ARGN_LANGUAGE)
    set (ARGN_LANGUAGE "CXX")
  endif ()

  # --------------------------------------------------------------------------
  # MATLAB Compiler
  # --------------------------------------------------------------------------

  if (ARGN_LANGUAGE STREQUAL "MATLAB")

    basis_add_mcc_target (
      ${TARGET_NAME}
      TYPE      "EXECUTABLE"
      COMPONENT "${ARGN_COMPONENT}"
      ${ARGN_UNPARSED_ARGUMENTS}
    )

  # --------------------------------------------------------------------------
  # other (just wrap add_executable () by default)
  # --------------------------------------------------------------------------

  else ()

    # add executable target
    add_executable (${TARGET_UID} ${ARGN_UNPARSED_ARGUMENTS})

    set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        BASIS_TYPE "EXECUTABLE"
    )

    # target version information
    set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        VERSION   ${PROJECT_VERSION}
        SOVERSION ${PROJECT_SOVERSION}
    )

    # install executable
    install (
      TARGETS     ${TARGET_UID}
      DESTINATION "${INSTALL_BIN_DIR}"
      COMPONENT   "${ARGN_COMPONENT}"
    )

    set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        RUNTIME_INSTALL_DIRECTORY "${INSTALL_BIN_DIR}"
    )

    # add target to list of targets
    set (
      BASIS_TARGETS "${BASIS_TARGETS};${TARGET_UID}"
      CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE
    )

  endif ()

  message (STATUS "Adding executable ${TARGET_UID}... - done")
endfunction ()

# ****************************************************************************
# \brief Replaces CMake's add_library () command.
#
# This function adds a library target.
#
# An install command for the added library target is added by this function
# as well. The runtime library will be installed as part of the component
# RUNTIME_COMPONENT in the directory INSTALL_BIN_DIR, the static/import library
# will be installed as part of the component DEVELOPMENT_COMPONENT in the
# directory INSTALL_LIB_DIR, while the corresponding public header files will
# be installed as part of the same component in the directory INSTALL_INCLUDE_DIR
# whereby the BASIS_INCLUDE_PREFIX is appended. By default, all header files
# are considered public. To declare certain header files private and hence
# exclude them from the installation, add them to the variable
# <TARGET_NAME>_PRIVATE_HEADER before calling this function. Note that the
# header file path must be exacly the same as the one passed to this function
# as part of ARGN!
#
# Example:
# \code
# set (
#   MYLIB_PRIVATE_HEADER
#     mylibprivate.h
#     utilities/utility.h
# )
#
# set (
#   MYLIB_SOURCE
#     mylib.c
#     mylibpublic.h
#     ${MYLIB_PRIVATE_HEADER}
# )
#
# basis_add_library (MyLib1 STATIC ${MYLIB_SOURCE})
# basis_add_library (MyLib2 STATIC ${MYLIB_SOURCE} COMPONENT dev)
# basis_add_library (MyLib3 STATIC ${MYLIB_SOURCE} RUNTIME_COMPONENT bin DEVELOPMENT_COMPONENT dev)
# \endcode
#
# \param [in] TARGET_NAME Name of the library target.
# \param [in] ARGN        Arguments passed to add_library () (excluding target name).
#                         This argument list is parsed and the following
#                         arguments are extracted, all other arguments are passed
#                         on to add_library ().
#
#   COMPONENT                Name of the component. Defaults to BASIS_DEFAULT_COMPONENT.
#   RUNTIME_COMPONENT        Name of runtime component. Defaults to COMPONENT.
#   DEVELOPMENT_COMPONENT    Name of development component. Defaults to COMPONENT.
#
#   STATIC|SHARED|MODULE|MEX Type of the library.
#   EXTERNAL                 Whether the library target is an external library, i.e.,
#                            the project version does not apply.

function (basis_add_library TARGET_NAME)
  basis_check_target_name (${TARGET_NAME})
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "STATIC;SHARED;MODULE;MEX;EXTERNAL"
      "COMPONENT;DEVELOPMENT_COMPONENT;RUNTIME_COMPONENT;LANGUAGE"
      ""
    ${ARGN}
  )

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_DEFAULT_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (NOT ARGN_DEVELOPMENT_COMPONENT)
    set (ARGN_DEVELOPMENT_COMPONENT "${ARGN_COMPONENT}")
  endif ()
  if (NOT ARGN_RUNTIME_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "${ARGN_COMPONENT}")
  endif ()

  # if the language is not explicitly selected, determine it from the
  # extensions of the source files
  if (NOT ARGN_LANGUAGE)
    foreach (ARG ${ARGN})
      if (ARG MATCHES "\\.m$")
        set (ARGN_LANGUAGE "MATLAB")
      endif ()
    endforeach ()
  endif ()

  # by default, consider source files as CXX language
  # (i.e., defaults to behavior of CMake's add_library ())
  if (NOT ARGN_LANGUAGE)
    set (ARGN_LANGUAGE "CXX")
  endif ()

  # status message including parsing of library type
  if (ARGN_LANGUAGE STREQUAL "MATLAB")
    message (STATUS "Adding MATLAB library ${TARGET_UID}...")
    if (NOT ARGN_SHARED OR ARGN_STATIC OR ARGN_MODULE OR ARGN_MEX)
      message (FATAL_ERROR "Invalid type for MATLAB library target ${TARGET_UID}. Only SHARED allowed.")
    endif ()
    set (ARGN_TYPE "SHARED")
  else ()
    if (NOT ARGN_SHARED AND NOT ARGN_STATIC AND NOT ARGN_MODULE AND NOT ARGN_MEX)
      if (BUILD_SHARED_LIBS)
        set (ARGN_SHARED 1)
      else ()
        set (ARGN_STATIC 0)
      endif ()
    endif ()

    if (ARGN_STATIC)
      message (STATUS "Adding static library ${TARGET_UID}...")
      if (ARGN_TYPE)
        message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
      endif ()
      set (ARGN_TYPE "STATIC")
    endif ()
    if (ARGN_SHARED)
      message (STATUS "Adding shared library ${TARGET_UID}...")
      if (ARGN_TYPE)
        message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
      endif ()
      set (ARGN_TYPE "SHARED")
    endif ()
    if (ARGN_MODULE)
      message (STATUS "Adding shared module ${TARGET_UID}...")
      if (ARGN_TYPE)
        message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
      endif ()
      set (ARGN_TYPE "MODULE")
    endif ()
    if (ARGN_MEX)
      message (STATUS "Adding MEX-file ${TARGET_UID}...")
      if (ARGN_TYPE)
        message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
      endif ()
      set (ARGN_TYPE "MEX")
    endif ()
  endif ()

  # --------------------------------------------------------------------------
  # MATLAB Compiler
  # --------------------------------------------------------------------------

  if (ARGN_LANGUAGE STREQUAL "MATLAB")

    basis_add_mcc_target (
      ${TARGET_NAME}
      TYPE      "LIBRARY"
      COMPONENT ${ARGN_COMPONENT}
      ${ARGN_UNPARSED_ARGUMENTS}
    )

  # --------------------------------------------------------------------------
  # C/C++
  # --------------------------------------------------------------------------

  else ()

    # public and private headers
    set (${TARGET_NAME}_PUBLIC_HEADER "")

    foreach (SOURCE_FILE ${ARGN})
      if (${SOURCE_FILE} MATCHES "\\.\(h|hpp|hxx|inl|txx\)$")
        list (APPEND ${TARGET_NAME}_PUBLIC_HEADER "${SOURCE_FILE}")
      endif ()
    endforeach ()

    foreach (PRIVATE_HEADER_FILE ${${TARGET_NAME}_PRIVATE_HEADER})
      list (REMOVE_ITEM ${TARGET_NAME}_PUBLIC_HEADER "${PRIVATE_HEADER_FILE}")
    endforeach ()

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MEX-file
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if (ARGN_TYPE STREQUAL "MEX")

      # MATLAB external library found ?
      if (NOT MATLAB_FOUND)
        message (FATAL_ERROR "MATLAB not found (or package not searched). It is required to build target ${TARGET_UID}."
                             "Set MATLAB_ROOT or MATLAB_INCLUDE_DIR and MATLAB_LIBRARIES manually and try again.")
      endif ()

      # determine extension of MEX-files for this architecture
      if (NOT MEX_EXT)
        basis_mexext (MEXEXT)
        set (MEX_EXT "${MEXEXT}" CACHE STRING "Extension of MEX-files." FORCE)
        mark_as_advanced (MEX_EXT)
      endif ()

      if (NOT MEX_EXT)
        message (FATAL_ERROR "Failed to determine extension of MEX-files. It is required to build target ${TARGET_UID}."
                             "Set BASIS_CMD_MEXEXT or MEX_EXT and try again.")
      endif ()

      # add library target
      add_library (${TARGET_UID} SHARED ${ARGN_UNPARSED_ARGUMENTS})

      set_target_properties (
        ${TARGET_UID}
        PROPERTIES
          BASIS_TYPE "MEX_FILE"
      )

      target_link_libraries (${TARGET_UID} ${MATLAB_LIBRARIES})

      # compiler flags and definitions specific to MEX-file build
      set (
        MEX_DEFINITIONS
          "_FILE_OFFSET_BITS=64"
          #"ARGCHECK"     # corresponds to MEX option -argcheck            ==> user may add via add_definitions ()
          #"MX_COMPAT_32" # corresponds to MEX option -compatibleArrayDims ==> user may add via add_definitions ()
          "MATLAB_MEX_FILE"
      )

      set (
        MEX_COMPILE_FLAGS
      )

      if (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_ISGNUCXX)
        list (APPEND MEX_DEFINITIONS "_GNU_SOURCE")
        list (APPEND MEX_COMPILE_FLAGS "-pthread -fexceptions -fno-omit-frame-pointer")
      endif ()

      set_target_properties (
        ${TARGET_UID}
        PROPERTIES
          PREFIX              ""
          SUFFIX              ".${MEX_EXT}"
          COMPILE_FLAGS       "${MEX_COMPILE_FLAGS}"
          COMPILE_DEFINITIONS "${MEX_DEFINITIONS}"
      )

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # other libraries
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    else ()

      add_library (${TARGET_UID} ${ARGN_TYPE} ${ARGN_UNPARSED_ARGUMENTS})

      set_target_properties (
        ${TARGET_UID}
        PROPERTIES
          BASIS_TYPE      "LIBRARY"
          PUBLIC_HEADER  ${${TARGET_NAME}_PUBLIC_HEADER}
          PRIVATE_HEADER ${${TARGET_NAME}_PRIVATE_HEADER}
      )

    endif ()

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # common
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # target version information
    if (NOT ARGN_EXTERNAL)
      set_target_properties (
        ${TARGET_NAME}
        PROPERTIES
          VERSION   "${PROJECT_VERSION}"
          SOVERSION "${PROJECT_SOVERSION}"
      )
    endif ()

    # install library
    install (
      TARGETS ${TARGET_UID}
      RUNTIME
        DESTINATION "${INSTALL_BIN_DIR}"
        COMPONENT   "${ARGN_RUNTIME_COMPONENT}"
      ARCHIVE
        DESTINATION "${INSTALL_LIB_DIR}"
        COMPONENT   "${ARGN_DEVELOPMENT_COMPONENT}"
      LIBRARY
        DESTINATION "${INSTALL_LIB_DIR}"
        COMPONENT   "${ARGN_DEVELOPMENT_COMPONENT}"
      PUBLIC_HEADER
        DESTINATION "${INSTALL_INCLUDE_DIR}/${BASIS_INCLUDE_PREFIX}"
        COMPONENT   "${ARGN_DEVELOPMENT_COMPONENT}"
    )

    # add target to list of targets
    set (
      BASIS_TARGETS "${BASIS_TARGETS};${TARGET_UID}"
      CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE
    )

  endif ()

  # done
  if (ARGN_LANGUAGE STREQUAL "MATLAB")
    message (STATUS "Adding MATLAB library ${TARGET_UID}... - done")
  else ()
    if (ARGN_STATIC)
      message (STATUS "Adding static library ${TARGET_UID}... - done")
    elseif (ARGN_SHARED)
      message (STATUS "Adding shared library ${TARGET_UID}... - done")
    elseif (ARGN_MODULE)
      message (STATUS "Adding shared module ${TARGET_UID}... - done")
    elseif (ARGN_MEX)
      message (STATUS "Adding MEX-file ${TARGET_UID}... - done")
    endif ()
  endif ()
endfunction ()

# ****************************************************************************
# \brief Add script target.
#
# This function adds a script "target" to the project, where the script is
# simply configured via configure_file () and copied to the directory
# specified by CMAKE_RUNTIME_OUTPUT_DIRECTORY or INSTALL_BIN_DIR, respectively.
# If the scripts' name ends in ".in", the ".in" suffix is removed from the
# output name. Further, all occurrences of ".in." anywhere within the script
# name are removed as well. The extension of the script such as .sh or .py is
# removed from the output filename if the project is build on UNIX systems
# and the script file contains a sha-bang directive, i.e., the first two
# characters on the first line are "#!" followed by the path to the script
# language interpreter.
#
# Example:
#
# \code
# basis_add_script (MyShellScript.sh.in)
# basis_add_script (AnotherShellScript.in.sh)
# basis_add_script (Script SCRIPT Script1.sh)
# \endcode
#
# Certain CMake variables within the script are replaced during the configure step.
# These variables and their values are given by a so-called script config(uration)
# file. The specified script configuration file is loaded during the build of the script
# prior to the configure_file () command. As paths may be different for scripts that
# are used directly from the build tree and scripts that are copied into the install tree,
# the variable BUILD_INSTALL_SCRIPT is 1 when the script is build for the install tree
# and 0 otherwise. This variable can be used within the script configuration file to
# set the value of the CMake variables used within the script differently for either
# case.
#
# Example:
# \code
# basis_add_script (Script1 SCRIPT Script1.sh CONFIG Script1Config.cmake)
# \endcode
#
# Script1Config.cmake
# \code
# if (BUILD_INSTALL_SCRIPT)
#   set (DATA_DIR "${INSTALL_DATA_DIR}")
# else ()
#   set (DATA_DIR "${PROJECT_DATA_DIR}")
# endif ()
# \endcode
#
# Note that this function only adds a custom target and stores all information
# required to setup the actual custom build command as properties of this target.
# The custom build command itself is added by basis_add_script_finalize (), which
# is supposed to be called once at the end of the root CMakeLists.txt file of the
# (super-)project. This way properties such as the OUTPUT_NAME can still be modified
# after adding the script target.
#
# \see basis_add_script_finalize ()
#
# \param [in] TARGET_NAME Name of the target. Alternatively, the script file
#                         path relative to the current source directory can be
#                         given here. In this case, the basename of the script
#                         file is used as target name and the SCRIPT option may
#                         not be used.
# \param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted:
#
#   SCRIPT    Script file paths relative to current source directory.
#   COMPONENT Name of the component. Defaults to BASIS_DEFAULT_COMPONENT.
#   CONFIG    Script configuration file. Defaults to the value of
#             BASIS_SCRIPT_CONFIG_FILE if defined. If no script configuration
#             file is specified or the specified file does not exist, the script
#             is copied only.

function (basis_add_script TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "SCRIPT;CONFIG;COMPONENT" "" ${ARGN})

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_DEFAULT_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()
  if (NOT ARGN_CONFIG)
    set (ARGN_CONFIG "${BASIS_SCRIPT_CONFIG_FILE}")
  endif ()

  if (ARGN_CONFIG STREQUAL "NONE" OR ARGN_CONFIG STREQUAL "none" OR ARGN_CONFIG STREQUAL "None")
    set (ARGN_CONFIG)
  endif ()

  if (ARGN_UNPARSED_ARGUMENTS)
    message ("Unknown arguments given for basis_add_script (${TARGET_NAME}): ${ARGN_UNPARSED_ARGUMENTS}")
  endif ()

  if (NOT ARGN_SCRIPT)
    set (ARGN_SCRIPT "${TARGET_NAME}")
 
    # remove ".in" from target name
    string (REGEX REPLACE "\\.in$"          ""    TARGET_NAME "${TARGET_NAME}")
    string (REGEX REPLACE "\\.in\(\\..*\)$" "\\1" TARGET_NAME "${TARGET_NAME}")

    # use file basename as target name
    get_filename_component (TARGET_NAME "${TARGET_NAME}" NAME_WE)
  endif ()

  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  message (STATUS "Adding script ${TARGET_UID}...")

  # make script file path absolute
  if (NOT IS_ABSOLUTE "${ARGN_SCRIPT}")
    set (ARGN_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/${ARGN_SCRIPT}")
  endif ()

  if (NOT EXISTS "${ARGN_SCRIPT}")
    message (FATAL_ERROR "Missing script ${ARGN_SCRIPT}!")
  endif ()

  # target output name
  get_filename_component (OUTPUT_NAME "${ARGN_SCRIPT}" NAME)

  # remove ".in" from output name
  string (REGEX REPLACE "\\.in$"          ""    OUTPUT_NAME "${OUTPUT_NAME}")
  string (REGEX REPLACE "\\.in\(\\..*\)$" "\\1" OUTPUT_NAME "${OUTPUT_NAME}")

  # remove extension from script name (if UNIX system and sha-bang directive exists)
  if (UNIX)
    file (STRINGS "${ARGN_SCRIPT}" SHABANG LIMIT_COUNT 2 LIMIT_INPUT 2)
    if (SHABANG STREQUAL "#!")
      get_filename_component (OUTPUT_NAME "${OUTPUT_NAME}" NAME_WE)
    endif ()
  endif ()

  # script configuration
  set (SCRIPT_CONFIG)

  if (ARGN_CONFIG)
    if (NOT EXISTS "${ARGN_CONFIG}")
      message (FATAL_ERROR "Script configuration file \"${ARGN_CONFIG}\" does not exist. It is required to build the script ${TARGET_UID}.")
    endif ()
    file (READ "${ARGN_CONFIG}" SCRIPT_CONFIG)
    string (CONFIGURE "${SCRIPT_CONFIG}" SCRIPT_CONFIG @ONLY)
  endif ()

  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${ARGN_SCRIPT})

  # set target properties required by basis_add_script_finalize ()
  set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      TYPE                      "EXECUTABLE"
      BASIS_TYPE                "SCRIPT"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${CMAKE_CURRENT_BINARY_DIR}"
      RUNTIME_OUTPUT_DIRECTORY  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
      RUNTIME_INSTALL_DIRECTORY "${INSTALL_BIN_DIR}"
      COMPILE_DEFINITIONS       "${SCRIPT_CONFIG}"
      COMPONENT                 "${ARGN_COMPONENT}"
  )

  # add target to list of targets
  set (
    BASIS_TARGETS "${BASIS_TARGETS};${TARGET_UID}"
    CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE
  )

  message (STATUS "Adding script ${TARGET_UID}... - done")
endfunction ()

# ****************************************************************************
# \brief Finalizes addition of script.
#
# This function uses the properties of the custom script target added by
# basis_add_script () to create the custom build command and adds this build
# command as dependency of this added target.
#
# \see basis_add_script ()
#
# \param [in] TARGET_UID "Global" target name. If this function is used
#                        within the same project as basis_add_script (),
#                        the "local" target name may be given alternatively.

function (basis_add_script_finalize TARGET_UID)
  # if used within (sub-)project itself, allow user to specify "local" target name
  basis_target_uid (TARGET_UID "${TARGET_UID}")

  # already finalized before ?
  if (TARGET "${TARGET_UID}+")
    return ()
  endif ()

  # does this target exist ?
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown target ${TARGET_UID}.")
    return ()
  endif ()

  message (STATUS "Adding build command for script ${TARGET_UID}...")

  # get target properties
  basis_target_name (TARGET_NAME ${TARGET_UID})

  set (
    PROPERTIES
      "BASIS_TYPE"
      "SOURCE_DIRECTORY"
      "BINARY_DIRECTORY"
      "RUNTIME_OUTPUT_DIRECTORY"
      "RUNTIME_INSTALL_DIRECTORY"
      "PREFIX"
      "OUTPUT_NAME"
      "SUFFIX"
      "VERSION"
      "SOVERSION"
      "SOURCES"
      "COMPILE_DEFINITIONS"
      "COMPONENT"
  )

  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()

  # check target type
  if (NOT BASIS_TYPE STREQUAL "SCRIPT")
    message (FATAL_ERROR "Target ${TARGET_UID} is no BASIS script target. Invalid type: ${BASIS_TYPE}")
  endif ()

  # build directory (note that CMake returns basename of build directory as first element of SOURCES list)
  list (GET SOURCES 0 BUILD_DIR)
  set (BUILD_DIR "${BUILD_DIR}.dir")

  # extract script file from SOURCES
  list (GET SOURCES 1 SCRIPT_FILE)

  # output name
  if (NOT OUTPUT_NAME)
    set (OUTPUT_NAME "${TARGET_NAME}")
  endif ()
  if (PREFIX)
    set (OUTPUT_NAME "${PREFIX}${OUTPUT_NAME}")
  endif ()
  if (SUFFIX)
    set (OUTPUT_NAME "${OUTPUT_NAME}${SUFFIX}")
  endif ()

  # create build script
  set (BUILD_DIR    "${BINARY_DIRECTORY}/CMakeFiles/${TARGET_UID}.dir")
  set (BUILD_SCRIPT "${BUILD_DIR}/build.cmake")
  set (OUTPUT_FILE  "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_NAME}")
  set (INSTALL_FILE "${SCRIPT_FILE}")
  set (OUTPUT_FILES "${OUTPUT_FILE}")

  set (BUILD_COMMANDS "# DO NOT edit. This file is automatically generated by BASIS.\n\n")

  if (COMPILE_DEFINITIONS)
    basis_set_script_path_definition (FUNCTIONS)
    string (CONFIGURE "${FUNCTIONS}" FUNCTIONS @ONLY)

    set (INSTALL_FILE "${BUILD_DIR}/${OUTPUT_NAME}")
    set (OUTPUT_FILES "${OUTPUT_FILE};${INSTALL_FILE}")

    string (REPLACE "\r" "" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")

    set (BUILD_COMMANDS "${BUILD_COMMANDS}${FUNCTIONS}\n\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}set (BUILD_INSTALL_SCRIPT 0)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}set (SCRIPT_DIR \"${RUNTIME_OUTPUT_DIRECTORY}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}${COMPILE_DEFINITIONS}\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}configure_file (\"${SCRIPT_FILE}\" \"${OUTPUT_FILE}\" @ONLY)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}\nif (UNIX)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}  execute_process (COMMAND chmod +x \"${OUTPUT_FILE}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}endif ()\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}\nset (BUILD_INSTALL_SCRIPT 1)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}set (SCRIPT_DIR \"${INSTALL_PREFIX}/${RUNTIME_INSTALL_DIRECTORY}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}${COMPILE_DEFINITIONS}\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}configure_file (\"${SCRIPT_FILE}\" \"${INSTALL_FILE}\" @ONLY)\n")
  else ()
    set (BUILD_COMMANDS "${BUILD_COMMANDS}configure_file (\"${SCRIPT_FILE}\" \"${OUTPUT_FILE}\" COPYONLY)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}\nif (UNIX)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}  execute_process (COMMAND chmod +x \"${OUTPUT_FILE}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}endif ()\n")
  endif ()

  # write build script only if it differs from previous build script
  #
  # \note Adding BUILD_SCRIPT to the dependencies of the custom command
  #       caused the custom command to be executed every time even when the
  #       BUILD_SCRIPT file was not modified. Therefore, use dummy output
  #       file which is deleted when the script differs from the previous one.
  #
  # \todo There must be a better solution to this problem.
  file (WRITE "${BUILD_SCRIPT}" "${BUILD_COMMANDS}")

  file (WRITE "${BUILD_SCRIPT}.check" "# DO NOT edit. Automatically generated by BASIS.
execute_process (
  COMMAND \"${CMAKE_COMMAND}\" -E compare_files \"${BUILD_SCRIPT}\" \"${BUILD_SCRIPT}.copy\"
  RESULT_VARIABLE BUILD_SCRIPT_CHANGED
  OUTPUT_QUIET
  ERROR_QUIET
)

if (BUILD_SCRIPT_CHANGED)
  file (REMOVE \"${BUILD_SCRIPT}.copy\")
endif ()"
  )

  # add custom target
  file (RELATIVE_PATH REL "${CMAKE_BINARY_DIR}" "${OUTPUT_FILE}")

  add_custom_command (
    OUTPUT  ${OUTPUT_FILES} "${BUILD_SCRIPT}.copy"
    DEPENDS "${SCRIPT_FILE}"
    COMMAND "${CMAKE_COMMAND}" -P "${BUILD_SCRIPT}"
    COMMAND "${CMAKE_COMMAND}" -E copy "${BUILD_SCRIPT}" "${BUILD_SCRIPT}.copy"
    COMMENT "Building script ${REL}..."
  )

  add_custom_target (
    ${TARGET_UID}-
    COMMAND "${CMAKE_COMMAND}" -P "${BUILD_SCRIPT}.check"
  )

  add_custom_target (
    ${TARGET_UID}+
    DEPENDS ${OUTPUT_FILES}
  )

  add_dependencies (${TARGET_UID}+ ${TARGET_UID}-)
  add_dependencies (${TARGET_UID}  ${TARGET_UID}+)

  # cleanup on "make clean"
  set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${OUTPUT_FILES})

  # install script
  install (
    PROGRAMS    "${INSTALL_FILE}"
    RENAME      "${OUTPUT_NAME}"
    DESTINATION "${RUNTIME_INSTALL_DIRECTORY}"
    COMPONENT   "${COMPONENT}"
  )

  message (STATUS "Adding build command for script ${TARGET_UID}... - done")
endfunction ()

# ****************************************************************************
# \brief Adds scripts with specified extension.
#
# This function calls basis_add_script () for each script within the current
# source directory which has the extension ".EXT" or ".EXT.in".
#
# \param [in] EXT  Script extension, e.g., "sh" for shell scripts.
# \param [in] ARGN This argument list is parsed and the following
#                  arguments are extracted:
#
#   COMPONENT Name of the component. Defaults to BASIS_DEFAULT_COMPONENT.

function (basis_add_scripts_by_extension EXT)
  if (BASIS_VERBOSE)
    file (RELATIVE_PATH DIR "${PROJECT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
    message (STATUS "Adding scripts in ${DIR} with extension .${EXT} or .${EXT}.in")
    set (DIR)
  endif ()

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "COMPONENT" "" ${ARGN})

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_DEFAULT_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (ARGN_UNPARSED_ARGUMENTS)
    message ("Unknown arguments given for basis_add_scripts_by_extension (${EXT}): ${ARGN_UNPARSED_ARGUMENTS}")
  endif ()

  # glob script files with given extension
  file (GLOB FILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*")

  # add scripts
  foreach (SCRIPT ${FILES})
    if (NOT IS_DIRECTORY "${SCRIPT}")
      if ("${SCRIPT}" MATCHES ".*\\.${EXT}$|.*\\.${EXT}\\.in$")
        basis_add_script ("${SCRIPT}" COMPONENT "${ARGN_COMPONENT}")
      endif ()
    endif ()
  endforeach ()
endfunction ()

# ****************************************************************************
# \brief Adds scripts with specified extensions.
#
# \see basis_add_scripts_by_extension
#
# \param [in] ARGN This argument list is parsed and the following arguments
#                  are extracted. All other arguments are considered script
#                  extension.
#
#   COMPONENT Name of the component.

macro (basis_add_scripts_by_extensions)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "COMPONENT" "" ${ARGN})

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_DEFAULT_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  # add scripts by extension
  foreach (EXT ${ARGN_UNPARSED_ARGUMENTS})
    basis_add_scripts_by_extension ("${EXT}" COMPONENT "${ARGN_COMPONENT}")
  endforeach ()
endmacro ()

# ****************************************************************************
# \brief Adds scripts with default extensions.
#
# This macro adds each script within the current source directory which has
# a default extension using basis_add_script ().
#
# Considered default extensions are "sh" for shell scripts, "py" for Python
# scripts, and "pl" for Perl scripts.
#
# \param [in] ARGN This argument list is parsed and the following arguments
#                  are extracted.
#
#   COMPONENT Name of the component.

macro (basis_add_scripts)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "COMPONENT" "" ${ARGN})

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_DEFAULT_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (ARGN_UNPARSED_ARGUMENTS)
    message ("Unknown arguments given for basis_add_scripts (): '${ARGN_UNPARSED_ARGUMENTS}'")
  endif ()

  # add scripts with known extensions
  basis_add_scripts_by_extension (sh COMPONENT "${ARGN_COMPONENT}") # shell scripts
  basis_add_scripts_by_extension (py COMPONENT "${ARGN_COMPONENT}") # python scripts
  basis_add_scripts_by_extension (pl COMPONENT "${ARGN_COMPONENT}") # Perl scripts
endmacro ()

# ****************************************************************************
# \brief Fianlizes addition of custom BASIS targets.
#
# \see basis_add_script_finalize ()
# \see basis_add_mcc_target_finalize ()

function (basis_add_custom_finalize)
  foreach (TARGET_UID ${BASIS_TARGETS})
    get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")
    if (BASIS_TYPE STREQUAL "SCRIPT")
      basis_add_script_finalize (${TARGET_UID})
    elseif (BASIS_TYPE MATCHES "^MCC_")
      basis_add_mcc_target_finalize (${TARGET_UID})
    endif ()
  endforeach ()
endfunction ()

# ****************************************************************************
# \brief Add uninstall target.
#
# Unix version works with any SUS-compliant operating system, as it needs
# only Bourne Shell features Win32 version works with any Windows which
# supports extended cmd.exe syntax (Windows NT 4.0 and newer, maybe Windows
# NT 3.x too).
#
# \author Pau Garcia i Quiles, modified by the SBIA Group
# \see    http://www.cmake.org/pipermail/cmake/2007-May/014221.html

function (basis_add_uninstall)
  if (WIN32)
    add_custom_target (
      uninstall
        \"FOR /F \"tokens=1* delims= \" %%f IN \(${CMAKE_BINARY_DIR}/install_manifest.txt"}\)\" DO \(
            IF EXIST %%f \(
              del /q /f %%f"
            \) ELSE \(
               echo Problem when removing %%f - Probable causes: File already removed or not enough permissions
             \)
         \)
      VERBATIM
    )
  else ()
    # Unix
    add_custom_target (
      uninstall
        cat "${CMAKE_BINARY_DIR}/install_manifest.txt"
          | while read f \; do if [ -e \"\$\${f}\" ]; then rm \"\$\${f}\" \; else echo \"Problem when removing \"\$\${f}\" - Probable causes: File already removed or not enough permissions\" \; fi\; done
      COMMENT Uninstalling...
    )
  endif ()
endfunction ()

# ============================================================================
# helpers
# ============================================================================

# ****************************************************************************
# \brief Generates the definition of the basis_set_script_path () function.
#
# This macro generates the definition of the basis_set_script_path ()
# function, the definition of which is evaluated during the build step of
# scripts before the inclusion of the script configuration. Hence,
# basis_set_script_path () can be used in script configuration files. This
# function takes a variable name and a path as input arguments. If the given
# path is relative, it makes it first absolute using PROJECT_SOURCE_DIR. Then
# the path is made relative to the directory of the built script file. A CMake
# variable of the given name is set to the specified relative path. Optionally,
# a third argument, the path used for building the script for the install tree
# can be passed as well. If a relative path is given as this argument, it is
# made absolute by prefixing it with INSTALL_PREFIX instead.
#
# \param [out] FUNC The generated basis_set_script_path () function definition.
#
#   VAR  Name of the variable.
#   PATH Path to directory or file.
#   ARG3 Path to directory or file inside install tree.
#        If this argument is not given, PATH is used for both
#        the build and install tree version of the script.

macro (basis_set_script_path_definition FUNC)
  set (${FUNC} "function (basis_set_script_path VAR PATH)
  if (ARGC GREATER 3)
    message (FATAL_ERROR \"Too many arguments given for function basis_set_script_path ()\")
  endif ()

  if (ARGC EQUAL 3 AND BUILD_INSTALL_SCRIPT)
    set (PREFIX \"@INSTALL_PREFIX@\")
    set (PATH   \"\${ARGV2}\")
  else ()
    set (PREFIX \"@PROJECT_SOURCE_DIR@\")
  endif ()

  if (NOT IS_ABSOLUTE \"\${PATH}\")
    set (PATH \"\${PREFIX}/\${PATH}\")
  endif ()

  file (RELATIVE_PATH PATH \"\${SCRIPT_DIR}\" \"\${PATH}\")

  if (NOT PATH)
    set (PATH \".\")
  endif ()

  set (\${VAR} \"\${PATH}\" PARENT_SCOPE)
endfunction ()")
endmacro ()


endif (NOT BASIS_TARGETTOOLS_INCLUDED)

