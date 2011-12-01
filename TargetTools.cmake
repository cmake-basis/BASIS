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

# ----------------------------------------------------------------------------
## @brief Set target property.
#
# This function is overwritten by BASIS in order to update the information
# about imported executable targets.
#
# @note Do not use this function in your CMakeLists.txt configuration files.
#       Use basis_set_target_properties() instead.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties
#
# @param [in] ARGN Arguments for set_target_properties().
function (set_target_properties)
  # target names
  list (FIND ARGN "PROPERTIES" IDX)
  if (IDX EQUAL -1)
    message (FATAL_ERROR "Missing PROPERTIES argument!")
  elseif (IDX EQUAL 0)
    message (FATAL_ERROR "No targets specified!")
  endif ()
  set (INDICES)
  set (I 0)
  while (I LESS IDX)
    list (APPEND INDICES ${I})
    math (EXPR I "${I} + 1")
  endwhile ()
  list (GET ARGN ${INDICES} TARGETS)
  # remaining arguments are property value pairs
  list (REMOVE_AT ARGN ${INDICES} ${IDX})
  # set target properties
  #
  # Note: By looping of the properties, the empty property values
  #       are correctly passed on to CMake's set_target_properties()
  #       command, while
  #       _set_target_properties(${TARGET_UIDS} PROPERTIES ${ARGN})
  #       (erroneously) discards the empty elements in ARGN.
  list (LENGTH ARGN N)
  while (N GREATER 1)
    list (GET ARGN 0 PROPERTY)
    list (GET ARGN 1 VALUE)
    list (REMOVE_AT ARGN 0 1)
    list (LENGTH ARGN N)
    # The following loop is only required b/c CMake's ARGV and ARGN
    # lists do not support arguments which are themselves lists.
    # Therefore, we need a way to decide when the list of values for a
    # property is terminated. We use here as a criteria the fact that
    # property names are generally all uppercase without whitespaces
    # while values will less likely follow this naming. As long as only one
    # value is given for a property, this will not affect anything.
    while (N GREATER 0)
      list (GET ARGN 0 ARG)
      if (ARG MATCHES "^[A-Z_]$")
        break ()
      endif ()
      list (APPEND VALUE "${ARG}")
      list (REMOVE_AT ARGN 0)
      list (LENGTH ARGN N)
    endwhile ()
    # check property name
    if ("${PROPERTY}" STREQUAL "")
      message (FATAL_ERROR "Empty property name given!")
    # if property is related to the location of an imported target,
    # update corresponding project properties
    elseif (PROPERTY MATCHES "^IMPORTED_LOCATION")
      list (GET TARGETS 0 TARGET)
      basis_update_imported_location (${TARGET} ${PROPERTY} "${VALUE}")
    # if property is related to the type of an imported target,
    # update corresponding project properties
    elseif (PROPERTY MATCHES "^BASIS_TYPE$")
      list (GET TARGETS 0 TARGET)
      basis_update_imported_type (${TARGET} "${VALUE}")
    endif ()
    # set target property
    _set_target_properties (${TARGETS} PROPERTIES ${PROPERTY} "${VALUE}")
  endwhile ()
  # make sure that every property had a corresponding value
  if (NOT N EQUAL 0)
    message (FATAL_ERROR "No value given for target property ${ARGN}")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Set properties on a target.
#
# This BASIS function replaces CMake's set_target_properties() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties
#
# @param [in] ARGN Arguments for set_target_properties().
#
# @returns Sets the specified properties on the given target.
function (basis_set_target_properties)
  # convert target names to UIDs
  set (TARGET_UIDS)
  list (GET ARGN 0 ARG)
  while (ARG AND NOT ARG MATCHES "^PROPERTIES$")
    basis_get_target_uid (TARGET_UID "${ARG}")
    list (APPEND TARGET_UIDS "${TARGET_UID}")
    list (REMOVE_AT ARGN 0)
    list (GET ARGN 0 ARG)
  endwhile ()
  if (NOT ARG MATCHES "^PROPERTIES$")
    message (FATAL_ERROR "Missing PROPERTIES argument!")
  elseif (NOT TARGET_UIDS)
    message (FATAL_ERROR "No targets specified!")
  endif ()
  # remove PROPERTIES keyword
  list (REMOVE_AT ARGN 0)
  # set target properties
  #
  # Note: By looping of the properties, the empty property values
  #       are correctly passed on to CMake's set_target_properties()
  #       command, while
  #       _set_target_properties(${TARGET_UIDS} PROPERTIES ${ARGN})
  #       (erroneously) discards the empty elements in ARGN.
  list (LENGTH ARGN N)
  while (N GREATER 1)
    list (GET ARGN 0 PROPERTY)
    list (GET ARGN 1 VALUE)
    list (REMOVE_AT ARGN 0 1)
    list (LENGTH ARGN N)
    # The following loop is only required b/c CMake's ARGV and ARGN
    # lists do not support arguments which are themselves lists.
    # Therefore, we need a way to decide when the list of values for a
    # property is terminated. We use here as a criteria the fact that
    # property names are generally all uppercase without whitespaces
    # while values will less likely follow this naming. As long as only one
    # value is given for a property, this will not affect anything.
    while (N GREATER 0)
      list (GET ARGN 0 ARG)
      if (ARG MATCHES "^[A-Z_]$")
        break ()
      endif ()
      list (APPEND VALUE "${ARG}")
      list (REMOVE_AT ARGN 0)
      list (LENGTH ARGN N)
    endwhile ()
    # check property name
    if ("${PROPERTY}" STREQUAL "")
      message (FATAL_ERROR "Empty property name given!")
    endif ()
    # set target property
    _set_target_properties (${TARGET_UIDS} PROPERTIES ${PROPERTY} "${VALUE}")
  endwhile ()
  # make sure that every property had a corresponding value
  if (NOT N EQUAL 0)
    message (FATAL_ERROR "No value given for target property ${ARGN}")
  endif ()
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
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")
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
# @brief Overwrites CMake's include_directories() command.
#
# The include_directories() command has to be overwritten such that when
# use files from other projects as for example ITK are included, we still
# get to know the paths added by these external projects which do not know
# about our own basis_include_directories() function.
#
# @param [in] ARGN All arguments are passed on to basis_include_directories().
macro (include_directories)
  basis_include_directories (${ARGN})
endmacro ()

##############################################################################
# @brief Replaces CMake's include_directories() command.
#
# All arguments are passed on to CMake's include_directories() command.
#
# Additionally, a list of all include directories used by a project is stored
# as project property (see basis_set_project_property()) named
# @c PROJECT_INCLUDE_DIRECTORIES.
#
# @param ARGN Argument list passed on to CMake's include_directories() command.
#
# @returns Nothing.

function (basis_include_directories)
  # CMake's include_directories ()
  _include_directories (${ARGN})

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "AFTER;BEFORE;SYSTEM" "" "" ${ARGN})

  # make relative paths absolute
  set (DIRS)
  foreach (P IN LISTS ARGN_UNPARSED_ARGUMENTS)
    get_filename_component (P "${P}" ABSOLUTE)
    list (APPEND DIRS "${P}")
  endforeach ()

  if (NOT DIRS)
    message (WARNING "basis_include_directories(): No directories given to add!")
  endif ()

  # append directories to "global" list of include directories
  basis_get_project_property (INCLUDE_DIRS PROPERTY PROJECT_INCLUDE_DIRS)
  list (APPEND INCLUDE_DIRS ${DIRS})
  if (INCLUDE_DIRS)
    list (REMOVE_DUPLICATES INCLUDE_DIRS)
  endif ()
  basis_set_project_property (PROPERTY PROJECT_INCLUDE_DIRS ${INCLUDE_DIRS})
endfunction ()

##############################################################################
# @brief Overwrites CMake's link_directories() command.
#
# The link_directories() command has to be overwritten such that when
# use files from other projects as for example ITK are included, we still
# get to know the paths added by these external projects which do not know
# about our own basis_link_directories() function.
#
# @param [in] ARGN All arguments are passed on to basis_link_directories().
macro (link_directories)
  basis_link_directories (${ARGN})
endmacro ()

##############################################################################
# @brief Replaces CMake's link_directories() command.
#
# All arguments are passed on to CMake's link_directories() command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories
#
# @param [in] ARGN Arguments for link_directories().
#
# @returns Nothing.

function (basis_link_directories)
  # CMake's link_directories()
  _link_directories (${ARGN})
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
    basis_get_target_uid (UID "${ARG}")
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
# build target names as used by BASIS (see basis_get_target_uid()).
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
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")

  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "basis_target_link_libraries(): Unknown target ${TARGET_UID}.")
  endif ()

  # get type of named target
  get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")

  # substitute non-fully qualified target names
  set (ARGS)
  foreach (ARG ${ARGN})
    basis_get_target_uid (UID "${ARG}")
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

    _set_target_properties (${TARGET_UID} PROPERTIES LINK_DEPENDS "${DEPENDS}")
  # other
  else ()
    target_link_libraries (${TARGET_UID} ${ARGS})
  endif ()
endfunction ()

