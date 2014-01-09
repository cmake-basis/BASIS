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
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# API reference (in-source code comments)
# ============================================================================

# replace < year > pattern in template file which shall be included in
# documentation to avoid unrecognized xml/html tags warning of Doxygen
file (READ "${PROJECT_DATA_DIR}/templates/basis/1.0/config/Depends.cmake" TEMPLATE)
string (REGEX REPLACE "<year>" "&lt;year&gt;" TEMPLATE "${TEMPLATE}")
file (WRITE "${PROJECT_BINARY_DIR}/doc/Depends.cmake" "${TEMPLATE}")
unset (TEMPLATE)

basis_add_doc (
  apidoc                ${APIDOC_OPTIONS}
  GENERATOR             Doxygen
  INPUT                 "${PROJECT_BINARY_DIR}/doc/Depends.cmake"
  EXCLUDE_PATTERNS      # external libraries packaged with BASIS
                        "*/gmock/*"            # Google Mock
                        "*/gtest/*"            # Google Test
                        "*/tclap/*"            # TCLAP library
                        "*/breathe/*"          # Sphinx extension
                        "*/doxylink/*"         # Sphinx extension
                        "*/argh/*"             # Python Argh
                        "*/test.cxx"           # Google Mock and Test
                        "*/test_main.cxx"      # main() of unit tests based on GMock
                        # testdriver which includes *.inc files
                        "*/testdriver.cxx"
  HTML_DESTINATION      "${INSTALL_DOC_DIR}/html/apidoc/latest"
  HTML_HEADER	          "apidoc/doxygen_header.html.in" 
  HTML_FOOTER           "apidoc/doxygen_footer.html.in" 
  HTML_EXTRA_STYLESHEET "apidoc/doxygen_extra.css.in"
  OUTPUT                html xml
)

# ============================================================================
# software manual
# ============================================================================

basis_add_doc (
  softwaremanual
  GENERATOR        Sphinx
  BUILDER          html pdf man
  MAN_SECTION      7
  HTML_THEME       readable-wide
  HTML_LOGO        logo_title.svg
  HTML_SIDEBARS    searchbox globaltoc
  HTML_DESTINATION "${INSTALL_DOC_DIR}/html"
  SIDEBARWIDTH     300
  MASTER_DOC       "sidebar"
  LATEX_MASTER_DOC "manual"
  LATEX_TITLE      "${PROJECT_NAME} Software Manual"
  OUTPUT_NAME      "${PROJECT_NAME}_Software_Manual"
  DOXYLINK         apidoc
  DOXYLINK_URL     "${PROJECT_WEBSITE}/apidoc/latest"
  NO_HTML_MODINDEX NO_HTML_INDEX
)

basis_add_custom_target (site)
basis_add_custom_target (manual)

basis_add_dependencies (site   softwaremanual_html)
basis_add_dependencies (manual softwaremanual_pdf)
basis_add_dependencies (doc    site manual)
