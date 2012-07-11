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

# The Python utilities can be found in <src>/lib/python/. Note that the packages
# found in the lib/ directory are automatically configured, build, and installed
# by BASIS.


# TODO Remove the following once this idea is implemented.
basis_get_target_name (UTILITIES ${BASIS_PYTHON_UTILITIES_LIBRARY})
basis_add_library (
  ${UTILITIES}
    "${PROJECT_LIBRARY_DIR}/python/sbia/__init__.py"
    "${PROJECT_LIBRARY_DIR}/python/sbia/basis/__init__.py"
    "${PROJECT_LIBRARY_DIR}/python/sbia/basis/argparse.py"
    "${PROJECT_LIBRARY_DIR}/python/sbia/basis/diff3.py"
    "${PROJECT_LIBRARY_DIR}/python/sbia/basis/utilities.py"
    "${PROJECT_LIBRARY_DIR}/python/sbia/basis/which.py"
)
basis_set_target_properties (${UTILITIES} PROPERTIES SOURCE_DIRECTORY "${PROJECT_LIBRARY_DIR}/python")
