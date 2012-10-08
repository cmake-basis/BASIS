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
# settings
# ============================================================================

# output names of PDF's generated from reStructuredText sources (excl. extension)
set (SITE_OUTPUT_NAME   "${PROJECT_NAME}_Web_Site")
set (MANUAL_OUTPUT_NAME "${PROJECT_NAME}_Software_Manual")
set (GUIDE_OUTPUT_NAME  "${PROJECT_NAME}_Developer_Guide")

# in particular, EXCLUDE_FROM_DOC will be added if pre-generated files exist
set (APIDOC_OPTIONS)
set (SITE_OPTIONS)
set (MANUAL_OPTIONS)
set (GUIDE_OPTIONS)

# ============================================================================
# pre-generated output files
# ============================================================================

# API documentation
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/apidoc/html/index.html")
  basis_add_doc ("${CMAKE_CURRENT_SOURCE_DIR}/apidoc/html" DESTINATION "${INSTALL_DOC_DIR}/apidoc")
  list (APPEND APIDOC_OPTIONS EXCLUDE_FROM_DOC)
endif ()

# web site
foreach (N IN ITEMS ${SITE_OUTPUT_NAME} site Site)
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${N}.pdf")
    basis_add_doc (${N}.pdf OUTPUT_NAME "${SITE_OUTPUT_NAME}.pdf")
    list (APPEND SITE_OPTIONS EXCLUDE_FROM_DOC)
    break ()
  endif ()
endforeach ()

# software manual
foreach (N IN ITEMS ${MANUAL_OUTPUT_NAME} manual Manual UserManual SoftwareManual UserGuide userguide)
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${N}.pdf")
    basis_add_doc (${N}.pdf OUTPUT_NAME "${MANUAL_OUTPUT_NAME}.pdf")
    list (APPEND MANUAL_OPTIONS EXCLUDE_FROM_DOC)
    break ()
  endif ()
endforeach ()

# developer's guide
foreach (N IN ITEMS ${GUIDE_OUTPUT_NAME} guide DeveloperGuide DeveloperManual developerguide)
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${N}.pdf")
    basis_add_doc (${N}.pdf OUTPUT_NAME "${GUIDE_OUTPUT_NAME}.pdf")
    list (APPEND GUIDE_OPTIONS EXCLUDE_FROM_DOC)
    break ()
  endif ()
endforeach ()

# ============================================================================
# API documentation (in-source code comments)
# ============================================================================

# replace <year> pattern in template file which shall be included in documentation
# to avoid unrecognized xml/html tags warning of Doxygen
file (READ "${PROJECT_DATA_DIR}/template-1.3/config/Depends.cmake" TEMPLATE)
string (REGEX REPLACE "<year>" "&lt;year&gt;" TEMPLATE "${TEMPLATE}")
file (WRITE "${PROJECT_BINARY_DIR}/doc/Depends.cmake" "${TEMPLATE}")
unset (TEMPLATE)

basis_add_doc (
  apidoc           ${APIDOC_OPTIONS}
  GENERATOR        Doxygen
  INPUT            "${PROJECT_BINARY_DIR}/doc/Depends.cmake"
  EXCLUDE_PATTERNS # external libraries packaged with BASIS
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
  HTML_DESTINATION "${INSTALL_DOC_DIR}/apidoc"
)

# ============================================================================
# comprehensive manual
# ============================================================================

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/index.rst")

  basis_add_doc (
    softwaremanual   ${MANUAL_OPTIONS}
    GENERATOR        Sphinx
    BUILDER          pdf html dirhtml man
    MAN_SECTION      7
    HTML_THEME       ${PROJECT_PACKAGE_VENDOR_L}
    RELLINKS         download installation manual help people
    SIDEBARWIDTH     300
    HTML_LOGO        logo.png
    HTML_SIDEBARS    searchbox globaltoc
    HTML_DESTINATION "${INSTALL_DOC_DIR}/html"
    LATEX_TITLE      "${PROJECT_NAME} Software Manual"
    OUTPUT_NAME      "${MANUAL_OUTPUT_NAME}"
    DOXYLINK         apidoc
    DOXYLINK_URL     http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest
  )

  basis_add_custom_target (site)
  basis_add_custom_target (site_dirhtml)
  basis_add_custom_target (manual)

  basis_add_dependencies  (site         softwaremanual_html)
  basis_add_dependencies  (site_dirhtml softwaremanual_dirhtml)
  basis_add_dependencies  (manual       softwaremanual_pdf)

# ============================================================================
# separate web site and manual
# ============================================================================

else ()

  # web site
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/site/index.rst")
    basis_add_doc (
      site          ${SITE_OPTIONS}
      GENERATOR     Sphinx
      BUILDER       html dirhtml pdf man
      MAN_SECTION   7
      HTML_THEME    ${PROJECT_PACKAGE_VENDOR_L}
      RELLINKS      download installation manual publications people
      HTML_SIDEBARS searchbox globaltoc
      LATEX_TITLE   "${PROJECT_NAME}"
      OUTPUT_NAME   "${SITE_OUTPUT_NAME}"
    )
  endif ()

  # software manual
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/manual/index.rst")
    basis_add_doc (
      manual           ${MANUAL_OPTIONS}
      GENERATOR        Sphinx
      BUILDER          pdf html
      HTML_DESTINATION "${INSTALL_DOC_DIR}/html"
      OUTPUT_NAME      "${MANUAL_OUTPUT_NAME}"
    )
  endif ()

endif ()

# ============================================================================
# developer's guide
# ============================================================================

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/guide/index.rst")
  basis_add_doc (
    guide            ${GUIDE_OPTIONS}
    GENERATOR        Sphinx
    BUILDER          pdf html
    HTML_DESTINATION "${INSTALL_DOC_DIR}/guide"
    LATEX_TITLE      "${PROJECT_NAME} Developer's Guide"
    OUTPUT_NAME      "${GUIDE_OUTPUT_NAME}"
  )
endif ()
