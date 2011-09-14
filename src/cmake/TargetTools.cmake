##############################################################################
# @file  TargetTools.cmake
# @brief Functions and macros to add executable and library targets.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_TARGETTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_TARGETTOOLS_INCLUDED TRUE)
endif ()


## @addtogroup CMakeAPI
#  @{

# ============================================================================
# properties
# ============================================================================

##############################################################################
# @brief Replaces CMake's set_target_properties() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties
#
# @param [in] ARGN Arguments for set_target_properties().
#
# @returns Sets the specified properties of the given build target.

function (basis_set_target_properties)
  set (UIDS)
  list (GET ARGN 0 ARG)
  while (ARG AND NOT ARG STREQUAL "PROPERTIES")
    basis_target_uid (UID "${ARG}")
    list (APPEND UIDS "${UID}")
    list (REMOVE_AT ARGN 0)
    list (GET ARGN 0 ARG)
  endwhile ()
  if (NOT UIDS)
    message (FATAL_ERROR "basis_set_target_properties (): No targets specified")
  endif ()
  set_target_properties (${UIDS} ${ARGN})
endfunction ()

##############################################################################
# @brief Replaces CMake's get_target_property() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_target_property
#
# @param [out] VAR         Name of output variable.
# @param [in]  TARGET_NAME Name of build target.
# @param [in]  ARGN        Remaining arguments for get_target_property().
#
# @returns Sets @p VAR to the value of the requested property.

