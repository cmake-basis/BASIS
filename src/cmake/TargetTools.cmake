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
  if (BASIS_TYPE MATCHES "MCC|MEX")
    get_target_property (DEPENDS ${TARGET_UID} "LINK_DEPENDS")

    if (NOT DEPENDS)
      set (DEPENDS)
    endif ()
    list (APPEND DEPENDS ${ARGS})
 
    # pull implicit dependencies (e.g., ITK uses this)
    # note that MCC does itself a dependency check
    if (NOT BASIS_TYPE MATCHES "MCC")
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
    CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE
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
    CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE
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

  # --------------------------------------------------------------------------
  # determine language
  CMAKE_PARSE_ARGUMENTS (ARGN "" "LANGUAGE" "" ${ARGN})

  if (NOT ARGN_LANGUAGE)

    CMAKE_PARSE_ARGUMENTS (
      TMP
      "LIBEXEC;TEST;MODULE;NO_BASIS_UTILITIES;NO_EXPORT"
      "DESTINATION;COMPONENT;CONFIG;CONFIG_FILE"
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    basis_get_source_language (ARGN_LANGUAGE "${TMP_UNPARSED_ARGUMENTS}")
    if (ARGN_LANGUAGE STREQUAL "AMBIGUOUS")
      message (FATAL_ERROR "basis_add_executable(${TARGET_UID}): Ambiguous source code files! Try to set LANGUAGE manually.")
    elseif (ARGN_LANGUAGE STREQUAL "UNKNOWN")
      message (FATAL_ERROR "basis_add_executable(${TARGET_UID}): Unknown source code language! Try to set LANGUAGE manually.")
    endif ()
  endif ()
  string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)

  # --------------------------------------------------------------------------
  # C++
  if (ARGN_LANGUAGE STREQUAL "CXX")

    basis_add_executable_target (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS})

  # --------------------------------------------------------------------------
  # MATLAB
  elseif (ARGN_LANGUAGE STREQUAL "MATLAB")

    basis_add_mcc_target (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS} TYPE EXECUTABLE)

  # --------------------------------------------------------------------------
  # scripting language
  else ()
    CMAKE_PARSE_ARGUMENTS (ARGN "MODULE" "" "" ${ARGN_UNPARSED_ARGUMENTS})
    if (ARGN_MODULE)
      message (FATAL_ERROR "basis_add_executable(${TARGET_UID}): A MODULE cannot be an executable! Use basis_add_library() instead.")
    endif ()
    basis_add_script (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS})
  endif ()
endfunction ()

##############################################################################
# @brief Replaces CMake's add_library() command.
#
# This function adds a library target.
#
# An install command for the added library target is added by this function
# as well. Runtime libraries are installed as part of the @p RUNTIME_COMPONENT
# to the @p RUNTIME_DESTINATION. Library components are installed as part of
# the @p LIBRARY_COMPONENT to the @p LIBRARY_DESTINATION.
#
# Besides adding usual library targets built from C/C++ source code files,
# this function can also add custom build targets for libraries implemented
# in other programming languages. It therefore tries to detect the programming
# language of the given source code files and delegates the addition of the
# build target to the proper helper functions.
#
# In particular, the following languages are supported:
#
# <table border="0">
#   <tr>
#     @tp @b CXX @endtp
#     <td>The default language, adding an executable target build from C/C++
#         source code. The target is added via CMake's add_executable() command
#         if neither or one of the options STATIC, SHARED, or MODULE is given.
#         If the option MEX is given, a MEX-file is build using the MEX script.</td>
#   </tr>
#   <tr>
#     @tp <b>PYTHON</b>|<b>PERL</b>|<b>BASH</b> @endtp
#     <td>Modules written in one of the named scripting language are built similar
#         to executable scripts except that the file name extension is preserved
#         and no executable file permission is set. These modules are intended
#         for import/inclusion in other modules or executables written in the
#         particular scripting language only.</td>
#   </tr>
#   <tr>
#     @tp @b MATLAB @endtp
#     <td>Shared libraries built from MATLAB sources using the MATLAB Compiler (mcc).
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
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted:
# @par
# <table border="0">
#   <tr>
#     @tp @b LANGUAGE lang @endtp
#     <td>Source code language. By default determined from the extensions of
#         the given source code files.</td>
#   </tr>
#   <tr>
#     @tp <b>STATIC</b>|<b>SHARED</b>|<b>MODULE</b>|<b>MEX</b> @endtp
#     <td>Type of the library.</td>
#   </tr>
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
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export build target.</td>
#   </tr>
# </table>
#
# @returns Adds a library build target. In case of a library not written in
#          C/C++, basis_add_custom_finalize() has to be invoked to finalize
#          the addition of the build target(s).

