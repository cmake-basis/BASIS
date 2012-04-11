##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of auxiliary data files.
#
# Copyright (c) 2011-2012, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

macro (basis_install_template VERSION)
  install (
    DIRECTORY   "${CMAKE_CURRENT_SOURCE_DIR}/template-${VERSION}/"
    DESTINATION "${INSTALL_TEMPLATE_DIR}-${VERSION}"
    PATTERN     *~             EXCLUDE
    PATTERN     .svn           EXCLUDE
    PATTERN     .git           EXCLUDE
    PATTERN     .DS_Store      EXCLUDE
  )
endmacro ()

basis_install_template (1.0)
basis_install_template (1.1)
basis_install_template (1.2)
basis_install_template (1.3)
