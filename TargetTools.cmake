##############################################################################
# @file  TargetTools.cmake
# @brief Functions and macros to add executable and library targets.
#
# Copyright (c) 2011-2012, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
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


## @addtogroup CMakeUtilities
#  @{


# ============================================================================
# properties
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Set properties on a target.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties">
# set_target_properties()</a> command and extends its functionality.
# In particular, it maps the given target names to the corresponding target UIDs.
#
# @note Due to a bug in CMake (http://www.cmake.org/Bug/view.php?id=12303),
#       except of the first property given directly after the @c PROPERTIES keyword,
#       only properties listed in @c BASIS_PROPERTIES_ON_TARGETS can be set.
#
# @param [in] ARGN List of arguments. See
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties">
#                  set_target_properties()</a>.
#
# @returns Sets the specified properties on the given target.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties
#
# @ingroup CMakeAPI
function (basis_set_target_properties)
  # convert target names to UIDs
  set (TARGET_UIDS)
  list (LENGTH ARGN N)
  if (N EQUAL 0)
    message (FATAL_ERROR "basis_set_target_properties(): Missing arguments!")
  endif ()
  list (GET ARGN 0 ARG)
  while (NOT ARG MATCHES "^PROPERTIES$")
    basis_get_target_uid (TARGET_UID "${ARG}")
    list (APPEND TARGET_UIDS "${TARGET_UID}")
    list (REMOVE_AT ARGN 0)
    list (LENGTH ARGN N)
    if (N EQUAL 0)
      break ()
    else ()
      list (GET ARGN 0 ARG)
    endif ()
  endwhile ()
  if (NOT ARG MATCHES "^PROPERTIES$")
    message (FATAL_ERROR "Missing PROPERTIES argument!")
  elseif (NOT TARGET_UIDS)
    message (FATAL_ERROR "No target specified!")
  endif ()
  # remove PROPERTIES keyword
  list (REMOVE_AT ARGN 0)
  math (EXPR N "${N} - 1")
  # set targets properties
  #
  # Note: By iterating over the properties, the empty property values
  #       are correctly passed on to CMake's set_target_properties()
  #       command, while
  #       _set_target_properties(${TARGET_UIDS} PROPERTIES ${ARGN})
  #       (erroneously) discards the empty elements in ARGN.
  if (BASIS_DEBUG)
    message ("** basis_set_target_properties:")
    message ("**   Target(s):  ${TARGET_UIDS}")
    message ("**   Properties: [${ARGN}]")
  endif ()
  while (N GREATER 1)
    list (GET ARGN 0 PROPERTY)
    list (GET ARGN 1 VALUE)
    list (REMOVE_AT ARGN 0 1)
    list (LENGTH ARGN N)
    # The following loop is only required b/c CMake's ARGV and ARGN
    # lists do not support arguments which are themselves lists.
    # Therefore, we need a way to decide when the list of values for a
    # property is terminated. Hence, we only allow known properties
    # to be set, except for the first property where the name follows
    # directly after the PROPERTIES keyword.
    while (N GREATER 0)
      list (GET ARGN 0 ARG)
      if (ARG MATCHES "${BASIS_PROPERTIES_ON_TARGETS_REGEX}")
        break ()
      endif ()
      list (APPEND VALUE "${ARG}")
      list (REMOVE_AT ARGN 0)
      list (LENGTH ARGN N)
    endwhile ()
    if (BASIS_DEBUG)
      message ("**   -> ${PROPERTY} = [${VALUE}]")
    endif ()
    # check property name
    if (PROPERTY MATCHES "^$") # remember: STREQUAL is buggy and evil!
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

