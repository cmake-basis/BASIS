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

# replace < year|contact|copyright|license > pattern in template file which
# shall be included in documentation to avoid unrecognized xml/html tag warning
file (READ "${PROJECT_DATA_DIR}/templates/basis/1.0/config/Depends.cmake" TEMPLATE)
string (REGEX REPLACE "<year>"      "&lt;year&gt;"      TEMPLATE "${TEMPLATE}")
string (REGEX REPLACE "<contact>"   "&lt;contact&gt;"   TEMPLATE "${TEMPLATE}")
string (REGEX REPLACE "<copyright>" "&lt;copyright&gt;" TEMPLATE "${TEMPLATE}")
string (REGEX REPLACE "<license>"   "&lt;license&gt;"   TEMPLATE "${TEMPLATE}")
file (WRITE "${PROJECT_BINARY_DIR}/doc/Depends.cmake" "${TEMPLATE}")
unset (TEMPLATE)

basis_add_doc (
  # documentation target name 
  apidoc                ${APIDOC_OPTIONS}      # additional options specified elsewhere (todo: explain in more detail)
  GENERATOR             Doxygen                # select doxygen as the generator, Sphinx is an alternative
  INPUT                 "${PROJECT_BINARY_DIR}/doc/Depends.cmake" 
  
  EXCLUDE_PATTERNS      # External libraries packaged with BASIS to exclude from final documentation
                        "*/gmock/*"            # Google Mock
                        "*/gtest/*"            # Google Test
                        "*/tclap/*"            # TCLAP library
                        "*/breathe/*"          # Sphinx extension
                        "*/doxylink/*"         # Sphinx extension
                        "*/argh/*"             # Python Argh
                        "*/test.cxx"           # Google Mock and Test
                        "*/test_main.cxx"      # main() of unit tests based on GMock
                       
                        "*/testdriver.cxx"      # testdriver which includes *.inc files
                        
  HTML_DESTINATION      "${INSTALL_DOC_DIR}/html/apidoc/latest" # output location of html documentation
  HTML_HEADER	          "apidoc/doxygen_header.html.in"       # custom top of page with CMake substitutions to fit with sphinx
  HTML_FOOTER           "apidoc/doxygen_footer.html.in"         # custom bottom of page with CMake substitutions to fit with sphinx
  HTML_EXTRA_STYLESHEET "apidoc/doxygen_extra.css.in"           # custom formatting to fit in with the sphinx docs
  
  OUTPUT                html xml                                # output in html for websites and xml for reprocessing, such as with the breathe sphinx extension
)

# ============================================================================
# software manual
# ============================================================================

basis_add_doc (
  softwaremanual                                        # documenation target name, the name of what you specify when you say "make softwaremanual" in this case
  GENERATOR        Sphinx                               # slect sphinx as the generator, doxygen is an alternative
  BUILDER          html pdf man                         # selected output documentation formats
  MAN_SECTION      7                                    # (todo: what is the MAN_SECTION 7 flag?)
  
  HTML_THEME       readable-wide                        # select the readable-wide sphinx layout theme provided by BASIS
                                                        # this could specify a path to a theme you provide
  HTML_LOGO        logo_title.svg                       # logo to use at heading of documentation
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

 # create a custom target so "make site" and "make manual" works on the command line

basis_add_custom_target (site)                    
basis_add_custom_target (manual)

# set a trigger so "make site" will build softwaremanual_html, 
# "make manual" will build softwaremanual_pdf, 
# and "make doc" will build all of the above

basis_add_dependencies (site   softwaremanual_html)    
basis_add_dependencies (manual softwaremanual_pdf)
basis_add_dependencies (doc    site manual)
