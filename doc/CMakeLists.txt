# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Carnegie Mellon University
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

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
##############################################################################

# ============================================================================
# generic targets
# ============================================================================

# create custom targets so "make site" and "make manual" always work
# note that the "doc" target is added automatically which will trigger
# the build of the complete documentation unless the EXCLUDE_FROM_ALL
# option is passed to basis_add_doc
basis_add_custom_target (site)   # build HTML pages
basis_add_custom_target (manual) # build PDF manual

# ============================================================================
# API reference (in-source code comments)
# ============================================================================

# replace < year|contact|copyright|license > pattern in template file which
# shall be included in documentation to avoid unrecognized xml/html tag warning
function (basis_sanitize_template_for_doxygen OUTPUT_FILE_VAR TEMPLATE_FILE)
  get_filename_component (TEMPLATE_NAME "${TEMPLATE_FILE}" NAME)
  file (READ "${TEMPLATE_FILE}" TEMPLATE)
  string (REGEX REPLACE "<year>"      "&lt;year&gt;"      TEMPLATE "${TEMPLATE}")
  string (REGEX REPLACE "<contact>"   "&lt;contact&gt;"   TEMPLATE "${TEMPLATE}")
  string (REGEX REPLACE "<copyright>" "&lt;copyright&gt;" TEMPLATE "${TEMPLATE}")
  string (REGEX REPLACE "<license>"   "&lt;license&gt;"   TEMPLATE "${TEMPLATE}")
  set (OUTPUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${TEMPLATE_NAME}")
  file (WRITE "${OUTPUT_FILE}" "${TEMPLATE}")
  set (${OUTPUT_FILE_VAR} "${OUTPUT_FILE}" PARENT_SCOPE)
endfunction ()

basis_sanitize_template_for_doxygen (DEPENDS_MODULE   "${PROJECT_DATA_DIR}/templates/basis/1.0/config/Depends.cmake")
basis_sanitize_template_for_doxygen (BOOTSTRAP_MODULE "${PROJECT_DATA_DIR}/templates/basis/1.1/BasisBootstrapping.cmake")

basis_add_doc (
  apidoc 
  GENERATOR             Doxygen
  INPUT                 "${DEPENDS_MODULE}" "${BOOTSTRAP_MODULE}"
  EXCLUDE_PATTERNS      # External libraries packaged with BASIS to exclude from final documentation
                        "*/gmock/*"            # Google Mock
                        "*/gtest/*"            # Google Test
                        "*/tclap/*"            # TCLAP library
                        "*/breathe/*"          # Sphinx extension
                        "*/doxylink/*"         # Sphinx extension
                        "*/argh/*"             # Python Argh
                        "*/test.cxx"           # Google Mock and Test
                        "*/test_main.cxx"      # main() of unit tests based on GMock
                        "*/testdriver.cxx"     # testdriver which includes *.inc files
  HTML_DESTINATION      "${INSTALL_DOC_DIR}/html/apidoc/latest"
  HTML_HEADER	          "apidoc/doxygen_header.html.in"
  HTML_FOOTER           "apidoc/doxygen_footer.html.in"
  HTML_EXTRA_STYLESHEET "apidoc/doxygen_extra.css.in"
  OUTPUT                html xml
)

# ============================================================================
# software manual
# ============================================================================

# add build target for the generation of the web pages and PDF manual from
# the same set of reStructuredText input source files
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/manual.rst" AND
    EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/sidebar.rst")

  basis_add_doc (
    softwaremanual                                        # documenation build target name
    GENERATOR        Sphinx                               # select Sphinx as the generator
    BUILDER          html pdf man                         # selected Sphinx output formats
    MAN_SECTION      7                                    # http://en.wikipedia.org/wiki/Man_page#Manual_sections
    HTML_THEME       cmake-basis                          # select the Sphinx layout theme
    HTML_LOGO        logo_title.svg                       # logo to use at heading of documentation
    HTML_FAVICON     favicon.ico                          # icon for bookmark and tab title
    HTML_SIDEBARS    searchbox globaltoc links            # sidebar options to use
    HTML_DESTINATION "${INSTALL_DOC_DIR}/html"            # output directory for completed documentation
    SIDEBARWIDTH     300                                  # sidebar width in pixels
    MASTER_DOC       "sidebar"                            # .rst file to start with when generating HTML
    LATEX_MASTER_DOC "manual"                             # .rst file to start with when generating LaTeX/PDF
    LATEX_TITLE      "${PROJECT_NAME} Software Manual"    # title within LaTeX/PDF documents
    OUTPUT_NAME      "${PROJECT_NAME}_Software_Manual"    # general output file name, e.g., LaTeX/PDF files
    DOXYLINK         apidoc                               # Doxygen generator build target for integrated API reference
    DOXYLINK_URL     "${PROJECT_WEBSITE}/apidoc/latest"   # location of Doxygen output files
    NO_HTML_MODINDEX NO_HTML_INDEX                        # disable currently unused index page
    EXCLUDE_PATTERN  intro.rst                            # .rst files explicitly included only
    EXCLUDE_PATTERN  faq.rst
    EXCLUDE_PATTERN  features.rst
  )
  
  # the Sphinx :download: link directive requires the download file to
  # be present in the source tree; thus copy generated PDF to source tree
  # if it contains modifications since last time
  basis_add_custom_target (softwaremanual_pdf_update
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different
      "${CMAKE_CURRENT_BINARY_DIR}/latex/${PROJECT_NAME}_Software_Manual.pdf" 
      "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_Software_Manual.pdf"
  )
  
  # add dependency such that PDF is re-generated before copied to source tree if it differs
  basis_add_dependencies (softwaremanual_pdf_update softwaremanual_pdf)
  # before building the HTML documentation, ensure that source tree version of manual is up-to-date
  basis_add_dependencies (softwaremanual_html softwaremanual_pdf_update)
  
  basis_add_dependencies  (site   softwaremanual_html)       # so "make site"   builds softwaremanual_html
  basis_add_dependencies  (manual softwaremanual_pdf_update) # so "make manual" builds softwaremanual_pdf

endif ()