function (basis_add_library TARGET_NAME)
  basis_check_target_name (${TARGET_NAME})
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # --------------------------------------------------------------------------
  # determine language
  CMAKE_PARSE_ARGUMENTS (ARGN "" "LANGUAGE" "" ${ARGN})

  if (NOT ARGN_LANGUAGE)

    CMAKE_PARSE_ARGUMENTS (
      TMP
      "STATIC;SHARED;MODULE;MEX;NO_EXPORT"
      "DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT"
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    basis_get_source_language (ARGN_LANGUAGE "${TMP_UNPARSED_ARGUMENTS}")
    if (ARGN_LANGUAGE STREQUAL "AMBIGUOUS")
      message (FATAL_ERROR "basis_add_library(${TARGET_UID}): Ambiguous source code files! Try to set LANGUAGE manually.")
    elseif (ARGN_LANGUAGE STREQUAL "UNKNOWN")
      message (FATAL_ERROR "basis_add_library(${TARGET_UID}): Unknown source code language! Try to set LANGUAGE manually.")
    endif ()
  endif ()
  string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)

  # --------------------------------------------------------------------------
  # C++
  if (ARGN_LANGUAGE STREQUAL "CXX")

    CMAKE_PARSE_ARGUMENTS (
      ARGN
      "MEX"
      ""
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    # MEX-file
    if (ARGN_MEX)

      CMAKE_PARSE_ARGUMENTS (
        ARGN
        ""
        "DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT"
        ""
        ${ARGN_UNPARSED_ARGUMENTS}
      )

      set (OPTS)
      if (ARGN_CXX_DESTINATION)
        list (APPEND OPTS "DESTINATION" "${ARGN_DESTINATION}")
      elseif (ARGN_RUNTIME_DESTINATION)
        list (APPEND OPTS "DESTINATION" "${ARGN_RUNTIME_DESTINATION}")
      endif ()
      if (ARGN_COMPONENT)
        list (APPEND OPTS "COMPONENT" "${ARGN_COMPONENT}")
      elseif (ARGN_RUNTIME_COMPONENT)
        list (APPEND OPTS "COMPONENT" "${ARGN_RUNTIME_COMPONENT}")
      endif ()

      basis_add_mex_target (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS} ${OPTS})

    # library
    else ()

      basis_add_library_target (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS})

    endif ()

  # --------------------------------------------------------------------------
  # MATLAB
  elseif (ARGN_LANGUAGE STREQUAL "MATLAB")

    CMAKE_PARSE_ARGUMENTS (
      ARGN
      "STATIC;SHARED;MODULE;MEX"
      ""
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    if (ARGN_STATIC OR ARGN_MODULE OR ARGN_MEX)
      message (FATAL_ERROR "basis_add_library(${TARGET_UID}): Invalid library type! Only shared libraries can be built by the MATLAB Compiler.")
    endif ()

    basis_add_mcc_target (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS} TYPE LIBRARY)

  # --------------------------------------------------------------------------
  # scripting language
  else ()

    CMAKE_PARSE_ARGUMENTS (
      ARGN
      "STATIC;SHARED;MODULE;MEX"
      ""
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    if (ARGN_STATIC OR ARGN_SHARED OR ARGN_MEX)
      message (FATAL_ERROR "basis_add_library(${TARGET_UID}): Invalid library type! Only modules can be built from scripts.")
    endif ()

    basis_add_script (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS} MODULE)
  endif ()