# ============================================================================
# add targets
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add executable target.
#
# This BASIS function overwrites CMake's add_executable() command in order
# to store information of imported targets which is in particular used to
# generate the source code of the ExecutableTargetInfo modules which are
# part of the BASIS utilities.
#
# @note Use basis_add_executable() instead where possible!
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable
#
# @param [in] TARGET Name of the target.
# @param [in] ARGN   Further arguments of CMake's add_executable().
#
# @ingroup CMakeUtilities
function (add_executable TARGET)
  if (ARGC EQUAL 2 AND ARGV1 MATCHES "^IMPORTED$")
    _add_executable (${TARGET} IMPORTED)
    basis_add_imported_target ("${TARGET}" EXECUTABLE)
  else ()
    _add_executable (${TARGET} ${ARGN})
    basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET}")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add library target.
#
# This BASIS function overwrites CMake's add_library() command in order
# to store information of imported targets.
#
# @note Use basis_add_library() instead where possible!
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable
#
# @param [in] TARGET Name of the target.
# @param [in] ARGN   Further arguments of CMake's add_library().
#
# @ingroup CMakeUtilities
function (add_library TARGET)
  if (ARGC EQUAL 3 AND ARGV2 MATCHES "^IMPORTED$")
    _add_library (${TARGET} "${ARGV1}" IMPORTED)
    basis_add_imported_target ("${TARGET}" "${ARGV1}")
  else ()
    _add_library (${TARGET} ${ARGN})
    basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET}")
  endif ()
endfunction ()

##############################################################################
# @brief Replacement for CMake's add_executable() command.
#
# This function adds an executable target.
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
#     @tp <b>PYTHON</b>|<b>PERL</b>|<b>BASH</b> @endtp
#     <td>Executables written in one of the named scripting language are built by
#         configuring and/or copying the script files to the build tree and
#         installation tree, respectively. During the build step, certain strings
#         of the form \@VARIABLE\@ are substituted by the values set during the
#         configure step. How these CMake variables are set is specified by a
#         so-called script configuration file, which itself is a CMake script.</td>
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
# In case of CXX, the BASIS utilities library is added as link dependency of
# the added executable target by default. If none of the BASIS C++ utilities
# are used by the executable, the option NO_BASIS_UTILITIES can be given.
# Note, however, that the utilities library is a static library and thus the
# linker would not include any of the BASIS utilities object code in the binary
# executable in that case anyway.
#
# An install command for the added executable target is added by this function
# as well. The executable will be installed as part of the component @p COMPONENT
# in the directory @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR if the option
# @p LIBEXEC is given.
#
# @param [in] TARGET_NAME Name of the target. If the target is build from a
#                         single source file, the file path of this source file
#                         can be given as first argument. The build target name
#                         is then derived from the name of the source file.
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
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory relative to @c INSTALL_PREFIX.
#         If "none" (the case is ignored) is given as argument,
#         no installation rules are added for this executable target.
#         Default: @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR
#                  (if @p LIBEXEC is given).</td>
#   </tr>
#   <tr>
#     @tp @b LANGUAGE lang @endtp
#     <td>Source code language. By default determined from the extensions of
#         the given source files.</td>
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
#         with basis_add_test(). Test executables are output to the
#         binary testing tree and are not installed.</td>
#   </tr>
#   <tr>
#     @tp @b NO_BASIS_UTILITIES @endtp
#     <td>Do not add the BASIS C++ utilities as link dependency.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export the target.</td>
#   </tr>
#   <tr>
#     @tp @b WITH_PATH , @b WITH_EXT @endtp
#     <td>See documentation of basis_add_script().</td>
#   </tr>
#   <tr>
#     @tp @b CONFIG , @b CONFIG_FILE @endtp
#     <td>See documentation of basis_add_script().</td>
#   </tr>
# </table>
#
# @returns Adds an executable build target. In case of an executable build from
#          non-CXX source files, the function basis_add_custom_finalize() has to be
#          invoked to actually add the custom target that builds it.

