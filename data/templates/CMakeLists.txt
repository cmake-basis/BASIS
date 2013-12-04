##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of basic project templates.
#
# Copyright (c) 2011, 2012 University of Pennsylvania, 2013 Andreas Schuh.<br />
# All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

macro (install_basis_template TEMPLATE_NAME)
  if (NOT DEFAULT_TEMPLATE_NAME MATCHES "${TEMPLATE_NAME}")
    basis_install_template (
      "${CMAKE_CURRENT_SOURCE_DIR}/${TEMPLATE_NAME}"
      "${INSTALL_TEMPLATE_DIR}/${TEMPLATE_NAME}"
    )
  endif ()
endmacro ()

install_basis_template (basisTemplate)
install_basis_template (sbia)
