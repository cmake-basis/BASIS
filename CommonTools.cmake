##############################################################################
# @file  CommonTools.cmake
# @brief Definition of common CMake functions.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_COMMONTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_COMMONTOOLS_INCLUDED TRUE)
endif ()


## @addtogroup CMakeUtilities
#  @{


# ============================================================================
# find other packages
# ============================================================================

# ----------------------------------------------------------------------------
macro (find_package)
  if (BASIS_DEBUG)
    message ("find_package(${ARGV})")
  endif ()
  # attention: find_package() can be recursive. Hence, use "stack" to keep
  #            track of library suffixes. Further note that we need to
  #            maintain a list of lists, which is not supported by CMake.
  list (APPEND _BASIS_FIND_LIBRARY_SUFFIXES "{${CMAKE_FIND_LIBRARY_SUFFIXES}}")
  _find_package(${ARGV})
  string (REGEX REPLACE ";?{([^}]*)}$" "" _BASIS_FIND_LIBRARY_SUFFIXES "${_BASIS_FIND_LIBRARY_SUFFIXES}")
  set (CMAKE_FIND_LIBRARY_SUFFIXES "${CMAKE_MATCH_1}")
endmacro ()

# ----------------------------------------------------------------------------
## @brief Tokenize dependency specification.
#
# This function parses a dependency specification such as
# "ITK-4.1{TestKernel,IO}" into the package name, i.e., ITK, the requested
# (minimum) package version, i.e., 4.1, and a list of package components, i.e.,
# TestKernel and IO. A valid dependency specification must specify the package
# name of the dependency (case-sensitive). The version and components
# specification are optional. Note that the components specification may
# be separated by an arbitrary number of whitespace characters including
# newlines. The same applies to the specification of the components themselves.
# This allows one to format the dependency specification as follows, for example:
# @code
# ITK {
#   TestKernel,
#   IO
# }
# @endcode
#
# @param [in]  DEP Dependency specification, i.e., "<Pkg>[-<version>][{<Component1>[,...]}]".
# @param [out] PKG Package name.
# @param [out] VER Package version.
# @param [out] CMP List of package components.
function (basis_tokenize_dependency DEP PKG VER CMP)
  set (CMPS)
  if (DEP MATCHES "^([^ ]+)[ \\n\\t]*{([^}]*)}$")
    set (DEP "${CMAKE_MATCH_1}")
    string (REPLACE "," ";" COMPONENTS "${CMAKE_MATCH_2}")
    foreach (C IN LISTS COMPONENTS)
      string (STRIP "${C}" C)
      list (APPEND CMPS ${C})
    endforeach ()
  endif ()
  if (DEP MATCHES "^(.*)-([0-9]+)(\\.[0-9]+)?(\\.[0-9]+)?(\\.[0-9]+)?$")
    set (${PKG} "${CMAKE_MATCH_1}" PARENT_SCOPE)
    set (${VER} "${CMAKE_MATCH_2}${CMAKE_MATCH_3}${CMAKE_MATCH_4}${CMAKE_MATCH_5}" PARENT_SCOPE)
  else ()
    set (${PKG} "${DEP}" PARENT_SCOPE)
    set (${VER} ""       PARENT_SCOPE)
  endif ()
  set (${CMP} "${CMPS}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Find external software package or other project module.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:find_package">
# find_package()</a> command and extends its functionality.
# In particular, if the given package name is the name of another module
# of this project (the top-level project), it ensures that this module is
# found instead of an external package.
#
# If the package is found, but only optionally used, i.e., the @c REQUIRED
# argument was not given to this macro, a <tt>USE_&lt;Pkg&gt;</tt> option is
# added by this macro which is by default @c ON. This option can be set to
# @c OFF by the user in order to force the <tt>&lt;Pkg&gt;_FOUND</tt> variable
# to be set to @c FALSE again even if the package was found. This allows the
# user to specify which of the optional dependencies should actually not be
# used for the build of the software even though these packages are installed
# on their system.
#
# @param [in] PACKAGE Name of other package. Optionally, the package name
#                     can include a version specification as suffix which
#                     is separated by the package name using a dash (-), i.e.,
#                     &lt;Package&gt;[-major[.minor[.patch[.tweak]]]].
#                     If a version specification is given, it is passed on as
#                     @c version argument to CMake's
#                     <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:find_package">
#                     find_package()</a> command.
# @param [in] ARGN    Advanced arguments for
#                     <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:find_package">
#                     find_package()</a>.
#
# @retval <PACKAGE>_FOUND Whether the given package was found.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:find_package
#
# @ingroup CMakeAPI
macro (basis_find_package PACKAGE)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
    "EXACT;QUIET;REQUIRED"
    ""
    "COMPONENTS"
    ${ARGN}
  )
  # --------------------------------------------------------------------------
  # tokenize dependency specification
  basis_tokenize_dependency ("${PACKAGE}" PKG VER CMPS)
  list (APPEND ARGN_COMPONENTS ${CMPS})
  unset (CMPS)
  if (ARGN_UNPARSED_ARGUMENTS MATCHES "^[0-9]+(\\.[0-9]+)*$" AND VER)
    message (FATAL_ERROR "Cannot use both version specification as part of "
                         "package name and explicit version argument.")
  else ()
    set (VER "${CMAKE_MATCH_0}")
  endif ()
  # --------------------------------------------------------------------------
  # preserve <PKG>_DIR variable which might get reset if different versions
  # of the package are searched or if package is optional and deselected
  set (PKG_DIR "${${PKG}_DIR}")
  # --------------------------------------------------------------------------
  # some debugging output
  if (BASIS_DEBUG)
    message ("** basis_find_package()")
    message ("**     Package:    ${PKG}")
    if (VER)
    message ("**     Version:    ${VER}")
    endif ()
    if (ARGN_COMPONENTS)
    message ("**     Components: [${ARGN_COMPONENTS}]")
    endif ()
  endif ()
  # --------------------------------------------------------------------------
  # find other modules of same project
  if (PROJECT_IS_MODULE)
    # allow modules to specify top-level project as dependency
    if (PKG MATCHES "^${BASIS_PROJECT_NAME}$")
      if (BASIS_DEBUG)
        message ("**     This is the top-level project.")
      endif ()
      set (${PKG}_FOUND TRUE)
    else ()
      # look for other module of top-level project
      list (FIND PROJECT_MODULES "${PKG}" IDX)
      if (NOT IDX EQUAL -1)
        list (FIND PROJECT_MODULES_ENABLED "${PKG}" IDX)
        if (IDX EQUAL -1)
          set (${PKG}_FOUND FALSE)
        else ()
          if (BASIS_DEBUG)
            message ("**     Identified it as other module of this project.")
          endif ()
          include ("${${PKG}_DIR}/${PKG}Config.cmake")
          set (${PKG}_FOUND TRUE)
        endif ()
      endif ()
    endif ()
  endif ()
  # --------------------------------------------------------------------------
  # hide or show already defined <PKG>_DIR cache entry
  if (DEFINED ${PKG}_DIR AND DEFINED USE_${PKG})
    if (USE_${PKG})
      mark_as_advanced (CLEAR ${PKG}_DIR)
    else ()
      mark_as_advanced (FORCE ${PKG}_DIR)
    endif ()
  endif ()
  # --------------------------------------------------------------------------
  # find external packages
  string (TOUPPER "${PKG}" PKG_UPPER)
  string (TOUPPER "${PKG}" PKG_LOWER)
  if (NOT ${PKG}_FOUND AND (NOT DEFINED USE_${PKG} OR USE_${PKG}))
    # circumvent issue with CMake's find_package() interpreting these variables
    # relative to the current binary directory instead of the top-level directory
    if (${PKG}_DIR AND NOT IS_ABSOLUTE "${${PKG}_DIR}")
      set (${PKG}_DIR "${CMAKE_BINARY_DIR}/${${PKG}_DIR}")
      get_filename_component (${PKG}_DIR "${${PKG}_DIR}" ABSOLUTE)
    endif ()
    # moreover, users tend to specify the installation prefix instead of the
    # actual directory containing the package configuration file
    if (IS_DIRECTORY "${${PKG}_DIR}")
      list (INSERT CMAKE_PREFIX_PATH 0 "${${PKG}_DIR}")
    endif ()
    # now look for the package
    set (FIND_ARGN)
    if (ARGN_EXACT)
      list (APPEND FIND_ARGN "EXACT")
    endif ()
    if (ARGN_QUIET)
      list (APPEND FIND_ARGN "QUIET")
    endif ()
    if (ARGN_COMPONENTS)
      list (APPEND FIND_ARGN "COMPONENTS" ${ARGN_COMPONENTS})
    elseif (ARGN_REQUIRED)
      list (APPEND FIND_ARGN "REQUIRED")
    endif ()
    if ("${PKG}" MATCHES "^(MFC|wxWidgets)$")
      # if Find<Pkg>.cmake prints status message, don't do it here
      find_package (${PKG} ${VER} ${FIND_ARGN})
    else ()
      set (MSG "${PKG}")
      if (VER)
        set (MSG "${PKG} ${VER}")
      endif ()
      if (BASIS_VERBOSE)
        message (STATUS "Looking for ${MSG}...")
      endif ()
      find_package (${PKG} ${VER} ${FIND_ARGN})
      if (${PKG_UPPER}_FOUND)
        set (${PKG}_FOUND TRUE)
      endif ()
      if (BASIS_VERBOSE)
        if (${PKG}_FOUND)
          if (DEFINED ${PKG}_DIR)
            message (STATUS "Looking for ${MSG}... - found: ${${PKG}_DIR}")
          elseif (DEFINED ${PKG_UPPER}_DIR)
            message (STATUS "Looking for ${MSG}... - found: ${${PKG_UPPER}_DIR}")
          else ()
            message (STATUS "Looking for ${MSG}... - found")
          endif ()
        else ()
          message (STATUS "Looking for ${MSG}... - not found")
        endif ()
      endif ()
    endif ()
    # provide option which allows users to disable use of not required packages
    if (${PKG}_FOUND AND NOT ARGN_REQUIRED)
      option (USE_${PKG} "Enable/disable use of package ${PKG}." ON)
      mark_as_advanced (USE_${PKG})
      if (NOT USE_${PKG})
        set (${PKG}_FOUND       FALSE)
        set (${PKG_UPPER}_FOUND FALSE)
      endif ()
    endif ()
  endif ()
  # --------------------------------------------------------------------------
  # reset <PKG>_DIR variable for possible search of different package version
  if (PKG_DIR AND NOT ${PKG}_DIR)
    basis_set_or_update_cache (${PKG}_DIR "${PKG_DIR}")
  endif ()
  # --------------------------------------------------------------------------
  # unset locally used variables
  unset (PACKAGE_DIR)
  unset (PKG)
  unset (PKG_UPPER)
  unset (VER)
  unset (USE_PKG_OPTION)