function (basis_get_target_property VAR TARGET_NAME)
  basis_target_uid (TARGET_UID "${TARGET_NAME}")
  get_target_property (VALUE "${TARGET_UID}" ${ARGN})
  set (${VAR} "${VALUE}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# definitions
# ============================================================================

##############################################################################
# @brief Replaces CMake's add_definitions() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_definitions
#
# @param [in] ARGN Arguments for add_definition().
#
# @returns Adds the given definitions.

function (basis_add_definitions)
  add_definitions (${ARGN})
endfunction ()

##############################################################################
# @brief Replaces CMake's remove_definitions() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:remove_definition
#
# @param [in] ARGN Arguments for remove_definitions().
#
# @returns Removes the specified definitions.

function (basis_remove_definitions)
  remove_definitions (${ARGN})
endfunction ()

# ============================================================================
# directories
# ============================================================================

##############################################################################
# @brief Replaces CMake's include_directories() command.
#
# All arguments are passed on to CMake's include_directories() command.
# Additionally, the list of include directories is stored in the cached CMake
# variable BASIS_INCLUDE_DIRECTORIES. This variable can be used by custom
# commands for the build process, e.g., it is used as argument for the -I
# option of the MATLAB Compiler.
#
# Additionally, a list of all include directories added is cached. Hence,
# this list is extended even across subdirectories. Directories are always
# appended ignoring the BEFORE argument. The value of this internal cache
# variabel is cleared by basis_project_initialize().
#
# @param ARGN Argument list passed on to CMake's include_directories command.
#
# @returns Adds the given paths to the list of include search paths and
#          to the variables @c BASIS_INCLUDE_DIRECTORIES and
#          @c BASIS_CACHED_INCLUDE_DIRECTORIES.

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

  set (BASIS_INCLUDE_DIRECTORIES "${BASIS_INCLUDE_DIRECTORIES}" PARENT_SCOPE)

  # cached include directories
  if (BASIS_CACHED_INCLUDE_DIRECTORIES)
    set (
      BASIS_CACHED_INCLUDE_DIRECTORIES
        "${BASIS_CACHED_INCLUDE_DIRECTORIES};${ARGN_UNPARSED_ARGUMENTS}"
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

##############################################################################
# @brief Replaces CMake's link_directories() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories
#
# @param [in] ARGN Arguments for link_directories().
#
# @returns Adds the given paths to the search path for link libraries and
#          to the variable @c BASIS_LINK_DIRECTORIES.

function (basis_link_directories)
  # CMake's link_directories()
  link_directories (${ARGN})

  # current link directories
  if (BASIS_LINK_DIRECTORIES)
    set (
      BASIS_LINK_DIRECTORIES
        "${BASIS_LINK_DIRECTORIES};${ARGN}"
    )
  else ()
    set (BASIS_LINK_DIRECTORIES "${ARGN}")
  endif ()

  if (BASIS_LINK_DIRECTORIES)
    list (REMOVE_DUPLICATES BASIS_LINK_DIRECTORIES)
  endif ()

  set (BASIS_LINK_DIRECTORIES "${BASIS_LINK_DIRECTORIES}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# dependencies
# ============================================================================

##############################################################################
# @brief Replaces CMake's add_dependencies() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_dependencies
#
# @param [in] ARGN Arguments for add_dependencies().
#
# @returns Adds the given dependencies of the specified build target.

function (basis_add_dependencies)
  set (ARGS)
  foreach (ARG ${ARGN})
    basis_target_uid (UID "${ARG}")
    if (TARGET "${UID}")
      list (APPEND ARGS "${UID}")
    else ()
      list (APPEND ARGS "${ARG}")
    endif ()
  endforeach ()
  add_dependencies (${ARGS})
endfunction ()

##############################################################################
# @brief Replaces CMake's target_link_libraries() command.
#
# The main reason for replacing this function is to treat libraries such as
# MEX-files which are supposed to be compiled into a MATLAB executable added
# by basis_add_executable() special. In this case, these libraries are added
# to the LINK_DEPENDS property of the given MATLAB Compiler target.
#
# Another reason is the mapping of build target names to fully-qualified
# build target names as used by BASIS (see basis_target_uid()).
#
# Example:
# @code
# basis_add_library (MyMEXFunc MEX myfunc.c)
# basis_add_executable (MyMATLABApp main.m)
# basis_target_link_libraries (MyMATLABApp MyMEXFunc OtherMEXFunc.mexa64)
# @endcode
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:target_link_libraries
#
# @param [in] TARGET_NAME Name of the target.
# @param [in] ARGN        Link libraries.
#
# @returns Adds link dependencies to the specified build target.
#          For custom targets, the given libraries are added to the
#          @c DEPENDS property of these target, in particular.

function (basis_target_link_libraries TARGET_NAME)
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "basis_target_link_libraries (): Unknown target ${TARGET_UID}.")
  endif ()

  # get type of named target
  get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")

  # substitute non-fully qualified target names
  set (ARGS)
  foreach (ARG ${ARGN})
    basis_target_uid (UID "${ARG}")
    if (TARGET "${UID}")
      list (APPEND ARGS "${UID}")
    else ()
      list (APPEND ARGS "${ARG}")
    endif ()
  endforeach ()

  # MATLAB Compiler or MEX target
  if (BASIS_TYPE MATCHES "^MCC_|^MEX$")
    get_target_property (DEPENDS ${TARGET_UID} "LINK_DEPENDS")

    if (NOT DEPENDS)
      set (DEPENDS)
    endif ()
    list (APPEND DEPENDS ${ARGS})
 
    # pull implicit dependencies (e.g., ITK uses this)
    # note that MCC does itself a dependency check
    if (NOT BASIS_TYPE MATCHES "^MCC_")
      set (DEPENDENCY_ADDED 1)
      while (DEPENDENCY_ADDED)
        set (DEPENDENCY_ADDED 0)
        foreach (LIB ${DEPENDS})
          foreach (LIB_DEPEND ${${LIB}_LIB_DEPENDS})
            if (NOT LIB_DEPEND MATCHES "^general$")
              string (REGEX REPLACE "^-l" "" LIB_DEPEND "${LIB_DEPEND}")
              list (FIND DEPENDS ${LIB_DEPEND} IDX)
              if (IDX EQUAL -1)
                list (APPEND DEPENDS ${LIB_DEPEND})
                set (DEPENDENCY_ADDED 1)
              endif ()
            endif ()
          endforeach ()
        endforeach ()
      endwhile ()
    endif ()

    set_target_properties (${TARGET_UID} PROPERTIES LINK_DEPENDS "${DEPENDS}")
  # other
  else ()
    target_link_libraries (${TARGET_UID} ${ARGS})
  endif ()
endfunction ()

# ============================================================================
# add targets
# ============================================================================

##############################################################################
# @brief CMake's add_executable(), overwritten only to be able to store also
#        imported build targets declared in exports files in BASIS_TARGETS.
#
# Use basis_add_executable() instead where possible!
#
# @sa basis_add_executable()
#
# @ingroup CMakeUtilities

function (add_executable TARGET_NAME)
  _add_executable (${TARGET_NAME} ${ARGN})
  set (
    BASIS_TARGETS "${BASIS_TARGETS};${TARGET_NAME}"
    CACHE STRING "${BASIS_TARGETS_DOC}" FORCE
  )
endfunction ()

##############################################################################
# @brief CMake's add_library(), overwritten only to be able to store also
#        imported build targets declared in exports files in BASIS_TARGETS.
#
# Use basis_add_library() instead where possible!
#
# @sa basis_add_library()
#
# @ingroup CMakeUtilities

function (add_library TARGET_NAME)
  _add_library (${TARGET_NAME} ${ARGN})
  set (
    BASIS_TARGETS "${BASIS_TARGETS};${TARGET_NAME}"
    CACHE STRING "${BASIS_TARGETS_DOC}" FORCE
  )
endfunction ()

##############################################################################
# @brief Replacement for CMake's add_executable() command.
#
# This function adds an executable target.
#
# By default, the BASIS C++ utilities library is added as link dependency of
# the added executable target. If none of the BASIS C++ utilities are used
# by the executable, the option NO_BASIS_UTILITIES can be given. Note, however,
# that the utilities library is a static library and thus the linker would not
# include any of the BASIS utilities object code in the binary executable.
#
# An install command for the added executable target is added by this function
# as well. The executable will be installed as part of the component @p COMPONENT
# in the directory @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR if the option
# @p LIBEXEC is given.
#
# Besides adding usual executable targets build by the set <tt>C/CXX</tt>
# language compiler, this function inspects the list of source files given and
# detects whether this list contains sources which need to be build using a
# different compiler. In particular, it supports the following languages:
#
# <table border="0">
#   <tr>
#     @tp @b CXX @endtp
#     <td>The default behavior, adding an executable target build from C/C++
#         source code. The target is added via CMake's add_executable() command.</td>
#   </tr>
#   <tr>
#     @tp @b MATLAB @endtp
#     <td>Standalone application build from MATLAB sources using the
#         MATLAB Compiler (mcc). This language option is used when the list
#         of source files contains one or more *.m files. A custom target is
#         added which depends on custom command(s) that build the executable.</td>
#         @n@n
#         Attention: The *.m file with the entry point/main function of the
#                    executable has to be given before any other *.m file.
#   </tr>
# </table>
#
# @param [in] TARGET_NAME Name of the executable target.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted, all other arguments are passed
#                         on to add_executable() or the respective custom
#                         commands used to build the executable.
# @par
# <table border="0">
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of the component. Default: @c BASIS_RUNTIME_COMPONENT.</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE lang @endtp
#     <td>Source code language. By default determined from the extensions of
#         the given source files, where CXX is assumed if no other language is
#         detected.</td>
#   </tr>
#   <tr>
#     @tp @b LIBEXEC @endtp
#     <td>Specifies that the built executable is an auxiliary executable
#         which is only called by other executable. Ignored if given together
#         with the option @p TEST.</td>
#   </tr>
#   <tr>
#     @tp @b TEST @endtp
#     <td>Specifies that the built executable is a test executable used
#         with basis_add_test().</td>
#   </tr>
#   <tr>
#     @tp @b NO_BASIS_UTILITIES @endtp
#     <td>Do not add the BASIS C++ utilities as link dependency.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export the target.</td>
#   </tr>
# </table>
#
# @returns Adds an executable build target. In case of a MATLAB Compiler
#          target, the function basis_add_custom_finalize() has to be
#          invoked to actually add the custom target that builds the executable.

function (basis_add_executable TARGET_NAME)
  basis_check_target_name (${TARGET_NAME})
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
    "LIBEXEC;TEST;NO_BASIS_UTILITIES;NO_EXPORT"
    "COMPONENT;LANGUAGE"
    ""
    ${ARGN}
  )

  # if no component is specified, use default
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (ARGN_TEST)
    set (ARGN_LIBEXEC 0)
  endif ()

  # if the language is not explicitly selected, determine it from the
  # extensions of the source files
  if (NOT ARGN_LANGUAGE)
    set (ARGN_LANGUAGE "CXX")
    foreach (ARG ${ARGN})
      if (ARG MATCHES "\\.m$")
        set (ARGN_LANGUAGE "MATLAB")
      endif ()
    endforeach ()
  endif ()

  # --------------------------------------------------------------------------
  # MATLAB Compiler
  # --------------------------------------------------------------------------

  if (ARGN_LANGUAGE STREQUAL "MATLAB")

    if (ARGN_TEST)
      set (EXECOPT "TEST")
    elseif (ARGN_LIBEXEC)
      set (EXECOPT "LIBEXEC")
    else ()
      set (EXECOPT "")
    endif ()

    basis_add_mcc_target (
      ${TARGET_NAME}
      TYPE      "EXECUTABLE"
      COMPONENT "${ARGN_COMPONENT}"
      ${EXECOPT}
      ${ARGN_UNPARSED_ARGUMENTS}
    )

  # --------------------------------------------------------------------------
  # other (just wrap add_executable () by default)
  # --------------------------------------------------------------------------

  else ()

    message (STATUS "Adding executable ${TARGET_UID}...")

    # add executable target
    add_executable (${TARGET_UID} ${ARGN_UNPARSED_ARGUMENTS})

    set_target_properties (${TARGET_UID} PROPERTIES BASIS_TYPE  "EXECUTABLE")
    set_target_properties (${TARGET_UID} PROPERTIES OUTPUT_NAME "${TARGET_NAME}")

    if (ARGN_LIBEXEC)
      set_target_properties (
        ${TARGET_UID}
        PROPERTIES
          LIBEXEC                  1
          COMPILE_DEFINITIONS      "LIBEXEC"
          RUNTIME_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
      )
    else ()
      set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 0)
    endif ()

    if (ARGN_TEST)
      set_target_properties (${TARGET_UID} PROPERTIES TEST 1)
    else ()
      set_target_properties (${TARGET_UID} PROPERTIES TEST 0)
    endif ()

    # add default link dependencies
    if (NOT ARGN_NO_BASIS_UTILITIES)
      target_link_libraries (${TARGET_UID} "basis${BASIS_NAMESPACE_SEPARATOR}utils")
    endif ()

    # target version information
    # Note: On UNIX-based systems this only creates annoying files with
    #       the version string as suffix and two symbolic links.
    if (WIN32)
      set_target_properties (
        ${TARGET_UID}
        PROPERTIES
          VERSION   ${PROJECT_VERSION}
          SOVERSION ${PROJECT_SOVERSION}
      )
    endif ()

    # install executable
    if (ARGN_TEST)
      # TODO install (selected?) tests
    else ()
      if (ARGN_LIBEXEC)
        set (INSTALL_DIR "${INSTALL_LIBEXEC_DIR}")
      else ()
        set (INSTALL_DIR "${INSTALL_RUNTIME_DIR}")
      endif ()

      if (ARGN_NO_EXPORT)
        set (EXPORT_OPT)
      else ()
        set (EXPORT_OPT "EXPORT" "${PROJECT_NAME}")

        set (
          BASIS_EXPORT_TARGETS "${BASIS_EXPORT_TARGETS};${TARGET_UID}"
          CACHE INTERNAL "${BASIS_EXPORT_TARGETS_DOC}" FORCE
        )
      endif ()

      install (
        TARGETS     ${TARGET_UID} ${EXPORT_OPT}
        DESTINATION "${INSTALL_DIR}"
        COMPONENT   "${ARGN_COMPONENT}"
      )

      set_target_properties (
        ${TARGET_UID}
        PROPERTIES
          RUNTIME_INSTALL_DIRECTORY "${INSTALL_DIR}"
      )
    endif ()

    message (STATUS "Adding executable ${TARGET_UID}... - done")

  endif ()
