##############################################################################
# @file  DirectoriesSettings.cmake
# @brief CMake variables of project directories.
#
# This file configures the project directory structure as defined by the
# Filesystem Hierarchy Standard for BASIS packages.
#
# @sa http://www.rad.upenn.edu/sbia/software/basis/standard/fhs/
#
# The project must follow the directory structure as defined by the
# <tt>PROJECT_&lt;*&gt;_DIR</tt> variables.
#
# Ideally, when changing the name of one of these directories, only the
# directory structure of the template needs to be updated. The BASIS CMake
# functions should not be required to change as they are supposed to use these
# variables instead of the actual names. Any change of the project directory
# structure has to be made with care, however, and backwards compatibility to
# previous releases of BASIS shall be maintained. Consider the use of the
# @c TEMPLATE_VERSION if required.
#
# @note The documentation of the variables can be found in Directories.cmake.in.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################


# ============================================================================
# root directories of top-level project
# ============================================================================

if (NOT PROJECT_IS_MODULE)
  set (BASIS_PROJECT_SOURCE_DIR "${PROJECT_SOURCE_DIR}")
  set (BASIS_PROJECT_BINARY_DIR "${PROJECT_BINARY_DIR}")
endif ()

# ============================================================================
# local variables
# ============================================================================

set (_VENDOR  "/${PROJECT_PACKAGE_VENDOR}")
set (_PACKAGE "/${PROJECT_PACKAGE}")
if (PROJECT_IS_SUBPROJECT)
  set (_MODULE  "/${PROJECT_NAME}")
else ()
  set (_MODULE  "")
endif ()
if (UNIX)
  string (TOLOWER "${_VENDOR}"  _VENDOR)
  string (TOLOWER "${_PACKAGE}" _PACKAGE)
  string (TOLOWER "${_MODULE}"  _MODULE)
endif ()

# ============================================================================
# source tree
# ============================================================================

set (PROJECT_CODE_DIR    "${PROJECT_SOURCE_DIR}/src")
set (PROJECT_CONFIG_DIR  "${PROJECT_SOURCE_DIR}/config")
set (PROJECT_DATA_DIR    "${PROJECT_SOURCE_DIR}/data")
set (PROJECT_DOC_DIR     "${PROJECT_SOURCE_DIR}/doc")
set (PROJECT_EXAMPLE_DIR "${PROJECT_SOURCE_DIR}/example")
set (PROJECT_INCLUDE_DIR "${PROJECT_SOURCE_DIR}/include")
set (PROJECT_LIBRARY_DIR "${PROJECT_SOURCE_DIR}/lib")
set (PROJECT_MODULES_DIR "${PROJECT_SOURCE_DIR}/modules")
set (PROJECT_TESTING_DIR "${PROJECT_SOURCE_DIR}/test")

# ============================================================================
# testing tree
# ============================================================================