function (basis_add_executable TARGET_NAME)
  # --------------------------------------------------------------------------
  # determine language
  CMAKE_PARSE_ARGUMENTS (ARGN "" "LANGUAGE" "" ${ARGN})

  if (NOT ARGN_LANGUAGE)

    CMAKE_PARSE_ARGUMENTS (
      TMP
      "LIBEXEC;TEST;MODULE;WITH_PATH;WITH_EXT;NO_BASIS_UTILITIES;NO_EXPORT"
      "BINARY_DIRECTORY;DESTINATION;COMPONENT;CONFIG;CONFIG_FILE"
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    if (NOT TMP_UNPARSED_ARGUMENTS)
      set (TMP_UNPARSED_ARGUMENTS "${TARGET_NAME}")
    endif ()

    basis_get_source_language (ARGN_LANGUAGE "${TMP_UNPARSED_ARGUMENTS}")
    if (ARGN_LANGUAGE MATCHES "AMBIGUOUS|UNKNOWN")
      message ("basis_add_executable(${TARGET_UID}): Given source code files: ${TMP_UNPARSED_ARGUMENTS}")
      if (ARGN_LANGUAGE MATCHES "AMBIGUOUS")
        message (FATAL_ERROR "basis_add_executable(${TARGET_UID}): Ambiguous source code files! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      elseif (ARGN_LANGUAGE MATCHES "UNKNOWN")
        message (FATAL_ERROR "basis_add_executable(${TARGET_UID}): Unknown source code language! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      endif ()
    endif ()
  endif ()
  string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)

  # --------------------------------------------------------------------------
  # C++
  if (ARGN_LANGUAGE MATCHES "CXX")

    basis_add_executable_target (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS})

  # --------------------------------------------------------------------------
  # MATLAB
  elseif (ARGN_LANGUAGE MATCHES "MATLAB")

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
#     <td>The default language, adding a library target build from C/C++
#         source code. The target is added via CMake's add_library() command
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
# An install command for the added library target is added by this function
# as well. Runtime libraries are installed as part of the @p RUNTIME_COMPONENT
# to the @p RUNTIME_DESTINATION. Library components are installed as part of
# the @p LIBRARY_COMPONENT to the @p LIBRARY_DESTINATION.
#
# Example:
# @code
# basis_add_library (MyLib1 STATIC mylib.cxx)
# basis_add_library (MyLib2 STATIC mylib.cxx COMPONENT dev)
#
# basis_add_library (
#   MyLib3 SHARED mylib.cxx
#   RUNTIME_COMPONENT bin
#   LIBRARY_COMPONENT dev
# )
#
# basis_add_library (MyMex MEX mymex.cxx)
# basis_add_library (PythonModule MyModule.py.in)
# basis_add_library (ShellModule MODULE MyModule.sh.in)
# @endcode
#
# @param [in] TARGET_NAME Name of the target. If the target is build from a
#                         single source file, the file path of this source file
#                         can be given as first argument. The build target name
#                         is then derived from the name of the source file.
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
  # --------------------------------------------------------------------------
  # determine language
  CMAKE_PARSE_ARGUMENTS (ARGN "" "LANGUAGE" "" ${ARGN})

  if (NOT ARGN_LANGUAGE)

    CMAKE_PARSE_ARGUMENTS (
      TMP
      "STATIC;SHARED;MODULE;MEX;TEST;WITH_PATH;NO_EXPORT"
      "BINARY_DIRECTORY;DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT;CONFIG;CONFIG_SCRIPT;MFILE"
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    if (NOT TMP_UNPARSED_ARGUMENTS)
      set (TMP_UNPARSED_ARGUMENTS "${TARGET_NAME}")
    endif ()

    basis_get_source_language (ARGN_LANGUAGE "${TMP_UNPARSED_ARGUMENTS}")
    if (ARGN_LANGUAGE MATCHES "AMBIGUOUS|UNKNOWN")
      message ("basis_add_library(${TARGET_UID}): Given source code files: ${TMP_UNPARSED_ARGUMENTS}")
      if (ARGN_LANGUAGE MATCHES "AMBIGUOUS")
        message (FATAL_ERROR "basis_add_library(${TARGET_UID}): Ambiguous source code files! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      elseif (ARGN_LANGUAGE MATCHES "UNKNOWN")
        message (FATAL_ERROR "basis_add_library(${TARGET_UID}): Unknown source code language! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      endif ()
    endif ()
  endif ()
  string (TOUPPER "${ARGN_LANGUAGE}" ARGN_LANGUAGE)

  # --------------------------------------------------------------------------
  # C++
  if (ARGN_LANGUAGE MATCHES "CXX")

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
  elseif (ARGN_LANGUAGE MATCHES "MATLAB")

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
# @param [in] TARGET_NAME Name of the target. If a source file is given
#                         as first argument, the build target name is derived
#                         from the name of this source file.
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
#         with basis_add_test(). Test executables are output to the
#         binary testing tree and are not installed.</td>
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
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
    "LIBEXEC;TEST;BASIS_UTILITIES;NO_BASIS_UTILITIES;NO_EXPORT"
    "DESTINATION;COMPONENT"
    ""
    ${ARGN}
  )

  set (SOURCES ${ARGN_UNPARSED_ARGUMENTS})

  get_filename_component (S "${TARGET_NAME}" ABSOLUTE)
  if (NOT SOURCES OR EXISTS "${S}")
    list (APPEND SOURCES "${TARGET_NAME}")
    basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME_WE)
  endif ()

  # check target name
  basis_check_target_name (${TARGET_NAME})
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")

  # whether or not to link to BASIS utilities
  set (NO_BASIS_UTILITIES "${BASIS_NO_BASIS_UTILITIES}")
  if (ARGN_NO_BASIS_UTILITIES)
    set (NO_BASIS_UTILITIES TRUE)
  endif ()
  if (ARGN_BASIS_UTILITIES)
    set (NO_BASIS_UTILITIES FALSE)
  endif ()

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

  # TEST implies non-LIBEXEC
  if (ARGN_TEST)
    set (ARGN_LIBEXEC 0)
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Adding executable ${TARGET_UID}...")
  endif ()

  # add standard auxiliary library
  if (NOT NO_BASIS_UTILITIES)
    set (BASIS_UTILITIES_TARGET "basis")
    if (BASIS_USE_FULLY_QUALIFIED_UIDS)
      set (BASIS_UTILITIES_TARGET "${BASIS_PROJECT_NAMESPACE_CMAKE}.${BASIS_UTILITIES_TARGET}")
    endif ()
    if (NOT TARGET ${BASIS_UTILITIES_TARGET} AND BASIS_UTILITIES_SOURCES)
      add_library (${BASIS_UTILITIES_TARGET} STATIC ${BASIS_UTILITIES_SOURCES})
      string (REGEX REPLACE "^.*\\." "" OUTPUT_NAME "${BASIS_UTILITIES_TARGET}")

      # define dependency on non-project specific utilities as the order in
      # which static libraries are listed on the command-line for the linker
      # matters; this will tell CMake to get the order right
      target_link_libraries (${BASIS_UTILITIES_TARGET} ${BASIS_UTILITIES_LIBRARY})

      _set_target_properties (
        ${BASIS_UTILITIES_TARGET}
        PROPERTIES
          BASIS_TYPE  "STATIC_LIBRARY"
          OUTPUT_NAME "${OUTPUT_NAME}"
          # make sure that this library is always output to the 'lib' directory
          # even if only test executables use it; see CMakeLists.txt in 'test'
          # subdirectory, which (re-)sets the CMAKE_*_OUTPUT_DIRECTORY variables.
          ARCHIVE_OUTPUT_DIRECTORY "${BASIS_BINARY_ARCHIVE_DIR}"
      )

      install (
        TARGETS ${BASIS_UTILITIES_TARGET}
        EXPORT  ${BASIS_PROJECT_NAME}
        ARCHIVE
          DESTINATION "${BASIS_INSTALL_ARCHIVE_DIR}"
          COMPONENT   "${BASIS_LIBRARY_COMPONENT}"
      )

      if (BASIS_DEBUG)
        message ("** Added BASIS utilities library ${BASIS_UTILITIES_TARGET}")
      endif ()
    endif ()
  endif ()

  # configure .in source files
  basis_configure_sources (SOURCES ${SOURCES})

  # add executable target
  add_executable (${TARGET_UID} ${SOURCES})

  basis_make_target_uid (HEADERS_TARGET headers)
  if (TARGET "${HEADERS_TARGET}")
    add_dependencies (${TARGET_UID} ${HEADERS_TARGET})
  endif ()

  _set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      BASIS_TYPE  "EXECUTABLE"
      OUTPUT_NAME "${TARGET_NAME}"
  )

  if (ARGN_LIBEXEC)
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        LIBEXEC                  1
        COMPILE_DEFINITIONS      "LIBEXEC"
        RUNTIME_OUTPUT_DIRECTORY "${BINARY_LIBEXEC_DIR}"
    )
  else ()
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        LIBEXEC 0
        RUNTIME_OUTPUT_DIRECTORY "${BINARY_RUNTIME_DIR}"
    )
  endif ()

  if (ARGN_TEST)
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        TEST                      1
        RUNTIME_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}"
    )
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES TEST 0)
  endif ()

  # add default link dependencies
  if (NOT ARGN_NO_BASIS_UTILITIES)
    # non-project specific utilities build as part of BASIS
    basis_target_link_libraries (${TARGET_UID} ${BASIS_UTILITIES_LIBRARY})
    # project specific utilities build as part of this project
    basis_target_link_libraries (${TARGET_UID} ${BASIS_UTILITIES_TARGET})
  endif ()

  # install executable
  if (ARGN_TEST)

    # TODO install (selected?) tests

  else ()

    if (ARGN_NO_EXPORT)
      set (EXPORT_OPT)
    else ()
      set (EXPORT_OPT "EXPORT" "${PROJECT_NAME}")
      basis_set_project_property (APPEND PROPERTY EXPORT_TARGETS "${TARGET_UID}")
    endif ()

    install (
      TARGETS     ${TARGET_UID} ${EXPORT_OPT}
      DESTINATION "${ARGN_DESTINATION}"
      COMPONENT   "${ARGN_COMPONENT}"
    )

    # set (custom) properties used by BASIS also for custom build targets
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        RUNTIME_INSTALL_DIRECTORY "${ARGN_DESTINATION}"
    )
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Adding executable ${TARGET_UID}... - done")
  endif ()
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
# @param [in] TARGET_NAME Name of the target. If a source file is given
#                         as first argument, the build target name is derived
#                         from the name of this source file.
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
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "STATIC;SHARED;MODULE;NO_EXPORT"
      "DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT"
      ""
    ${ARGN}
  )

  set (SOURCES ${ARGN_UNPARSED_ARGUMENTS})

  get_filename_component (S "${TARGET_NAME}" ABSOLUTE)
  if (NOT SOURCES OR EXISTS "${S}")
    list (APPEND SOURCES "${TARGET_NAME}")
    basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME_WE)
  endif ()

  # check target name
  basis_check_target_name (${TARGET_NAME})
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")

  # library type
  if (NOT ARGN_SHARED AND NOT ARGN_STATIC AND NOT ARGN_MODULE)
    if (BUILD_SHARED_LIBS)
      set (ARGN_SHARED 1)
    else ()
      set (ARGN_STATIC 1)
    endif ()
  endif ()

  # installation directories
  if (ARGN_DESTINATION)
    if (NOT ARGN_STATIC AND NOT ARGN_RUNTIME_DESTINATION)
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
    if (BASIS_VERBOSE)
      message (STATUS "Adding static library ${TARGET_UID}...")
    endif ()
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
    endif ()
    set (TYPE "STATIC")
  endif ()
  if (ARGN_SHARED)
    if (BASIS_VERBOSE)
      message (STATUS "Adding shared library ${TARGET_UID}...")
    endif ()
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
    endif ()
    set (TYPE "SHARED")
  endif ()
  if (ARGN_MODULE)
    if (BASIS_VERBOSE)
      message (STATUS "Adding module ${TARGET_UID}...")
    endif ()
    if (TYPE)
      message (FATAL_ERROR "More than one library type specified for target ${TARGET_UID}.")
    endif ()
    set (TYPE "MODULE")
  endif ()

  # configure .in source files
  basis_configure_sources (SOURCES ${SOURCES})

  # add library target
  add_library (${TARGET_UID} ${TYPE} ${SOURCES})

  basis_make_target_uid (HEADERS_TARGET headers)
  if (TARGET ${HEADERS_TARGET})
    add_dependencies (${TARGET_UID} ${HEADERS_TARGET})
  endif ()

  _set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      BASIS_TYPE "${TYPE}_LIBRARY"
      OUTPUT_NAME "${TARGET_NAME}"
      RUNTIME_OUTPUT_DIRECTORY "${BINARY_RUNTIME_DIR}"
      LIBRARY_OUTPUT_DIRECTORY "${BINARY_LIBRARY_DIR}"
      ARCHIVE_OUTPUT_DIRECTORY "${BINARY_ARCHIVE_DIR}"
  )

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
    basis_set_project_property (APPEND PROPERTY EXPORT_TARGETS "${TARGET_UID}")
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
  if (BASIS_VERBOSE)
    if (ARGN_STATIC)
      message (STATUS "Adding static library ${TARGET_UID}... - done")
    elseif (ARGN_SHARED)
      message (STATUS "Adding shared library ${TARGET_UID}... - done")
    elseif (ARGN_MODULE)
      message (STATUS "Adding module ${TARGET_UID}... - done")
    endif ()
  endif ()
endfunction ()