endfunction ()

##############################################################################
# @brief Replaces CMake's add_library() command.
#
# This function adds a library target.
#
# An install command for the added library target is added by this function
# as well. The runtime library will be installed as part of the component
# RUNTIME_COMPONENT in the directory INSTALL_LIBRARY_DIR on UNIX systems
# and INSTALL_RUNTIME_DIR on Windows. Static/import libraries will be installed
# as part of the LIBRARY_COMPONENT in the directory INSTALL_ARCHIVE_DIR.
#
# Besides adding usual library targets build by the set <tt>C/CXX</tt>
# language compiler, this function inspects the list of source files given and
# detects whether this list contains sources which need to be build using a
# different compiler. In particular, it supports the following languages:
#
# <table border="0">
#   <tr>
#     @tp @b CXX @endtp
#     <td>The default behavior, adding an executable target build from C/C++
#         source code. The target is added via CMake's add_executable() command
#         if neither or one of the options STATIC, SHARED, or MODULE is given.
#         If the option MEX is given, a MEX-file is build using the MEX script.</td>
#   </tr>
#   <tr>
#     @tp @b MATLAB @endtp
#     <td>Shared libraries build from MATLAB sources using the MATLAB Compiler (mcc).
#         This language option is used when the list of source files contains one or
#         more *.m files. A custom target is added which depends on custom command(s)
#         that build the library.</td>
#   </tr>
# </table>
#
# Example:
# @code
# basis_add_library (MyLib1 STATIC mylib.cc)
# basis_add_library (MyLib2 STATIC mylib.cc COMPONENT dev)
#
# basis_add_library (
#   MyLib3 SHARED mylib.cc
#   RUNTIME_COMPONENT bin
#   LIBRARY_COMPONENT dev
# )
# @endcode
#
# @param [in] TARGET_NAME Name of the library target.
# @param [in] ARGN        Arguments passed to add_library() (excluding target name).
#                         This argument list is parsed and the following
#                         arguments are extracted, all other arguments are passed
#                         on to add_library().
# @par
# <table border="0">
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of the component. Default: @c BASIS_LIBRARY_COMPONENT.</td>
#   </tr>
#   <tr>
#     @tp @b RUNTIME_COMPONENT name @endtp
#     <td>Name of runtime component. Default: @c COMPONENT if specified or
#         @c BASIS_RUNTIME_COMPONENT, otherwise.</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_COMPONENT name @endtp
#     <td>Name of library component. Default: @c COMPONENT if specified or
#         @c BASIS_LIBRARY_COMPONENT, otherwise.</td>
#   </tr>
#   <tr>
#     @tp <b>STATIC</b>|<b>SHARED</b>|<b>MODULE</b>|<b>MEX</b> @endtp
#     <td>Type of the library.</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE lang @endtp
#     <td>Source code language. By default determined from the extensions of
#         the given source files, where CXX is assumed if no other language is
#         detected.</td>
#   </tr>
#   <tr>
#     @tp @b INTERNAL @endtp
#     <td>Whether the library target is an internal library, i.e., only
#         shared libraries are installed but not static or import libraries.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export build target.</td>
#   </tr>
# </table>
#
# @returns Adds a library build target. In case of a MATLAB Compiler target
#          or a MEX script target, basis_add_custom_finalize() has to be invoked
#          to actually add the custom target that builds the library.