set (TESTING_OUTPUT_DIR  "${BASIS_PROJECT_BINARY_DIR}/Testing/Temporary${_MODULE}")
set (TESTING_RUNTIME_DIR "${BASIS_PROJECT_BINARY_DIR}/Testing/bin${_MODULE}")
set (TESTING_LIBEXEC_DIR "${BASIS_PROJECT_BINARY_DIR}/Testing/lib${_MODULE}")
set (TESTING_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/Testing/lib${_MODULE}")
set (TESTING_ARCHIVE_DIR "${BASIS_PROJECT_BINARY_DIR}/Testing/lib${_MODULE}")

foreach (_L IN ITEMS python jython perl matlab bash)
  string (TOUPPER "${_L}" _U)
  set (TESTING_${_U}_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/Testing/lib/${_L}")
endforeach ()

# ============================================================================
# build tree
# ============================================================================

# set directories corresponding to the source tree directories
foreach (_P CODE CONFIG DATA DOC EXAMPLE MODULES TESTING)
  basis_get_relative_path (_D "${PROJECT_SOURCE_DIR}" "${PROJECT_${_P}_DIR}")
  set (BINARY_${_P}_DIR "${PROJECT_BINARY_DIR}/${_D}")
endforeach ()

basis_get_relative_path (_D "${PROJECT_SOURCE_DIR}" "${PROJECT_INCLUDE_DIR}")
set (BINARY_INCLUDE_DIR "${BASIS_PROJECT_BINARY_DIR}/${_D}")

set (BINARY_RUNTIME_DIR "${BASIS_PROJECT_BINARY_DIR}/bin")
set (BINARY_LIBEXEC_DIR "${BASIS_PROJECT_BINARY_DIR}/lib${_MODULE}")
set (BINARY_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/lib${_MODULE}")
set (BINARY_ARCHIVE_DIR "${BASIS_PROJECT_BINARY_DIR}/lib${_MODULE}")

foreach (_L IN ITEMS python jython perl matlab bash)
  string (TOUPPER "${_L}" _U)
  set (BINARY_${_U}_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/lib/${_L}")
endforeach ()

# set default CMake variables which are, however, not used by BASIS
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${BINARY_RUNTIME_DIR}")
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${BINARY_LIBRARY_DIR}")
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${BINARY_ARCHIVE_DIR}")

# ============================================================================
# install tree
# ============================================================================

# Attention: In order for CPack to work correctly, the destination paths have
#            to be given relative to CMAKE_INSTALL_PREFIX. Therefore, this
#            prefix must be excluded from the following paths!

# ----------------------------------------------------------------------------
# default installation prefix
string (REGEX REPLACE "[\\/]+$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
# change default installation prefix used by CMake
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # <ProgramFilesDir>/<Vendor>/<Package>[-<version>]
  if (WIN32)
    get_filename_component (CMAKE_INSTALL_PREFIX "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion;ProgramFilesDir]" ABSOLUTE)
    if (NOT CMAKE_INSTALL_PREFIX OR CMAKE_INSTALL_PREFIX MATCHES "/registry")
      set (CMAKE_INSTALL_PREFIX "C:/Program Files")
    endif ()
    set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}${_VENDOR}${_PACKAGE}")
    if (NOT PROJECT_VERSION MATCHES "^0\\.0\\.0$")
      set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}-${PROJECT_VERSION}")
    endif ()
  # /opt/<vendor>/<package>[-<version>]
  else ()
    set (CMAKE_INSTALL_PREFIX "/opt${_VENDOR}${_PACKAGE}")
    if (NOT PROJECT_VERSION MATCHES "^0\\.0\\.0$")
      set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}-${PROJECT_VERSION}")
    endif ()
  endif ()
endif ()
set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH "Installation prefix." FORCE)

# ----------------------------------------------------------------------------
# installation scheme - non-cached, can be preset using -D option of CMake
set (BASIS_INSTALL_SCHEME "default" CACHE STRING "default, opt, usr, or win")
set_property(CACHE BASIS_INSTALL_SCHEME PROPERTY STRINGS default opt usr win)
mark_as_advanced (BASIS_INSTALL_SCHEME)

if (BASIS_INSTALL_SCHEME MATCHES "default")
  if (WIN32)
    set (BASIS_INSTALL_SCHEME win)
  elseif (CMAKE_INSTALL_PREFIX MATCHES "^/(usr|opt)(/local)?$")
    set (BASIS_INSTALL_SCHEME usr)
  else ()
    set (BASIS_INSTALL_SCHEME opt)
  endif ()
endif ()

if (NOT BASIS_INSTALL_SCHEME MATCHES "^(opt|usr|win)$")
  message (FATAL_ERROR "Invalid BASIS_INSTALL_SCHEME! Valid values are 'default', 'opt', 'usr', or 'win'.")
endif ()

# ----------------------------------------------------------------------------
# installation directories
if (BASIS_INSTALL_SCHEME MATCHES "win") # e.g., CMAKE_INSTALL_PREFIX := <ProgramFilesDir>/<Vendor>/<Package>

  # package configuration
  set (INSTALL_CONFIG_DIR  "CMake${_MODULE}")
  # executables
  set (INSTALL_RUNTIME_DIR "Bin")
  set (INSTALL_LIBEXEC_DIR "Library${_MODULE}")
  # libraries
  set (INSTALL_INCLUDE_DIR "Include")
  set (INSTALL_LIBRARY_DIR "Library${_MODULE}")
  set (INSTALL_ARCHIVE_DIR "Library${_MODULE}")
  # shared data
  set (INSTALL_SHARE_DIR   "Share${_MODULE}")
  set (INSTALL_DATA_DIR    "Data${_MODULE}")
  set (INSTALL_EXAMPLE_DIR "Example${_MODULE}")
  # documentation
  set (INSTALL_DOC_DIR     "Doc${_MODULE}")
  set (INSTALL_MAN_DIR)
  set (INSTALL_TEXINFO_DIR)

elseif (BASIS_INSTALL_SCHEME MATCHES "usr") # e.g., CMAKE_INSTALL_PREFIX := /usr/local

  # package configuration
  set (INSTALL_CONFIG_DIR  "lib${_PACKAGE}${_MODULE}/cmake")
  # executables
  set (INSTALL_RUNTIME_DIR "bin")
  set (INSTALL_LIBEXEC_DIR "lib${_PACKAGE}${_MODULE}")
  # libraries
  set (INSTALL_INCLUDE_DIR "include")
  set (INSTALL_LIBRARY_DIR "lib${_PACKAGE}${_MODULE}")
  set (INSTALL_ARCHIVE_DIR "lib${_PACKAGE}${_MODULE}")
  # shared data
  set (INSTALL_SHARE_DIR   "share${_PACKAGE}${_MODULE}")
  set (INSTALL_DATA_DIR    "share${_PACKAGE}${_MODULE}/data")
  set (INSTALL_EXAMPLE_DIR "share${_PACKAGE}${_MODULE}/example")
  # documentation
  set (INSTALL_DOC_DIR     "doc${_PACKAGE}${_MODULE}")
  set (INSTALL_MAN_DIR     "share/man")
  set (INSTALL_TEXINFO_DIR "share/info")

else () # e.g., CMAKE_INSTALL_PREFIX := /opt/<vendor>/<package>

  # package configuration
  set (INSTALL_CONFIG_DIR  "lib${_MODULE}/cmake")
  # executables
  set (INSTALL_RUNTIME_DIR "bin")
  set (INSTALL_LIBEXEC_DIR "lib${_MODULE}")
  # libraries
  set (INSTALL_INCLUDE_DIR "include")
  set (INSTALL_LIBRARY_DIR "lib${_MODULE}")
  set (INSTALL_ARCHIVE_DIR "lib${_MODULE}")
  # shared data
  set (INSTALL_SHARE_DIR   "share${_MODULE}")
  set (INSTALL_DATA_DIR    "share${_MODULE}/data")
  set (INSTALL_EXAMPLE_DIR "share${_MODULE}/example")
  # documentation
  set (INSTALL_DOC_DIR     "doc${_MODULE}")
  set (INSTALL_MAN_DIR     "man")
  set (INSTALL_TEXINFO_DIR "info")

endif ()

# ----------------------------------------------------------------------------
# private script libraries
#
# The modules of script libraries which are only intended for use by this
# package itself are installed within the package own installation
# prefix/subdirectories.
if (BASIS_INSTALL_SCHEME MATCHES "win")

  foreach (_L IN ITEMS Python Jython Perl Matlab Bash)
    string (TOUPPER "${_L}" _U)
    set (INSTALL_${_U}_LIBRARY_DIR "Library/${_L}")
  endforeach ()

elseif (BASIS_INSTALL_SCHEME MATCHES "usr")

  foreach (_L IN ITEMS python jython perl matlab bash)
    string (TOUPPER "${_L}" _U)
    set (INSTALL_${_U}_LIBRARY_DIR "lib${_PACKAGE}/${_L}")
  endforeach ()

else ()

  foreach (_L IN ITEMS python jython perl matlab bash)
    string (TOUPPER "${_L}" _U)
    set (INSTALL_${_U}_LIBRARY_DIR "lib/${_L}")
  endforeach ()

endif ()

# ----------------------------------------------------------------------------
# public script libraries
#
# The modules of script libraries which are intended for use by external packages
# are installed in the respective installation directories of the particular
# interpreter. For example, in case of Python, the public Python modules are
# installed in the site-packages directory of the found PYTHON_EXECUTABLE.
# In particular the modules in the PROJECT_LIBRARY_DIR are intended for use
# by external packages. Other modules added using the basis_add_script_library()
# and basis_add_script() CMake functions are by default considered to be intended
# for internal use by the other modules and executable scripts.
#
# Note: For those interpreters of scripting language which by themselves do
#       not define a common installation directory for site packages, the
#       installation directory for public modules may be identical to the
#       one for private modules. Moreover, the user has the option to disable
#       the installation of public modules in the system default site directories
#       in order to prevent the installation of files outside the CMAKE_INSTALL_PREFIX.

# reset directories if BASIS_SITE_DIRS option has been changed
if (DEFINED _BASIS_SITE_DIRS)
  set (_RESET FALSE)
  if (BASIS_SITE_DIRS AND NOT _BASIS_SITE_DIRS)
    set (_RESET TRUE)
  elseif (NOT BASIS_SITE_DIRS AND _BASIS_SITE_DIRS)
    set (_RESET TRUE)
  endif ()
  if (_RESET)
    foreach (_L IN ITEMS PYTHON JYTHON PERL)
      # do not reset if BASIS_SITE_DIRS is OFF and path is already relative
      if (IS_ABSOLUTE "${INSTALL_${_L}_SITE_DIR}" OR BASIS_SITE_DIRS)
        basis_update_value (INSTALL_${_L}_SITE_DIR)
      endif ()
    endforeach ()
  endif ()
  unset (_RESET)
endif ()
set (_BASIS_SITE_DIRS "${BASIS_SITE_DIRS}" CACHE INTERNAL "Previous value of BASIS_SITE_DIRS option." FORCE)

# try to determine default installation directories
if (BASIS_SITE_DIRS)
  # Python
  if (NOT INSTALL_PYTHON_SITE_DIR AND PYTHON_EXECUTABLE)
    execute_process (
      COMMAND "${PYTHON_EXECUTABLE}" -E "${BASIS_MODULE_PATH}/get_python_lib.py"
      RESULT_VARIABLE _RV
      OUTPUT_VARIABLE INSTALL_PYTHON_SITE_DIR
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    if (NOT _RV EQUAL 0)
      set (INSTALL_PYTHON_SITE_DIR)
    endif ()
  endif ()
  # Jython
  if (NOT INSTALL_JYTHON_SITE_DIR AND JYTHON_EXECUTABLE)
    execute_process (
      COMMAND "${JYTHON_EXECUTABLE}" "${BASIS_MODULE_PATH}/get_python_lib.py"
      RESULT_VARIABLE _RV
      OUTPUT_VARIABLE INSTALL_JYTHON_SITE_DIR
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    if (NOT _RV EQUAL 0)
      set (INSTALL_JYTHON_SITE_DIR)
    endif ()
  endif ()
  # Perl
  if (NOT INSTALL_PERL_SITE_DIR)
    find_package (PerlLibs QUIET)
    if (PERLLIBS_FOUND)
      set (INSTALL_PERL_SITE_DIR "${PERL_SITELIB}")
    endif ()
  endif ()
endif ()

# if it failed to determine the default installation directories by executing some
# code or command, use some other reasonable defaults instead
if (BASIS_INSTALL_SCHEME MATCHES "win")

  foreach (_L IN ITEMS Python Jython Perl Bash)
    string (TOUPPER "${_L}" _U)
    if (NOT INSTALL_${_U}_SITE_DIR)
      if (${_U}_VERSION_MAJOR AND DEFINED ${_U}_VERSION_STRING)
        set (INSTALL_${_U}_SITE_DIR "Library/${_L}${${_U}_VERSION_MAJOR}.${${_U}_VERSION_MINOR}")
      else ()
        set (INSTALL_${_U}_SITE_DIR "Library/${_L}")
      endif ()
    endif ()
  endforeach ()

  if (NOT INSTALL_MATLAB_SITE_DIR)
    if (MATLAB_RELEASE)
      set (INSTALL_MATLAB_SITE_DIR "Library/Matlab/${MATLAB_RELEASE}")
    elseif (MATLAB_VERSION_MAJOR AND DEFINED MATLAB_VERSION_MINOR)
      set (INSTALL_MATLAB_SITE_DIR "Library/Matlab${MATLAB_VERSION_MAJOR}.${MATLAB_VERSION_MINOR}")
    else ()
      set (INSTALL_MATLAB_SITE_DIR "Library/Matlab")
    endif ()
  endif ()

else ()

  # Python
  if (NOT INSTALL_PYTHON_SITE_DIR)
    if (PYTHON_VERSION_MAJOR AND DEFINED PYTHON_VERSION_MINOR)
      set (INSTALL_PYTHON_SITE_DIR "lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages")
    else ()
      set (INSTALL_PYTHON_SITE_DIR "lib/python/site-packages")
    endif ()
  endif ()
  # Jython
  if (NOT INSTALL_JYTHON_SITE_DIR)
    if (JYTHON_VERSION_MAJOR AND DEFINED JYTHON_VERSION_MINOR)
      set (INSTALL_JYTHON_SITE_DIR "lib/jython${JYTHON_VERSION_MAJOR}.${JYTHON_VERSION_MINOR}/site-packages")
    else ()
      set (INSTALL_JYTHON_SITE_DIR "lib/jython/site-packages")
    endif ()
  endif ()
  # Perl
  if (NOT INSTALL_PERL_SITE_DIR)
    if (PERL_VERSION_MAJOR AND DEFINED PERL_VERSION_STRING)
      set (INSTALL_PERL_SITE_DIR "lib/perl${PERL_VERSION_MAJOR}/site_perl/${PERL_VERSION_STRING}")
    else ()
      set (INSTALL_PERL_SITE_DIR "lib/perl/site_perl")
    endif ()
  endif ()
  # MATLAB
  if (NOT INSTALL_MATLAB_SITE_DIR)
    if (MATLAB_RELEASE)
      set (INSTALL_MATLAB_SITE_DIR "lib/matlab/${MATLAB_RELEASE}")
    elseif (MATLAB_VERSION_MAJOR AND DEFINED MATLAB_VERSION_MINOR)
      set (INSTALL_MATLAB_SITE_DIR "lib/matlab${MATLAB_VERSION_MAJOR}.${MATLAB_VERSION_MINOR}")
    else ()
      set (INSTALL_MATLAB_SITE_DIR "lib/matlab")
    endif ()
  endif ()
  # Bash
  if (NOT INSTALL_BASH_SITE_DIR)
    if (BASH_VERSION_MAJOR AND DEFINED BASH_VERSION_STRING)
      set (INSTALL_BASH_SITE_DIR "lib/bash${BASH_VERSION_MAJOR}.${BASH_VERSION_MINOR}")
    else ()
      set (INSTALL_BASH_SITE_DIR "lib/bash")
    endif ()
  endif ()

endif ()

# cache directories - also so users can edit them
foreach (_L IN ITEMS Python Jython Perl MATLAB Bash)
  string (TOUPPER "${_L}" _U)
  set (INSTALL_${_U}_SITE_DIR "${INSTALL_${_U}_SITE_DIR}" CACHE PATH "Installation directory for public ${_L} modules." FORCE)
  mark_as_advanced (INSTALL_${_U}_SITE_DIR)
endforeach ()

# ============================================================================
# top-level references
# ============================================================================

if (NOT PROJECT_IS_MODULE)
  # build tree
  foreach (_D CODE CONFIG DATA DOC EXAMPLE INCLUDE MODULES TESTING RUNTIME LIBEXEC LIBRARY ARCHIVE)
    set (BASIS_BINARY_${_D}_DIR "${BINARY_${_D}_DIR}")
  endforeach ()
  foreach (_L IN ITEMS PYTHON JYTHON PERL MATLAB BASH)
    set (BASIS_BINARY_${_L}_LIBRARY_DIR "${BINARY_${_L}_LIBRARY_DIR}")
  endforeach ()
  # installation
  foreach (_D IN ITEMS CONFIG INCLUDE RUNTIME LIBEXEC LIBRARY ARCHIVE DATA DOC EXAMPLE SHARE)
    set (BASIS_INSTALL_${_D}_DIR "${INSTALL_${_D}_DIR}")
  endforeach ()
  foreach (_L IN ITEMS PYTHON JYTHON PERL MATLAB BASH)
    set (BASIS_INSTALL_${_L}_LIBRARY_DIR "${INSTALL_${_L}_LIBRARY_DIR}")
  endforeach ()
endif ()

# ============================================================================
# clean up
# ============================================================================

unset (_D)
unset (_L)
unset (_U)
unset (_P)
unset (_RV)
unset (_VENDOR)
unset (_PACKAGE)
unset (_MODULE)
unset (_DEFAULT_SCHEME)


## @}
# end of Doxygen group