endfunction ()

##############################################################################
# @brief Adds an executable target built from C++ source code.
#
# This function adds an executable target for the build of an executable from
# C++ source code files.
#
# By default, the BASIS C++ utilities library is added as link dependency of
# the executable target. If none of the BASIS C++ utilities are used by the
# executable, the option NO_BASIS_UTILITIES can be given. Note, however,
# that the utilities library is a static library and thus the linker would
# simply not include any of the BASIS utilities object code in the final
# binary executable file.
#
# Further, an install command for the added executable target is added by
# this function. The executable will be installed as part of the component
# @p COMPONENT in the directory specified by the @p DESTINATION argument.
# This can be omitted by specifying "none" as argument for @p DESTINATION.
# An installation rule should then be added manually using the command
# basis_install() after the executable target was added.
#
# @note This function should not be used directly. Instead, it is called
#       by basis_add_executable() if the (detected) programming language
#       of the given source code files is @c CXX (i.e., C/C++).
#
# @sa basis_add_executable()
# @sa basis_install()
#
# @param [in] TARGET_NAME Name of executable target.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted, all other arguments are
#                         considered to be source code files and simply passed
#                         on to CMake's add_executable() command.
# @par
# <table border="0">
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory relative to @c INSTALL_PREFIX.
#         If "none" (the case is ignored) is given as argument,
#         no installation rules are added for this executable target.
#         Default: @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR
#                  (if @p LIBEXEC is given).</td>
#   </tr>
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of the component. Default: @c BASIS_RUNTIME_COMPONENT.</td>
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
# @returns Adds an executable build target built from C++ sources.
#
# @ingroup CMakeUtilities

function (basis_add_executable_target TARGET_NAME)
  basis_check_target_name (${TARGET_NAME})
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
    "LIBEXEC;TEST;NO_BASIS_UTILITIES;NO_EXPORT"
    "DESTINATION;COMPONENT"
    ""
    ${ARGN}
  )

  set (SOURCES ${ARGN_UNPARSED_ARGUMENTS})

  # component
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()

  # installation directory
  if (NOT ARGN_DESTINATION)
    if (ARGN_LIBEXEC)
      set (ARGN_DESTINATION "${INSTALL_LIBEXEC_DIR}")
    else ()
      set (ARGN_DESTINATION "${INSTALL_RUNTIME_DIR}")
    endif ()
  endif ()

  # TEST implies LIBEXEC
  if (ARGN_TEST)
    set (ARGN_LIBEXEC 0)
  endif ()

  message (STATUS "Adding executable ${TARGET_UID}...")

  # add standard auxiliary library
  if (NOT ARGN_NO_BASIS_UTILITIES)
    basis_target_uid (STDAUX stdaux)
    if (NOT TARGET ${STDAUX})
      basis_add_library (
        stdaux
        STATIC
          "${BINARY_CODE_DIR}/config.cc"
          "${BINARY_CODE_DIR}/stdaux.cc"
          "${BINARY_CODE_DIR}/ExecutableTargetInfo.cc"
      )

      # make sure that this library is always output to the 'lib' directory
      # even if only test executables use it; see CMakeLists.txt in 'test'
      # subdirectory, which (re-)sets the CMAKE_*_OUTPUT_DIRECTORY variables.
      basis_set_target_properties (
        stdaux
        PROPERTIES
          ARCHIVE_OUTPUT_DIRECTORY "${BINARY_ARCHIVE_DIR}"
      )
    endif ()
  endif ()

  # add executable target
  add_executable (${TARGET_UID} ${SOURCES})

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
    target_link_libraries (${TARGET_UID} "basis${BASIS_NAMESPACE_SEPARATOR}utils" ${STDAUX})
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
      DESTINATION "${ARGN_DESTINATION}"
      COMPONENT   "${ARGN_COMPONENT}"
    )

    # set (custom) properties used by BASIS also for custom build targets
    set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        RUNTIME_INSTALL_DIRECTORY "${ARGN_DESTINATION}"
    )
  endif ()

  message (STATUS "Adding executable ${TARGET_UID}... - done")
