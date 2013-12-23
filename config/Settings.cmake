##############################################################################
# @file  Settings.cmake
# @brief Non-default project settings.
#
# This file is included by basis_project_impl() after it looked for the
# required and optional dependencies and the CMake variables related to the
# project directory structure were defined (see BASISDirectories.cmake file
# in @c PROJECT_BINARY_DIR, where BASIS is here the name of the project).
# It is further included before the BasisSettings.cmake file.
#
# In particular, build options should be added in this file using CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:option">
# option()</a> command. Further, any common settings related to using a found
# dependency can be set here if the basis_use_package() command was enable
# to import the required configuration of a particular external package.
#
# Copyright (c) 2011, 2012 University of Pennsylvania.<br />
# Copyright (c) 2013 Andreas Schuh.<br />
# All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: Andreas Schuh <andreas.schuh.84 at gmail.com>
#
# @ingroup BasisSettings
##############################################################################

# ============================================================================
# directories
# ============================================================================

# installation directory of CMake modules
set (INSTALL_MODULES_DIR "${INSTALL_SHARE_DIR}/cmake-modules")

# installation directory of utilities template files
set (INSTALL_CXX_TEMPLATES_DIR    "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_JAVA_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_PYTHON_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_PERL_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_MATLAB_TEMPLATES_DIR "${INSTALL_SHARE_DIR}/utilities")
set (INSTALL_BASH_TEMPLATES_DIR   "${INSTALL_SHARE_DIR}/utilities")

# common prefix of Sphinx extensions
set (SPHINX_EXTENSIONS_PREFIX "basis/sphinx/ext/")
# installation directory of Sphinx themes
set (INSTALL_SPHINX_THEMES_DIR "${INSTALL_SHARE_DIR}/sphinx-themes")

# ============================================================================
# project template
# ============================================================================

# options
option (BUILD_PROJECT_TOOL "Request build of the basisproject command-line tool."    ON)
option (INSTALL_TEMPLATES  "Install additional project templates provided by BASIS." ON)

set (DEFAULT_TEMPLATE     ""                               CACHE PATH "Name/Directory of default project template.")
set (INSTALL_TEMPLATE_DIR "${INSTALL_SHARE_DIR}/templates" CACHE PATH "Installation directory of project templates.")

# force default template to be set
if (NOT DEFAULT_TEMPLATE)
  set_property (CACHE DEFAULT_TEMPLATE PROPERTY VALUE "basis/1.0")
endif ()
# disable installation of templates if no destination specified
if (NOT INSTALL_TEMPLATE_DIR)
  message (WARNING "No installation directory for project templates specified."
                   " Disabling installation of templates. To enable the installation"
                   " of the project templates again, set INSTALL_TEMPLATE_DIR to"
                   " the desired destination such as \"share/templates\" and the"
                   " option INSTALL_TEMPLATES to ON.")
  set_property (CACHE INSTALL_TEMPLATES PROPERTY VALUE OFF)
endif ()

# mark cache entires as advanced if unused
if (BUILD_PROJECT_TOOL)
  mark_as_advanced (CLEAR DEFAULT_TEMPLATE INSTALL_TEMPLATES)
else ()
  mark_as_advanced (FORCE DEFAULT_TEMPLATE INSTALL_TEMPLATES)
endif ()
mark_as_advanced (INSTALL_TEMPLATE_DIR)

if (BUILD_PROJECT_TOOL)
  # make default template path absolute
  if (NOT IS_ABSOLUTE "${DEFAULT_TEMPLATE}")
    if (IS_DIRECTORY "${PROJECT_DATA_DIR}/templates/${DEFAULT_TEMPLATE}")
      set (DEFAULT_TEMPLATE "${PROJECT_DATA_DIR}/templates/${DEFAULT_TEMPLATE}")
    else ()
      set (DEFAULT_TEMPLATE "${CMAKE_BINARY_DIR}/${DEFAULT_TEMPLATE}")
      if (NOT IS_DIRECTORY "${DEFAULT_TEMPLATE}")
        message (FATAL_ERROR "Invalid default project template. The directory"
                             " ${DEFAULT_TEMPLATE} does not exist. Please specify"
                             " either the name of a template included with BASIS as"
                             " \"<name>/<version>\" or use an absolute path to the"
                             " specific project template to use, i.e., \"/<path>/<name>/<version>\"")
      endif ()
    endif ()
  endif ()
  if (NOT EXISTS "${DEFAULT_TEMPLATE}/_config.py")
    message (FATAL_ERROR "Invalid default project template. Missing template configuration file:"
                         "\n    ${DEFAULT_TEMPLATE}/_config.py\n")
  endif ()
  # split default template path into parts
  if (DEFAULT_TEMPLATE MATCHES "^(.*)/([^/]*)/([0-9]+\\.[0-9]+)$")
    set (DEFAULT_TEMPLATE_DIR     "${CMAKE_MATCH_1}")
    set (DEFAULT_TEMPLATE_NAME    "${CMAKE_MATCH_2}")
    set (DEFAULT_TEMPLATE_VERSION "${CMAKE_MATCH_3}")
  else ()
    message (FATAL_ERROR "Invalid default project template. The absolute template directory path "
                         " must match the pattern \"/<path>/<name>/<major>.<minor>\", where"
                         " <name> is the template name and <major>.<minor> is the template version."
                         "\nInstead DEFAULT_TEMPLATE is set to the following absolute path:"
                         "\n    ${DEFAULT_TEMPLATE}\n")
  endif ()
  # install default project template
  if (INSTALL_TEMPLATE_DIR)
    basis_install_template (
      "${DEFAULT_TEMPLATE_DIR}/${DEFAULT_TEMPLATE_NAME}"
      "${INSTALL_TEMPLATE_DIR}/${DEFAULT_TEMPLATE_NAME}"
    )
  endif ()
endif ()

# ============================================================================
# utilities
# ============================================================================

# list of enabled utilities
# in case of other projects defined by BASISConfig.cmake
set (BASIS_UTILITIES_ENABLED CXX)
if (PythonInterp_FOUND)
  list (APPEND BASIS_UTILITIES_ENABLED PYTHON)
endif ()
if (Perl_FOUND)
  list (APPEND BASIS_UTILITIES_ENABLED PERL)
endif ()
if (BASH_FOUND)
  list (APPEND BASIS_UTILITIES_ENABLED BASH)
endif ()

# configure all BASIS utilities such that they are included in API
# documentation even if BASIS does not use them itself
if (Java_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_JAVA_UTILITIES TRUE)
endif ()
if (PythonInterp_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_PYTHON_UTILITIES TRUE)
endif ()
if (Perl_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_PERL_UTILITIES TRUE)
endif ()
if (BASH_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_BASH_UTILITIES TRUE)
endif ()
if (MATLAB_FOUND)
  basis_set_project_property (PROPERTY PROJECT_USES_MATLAB_UTILITIES TRUE)
endif ()

# target UIDs of BASIS libraries; these would be set by the package configuration
# file if this BASIS project would not be BASIS itself
if (BASIS_USE_FULLY_QUALIFIED_UIDS)
  set (NS "basis.")
else ()
  set (NS)
endif ()
set (BASIS_CXX_UTILITIES_LIBRARY    "${NS}utilities_cxx")
set (BASIS_PYTHON_UTILITIES_LIBRARY "${NS}utilities_python")
set (BASIS_PERL_UTILITIES_LIBRARY   "${NS}utilities_perl")
set (BASIS_BASH_UTILITIES_LIBRARY   "${NS}utilities_bash")
set (BASIS_TEST_LIBRARY             "${NS}testlib")
set (BASIS_TEST_MAIN_LIBRARY        "${NS}testmain")
