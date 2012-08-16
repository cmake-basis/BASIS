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

set (TESTING_OUTPUT_DIR        "${BASIS_PROJECT_BINARY_DIR}/Testing${_MODULE}/Temporary")
set (TESTING_RUNTIME_DIR       "${BASIS_PROJECT_BINARY_DIR}/Testing${_MODULE}/bin")
set (TESTING_LIBEXEC_DIR       "${BASIS_PROJECT_BINARY_DIR}/Testing${_MODULE}/lib")
set (TESTING_LIBRARY_DIR       "${BASIS_PROJECT_BINARY_DIR}/Testing${_MODULE}/lib")
set (BINARY_PYTHON_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/Testing/lib/python")
set (BINARY_JYTHON_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/Testing/lib/jython")
set (BINARY_PERL_LIBRARY_DIR   "${BASIS_PROJECT_BINARY_DIR}/Testing/lib/perl5")
set (BINARY_MATLAB_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/Testing/lib/matlab")

# ============================================================================
# build tree
# ============================================================================

# set directories corresponding to the source tree directories
foreach (_P CODE CONFIG DATA DOC EXAMPLE INCLUDE MODULES TESTING)
  basis_get_relative_path (_D "${PROJECT_SOURCE_DIR}" "${PROJECT_${_P}_DIR}")
  set (BINARY_${_P}_DIR "${PROJECT_BINARY_DIR}/${_D}")
endforeach ()

set (BINARY_RUNTIME_DIR        "${BASIS_PROJECT_BINARY_DIR}/bin")
set (BINARY_LIBEXEC_DIR        "${BASIS_PROJECT_BINARY_DIR}/lib${_MODULE}")
set (BINARY_LIBRARY_DIR        "${BASIS_PROJECT_BINARY_DIR}/lib${_MODULE}")
set (BINARY_ARCHIVE_DIR        "${BASIS_PROJECT_BINARY_DIR}/lib${_MODULE}")
set (BINARY_PYTHON_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/lib/python")
set (BINARY_JYTHON_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/lib/jython")
set (BINARY_PERL_LIBRARY_DIR   "${BASIS_PROJECT_BINARY_DIR}/lib/perl5")
set (BINARY_MATLAB_LIBRARY_DIR "${BASIS_PROJECT_BINARY_DIR}/lib/matlab")

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
    set (CMAKE_INSTALL_PREFIX "/opt/${_VENDOR}${_PACKAGE}")
    if (NOT PROJECT_VERSION MATCHES "^0\\.0\\.0$")
      set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}-${PROJECT_VERSION}")
    endif ()
  endif ()
endif ()
set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH "Installation prefix." FORCE)

# ----------------------------------------------------------------------------
# installation scheme - non-cached, can be preset using -D option of CMake
if (BASIS_INSTALL_SCHEME)
  if (NOT BASIS_INSTALL_SCHEME MATCHES "^(usr|opt|win)$")
    message (FATAL_ERROR "Invalid BASIS_INSTALL_SCHEME! Valid values are 'usr', 'opt', or 'win'.")
  endif ()
elseif (WIN32)
  set (BASIS_INSTALL_SCHEME win)
elseif (CMAKE_INSTALL_PREFIX MATCHES "^/usr(/local)?$")
  set (BASIS_INSTALL_SCHEME usr)
else ()
  set (BASIS_INSTALL_SCHEME opt)
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
  set (INSTALL_CONFIG_DIR  "lib/cmake${_PACKAGE}${_MODULE}")
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
  set (INSTALL_CONFIG_DIR  "lib/cmake${_MODULE}")
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
  set (INSTALL_MAN_DIR     "share/man")
  set (INSTALL_TEXINFO_DIR "share/info")

endif ()

# ----------------------------------------------------------------------------
# public module directories
if (BASIS_INSTALL_SCHEME MATCHES "win")

  # Python
  if (PYTHON_VERSION_MAJOR AND DEFINED PYTHON_VERSION_MINOR)
    set (INSTALL_PYTHON_LIBRARY_DIR "Library/Python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
  else ()
    set (INSTALL_PYTHON_LIBRARY_DIR "Library/Python")
  endif ()
  # Jython
  if (JYTHON_VERSION_MAJOR AND DEFINED JYTHON_VERSION_MINOR)
    set (INSTALL_JYTHON_LIBRARY_DIR "Library/Jython${JYTHON_VERSION_MAJOR}.${JYTHON_VERSION_MINOR}")
  else ()
    set (INSTALL_JYTHON_LIBRARY_DIR "Library/Jython")
  endif ()
  # Perl
  if (PERL_VERSION_MAJOR AND DEFINED PERL_VERSION_STRING)
    set (INSTALL_PERL_LIBRARY_DIR "Library/Perl${PERL_VERSION_MAJOR}/site_perl/${PERL_VERSION_STRING}")
  else ()
    set (INSTALL_PERL_LIBRARY_DIR "Library/Perl/site_perl")
  endif ()
  # MATLAB
  if (MATLAB_RELEASE)
    set (INSTALL_MATLAB_LIBRARY_DIR "Library/Matlab/${MATLAB_RELEASE}")
  elseif (MATLAB_VERSION_MAJOR AND DEFINED MATLAB_VERSION_MINOR)
    set (INSTALL_MATLAB_LIBRARY_DIR "Library/Matlab${MATLAB_VERSION_MAJOR}.${MATLAB_VERSION_MINOR}")
  else ()
    set (INSTALL_MATLAB_LIBRARY_DIR "Library/Matlab")
  endif ()

else ()

  # Python
  if (PYTHON_VERSION_MAJOR AND DEFINED PYTHON_VERSION_MINOR)
    set (INSTALL_PYTHON_LIBRARY_DIR "lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages")
  else ()
    set (INSTALL_PYTHON_LIBRARY_DIR "lib/python/site-packages")
  endif ()
  # Jython
  if (JYTHON_VERSION_MAJOR AND DEFINED JYTHON_VERSION_MINOR)
    set (INSTALL_JYTHON_LIBRARY_DIR "lib/jython${JYTHON_VERSION_MAJOR}.${JYTHON_VERSION_MINOR}/site-packages")
  else ()
    set (INSTALL_JYTHON_LIBRARY_DIR "lib/jython/site-packages")
  endif ()
  # Perl
  if (PERL_VERSION_MAJOR AND DEFINED PERL_VERSION_STRING)
    set (INSTALL_PERL_LIBRARY_DIR "lib/perl${PERL_VERSION_MAJOR}/site_perl/${PERL_VERSION_STRING}")
  else ()
    set (INSTALL_PERL_LIBRARY_DIR "lib/perl/site_perl")
  endif ()
  # MATLAB
  if (MATLAB_RELEASE)
    set (INSTALL_MATLAB_LIBRARY_DIR "lib/matlab/${MATLAB_RELEASE}")
  elseif (MATLAB_VERSION_MAJOR AND DEFINED MATLAB_VERSION_MINOR)
    set (INSTALL_MATLAB_LIBRARY_DIR "lib/matlab${MATLAB_VERSION_MAJOR}.${MATLAB_VERSION_MINOR}")
  else ()
    set (INSTALL_MATLAB_LIBRARY_DIR "lib/matlab")
  endif ()

endif ()

# ============================================================================
# top-level references
# ============================================================================

if (NOT PROJECT_IS_MODULE)
  # build tree
  foreach (_D CODE CONFIG DATA DOC EXAMPLE MODULES TESTING
              RUNTIME LIBEXEC LIBRARY ARCHIVE
              PYTHON_LIBRARY JYTHON_LIBRARY PERL_LIBRARY MATLAB_LIBRARY)
    set (BASIS_BINARY_${_D}_DIR "${BINARY_${_D}_DIR}")
  endforeach ()
  # installation
  foreach (_D IN ITEMS CONFIG INCLUDE RUNTIME LIBEXEC LIBRARY ARCHIVE
                 PYTHON_LIBRARY PERL_LIBRARY DATA DOC EXAMPLE SHARE)
    set (BASIS_INSTALL_${_D}_DIR "${INSTALL_${_D}_DIR}")
  endforeach ()
endif ()

# ============================================================================
# clean up
# ============================================================================

unset (_D)
unset (_P)
unset (_VENDOR)
unset (_PACKAGE)
unset (_MODULE)
unset (_DEFAULT_SCHEME)


## @}
# end of Doxygen group