endfunction ()

##############################################################################
# @brief Add build target for library built from C++ source code.
#
# This function adds a library target which builds a library from C++ source
# code files.
#
# An install command for the added library target is added by this function
# as well. The runtime library, i.e., shared library or module, will be
# installed as part of the @p RUNTIME_COMPONENT in the directory specified
# by @p RUNTIME_DESTINATION. Static and import libraries will be installed
# as part of the LIBRARY_COMPONENT in the directory specified by the
# @p LIBRARY_DESTINATION. The installation of each of the library components
# can be omitted by giving "none" as argument for the destination parameters.
#
# @param [in] TARGET_NAME Name of the library target.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted. All other arguments are
#                         considered to be source code files and simply
#                         passed on to CMake's add_library() command.
# @par
# <table border="0">
#   <tr>
#     @tp <b>STATIC</b>|<b>SHARED</b>|<b>MODULE</b> @endtp
#     <td>Type of the library.</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory for runtime and library component
#         relative to @c INSTALL_PREFIX. See @p RUNTIME_DESTINATION
#         and @p LIBRARY_DESTINATION.</td>
#   </tr>
#   <tr>
#     @tp @b RUNTIME_DESTINATION dir @endtp
#     <td>Installation directory of the runtime component relative to
#         @c INSTALL_PREFIX. If "none" (case ignored) is given as argument,
#         no installation rule for the runtime library is not added.
#         Default: @c INSTALL_LIBRARY_DIR on Unix or @c INSTALL_RUNTIME_DIR
#         on Windows.</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_DESTINATION dir @endtp
#     <td>Installation directory of the library component relative to
#         @c INSTALL_PREFIX. If "none" (case ignored) is given as argument,
#         no installation rule for the library component is added.
#         Default: @c INSTALL_ARCHIVE_DIR.</td>
#   </tr>
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
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export build target.</td>
#   </tr>
# </table>
#
# @returns Adds a library build target.
#
# @ingroup CMakeUtilities