# ----------------------------------------------------------------------------
## @brief Get value of property set on target.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_target_properties">
# get_target_properties()</a> command and extends its functionality.
# In particular, it maps the given @p TARGET_NAME to the corresponding target UID.
#
# @param [out] VAR         Name of output variable.
# @param [in]  TARGET_NAME Name of build target.
# @param [in]  ARGN        Remaining arguments for
#                          <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_target_properties">
#                          get_target_properties()</a>.
#
# @returns Sets @p VAR to the value of the requested property.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_target_property
#
# @ingroup CMakeAPI
function (basis_get_target_property VAR TARGET_NAME)
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")
  get_target_property (VALUE "${TARGET_UID}" ${ARGN})
  set (${VAR} "${VALUE}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# definitions
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add compile definitions.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_definitions">
# add_definitions()</a> command.
#
# @param [in] ARGN List of arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_definitions">
#                  add_definitions()</a>.
#
# @returns Adds the given definitions.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_definitions
#
# @ingroup CMakeAPI
function (basis_add_definitions)
  add_definitions (${ARGN})
endfunction ()

# ----------------------------------------------------------------------------
## @brief Remove previously added compile definitions.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:remove_definitions">
# remove_definitions()</a> command.
#
# @param [in] ARGN List of arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:remove_definitions">
#                  remove_definitions()</a>.
#
# @returns Removes the specified definitions.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:remove_definition
#
# @ingroup CMakeAPI
function (basis_remove_definitions)
  remove_definitions (${ARGN})
endfunction ()

# ============================================================================
# directories
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add directories to search path for include files.
#
# Overwrites CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories">
# include_directories()</a> command. This is required because the
# basis_include_directories() function is not used by other projects in their
# package use files. Therefore, this macro is an alias for
# basis_include_directories().
#
# @param [in] ARGN List of arguments for basis_include_directories().
#
# @returns Adds the given paths to the search path for include files.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories
macro (include_directories)
  basis_include_directories (${ARGN})
endmacro ()

# ----------------------------------------------------------------------------
## @brief Add directories to search path for include files.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories">
# include_directories()</a> command. Besides invoking CMake's internal command
# with the given arguments, it updates the @c PROJECT_INCLUDE_DIRECTORIES
# property on the current project (see basis_set_project_property()). This list
# contains a list of all include directories used by a project, regardless of
# the directory in which the basis_include_directories() function was used.
#
# @param ARGN List of arguments for
#             <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories">
#             include_directories()</a> command.
#
# @returns Nothing.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:include_directories
#
# @ingroup CMakeAPI
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
  if (BEFORE)
    list (INSERT INCLUDE_DIRS 0 ${DIRS})
  else ()
    list (APPEND INCLUDE_DIRS ${DIRS})
  endif ()
  if (INCLUDE_DIRS)
    list (REMOVE_DUPLICATES INCLUDE_DIRS)
  endif ()
  if (BASIS_DEBUG)
    message ("** basis_include_directories():")
    if (BEFORE)
      message ("**    Add before:  ${DIRS}")
    else ()
      message ("**    Add after:   ${DIRS}")
    endif ()
    if (BASIS_VERBOSE)
      message ("**    Directories: ${INCLUDE_DIRS}")
    endif ()
  endif ()
  basis_set_project_property (PROPERTY PROJECT_INCLUDE_DIRS ${INCLUDE_DIRS})
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add directories to search path for libraries.
#
# Overwrites CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories">
# link_directories()</a> command. This is required because the
# basis_link_directories() function is not used by other projects in their
# package use files. Therefore, this macro is an alias for
# basis_link_directories().
#
# @param [in] ARGN List of arguments for basis_link_directories().
#
# @returns Adds the given paths to the search path for libraries.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories
macro (link_directories)
  basis_link_directories (${ARGN})
endmacro ()

# ----------------------------------------------------------------------------
## @brief Add directories to search path for libraries.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories">
# link_directories()</a> command. Even though this function yet only invokes
# CMake's internal command, it should be used in BASIS projects to enable the
# extension of this command's functionality as part of BASIS if required.
#
# @param [in] ARGN List of arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories">
#                  link_directories()</a>.
#
# @returns Adds the given paths to the search path for libraries.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:link_directories
#
# @ingroup CMakeAPI
function (basis_link_directories)
  # CMake's link_directories() command
  _link_directories (${ARGN})
endfunction ()

# ============================================================================
# dependencies
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add dependencies to build target.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_dependencies">
# add_dependencies()</a> command and extends its functionality.
# In particular, it maps the given target names to the corresponding target UIDs.
#
# @param [in] ARGN Arguments for
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_dependencies">
#                  add_dependencies()</a>.
#
# @returns Adds the given dependencies of the specified build target.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_dependencies
#
# @ingroup CMakeAPI
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

# ----------------------------------------------------------------------------
## @brief Add link dependencies to build target.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:target_link_libraries">
# target_link_libraries()</a> command.
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
# @param [in] TARGET_NAME Name of the target.
# @param [in] ARGN        Link libraries.
#
# @returns Adds link dependencies to the specified build target.
#          For custom targets, the given libraries are added to the
#          @c DEPENDS property of these target, in particular.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:target_link_libraries
#
# @ingroup CMakeAPI
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
# This is the main function to add an executable target to the build system,
# where an executable can be a binary file or a script written in a scripting
# language. In general we refer to any output file which is part of the software
# (i.e., excluding configuration files) and which can be executed
# (e.g., a binary file in the ELF format) or interpreted (e.g., a BASH script)
# directly, as executable file. Natively, CMake supports only executables build
# from C/C++ source code files. This function extends CMake's capabilities
# by adding custom build commands for non-natively supported programming
# languages and further standardizes the build of executable targets.
# For example, by default, it is not necessary to specify installation rules
# separately as these are added by this function already (see below).
#
# @par Programming languages
# Besides adding usual executable targets build by the set <tt>C/CXX</tt>
# language compiler, this function inspects the list of source files given and
# detects whether this list contains sources which need to be build using a
# different compiler. In particular, it supports the following languages:
# @n
# <table border="0">
#   <tr>
#     @tp @b CXX @endtp
#     <td>The default behavior, adding an executable target build from C/C++
#         source code. The target is added via CMake's add_executable() command.</td>
#   </tr>
#   <tr>
#     @tp <b>PYTHON</b>|<b>PERL</b>|<b>BASH</b> @endtp
#     <td>Executables written in one of the named scripting languages are built by
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
# @par Helper functions
# If the programming language of the input source files is not specified
# explicitly by providing the @p LANGUAGE argument, the extensions of the
# source files are inspected using basis_get_source_language(). Once the
# programming language is known, this function invokes the proper subcommand.
# In particular, it calls basis_add_executable_target() for C++ sources (.cxx),
# basis_add_mcc_target() for MATLAB scripts (.m), and basis_add_script() for all
# other source files.
#
# @note DO NOT use the mentioned subcommands directly. Always use
#       basis_add_library() to add a library target to your project. Only refer
#       to the documentation of the subcommands to learn about the available
#       options of the particular subcommand.
#
# @par Output directories
# The built executable file is output to the @c BINARY_RUNTIME_DIR or
# @c BINARY_LIBEXEC_DIR if the @p LIBEXEC option is given.
# If this function is used within the @c PROJECT_TESTING_DIR, however,
# the built executable is output to the @c TESTING_RUNTIME_DIR or
# @c TESTING_LIBEXEC_DIR instead.
#
# @par Installation
# An install command for the added executable target is added by this function
# as well. The executable will be installed as part of the component @p COMPONENT
# in the directory @c INSTALL_RUNTIME_DIR or @c INSTALL_LIBEXEC_DIR if the option
# @p LIBEXEC is given. Executable targets are exported such that they can be
# imported by other CMake-aware projects by including the CMake configuration file
# of this package (&lt;Package&gt;Config.cmake file). No installation rules are
# added, however, if this function is used within the @c PROJECT_TESTING_DIR.
# Test executables are further only exported as part of the build tree.
#
# @note If this function is used within the @c PROJECT_TESTING_DIR, the built
#       executable is output to the @c TESTING_RUNTIME_DIR or
#       @c TESTING_LIBEXEC_DIR instead. Moreover, no installation rules are added.
#       Test executables are further only exported as part of the build tree.
#
# @param [in] TARGET_NAME Name of the target. If a source file is given
#                         as first argument, the build target name is derived
#                         from the name of this source file.
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
#         which is only called by other executables.</td>
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
# @returns Adds an executable build target. In case of an executable which is
#          not build from C++ source files, the function basis_add_custom_finalize()
#          has to be invoked to finalize the addition of the custom build target.
#          This is done automatically by the basis_project_impl() macro.
#
# @sa basis_add_executable_target()
# @sa basis_add_script()
# @sa basis_add_mcc_target()
#
# @ingroup CMakeAPI
function (basis_add_executable TARGET_NAME)
  # --------------------------------------------------------------------------
  # determine language
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "TEST" # discard deprecated TEST option
      "LANGUAGE"
      ""
    ${ARGN}
  )

  if (NOT ARGN_LANGUAGE)

    CMAKE_PARSE_ARGUMENTS (
      TMP
      "LIBEXEC;MODULE;WITH_PATH;WITH_EXT;NO_BASIS_UTILITIES;NO_EXPORT"
      "BINARY_DIRECTORY;DESTINATION;COMPONENT;CONFIG;CONFIG_FILE"
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    if (NOT TMP_UNPARSED_ARGUMENTS)
      set (TMP_UNPARSED_ARGUMENTS "${TARGET_NAME}")
    endif ()

    basis_get_source_language (ARGN_LANGUAGE "${TMP_UNPARSED_ARGUMENTS}")
    if (ARGN_LANGUAGE MATCHES "AMBIGUOUS|UNKNOWN")
      message ("basis_add_executable(${TARGET_NAME}): Given source code files: ${TMP_UNPARSED_ARGUMENTS}")
      if (ARGN_LANGUAGE MATCHES "AMBIGUOUS")
        message (FATAL_ERROR "basis_add_executable(${TARGET_NAME}): Ambiguous source code files! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      elseif (ARGN_LANGUAGE MATCHES "UNKNOWN")
        message (FATAL_ERROR "basis_add_executable(${TARGET_NAME}): Unknown source code language! Try to set LANGUAGE manually and make sure that no unknown option was given.")
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

# ----------------------------------------------------------------------------
## @brief Add library target.
#
# This is the main function to add a library target to the build system, where
# a library can be a binary archive, shared library, a MEX-file or a module
# written in a scripting language. In general we refer to any output file which
# is part of the software (i.e., excluding configuration files), but cannot be
# executed (e.g., a binary file in the ELF format) or interpreted
# (e.g., a BASH script) directly, as library file. Natively, CMake supports only
# libraries build from C/C++ source code files. This function extends CMake's
# capabilities by adding custom build commands for non-natively supported
# programming languages and further standardizes the build of library targets.
# For example, by default, it is not necessary to specify installation rules
# separately as these are added by this function already (see below).
#
# @par Programming languages
# Besides adding usual library targets built from C/C++ source code files,
# this function can also add custom build targets for libraries implemented
# in other programming languages. It therefore tries to detect the programming
# language of the given source code files and delegates the addition of the
# build target to the proper helper functions. It in particular supports the
# following languages:
# @n
# <table border="0">
#   <tr>
#     @tp @b CXX @endtp
#     <td>Source files written in C/C++ are by default built into either
#         @p STATIC, @p SHARED, or @p MODULE libraries. If the @p MEX option
#         is given, however, a MEX-file (a shared library) is build using
#         the MEX script instead of using the default C++ compiler directly.</td>
#   </tr>
#   <tr>
#     @tp <b>PYTHON</b>|<b>PERL</b>|<b>BASH</b> @endtp
#     <td>Modules written in one of the named scripting languages are built similar
#         to executable scripts except that the file name extension is preserved
#         and no executable file permission is set on Unix. These modules are
#         intended for import/inclusion in other modules or executables written
#         in the particular scripting language only.</td>
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
# @par Helper functions
# If the programming language of the input source files is not specified
# explicitly by providing the @p LANGUAGE argument, the extensions of the
# source files are inspected using basis_get_source_language(). Once the
# programming language is known, this function invokes the proper subcommand.
# In particular, it calls basis_add_library_target() for C++ sources (.cxx)
# if the target is not a MEX-file target, basis_add_mex_target() for C++ sources
# if the @p MEX option is given, basis_add_mcc_target() for MATLAB scripts (.m),
# and basis_add_script() for all other source files.
#
# @note DO NOT use the mentioned subcommands directly. Always use
#       basis_add_library() to add a library target to your project. Only refer
#       to the documentation of the subcommands to learn about the available
#       options of the particular subcommand.
#
# @par Output directories
# The built libraries are output to the @c BINARY_RUNTIME_DIR, @c BINARY_LIBRARY_DIR,
# and/or @c BINARY_ARCHIVE_DIR. Python modules are output to subdirectories in
# the @c BINARY_PYTHON_LIBRARY_DIR. Perl modules are output to subdirectories in
# the @c BINARY_PERL_LIBRARY_DIR. If this command is used within the
# @c PROJECT_TESTING_DIR, however, the files are output to the
# @c TESTING_RUNTIME_DIR, @c TESTING_LIBRARY_DIR, @c TESTING_ARCHIVE_DIR,
# @c TESTING_PYTHON_LIBRARY_DIR, or @c TESTING_PERL_LIBRARY_DIR instead.
#
# @par Installation
# An install command for the added library target is added by this function
# as well. Runtime libraries are installed as part of the @p RUNTIME_COMPONENT
# to the @p RUNTIME_DESTINATION. Library components are installed as part of
# the @p LIBRARY_COMPONENT to the @p LIBRARY_DESTINATION. Library targets are
# exported such that they can be imported by other CMake-aware projects by
# including the CMake configuration file of this package
# (&lt;Package&gt;Config.cmake file). If this function is used within the
# @c PROJECT_TESTING_DIR, however, no installation rules are added.
# Test library targets are further only exported as part of the build tree.
#
# @par Example
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
# @param [in] TARGET_NAME Name of the target. If a source file is given
#                         as first argument, the build target name is derived
#                         from the name of this source file.
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
# @returns Adds a library build target. In case of a library not written in C++
#          or MEX-file targets, basis_add_custom_finalize() has to be invoked
#          to finalize the addition of the build target(s). This is done
#          automatically by the basis_project_impl() macro.
#
# @sa basis_add_library_target()
# @sa basis_add_script()
# @sa basis_add_mex_target()
# @sa basis_add_mcc_target()
#
# @ingroup CMakeAPI
function (basis_add_library TARGET_NAME)
  # --------------------------------------------------------------------------
  # determine language
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "TEST" # discard deprecated TEST option
      "LANGUAGE"
      ""
    ${ARGN}
  )

  if (NOT ARGN_LANGUAGE)

    CMAKE_PARSE_ARGUMENTS (
      TMP
      "STATIC;SHARED;MODULE;MEX;WITH_PATH;NO_EXPORT"
      "BINARY_DIRECTORY;DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT;CONFIG;CONFIG_SCRIPT;MFILE"
      ""
      ${ARGN_UNPARSED_ARGUMENTS}
    )

    if (NOT TMP_UNPARSED_ARGUMENTS)
      set (TMP_UNPARSED_ARGUMENTS "${TARGET_NAME}")
    endif ()

    basis_get_source_language (ARGN_LANGUAGE "${TMP_UNPARSED_ARGUMENTS}")
    if (ARGN_LANGUAGE MATCHES "AMBIGUOUS|UNKNOWN")
      message ("basis_add_library(${TARGET_NAME}): Given source code files: ${TMP_UNPARSED_ARGUMENTS}")
      if (ARGN_LANGUAGE MATCHES "AMBIGUOUS")
        message (FATAL_ERROR "basis_add_library(${TARGET_NAME}): Ambiguous source code files! Try to set LANGUAGE manually and make sure that no unknown option was given.")
      elseif (ARGN_LANGUAGE MATCHES "UNKNOWN")
        message (FATAL_ERROR "basis_add_library(${TARGET_NAME}): Unknown source code language! Try to set LANGUAGE manually and make sure that no unknown option was given.")
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

# ============================================================================
# internal helpers
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add executable target.
#
# This BASIS function overwrites CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable">
# add_executable()</a> command in order to store information of imported targets
# which is in particular used to generate the source code of the ExecutableTargetInfo
# modules which are part of the BASIS utilities.
#
# @note Use basis_add_executable() instead where possible!
#
# @param [in] TARGET Name of the target.
# @param [in] ARGN   Further arguments of CMake's add_executable().
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable
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
# This BASIS function overwrites CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_library">
# add_library()</a> command in order to store information of imported targets.
#
# @note Use basis_add_library() instead where possible!
#
# @param [in] TARGET Name of the target.
# @param [in] ARGN   Further arguments of CMake's add_library().
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_library
function (add_library TARGET)
  if (ARGC EQUAL 3 AND ARGV2 MATCHES "^IMPORTED$")
    _add_library (${TARGET} "${ARGV1}" IMPORTED)
    basis_add_imported_target ("${TARGET}" "${ARGV1}")
  else ()
    _add_library (${TARGET} ${ARGN})
    basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET}")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Adds an executable target built from C++ source code.