##############################################################################
# @brief Add script target.
#
#
# If the script name ends in ".in", the ".in" suffix is removed from the
# output name. Further, the extension of the script such as .sh or .py is
# removed from the output filename during the installation if the project
# is build on Unix-based systems and the script file contains a sha-bang
# directive, i.e., the first two characters on the first line are "#!"
# followed by the path to the script language interpreter. In case of script
# modules, the script file name extension is preserved, however.
#
# Example:
# @code
# basis_add_script (MyShellScript.sh.in)
# basis_add_script (Script Script1.sh)
# @endcode
#
# Certain CMake variables within the script are replaced during the configure step.
# See @ref ScriptTargets for details.
#
# Note that this function only configures the script file if it ends in the ".in"
# suffix and adds a custom target which stores all information required to setup
# the actual custom build command as properties. The custom build command itself
# is added by basis_add_script_finalize(), which is supposed to be called once at
# the end of the root CMakeLists.txt file. This way properties such as the
# @c OUTPUT_NAME can still be modified after adding the script target.
#
# @note This function should not be used directly. Instead, the functions
#       basis_add_executable() and basis_add_library() should be used which in
#       turn make use of this function if the (detected) programming language
#       is a (supported) scripting language.
#
# @sa basis_add_executable()
# @sa basis_add_library()
# @sa basis_add_script_finalize()
# @sa basis_add_custom_finalize()
#
# @param [in] TARGET_NAME Name of the target. If the target is build from a
#                         single source file, the file path of this source file
#                         can be given as first argument. The build target name
#                         is then derived from the name of the source file.
# @param [in] ARGN        This argument list is parsed and the following
#                         arguments are extracted:
# @par
# <table border="0">
#   <tr>
#      @tp @b COMPONENT name @endtp
#      <td>Name of the component. Default: @c BASIS_RUNTIME_COMPONENT for
#          executable scripts or @c BASIS_LIBRARY_COMPONENT for modules.</td>
#   </tr>
#   <tr>
#      @tp @b CONFIG config @endtp
#      <td>Additional script configuration given directly as string argument.
#          This string is included in the CMake build script before configuring
#          the script file after the script configuration files have been included.</td>
#   </tr>
#   <tr>
#      @tp @b CONFIG_FILE file @endtp
#      <td>Additional script configuration file. This file is included after
#          the default script configuration file of BASIS and after the default
#          script configuration file which is located in @c PROJECT_BINARY_DIR,
#          but before the script configuration code given by @p CONFIG.</td>
#   </tr>
#   <tr>
#      @tp @b DESTINATION dir @endtp
#      <td>The installation directory relative to @c INSTALL_PREFIX.
#          Default: @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR if
#                   the @p LIBEXEC option is given or @c INSTALL_LIBRARY_DIR
#                   if the @p MODULE option is given.</td>
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
#         with basis_add_test(). Test executables are output to the
#         binary testing tree and are not installed.</td>
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
#     @tp @b WITH_PATH @endtp
#     <td>Preserve relative path of module. Required for example for
#         Python and Perl packages where the directory hierarchy is important.</td>
#   </tr>
#   <tr>
#     @tp @b WITH_EXT @endtp
#     <td>Specify that the filename extension should be kept also in case of
#         an executable script with a sha-bang directive built on Unix.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export build target.</td>
#   </tr>
#   <tr>
#     @tp @b COMPILE | @c NOCOMPILE @endtp
#     <td>Enable/disable compilation of script if supported by scripting
#         language as well as BASIS. In particular, Python modules can be
#         compiled. If a script could be compiled by BASIS, only the
#         compiled file is installed. Default: @c BASIS_COMPILE_SCRIPTS</td>
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
      "LIBEXEC;TEST;MODULE;WITH_PATH;WITH_EXT;NO_EXPORT;COMPILE;NOCOMPILE"
      "BINARY_DIRECTORY;CONFIG;CONFIG_FILE;COMPONENT;DESTINATION"
      ""
    ${ARGN}
  )

  if (ARGN_COMPILE)
    set (COMPILE TRUE)
  elseif (ARGN_NOCOMPILE)
    set (COMPILE FALSE)
  else ()
    set (COMPILE "${BASIS_COMPILE_SCRIPTS}")
  endif ()

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
    if (ARGN_MODULE)
      basis_get_source_target_name (TARGET_NAME "${ARGN_SCRIPT}" NAME)
    else ()
      basis_get_source_target_name (TARGET_NAME "${ARGN_SCRIPT}" NAME_WE)
    endif ()
  endif ()

  # determine path part which is optionally prepended to the binary directory
  if (ARGN_WITH_PATH)
    get_filename_component (SCRIPT_PATH "${ARGN_SCRIPT}" PATH)
    if (IS_ABSOLUTE "${SCRIPT_PATH}")
      if (SCRIPT_PATH MATCHES "^${PROJECT_SOURCE_DIR}")
        basis_get_relative_path (SCRIPT_PATH "${CMAKE_CURRENT_SOURCE_DIR}" "${SCRIPT_PATH}")
      else ()
        set (SCRIPT_PATH)
      endif ()
    endif ()
  endif ()

  if (ARGN_MODULE AND ARGN_LIBEXEC)
    message (FATAL_ERROR "basis_add_script(${TARGET_UID}): Script cannot be MODULE and LIBEXEC at the same time!")
  endif ()

  if (ARGN_TEST)
    set (ARGN_LIBEXEC   FALSE)
    set (ARGN_NO_EXPORT TRUE)
  endif ()
  if (NOT ARGN_NO_EXPORT)
    set (ARGN_NO_EXPORT FALSE)
  endif ()

  if (NOT ARGN_COMPONENT)
    if (ARGN_MODULE)
      set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
    else ()
      set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
    endif ()
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")

  if (BASIS_VERBOSE)
    if (ARGN_MODULE)
      message (STATUS "Adding module script ${TARGET_UID}...")
    else ()
      message (STATUS "Adding executable script ${TARGET_UID}...")
    endif ()
  endif ()

  # make script file path absolute
  get_filename_component (ARGN_SCRIPT "${ARGN_SCRIPT}" ABSOLUTE)

  if (NOT EXISTS "${ARGN_SCRIPT}")
    set (ARGN_SCRIPT "${ARGN_SCRIPT}.in")
  endif ()
  if (NOT EXISTS "${ARGN_SCRIPT}")
    message (FATAL_ERROR "basis_add_script(${TARGET_UID}): Missing script file ${ARGN_SCRIPT}!")
  endif ()

  # "parse" script to check if BASIS utilities are used and hence required
  file (READ "${ARGN_SCRIPT}" SCRIPT)
  if (SCRIPT MATCHES "@BASIS_([A-Z]+)_UTILITIES@")
    basis_set_project_property (PROPERTY PROJECT_USES_${CMAKE_MATCH_1}_UTILITIES TRUE)
  endif ()
  set (SCRIPT)

  # get scripting language
  basis_get_source_language (SCRIPT_LANGUAGE "${ARGN_SCRIPT}")

  # get script name without ".in"
  get_filename_component (SCRIPT_NAME "${ARGN_SCRIPT}" NAME)
  string (REGEX REPLACE "\\.in$" "" SCRIPT_NAME "${SCRIPT_NAME}")

  # configure script file
  #
  # Note: This is the first pass, which replaces @NAME@ patterns as
  #       also done for other source files if the file name ends in ".in".
  #       The second pass is done during the build step, where
  #       %NAME% patterns are replaced using the variables set in the
  #       script configuration.
  if (ARGN_BINARY_DIRECTORY)
    basis_configure_sources (
      ARGN_SCRIPT
        "${ARGN_SCRIPT}"
      BINARY_DIRECTORY "${ARGN_BINARY_DIRECTORY}"
      KEEP_DOT_IN_SUFFIX
    )
  else ()
    basis_configure_sources (ARGN_SCRIPT "${ARGN_SCRIPT}" KEEP_DOT_IN_SUFFIX)
  endif ()

  # remove extension on Unix if sha-bang directive is present
  set (OUTPUT_NAME "${SCRIPT_NAME}")
  if (NOT ARGN_MODULE AND NOT ARGN_WITH_EXT AND UNIX)
    file (STRINGS "${ARGN_SCRIPT}" SHABANG LIMIT_COUNT 2 LIMIT_INPUT 2)
    if (SHABANG MATCHES "#!")
      get_filename_component (OUTPUT_NAME "${OUTPUT_NAME}" NAME_WE)
    endif ()
  endif ()

  # directory for build system files
  set (BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_UID}.dir")

  # binary directory
  if (ARGN_BINARY_DIRECTORY)
    set (BINARY_DIRECTORY "${ARGN_BINARY_DIRECTORY}")
  else ()
    set (BINARY_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
  endif ()

  # output directory
  if (ARGN_TEST)
    if (ARGN_MODULE)
      if (SCRIPT_LANGUAGE MATCHES "^PYTHON$")
        set (OUTPUT_DIRECTORY "${TESTING_PYTHON_LIBRARY_DIR}/sbia/${PROJECT_NAME_LOWER}")
      elseif (SCRIPT_LANGUAGE MATCHES "^PERL$")
        set (OUTPUT_DIRECTORY "${TESTING_PERL_LIBRARY_DIR}/SBIA/${PROJECT_NAME}")
      else ()
        set (OUTPUT_DIRECTORY "${TESTING_LIBRARY_DIR}")
      endif ()
    else ()
      set (OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")
    endif ()
  elseif (ARGN_MODULE)
    if (SCRIPT_LANGUAGE MATCHES "^PYTHON$")
      set (OUTPUT_DIRECTORY "${BINARY_PYTHON_LIBRARY_DIR}/sbia/${PROJECT_NAME_LOWER}")
    elseif (SCRIPT_LANGUAGE MATCHES "^PERL$")
      set (OUTPUT_DIRECTORY "${BINARY_PERL_LIBRARY_DIR}/SBIA/${PROJECT_NAME}")
    else ()
      set (OUTPUT_DIRECTORY "${BINARY_LIBRARY_DIR}")
    endif ()
  elseif (ARGN_LIBEXEC)
    set (OUTPUT_DIRECTORY "${BINARY_LIBEXEC_DIR}")
  else ()
    set (OUTPUT_DIRECTORY "${BINARY_RUNTIME_DIR}")
  endif ()
  if (SCRIPT_PATH AND ARGN_WITH_PATH)
    set (OUTPUT_DIRECTORY "${OUTPUT_DIRECTORY}/${SCRIPT_PATH}")
  endif ()

  # installation directory
  if (ARGN_DESTINATION)
    if (IS_ABSOLUTE "${ARGN_DESTINATION}")
      file (RELATIVE_PATH ARGN_DESTINATION "${INSTALL_PREFIX}" "${ARGN_DESTINATION}")
    endif ()
  else ()
    if (ARGN_TEST)
      set (ARGN_DESTINATION)
    elseif (ARGN_MODULE)
      if (SCRIPT_LANGUAGE MATCHES "^PYTHON$")
        set (ARGN_DESTINATION "${INSTALL_PYTHON_LIBRARY_DIR}/sbia/${PROJECT_NAME_LOWER}")
      elseif (SCRIPT_LANGUAGE MATCHES "^PERL$")
        set (ARGN_DESTINATION "${INSTALL_PERL_LIBRARY_DIR}/SBIA/${PROJECT_NAME}")
      else ()
        set (ARGN_DESTINATION "${INSTALL_LIBRARY_DIR}")
      endif ()
    elseif (ARGN_LIBEXEC)
      set (ARGN_DESTINATION "${INSTALL_LIBEXEC_DIR}")
    else ()
      set (ARGN_DESTINATION "${INSTALL_RUNTIME_DIR}")
    endif ()
    if (ARGN_DESTINATION AND SCRIPT_PATH AND ARGN_WITH_PATH)
      set (ARGN_DESTINATION "${ARGN_DESTINATION}/${SCRIPT_PATH}")
    endif ()
  endif ()

  # script configuration (only if script file name ends in ".in")
  set (INSTALL_DIR "${ARGN_DESTINATION}")

  if (ARGN_SCRIPT MATCHES "\\.in$")
    # Configure script configuration files using configure_file()
    # to have CMake create build rules to update the configured
    # file if the script configuration was modified.
    # The configured files are included by the build script that is
    # generated by basis_add_script_finalize().
    configure_file ("${BASIS_SCRIPT_CONFIG_FILE}" "${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake" @ONLY)
    if (EXISTS "${PROJECT_CONFIG_DIR}/ScriptConfig.cmake.in")
      configure_file ("${PROJECT_CONFIG_DIR}/ScriptConfig.cmake.in" "${BINARY_CONFIG_DIR}/ScriptConfig.cmake" @ONLY)
    endif ()
    if (ARGN_CONFIG_FILE)
      if (NOT EXISTS "${ARGN_CONFIG_FILE}")
        message (FATAL_ERROR "Script configuration file \"${ARGN_CONFIG_FILE}\" does not exist. It is required to build the script ${TARGET_UID}.")
      endif ()
      configure_file ("${ARGN_CONFIG_FILE}" "${BUILD_DIR}/ScriptConfig.cmake" @ONLY)
    endif ()
    # configure script configuration given as string
    if (ARGN_CONFIG)
      string (CONFIGURE ARGN_CONFIG "${ARGN_CONFIG}" @ONLY)
    endif ()
  elseif (ARGN_CONFIG OR ARGN_CONFIG_FILE)
    message (WARNING "Provided script configuration for ${TARGET_UID} but the script file "
                     "is missing a .in suffix. Will ignore script configuration and just "
                     "copy the script file as is without configuring it.")
    set (ARGN_CONFIG)
    set (ARGN_CONFIG_FILE)
  endif ()

  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${ARGN_SCRIPT})

  # set target properties required by basis_add_script_finalize ()
  if (ARGN_MODULE)
    set (TYPE "MODULE_SCRIPT")
  else ()
    set (TYPE "EXECUTABLE_SCRIPT")
  endif ()

  _set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      BASIS_TYPE                "${TYPE}"
      BASIS_LANGUAGE            "${SCRIPT_LANGUAGE}"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${BINARY_DIRECTORY}"
      RUNTIME_OUTPUT_DIRECTORY  "${OUTPUT_DIRECTORY}"
      LIBRARY_OUTPUT_DIRECTORY  "${OUTPUT_DIRECTORY}"
      RUNTIME_INSTALL_DIRECTORY "${ARGN_DESTINATION}"
      LIBRARY_INSTALL_DIRECTORY "${ARGN_DESTINATION}"
      OUTPUT_NAME               "${OUTPUT_NAME}"
      PREFIX                    ""
      SUFFIX                    ""
      COMPILE_DEFINITIONS       "${ARGN_CONFIG}"
      RUNTIME_COMPONENT         "${ARGN_COMPONENT}"
      LIBRARY_COMPONENT         "${ARGN_COMPONENT}"
      NO_EXPORT                 "${ARGN_NO_EXPORT}"
      COMPILE                   "${COMPILE}"
  )

  if (ARGN_TEST)
    _set_target_properties (${TARGET_UID} PROPERTIES TEST 1)
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES TEST 0)
  endif ()

  if (ARGN_LIBEXEC)
    _set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 1)
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 0)
  endif ()

  # add target to list of targets
  basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET_UID}")

  if (BASIS_VERBOSE)
    if (ARGN_MODULE)
      message (STATUS "Adding module script ${TARGET_UID}... - done")
    else ()
      message (STATUS "Adding executable script ${TARGET_UID}... - done")
    endif ()
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
  basis_get_target_uid (TARGET_UID "${TARGET_UID}")

  # already finalized before ?
  if (TARGET "_${TARGET_UID}")
    return ()
  endif ()

  # does this target exist ?
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown target ${TARGET_UID}.")
    return ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Adding build command for script ${TARGET_UID}...")
  endif ()

  # get target properties
  basis_get_target_name (TARGET_NAME ${TARGET_UID})

  set (
    PROPERTIES
      "BASIS_TYPE"
      "BASIS_LANGUAGE"
      "SOURCE_DIRECTORY"
      "BINARY_DIRECTORY"
      "RUNTIME_OUTPUT_DIRECTORY"
      "RUNTIME_INSTALL_DIRECTORY"
      "LIBRARY_OUTPUT_DIRECTORY"
      "LIBRARY_INSTALL_DIRECTORY"
      "PREFIX"
      "OUTPUT_NAME"
      "SUFFIX"
      "VERSION"
      "SOVERSION"
      "SOURCES"
      "COMPILE_DEFINITIONS"
      "RUNTIME_COMPONENT"
      "LIBRARY_COMPONENT"
      "LIBEXEC"
      "TEST"
      "NO_EXPORT"
      "COMPILE"
  )

  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()

  # check target type
  if (NOT BASIS_TYPE MATCHES "^EXECUTABLE_SCRIPT$|^MODULE_SCRIPT$")
    message (FATAL_ERROR "Target ${TARGET_UID} has invalid BASIS_TYPE: ${BASIS_TYPE}")
  endif ()

  if (BASIS_TYPE MATCHES "^MODULE_SCRIPT$")
    set (MODULE 1)
  else ()
    set (MODULE 0)
  endif ()

  # build directory (note that CMake returns basename of build directory as first element of SOURCES list)
  list (GET SOURCES 0 BUILD_DIR)
  set (BUILD_DIR "${BUILD_DIR}.dir")

  # binary directory
  if (NOT BINARY_DIRECTORY)
    message (FATAL_ERROR "basis_add_script_finalize(${TARGET_UID}): BINARY_DIRECTORY property not set!")
  endif ()
  if (NOT BINARY_DIRECTORY MATCHES "^${PROJECT_BINARY_DIR}")
    message (FATAL_ERROR "basis_add_script_finalize(${TARGET_UID}): BINARY_DIRECTORY must be inside of build tree!")
  endif ()

  # extract script file from SOURCES
  list (GET SOURCES 1 SCRIPT_FILE)

  # get script name without ".in"
  get_filename_component (SCRIPT_NAME "${SCRIPT_FILE}" NAME)
  string (REGEX REPLACE "\\.in$" "" SCRIPT_NAME "${SCRIPT_NAME}")

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

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
  # configured script file for build tree
  if (MODULE)
    set (CONFIGURED_FILE "${LIBRARY_OUTPUT_DIRECTORY}/${OUTPUT_NAME}")
  else ()
    set (CONFIGURED_FILE "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_NAME}")
  endif ()
  # final output script file for build tree
  set (OUTPUT_FILE "${CONFIGURED_FILE}")
  # configured script file for install tree
  set (CONFIGURED_INSTALL_FILE "${SCRIPT_FILE}")
  # final output script file for install tree
  set (INSTALL_FILE "${CONFIGURED_INSTALL_FILE}")
  set (INSTALL_NAME "${OUTPUT_NAME}")
  # output files of build command
  set (OUTPUT_FILES "${OUTPUT_FILE}")
  set (DEPENDS "${BUILD_SCRIPT}") # and script configuration files if used

  set (C "# DO NOT edit. This file was automatically generated by BASIS.\n")

  if (SCRIPT_FILE MATCHES "\\.in$")
    # make (configured) script configuration files a dependency
    list (APPEND DEPENDS "${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake")
    if (EXISTS "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
      list (APPEND DEPENDS "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
    endif ()
    if (EXISTS "${BUILD_DIR}/ScriptConfig.cmake")
      list (APPEND DEPENDS "${BUILD_DIR}/ScriptConfig.cmake")
    endif ()

    # additional output files
    set (TEMPLATE_FILE "${BUILD_DIR}/${SCRIPT_NAME}.in")
    list (APPEND OUTPUT_FILES "${TEMPLATE_FILE}")
    if (RUNTIME_INSTALL_DIRECTORY)
      set (CONFIGURED_INSTALL_FILE "${BINARY_DIRECTORY}/${SCRIPT_NAME}")
      set (INSTALL_FILE "${CONFIGURED_INSTALL_FILE}")
      list (APPEND OUTPUT_FILES "${CONFIGURED_INSTALL_FILE}")
    endif ()
    if (MODULE AND COMPILE AND BASIS_LANGUAGE MATCHES "PYTHON")
      # Python modules get optionally compiled
      get_filename_component (MODULE_PATH "${CONFIGURED_FILE}" PATH)
      get_filename_component (MODULE_NAME "${CONFIGURED_FILE}" NAME_WE)
      set (OUTPUT_FILE "${MODULE_PATH}/${MODULE_NAME}.pyc")
      list (APPEND OUTPUT_FILES "${OUTPUT_FILE}")
      # and the compiled module installed
      if (RUNTIME_INSTALL_DIRECTORY)
        get_filename_component (MODULE_PATH "${CONFIGURED_INSTALL_FILE}" PATH)
        get_filename_component (MODULE_NAME "${CONFIGURED_INSTALL_FILE}" NAME_WE)
        set (INSTALL_FILE "${MODULE_PATH}/${MODULE_NAME}.pyc")
        list (APPEND OUTPUT_FILES "${INSTALL_FILE}")
      endif ()
    endif ()

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # common code for build of build tree and install tree version

    # convert %NAME% patterns in script file to @NAME@
    set (C "${C}\n")
    set (C "${C}# convert %NAME% to \@NAME\@\n")
    set (C "${C}file (READ \"${SCRIPT_FILE}\" SCRIPT)\n")
    set (C "${C}string (REGEX REPLACE \"%([A-Z0-9_][A-Z0-9_]+)%\" \"\@\\\\1\@\" SCRIPT \"\${SCRIPT}\")\n")
    set (C "${C}file (WRITE \"${TEMPLATE_FILE}\" \"\${SCRIPT}\")\n")

    # tools for use in script configuration
    set (C "${C}\n")
    set (C "${C}# definitions of utility functions\n")
    set (C "${C}include (\"${BASIS_MODULE_PATH}/CommonTools.cmake\")\n")
    set (C "${C}\n")
    set (C "${C}function (basis_set_script_path VAR PATH)\n")
    set (C "${C}  if (ARGC GREATER 3)\n")
    set (C "${C}    message (FATAL_ERROR \"Too many arguments given for function basis_set_script_path()\")\n")
    set (C "${C}  endif ()\n")
    set (C "${C}  if (ARGC EQUAL 3 AND BUILD_INSTALL_SCRIPT)\n")
    set (C "${C}    set (PREFIX \"${INSTALL_PREFIX}\")\n")
    set (C "${C}    set (PATH   \"\${ARGV2}\")\n")
    set (C "${C}  else ()\n")
    set (C "${C}    set (PREFIX \"${PROJECT_SOURCE_DIR}\")\n")
    set (C "${C}  endif ()\n")
    set (C "${C}  if (NOT IS_ABSOLUTE \"\${PATH}\")\n")
    set (C "${C}    set (PATH \"\${PREFIX}/\${PATH}\")\n")
    set (C "${C}  endif ()\n")
    set (C "${C}  basis_get_relative_path (PATH \"\${DIR}\" \"\${PATH}\")\n")
    set (C "${C}  if (NOT PATH)\n")
    set (C "${C}    set (PATH \".\")\n")
    set (C "${C}  endif ()\n")
    set (C "${C}  string (REGEX REPLACE \"/$\" \"\" PATH \"\${PATH}\")\n")
    set (C "${C}  set (\${VAR} \"\${PATH}\" PARENT_SCOPE)\n")
    set (C "${C}endfunction ()\n")

    # common variables
    set (C "${C}\n")
    set (C "${C}# set script attributes\n")
    set (C "${C}set (LANGUAGE \"${BASIS_LANGUAGE}\")\n")
    set (C "${C}set (NAME \"${OUTPUT_NAME}\")\n")
    set (C "${C}string (TOUPPER \"\${NAME}\" NAME_UPPER)\n")
    set (C "${C}string (TOLOWER \"\${NAME}\" NAME_LOWER)\n")
    set (C "${C}get_filename_component (NAMESPACE \"\${NAME}\" NAME_WE)\n")
    set (C "${C}string (REGEX REPLACE \"[^a-zA-Z0-9]\" \"_\" NAMESPACE \"\${NAMESPACE}\")\n")
    set (C "${C}string (TOUPPER \"\${NAMESPACE}\" NAMESPACE_UPPER)\n")
    set (C "${C}string (TOLOWER \"\${NAMESPACE}\" NAMESPACE_LOWER)\n")

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # build script for build tree

    # script configuration code
    set (C "${C}\n")
    set (C "${C}# build script for use in build tree\n")
    set (C "${C}set (BUILD_INSTALL_SCRIPT 0)\n")
    if (MODULE)
      set (C "${C}set (DIR \"${LIBRARY_OUTPUT_DIRECTORY}\")\n")
    else ()
      set (C "${C}set (DIR \"${RUNTIME_OUTPUT_DIRECTORY}\")\n")
    endif ()
    set (C "${C}set (FILE \"\${DIR}/\${NAME}\")\n")
    set (C "${C}\n")
    set (C "${C}include (\"${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake\")\n")
    set (C "${C}include (\"${BINARY_CONFIG_DIR}/ScriptConfig.cmake\" OPTIONAL)\n")
    set (C "${C}include (\"${BUILD_DIR}/ScriptConfig.cmake\" OPTIONAL)\n")
    set (C "${C}\n")
    if (COMPILE_DEFINITIONS)
      set (C "${C}${COMPILE_DEFINITIONS}\n")
    endif ()
    # configure script for build tree
    set (C "${C}configure_file (\"${TEMPLATE_FILE}\" \"${CONFIGURED_FILE}\" @ONLY)\n")
    if (MODULE)
      # compile module if applicable
      if (COMPILE AND BASIS_LANGUAGE MATCHES "PYTHON")
        set (C "${C}execute_process (COMMAND \"${PYTHON_EXECUTABLE}\" -c \"import py_compile;py_compile.compile('${CONFIGURED_FILE}')\")\n")
        get_filename_component (MODULE_PATH "${CONFIGURED_FILE}" PATH)
        get_filename_component (MODULE_NAME "${CONFIGURED_FILE}" NAME_WE)
        set (OUTPUT_FILE "${MODULE_PATH}/${MODULE_NAME}.pyc")
        list (APPEND OUTPUT_FILES "${OUTPUT_FILE}")
      endif ()
    else ()
      # or set executable bit on Unix
      set (C "${C}\n")
      set (C "${C}if (UNIX)\n")
      set (C "${C}  execute_process (COMMAND /bin/chmod +x \"${CONFIGURED_FILE}\")\n")
      set (C "${C}endif ()\n")
    endif ()

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # build script for installation tree (optional)

    if (MODULE)
      set (INSTALL_DIR "${LIBRARY_INSTALL_DIRECTORY}")
    else ()
      set (INSTALL_DIR "${RUNTIME_INSTALL_DIRECTORY}")
    endif ()

    if (INSTALL_DIR)
      # script configuration code
      set (C "${C}\n")
      set (C "${C}# build script for use in installation tree\n")
      set (C "${C}set (BUILD_INSTALL_SCRIPT 1)\n")
      set (C "${C}set (DIR \"${CMAKE_INSTALL_PREFIX}/${INSTALL_DIR}\")\n")
      set (C "${C}set (FILE \"\${DIR}/\${NAME}\")\n")
      set (C "${C}\n")
      set (C "${C}include (\"${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake\")\n")
      set (C "${C}include (\"${BINARY_CONFIG_DIR}/ScriptConfig.cmake\" OPTIONAL)\n")
      set (C "${C}include (\"${BUILD_DIR}/ScriptConfig.cmake\" OPTIONAL)\n")
      set (C "${C}\n")
      if (COMPILE_DEFINITIONS)
        set (C "${C}${COMPILE_DEFINITIONS}\n")
      endif ()
      # configure script for installation tree
      set (C "${C}configure_file (\"${TEMPLATE_FILE}\" \"${CONFIGURED_INSTALL_FILE}\" @ONLY)\n")
      # compile module if applicable
      if (MODULE AND COMPILE AND BASIS_LANGUAGE MATCHES "PYTHON")
        set (C "${C}execute_process (COMMAND \"${PYTHON_EXECUTABLE}\" -c \"import py_compile;py_compile.compile('${CONFIGURED_INSTALL_FILE}')\")\n")
        get_filename_component (MODULE_PATH "${CONFIGURED_INSTALL_FILE}" PATH)
        get_filename_component (MODULE_NAME "${CONFIGURED_INSTALL_FILE}" NAME_WE)
        set (INSTALL_FILE "${MODULE_PATH}/${MODULE_NAME}.pyc")
        string (REGEX REPLACE "\\.py$" ".pyc" INSTALL_NAME "${INSTALL_NAME}")
        list (APPEND OUTPUT_FILES "${INSTALL_FILE}")
      endif ()
    endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # otherwise, just copy script file
  else ()
    set (C "${C}configure_file (\"${SCRIPT_FILE}\" \"${CONFIGURED_FILE}\" COPYONLY)\n")
    # compile module if applicable
    if (MODULE)
      if (COMPILE AND BASIS_LANGUAGE MATCHES "PYTHON")
        set (C "${C}execute_process (COMMAND \"${PYTHON_EXECUTABLE}\" -c \"import py_compile;py_compile.compile('${CONFIGURED_FILE}')\")\n")
        get_filename_component (MODULE_PATH "${CONFIGURED_FILE}" PATH)
        get_filename_component (MODULE_NAME "${CONFIGURED_FILE}" NAME_WE)
        set (INSTALL_FILE "${MODULE_PATH}/${MODULE_NAME}.pyc")
        string (REGEX REPLACE "\\.py$" ".pyc" INSTALL_NAME "${INSTALL_NAME}")
        list (APPEND OUTPUT_FILES "${INSTALL_FILE}")
      endif ()
    # or set executable bit on Unix
    else ()
      set (C "${C}\n")
      set (C "${C}if (UNIX)\n")
      set (C "${C}  execute_process (COMMAND /bin/chmod +x \"${CONFIGURED_FILE}\")\n")
      set (C "${C}endif ()\n")
    endif ()
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # create __init__.py files in build tree Python package
  set (INIT_PY)
  set (MAIN_INIT_PY)
  if (MODULE AND BASIS_LANGUAGE MATCHES "PYTHON" AND LIBRARY_OUTPUT_DIRECTORY MATCHES "^${BINARY_PYTHON_LIBRARY_DIR}/.+")
    set (D "${LIBRARY_OUTPUT_DIRECTORY}")
    while (NOT "${D}" STREQUAL "${BINARY_PYTHON_LIBRARY_DIR}")
      if (D MATCHES "sbia$")
        set (C "${C}file (WRITE \"${D}/__init__.py\" \"from pkgutil import extend_path\\n__path__ = extend_path(__path__, __name__)\\n\")\n")
        if (COMPILE)
          basis_set_if_empty (MAIN_INIT_PY "${D}/__init__.pyc")
        else ()
          basis_set_if_empty (MAIN_INIT_PY "${D}/__init__.py")
        endif ()
      else ()
        set (C "${C}execute_process (COMMAND \"${CMAKE_COMMAND}\" -E touch \"${D}/__init__.py\")\n")
        if (COMPILE)
          basis_set_if_empty (INIT_PY "${D}/__init__.pyc")
        else ()
          basis_set_if_empty (INIT_PY "${D}/__init__.py")
        endif ()
      endif ()
      if (COMPILE)
        set (C "${C}execute_process (COMMAND \"${PYTHON_EXECUTABLE}\" -c \"import py_compile;py_compile.compile('${D}/__init__.py')\")\n")
        list (APPEND OUTPUT_FILES "${D}/__init__.py" "${D}/__init__.pyc")
      else ()
        list (APPEND OUTPUT_FILES "${D}/__init__.py" "${D}/__init__.py")
      endif ()
      get_filename_component (D "${D}" PATH)
    endwhile ()
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # setup build commands

  # write/update build script
  if (EXISTS "${BUILD_SCRIPT}")
    file (WRITE "${BUILD_SCRIPT}.tmp" "${C}")
    execute_process (
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different
          "${BUILD_SCRIPT}" "${BUILD_SCRIPT}.tmp"
    )
    file (REMOVE "${BUILD_SCRIPT}.tmp")
  else ()
    file (WRITE "${BUILD_SCRIPT}" "${C}")
  endif ()

  # add custom target to execute build script
  file (RELATIVE_PATH REL "${CMAKE_BINARY_DIR}" "${OUTPUT_FILE}")

  add_custom_command (
    OUTPUT  ${OUTPUT_FILES}
    MAIN_DEPENDENCY "${SCRIPT_FILE}"
    DEPENDS ${DEPENDS}
    COMMAND "${CMAKE_COMMAND}" -P "${BUILD_SCRIPT}"
    COMMENT "Building script ${REL}..."
  )

  if (TARGET "_${TARGET_UID}")
    message (FATAL_ERROR "There is another target named _${TARGET_UID}. "
                         "BASIS uses target names starting with an underscore "
                         "for custom targets which are required to build script files. "
                         "Do not use leading underscores in target names.")
  endif ()

  # add custom target which triggers execution of build script
  add_custom_target (_${TARGET_UID} DEPENDS ${OUTPUT_FILES})
  add_dependencies (${TARGET_UID} _${TARGET_UID})

  # Provide target to build all scripts. In particular, scripts need to be build
  # before the doc target which thus depends on this target.
  if (NOT TARGET scripts)
    add_custom_target (scripts)
  endif ()
  add_dependencies (scripts _${TARGET_UID})

  # cleanup on "make clean"
  set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${OUTPUT_FILES})

  # install script
  if (NOT ARGN_NO_EXPORT AND NOT TEST)
    basis_set_project_property (APPEND PROPERTY CUSTOM_EXPORT_TARGETS "${TARGET_UID}")
  endif ()

  if (MODULE)
    if (LIBRARY_INSTALL_DIRECTORY)
      install (
        FILES       "${INSTALL_FILE}"
        RENAME      "${INSTALL_NAME}"
        DESTINATION "${LIBRARY_INSTALL_DIRECTORY}"
        COMPONENT   "${LIBRARY_COMPONENT}"
      )

      if (INIT_PY OR MAIN_INIT_PY)
        set (D "${LIBRARY_INSTALL_DIRECTORY}")
        while (NOT "${D}" STREQUAL "${INSTALL_PYTHON_LIBRARY_DIR}")
          if (D MATCHES "sbia$")
            install (
              FILES       "${MAIN_INIT_PY}"
              DESTINATION "${D}"
              COMPONENT   "${LIBRARY_COMPONENT}"
            )
          else ()
            install (
              FILES       "${INIT_PY}"
              DESTINATION "${D}"
              COMPONENT   "${LIBRARY_COMPONENT}"
            )
          endif ()
          get_filename_component (D "${D}" PATH)
        endwhile ()
      endif ()
    endif ()
  else ()
    if (RUNTIME_INSTALL_DIRECTORY)
      install (
        PROGRAMS    "${INSTALL_FILE}"
        RENAME      "${INSTALL_NAME}"
        DESTINATION "${RUNTIME_INSTALL_DIRECTORY}"
        COMPONENT   "${RUNTIME_COMPONENT}"
      )
    endif ()
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Adding build command for script ${TARGET_UID}... - done")
  endif ()
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
  basis_get_project_property (TARGETS PROPERTY TARGETS)
  foreach (TARGET_UID ${TARGETS})
    get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")
    if (BASIS_TYPE MATCHES "SCRIPT")
      basis_add_script_finalize (${TARGET_UID})
    elseif (BASIS_TYPE MATCHES "MEX")
      basis_add_mex_target_finalize (${TARGET_UID})
    elseif (BASIS_TYPE MATCHES "MCC")
      basis_add_mcc_target_finalize (${TARGET_UID})
    endif ()
  endforeach ()
endfunction ()

# ============================================================================
# importing targets
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add imported target.
#
# Imported targets are only valid in the scope where they were imported.
# In order to be able to add the information of the imported executable targets
# to the ExecutableTargetInfo modules of the BASIS utilities which are configured
# during the finalization of the (top-level) project, the information of
# imported targets has to be stored in the global scope. Therefore, internal
# cache variables prefixed by the name of the project are used
# (see basis_set_project_property()):
#
# - <Project>_IMPORTED_TARGETS   : List of imported targets.
# - <Project>_IMPORTED_TYPES     : Types of imported targets.
# - <Project>_IMPORTED_LOCATIONS : Locations of imported target files.
# - <Project>_IMPORTED_RANKS     : Rank of current imported locations. This rank
#                                  value is used to decide whether the current
#                                  location takes precedence over another imported
#                                  location. For example, IMPORTED_LOCATION_<a>,
#                                  may be preferred over IMPORTED_LOCATION_<b>.
#
# @sa basis_update_imported_location()
#
# @param [in] TARGET Name (UID) of the imported target.
# @param [in] TYPE   Type of the imported target.
function (basis_add_imported_target TARGET TYPE)
  # if target was added before
  basis_get_project_property (TARGETS PROPERTY IMPORTED_TARGETS)
  if (TARGETS)
    list (FIND TARGETS "${TARGET}" IDX)
    if (NOT IDX EQUAL -1)
      # do nothing
      return ()
    endif ()
  endif ()
  # otherwise, add it to the project properties
  basis_set_project_property (APPEND PROPERTY IMPORTED_TARGETS   "${TARGET}")
  basis_set_project_property (APPEND PROPERTY IMPORTED_TYPES     "${TYPE}")
  basis_set_project_property (APPEND PROPERTY IMPORTED_LOCATIONS "NOTFOUND")
  basis_set_project_property (APPEND PROPERTY IMPORTED_RANKS     10)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Update location of imported target.
#
# @param [in] TARGET     Name (UID) of the imported target.
# @param [in] PROPERTY   Target location property. Either IMPORTED_LOCATION
#                        or IMPORTED_LOCATION_<config>, where <config> is
#                        one of the imported build configurations.
#                        This argument is used to decide whether to keep
#                        the current target information or to replace it
#                        by the new one.
# @param [in] LOCATION   Location of imported target.
function (basis_update_imported_location TARGET PROPERTY LOCATION)
  # get index of imported target
  basis_get_project_property (TARGETS PROPERTY IMPORTED_TARGETS)
  list (FIND TARGETS "${TARGET}" IDX)
  if (IDX EQUAL -1)
    # imported targets have to be added via basis_add_imported_target() first
    # otherwise, ignore target here and do not update the non-existent information
    return ()
  endif ()
  # get current information of target
  basis_get_project_property (TYPES     PROPERTY IMPORTED_TYPES)
  basis_get_project_property (LOCATIONS PROPERTY IMPORTED_LOCATIONS)
  basis_get_project_property (RANKS     PROPERTY IMPORTED_RANKS)
  list (GET TYPES ${IDX} TYPE)
  list (GET RANKS ${IDX} CURRENT_RANK)
  # decide whether current information shall be overwritten
  string (TOUPPER "${CMAKE_BUILD_TYPE}" C)
  set (
    RANKING
      # first pick
      "IMPORTED_LOCATION_${C}"    # 0) prefer location corresponding to current configuration
      "IMPORTED_LOCATION"         # 1) then use non-configuration specific location
      "IMPORTED_LOCATION_RELEASE" # 2) otherwise use RELEASE version if available
      # 3) last pick, use first imported executable
  )
  list (FIND RANKING "${PROPERTY}" RANK)
  if (RANK EQUAL -1)
    set (RANK 3)
  endif ()
  # bail out if current information shall be kept
  if (NOT "${RANK}" LESS "${CURRENT_RANK}")
    return ()
  endif ()
  # remove current information
  list (REMOVE_AT TYPES     ${IDX})
  list (REMOVE_AT LOCATIONS ${IDX})
  list (REMOVE_AT RANKS     ${IDX})
  # add imported information
  list (LENGTH TYPES N)
  if (IDX LESS N)
    list (INSERT TYPES     ${IDX} "${TYPE}")
    list (INSERT LOCATIONS ${IDX} "${LOCATION}")
    list (INSERT RANKS     ${IDX} "${RANK}")
  else ()
    list (APPEND TYPES     "${TYPE}")
    list (APPEND LOCATIONS "${LOCATION}")
    list (APPEND RANKS     "${RANK}")
  endif ()
  # update project properties
  basis_set_project_property (PROPERTY IMPORTED_TYPES     "${TYPES}")
  basis_set_project_property (PROPERTY IMPORTED_LOCATIONS "${LOCATIONS}")
  basis_set_project_property (PROPERTY IMPORTED_RANKS     "${RANKS}")
endfunction ()

# ----------------------------------------------------------------------------
## @brief Update type of imported target.
#
# This function is in particular called in basis_set_target_properties()
# if the BASIS_TYPE property of custom BASIS targets is set after the
# imported target was added with the initial type UNKNOWN.
#
# @param [in] TARGET Name (UID) of the imported target.
# @param [in] TYPE   Type of imported target.
function (basis_update_imported_type TARGET TYPE)
  # get index of imported target
  basis_get_project_property (TARGETS PROPERTY IMPORTED_TARGETS)
  list (FIND TARGETS "${TARGET}" IDX)
  if (IDX EQUAL -1)
    # imported targets have to be added via basis_add_imported_target() first
    # otherwise, ignore target here and do not update the non-existent information
    return ()
  endif ()
  # get current type of imported target
  basis_get_project_property (TYPES PROPERTY IMPORTED_TYPES)
  list (GET TYPES ${IDX} CURRENT_TYPE)
  # bail out if current type shall be kept
  if (NOT CURRENT_TYPE MATCHES "^UNKNOWN$")
    return ()
  endif ()
  # replace current type
  list (REMOVE_AT TYPES ${IDX})
  list (LENGTH TYPES N)
  if (IDX LESS N)
    list (INSERT TYPES ${IDX} ${TYPE})
  else ()
    list (APPEND TYPES ${TYPE})
  endif ()
  # update project property
  basis_set_project_property (PROPERTY IMPORTED_TYPES "${TYPES}")
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
  basis_get_target_uid (TARGET_UID ${OBJFILE})
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

  basis_get_project_property (EXPORT_TARGETS PROPERTY EXPORT_TARGETS)

  if (EXPORT_TARGETS)
    if (BASIS_USE_FULLY_QUALIFIED_UIDS)
      set (NAMESPACE_OPT)
    else ()
      set (NAMESPACE_OPT NAMESPACE "${BASIS_PROJECT_NAMESPACE_CMAKE}.")
    endif ()

    export (
      TARGETS   ${EXPORT_TARGETS}
      FILE      "${PROJECT_BINARY_DIR}/${ARGN_FILE}"
      ${NAMESPACE_OPT}
    )
    foreach (COMPONENT "${BASIS_RUNTIME_COMPONENT}" "${BASIS_LIBRARY_COMPONENT}")
      install (
        EXPORT      "${PROJECT_NAME}"
        DESTINATION "${INSTALL_CONFIG_DIR}"
        FILE        "${ARGN_FILE}"
        COMPONENT   "${COMPONENT}"
        ${NAMESPACE_OPT}
      )
    endforeach ()
  endif ()

  # --------------------------------------------------------------------------
  # export custom targets

  basis_get_project_property (CUSTOM_EXPORT_TARGETS PROPERTY CUSTOM_EXPORT_TARGETS)

  if (CUSTOM_EXPORT_TARGETS)

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
      foreach (T ${CUSTOM_EXPORT_TARGETS})
        basis_get_fully_qualified_target_uid (UID "${T}")
        set (C "${C}\n# Create import target \"${UID}\"\n")
        get_target_property (BASIS_TYPE ${T} "BASIS_TYPE")
        if (BASIS_TYPE MATCHES "EXECUTABLE")
          set (C "${C}add_executable (${UID} IMPORTED)\n")
        elseif (BASIS_TYPE MATCHES "LIBRARY|MODULE_SCRIPT|MEX")
          string (REGEX REPLACE "_LIBRARY" "" TYPE "${BASIS_TYPE}")
          if (TYPE MATCHES "MEX|MCC")
            set (TYPE "SHARED")
          elseif (TYPE MATCHES "^MODULE_SCRIPT$")
            set (TYPE "UNKNOWN")
          endif ()
          set (C "${C}add_library (${UID} ${TYPE} IMPORTED)\n")
        else ()
          message (FATAL_ERROR "Cannot export target ${T} of type ${BASIS_TYPE}! Use NO_EXPORT option.")
        endif ()
        set (C "${C}set_target_properties (${UID} PROPERTIES BASIS_TYPE \"${BASIS_TYPE}\")\n")
      endforeach ()
    endmacro ()

    # set properties of imported targets
    macro (build_properties)
      foreach (CONFIG ${CMAKE_BUILD_TYPE})
        string (TOUPPER "${CONFIG}" CONFIG_UPPER)
        foreach (T ${CUSTOM_EXPORT_TARGETS})
          basis_get_fully_qualified_target_uid (UID "${T}")
          set (C "${C}\n# Import target \"${UID}\" for configuration \"${CONFIG}\"\n")
          set (C "${C}set_property (TARGET ${UID} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${CONFIG})\n")
          set (C "${C}set_target_properties (${UID} PROPERTIES\n")
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
        foreach (T ${CUSTOM_EXPORT_TARGETS})
          basis_get_fully_qualified_target_uid (UID "${T}")
          set (C "${C}\n# Import target \"${UID}\" for configuration \"${CONFIG}\"\n")
          set (C "${C}set_property (TARGET ${UID} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${CONFIG})\n")
          set (C "${C}set_target_properties (${UID} PROPERTIES\n")
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
      set (C "${C}\n# Cleanup temporary variables.\n")
      set (C "${C}set (_IMPORT_PREFIX)\n")
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


## @}
# Doxygen group
