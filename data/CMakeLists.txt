##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of auxiliary data files.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
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

# Attention: Whenever a template file is modified or added,
#            a new template directory with an updated version
#            number (<major>.<minor>) has to be created and the
#            modified or added files saved under this new directory.
#            As only the "differences" are stored each time,
#            *all* template versions are important to keep !
#            Otherwise, the three-way diff merge used by the basisproject
#            tool to update existing projects will fail.

if (BUILD_PROJECT_TOOL)
  basis_install_template (1.0)
  basis_install_template (1.1)
  basis_install_template (1.2)
  basis_install_template (1.3)
  basis_install_template (1.4)
  basis_install_template (1.5)
  basis_install_template (1.6)
  basis_install_template (1.7)
endif ()