endmacro ()

# ----------------------------------------------------------------------------
## @brief Use found package.
#
# This macro includes the package's use file if the variable @c &lt;Pkg&gt;_USE_FILE
# is defined. Otherwise, it adds the include directories to the search path
# for include paths if possible. Therefore, the corresponding package
# configuration file has to set the proper CMake variables, i.e.,
# either @c &lt;Pkg&gt;_INCLUDES, @c &lt;Pkg&gt;_INCLUDE_DIRS, or @c &lt;Pkg&gt;_INCLUDE_DIR.
#
# If the given package name is the name of another module of this project
# (the top-level project), this function includes the use file of the specified
# module.
#
# @note As some packages still use all captial variables instead of ones
#       prefixed by a string that follows the same capitalization as the
#       package's name, this function also considers these if defined instead.
#       Hence, if @c &lt;PKG&gt;_INCLUDES is defined, but not @c &lt;Pkg&gt;_INCLUDES, it
#       is used in place of the latter.
#
# @note According to an email on the CMake mailing list, it is not a good idea
#       to use basis_link_directories() any more given that the arguments to
#       basis_target_link_libraries() are absolute paths to the library files.
#       Therefore, this code is commented and not used. It remains here as a
#       reminder only.
#
# @param [in] PACKAGE Name of other package. Optionally, the package name
#                     can include a version specification as suffix which
#                     is separated by the package name using a dash (-), i.e.,
#                     &lt;Package&gt;[-major[.minor[.patch[.tweak]]]].
#                     A version specification is simply ignored by this macro.
#
# @ingroup CMakeAPI
macro (basis_use_package PACKAGE)
  # tokenize package specification
  basis_tokenize_dependency ("${PACKAGE}" PKG VER CMPS)
  # use package
  foreach (A IN ITEMS "WORKAROUND FOR NOT BEING ABLE TO USE RETURN")
    if (BASIS_DEBUG)
      message ("** basis_use_package()")
      message ("**    Package: ${PKG}")
    endif ()
    if (PROJECT_IS_MODULE)
      # allow modules to specify top-level project as dependency
      if (PKG MATCHES "^${BASIS_PROJECT_NAME}$")
        if (BASIS_DEBUG)
          message ("**     This is the top-level project.")
        endif ()
        break () # instead of return()
      else ()
        # use other module of top-level project
        list (FIND PROJECT_MODULES "${PKG}" IDX)
        if (NOT IDX EQUAL -1)
          if (${PKG}_FOUND)
            if (BASIS_DEBUG)
              message ("**     Include package use file of other module.")
            endif ()
            include ("${${PKG}_DIR}/${PKG}Use.cmake")
            break () # instead of return()
          else ()
            message (FATAL_ERROR "Module ${PKG} not found! This must be a "
                                 "mistake of BASIS. Talk to the maintainer of this "
                                 "package and have them fix it.")
          endif ()
        endif ()
      endif ()
    endif ()
    # use external package
    string (TOUPPER "${PKG}" PKG_UPPER)
    if (${PKG}_FOUND OR ${PKG_UPPER}_FOUND)
      # use package only if basis_use_package() not invoked before
      if (BASIS_USE_${PKG}_INCLUDED)
        if (BASIS_DEBUG)
          message ("**     External package used before already.")
        endif ()
        break ()
      endif ()
      if (${PKG}_USE_FILE)
        if (BASIS_DEBUG)
          message ("**     Include package use file of external package.")
        endif ()
        include ("${${PKG}_USE_FILE}")
      elseif (${PKG_UPPER}_USE_FILE)
        if (BASIS_DEBUG)
          message ("**     Include package use file of external package.")
        endif ()
        include ("${${PKG_UPPER}_USE_FILE}")
      else ()
        if (BASIS_DEBUG)
          message ("**     Use variables which were set by basis_find_package().")
        endif ()
        # OpenCV
        if ("${PKG}" STREQUAL "OpenCV")
          # the cv.h may be found as part of PerlLibs, the include path of
          # which is added at first by BASISConfig.cmake
          if (OpenCV_INCLUDE_DIRS)
            basis_include_directories (BEFORE ${OpenCV_INCLUDE_DIRS})
          elseif (OpenCV_INCLUDE_DIR)
            basis_include_directories (BEFORE ${OpenCV_INCLUDE_DIR})
          endif ()
        # generic
        else ()
          if (${PKG}_INCLUDE_DIRS OR ${PKG_UPPER}_INCLUDE_DIRS)
            if (${PKG}_INCLUDE_DIRS)
              basis_include_directories (${${PKG}_INCLUDE_DIRS})
            else ()
              basis_include_directories (${${PKG_UPPER}_INCLUDE_DIRS})
            endif ()
          elseif (${PKG}_INCLUDES OR ${v}_INCLUDES)
            if (${PKG}_INCLUDES)
              basis_include_directories (${${PKG}_INCLUDES})
            else ()
              basis_include_directories (${${PKG_UPPER}_INCLUDES})
            endif ()
          elseif (${PKG}_INCLUDE_PATH OR ${PKG_UPPER}_INCLUDE_PATH)
            if (${PKG}_INCLUDE_PATH)
              basis_include_directories (${${PKG}_INCLUDE_PATH})
            else ()
              basis_include_directories (${${PKG_UPPER}_INCLUDE_PATH})
            endif ()
          elseif (${PKG}_INCLUDE_DIR OR ${PKG_UPPER}_INCLUDE_DIR)
            if (${PKG}_INCLUDE_DIR)
              basis_include_directories (${${PKG}_INCLUDE_DIR})
            else ()
              basis_include_directories (${${PKG_UPPER}_INCLUDE_DIR})
            endif ()  
          endif ()
        endif ()
      endif ()
      set (BASIS_USE_${PKG}_INCLUDED TRUE)
    elseif (ARGC GREATER 1 AND "${ARGV1}" MATCHES "^REQUIRED$")
      if (BASIS_DEBUG)
        basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterFind${PKG}.cmake")
      endif ()
      message (FATAL_ERROR "Package ${PACKAGE} not found!")
    endif ()
    unset (PKG_UPPER)
  endforeach ()
endmacro ()