#
# This function adds an executable target for the build of an executable from
# C++ source code files. Refer to the documentation of basis_add_executable()
# for a description of general options for adding an executable target.
#
# By default, the BASIS C++ utilities library is added as link dependency of
# the executable target. If none of the BASIS C++ utilities are used by the
# executable, the option NO_BASIS_UTILITIES can be given. To enable this option
# by default, set the variable @c BASIS_NO_BASIS_UTILITIES to TRUE before the
# basis_add_executable() commands, i.e., best in the Settings.cmake file located
# in the @c PROJECT_CONFIG_DIR. Note, however, that the utilities library is a
# static library and thus the linker would simply not include any of the BASIS
# utilities object code in the final binary executable file if not used.
#
# @note This function should not be used directly. Instead, it is called
#       by basis_add_executable() if the (detected) programming language
#       of the given source code files is @c CXX (i.e., C/C++).
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
#         which is only called by other executable.</td>
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
# @sa basis_add_executable()
# @sa basis_install()
function (basis_add_executable_target TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
    "LIBEXEC;TEST;BASIS_UTILITIES;NO_BASIS_UTILITIES;NO_EXPORT"
    "DESTINATION;COMPONENT"
    ""
    ${ARGN}
  )

  basis_sanitize_for_regex (R "${PROJECT_TESTING_DIR}")
  if (CMAKE_CURRENT_SOURCE_DIR MATCHES "^${R}")
    set (ARGN_TEST TRUE)
  else ()
    if (ARGN_TEST)
      message (FATAL_ERROR "Executable ${TARGET_NAME} cannot have TEST property!"
                           "If it is a test executable, put it in ${PROJECT_TESTING_DIR}.")
    endif ()
    set (ARGN_TEST FALSE)
  endif ()

  set (SOURCES ${ARGN_UNPARSED_ARGUMENTS})

  get_filename_component (S "${TARGET_NAME}" ABSOLUTE)
  if (NOT SOURCES OR EXISTS "${S}" OR EXISTS "${S}.in")
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

  if (BASIS_VERBOSE)
    message (STATUS "Adding executable ${TARGET_UID}...")
  endif ()

  # add standard auxiliary library
  if (NOT NO_BASIS_UTILITIES)
    if (NOT BASIS_UTILITIES_ENABLED MATCHES "CXX")
      message (FATAL_ERROR "Target ${TARGET_UID} makes use of the BASIS C++ utilities"
                           " but BASIS was build without C++ utilities enabled."
                           " Either specify the option NO_BASIS_UTILITIES or rebuild"
                           " BASIS with C++ utilities enabled.")
    endif ()
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

  # target properties
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
        LIBEXEC             1
        COMPILE_DEFINITIONS "LIBEXEC"
    )
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 0)
  endif ()
  if (ARGN_TEST)
    _set_target_properties (${TARGET_UID} PROPERTIES TEST 1)
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES TEST 0)
  endif ()

  # output directory
  if (ARGN_TEST)
    if (ARGN_LIBEXEC)
      _set_target_properties (
        ${TARGET_UID}
        PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "${TESTING_LIBEXEC_DIR}"
      )
    else ()
      _set_target_properties (
        ${TARGET_UID}
        PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}"
      )
    endif ()
  elseif (ARGN_LIBEXEC)
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
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

  # add default link dependencies
  if (NOT ARGN_NO_BASIS_UTILITIES)
    # non-project specific utilities build as part of BASIS
    basis_target_link_libraries (${TARGET_UID} ${BASIS_UTILITIES_LIBRARY})
    # project specific utilities build as part of this project
    basis_target_link_libraries (${TARGET_UID} ${BASIS_UTILITIES_TARGET})
  endif ()

  # install executable and/or export target
  if (ARGN_TEST)

    # TODO install (selected?) tests

    if (NOT ARGN_NO_EXPORT)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    endif ()

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

