##############################################################################
# @file  FindWeka.cmake
# @brief Find Weka (http://www.cs.waikato.ac.nz/ml/weka/) package.
#
# @par Input variables:
# <table border="0">
#   <tr>
#     @tp @b Weka_DIR @endtp
#     <td>The Weka package files are searched under the specified root
#         directory. If they are not found there, the default search paths
#         are considered. This variable can also be set as environment variable.</td>
#   </tr>
#   <tr>
#     @tp @b WEKA_DIR @endtp
#     <td>Alternative environment variable for @c Weka_DIR.</td>
#   </tr>
#   <tr>
#     @tp @b Weka_PACKAGES_DIR @endtp
#     <td>Directory where additional Weka packages are installed. If they are
#         not found there or if this variable is not set, this module will look
#         in the standard installation directories. This variable can also be set
#         as environment variable.</td>
#   </tr>
#   <tr>
#     @tp @b WEKA_PACKAGES_DIR @endtp
#     <td>Alternative environment variable for @c Weka_PACKAGES_DIR.</td>
#   </tr>
#   <tr>
#     @tp <b>Weka_&lt;package&gt;_DIR</b> @endtp
#     <td>The path of the given Weka package, i.e., the directory containing the
#         <tt>&lt;package&gt;.jar</tt> file or a subdirectory named <tt>weka</tt>
#         with the uncompressed <tt>.class</tt> files of the package.</td>
#   </tr>
#   <tr>
#     @tp @b Weka_FIND_COMPONENTS @endtp
#     <td>The @c COMPONENTS argument(s) of the find_package() command can
#         be used to also look for additionally installed Weka packages.</td>
#   </tr>
#   <tr>
#     @tp @b Weka_ADDITIONAL_VERSIONS @endtp
#     <td>List of version numbers that should be taken into account when
#         searching for Weka.</td>
#   </tr>
# </table>
#
# @par Output variables:
# <table border="0">
#   <tr>
#     @tp @b Weka_FOUND @endtp
#     <td>Whether the package was found and the following CMake variables are valid.</td>
#   </tr>
#   <tr>
#     @tp @b Weka_CLASSPATH @endtp
#     <td>The path of the found <tt>weka.jar</tt> file.</td>
#   </tr>
#   <tr>
#     @tp @b Weka_PACKAGES_CLASSPATH @endtp
#     <td>The @c CLASSPATH of all found additional Weka packages (non-cached).</td>
#   </tr>
#   <tr>
#     @tp @b Weka_CLASSPATHS @endtp
#     <td>Combination of both @c Weka_CLASSPATH and @c Weka_PACKAGES_CLASSPATH.</td>
#   </tr>
# </table>
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeFindModules
##############################################################################

