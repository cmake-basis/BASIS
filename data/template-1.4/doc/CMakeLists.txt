##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of software documentation.
#
# This build configuration builds and/or installs the documentation of the
# software package. The documentation can be divided into user documentation
# (e.g., software manual) and developer documentation (e.g., developer's guide).
# For developers, both those using a library provided by this package and the
# package maintainers, the documentation of the API is of particular interest.
# Developers who are responsible for maintaining this software may be provided
# with even more detailed documentation of the implementation in the so-called
# developer's guide.
#
# See the basis_add_doc() command for details on the documentation build tools
# supported by BASIS for the generation of documentation from plain text files
# and in-source code comments.
#
# Copyright (c) <year> University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# API documentation (in-source code comments)
basis_add_doc (apidoc GENERATOR Doxygen)

# ----------------------------------------------------------------------------
# software manual
set (OUTPUT_NAME "${PROJECT_NAME}_Software_Manual")

foreach (N IN ITEMS Manual UserManual SoftwareManual UserGuide)
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${N}.pdf")
    basis_add_doc (${N}.pdf OUTPUT_NAME "${OUTPUT_NAME}.pdf")
    break ()
  endif ()
endforeach ()

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/manual/index.rst")
  basis_add_doc (
    manual
    GENERATOR        Sphinx
    BUILDER          pdf html
    OUTPUT_NAME      "${OUTPUT_NAME}"
    HTML_DESTINATION "${INSTALL_DOC_DIR}/html"
    COPYRIGHT        "<year> University of Pennsylvania"
    AUTHOR           "<author>"
  )
endif ()

# ----------------------------------------------------------------------------
# developer's guide (optional)
set (OUTPUT_NAME "${PROJECT_NAME}_Developer's_Guide")

foreach (N IN ITEMS DeveloperGuide DeveloperManual)
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${N}.pdf")
    basis_add_doc (${N}.pdf OUTPUT_NAME "${OUTPUT_NAME}.pdf")
    break ()
  endif ()
endforeach ()

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/developer/index.rst")
  basis_add_doc (
    guide
    GENERATOR        Sphinx
    BUILDER          pdf html
    SOURCE_DIRECTORY developer
    OUTPUT_NAME      "${OUTPUT_NAME}"
    COPYRIGHT        "<year> University of Pennsylvania"
    AUTHOR           "<author>"
  )
endif ()

# ----------------------------------------------------------------------------
# web site (optional)
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/site/index.rst")
  basis_add_doc (
    site
    GENERATOR     Sphinx
    BUILDER       html dirhtml pdf man
    MAN_SECTION   7
    SHOW_RELEASE  false
    INDEXLINK     "SBIA Software"
    RELLINKS      download installation documentation examples publications
    HTML_SIDEBARS localtoc relations sourcelink
    LATEX_TITLE   "${PROJECT_NAME}"
    COPYRIGHT     "<year> University of Pennsylvania"
    AUTHOR        "<author>"
  )
endif ()
