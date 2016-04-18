# ============================================================================
# Copyright (c) <copyright>
# All rights reserved.
#
# <license>
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
# API reference (Doxygen-style in-source code comments)
# ============================================================================

basis_find_package(Doxygen REQUIRED)

basis_add_doc (
  apidoc                                                        # documentation build target name
  GENERATOR             Doxygen                                 # select Doxygen as the generator
  HTML_DESTINATION      "${INSTALL_DOC_DIR}/html/apidoc/latest" # output location of html documentation
  HTML_HEADER	          "apidoc/doxygen_header.html.in"         # custom top of page with CMake substitutions to fit with Sphinx
  HTML_FOOTER           "apidoc/doxygen_footer.html.in"         # custom bottom of page with CMake substitutions to fit with Sphinx
  HTML_EXTRA_STYLESHEET "apidoc/doxygen_extra.css.in"           # custom formatting to fit in with the Sphinx docs
  OUTPUT                html xml                                # request output in HTML for websites and XML for reprocessing,
                                                                # such as with the breathe Sphinx extension in particular
)
 
# ============================================================================
# Software manual
# ============================================================================

# add build target for the generation of the web pages and PDF manual from
# the same set of reStructuredText input source files
basis_set_if_not_set (BUILD_SOFTWAREMANUAL ON)
if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/manual.rst" AND
    EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/sidebar.rst")

  basis_find_package (Sphinx REQUIRED COMPONENTS build)
  basis_find_package (LATEX  REQUIRED COMPONENTS PDFLATEX)

  # software manual output formats
  set (SOFTWAREMANUAl_BUILDER html pdf)
  if (UNIX)
    list (APPEND SOFTWAREMANUAL_BUILDER man)
  endif ()

  # add target to build software manual
  basis_add_doc (
    softwaremanual                                        # documenation build target name
    GENERATOR        Sphinx                               # select Sphinx as the generator
    BUILDER          ${SOFTWAREMANUAl_BUILDER}            # selected Sphinx output formats
    MAN_SECTION      7                                    # http://en.wikipedia.org/wiki/Man_page#Manual_sections
    HTML_THEME       cmake-basis                          # select the Sphinx layout theme
    HTML_LOGO        logo.svg                             # logo to use at heading of documentation
    HTML_SIDEBARS    searchbox globaltoc                  # sidebar options to use
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
    EXCLUDE_PATTERN  features.rst
  )

  # PDF manual required for build of HTML download page
  #
  # Note that the Sphinx :download: link directive requires the download file
  # to be present in the source tree; thus copy generated PDF to source tree
  add_custom_command (TARGET softwaremanual_pdf POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different
      "${CMAKE_CURRENT_BINARY_DIR}/latex/${PROJECT_NAME}_Software_Manual.pdf" 
      "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}_Software_Manual.pdf"
  )
  basis_add_dependencies (softwaremanual_html softwaremanual_pdf)

  # add dependency to more readable target names
  basis_add_dependencies (manual softwaremanual_pdf)
  basis_add_dependencies (site   softwaremanual_html)

endif ()