function (basis_add_library_target TARGET_NAME)
  basis_check_target_name (${TARGET_NAME})
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "STATIC;SHARED;MODULE;NO_EXPORT"
      "DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT"
      ""
    ${ARGN}
  )

  set (SOURCES ${ARGN_UNPARSED_ARGUMENTS})

  # library type
  if (NOT ARGN_SHARED AND NOT ARGN_STATIC AND NOT ARGN_MODULE)
    if (BUILD_SHARED_LIBS)
      set (ARGN_SHARED 1)
    else ()
      set (ARGN_STATIC 0)
    endif ()
  endif ()

  # installation directories
  if (ARGN_DESTINATION)
    if (NOT ARGN_RUNTIME_DESTINATION)
      set (ARGN_RUNTIME_DESTINATION "${ARGN_DESTINATION}")
    endif ()
    if (NOT ARGN_LIBRARY_DESTINATION)
      set (ARGN_LIBRARY_DESTINATION "${ARGN_DESTINATION}")
    endif ()
  endif ()
  if (NOT ARGN_RUNTIME_DESTINATION)
    set (ARGN_RUNTIME_DESTINATION "${INSTALL_RUNTIME_DIR}")
  endif ()
  if (NOT ARGN_LIBRARY_DESTINATION)
    set (ARGN_LIBRARY_DESTINATION "${INSTALL_LIBRARY_DIR}")
  endif ()

  if (ARGN_STATIC OR ARGN_RUNTIME_DESTINATION MATCHES "^none$|^None$|^NONE$")
    set (ARGN_RUNTIME_DESTINATION)
  endif ()
  if (ARGN_NO_EXPORT OR ARGN_LIBRARY_DESTINATION MATCHES "^none$|^None$|^NONE$")
    set (ARGN_LIBRARY_DESTINATION)
  endif ()

  # component
  if (ARGN_COMPONENT)
    if (NOT ARGN_RUNTIME_COMPONENT)
      set (ARGN_RUNTIME_COMPONENT "${ARGN_COMPONENT}")
    endif ()
    if (NOT ARGN_LIBRARY_COMPONENT)
      set (ARGN_LIBRARY_COMPONENT "${ARGN_COMPONENT}")
    endif ()
  endif ()
  if (NOT ARGN_RUNTIME_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_LIBRARY_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()

  # status message
  if (ARGN_STATIC)
    message (STATUS "Adding static library ${TARGET_UID}...")
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
    endif ()
    set (TYPE "STATIC")
  endif ()
  if (ARGN_SHARED)
    message (STATUS "Adding shared library ${TARGET_UID}...")
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
    endif ()
    set (TYPE "SHARED")
  endif ()
  if (ARGN_MODULE)
    message (STATUS "Adding module ${TARGET_UID}...")
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
    endif ()
    set (TYPE "MODULE")
  endif ()

  # add library target
  add_library (${TARGET_UID} ${TYPE} ${SOURCES})

  set_target_properties (${TARGET_UID} PROPERTIES BASIS_TYPE  "${TYPE}_LIBRARY")
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

  if (ARGN_RUNTIME_DESTINATION)
    install (
      TARGETS ${TARGET_UID} ${EXPORT_OPT}
      RUNTIME
        DESTINATION "${ARGN_RUNTIME_DESTINATION}"
        COMPONENT   "${ARGN_RUNTIME_COMPONENT}"
    )
  endif ()

  if (ARGN_LIBRARY_DESTINATION)
    install (
      TARGETS ${TARGET_UID} ${EXPORT_OPT}
      LIBRARY
        DESTINATION "${ARGN_LIBRARY_DESTINATION}"
        COMPONENT   "${ARGN_LIBRARY_COMPONENT}"
      ARCHIVE
        DESTINATION "${ARGN_LIBRARY_DESTINATION}"
        COMPONENT   "${ARGN_LIBRARY_COMPONENT}"
    )
  endif ()

  # done
  if (ARGN_STATIC)
    message (STATUS "Adding static library ${TARGET_UID}... - done")
  elseif (ARGN_SHARED)
    message (STATUS "Adding shared library ${TARGET_UID}... - done")
  elseif (ARGN_MODULE)
    message (STATUS "Adding module ${TARGET_UID}... - done")
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
#
# @ingroup CMakeUtilities

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
# step the script is configured via configure_file() and copied to the binary
# output directory. During installation, the script built for the install
# tree is copied to the specified @p DESTINATION.
#
# If the script name ends in ".in", the ".in" suffix is removed from the
# output name. Further, the extension of the script such as .sh or .py is
# removed from the output filename during the installation if the project
# is build on Unix-based systems and the script file contains a sha-bang
# directive, i.e., the first two characters on the first line are "#" followed
# by the path to the script language interpreter. In case of script modules,
# the script file name extension is preserved, however.
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
# @todo Install Perl modules (@b not scripts) to common directory, i.e.,
#       @c INSTALL_PREFIX /lib/perl5/<version>/, for example.
#       Consider further to install Perl modules into system default location.
#       For example, PERL_PRIVLIB directory as determined by FindPerlLibs module.
#
# @note This function should not be used directly. Instead, the functions
#       basis_add_executable() and basis_add_library() call this function if
#       the (detected) programming language is a (supported) scripting language.
#
# @sa basis_add_executable()
# @sa basis_add_library()
# @sa basis_add_script_finalize()
# @sa basis_add_custom_finalize()
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
#      @tp @b LIBEXEC @endtp
#      <td>Specifies that the script is an auxiliary executable, i.e., a script
#          which is called by other executables only.</td>
#   </tr>
#   <tr>
#     @tp @b TEST @endtp
#     <td>Specifies that the script is a test executable. Implies @p LIBEXEC.</td>
#   </tr>
#   <tr>
#      @tp @b MODULE @endtp
#      <td>Specifies that the script is a module file which is included by
#          other scripts. Implies @p LIBEXEC regarding installation directory and
#          preserves file name extension on all platforms. It can be used,
#          for example, for Python modules that are to be imported only by other
#          Python scripts.
#
#          Note that this option can also be used for arbitrary text files
#          which are used as input to a program, not only actual modules written
#          in a scripting language.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export build target.</td>
#   </tr>
# </table>
#
# @returns Adds custom build target @p TARGET_NAME. In order to add the
#          custom target that actually builds the script file,
#          basis_add_script_finalize() has to be invoked.
#
# @ingroup CMakeUtilities

function (basis_add_script TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "LIBEXEC;TEST;MODULE;NO_EXPORT"
      "CONFIG;CONFIG_FILE;COMPONENT;DESTINATION"
      ""
    ${ARGN}
  )

  list (LENGTH ARGN_UNPARSED_ARGUMENTS LEN)
  if (LEN EQUAL 0)
    set (ARGN_SCRIPT)
  elseif (LEN EQUAL 1)
    list (GET ARGN_UNPARSED_ARGUMENTS 0 ARGN_SCRIPT)
  else ()
    message (FATAL_ERROR "basis_add_script(${TARGET_UID}): Too many arguments! Only one script can be built by a script target.")
  endif ()

  if (NOT ARGN_SCRIPT)
    set (ARGN_SCRIPT "${TARGET_NAME}")
    basis_script_target_name (TARGET_NAME "${ARGN_SCRIPT}")
  endif ()

  if (ARGN_MODULE AND ARGN_TEST)
    message (FATAL_ERROR "basis_add_script(${TARGET_UID}): Script cannot be MODULE and TEST executable at the same time!")
  endif ()

  if (ARGN_MODULE OR ARGN_TEST)
    set (ARGN_LIBEXEC 1)
  endif ()

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (ARGN_DESTINATION)
    if (IS_ABSOLUTE "${ARGN_DESTINATION}")
      file (RELATIVE_PATH ARGN_DESTINATION "${INSTALL_PREFIX}" "${ARGN_DESTINATION}")
    endif ()
  else ()
    if (ARGN_TEST)
      set (ARGN_DESTINATION)
    elseif (ARGN_MODULE)
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

  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  if (ARGN_MODULE)
    message (STATUS "Adding module script ${TARGET_UID}...")
  else ()
    message (STATUS "Adding executable script ${TARGET_UID}...")
  endif ()

  # make script file path absolute
  get_filename_component (ARGN_SCRIPT "${ARGN_SCRIPT}" ABSOLUTE)

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
    message (FATAL_ERROR "basis_add_script(${TARGET_UID}): Missing script file ${ARGN_SCRIPT}!")
  endif ()

  # get script name without ".in"
  get_filename_component (SCRIPT_NAME_IN "${ARGN_SCRIPT}" NAME)
  string (REGEX REPLACE "\\.in$" "" SCRIPT_NAME "${SCRIPT_NAME_IN}")

  set (OUTPUT_NAME "${SCRIPT_NAME}")
  if (NOT ARGN_MODULE AND UNIX)
    file (STRINGS "${ARGN_SCRIPT}" SHABANG LIMIT_COUNT 2 LIMIT_INPUT 2)
    if (SHABANG STREQUAL "#!")
      get_filename_component (OUTPUT_NAME "${OUTPUT_NAME}" NAME_WE)
    endif ()
  endif ()

  # output directory
  if (ARGN_MODULE)
    set (OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
  elseif (ARGN_LIBEXEC)
    set (OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
  else ()
    set (OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
  endif ()

  # script configuration (only if script file name ends in ".in")
  set (INSTALL_DIR "${ARGN_DESTINATION}")
  set (SCRIPT_CONFIG)

  if (NOT SCRIPT_NAME STREQUAL SCRIPT_NAME_IN)
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
    set (TYPE "EXECUTABLE_SCRIPT")
  endif ()

  set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      BASIS_TYPE                "${TYPE}"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${CMAKE_CURRENT_BINARY_DIRECTORY}"
      RUNTIME_OUTPUT_DIRECTORY  "${OUTPUT_DIRECTORY}"
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

  if (ARGN_MODULE)
    message (STATUS "Adding module script ${TARGET_UID}... - done")
  else ()
    message (STATUS "Adding executable script ${TARGET_UID}... - done")
  endif ()
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
      "TEST"
  )

  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()

  # check target type
  if (NOT BASIS_TYPE MATCHES "^EXECUTABLE_SCRIPT$|^MODULE_SCRIPT$")
    message (FATAL_ERROR "Target ${TARGET_UID} has invalid BASIS_TYPE: ${BASIS_TYPE}")
  endif ()

  if (BASIS_TYPE MATCHES "^MODULE_SCRIPT$")
    set (NOEXEC 1)
  else ()
    set (NOEXEC 0)
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

  if (COMPILE_DEFINITIONS)
    basis_set_script_path_definition (FUNCTIONS)
    string (CONFIGURE "${FUNCTIONS}" FUNCTIONS @ONLY)

    if (RUNTIME_INSTALL_DIRECTORY)
      set (INSTALL_FILE "${BINARY_DIRECTORY}/${SCRIPT_NAME}")
      list (APPEND OUTPUT_FILES "${INSTALL_FILE}")
    endif ()

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
    if (RUNTIME_INSTALL_DIRECTORY)
      set (BUILD_COMMANDS "${BUILD_COMMANDS}\nset (BUILD_INSTALL_SCRIPT 1)\n")
      set (BUILD_COMMANDS "${BUILD_COMMANDS}set (SCRIPT_DIR \"${CMAKE_INSTALL_PREFIX}/${RUNTIME_INSTALL_DIRECTORY}\")\n")
      set (BUILD_COMMANDS "${BUILD_COMMANDS}set (NAME \"${OUTPUT_NAME}\")\n")
      set (BUILD_COMMANDS "${BUILD_COMMANDS}${COMPILE_DEFINITIONS}\n")
      set (BUILD_COMMANDS "${BUILD_COMMANDS}configure_file (\"${SCRIPT_FILE}\" \"${INSTALL_FILE}\" @ONLY)\n")
    endif ()
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
  if (RUNTIME_INSTALL_DIRECTORY)
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
  endif ()

  message (STATUS "Adding build command for script ${TARGET_UID}... - done")
endfunction ()

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
      if (BASIS_TYPE MATCHES "SCRIPT")
        basis_add_script_finalize (${TARGET_UID})
      elseif (BASIS_TYPE MATCHES "MEX")
        basis_add_mex_target_finalize (${TARGET_UID})
      elseif (BASIS_TYPE MATCHES "MCC")
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
  # get absolute path of object file
  basis_target_uid (TARGET_UID ${OBJFILE})
  if (TARGET TARGET_UID)
    basis_get_target_location (OBJFILE ${TARGET_UID} ABSOLUTE)
  else ()
    get_filename_component (OBJFILE "${OBJFILE}" ABSOLUTE)
  endif ()
  # usually CMake did this already
  find_program (CMAKE_OBJDUMP NAMES objdump DOC "The objdump command")
  # run objdump and extract soname
  execute_process (
    COMMAND ${CMAKE_OBJDUMP} -p "${OBJFILE}"
    COMMAND sed -n "-e's/^[[:space:]]*SONAME[[:space:]]*//p'"
    RESULT_VARIABLE STATUS
    OUTPUT_VARIABLE SONAME_OUT
    ERROR_QUIET
  )
  # return
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

    # compute installation prefix relative to INSTALL_CONFIG_DIR
    macro (prefix)
      set (C "${C}\n# Compute the installation prefix relative to this file.\n")
      set (C "${C}get_filename_component (_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\n")
      string (REGEX REPLACE "[/\\]" ";" DIRS "${INSTALL_CONFIG_DIR}")
      foreach (D ${DIRS})
        set (C "${C}get_filename_component (_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\n")
      endforeach ()
    endmacro ()

    # create import targets
    macro (import_targets)
      foreach (T ${BASIS_CUSTOM_EXPORT_TARGETS})
        set (C "${C}\n# Create import target ${T}\n")
        get_target_property (BASIS_TYPE ${T} "BASIS_TYPE")
        if (BASIS_TYPE MATCHES "EXECUTABLE")
          set (C "${C}add_executable (${T} IMPORTED)\n")
        elseif (BASIS_TYPE MATCHES "LIBRARY|MODULE_SCRIPT|MEX")
          string (REGEX REPLACE "_LIBRARY" "" TYPE "${BASIS_TYPE}")
          if (TYPE MATCHES "MEX|MCC")
            set (TYPE "SHARED")
          elseif (TYPE MATCHES "^MODULE_SCRIPT$")
            set (TYPE "UNKNOWN")
          endif ()
          set (C "${C}add_library (${T} ${TYPE} IMPORTED)\n")
        else ()
          message (FATAL_ERROR "Cannot export target ${T} of type ${BASIS_TYPE}! Use NO_EXPORT option.")
        endif ()
        set (C "${C}set_target_properties (${T} PROPERTIES BASIS_TYPE \"${BASIS_TYPE}\")\n")
      endforeach ()
    endmacro ()

    # set properties of imported targets
    macro (build_properties)
      foreach (CONFIG ${CMAKE_BUILD_TYPE})
        string (TOUPPER "${CONFIG}" CONFIG_UPPER)
        foreach (T ${BASIS_CUSTOM_EXPORT_TARGETS})
          set (C "${C}\n# Import target \"${T}\" for configuration \"${CONFIG}\"\n")
          set (C "${C}set_property (TARGET ${T} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${CONFIG})\n")
          set (C "${C}set_target_properties (${T} PROPERTIES\n")
          basis_get_target_location (LOCATION ${T} ABSOLUTE)
          set (C "${C}  IMPORTED_LOCATION_${CONFIG_UPPER} \"${LOCATION}\"\n")
          if (BASIS_TYPE MATCHES "LIBRARY|MEX")
            set (C "${C}  IMPORTED_LINK_INTERFACE_LANGUAGES_${CONFIG_UPPER} \"CXX\"\n")
          endif ()
          set (C "${C}  )\n")
        endforeach ()
      endforeach ()
    endmacro ()

    macro (install_properties)
      foreach (CONFIG ${CMAKE_BUILD_TYPE})
        string (TOUPPER "${CONFIG}" CONFIG_UPPER)
        foreach (T ${BASIS_CUSTOM_EXPORT_TARGETS})
          set (C "${C}\n# Import target \"${T}\" for configuration \"${CONFIG}\"\n")
          set (C "${C}set_property (TARGET ${T} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${CONFIG})\n")
          set (C "${C}set_target_properties (${T} PROPERTIES\n")
          basis_get_target_location (LOCATION ${T} POST_INSTALL_RELATIVE)
          set (C "${C}  IMPORTED_LOCATION_${CONFIG_UPPER} \"\${_IMPORT_PREFIX}/${LOCATION}\"\n")
          if (BASIS_TYPE MATCHES "LIBRARY|MEX")
            set (C "${C}  IMPORTED_LINK_INTERFACE_LANGUAGES_${CONFIG_UPPER} \"CXX\"\n")
          endif ()
          set (C "${C}  )\n")
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

    # write exports for build tree
    header ()
    import_targets ()
    build_properties ()
    footer ()

    file (WRITE "${PROJECT_BINARY_DIR}/${ARGN_CUSTOM_FILE}" "${C}")

    # write exports for installation
    header ()
    prefix ()
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