# ----------------------------------------------------------------------------
## @brief Add build target for library built from C++ source code.
#
# This function adds a library target which builds a library from C++ source
# code files. Refer to the documentation of basis_add_library() for a
# description of the general options for adding a library target.
#
# @note This function should not be used directly. Instead, it is called
#       by basis_add_library() if the (detected) programming language
#       of the given source code files is @c CXX (i.e., C/C++) and the
#       option @c MEX is not given.
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
function (basis_add_library_target TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "STATIC;SHARED;MODULE;NO_EXPORT"
      "DESTINATION;RUNTIME_DESTINATION;LIBRARY_DESTINATION;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT"
      ""
    ${ARGN}
  )

  basis_sanitize_for_regex (R "${PROJECT_TESTING_DIR}")
  if (CMAKE_CURRENT_SOURCE_DIR MATCHES "^${R}")
    set (ARGN_TEST TRUE)
  else ()
    set (ARGN_TEST FALSE)
  endif ()

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
  )

  # output directory
  if (ARGN_TEST)
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}"
        LIBRARY_OUTPUT_DIRECTORY "${TESTING_LIBRARY_DIR}"
        ARCHIVE_OUTPUT_DIRECTORY "${TESTING_ARCHIVE_DIR}"
    )
  else ()
    _set_target_properties (
      ${TARGET_UID}
      PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${BINARY_RUNTIME_DIR}"
        LIBRARY_OUTPUT_DIRECTORY "${BINARY_LIBRARY_DIR}"
        ARCHIVE_OUTPUT_DIRECTORY "${BINARY_ARCHIVE_DIR}"
    )
  endif ()

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
  if (ARGN_TEST)
    # TODO At the moment, no tests are installed. Once there is a way to
    #      install selected tests, the shared libraries they depend on
    #      need to be installed as well.

    if (NOT ARGN_NO_EXPORT)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    endif ()
  else ()
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

