##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of basic project templates.
#
# Copyright (c) 2011-2012 University of Pennsylvania. <br />
# Copyright (c) 2013-2014 Andreas Schuh.              <br />
# All rights reserved.                                <br />
#
# See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
# or COPYING file for license information.
#
# Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
#          report issues at https://github.com/schuhschuh/cmake-basis/issues
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
install_basis_template (sbia)
