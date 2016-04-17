# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of basic project templates.
##############################################################################

macro (install_basis_template TEMPLATE_NAME)
  if (NOT DEFAULT_TEMPLATE_NAME MATCHES "${TEMPLATE_NAME}")
    basis_install_template (
      "${CMAKE_CURRENT_SOURCE_DIR}/${TEMPLATE_NAME}"
      "${INSTALL_TEMPLATE_DIR}/${TEMPLATE_NAME}"
    )
  endif ()
endmacro ()

install_basis_template (basis)