# ----------------------------------------------------------------------------
## @brief Add script target.
#
# If the script name ends in ".in", the ".in" suffix is removed from the
# output name. Further, the extension of the script such as .sh or .py is
# removed from the output filename of executable scripts. On Unix, a shebang
# directive is added to executable scripts at the top of the script files
# instead if such directive is not given yet. In order to enable the convenient
# execution of Python and Perl scripts on Windows as well, some Batch code
# is added at the top and bottom of executable Python and Perl scripts which
# calls the Python or Perl interpreter with the script file and the given
# script arguments as command-line arguments. The file name extension of
# such modified scripts is by default set to <tt>.cmd</tt>, the common
# extension for Windows NT Command Scripts. Scripts in other languages are
# not specifically modified. In case of script modules, the script file name
# extension is preserved in any case. When the @c WITH_EXT option is given,
# executable scripts are not modified as described and their file name
# extension is preserved.
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
# @note If this function is used within the @c PROJECT_TESTING_DIR, the built
#       executable is output to the @c BINARY_TESTING_DIR directory tree instead.
#       Moreover, no installation rules are added. Test executables are further
#       not exported, regardless of whether NO_EXPORT is given or not.
#
# @note This function should not be used directly. Instead, the functions
#       basis_add_executable() and basis_add_library() should be used which in
#       turn make use of this function if the (detected) programming language
#       is a (supported) scripting language.
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
#         which is only called by other executable.</td>
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
#     <td>Specify that the existing filename extension should be kept also
#         in case of an executable script. No shebang directive is added to
#         the top of the script automatically if this option is given.
#         On Windows, on the other side, this prevents the addition of Batch
#         code to execute the script and no <tt>.cmd</tt> file name extension
#         is used for executable scripts build with this option.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export build target.</td>
#   </tr>
#   <tr>
#     @tp @b COMPILE | @b NOCOMPILE @endtp
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
# @sa basis_add_executable()
# @sa basis_add_library()
# @sa basis_add_script_finalize()
# @sa basis_add_custom_finalize()
function (basis_add_script TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "LIBEXEC;TEST;MODULE;WITH_PATH;WITH_EXT;NO_EXPORT;COMPILE;NOCOMPILE"
      "BINARY_DIRECTORY;CONFIG;CONFIG_FILE;COMPONENT;DESTINATION"
      ""
    ${ARGN}
  )

  basis_sanitize_for_regex (R "${PROJECT_TESTING_DIR}")
  if (CMAKE_CURRENT_SOURCE_DIR MATCHES "^${R}")
    set (ARGN_TEST TRUE)
  else ()
    if (ARGN_TEST)
      message (FATAL_ERROR "Executable ${TARGET_NAME} cannot have TEST property!"
                           "If it is a test executable, put it in ${PROJECT_TESTING_DIR}.")
    endif ()
    set (ARGN_TEST FALSE)
  endif ()

  if (ARGN_COMPILE)
    set (COMPILE TRUE)
  elseif (ARGN_NOCOMPILE)
    set (COMPILE FALSE)
  else ()
    set (COMPILE "${BASIS_COMPILE_SCRIPTS}")
  endif ()

  if (ARGN_TEST)
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

  # get script file and script name
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
    set (TARGET_NAME) # set below from ARGN_SCRIPT
  endif ()
  get_filename_component (ARGN_SCRIPT "${ARGN_SCRIPT}" ABSOLUTE)
  if (NOT EXISTS "${ARGN_SCRIPT}")
    set (ARGN_SCRIPT "${ARGN_SCRIPT}.in")
  endif ()
  if (NOT EXISTS "${ARGN_SCRIPT}")
    string (REGEX REPLACE "\\.in$" "" ARGN_SCRIPT "${ARGN_SCRIPT}")
    message (FATAL_ERROR "basis_add_script(): Missing script file ${ARGN_SCRIPT}[.in]!")
  endif ()
  get_filename_component (SCRIPT_NAME "${ARGN_SCRIPT}" NAME)
  string (REGEX REPLACE "\\.in$" "" SCRIPT_NAME "${SCRIPT_NAME}")
  get_filename_component (SCRIPT_NAME_WE "${SCRIPT_NAME}" NAME_WE)
  get_filename_component (SCRIPT_EXT "${SCRIPT_NAME}" EXT)

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

  # get script language
  basis_get_source_language (SCRIPT_LANGUAGE "${ARGN_SCRIPT}")

  # set output name and target name (if not set yet)
  set (OUTPUT_PREFIX "")
  set (OUTPUT_NAME   "")
  set (OUTPUT_SUFFIX "")
  if (TARGET_NAME)
    set (OUTPUT_NAME "${TARGET_NAME}")
  else ()
    set (OUTPUT_NAME "${SCRIPT_NAME_WE}")
    if (ARGN_MODULE)
      basis_get_source_target_name (TARGET_NAME "${SCRIPT_NAME}" NAME)
    else ()
      basis_get_source_target_name (TARGET_NAME "${SCRIPT_NAME}" NAME_WE)
    endif ()
  endif ()
  # use output name extension for modules,
  # for executables also on Windows, and if WITH_EXT option is given
  if (ARGN_MODULE OR ARGN_WITH_EXT)
    set (OUTPUT_SUFFIX "${SCRIPT_EXT}")
  elseif (WIN32)
    if (SCRIPT_LANGUAGE MATCHES "PYTHON|PERL")
      set (OUTPUT_SUFFIX ".cmd")
    else ()
      set (OUTPUT_SUFFIX "${SCRIPT_EXT}")
    endif ()
  endif ()
  # SUFFIX and PREFIX used by CMake only for libraries
  if (NOT ARGN_MODULE)
    set (OUTPUT_NAME "${OUTPUT_PREFIX}${OUTPUT_NAME}${OUTPUT_SUFFIX}")
    set (OUTPUT_PREFIX "")
    set (OUTPUT_SUFFIX "")
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

  if (ARGN_MODULE AND ARGN_LIBEXEC)
    message (FATAL_ERROR "basis_add_script(${TARGET_UID}): Script cannot be MODULE and LIBEXEC at the same time!")
  endif ()

  # directory for build system files
  set (BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_UID}.dir")

  # dump CMake variables for "build" of script
  basis_dump_variables ("${BUILD_DIR}/variables.cmake")

  # "parse" script to check if BASIS utilities are used and hence required
  file (READ "${ARGN_SCRIPT}" SCRIPT)
  if (SCRIPT MATCHES "@BASIS_([A-Z]+)_UTILITIES@")
    if (BASIS_DEBUG)
      message ("** Target ${TARGET_UID} uses BASIS ${CMAKE_MATCH_1} utilities.")
    endif ()
    basis_set_project_property (PROPERTY PROJECT_USES_${CMAKE_MATCH_1}_UTILITIES TRUE)
  endif ()
  set (SCRIPT)

  # binary directory
  if (ARGN_BINARY_DIRECTORY)
    set (BINARY_DIRECTORY "${ARGN_BINARY_DIRECTORY}")
  else ()
    set (BINARY_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
  endif ()

  # output directory
  if (ARGN_TEST)
    if (ARGN_MODULE)
      if (SCRIPT_LANGUAGE MATCHES "PYTHON")
        set (OUTPUT_DIRECTORY "${TESTING_PYTHON_LIBRARY_DIR}/sbia/${PROJECT_NAME_LOWER}")
      elseif (SCRIPT_LANGUAGE MATCHES "PERL")
        set (OUTPUT_DIRECTORY "${TESTING_PERL_LIBRARY_DIR}/SBIA/${PROJECT_NAME}")
      else ()
        set (OUTPUT_DIRECTORY "${TESTING_LIBRARY_DIR}")
      endif ()
    elseif (ARGN_LIBEXEC)
      set (OUTPUT_DIRECTORY "${TESTING_LIBEXEC_DIR}")
    else ()
      set (OUTPUT_DIRECTORY "${TESTING_RUNTIME_DIR}")
    endif ()
  elseif (ARGN_MODULE)
    if (SCRIPT_LANGUAGE MATCHES "PYTHON")
      set (OUTPUT_DIRECTORY "${BINARY_PYTHON_LIBRARY_DIR}/sbia/${PROJECT_NAME_LOWER}")
    elseif (SCRIPT_LANGUAGE MATCHES "PERL")
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
    # reference to BASIS doxygen page documenting the script configuration
    if (PROJECT_NAME MATCHES "^BASIS$")
      set (BuildOfScriptTargetsPageRef "@ref BuildOfScriptTargets")
    else ()
      set (BuildOfScriptTargetsPageRef "Build of Script Targets")
    endif ()
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
      PREFIX                    "${OUTPUT_PREFIX}"
      SUFFIX                    "${OUTPUT_SUFFIX}"
      COMPILE_DEFINITIONS       "${ARGN_CONFIG}"
      LINK_DEPENDS              "${ARGN_CONFIG_FILE}"
      RUNTIME_COMPONENT         "${ARGN_COMPONENT}"
      LIBRARY_COMPONENT         "${ARGN_COMPONENT}"
      NO_EXPORT                 "${ARGN_NO_EXPORT}"
      COMPILE                   "${COMPILE}"
      WITH_EXT                  "${ARGN_WITH_EXT}"
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

# ----------------------------------------------------------------------------
## @brief Finalize addition of script.
#
# This function uses the properties of the custom script target added by
# basis_add_script() to create the custom build command and adds this build
# command as dependency of this added target.
#
# @param [in] TARGET_UID "Global" target name. If this function is used
#                        within the same project as basis_add_script(),
#                        the "local" target name may be given alternatively.
#
# @returns Adds custom target(s) to actually build the script target
#          @p TARGET_UID added by basis_add_script().
#
# @sa basis_add_script()
# @sa basis_add_custom_finalize()
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
      "LINK_DEPENDS"
      "RUNTIME_COMPONENT"
      "LIBRARY_COMPONENT"
      "LIBEXEC"
      "TEST"
      "NO_EXPORT"
      "COMPILE"
      "WITH_EXT"
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
  set (CONFIGURED_INSTALL_FILE "${CONFIGURED_FILE}")
  # final output script file for install tree
  set (INSTALL_FILE "${CONFIGURED_INSTALL_FILE}")
  set (INSTALL_NAME "${OUTPUT_NAME}")
  # output files of build command
  set (OUTPUT_FILES "${OUTPUT_FILE}")
  # files this script and its build depends on
  set (DEPENDS ${LINK_DEPENDS} "${BUILD_SCRIPT}")

  set (C "# DO NOT edit. This file was automatically generated by BASIS.\n")

  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # look for required interpreter executable
  if (BASIS_LANGUAGE MATCHES "PYTHON")
    find_package (PythonInterp QUIET)
    if (NOT PYTHONINTERP_FOUND)
      message (FATAL_ERROR "Python interpreter not found. It is required to"
                           " execute the script file target ${TARGET_UID}.")
    endif ()
  elseif (BASIS_LANGUAGE MATCHES "PERL")
    find_package (Perl QUIET)
    if (NOT PERL_FOUND)
      message (FATAL_ERROR "Perl interpreter not found. It is required to"
                           " execute the script file target ${TARGET_UID}.")
    endif ()
  elseif (BASIS_LANGUAGE MATCHES "BASH")
    find_package (BASH QUIET)
    if (NOT BASH_FOUND)
      message (FATAL_ERROR "BASH interpreter not found. It is required to"
                           " execute the script file target ${TARGET_UID}.")
    endif ()
  endif ()

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # common variables and functions used by build scripts
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
  set (C "${C}\n")
  set (C "${C}# function used by build script to generate script for this platform\n")
  set (C "${C}function (basis_configure_script SCRIPT_FILE CONFIGURED_FILE MODE)\n")
  set (C "${C}  file (READ \"\${SCRIPT_FILE}\" SCRIPT)\n")
  set (C "${C}  if (NOT MODE MATCHES \"COPYONLY\")\n")
  set (C "${C}    string (CONFIGURE \"\${SCRIPT}\" SCRIPT \${MODE})\n")
  set (C "${C}    string (CONFIGURE \"\${SCRIPT}\" SCRIPT \${MODE})\n")
  set (C "${C}  endif ()\n")
  if (NOT MODULE AND NOT WITH_EXT)
  set (C "${C}  if (WIN32)\n")
  set (C "${C}    if (LANGUAGE MATCHES \"PYTHON\")\n")
  set (C "${C}      set (SCRIPT \"@setlocal enableextensions & ${PYTHON_EXECUTABLE} -x %~f0 %* & goto :EOF\\n\${SCRIPT}\")\n")
  set (C "${C}    elseif (LANGUAGE MATCHES \"PERL\")\n")
  set (C "${C}      set (SCRIPT \"@goto = \\\"START_OF_BATCH\\\" ;\\n@goto = ();\\n\\n\${SCRIPT}\")\n")
  set (C "${C}      set (SCRIPT \"\${SCRIPT}\\n\\n__END__\\n\\n:\\\"START_OF_BATCH\\\"\\n@${PERL_EXECUTABLE} -w -S %~f0 %*\")\n")
  set (C "${C}    endif ()\n")
  set (C "${C}  elseif (NOT SCRIPT MATCHES \"^#!\")\n")
  set (C "${C}    if (LANGUAGE MATCHES \"PYTHON\")\n")
  set (C "${C}      set (SCRIPT \"#! ${PYTHON_EXECUTABLE}\\n\${SCRIPT}\")\n")
  set (C "${C}    elseif (LANGUAGE MATCHES \"PERL\")\n")
  set (C "${C}      set (SCRIPT \"#! ${PERL_EXECUTABLE} -w\\n\${SCRIPT}\")\n")
  set (C "${C}    elseif (LANGUAGE MATCHES \"BASH\")\n")
  set (C "${C}      set (SCRIPT \"#! ${BASH_EXECUTABLE}\\n\${SCRIPT}\")\n")
  set (C "${C}    endif ()\n")
  set (C "${C}  endif ()\n")
  endif ()
  set (C "${C}  file (WRITE \"\${CONFIGURED_FILE}\" \"\${SCRIPT}\")\n")
  set (C "${C}endfunction ()\n")

  if (SCRIPT_FILE MATCHES "\\.in$")
    # make (configured) script configuration files a dependency
    list (APPEND DEPENDS "${BUILD_DIR}/variables.cmake")
    if (EXISTS "${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake")
      list (APPEND DEPENDS "${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake")
    endif ()
    if (EXISTS "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
      list (APPEND DEPENDS "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
    endif ()
    if (EXISTS "${BUILD_DIR}/ScriptConfig.cmake")
      list (APPEND DEPENDS "${BUILD_DIR}/ScriptConfig.cmake")
    endif ()

    # additional output files
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

    # variables dumped by basis_add_script()
    set (C "${C}\n")
    set (C "${C}# dumped CMake variables\n")
    set (C "${C}include (\"\${CMAKE_CURRENT_LIST_DIR}/variables.cmake\")\n")

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
    set (C "${C}basis_configure_script (\"${SCRIPT_FILE}\" \"${CONFIGURED_FILE}\" @ONLY)\n")
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
      set (C "${C}set (DIR \"${INSTALL_PREFIX}/${INSTALL_DIR}\")\n")
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
      set (C "${C}basis_configure_script (\"${SCRIPT_FILE}\" \"${CONFIGURED_INSTALL_FILE}\" @ONLY)\n")
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

    set (C "${C}\nbasis_configure_script (\"${SCRIPT_FILE}\" \"${CONFIGURED_FILE}\" COPYONLY)\n")
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
  # setup build commands

  # write/update build script
  if (EXISTS "${BUILD_SCRIPT}")
    file (WRITE "${BUILD_SCRIPT}.tmp" "${C}")
    execute_process (
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different
          "${BUILD_SCRIPT}.tmp" "${BUILD_SCRIPT}"
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
  if (NOT ARGN_NO_EXPORT)
    if (TEST)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    else ()
      basis_set_project_property (APPEND PROPERTY CUSTOM_EXPORT_TARGETS "${TARGET_UID}")
    endif ()
  endif ()

  if (MODULE)
    if (LIBRARY_INSTALL_DIRECTORY)
      install (
        FILES       "${INSTALL_FILE}"
        RENAME      "${INSTALL_NAME}"
        DESTINATION "${LIBRARY_INSTALL_DIRECTORY}"
        COMPONENT   "${LIBRARY_COMPONENT}"
      )
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

# ----------------------------------------------------------------------------
# @brief Add target to build/install __init__.py files.
function (basis_add_init_py_target)
  # constants
  set (BUILD_DIR "${PROJECT_BINARY_DIR}/CMakeFiles/_initpy.dir")
  basis_sanitize_for_regex (BINARY_PYTHON_LIBRARY_DIR_REGEX  "${BINARY_PYTHON_LIBRARY_DIR}")
  basis_sanitize_for_regex (TESTING_PYTHON_LIBRARY_DIR_REGEX "${TESTING_PYTHON_LIBRARY_DIR}")
  basis_sanitize_for_regex (INSTALL_PYTHON_LIBRARY_DIR_REGEX "${INSTALL_PYTHON_LIBRARY_DIR}")
  # collect build tree directories requiring a __init__.py file
  set (DIRS)            # directories for which to generate a __init__.py file
  set (EXCLUDE)         # exclude these directories
  set (INSTALL_EXCLUDE) # exclude these directories on installation
  set (COMPONENTS)      # installation components
  basis_get_project_property (TARGETS PROPERTY TARGETS)
  foreach (TARGET_UID ${TARGETS})
    get_target_property (BASIS_TYPE     ${TARGET_UID} "BASIS_TYPE")
    get_target_property (BASIS_LANGUAGE ${TARGET_UID} "BASIS_LANGUAGE")
    if (BASIS_TYPE MATCHES "^MODULE_SCRIPT$" AND BASIS_LANGUAGE MATCHES "PYTHON")
      # get absolute path of built Python module
      basis_get_target_location (LOCATION         ${TARGET_UID} ABSOLUTE)
      basis_get_target_location (INSTALL_LOCATION ${TARGET_UID} POST_INSTALL_RELATIVE)
      # get component (used by installation rule)
      get_target_property (COMPONENT ${TARGET_UID} "LIBRARY_COMPONENT")
      list (FIND COMPONENTS "${COMPONENT}" IDX)
      if (IDX EQUAL -1)
        list (APPEND COMPONENTS "${COMPONENT}")
        set (INSTALL_DIRS_${COMPONENT}) # list of directories for which to install
                                        # __init__.py for this component
      endif ()
      # directories for which to build a __init__.py file
      basis_get_filename_component (DIR "${LOCATION}" PATH)
      if (LOCATION MATCHES "/__init__.py$")
        list (APPEND EXCLUDE "${DIR}")
      else ()
        if (DIR MATCHES "^${BINARY_PYTHON_LIBRARY_DIR_REGEX}/.+")
          while (NOT "${DIR}" MATCHES "^${BINARY_PYTHON_LIBRARY_DIR_REGEX}$")
            list (APPEND DIRS "${DIR}")
            get_filename_component (DIR "${DIR}" PATH)
          endwhile ()
        elseif (DIR MATCHES "^${TESTING_PYTHON_LIBRARY_DIR_REGEX}/.+")
          while (NOT "${DIR}" MATCHES "^${TESTING_PYTHON_LIBRARY_DIR_REGEX}$")
            list (APPEND DIRS "${DIR}")
            get_filename_component (DIR "${DIR}" PATH)
          endwhile ()
        endif ()
      endif ()
      # directories for which to install a __init__.py file
      basis_get_filename_component (DIR "${INSTALL_LOCATION}" PATH)
      if (INSTALL_LOCATION MATCHES "/__init__.py$")
        list (APPEND INSTALL_EXCLUDE "${DIR}")
      else ()
        if (DIR MATCHES "^${INSTALL_PYTHON_LIBRARY_DIR_REGEX}/.+")
          while (NOT "${DIR}" MATCHES "^${INSTALL_PYTHON_LIBRARY_DIR_REGEX}$")
            list (APPEND INSTALL_DIRS_${COMPONENT} "${DIR}")
            get_filename_component (DIR "${DIR}" PATH)
          endwhile ()
        endif ()
      endif ()
    endif ()
  endforeach ()
  # return if no Python module is being build
  if (NOT DIRS)
    return ()
  endif ()
  list (REMOVE_DUPLICATES DIRS)
  if (EXCLUDE)
    list (REMOVE_DUPLICATES EXCLUDE)
  endif ()
  if (INSTALL_EXCLUDE)
    list (REMOVE_DUPLICATES INSTALL_EXCLUDE)
  endif ()
  # generate build script
  set (C)
  set (OUTPUT_FILES)
  foreach (DIR IN LISTS DIRS)
    list (FIND EXCLUDE "${DIR}" IDX)
    if (IDX EQUAL -1)
      set (C "${C}configure_file (\"${BASIS_PYTHON_TEMPLATES_DIR}/__init__.py.in\" \"${DIR}/__init__.py\" @ONLY)\n")
      list (APPEND OUTPUT_FILES "${DIR}/__init__.py")
      if (BASIS_COMPILE_SCRIPTS)
        set (C "${C}execute_process (COMMAND \"${PYTHON_EXECUTABLE}\" -c \"import py_compile;py_compile.compile('${DIR}/__init__.py')\")\n")
        list (APPEND OUTPUT_FILES "${DIR}/__init__.pyc")
      endif ()
    endif ()
  endforeach ()
  set (C "${C}configure_file (\"${BASIS_PYTHON_TEMPLATES_DIR}/__init__.py.in\" \"${BUILD_DIR}/__init__.py\" @ONLY)\n")
  list (APPEND OUTPUT_FILES "${BUILD_DIR}/__init__.py")
  if (BASIS_COMPILE_SCRIPTS)
    set (C "${C}execute_process (COMMAND \"${PYTHON_EXECUTABLE}\" -c \"import py_compile;py_compile.compile('${BUILD_DIR}/__init__.py')\")\n")
    list (APPEND OUTPUT_FILES "${BUILD_DIR}/__init__.pyc")
  endif ()
  # write/update build script
  set (BUILD_SCRIPT "${BUILD_DIR}/build.cmake")
  if (EXISTS "${BUILD_SCRIPT}")
    file (WRITE "${BUILD_SCRIPT}.tmp" "${C}")
    execute_process (
      COMMAND "${CMAKE_COMMAND}" -E copy_if_different
          "${BUILD_SCRIPT}.tmp" "${BUILD_SCRIPT}"
    )
    file (REMOVE "${BUILD_SCRIPT}.tmp")
  else ()
    file (WRITE "${BUILD_SCRIPT}" "${C}")
  endif ()
  # add custom build command
  add_custom_command (
    OUTPUT  ${OUTPUT_FILES}
    COMMAND "${CMAKE_COMMAND}" -P "${BUILD_SCRIPT}"
    COMMENT "Building __init__.py modules..."
  )
  # add custom target which triggers execution of build script
  add_custom_target (_initpy ALL DEPENDS ${OUTPUT_FILES})
  if (TARGET scripts)
    add_dependencies (scripts _initpy)
  endif ()
  # cleanup on "make clean"
  set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${OUTPUT_FILES})
  # add install rules
  if (BASIS_COMPILE_SCRIPTS)
    set (INSTALL_INIT_FILE "${BUILD_DIR}/__init__.pyc")
  else ()
    set (INSTALL_INIT_FILE "${BUILD_DIR}/__init__.py")
  endif ()
  foreach (COMPONENT IN LISTS COMPONENTS)
    if (INSTALL_DIRS_${COMPONENT})
      list (REMOVE_DUPLICATES INSTALL_DIRS_${COMPONENT})
    endif ()
    foreach (DIR IN LISTS INSTALL_DIRS_${COMPONENT})
      list (FIND INSTALL_EXCLUDE "${DIR}" IDX)
      if (IDX EQUAL -1)
        install (
          FILES       "${INSTALL_INIT_FILE}"
          DESTINATION "${DIR}"
          COMPONENT   "${COMPONENT}"
        )
      endif ()
    endforeach ()
  endforeach ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Finalize addition of custom targets.
#
# This function is called by basis_add_project_finalize() to finalize the
# addition of the custom build targets such as, for example, build targets
# to build script files, MATLAB Compiler targets, and MEX script generated
# MEX-files.
#
# @returns Adds custom targets that actually build the executables and
#          libraries for which custom build targets where added by
#          basis_add_executable(), basis_add_library(), and basis_add_script().
#
# @sa basis_add_script_finalize()
# @sa basis_add_mcc_target_finalize()
# @sa basis_add_mex_target_finalize()
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


## @}
# end of Doxygen group