# ============================================================================
# basis_get_filename_component / basis_get_relative_path
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Fixes CMake's
#         <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_filename_component">
#         get_filename_component()</a> command.
#
# The get_filename_component() command of CMake returns the entire portion
# after the first period (.) [including the period] as extension. However,
# only the component following the last period (.) [including the period]
# should be considered to be the extension.
#
# @note Consider the use of the basis_get_filename_component() macro as
#       an alias to emphasize that this function is different from CMake's
#       <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_filename_component">
#       get_filename_component()</a> command.
#
# @param [in,out] ARGN Arguments as accepted by get_filename_component().
#
# @returns Sets the variable named by the first argument to the requested
#          component of the given file path.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_filename_component
# @sa basis_get_filename_component()
function (get_filename_component)
  if (ARGC GREATER 4)
    message (FATAL_ERROR "[basis_]get_filename_component(): Too many arguments!")
  endif ()

  list (GET ARGN 0 VAR)
  list (GET ARGN 1 STR)
  list (GET ARGN 2 CMD)
  if (CMD MATCHES "^EXT")
    _get_filename_component (${VAR} "${STR}" ${CMD})
    string (REGEX MATCHALL "\\.[^.]*" PARTS "${${VAR}}")
    list (LENGTH PARTS LEN)
    if (LEN GREATER 1)
      math (EXPR LEN "${LEN} - 1")
      list (GET PARTS ${LEN} ${VAR})
    endif ()
  elseif (CMD MATCHES "NAME_WE")
    _get_filename_component (${VAR} "${STR}" NAME)
    string (REGEX REPLACE "\\.[^.]*$" "" ${VAR} ${${VAR}})
  else ()
    _get_filename_component (${VAR} "${STR}" ${CMD})
  endif ()
  if (ARGC EQUAL 4)
    if (NOT ARGV3 MATCHES "^CACHE$")
      message (FATAL_ERROR "[basis_]get_filename_component(): Invalid fourth argument: ${ARGV3}!")
    else ()
      set (${VAR} "${${VAR}}" CACHE STRING "")
    endif ()
  else ()
    set (${VAR} "${${VAR}}" PARENT_SCOPE)
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Alias for the overwritten get_filename_component() function.
#
# @sa get_filename_component()
#
# @ingroup CMakeAPI
macro (basis_get_filename_component)
  get_filename_component (${ARGN})
endmacro ()

