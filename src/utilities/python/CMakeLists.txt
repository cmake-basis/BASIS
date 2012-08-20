##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Python utilities.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# template files
basis_install (
  FILES
    "__init__.py.in" # default package configuration file
    "basis.py.in"    # project-specific utilities
  DESTINATION
    "${INSTALL_PYTHON_TEMPLATES_DIR}"
)

# ----------------------------------------------------------------------------
# utilities
basis_get_target_name (UTILITIES ${BASIS_PYTHON_UTILITIES_LIBRARY})

basis_add_library (
  ${UTILITIES}
    __init__.py
    argparse.py
    diff3.py
    utilities.py
    which.py
)

basis_library_prefix (PREFIX PYTHON)
basis_set_target_properties (
  ${UTILITIES}
  PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY  "${BINARY_PYTHON_LIBRARY_DIR}"
    LIBRARY_INSTALL_DIRECTORY "${INSTALL_PYTHON_LIBRARY_DIR}"
    PREFIX                    "${PREFIX}"
)

add_dependencies (${ALL_UTILITIES} ${UTILITIES})