# ============================================================================
# helpers
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get list of Weka packages.
#
# @param [out] PACKAGES Name of variable storing the list of packages.
# @param [in]  WHICH    Argument to -list-packages option of Weka package
#                       manager, i.e., "all", "available", or "installed".
function (weka_list_packages PACKAGES WHICH)
  string (TOLOWER "${WHICH}" WHICH) # ignore case of argument
  set (PKGS)
  if (NOT JAVA_EXECUTABLE)
    set (JAVA_EXECUTABLE java)
  endif ()
  if (Weka_CLASSPATH)
    execute_process (
      COMMAND "${JAVA_EXECUTABLE}"
                  -classpath "${Weka_CLASSPATH}"
                  weka.core.WekaPackageManager
                  -list-packages "${WHICH}"
      RESULT_VARIABLE STATUS
      OUTPUT_VARIABLE STDOUT
    )
    if (STATUS EQUAL 0)
      string (REPLACE ";"  "," STDOUT "${STDOUT}")
      string (REPLACE "\n" ";" STDOUT "${STDOUT}")
      foreach (LINE IN LISTS STDOUT)
        if (LINE MATCHES "^(-+|[0-9]+(\\.[0-9]+(\\.[0-9]+)))[ \t]+[0-9]+(\\.[0-9]+(\\.[0-9]+))[ \t]+([a-zA-Z_-]+):")
          list (APPEND PKGS "${CMAKE_MATCH_6}")
        endif ()
      endforeach ()
    else ()
      message (WARNING "Failed to retrieve list of ${WHICH} Weka packages!")
    endif ()
  else ()
    message (WARNING "Cannot retrieve list of Weka packages because Weka_CLASSPATH is not set!")
  endif ()
  set (${PACKAGES} "${PKGS}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get Weka version.
#
# @param [out] VERSION Version string of Weka or 0.0.0.
# @param [out] MAJOR   Major version of Weka or 0.
# @param [out] MINOR   Minor version of Weka or 0.
# @param [out] PATCH   Patch number of Weka or 0.
function (weka_get_version VERSION MAJOR MINOR PATCH)
  set (VERSION_STRING "0.0.0")
  set (VERSION_MAJOR 0)
  set (VERSION_MINOR 0)
  set (VERSION_PATCH 0)
  if (NOT JAVA_EXECUTABLE)
    set (JAVA_EXECUTABLE java)
  endif ()
  if (Weka_CLASSPATH)
    execute_process (
      COMMAND "${JAVA_EXECUTABLE}" -classpath "${Weka_CLASSPATH}" weka.core.Version
      RESULT_VARIABLE RETVAL
      OUTPUT_VARIABLE STDOUT
    )
    if (STDOUT MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)")
      set (VERSION_STRING "${CMAKE_MATCH_0}")
      set (VERSION_MAJOR  "${CMAKE_MATCH_1}")
      set (VERSION_MINOR  "${CMAKE_MATCH_2}")
      set (VERSION_PATCH  "${CMAKE_MATCH_3}")
    endif ()
  endif ()
  set (${VERSION} "${VERSION_STRING}" PARENT_SCOPE)
  set (${MAJOR}   "${VERSION_MAJOR}" PARENT_SCOPE)
  set (${MINOR}   "${VERSION_MINOR}" PARENT_SCOPE)
  set (${PATCH}   "${VERSION_PATCH}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# main
# ============================================================================

# ----------------------------------------------------------------------------
# initialize search
if (NOT Weka_DIR)
  if (NOT $ENV{Weka_DIR} STREQUAL "")
    set (Weka_DIR "$ENV{Weka_DIR}" CACHE PATH "Installation directory of Weka." FORCE)
  else ()
    set (Weka_DIR "$ENV{WEKA_DIR}" CACHE PATH "Installation directory of Weka." FORCE)
  endif ()
endif ()

set (Weka_HINTS)
if (CMAKE_HOST_APPLE)
  # TODO seach /Applications/weka-3-7-6.app/Contents and
  #      $ENV{HOME}/Applications/weka-3-7-6.app/Contents
  #      directories for all requested/known Weka versions
endif ()

#-------------------------------------------------------------
# find weka.jar
if (Weka_DIR)
  find_file (
    Weka_CLASSPATH
    NAMES         weka.jar
    HINTS         "${Weka_DIR}"
    PATH_SUFFIXES "weka"
                  "Contents/Resources/Java"
                  "Resources/Java"
    DOC           "The Java library of the Weka package (weka.jar)."
    NO_DEFAULT_PATH
  )
else ()
  find_file (
    Weka_CLASSPATH
    NAMES         weka.jar
    HINTS         ${Weka_HINTS} ENV CLASSPATH
    PATH_SUFFIXES "weka"
                  "Contents/Resources/Java"
                  "Resources/Java"
    DOC           "The Java library of the Weka package (weka.jar)."
  )
  if (Weka_CLASSPATH)
    get_filename_component (Weka_DIR "${Weka_CLASSPATH}" PATH)
    set (Weka_DIR "${Weka_DIR}" CACHE PATH "Installation directory of Weka." FORCE)
  endif ()
endif ()
mark_as_advanced (Weka_CLASSPATH)

#-------------------------------------------------------------
# determine Weka version
weka_get_version (Weka_VERSION_STRING Weka_VERSION_MAJOR Weka_VERSION_MINOR Weka_VERSION_PATCH)

#-------------------------------------------------------------
# find Weka packages
if (NOT Weka_PACKAGES_DIR AND Weka_DIR)
  if (IS_DIRECTORY "${Weka_DIR}/packages")
    set (Weka_PACKAGES_DIR "${Weka_DIR}/packages" CACHE PATH "Installation directory of Weka packages." FORCE)
  elseif (IS_DIRECTORY "$ENV{HOME}/wekafiles/packages")
    set (Weka_PACKAGES_DIR "$ENV{HOME}/wekafiles/packages" CACHE PATH "Installation directory of Weka packages." FORCE)
  endif ()
endif ()
set (Weka_REQUIRED_PACKAGE_VARS)
if (Weka_FIND_COMPONENTS)
  foreach (Weka_PKG IN LISTS Weka_FIND_COMPONENTS)
    list (APPEND Weka_REQUIRED_PACKAGE_VARS "Weka_${Weka_PKG}_DIR")
  endforeach ()
elseif (Weka_CLASSPATH)
  weka_list_packages (Weka_FIND_COMPONENTS installed)
endif ()
foreach (Weka_PKG IN LISTS Weka_FIND_COMPONENTS)
  set (Weka_${Weka_PKG}_DIR "NOTFOUND" CACHE PATH "Directory of ${Weka_PKG} Weka package." FORCE)
  mark_as_advanced (Weka_${Weka_PKG}_DIR)
  if (IS_DIRECTORY "${Weka_PACKAGES_DIR}/${Weka_PKG}")
    if (EXISTS "${Weka_PACKAGES_DIR}/${Weka_PKG}/${Weka_PKG}.jar")
      set (Weka_${Weka_PKG}_CLASSPATH "${Weka_PACKAGES_DIR}/${Weka_PKG}/${Weka_PKG}.jar")
    elseif (IS_DIRECTORY "${Weka_PACKAGES_DIR}/${Weka_PKG}/weka")
      set (Weka_${Weka_PKG}_CLASSPATH "${Weka_PACKAGES_DIR}/${Weka_PKG}")
    elseif (IS_DIRECTORY "${Weka_PACKAGES_DIR}/${Weka_PACKAGE}/src/main/java/weka")
      set (Weka_${Weka_PKG}_CLASSPATH "${Weka_PACKAGES_DIR}/${Weka_PKG}/src/main/java")
    endif ()
  endif ()
  if (Weka_${Weka_PKG}_CLASSPATH)
    list (APPEND Weka_PACKAGES_CLASSPATH "${Weka_${Weka_PKG}_CLASSPATH}")
    set (Weka_${Weka_PKG}_DIR "${Weka_PACKAGES_DIR}/${Weka_PKG}" CACHE PATH "Directory of ${Weka_PKG} Weka package." FORCE)
    break ()
  endif ()
endforeach ()
unset (Weka_PKG)

# ----------------------------------------------------------------------------
# Weka_CLASSPATHS
set (Weka_CLASSPATHS)
if (Weka_CLASSPATH)
  list (APPEND Weka_CLASSPATHS "${Weka_CLASSPATH}")
endif ()
if (Weka_PACKAGES_CLASSPATH)
  list (APPEND Weka_CLASSPATHS ${Weka_PACKAGES_CLASSPATH})
endif ()

# ----------------------------------------------------------------------------
# debugging
if (BASIS_DEBUG AND COMMAND basis_dump_variables)
  basis_dump_variables ("${CMAKE_CURRENT_BINARY_DIR}/FindWekaVariables.cmake")
endif ()

# ----------------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set *_FOUND to TRUE
# if all listed variables are found or TRUE
include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (
  Weka
  REQUIRED_VARS Weka_CLASSPATH ${Weka_REQUIRED_PACKAGE_VARS}
  VERSION_VAR   ${Weka_VERSION_STRING}
)

unset (Weka_HINTS)
unset (Weka_REQUIRED_PACKAGE_VARS)
