##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Sphinx extensions.
#
# Copyright (c) 2011-2012 University of Pennsylvania. <br />
# Copyright (c) 2013-2014 Andreas Schuh.              <br />
# All rights reserved.                                <br />
#
# See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
# or COPYING file for license information.
#
# Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
#          report issues at https://github.com/schuhschuh/cmake-basis/issues
##############################################################################

basis_add_library (breathe)
basis_add_library (doxylink)

basis_set_target_properties (
  breathe doxylink
  PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY  "${BINARY_PYTHON_LIBRARY_DIR}"
    LIBRARY_INSTALL_DIRECTORY "${INSTALL_PYTHON_LIBRARY_DIR}"
    PREFIX                    "${SPHINX_EXTENSIONS_PREFIX}"
)
