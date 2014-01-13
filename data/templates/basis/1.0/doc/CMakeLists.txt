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
# Copyright (c) <copyright>
# All rights reserved.
#
# <license>
#
# Contact: <contact>
##############################################################################

# ============================================================================
# settings
# ============================================================================

# output names of PDF's generated from reStructuredText sources (excl. extension)
set (SITE_OUTPUT_NAME   "${PROJECT_NAME}_Web_Site")
set (MANUAL_OUTPUT_NAME "${PROJECT_NAME}_Software_Manual")
set (GUIDE_OUTPUT_NAME  "${PROJECT_NAME}_Developer_Guide")
set(APIDOC_DEPENDS_INPUT) # clear variable

# ============================================================================
# API reference (in-source code comments)
# ============================================================================

 # create a custom target so "make site" and "make manual" works on the command line

basis_add_custom_target (site)                    
basis_add_custom_target (manual)

# creade Doxygen documentation

basis_add_doc (
  # documentation target name 
  apidoc                ${APIDOC_OPTIONS}      # additional options specified elsewhere (todo: explain in more detail)
  GENERATOR             Doxygen                # select doxygen as the generator, Sphinx is an alternative
                        
  HTML_DESTINATION      "${INSTALL_DOC_DIR}/html/apidoc/latest" # output location of html documentation
  HTML_HEADER	          "apidoc/doxygen_header.html.in"       # custom top of page with CMake substitutions to fit with sphinx
  HTML_FOOTER           "apidoc/doxygen_footer.html.in"         # custom bottom of page with CMake substitutions to fit with sphinx
  HTML_EXTRA_STYLESHEET "apidoc/doxygen_extra.css.in"           # custom formatting to fit in with the sphinx docs
  
  OUTPUT                html xml                                # output in html for websites and xml for reprocessing, such as with the breathe sphinx extension
)

basis_add_dependencies (doc    apidoc) # make the general doc target build the apidoc
 

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/index.rst" AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/sidebar.rst")

    # ============================================================================
    # software manual
    # ============================================================================
    
    basis_add_doc (
      softwaremanual                                        # documenation target name, the name of what you specify when you say "make softwaremanual" in this case
      GENERATOR        Sphinx                               # slect sphinx as the generator, doxygen is an alternative
      BUILDER          html pdf man                         # selected output documentation formats
      MAN_SECTION      7                                    # (todo: what is the MAN_SECTION 7 flag?)
      
      HTML_THEME       cmake-basis                          # select the cmake-basis sphinx layout theme provided by BASIS in basis/src/sphinx/themes
                                                            # this could specify a path to a theme you provide
      HTML_LOGO        logo.svg                             # logo to use at heading of documentation
      HTML_SIDEBARS    searchbox globaltoc                  # sidebar options to use
      HTML_DESTINATION "${INSTALL_DOC_DIR}/html"            # output directory for completed documentation
      SIDEBARWIDTH     300                                  # sidebar width in pixels
      
      MASTER_DOC       "sidebar"                            # restructured text file to start with when generating HTML documentation
      LATEX_MASTER_DOC "manual"                             # restructured text file to start with when generating LaTeX, and thus PDF documentation                
      LATEX_TITLE      "${PROJECT_NAME} Software Manual"    # Title to use in the PDF doc itself
      OUTPUT_NAME      "${PROJECT_NAME}_Software_Manual"
      
      DOXYLINK         apidoc                               # target to use for integrated Doxygen documentation
      DOXYLINK_URL     "${PROJECT_WEBSITE}/apidoc/latest"   # location of integrated Doxygen documentation output files
      
      NO_HTML_MODINDEX NO_HTML_INDEX                        # disable index page (we don't currently use it)
    )
    
    
    # set a trigger so "make site" will build softwaremanual_html, 
    # "make manual" will build softwaremanual_pdf, 
    # and "make doc" will build all of the above
    
    basis_add_dependencies (site   softwaremanual_html)    
    basis_add_dependencies (manual softwaremanual_pdf)
    basis_add_dependencies (doc    site manual)

endif ()