function (basis_add_library TARGET_NAME)
  basis_check_target_name (${TARGET_NAME})
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "STATIC;SHARED;MODULE;MEX;INTERNAL;NO_EXPORT"
      "COMPONENT;LIBRARY_COMPONENT;RUNTIME_COMPONENT;LANGUAGE"
      ""
    ${ARGN}
  )

  if (NOT ARGN_LIBRARY_COMPONENT AND ARGN_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "${ARGN_COMPONENT}")
  endif ()
  if (NOT ARGN_RUNTIME_COMPONENT AND ARGN_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "${ARGN_COMPONENT}")
  endif ()

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (NOT ARGN_LIBRARY_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()
  if (NOT ARGN_LIBRARY_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "Unspecified")
  endif ()

  if (NOT ARGN_RUNTIME_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_RUNTIME_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "Unspecified")
  endif ()

  # do not export internal targets
  if (ARGN_INTERNAL)
    set (ARGN_NO_EXPORT 1)
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

  # mismatch between library type and source code language?
  if (ARGN_MEX AND NOT "${ARGN_LANGUAGE}" STREQUAL "CXX")
    message (FATAL_ERROR "Invalid language '${ARGN_LANGUAGE}'. The source code of the MEX-file target ${TARGET_UID} must be written in C/C++.")
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

    set (OPTS)
    list (APPEND OPTS "TYPE" "LIBRARY")
    list (APPEND OPTS "RUNTIME_COMPONENT" "${ARGN_RUNTIME_COMPONENT}")
    list (APPEND OPTS "LIBRARY_COMPONENT" "${ARGN_LIBRARY_COMPONENT}")
    if (ARGN_NO_EXPORT)
      list (APPEND OPTS "NO_EXPORT")
    endif ()

    basis_add_mcc_target (${TARGET_NAME} ${OPTS} ${ARGN_UNPARSED_ARGUMENTS})

  # --------------------------------------------------------------------------
  # MEX
  # --------------------------------------------------------------------------

  elseif (ARGN_TYPE STREQUAL "MEX")
 
    set (OPTS)
    list (APPEND OPTS "COMPONENT" "${ARGN_LIBRARY_COMPONENT}")
    if (ARGN_NO_EXPORT)
      list (APPEND OPTS "NO_EXPORT")
    endif ()

    basis_add_mex_target (${TARGET_NAME} ${OPTS} ${ARGN_UNPARSED_ARGUMENTS})

  # --------------------------------------------------------------------------
  # C/C++
  # --------------------------------------------------------------------------

  else ()

    add_library (${TARGET_UID} ${ARGN_TYPE} ${ARGN_UNPARSED_ARGUMENTS})

    set_target_properties (${TARGET_UID} PROPERTIES BASIS_TYPE  "${ARGN_TYPE}_LIBRARY")
    set_target_properties (${TARGET_UID} PROPERTIES OUTPUT_NAME "${TARGET_NAME}")

    # target version information
    #
    # Note:      On UNIX-based systems this only creates annoying files with the
    #            version string as suffix.
    # Attention: MEX-files may NEVER have a suffix after the MEX extension!
    #            Otherwise, the MATLAB Compiler when using the symbolic link
    #            without this suffix will create code that fails on runtime
    #            with an .auth file missing error.
    #
    # Thus, do NOT set VERSION and SOVERSION properties.

    # install library
    if (ARGN_NO_EXPORT)
      set (EXPORT_OPT)
    else ()
      set (EXPORT_OPT "EXPORT" "${PROJECT_NAME}")
      set (
        BASIS_EXPORT_TARGETS "${BASIS_EXPORT_TARGETS};${TARGET_UID}"
        CACHE INTERNAL "${BASIS_EXPORT_TARGETS_DOC}" FORCE
      )
    endif ()

    if (NOT ARGN_STATIC)
        install (
          TARGETS ${TARGET_UID} ${EXPORT_OPT}
          RUNTIME
            DESTINATION "${INSTALL_RUNTIME_DIR}"
            COMPONENT   "${ARGN_RUNTIME_COMPONENT}"
        )
    endif ()

    if (NOT ARGN_INTERNAL)
        install (
          TARGETS ${TARGET_UID} ${EXPORT_OPT}
          LIBRARY
            DESTINATION "${INSTALL_LIBRARY_DIR}"
            COMPONENT   "${ARGN_LIBRARY_COMPONENT}"
          ARCHIVE
            DESTINATION "${INSTALL_ARCHIVE_DIR}"
            COMPONENT   "${ARGN_LIBRARY_COMPONENT}"
        )
    endif ()
 
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

##############################################################################
# @brief Get default target name for given script file.
#
# This function returns the target name as used by basis_add_script() if
# no particular target name was specified.
#
# @param [out] TARGET_NAME Target name.
# @param [in]  SCRIPT_FILE File name of script.
#
# @returns Default target name derived from script file path.

function (basis_script_target_name TARGET_NAME SCRIPT_FILE)
  # remove ".in" suffix from file name
  string (REGEX REPLACE "\\.in$" "" SCRIPT_FILE "${SCRIPT_FILE}")
  # use file basename as target name
  get_filename_component (TARGET_NAME "${SCRIPT_FILE}" NAME)
  # return
  set (TARGET_NAME "${TARGET_NAME}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Add script target.
#
# This function adds a script target to the project, where during the build
# step the script is configured via configure_file() and copied to the
# directory specified by @p OUTPUT_DIRECTORY. During installation, the script
# built for the install tree is copied to the specified @p DESTINATION.
#
# If the script name ends in ".in", the ".in" suffix is removed from the
# output name. Further, the extension of the script such as .sh or .py is
# removed from the output filename during the installation if the project
# is build on Unix-based systems and the script file contains a sha-bang
# directive, i.e., the first two characters on the first line are "#" followed
# by the path to the script language interpreter.
#
# Example:
# @code
# basis_add_script (MyShellScript.sh.in)
# basis_add_script (Script SCRIPT Script1.sh)
# @endcode
#
# Certain CMake variables within the script are replaced during the configure step.
# These variables and their values are given by a so-called script config(uration)
# file. The specified script configuration file is loaded during the build of
# the script prior to the configure_file() command. As paths may be different
# for scripts that are used directly from the build tree and scripts that are
# copied into the install tree, the variable @c BUILD_INSTALL_SCRIPT is 1 when the
# script is build for the install tree and 0 otherwise. This variable can be
# used within the script configuration file to set the value of the CMake
# variables used within the script differently for either case.
#
# Example:
# @code
# basis_add_script (Script1 SCRIPT Script1.sh CONFIG Script1Config.cmake)
# @endcode
#
# Script1Config.cmake
# @code
# basis_set_script_path (DATA_DIR "@PROJECT_DATA_DIR@" "@INSTALL_DATA_DIR@")
# @endcode
#
# See documentation of basis_set_script_path_definition() and ScriptConfig.cmake
# file in @c BASIS_MODULE_PATH for details.
#
# Note that this function only adds a custom target and stores all information
# required to setup the actual custom build command as properties of this target.
# The custom build command itself is added by basis_add_script_finalize(), which
# is supposed to be called once at the end of the root CMakeLists.txt file of the
# sub-/superproject. This way properties such as the @c OUTPUT_NAME can still be modified
# after adding the script target.
#
# If a custom script configuration file is used, the variable
# \@BASIS_SCRIPT_CONFIG\@ can be used within this custom script configuration file
# to include the default configuration of the @c BASIS_SCRIPT_CONFIG_FILE.
#
# @sa basis_add_script_finalize()
#
# @param [in] TARGET_NAME Name of the target. Alternatively, the script file
#                         path relative to the current source directory can be
#                         given here. In this case, the basename of the script
#                         file is used as target name and the SCRIPT option may
#                         not be used.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted:
# @par
# <table border="0">
#   <tr>
#      @tp @b SCRIPT file @endtp
#      <td>Script file path relative to current source directory.</td>
#   </tr>
#   <tr>
#      @tp @b OUTPUT_DIRECTORY dir @endtp
#      <td>The output directory for the configured script in the
#          build tree. Default: @c CMAKE_RUNTIME_OUTPUT_DIRECTORY.</td>
#   </tr>
#   <tr>
#      @tp @b DESTINATION dir @endtp
#      <td>The installation directory relative to @c INSTALL_PREFIX.
#          Default: @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR if
#                   the @p LIBEXEC option is given or @c INSTALL_LIBRARY_DIR
#                   if the @p MODULE option is given.</td>
#   </tr>
#   <tr>
#      @tp @b COMPONENT name @endtp
#      <td>Name of the component. Default: @c BASIS_RUNTIME_COMPONENT.</td>
#   </tr>
#   <tr>
#      @tp @b CONFIG config @endtp
#      <td>Script configuration given directly as string argument. This
#          string is appended to the content of the script configuration file
#          as specified by @p CONFIG_FILE if this option is given. The string
#          "@BASIS_SCRIPT_CONFIG@" in the script configuration is replaced by
#          the content of the default script configuration file.
#          Default: "@BASIS_SCRIPT_CONFIG@"</td>
#   </tr>
#   <tr>
#      @tp @b CONFIG_FILE file @endtp
#      <td>Script configuration file. If "NONE", "None", or "none" is given,
#          the script is copied only. Defaults to the file
#          PROJECT_CONFIG_DIR/ScriptConfig.cmake.in if it exists. Otherwise,
#          @p CONFIG is used only.</td>
#   </tr>
#   <tr>
#     @tp @b COPYONLY @endtp
#     <td>Specifies that the script file shall be copied only. If given, the options
#         @p CONFIG and @p CONFIG_FILE are ignored.
#   </tr>
#   <tr>
#      @tp @b NOEXEC @endtp
#      <td>Specifies that the script cannot be "executed" directly,
#          but always requires some kind of interpreter. Note that
#          with this option, the meaning of "script" can be even more
#          general. Any text file, which is processed by a program
#          to perform certain tasks, i.e., a configuration file
#          can be considered as "script" in this sense.</td>
#   </tr>
#   <tr>
#      @tp @b KEEPEXT @endtp
#      <td>If this option is given, it forces this function to keep
#          the scripts file name extension even if a sha-bang
#          directive is given on Unix-based systems.</td>
#   </tr>
#   <tr>
#      @tp @b LIBEXEC @endtp
#      <td>Specifies that the script is an auxiliary executable or script which is
#          called by other executables only.</td>
#   </tr>
#   <tr>
#      @tp @b MODULE @endtp
#      <td>Specifies that the script is a module file which is included by
#          other scripts. Implies @p NOEXEC, @p LIBEXEC (regarding destination),
#          and @p KEEPEXT. It can be used, for example, for Python modules that
#          are to be imported only by other Python scripts and BASH scripts that
#          are to be sourced only by other BASH scripts.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export build target.</td>
#   </tr>
# </table>
#
# @returns Adds custom build target @p TARGET_NAME. In order to add the
#          custom target that actually builds the script file,
#          basis_add_custom_finalize() has to be invoked.

function (basis_add_script TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "LIBEXEC;NOEXEC;KEEPEXT;MODULE;COPYONLY;NO_EXPORT"
      "SCRIPT;CONFIG;CONFIG_FILE;COMPONENT;BINARY_DIRECTORY;OUTPUT_DIRECTORY;DESTINATION"
      ""
    ${ARGN}
  )

  if (ARGN_MODULE)
    set (ARGN_LIBEXEC 1)
    set (ARGN_KEEPEXT 1)
    set (ARGN_NOEXEC  1)
  endif ()

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (ARGN_BINARY_DIRECTORY)
    if (NOT IS_ABSOLUTE "${ARGN_BINARY_DIRECTORY}")
      get_filename_component (ARGN_BINARY_DIRECTORY "${ARGN_BINARY_DIRECTORY}" ABSOLUTE)
    endif ()
  else ()
    set (ARGN_BINARY_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
  endif ()
  if (ARGN_OUTPUT_DIRECTORY)
    if (NOT IS_ABSOLUTE "${ARGN_OUTPUT_DIRECTORY}")
      get_filename_component (ARGN_OUTPUT_DIRECTORY "${ARGN_OUTPUT_DIRECTORY}" ABSOLUTE)
    endif ()
  else ()
    if (ARGN_MODULE)
      set (ARGN_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
    elseif (ARGN_LIBEXEC)
      set (ARGN_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
    else ()
      set (ARGN_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    endif ()
  endif ()

  if (ARGN_DESTINATION)
    if (IS_ABSOLUTE "${ARGN_DESTINATION}")
      file (RELATIVE_PATH ARGN_DESTINATION "${INSTALL_PREFIX}" "${ARGN_DESTINATION}")
    endif ()
  else ()
    if (ARGN_MODULE)
      set (ARGN_DESTINATION "${INSTALL_LIBRARY_DIR}")
    elseif (ARGN_LIBEXEC)
      set (ARGN_DESTINATION "${INSTALL_LIBEXEC_DIR}")
    else ()
      set (ARGN_DESTINATION "${INSTALL_RUNTIME_DIR}")
    endif ()
  endif ()

  if (IS_ABSOLUTE "${ARGN_DESTINATION}")
    message (FATAL_ERROR "basis_add_script (${TARGET_NAME}: Destination must be a relative path")
  endif ()

  if (NOT ARGN_CONFIG AND NOT ARGN_CONFIG_FILE)
    if (EXISTS "${PROJECT_CONFIG_DIR}/ScriptConfig.cmake.in")
      set (ARGN_CONFIG_FILE "${PROJECT_CONFIG_DIR}/ScriptConfig.cmake.in")
    else ()
      set (ARGN_CONFIG "\@BASIS_SCRIPT_CONFIG\@")
    endif ()
  endif ()

  if (ARGN_UNPARSED_ARGUMENTS)
    message (FATAL_ERROR "Unknown arguments given for basis_add_script (${TARGET_NAME}): ${ARGN_UNPARSED_ARGUMENTS}")
  endif ()

  if (NOT ARGN_SCRIPT)
    set (ARGN_SCRIPT "${TARGET_NAME}")
    basis_script_target_name (TARGET_NAME "${ARGN_SCRIPT}")
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
    if (EXISTS "${ARGN_SCRIPT}.in")
      set (ARGN_SCRIPT "${ARGN_SCRIPT}.in")
    else ()
      get_filename_component (DIR    "${ARGN_SCRIPT}" PATH)
      get_filename_component (FNAME  "${ARGN_SCRIPT}" NAME_WE)
      get_filename_component (SUFFIX "${ARGN_SCRIPT}" EXT)
      if (EXISTS "${DIR}/${FNAME}.in${SUFFIX}")
        set (ARGN_SCRIPT "${DIR}/${FNAME}.in${SUFFIX}")
      endif ()
    endif ()
  endif ()

  if (NOT EXISTS "${ARGN_SCRIPT}")
    message (FATAL_ERROR "Missing script ${ARGN_SCRIPT}!")
  endif ()

  # get script file name
  get_filename_component (SCRIPT_NAME "${ARGN_SCRIPT}" NAME)

  # remove ".in" from output name
  string (REGEX REPLACE "\\.in$" "" SCRIPT_NAME "${SCRIPT_NAME}")

  set (OUTPUT_NAME "${SCRIPT_NAME}")
  if (NOT ARGN_KEEPEXT AND UNIX)
    file (STRINGS "${ARGN_SCRIPT}" SHABANG LIMIT_COUNT 2 LIMIT_INPUT 2)
    if (SHABANG STREQUAL "#!")
      get_filename_component (OUTPUT_NAME "${OUTPUT_NAME}" NAME_WE)
    endif ()
  endif ()

  # script configuration
  set (INSTALL_DIR "${ARGN_DESTINATION}")
  set (SCRIPT_CONFIG)

  if (NOT ARGN_COPYONLY)
    if (ARGN_CONFIG_FILE)
      if (NOT EXISTS "${ARGN_CONFIG_FILE}")
        message (FATAL_ERROR "Script configuration file \"${ARGN_CONFIG_FILE}\" does not exist. It is required to build the script ${TARGET_UID}.")
      endif ()
      file (READ "${ARGN_CONFIG_FILE}" SCRIPT_CONFIG)
    endif ()
    if (ARGN_CONFIG)
      set (SCRIPT_CONFIG "${SCRIPT_CONFIG}\n\n${ARGN_CONFIG}")
    endif ()

    if (SCRIPT_CONFIG MATCHES "@BASIS_SCRIPT_CONFIG@" AND EXISTS "${BASIS_SCRIPT_CONFIG_FILE}")
      file (READ "${BASIS_SCRIPT_CONFIG_FILE}" BASIS_SCRIPT_CONFIG)
    else ()
      set (BASIS_SCRIPT_CONFIG)
    endif ()

    while (SCRIPT_CONFIG MATCHES "@[a-zA-Z0-9_-]+@")
      string (CONFIGURE "${SCRIPT_CONFIG}" SCRIPT_CONFIG @ONLY)
    endwhile ()
    set (BASIS_SCRIPT_CONFIG)
  endif ()

  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${ARGN_SCRIPT})

  # set target properties required by basis_add_script_finalize ()
  if (ARGN_MODULE)
    set (TYPE "MODULE_SCRIPT")
  else ()
    set (TYPE "SCRIPT")
  endif ()

  set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      BASIS_TYPE                "${TYPE}"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${ARGN_BINARY_DIRECTORY}"
      RUNTIME_OUTPUT_DIRECTORY  "${ARGN_OUTPUT_DIRECTORY}"
      RUNTIME_INSTALL_DIRECTORY "${ARGN_DESTINATION}"
      OUTPUT_NAME               "${OUTPUT_NAME}"
      PREFIX                    ""
      SUFFIX                    ""
      COMPILE_DEFINITIONS       "${SCRIPT_CONFIG}"
      RUNTIME_COMPONENT         "${ARGN_COMPONENT}"
  )

  if (ARGN_LIBEXEC)
    set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 1)
  else ()
    set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 0)
  endif ()

  if (ARGN_NOEXEC)
    set_target_properties (${TARGET_UID} PROPERTIES NOEXEC 1)
  else ()
    set_target_properties (${TARGET_UID} PROPERTIES NOEXEC 0)
  endif ()

  # add target to list of targets
  set (
    BASIS_TARGETS "${BASIS_TARGETS};${TARGET_UID}"
    CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE
  )

  if (NOT ARGN_NO_EXPORT)
    set (
      BASIS_CUSTOM_EXPORT_TARGETS "${BASIS_CUSTOM_EXPORT_TARGETS};${TARGET_UID}"
      CACHE INTERNAL "${BASIS_CUSTOM_EXPORT_TARGETS_DOC}" FORCE
    )
  endif ()

  message (STATUS "Adding script ${TARGET_UID}... - done")
endfunction ()

##############################################################################
# @brief Finalize addition of script.
#
# This function uses the properties of the custom script target added by
# basis_add_script() to create the custom build command and adds this build
# command as dependency of this added target.
#
# @sa basis_add_script()
# @sa basis_add_custom_finalize()
#
# @param [in] TARGET_UID "Global" target name. If this function is used
#                        within the same project as basis_add_script(),
#                        the "local" target name may be given alternatively.
#
# @returns Adds custom target(s) to actually build the script target
#          @p TARGET_UID added by basis_add_script().
#
# @ingroup CMakeUtilities

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
      "RUNTIME_COMPONENT"
      "LIBEXEC"
      "NOEXEC"
  )

  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()

  # check target type
  if (NOT BASIS_TYPE MATCHES "^SCRIPT$|^MODULE_SCRIPT$")
    message (FATAL_ERROR "Target ${TARGET_UID} has invalid BASIS_TYPE: ${BASIS_TYPE}")
  endif ()

  # build directory (note that CMake returns basename of build directory as first element of SOURCES list)
  list (GET SOURCES 0 BUILD_DIR)
  set (BUILD_DIR "${BUILD_DIR}.dir")

  # extract script file from SOURCES
  list (GET SOURCES 1 SCRIPT_FILE)

  # get script name without ".in"
  get_filename_component (SCRIPT_NAME_IN "${SCRIPT_FILE}" NAME)
  string (REGEX REPLACE "\\.in$" "" SCRIPT_NAME "${SCRIPT_NAME_IN}")

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
  #
  # Note: If the script is configured, this is done twice, once for the build tree
  #       and once for the installation. The build tree version of the configured
  #       script is written to the runtime output directory in the build tree.
  #       The version configured for the installation, is written to the binary
  #       directory that corresponds to the source directory of the script.
  #       If a documentation is generated automatically from the sources, the
  #       latter, i.e., the script which will be installed is used as input file.
  set (BUILD_SCRIPT "${BUILD_DIR}/build.cmake")
  set (OUTPUT_FILE  "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_NAME}")
  set (INSTALL_FILE "${SCRIPT_FILE}")
  set (OUTPUT_FILES "${OUTPUT_FILE}")

  set (BUILD_COMMANDS "# DO NOT edit. This file is automatically generated by BASIS.\n\n")

  # If script file name ends in ".in" and a script configuration file is given,
  # configure the script twice, once for the build tree and once for the installation.
  # Otherwise, just copy the script file directoy to the output directory.
  if (COMPILE_DEFINITIONS AND NOT "${SCRIPT_NAME}" STREQUAL "${SCRIPT_NAME_IN}")
    basis_set_script_path_definition (FUNCTIONS)
    string (CONFIGURE "${FUNCTIONS}" FUNCTIONS @ONLY)

    set (INSTALL_FILE "${BINARY_DIRECTORY}/${SCRIPT_NAME}")
    list (APPEND OUTPUT_FILES "${INSTALL_FILE}")

    string (REPLACE "\r" "" COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}")

    set (BUILD_COMMANDS "${BUILD_COMMANDS}${FUNCTIONS}\n\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}set (BUILD_INSTALL_SCRIPT 0)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}set (SCRIPT_DIR \"${RUNTIME_OUTPUT_DIRECTORY}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}set (NAME \"${OUTPUT_NAME}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}${COMPILE_DEFINITIONS}\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}configure_file (\"${SCRIPT_FILE}\" \"${OUTPUT_FILE}\" @ONLY)\n")
    if (NOT NOEXEC)
    set (BUILD_COMMANDS "${BUILD_COMMANDS}\nif (UNIX)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}  execute_process (COMMAND chmod +x \"${OUTPUT_FILE}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}endif ()\n")
    endif ()
    set (BUILD_COMMANDS "${BUILD_COMMANDS}\nset (BUILD_INSTALL_SCRIPT 1)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}set (SCRIPT_DIR \"${CMAKE_INSTALL_PREFIX}/${RUNTIME_INSTALL_DIRECTORY}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}set (NAME \"${OUTPUT_NAME}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}${COMPILE_DEFINITIONS}\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}configure_file (\"${SCRIPT_FILE}\" \"${INSTALL_FILE}\" @ONLY)\n")
  else ()
    set (BUILD_COMMANDS "${BUILD_COMMANDS}configure_file (\"${SCRIPT_FILE}\" \"${OUTPUT_FILE}\" COPYONLY)\n")
    if (NOT NOEXEC)
    set (BUILD_COMMANDS "${BUILD_COMMANDS}\nif (UNIX)\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}  execute_process (COMMAND chmod +x \"${OUTPUT_FILE}\")\n")
    set (BUILD_COMMANDS "${BUILD_COMMANDS}endif ()\n")
    endif ()
  endif ()

  # write build script only if it differs from previous build script
  #
  # Note: Adding BUILD_SCRIPT to the dependencies of the custom command
  #       caused the custom command to be executed every time even when the
  #       BUILD_SCRIPT file was not modified. Therefore, use dummy output
  #       file which is deleted when the script differs from the previous one.
  #
  # TODO There must be a better solution to this problem.
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
  if (NOEXEC)
    set (WHAT "FILES")
  else ()
    set (WHAT "PROGRAMS")
  endif ()

  install (
    ${WHAT}     "${INSTALL_FILE}"
    RENAME      "${OUTPUT_NAME}"
    DESTINATION "${RUNTIME_INSTALL_DIRECTORY}"
    COMPONENT   "${RUNTIME_COMPONENT}"
  )

  message (STATUS "Adding build command for script ${TARGET_UID}... - done")
endfunction ()

##############################################################################
# @brief Add scripts with specified extension.
#
# This function calls basis_add_script() for each script within the current
# source directory which has the extension ".EXT" or ".EXT.in".
#
# @param [in] EXT  Script extension, e.g., "sh" for shell scripts.
# @param [in] ARGN This argument list is parsed and the following
#                  arguments are extracted:
# @par
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b COMPONENT name</td>
#     <td>Name of the component. See basis_add_script() for default.</td>
#   </tr>
# </table>
#
# @returns Adds custom build targets for the globbed scritps. To add the
#          custom targets that actually build the scripts,
#          basis_add_custom_finalize() has to be invoked.

function (basis_add_scripts_by_extension EXT)
  if (BASIS_VERBOSE)
    file (RELATIVE_PATH DIR "${PROJECT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
    message (STATUS "Adding scripts in ${DIR} with extension .${EXT} or .${EXT}.in")
    set (DIR)
  endif ()

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "COMPONENT" "" ${ARGN})

  if (ARGN_UNPARSED_ARGUMENTS)
    message ("Unknown arguments given for basis_add_scripts_by_extension (${EXT}): ${ARGN_UNPARSED_ARGUMENTS}")
  endif ()

  if (ARGN_COMPONENT)
    set (COMPONENT "COMPONENT" "${ARGN_COMPONENT}")
  endif ()

  # glob script files with given extension
  file (GLOB FILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/*")

  # add scripts
  foreach (SCRIPT ${FILES})
    if (NOT IS_DIRECTORY "${SCRIPT}")
      if ("${SCRIPT}" MATCHES ".*\\.${EXT}$|.*\\.${EXT}\\.in$")
        basis_add_script ("${SCRIPT}" ${COMPONENT})
      endif ()
    endif ()
  endforeach ()
endfunction ()

##############################################################################
# @brief Add scripts with specified extensions.
#
# @sa basis_add_scripts_by_extension()
#
# @param [in] ARGN This argument list is parsed and the following arguments
#                  are extracted. All other arguments are considered script
#                  extension.
# @par
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b COMPONENT name</td>
#     <td>Name of the component. See basis_add_script() for default.</td>
#   </tr>
# </table>
#
# @returns Adds custom build targets for the globbed scritps. To add the
#          custom targets that actually build the scripts,
#          basis_add_custom_finalize() has to be invoked.

macro (basis_add_scripts_by_extensions)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "COMPONENT" "" ${ARGN})

  if (ARGN_COMPONENT)
    set (COMPONENT "COMPONENT" "${ARGN_COMPONENT}")
  endif ()

  # add scripts by extension
  foreach (EXT ${ARGN_UNPARSED_ARGUMENTS})
    basis_add_scripts_by_extension ("${EXT}" ${COMPONENT})
  endforeach ()
endmacro ()

##############################################################################
# @brief Add scripts with default extensions.
#
# This macro adds each script within the current source directory which has
# a default extension using basis_add_script().
#
# Considered default extensions are "sh" for shell scripts, "py" for Python
# scripts, and "pl" for Perl scripts.
#
# \param [in] ARGN This argument list is parsed and the following arguments
#                  are extracted.
# @par
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b COMPONENT name</td>
#     <td>Name of the component. See basis_add_script() for default.</td>
#   </tr>
# </table>
#
# @returns Adds custom build targets for the globbed scritps. To add the
#          custom targets that actually build the scripts,
#          basis_add_custom_finalize() has to be invoked.

macro (basis_add_scripts)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "COMPONENT" "" ${ARGN})

  if (ARGN_UNPARSED_ARGUMENTS)
    message ("Unknown arguments given for basis_add_scripts (): '${ARGN_UNPARSED_ARGUMENTS}'")
  endif ()

  if (ARGN_COMPONENT)
    set (COMPONENT "COMPONENT" "${ARGN_COMPONENT}")
  endif ()

  # add scripts with known extensions
  basis_add_scripts_by_extension (sh ${COMPONENT}) # shell scripts
  basis_add_scripts_by_extension (py ${COMPONENT}) # python scripts
  basis_add_scripts_by_extension (pl ${COMPONENT}) # Perl scripts
endmacro ()

##############################################################################
# @brief Finalize addition of custom targets.
#
# This function is called by basis_add_project_finalize() to finalize the
# addition of the custom build targets such as, for example, build targets
# to build script files, MATLAB Compiler targets, and MEX script generated
# MEX-files.
#
# @sa basis_add_script_finalize()
# @sa basis_add_mcc_target_finalize()
# @sa basis_add_mex_target_finalize()
#
# @returns Adds custom targets that actually build the executables and
#          libraries for which custom build targets where added by
#          basis_add_executable(), basis_add_library(), and basis_add_script().
#
# @ingroup CMakeUtilities

function (basis_add_custom_finalize)
  foreach (TARGET_UID ${BASIS_TARGETS})
    get_target_property (IMPORTED   ${TARGET_UID} "IMPORTED")
    if (NOT IMPORTED)
      get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")
      if (BASIS_TYPE MATCHES "SCRIPT$")
        basis_add_script_finalize (${TARGET_UID})
      elseif (BASIS_TYPE MATCHES "^MEX$")
        basis_add_mex_target_finalize (${TARGET_UID})
      elseif (BASIS_TYPE MATCHES "^MCC_")
        basis_add_mcc_target_finalize (${TARGET_UID})
      endif ()
    endif ()
  endforeach ()
endfunction ()

# ============================================================================
# exporting targets
# ============================================================================

##############################################################################
# @brief Get soname of object file.
#
# This function extracts the soname from object files in the ELF format on
# systems where the objdump command is available. On all other systems,
# an empty string is returned.
#
# @param [out] SONAME  The soname of the object file.
# @param [in]  OBJFILE Object file in ELF format.
#
# @ingroup CMakeUtilities

function (basis_get_soname SONAME OBJFILE)
  basis_target_uid (TARGET_UID ${OBJFILE})
  if (TARGET TARGET_UID)
    basis_get_target_location (OBJFILE ${TARGET_UID})
  else ()
    set (OBJFILE "${OBJ}")
  endif ()
  execute_process (
    COMMAND objdump -p "${OBJFILE}"
    COMMAND sed -n "-e's/^[[:space:]]*SONAME[[:space:]]*//p'"
    RESULT_VARIABLE STATUS
    OUTPUT_VARIABLE SONAME_OUT
    ERROR_QUIET
  )
  if (STATUS EQUAL 0)
    set (${SONAME} "${SONAME_OUT}" PARENT_SCOPE)
  else ()
    set (${SONAME} "" PARENT_SCOPE)
  endif ()
endfunction ()

##############################################################################
# @brief Export all targets added by basis_add_* commands.
#
# @ingroup CMakeUtilities

function (basis_export_targets)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "FILE;CUSTOM_FILE" "" ${ARGN})

  if (NOT ARGN_FILE)
    message (FATAL_ERROR "basis_export_targets(): FILE option is required!")
  endif ()
  if (NOT ARGN_CUSTOM_FILE)
    message (FATAL_ERROR "basis_export_targets(): CUSTOM_FILE option is required!")
  endif ()

  if (IS_ABSOLUTE ARGN_FILE)
    message (FATAL_ERROR "basis_export_targets(): FILE option argument must be a relative path!")
  endif ()
  if (IS_ABSOLUTE ARGN_CUSTOM_FILE)
    message (FATAL_ERROR "basis_export_targets(): CUSTOM_FILE option argument must be a relative path!")
  endif ()

  # --------------------------------------------------------------------------
  # export non-custom targets
  export (
    TARGETS   ${BASIS_EXPORT_TARGETS}
    FILE      "${PROJECT_BINARY_DIR}/${ARGN_FILE}"
  )
  foreach (COMPONENT "${BASIS_RUNTIME_COMPONENT}" "${BASIS_LIBRARY_COMPONENT}")
    install (
      EXPORT      "${PROJECT_NAME}"
      DESTINATION "${INSTALL_CONFIG_DIR}"
      FILE        "${ARGN_FILE}"
      COMPONENT   "${COMPONENT}"
    )
  endforeach ()

  # --------------------------------------------------------------------------
  # export custom targets

  if (BASIS_CUSTOM_EXPORT_TARGETS)

    # helper macros to avoid duplication of code
    # two version of exports file are created, one for the build tree and
    # one for the installation tree

    # header
    macro (header)
      set (C)
      set (C "# Generated by BASIS\n\n")
      set (C "${C}if (\"\${CMAKE_MAJOR_VERSION}.\${CMAKE_MINOR_VERSION}\" LESS 2.8)\n")
      set (C "${C}  message (FATAL_ERROR \"CMake >= 2.8.4 required\")\n")
      set (C "${C}endif ()\n")
      set (C "${C}cmake_policy (PUSH)\n")
      set (C "${C}cmake_policy (VERSION 2.8.4)\n")
      set (C "${C}#----------------------------------------------------------------\n")
      set (C "${C}# Generated CMake target import file.\n")
      set (C "${C}#----------------------------------------------------------------\n")
      set (C "${C}\n# Commands may need to know the format version.\n")
      set (C "${C}set (CMAKE_IMPORT_FILE_VERSION 1)\n")
    endmacro ()

    # create import targets
    macro (import_targets)
      foreach (T ${BASIS_CUSTOM_EXPORT_TARGETS})
        set (C "${C}\n# Create import target ${T}\n")
        get_target_property (BASIS_TYPE ${T} "BASIS_TYPE")
        if (BASIS_TYPE MATCHES "EXECUTABLE$|^SCRIPT$")
          set (C "${C}add_executable (${T} IMPORTED)\n")
        elseif (BASIS_TYPE MATCHES "LIBRARY$|^MODULE_SCRIPT$|^MEX$")
          get_target_property (TYPE "${T}" "BASIS_TYPE")
          string (REGEX REPLACE "_LIBRARY" "" TYPE "${BASIS_TYPE}")
          if (TYPE MATCHES "MEX|MCC")
            set (TYPE "SHARED")
          elseif (TYPE MATCHES "^MODULE_SCRIPT$")
            set (TYPE "UNKNOWN")
          endif ()
          set (C "${C}add_library (${T} ${TYPE} IMPORTED)\n")
        else ()
          set (C "${C}# WARNING: basis_export_targets(): Unknown target type")
        endif ()
      endforeach ()
    endmacro ()

    # set properties of imported targets
    macro (build_properties)
      foreach (CONFIG ${CMAKE_BUILD_TYPE})
        string (TOUPPER "${CONFIG}" CONFIG_UPPER)
        foreach (T ${BASIS_CUSTOM_EXPORT_TARGETS})
          set (C "${C}\n# Import target \"${T}\" for configuration \"${CONFIG}\"\n")
          set (C "${C}set_property (TARGET ${T} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${CONFIG})\n")
          basis_get_target_location (LOCATION ${T})
          if (BASIS_TYPE MATCHES "EXECUTABLE$|^SCRIPT$")
            set (C "${C}set_target_properties (${T} PROPERTIES\n")
            set (C "${C}  IMPORTED_LOCATION_${CONFIG_UPPER} \"${LOCATION}\"\n")
            set (C "${C}  )\n")
          elseif (BASIS_TYPE MATCHES "LIBRARY$|^MEX$")
            set (C "${C}set_target_properties (${T} PROPERTIES\n")
            set (C "${C}  IMPORTED_LINK_INTERFACE_LANGUAGES_${CONFIG_UPPER} \"CXX\"\n")
            set (C "${C}  IMPORTED_LOCATION_${CONFIG_UPPER} \"${LOCATION}\"\n")
            set (C "${C}  )\n")
          elseif (BASIS_TYPE MATCHES "^MODULE_SCRIPT$")
            set (C "${C}set_target_properties (${T} PROPERTIES\n")
            set (C "${C}  IMPORTED_LOCATION_${CONFIG_UPPER} \"${LOCATION}\"\n")
            set (C "${C}  )\n")
          endif ()
        endforeach ()
      endforeach ()
    endmacro ()

    macro (install_properties)
      foreach (CONFIG ${CMAKE_BUILD_TYPE})
        string (TOUPPER "${CONFIG}" CONFIG_UPPER)
        foreach (T ${BASIS_CUSTOM_EXPORT_TARGETS})
          set (C "${C}\n# Import target \"${T}\" for configuration \"${CONFIG}\"\n")
          set (C "${C}set_property (TARGET ${T} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${CONFIG})\n")
          basis_get_target_location (LOCATION ${T} POST_INSTALL_RELATIVE)
          if (BASIS_TYPE MATCHES "EXECUTABLE$|^SCRIPT$")
            set (C "${C}set_target_properties (${T} PROPERTIES\n")
            set (C "${C}  IMPORTED_LOCATION_${CONFIG_UPPER} \"\${_INSTALL_PREFIX}/${LOCATION}\"\n")
            set (C "${C}  )\n")
          elseif (BASIS_TYPE MATCHES "LIBRARY$|^MEX$")
            set (C "${C}set_target_properties (${T} PROPERTIES\n")
            set (C "${C}  IMPORTED_LINK_INTERFACE_LANGUAGES_${CONFIG_UPPER} \"CXX\"\n")
            set (C "${C}  IMPORTED_LOCATION_${CONFIG_UPPER} \"\${_INSTALL_PREFIX}/${LOCATION}\"\n")
            set (C "${C}  )\n")
          elseif (BASIS_TYPE MATCHES "^MODULE_SCRIPT$")
            set (C "${C}set_target_properties (${T} PROPERTIES\n")
            set (C "${C}  IMPORTED_LOCATION_${CONFIG_UPPER} \"\${_INSTALL_PREFIX}/${LOCATION}\"\n")
            set (C "${C}  )\n")
          endif ()
        endforeach ()
      endforeach ()
    endmacro ()

    # footer
    macro (footer)
      set (C "${C}\n# Commands beyond this point should not need to know the version.\n")
      set (C "${C}set (CMAKE_IMPORT_FILE_VERSION)\n")
      set (C "${C}cmake_policy (POP)\n")
    endmacro ()

    # DO NOT use '-' in the filename prefix for the custom exports.
    # Otherwise, it is automatically included by the exports file written
    # by CMake for the installation tree. This is, however, not the case
    # for the build tree. Therefore, we have to include the custom exports
    # file our selves in the use file.

    # HACK: For some reason, ARGV2 when used inside of basis_get_target_location()
    #       is set to the ARGV2 value of this function. This is probably a bug
    #       in CMake. However, I could not come up with a test that actually
    #       reproduces this error in a simpler use case. Thus, no bug report
    #       has been submitted.
    set (ARGV2)

    # write exports for build tree
    header ()
    import_targets ()
    build_properties ()
    footer ()

    file (WRITE "${PROJECT_BINARY_DIR}/${ARGN_CUSTOM_FILE}" "${C}")

    # write exports for installation
    header ()
    import_targets ()
    install_properties ()
    footer ()

    get_filename_component (TMP_FILE "${ARGN_CUSTOM_FILE}" NAME_WE)
    set (TMP_FILE "${TMP_FILE}.install")
    file (WRITE "${PROJECT_BINARY_DIR}/${TMP_FILE}" "${C}")
    install (
      FILES       "${PROJECT_BINARY_DIR}/${TMP_FILE}"
      DESTINATION "${INSTALL_CONFIG_DIR}"
      RENAME      "${ARGN_CUSTOM_FILE}"
    )

  endif ()
endfunction ()

##############################################################################
# @brief Replaces CMake's install() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:install

function (basis_install)
  install (${ARGN})
endfunction ()

## @}
