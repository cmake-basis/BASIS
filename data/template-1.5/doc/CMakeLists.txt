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

# ============================================================================
# API documentation (in-source code comments)
# ============================================================================

set (OPTIONS)

# ----------------------------------------------------------------------------
# pre-generated API documentation
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/apidoc/html/index.html")
  basis_add_doc ("${CMAKE_CURRENT_SOURCE_DIR}/apidoc/html" DESTINATION "${INSTALL_DOC_DIR}/apidoc")
  list (APPEND OPTIONS EXCLUDE_FROM_DOC)
endif ()

# ----------------------------------------------------------------------------
# Doxygen
basis_add_doc (
  apidoc           ${OPTIONS}
  GENERATOR        Doxygen
  HTML_DESTINATION "${INSTALL_DOC_DIR}/apidoc"
)

# ============================================================================
# condensed software manual (e.g., excluding download and installation)
# ============================================================================

set (OUTPUT_NAME "${PROJECT_NAME} Software Manual")

# ----------------------------------------------------------------------------
# pre-generated PDF
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/site/${OUTPUT_NAME}.pdf")
  # pre-generated PDF which is included with web site for download
  basis_add_doc ("site/${OUTPUT_NAME}.pdf")
else ()
  # other pre-generated PDF found in the current source directory
  foreach (N IN ITEMS manual Manual UserManual SoftwareManual UserGuide userguide)
    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${N}.pdf")
      basis_add_doc (${N}.pdf OUTPUT_NAME "${OUTPUT_NAME}.pdf")
      break ()
    endif ()
  endforeach ()
endif ()

# ----------------------------------------------------------------------------
# generate software manual from reStructuredText sources
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/manual/index.rst")
  basis_add_doc (
    manual
    GENERATOR        Sphinx
    BUILDER          pdf html
    OUTPUT_NAME      "${OUTPUT_NAME}"
    HTML_DESTINATION "${INSTALL_DOC_DIR}/manual"
  )
endif ()

# ============================================================================
# developer's guide (optional)
# ============================================================================

set (OUTPUT_NAME "${PROJECT_NAME} Developer's Guide")

# ----------------------------------------------------------------------------
# pre-generated PDF
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/site/${OUTPUT_NAME}.pdf")
  # pre-generated PDF which is included with web site for download
  basis_add_doc ("site/${OUTPUT_NAME}.pdf")
else ()
  # other pre-generated PDF found in the current source directory
  foreach (N IN ITEMS DeveloperManual DeveloperGuide)
    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${N}.pdf")
      basis_add_doc (${N}.pdf OUTPUT_NAME "${OUTPUT_NAME}.pdf")
      break ()
    endif ()
  endforeach ()
endif ()

# ----------------------------------------------------------------------------
# generate developer's guide from reStructuredText sources
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/developer/index.rst")
  basis_add_doc (
    guide
    GENERATOR        Sphinx
    BUILDER          pdf html
    SOURCE_DIRECTORY developer
    OUTPUT_NAME      "${OUTPUT_NAME}"
    HTML_DESTINATION "${INSTALL_DOC_DIR}/guide"
  )
endif ()

# ============================================================================
# web site (optional)
# ============================================================================

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/site/index.rst")

  set (HTML_SIDEBARS localtoc relations)

  # --------------------------------------------------------------------------
  # pre-generated site PDF for download
  if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/site/${PROJECT_NAME}.pdf")
    basis_add_doc ("${CMAKE_CURRENT_LIST_DIR}/site/${PROJECT_NAME}.pdf")
    list (APPEND HTML_SIDEBARS sourcepdflink)
  else ()
    list (APPEND HTML_SIDEBARS sourcelink)
  endif ()

  # --------------------------------------------------------------------------
  # web site
  basis_add_doc (
    site
    GENERATOR     Sphinx
    BUILDER       html dirhtml pdf man
    MAN_SECTION   7
    HTML_THEME    ${PROJECT_PACKAGE_VENDOR_L}
    SHOW_RELEASE  false
    INDEXLINK     "${PROJECT_PACKAGE_VENDOR} Software"
    RELLINKS      download installation documentation examples publications
    HTML_SIDEBARS ${HTML_SIDEBARS}
    LATEX_TITLE   "${PROJECT_NAME}"
  )

endif ()

# ============================================================================
# comprehensive manual (may contain all of the above)
# ============================================================================

if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/index.rst")

  set (OPTIONS)
  set (HTML_SIDEBARS localtoc relations)

  # --------------------------------------------------------------------------
  # pre-generated PDF
  if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}.pdf")
    basis_add_doc ("${PROJECT_NAME}.pdf")
    list (APPEND HTML_SIDEBARS sourcepdflink)
    list (APPEND OPTIONS       EXCLUDE_FROM_DOC)
  else ()
    list (APPEND HTML_SIDEBARS sourcelink)
  endif ()

  # --------------------------------------------------------------------------
  # comprehensive software manual
  basis_add_doc (
    softwaremanual   ${OPTIONS}
    GENERATOR        Sphinx
    BUILDER          pdf html dirhtml man
    MAN_SECTION      7
    HTML_THEME       ${PROJECT_PACKAGE_VENDOR_L}
    SHOW_RELEASE     false
    INDEXLINK        "${PROJECT_PACKAGE_VENDOR} Software"
    RELLINKS         download installation documentation faq publications
    HTML_SIDEBARS    ${HTML_SIDEBARS}
    HTML_DESTINATION "${INSTALL_DOC_DIR}/html"
    LATEX_TITLE      ${PROJECT_NAME}
    EXCLUDE_PATTERNS "manual/*"    # condensed manual
                     "developer/*" # developer's guide
                     "site/*"      # web site
  )

  # --------------------------------------------------------------------------
  # add dummy 'site' target(s)
  basis_exists_target (SITE_TARGET_EXISTS site)
  if (NOT SITE_TARGET_EXISTS)
    basis_add_custom_target (site)
    basis_add_dependencies (site softwaremanual_html)
    basis_add_custom_target (site_dirhtml)
    basis_add_dependencies (site_dirhtml softwaremanual_dirhtml)
  endif ()

  # --------------------------------------------------------------------------
  # add dummy 'manual' target
  basis_exists_target (MANUAL_TARGET_EXISTS manual)
  if (NOT MANUAL_TARGET_EXISTS)
    basis_add_custom_target (manual)
    basis_add_dependencies (manual softwaremanual_pdf)
  endif ()

endif ()
