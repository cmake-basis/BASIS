# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of basisproject tool.
##############################################################################

# advanced options
set (DEFAULT_TEMPLATE     "" CACHE PATH "Name/Directory of default project template.")
set (INSTALL_TEMPLATE_DIR "" CACHE PATH "Non-default installation directory of project templates.")
mark_as_advanced (DEFAULT_TEMPLATE INSTALL_TEMPLATE_DIR)

if (NOT INSTALL_TEMPLATE_DIR)
  set (INSTALL_TEMPLATE_DIR "${INSTALL_SHARE_DIR}/templates")
endif ()

# force default template to be set
if (NOT DEFAULT_TEMPLATE)
  set_property (CACHE DEFAULT_TEMPLATE PROPERTY VALUE "basis/1.4")
endif ()

# make default template path absolute
if (NOT IS_ABSOLUTE "${DEFAULT_TEMPLATE}")
  if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/templates/${DEFAULT_TEMPLATE}")
    set (DEFAULT_TEMPLATE "${CMAKE_CURRENT_SOURCE_DIR}/templates/${DEFAULT_TEMPLATE}")
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
basis_install_template (
  "${DEFAULT_TEMPLATE_DIR}/${DEFAULT_TEMPLATE_NAME}"
  "${INSTALL_TEMPLATE_DIR}/${DEFAULT_TEMPLATE_NAME}"
)

# install other templates
add_subdirectory (templates)

# add executable target
basis_add_executable (basisproject.py USE_BASIS_UTILITIES)