# ----------------------------------------------------------------------------
## @brief Get path relative to a given base directory.
#
# Unlike the file(RELATIVE_PATH ...) command of CMake which if @p PATH and
# @p BASE are the same directory returns an empty string, this function
# returns a dot (.) in this case instead.
#
# @param [out] REL  @c PATH relative to @c BASE.
# @param [in]  BASE Path of base directory. If a relative path is given, it
#                   is made absolute using basis_get_filename_component()
#                   with ABSOLUTE as last argument.
# @param [in]  PATH Absolute or relative path. If a relative path is given
#                   it is made absolute using basis_get_filename_component()
#                   with ABSOLUTE as last argument.
#
# @returns Sets the variable named by the first argument to the relative path.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:file
#
# @ingroup CMakeAPI
function (basis_get_relative_path REL BASE PATH)
  basis_get_filename_component (PATH "${PATH}" ABSOLUTE)
  basis_get_filename_component (BASE "${BASE}" ABSOLUTE)
  if (NOT PATH)
    message (FATAL_ERROR "basis_get_relative_path(): No PATH given!")
  endif ()
  if (NOT BASE)
    message (FATAL_ERROR "basis_get_relative_path(): No BASE given!")
  endif ()
  file (RELATIVE_PATH P "${BASE}" "${PATH}")
  if ("${P}" STREQUAL "")
    set (P ".")
  endif ()
  set (${REL} "${P}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# name / version
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Convert string to lowercase only or mixed case.
#
# Strings in all uppercase or all lowercase are converted to all lowercase
# letters because these are usually used for acronymns. All other strings
# are returned unmodified with the one exception that the first letter has
# to be uppercase for mixed case strings.
#
# This function is in particular used to normalize the project name for use
# in installation directory paths and namespaces.
#
# @param [out] OUT String in CamelCase.
# @param [in]  STR String.
function (basis_normalize_name OUT STR)
  # strings in all uppercase or all lowercase such as acronymns are an
  # exception and shall be converted to all lowercase instead
  string (TOLOWER "${STR}" L)
  string (TOUPPER "${STR}" U)
  if ("${STR}" STREQUAL "${L}" OR "${STR}" STREQUAL "${U}")
    set (${OUT} "${L}" PARENT_SCOPE)
  # change first letter to uppercase
  else ()
    string (SUBSTRING "${U}"   0  1 A)
    string (SUBSTRING "${STR}" 1 -1 B)
    set (${OUT} "${A}${B}" PARENT_SCOPE)
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Extract version numbers from version string.
#
# @param [in]  VERSION Version string in the format "MAJOR[.MINOR[.PATCH]]".
# @param [out] MAJOR   Major version number if given or 0.
# @param [out] MINOR   Minor version number if given or 0.
# @param [out] PATCH   Patch number if given or 0.
#
# @returns See @c [out] parameters.
function (basis_version_numbers VERSION MAJOR MINOR PATCH)
  if (VERSION MATCHES "([0-9]+)\\.([0-9]+)rc[1-9][0-9]*")
    set (VERSION_MAJOR ${CMAKE_MATCH_1})
    set (VERSION_MINOR ${CMAKE_MATCH_2})
    set (VERSION_PATCH 0)
  else ()
    string (REGEX MATCHALL "[0-9]+" VERSION_PARTS "${VERSION}")
    list (LENGTH VERSION_PARTS VERSION_COUNT)

    if (VERSION_COUNT GREATER 0)
      list (GET VERSION_PARTS 0 VERSION_MAJOR)
    else ()
      set (VERSION_MAJOR "0")
    endif ()
    if (VERSION_COUNT GREATER 1)
      list (GET VERSION_PARTS 1 VERSION_MINOR)
    else ()
      set (VERSION_MINOR "0")
    endif ()
    if (VERSION_COUNT GREATER 2)
      list (GET VERSION_PARTS 2 VERSION_PATCH)
    else ()
      set (VERSION_PATCH "0")
    endif ()
  endif ()
  set ("${MAJOR}" "${VERSION_MAJOR}" PARENT_SCOPE)
  set ("${MINOR}" "${VERSION_MINOR}" PARENT_SCOPE)
  set ("${PATCH}" "${VERSION_PATCH}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# set
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Set variable.
#
# If the variable is cached, this function will update the cache value,
# otherwise, it simply sets the CMake variable uncached to the given value(s).
function (basis_set_or_update_cache VAR)
  if (DEFINED "${VAR}")
    get_property (CACHED CACHE "${VAR}" PROPERTY VALUE DEFINED)
  else ()
    set (CACHED FALSE)
  endif ()
  if (CACHED)
    if (ARGC GREATER 1)
      set_property (CACHE "${VAR}" PROPERTY VALUE ${ARGN})
    else ()
      set ("${VAR}" "" CACHE INTERNAL "" FORCE)
    endif ()
  else ()
    set ("${VAR}" ${ARGN} PARENT_SCOPE)
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Update cache variable.
function (basis_update_cache VAR)
  if (DEFINED "${VAR}")
    get_property (CACHED CACHE "${VAR}" PROPERTY VALUE DEFINED)
  else ()
    set (CACHED FALSE)
  endif ()
  if (CACHED)
    set_property (CACHE "${VAR}" PROPERTY VALUE ${ARGN})
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Set value of variable only if variable is not set already.
#
# @param [out] VAR  Name of variable.
# @param [in]  ARGN Arguments to set() command excluding variable name.
#
# @returns Sets @p VAR if its value was not valid before.
macro (basis_set_if_empty VAR)
  if (NOT "${VAR}")
    set ("${VAR}" ${ARGN})
  endif ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Set value of variable only if variable is not defined yet.
#
# @param [out] VAR  Name of variable.
# @param [in]  ARGN Arguments to set() command excluding variable name.
#
# @returns Sets @p VAR if it was not defined before.
macro (basis_set_if_not_set VAR)
  if (NOT DEFINED "${VAR}")
    set ("${VAR}" ${ARGN})
  endif ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Set path relative to script file.
#
# This function can be used in script configurations. It takes a variable
# name and a path as input arguments. If the given path is relative, it makes
# it first absolute using @c PROJECT_SOURCE_DIR. Then the path is made
# relative to the directory of the built script file. A CMake variable of the
# given name is set to the specified relative path. Optionally, a third
# argument, the path used for building the script for the install tree
# can be passed as well. If a relative path is given as this argument,
# it is made absolute by prefixing it with @c INSTALL_PREFIX instead.
#
# @note This function can only be used in script configurations such as
#       in particular the ScriptConfig.cmake.in file. The actual definition
#       of the function is generated by basis_add_script_finalize() and added
#       to the top of the build script. The definition in CommonTools.cmake
#       is only used to include the function in the API documentation.
#
# @param [out] VAR   Name of the variable.
# @param [in]  PATH  Path to directory or file.
# @param [in]  ARGV3 Path to directory or file inside install tree.
#                    If this argument is not given, PATH is used for both
#                    the build and install tree version of the script.
#
# @ingroup CMakeAPI
function (basis_set_script_path VAR PATH)
  message (FATAL_ERROR "This function can only be used in ScriptConfig.cmake.in!")
endfunction ()

# ============================================================================
# set/get any property
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Convert list into regular expression.
#
# This function is in particular used to convert a list of property names
# such as &lt;CONFIG&gt;_OUTPUT_NAME, e.g., the list @c BASIS_PROPERTIES_ON_TARGETS,
# into a regular expression which can be used in pattern matches.
#
# @param [out] REGEX Name of variable for resulting regular expression.
# @param [in]  ARGN  List of patterns which may contain placeholders in the
#                    form of "<this is a placeholder>". These are replaced
#                    by the regular expression "[^ ]+".
macro (basis_list_to_regex REGEX)
  string (REGEX REPLACE "<[^>]+>" "[^ ]+" ${REGEX} "${ARGN}")
  string (REGEX REPLACE ";" "|" ${REGEX} "${${REGEX}}")
  set (${REGEX} "^(${${REGEX}})$")
endmacro ()

# ----------------------------------------------------------------------------
## @brief Output current CMake variables to file.
function (basis_dump_variables RESULT_FILE)
  set (DUMP)
  get_cmake_property (VARIABLE_NAMES VARIABLES)
  foreach (V IN LISTS VARIABLE_NAMES)
    if (NOT V MATCHES "^_|^RESULT_FILE$|^ARGC$|^ARGV[0-9]?$")
      set (VALUE "${${V}}")
      # sanitize value for use in set() command
      string (REPLACE "\\" "\\\\" VALUE "${VALUE}") # escape backspaces
      string (REPLACE "\"" "\\\"" VALUE "${VALUE}") # escape double quotes
      # Escape ${VAR} by \${VAR} such that CMake does not evaluate it.
      # Escape $STR{VAR} by \$STR{VAR} such that CMake does not report a
      # syntax error b/c it expects either ${VAR}, $ENV{VAR}, or $CACHE{VAR}.
      # Escape @VAR@ by \@VAR\@ such that CMake does not evaluate it.
      string (REGEX REPLACE "([^\\])\\\$([^ ]*){" "\\1\\\\\$\\2{" VALUE "${VALUE}")
      string (REGEX REPLACE "([^\\])\\\@([^ ]*)\@" "\\1\\\\\@\\2\\\\\@" VALUE "${VALUE}")
      # append variable to output file
      set (DUMP "${DUMP}set (${V} \"${VALUE}\")\n")
    endif ()
  endforeach ()
  file (WRITE "${RESULT_FILE}" "# CMake variables dump created by BASIS\n${DUMP}")
endfunction ()

# ----------------------------------------------------------------------------
## @brief Set a named property in a given scope.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_property">
# set_property()</a> command.
#
# @param [in] SCOPE The argument for the @p SCOPE parameter of
#                   <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_property">
#                   set_property()</a>.
# @param [in] ARGN  Arguments as accepted by.
#                   <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_property">
#                   set_property()</a>.
#
# @returns Sets the specified property.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:set_property
#
# @ingroup CMakeAPI
function (basis_set_property SCOPE)
  if (SCOPE MATCHES "^TARGET$|^TEST$")
    # map target/test names to UIDs
    list (LENGTH ARGN ARGN_LENGTH)
    if (ARGN_LENGTH EQUAL 0)
      message (FATAL_ERROR "basis_set_property(${SCOPE}): Expected arguments after SCOPE!")
    endif ()
    set (IDX 0)
    set (ARG)
    while (IDX LESS ARGN_LENGTH)
      list (GET ARGN ${IDX} ARG)
      if (ARG MATCHES "^APPEND$")
        math (EXPR IDX "${IDX} + 1")
        list (GET ARGN ${IDX} ARG)
        if (NOT ARG MATCHES "^PROPERTY$")
          message (FATAL_ERROR "basis_set_properties(${SCOPE}): Expected PROPERTY keyword after APPEND!")
        endif ()
        break ()
      elseif (ARG MATCHES "^PROPERTY$")
        break ()
      else ()
        if (SCOPE MATCHES "^TEST$")
          basis_get_test_uid (UID "${ARG}")
        else ()
          basis_get_target_uid (UID "${ARG}")
        endif ()
        list (INSERT ARGN ${IDX} "${UID}")
        math (EXPR IDX "${IDX} + 1")
        list (REMOVE_AT ARGN ${IDX}) # after insert to avoid index out of range
      endif ()
    endwhile ()
    if (IDX EQUAL ARGN_LENGTH)
      message (FATAL_ERROR "basis_set_properties(${SCOPE}): Missing PROPERTY keyword!")
    endif ()
    math (EXPR IDX "${IDX} + 1")
    list (GET ARGN ${IDX} ARG)
    # property name matches DEPENDS
    if (ARG MATCHES "DEPENDS")
      math (EXPR IDX "${IDX} + 1")
      while (IDX LESS ARGN_LENGTH)
        list (GET ARGN ${IDX} ARG)
        if (SCOPE MATCHES "^TEST$")
          basis_get_test_uid (UID "${ARG}")
        else ()
          basis_get_target_uid (UID "${ARG}")
        endif ()
        list (INSERT ARGN ${IDX} "${UID}")
        math (EXPR IDX "${IDX} + 1")
        list (REMOVE_AT ARGN ${IDX}) # after insert ot avoid index out of range
      endwhile ()
    endif ()
  endif ()
  if (BASIS_DEBUG)
    message ("** basis_set_property():")
    message ("**   Scope:     ${SCOPE}")
    message ("**   Arguments: [${ARGN}]")
  endif ()
  set_property (${SCOPE} ${ARGN})
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get a property.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_property">
# get_property()</a> command.
#
# @param [out] VAR     Property value.
# @param [in]  SCOPE   The argument for the @p SCOPE argument of
#                      <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_property">
#                      get_property()</a>.
# @param [in]  ELEMENT The argument for the @p ELEMENT argument of
#                      <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_property">
#                      get_property()</a>.
# @param [in]  ARGN    Arguments as accepted by
#                      <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_property">
#                      get_property()</a>.
#
# @returns Sets @p VAR to the value of the requested property.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:get_property
#
# @ingroup CMakeAPI
function (basis_get_property VAR SCOPE ELEMENT)
  if (SCOPE MATCHES "^TARGET$")
    basis_get_target_uid (ELEMENT "${ELEMENT}")
  elseif (SCOPE MATCHES "^TEST$")
    basis_get_test_uid (ELEMENT "${ELEMENT}")
  endif ()
  get_property (VALUE ${SCOPE} ${ELEMENT} ${ARGN})
  set ("${VAR}" "${VALUE}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Set project-global property.
#
# Set property associated with current project/module. The property is in
# fact just a cached variable whose name is prefixed by the project's name.
function (basis_set_project_property)
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "APPEND"
      "PROJECT"
      "PROPERTY"
    ${ARGN}
  )

  if (NOT ARGN_PROJECT)
    set (ARGN_PROJECT "${PROJECT_NAME}")
  endif ()
  if (NOT ARGN_PROPERTY)
    message (FATAL_ERROR "Missing PROPERTY argument!")
  endif ()

  list (GET ARGN_PROPERTY 0 PROPERTY_NAME)
  list (REMOVE_AT ARGN_PROPERTY 0) # remove property name from values

  if (ARGN_APPEND)
    basis_get_project_property (CURRENT PROPERTY ${PROPERTY_NAME})
    if (NOT "${CURRENT}" STREQUAL "")
      list (INSERT ARGN_PROPERTY 0 "${CURRENT}")
    endif ()
  endif ()

  set (
    ${ARGN_PROJECT}_${PROPERTY_NAME}
      "${ARGN_PROPERTY}"
    CACHE INTERNAL
      "Property ${PROPERTY_NAME} of project ${ARGN_PROJECT}."
    FORCE
  )
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get project-global property value.
#
# Example:
# @code
# basis_get_project_property(TARGETS)
# basis_get_project_property(TARGETS ${PROJECT_NAME})
# basis_get_project_property(TARGETS ${PROJECT_NAME} TARGETS)
# basis_get_project_property(TARGETS PROPERTY TARGETS)
# @endcode
#
# @param [out] VARIABLE Name of result variable.
# @param [in]  ARGN     See the example uses. The optional second argument
#                       is either the name of the project similar to CMake's
#                       get_target_property() command or the keyword PROPERTY
#                       followed by the name of the property.
function (basis_get_project_property VARIABLE)
  if (ARGC GREATER 3)
    message (FATAL_ERROR "Too many arguments!")
  endif ()
  if (ARGC EQUAL 1)
    set (ARGN_PROJECT "${PROJECT_NAME}")
    set (ARGN_PROPERTY "${VARIABLE}")
  elseif (ARGC EQUAL 2)
    if (ARGV1 MATCHES "^PROPERTY$")
      message (FATAL_ERROR "Expected argument after PROPERTY keyword!")
    endif ()
    set (ARGN_PROJECT  "${ARGV1}")
    set (ARGN_PROPERTY "${VARIABLE}")
  else ()
    if (ARGV1 MATCHES "^PROPERTY$")
      set (ARGN_PROJECT "${PROJECT_NAME}")
    else ()
      set (ARGN_PROJECT  "${ARGV1}")
    endif ()
    set (ARGN_PROPERTY "${ARGV2}")
  endif ()
  set (${VARIABLE} "${${ARGN_PROJECT}_${ARGN_PROPERTY}}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# list / string manipulations
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Sanitize string variable for use in regular expression.
#
# @note This function may not work for all cases, but is used in particular
#       to sanitize project names, target names, namespace identifiers,...
#
# @param [out] OUT String that can be used in regular expression.
# @param [in]  STR String to sanitize.
macro (basis_sanitize_for_regex OUT STR)
  string (REGEX REPLACE "([.+*?^$])" "\\\\\\1" ${OUT} "${STR}")
endmacro ()

# ----------------------------------------------------------------------------
## @brief Concatenates all list elements into a single string.
#
# The list elements are concatenated without any delimiter in between.
# Use basis_list_to_delimited_string() to specify a delimiter such as a
# whitespace character or comma (,) as delimiter.
#
# @param [out] STR  Output string.
# @param [in]  ARGN Input list.
#
# @returns Sets @p STR to the resulting string.
#
# @sa basis_list_to_delimited_string()
function (basis_list_to_string STR)
  set (OUT)
  foreach (ELEM ${ARGN})
    set (OUT "${OUT}${ELEM}")
  endforeach ()
  set ("${STR}" "${OUT}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Concatenates all list elements into a single delimited string.
#
# @param [out] STR   Output string.
# @param [in]  DELIM Delimiter used to separate list elements.
#                    Each element which contains the delimiter as substring
#                    is surrounded by double quotes (") in the output string.
# @param [in]  ARGN  Input list. If this list starts with the argument
#                    @c NOAUTOQUOTE, the automatic quoting of list elements
#                    which contain the delimiter is disabled.
#
# @returns Sets @p STR to the resulting string.
function (basis_list_to_delimited_string STR DELIM)
  set (OUT)
  set (AUTOQUOTE TRUE)
  if (ARGN)
    list (GET ARGN 0 FIRST)
    if (FIRST MATCHES "^NOAUTOQUOTE$")
      list (REMOVE_AT ARGN 0)
      set (AUTOQUOTE FALSE)
    endif ()
  endif ()
  foreach (ELEM ${ARGN})
    if (OUT)
      set (OUT "${OUT}${DELIM}")
    endif ()
    if (AUTOQUOTE AND ELEM MATCHES "${DELIM}")
      set (OUT "${OUT}\"${ELEM}\"")
    else ()
      set (OUT "${OUT}${ELEM}")
    endif ()
  endforeach ()
  set ("${STR}" "${OUT}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Splits a string at space characters into a list.
#
# @todo Probably this can be done in a better way...
#       Difficulty is, that string(REPLACE) does always replace all
#       occurrences. Therefore, we need a regular expression which matches
#       the entire string. More sophisticated regular expressions should do
#       a better job, though.
#
# @param [out] LST  Output list.
# @param [in]  STR  Input string.
#
# @returns Sets @p LST to the resulting CMake list.
function (basis_string_to_list LST STR)
  set (TMP "${STR}")
  set (OUT)
  # 1. extract elements such as "a string with spaces"
  while (TMP MATCHES "\"[^\"]*\"")
    string (REGEX REPLACE "^(.*)\"([^\"]*)\"(.*)$" "\\1\\3" TMP "${TMP}")
    if (OUT)
      set (OUT "${CMAKE_MATCH_2};${OUT}")
    else (OUT)
      set (OUT "${CMAKE_MATCH_2}")
    endif ()
  endwhile ()
  # 2. extract other elements separated by spaces (excluding first and last)
  while (TMP MATCHES " [^\" ]+ ")
    string (REGEX REPLACE "^(.*) ([^\" ]+) (.*)$" "\\1\\3" TMP "${TMP}")
    if (OUT)
      set (OUT "${CMAKE_MATCH_2};${OUT}")
    else (OUT)
      set (OUT "${CMAKE_MATCH_2}")
    endif ()
  endwhile ()
  # 3. extract first and last elements (if not done yet)
  if (TMP MATCHES "^[^\" ]+")
    set (OUT "${CMAKE_MATCH_0};${OUT}")
  endif ()
  if (NOT "${CMAKE_MATCH_0}" STREQUAL "${TMP}" AND TMP MATCHES "[^\" ]+$")
    set (OUT "${OUT};${CMAKE_MATCH_0}")
  endif ()
  # return resulting list
  set (${LST} "${OUT}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# name <=> UID
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Derive target name from source file name.
#
# @param [out] TARGET_NAME Target name.
# @param [in]  SOURCE_FILE Source file.
# @param [in]  ARGN        Third argument to get_filename_component().
#                          If not specified, the given path is only sanitized.
#
# @returns Target name derived from @p SOURCE_FILE.
function (basis_get_source_target_name TARGET_NAME SOURCE_FILE)
  # remove ".in" suffix from file name
  string (REGEX REPLACE "\\.in$" "" OUT "${SOURCE_FILE}")
  # get name component
  if (ARGC GREATER 2)
    get_filename_component (OUT "${OUT}" ${ARGV2})
  endif ()
  # replace special characters
  string (REGEX REPLACE "[./\\]" "_" OUT "${OUT}")
  # return
  set (${TARGET_NAME} "${OUT}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Make target UID from given target name.
#
# This function is intended for use by the basis_add_*() functions only.
#
# @param [out] TARGET_UID  "Global" target name, i.e., actual CMake target name.
# @param [in]  TARGET_NAME Target name used as argument to BASIS CMake functions.
#
# @returns Sets @p TARGET_UID to the UID of the build target @p TARGET_NAME.
#
# @sa basis_get_target_uid()
macro (basis_make_target_uid TARGET_UID TARGET_NAME)
  set ("${TARGET_UID}" "${PROJECT_NAMESPACE_CMAKE}.${TARGET_NAME}")
  # strip off top-level namespace part (optional)
  if (NOT BASIS_USE_FULLY_QUALIFIED_UIDS)
    string (
      REGEX REPLACE
        "^${BASIS_PROJECT_NAMESPACE_CMAKE_REGEX}\\."
        ""
      "${TARGET_UID}"
        "${${TARGET_UID}}"
    )
  endif ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Get "global" target name, i.e., actual CMake target name.
#
# In order to ensure that CMake target names are unique across modules of
# a BASIS project, the target name given to the BASIS CMake functions is
# converted by basis_make_target_uid() into a so-called target UID which is
# used as actual CMake target name. This function can be used to get for a
# given target name or UID the closest match of a known target UID.
#
# In particular, if this project is a module of another BASIS project, the
# namespace given by @c PROJECT_NAMESPACE_CMAKE is used as prefix, where the
# namespace prefix and the build target name are separated by a dot (.).
# Otherwise, if this project is the top-level project, no namespace prefix is
# used and if the project's namespace is given as prefix, it will be removed.
# When the target is exported, however, the namespace of this project will be
# prefixed again. This is done by the basis_export_targets() function.
#
# Note that names of imported targets are not prefixed in any case.
#
# The counterpart basis_get_target_name() can be used to convert the target UID
# back to the target name without namespace prefix.
#
# @note At the moment, BASIS does not support modules which themselves have
#       modules again. This would require a more nested namespace hierarchy.
#
# @param [out] TARGET_UID  "Global" target name, i.e., actual CMake target name.
# @param [in]  TARGET_NAME Target name used as argument to BASIS CMake functions.
#
# @returns Sets @p TARGET_UID to the UID of the build target @p TARGET_NAME.
#
# @sa basis_get_target_name()
function (basis_get_target_uid TARGET_UID TARGET_NAME)
  # in case of a leading namespace separator, do not modify target name
  if (TARGET_NAME MATCHES "^\\.")
    set (UID "${TARGET_NAME}")
  # otherwise,
  else ()
    set (UID "${TARGET_NAME}")
    # try prepending namespace or parts of it until target is known
    if (BASIS_DEBUG AND BASIS_VERBOSE)
      message ("** basis_get_target_uid()")
    endif ()
    set (PREFIX "${PROJECT_NAMESPACE_CMAKE}")
    if (NOT BASIS_USE_FULLY_QUALIFIED_UIDS)
      string (
        REGEX REPLACE
          "^${BASIS_PROJECT_NAMESPACE_CMAKE_REGEX}\\."
          ""
        PREFIX
          "${PREFIX}"
      )
    endif ()
    while (PREFIX)
      if (BASIS_DEBUG AND BASIS_VERBOSE)
        message ("**     Trying: ${PREFIX}.${TARGET_NAME}")
      endif ()
      if (TARGET "${PREFIX}.${TARGET_NAME}")
        set (UID "${PREFIX}.${TARGET_NAME}")
        break ()
      else ()
        if (PREFIX MATCHES "(.*)\\.[^.]+")
          set (PREFIX "${CMAKE_MATCH_1}")
        else ()
          break ()
        endif ()
      endif ()
    endwhile ()
  endif ()
  # strip off top-level namespace part (optional)
  if (NOT BASIS_USE_FULLY_QUALIFIED_UIDS)
    string (
      REGEX REPLACE
        "^${BASIS_PROJECT_NAMESPACE_CMAKE_REGEX}\\."
        ""
      UID
        "${UID}"
    )
  endif ()
  # return
  if (BASIS_DEBUG AND BASIS_VERBOSE)
    message ("** basis_get_target_uid(): ${TARGET_NAME} -> ${UID}")
  endif ()
  set ("${TARGET_UID}" "${UID}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get fully-qualified target name.
#
# This function always returns a fully-qualified target UID, no matter if
# the option @c BASIS_USE_FULLY_QUALIFIED_UIDS is @c OFF. Note that
# if this option is @c ON, the returned target UID is may not be the
# actual name of a CMake target.
#
# @param [out] TARGET_UID  Fully-qualified target UID.
# @param [in]  TARGET_NAME Target name used as argument to BASIS CMake functions.
#
# @sa basis_get_target_uid()
function (basis_get_fully_qualified_target_uid TARGET_UID TARGET_NAME)
  basis_get_target_uid (UID "${TARGET_NAME}")
  if (NOT BASIS_USE_FULLY_QUALIFIED_UIDS)
    get_target_property (IMPORTED "${UID}" IMPORTED)
    if (NOT IMPORTED)
      set (UID "${BASIS_PROJECT_NAMESPACE_CMAKE}.${UID}")
    endif ()
  endif ()
  set ("${TARGET_UID}" "${UID}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get namespace of build target.
#
# @param [out] TARGET_NS  Namespace part of target UID.
# @param [in]  TARGET_UID Target UID/name.
function (basis_get_target_namespace TARGET_NS TARGET_UID)
  # make sure we have a fully-qualified target UID
  basis_get_fully_qualified_target_uid (UID "${TARGET_UID}")
  # return namespace part
  if (UID MATCHES "^(.*)\\.")
    set ("${TARGET_NS}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
  else ()
    set ("${TARGET_NS}" "" PARENT_SCOPE)
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get "local" target name, i.e., BASIS target name.
#
# @param [out] TARGET_NAME Target name used as argument to BASIS functions.
# @param [in]  TARGET_UID  "Global" target name, i.e., actual CMake target name.
#
# @returns Sets @p TARGET_NAME to the name of the build target with UID @p TARGET_UID.
#
# @sa basis_get_target_uid()
function (basis_get_target_name TARGET_NAME TARGET_UID)
  # make sure we have a fully-qualified target UID
  basis_get_fully_qualified_target_uid (UID "${TARGET_UID}")
  # strip off namespace of current project
  string (REGEX REPLACE "^${PROJECT_NAMESPACE_CMAKE_REGEX}\\." "" NAME "${UID}")
  # return
  if (BASIS_DEBUG AND BASIS_VERBOSE)
    message ("** basis_get_target_name(): ${UID} -> ${NAME}")
  endif ()
  set ("${TARGET_NAME}" "${NAME}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Checks whether a given name is a valid target name.
#
# Displays fatal error message when target name is invalid.
#
# @param [in] TARGET_NAME Desired target name.
#
# @returns Nothing.
function (basis_check_target_name TARGET_NAME)
  # reserved target name ?
  foreach (PATTERN IN LISTS BASIS_RESERVED_TARGET_NAMES)
    if (TARGET_NAME MATCHES "^${PATTERN}$")
      message (FATAL_ERROR "Target name \"${TARGET_NAME}\" is reserved and cannot be used.")
    endif ()
  endforeach ()
  # invalid target name ?
  if (NOT TARGET_NAME MATCHES "^[a-zA-Z]([a-zA-Z0-9_+]|-)*$|^__init__(_py)?$")
    message (FATAL_ERROR "Target name '${TARGET_NAME}' is invalid.\nChoose a target name"
                         " which only contains alphanumeric characters,"
                         " '_', '-', or '+', and starts with a letter."
                         " The only exception from this rule is __init__[_py] for"
                         " a __init__.py script.\n")
  endif ()

  # unique ?
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")

  if (TARGET "${TARGET_UID}")
    message (FATAL_ERROR "There exists already a target named ${TARGET_UID}."
                         " Target names must be unique.")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Make test UID from given test name.
#
# This function is intended for use by the basis_add_test() only.
#
# @param [out] TEST_UID  "Global" test name, i.e., actual CTest test name.
# @param [in]  TEST_NAME Test name used as argument to BASIS CMake functions.
#
# @returns Sets @p TEST_UID to the UID of the test @p TEST_NAME.
#
# @sa basis_get_test_uid()
macro (basis_make_test_uid TEST_UID TEST_NAME)
  basis_make_target_uid ("${TEST_UID}" "${TEST_NAME}")
endmacro ()

# ----------------------------------------------------------------------------
## @brief Get "global" test name, i.e., actual CTest test name.
#
# In order to ensure that CTest test names are unique across BASIS projects,
# the test name used by a developer of a BASIS project is converted by this
# function into another test name which is used as acutal CTest test name.
#
# The function basis_get_test_name() can be used to convert the unique test
# name, the test UID, back to the original test name passed to this function.
#
# @param [out] TEST_UID  "Global" test name, i.e., actual CTest test name.
# @param [in]  TEST_NAME Test name used as argument to BASIS CMake functions.
#
# @returns Sets @p TEST_UID to the UID of the test @p TEST_NAME.
#
# @sa basis_get_test_name()
macro (basis_get_test_uid TEST_UID TEST_NAME)
  if (TEST_NAME MATCHES "\\.")
    set ("${TEST_UID}" "${TEST_NAME}")
  else ()
    set ("${TEST_UID}" "${PROJECT_NAMESPACE_CMAKE}.${TEST_NAME}")
  endif ()
  # strip off top-level namespace part (optional)
  if (NOT BASIS_USE_FULLY_QUALIFIED_UIDS)
    string (
      REGEX REPLACE
        "^${BASIS_PROJECT_NAMESPACE_CMAKE_REGEX}\\."
        ""
      "${TEST_UID}"
        "${${TEST_UID}}"
    )
  endif ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Get "global" test name, i.e., actual CTest test name.
#
# This function always returns a fully-qualified test UID, no matter if
# the option @c BASIS_USE_FULLY_QUALIFIED_UIDS is @c OFF. Note that
# if this option is @c ON, the returned test UID may not be the
# actual name of a CMake test.
#
# @param [out] TEST_UID  Fully-qualified test UID.
# @param [in]  TEST_NAME Test name used as argument to BASIS CMake functions.
#
# @sa basis_get_test_uid()
macro (basis_get_fully_qualified_test_uid TEST_UID TEST_NAME)
  if (TEST_NAME MATCHES "\\.")
    set ("${TEST_UID}" "${TEST_NAME}")
  else ()
    set ("${TEST_UID}" "${PROJECT_NAMESPACE_CMAKE}.${TEST_NAME}")
  endif ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Get namespace of test.
#
# @param [out] TEST_NS  Namespace part of test UID. If @p TEST_UID is
#                       no UID, i.e., does not contain a namespace part,
#                       the namespace of this project is returned.
# @param [in]  TEST_UID Test UID/name.
macro (basis_get_test_namespace TEST_NS TEST_UID)
  if (TEST_UID MATCHES "^(.*)\\.")
    set ("${TEST_NS}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
  else ()
    set ("${TEST_NS}" "" PARENT_SCOPE)
  endif ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Get "local" test name, i.e., BASIS test name.
#
# @param [out] TEST_NAME Test name used as argument to BASIS functions.
# @param [in]  TEST_UID  "Global" test name, i.e., actual CTest test name.
#
# @returns Sets @p TEST_NAME to the name of the test with UID @p TEST_UID.
#
# @sa basis_get_test_uid()
macro (basis_get_test_name TEST_NAME TEST_UID)
  if (TEST_UID MATCHES "([^.]+)$")
    set ("${TEST_NAME}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
  else ()
    set ("${TEST_NAME}" "" PARENT_SCOPE)
  endif ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Checks whether a given name is a valid test name.
#
# Displays fatal error message when test name is invalid.
#
# @param [in] TEST_NAME Desired test name.
#
# @returns Nothing.
function (basis_check_test_name TEST_NAME)
  # reserved test name ?
  foreach (PATTERN IN LISTS BASIS_RESERVED_TARGET_NAMES)
    if (TARGET_NAME MATCHES "^${PATTERN}$")
      message (FATAL_ERROR "Test name \"${TARGET_NAME}\" is reserved and cannot be used.")
    endif ()
  endforeach ()
  # invalid test name ?
  if (NOT TEST_NAME MATCHES "^[a-zA-Z]([a-zA-Z0-9_+]|-)*$")
    message (FATAL_ERROR "Test name ${TEST_NAME} is invalid.\nChoose a test name "
                         " which only contains alphanumeric characters,"
                         " '_', '-', or '+', and starts with a letter.\n")
  endif ()
endfunction ()

# ============================================================================
# common target tools
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Detect programming language of given source code files.
#
# This function determines the programming language in which the given source
# code files are written. If no common programming language could be determined,
# "AMBIGUOUS" is returned. If none of the following programming languages
# could be determined, "UNKNOWN" is returned: CXX (i.e., C++), JAVA,
# JAVASCRIPT, PYTHON, PERL, BASH, BATCH, MATLAB.
#
# @param [out] LANGUAGE Detected programming language.
# @param [in]  ARGN     List of source code files.
function (basis_get_source_language LANGUAGE)
  set (LANGUAGE_OUT)
  # iterate over source files
  foreach (SOURCE_FILE ${ARGN})
    # ignore .in suffix
    string (REGEX REPLACE "\\.in$" "" SOURCE_FILE "${SOURCE_FILE}")
    # C++
    if (SOURCE_FILE MATCHES "\\.(c|cc|cpp|cxx|h|hpp|hxx|txx|inl)$")
      set (LANG "CXX")
    # Java
    elseif (SOURCE_FILE MATCHES "\\.java$")
      set (LANG "JAVA")
    # JavaScript
    elseif (SOURCE_FILE MATCHES "\\.js$")
      set (LANG "JAVASCRIPT")
    # Python
    elseif (SOURCE_FILE MATCHES "\\.py$")
      set (LANG "PYTHON")
    # Perl
    elseif (SOURCE_FILE MATCHES "\\.(pl|pm|t)$")
      set (LANG "PERL")
    # BASH
    elseif (SOURCE_FILE MATCHES "\\.sh$")
      set (LANG "BASH")
    # Batch
    elseif (SOURCE_FILE MATCHES "\\.bat$")
      set (LANG "BATCH")
    # MATLAB
    elseif (SOURCE_FILE MATCHES "\\.m$")
      set (LANG "MATLAB")
    # unknown
    else ()
      set (LANGUAGE_OUT "UNKNOWN")
      break ()
    endif ()
    # detect ambiguity
    if (LANGUAGE_OUT AND NOT LANG MATCHES "${LANGUAGE_OUT}")
      if (LANGUAGE_OUT MATCHES "CXX" AND LANG MATCHES "MATLAB")
        # MATLAB Compiler can handle this...
      elseif (LANGUAGE_OUT MATCHES "MATLAB" AND LANG MATCHES "CXX")
        # language stays MATLAB
        set (LANG "MATLAB")
      else ()
        # ambiguity
        set (LANGUAGE_OUT "AMBIGUOUS")
        break ()
      endif ()
    endif ()
    # update current language
    set (LANGUAGE_OUT "${LANG}")
  endforeach ()
  # return
  set (${LANGUAGE} "${LANGUAGE_OUT}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Configure .in source files.
#
# This function configures each source file in the given argument list with
# a .in file name suffix and stores the configured file in the build tree
# with the same relative directory as the template source file itself.
# The first argument names the CMake variable of the list of configured
# source files where each list item is the absolute file path of the
# corresponding (configured) source file.
#
# @param [out] LIST_NAME Name of output list.
# @param [in]  ARGN      These arguments are parsed and the following
#                        options recognized. All remaining arguments are
#                        considered to be source file paths.
# @par
# <table border="0">
#   <tr>
#     @tp @b BINARY_DIRECTORY @endtp
#     <td>Explicitly specify directory in build tree where configured
#         source files should be written to.</td>
#   </tr>
#   <tr>
#     @tp @b KEEP_DOT_IN_SUFFIX @endtp
#     <td>By default, after a source file with the .in extension has been
#         configured, the .in suffix is removed from the file name.
#         This can be omitted by giving this option.</td>
#   </tr>
# </table>
#
# @returns Nothing.
function (basis_configure_sources LIST_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "KEEP_DOT_IN_SUFFIX" "BINARY_DIRECTORY" "" ${ARGN})

  if (ARGN_BINARY_DIRECTORY AND NOT ARGN_BINARY_DIRECTORY MATCHES "^${PROJECT_BINARY_DIR}")
    message (FATAL_ERROR "Specified BINARY_DIRECTORY must be inside the build tree!")
  endif ()

  # configure source files
  set (CONFIGURED_SOURCES)
  foreach (SOURCE ${ARGN_UNPARSED_ARGUMENTS})
    # The .in suffix is optional, add it here if a .in file exists for this
    # source file, but only if the source file itself does not name an actually
    # existing source file.
    #
    # If the source file path is relative, prefer possibly already configured
    # sources in build tree such as the test driver source file created by
    # create_test_sourcelist() or a manual use of configure_file().
    #
    # Note: Make path absolute, otherwise EXISTS check will not work!
    if (NOT IS_ABSOLUTE "${SOURCE}")
      if (EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}")
        set (SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}")
      elseif (EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}.in")
        set (SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE}.in")
      elseif (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}")
        set (SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}")
      elseif (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}.in")
        set (SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}.in")
      endif ()
    else ()
      if (NOT EXISTS "${SOURCE}" AND EXISTS "${SOURCE}.in")
        set (SOURCE "${SOURCE}.in")
      endif ()
    endif ()
    # configure source file if filename ends in .in suffix
    if (SOURCE MATCHES "\\.in$")
      # if binary directory was given explicitly, use it
      if (ARGN_BINARY_DIRECTORY)
        get_filename_component (SOURCE_NAME "${SOURCE}" NAME)
        if (NOT ARGN_KEEP_DOT_IN_SUFFIX)
          string (REGEX REPLACE "\\.in$" "" SOURCE_NAME "${SOURCE_NAME}")
        endif ()
        set (CONFIGURED_SOURCE "${ARGN_BINARY_DIRECTORY}/${SOURCE_NAME}")
      # otherwise,
      else ()
        # if source is in project's source tree use relative binary directory
        basis_sanitize_for_regex (REGEX "${PROJECT_SOURCE_DIR}")
        if (SOURCE MATCHES "^${REGEX}")
          basis_get_relative_path (CONFIGURED_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}" "${SOURCE}")
          get_filename_component (CONFIGURED_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${CONFIGURED_SOURCE}" ABSOLUTE)
          if (NOT ARGN_KEEP_DOT_IN_SUFFIX)
            string (REGEX REPLACE "\\.in$" "" CONFIGURED_SOURCE "${CONFIGURED_SOURCE}")
          endif ()
        # otherwise, use current binary directory
        else ()
          get_filename_component (SOURCE_NAME "${SOURCE}" NAME)
          if (NOT ARGN_KEEP_DOT_IN_SUFFIX)
            string (REGEX REPLACE "\\.in$" "" SOURCE_NAME "${SOURCE_NAME}")
          endif ()
          set (CONFIGURED_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/${SOURCE_NAME}")
        endif ()
      endif ()
      # configure source file
      configure_file ("${SOURCE}" "${CONFIGURED_SOURCE}" @ONLY)
      if (BASIS_DEBUG)
        message ("** Configured source file with .in extension")
      endif ()
    # otherwise, skip configuration of this source file
    else ()
      set (CONFIGURED_SOURCE "${SOURCE}")
      if (BASIS_DEBUG)
        message ("** Skipped configuration of source file")
      endif ()
    endif ()
    if (BASIS_DEBUG)
      message ("**     Source:            ${SOURCE}")
      message ("**     Configured source: ${CONFIGURED_SOURCE}")
    endif ()
    list (APPEND CONFIGURED_SOURCES "${CONFIGURED_SOURCE}")
  endforeach ()
  # return
  set (${LIST_NAME} "${CONFIGURED_SOURCES}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get type name of target.
#
# @param [out] TYPE        The target's type name or NOTFOUND.
# @param [in]  TARGET_NAME The name of the target.
function (basis_get_target_type TYPE TARGET_NAME)
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")
  if (TARGET ${TARGET_UID})
    get_target_property (TYPE_OUT ${TARGET_UID} "BASIS_TYPE")
    if (NOT TYPE_OUT)
      # in particular imported targets may not have a BASIS_TYPE property
      get_target_property (TYPE_OUT ${TARGET_UID} "TYPE")
    endif ()
  else ()
    set (TYPE_OUT "NOTFOUND")
  endif ()
  set ("${TYPE}" "${TYPE_OUT}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get location of build target output file.
#
# This convenience function can be used to get the full path of the output
# file generated by a given build target. It is similar to the read-only
# @c LOCATION property of CMake targets and should be used instead of
# reading this porperty.
#
# @param [out] VAR         Path of build target output file.
# @param [in]  TARGET_NAME Name of build target.
# @param [in]  PART        Which file name component of the @c LOCATION
#                          property to return. See get_filename_component().
#                          If POST_INSTALL_RELATIVE is given as argument,
#                          @p VAR is set to the path of the installed file
#                          relative to the installation prefix. Similarly,
#                          POST_INSTALL sets @p VAR to the absolute path
#                          of the installed file post installation.
#
# @returns Path of output file similar to @c LOCATION property of CMake targets.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#prop_tgt:LOCATION
function (basis_get_target_location VAR TARGET_NAME PART)
  basis_get_target_uid (TARGET_UID "${TARGET_NAME}")
  if (TARGET "${TARGET_UID}")
    basis_get_target_name (TARGET_NAME "${TARGET_UID}")
    basis_get_target_type (TYPE        "${TARGET_UID}")
    get_target_property (IMPORTED ${TARGET_UID} "IMPORTED")

    # ------------------------------------------------------------------------
    # imported custom targets
    #
    # Note: This might not be required though as even custom executable
    #       and library targets can be imported using CMake's
    #       add_executable(<NAME> IMPORTED) and add_library(<NAME> <TYPE> IMPORTED)
    #       commands. Such executable can, for example, also be a BASH
    #       script built by basis_add_script().

    if (IMPORTED)

      # 1. Try IMPORTED_LOCATION_<CMAKE_BUILD_TYPE>
      if (CMAKE_BUILD_TYPE)
        string (TOUPPER "${CMAKE_BUILD_TYPE}" U)
      else ()
        set (U "NOCONFIG")
      endif ()
      get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION_${U}")
      # 2. Try IMPORTED_LOCATION
      if (NOT LOCATION)
        get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION")
      endif ()
      # 3. Prefer Release over all other configurations
      if (NOT LOCATION)
        get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION_RELEASE")
      endif ()
      # 4. Just use any of the imported configurations
      if (NOT LOCATION)
        get_property (CONFIGS TARGET "${TARGET_UID}" PROPERTY IMPORTED_CONFIGURATIONS)
        foreach (C IN LISTS CONFIGS)
          get_target_property (LOCATION ${TARGET_UID} "IMPORTED_LOCATION_${C}")
          if (LOCATION)
            break ()
          endif ()
        endforeach ()
      endif ()

      # Make path relative to INSTALL_PREFIX if POST_INSTALL_PREFIX given
      if (LOCATION AND ARGV2 MATCHES "POST_INSTALL_RELATIVE")
        file (RELATIVE_PATH LOCATION "${INSTALL_PREFIX}" "${LOCATION}")
      endif ()

    # ------------------------------------------------------------------------
    # non-imported custom targets

    else ()

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # libraries

      if (TYPE MATCHES "LIBRARY|MODULE|MEX")

        if (TYPE MATCHES "STATIC")
          if (PART MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
            get_target_property (DIRECTORY "${TARGET_UID}" "ARCHIVE_INSTALL_DIRECTORY")
          endif ()
          if (NOT DIRECTORY)
            get_target_property (DIRECTORY "${TARGET_UID}" "ARCHIVE_OUTPUT_DIRECTORY")
          endif ()
          get_target_property (FNAME "${TARGET_UID}" "ARCHIVE_OUTPUT_NAME")
        else ()
          if (PART MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
            get_target_property (DIRECTORY "${TARGET_UID}" "LIBRARY_INSTALL_DIRECTORY")
          endif ()
          if (NOT DIRECTORY)
            get_target_property (DIRECTORY "${TARGET_UID}" "LIBRARY_OUTPUT_DIRECTORY")
          endif ()
          get_target_property (FNAME "${TARGET_UID}" "LIBRARY_OUTPUT_NAME")
        endif ()

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # executables

      else ()

        if (PART MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
          get_target_property (DIRECTORY "${TARGET_UID}" "RUNTIME_INSTALL_DIRECTORY")
        endif ()
        if (NOT DIRECTORY)
          get_target_property (DIRECTORY "${TARGET_UID}" "RUNTIME_OUTPUT_DIRECTORY")
        endif ()
        get_target_property (FNAME "${TARGET_UID}" "RUNTIME_OUTPUT_NAME")
      endif ()
      if (NOT FNAME)
        get_target_property (FNAME "${TARGET_UID}" "OUTPUT_NAME")
      endif ()
      get_target_property (PREFIX "${TARGET_UID}" "PREFIX")
      get_target_property (SUFFIX "${TARGET_UID}" "SUFFIX")

      if (FNAME)
        set (TARGET_FILE "${FNAME}")
      else ()
        set (TARGET_FILE "${TARGET_NAME}")
      endif ()
      if (PREFIX)
        set (TARGET_FILE "${PREFIX}${TARGET_FILE}")
      endif ()
      if (SUFFIX)
        set (TARGET_FILE "${TARGET_FILE}${SUFFIX}")
      elseif (WIN32 AND TYPE MATCHES "^EXECUTABLE$")
        set (TARGET_FILE "${TARGET_FILE}.exe")
      endif ()

      if (PART MATCHES "^POST_INSTALL$")
        if (NOT IS_ABSOLUTE "${DIRECTORY}")
          set (DIRECTORY "${INSTALL_PREFIX}/${DIRECTORY}")
        endif ()
      elseif (PART MATCHES "^POST_INSTALL_RELATIVE$")
        if (IS_ABSOLUTE "${DIRECTORY}")
          file (RELATIVE_PATH DIRECTORY "${INSTALL_PREFIX}" "${DIRECTORY}")
          if (NOT DIRECTORY)
            set (DIRECTORY ".")
          endif ()
        endif ()
      endif ()

      set (LOCATION "${DIRECTORY}/${TARGET_FILE}")

    endif ()

    # get filename component
    if (NOT PART MATCHES "^POST_INSTALL$|^POST_INSTALL_RELATIVE$")
      get_filename_component (LOCATION "${LOCATION}" "${PART}")
    endif ()

  else ()
    message (FATAL_ERROR "basis_get_target_location(): Unknown target ${TARGET_UID}")
  endif ()

  # return
  set ("${VAR}" "${LOCATION}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# generator expressions
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Process generator expressions in arguments.
#
# This command evaluates the $&lt;TARGET_FILE:tgt&gt; and related generator
# expressions also for custom targets such as scripts and MATLAB Compiler
# targets. For other generator expressions whose argument is a target name,
# this function replaces the target name by the target UID, i.e., the actual
# CMake target name such that the expression can be evaluated by CMake.
# The following generator expressions are directly evaluated by this function:
# <table border=0>
#   <tr>
#     @tp <b><tt>$&lt;TARGET_FILE:tgt&gt;</tt></b> @endtp
#     <td>Absolute file path of built target.</td>
#   </tr>
#   <tr>
#     @tp <b><tt>$&lt;TARGET_FILE_POST_INSTALL:tgt&gt;</tt></b> @endtp
#     <td>Absolute path of target file after installation using the
#         current @c INSTALL_PREFIX.</td>
#   </tr>
#   <tr>
#     @tp <b><tt>$&lt;TARGET_FILE_POST_INSTALL_RELATIVE:tgt&gt;</tt></b> @endtp
#     <td>Path of target file after installation relative to @c INSTALL_PREFIX.</td>
#   </tr>
# </table>
# Additionally, the suffix <tt>_NAME</tt> or <tt>_DIR</tt> can be appended
# to the name of each of these generator expressions to get only the basename
# of the target file including the extension or the corresponding directory
# path, respectively.
#
# Generator expressions are in particular supported by basis_add_test().
#
# @param [out] ARGS Name of output list variable.
# @param [in]  ARGN List of arguments to process.
#
# @sa basis_add_test()
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_test
function (basis_process_generator_expressions ARGS)
  set (ARGS_OUT)
  foreach (ARG IN LISTS ARGN)
    string (REGEX MATCHALL "\\$<.*TARGET.*:.*>" EXPRS "${ARG}")
    foreach (EXPR IN LISTS EXPRS)
      if (EXPR MATCHES "\\$<(.*):(.*)>")
        set (EXPR_NAME   "${CMAKE_MATCH_1}")
        set (TARGET_NAME "${CMAKE_MATCH_2}")
        # TARGET_FILE* expression, including custom targets
        if (EXPR_NAME MATCHES "^TARGET_FILE(.*)")
          if (NOT CMAKE_MATCH_1)
            set (CMAKE_MATCH_1 "ABSOLUTE")
          endif ()
          string (REGEX REPLACE "^_" "" PART "${CMAKE_MATCH_1}")
          basis_get_target_location (ARG "${TARGET_NAME}" ${PART})
        # other generator expression supported by CMake
        # only replace target name, but do not evaluate expression
        else ()
          basis_get_target_uid (TARGET_UID "${CMAKE_MATCH_2}")
          string (REPLACE "${EXPR}" "$<${CMAKE_MATCH_1}:${TARGET_UID}>" ARG "${ARG}")
        endif ()
        if (BASIS_DEBUG AND BASIS_VERBOSE)
          message ("** basis_process_generator_expressions():")
          message ("**   Expression:  ${EXPR}")
          message ("**   Keyword:     ${EXPR_NAME}")
          message ("**   Argument:    ${TARGET_NAME}")
          message ("**   Replaced by: ${ARG}")
        endif ()
      endif ()
    endforeach ()
    list (APPEND ARGS_OUT "${ARG}")
  endforeach ()
  set (${ARGS} "${ARGS_OUT}" PARENT_SCOPE)
endfunction ()


## @}
# end of Doxygen group
