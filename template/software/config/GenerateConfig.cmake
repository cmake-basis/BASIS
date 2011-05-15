##############################################################################
# \file  CMakeLists.txt
# \brief Configures and installs the configuration files Config.cmake.in,
#        ConfigVersion.cmake.in, and Use.cmake.in.
#
# This CMake script configures the project's CMake configuration file for
# both the build tree (depends on source tree) and the install tree.
# Further, it configures and installs the corresponding project version file
# and finally also configures and installs the project's use file which can
# be included by other projects at their convenience.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# configure names of output files
# ============================================================================

# \attention This has to be done before configuring any files such that these
#            variables can be used by the template files.

string (CONFIGURE "${PROJECT_CONFIG_FILE}"  CONFIG_FILE  @ONLY)
string (CONFIGURE "${PROJECT_VERSION_FILE}" VERSION_FILE @ONLY)
string (CONFIGURE "${PROJECT_USE_FILE}"     USE_FILE     @ONLY)

# ============================================================================
# project configuration file
# ============================================================================

# ----------------------------------------------------------------------------
# build tree related configuration



# ----------------------------------------------------------------------------
# configure Config.cmake file for build tree

configure_file ("${PROJECT_CONFIG_TEMPLATE}"
                "${PROJECT_BINARY_DIR}/${CONFIG_FILE}" @ONLY)

# ----------------------------------------------------------------------------
# install tree related configuration



# ----------------------------------------------------------------------------
# configure project configuration file for install tree

configure_file ("${PROJECT_CONFIG_TEMPLATE}"
                "${PROJECT_BINARY_DIR}/${CONFIG_FILE}.install" @ONLY)

# ----------------------------------------------------------------------------
# install project configuration file

get_filename_component (CONFIG_DIR  "${CONFIG_FILE}" PATH)
get_filename_component (CONFIG_NAME "${CONFIG_FILE}" NAME)

install (
  FILES       "${PROJECT_BINARY_DIR}/${CONFIG_FILE}.install"
  DESTINATION "${CMAKE_INSTALL_PREFIX}/${CONFIG_DIR}"
  RENAME      "${CONFIG_NAME}"
)

# ============================================================================
# project version 
# ============================================================================

# ----------------------------------------------------------------------------
# configure project configuration version file

configure_file ("${PROJECT_VERSION_TEMPLATE}"
                "${PROJECT_BINARY_DIR}/${VERSION_FILE}" @ONLY)

# ----------------------------------------------------------------------------
# install project configuration version file

get_filename_component (VERSION_DIR  "${VERSION_FILE}" PATH)
get_filename_component (VERSION_NAME "${VERSION_FILE}" NAME)

install (
  FILES       "${PROJECT_BINARY_DIR}/${VERSION_FILE}"
  DESTINATION "${CMAKE_INSTALL_PREFIX}/${VERSION_DIR}"
  RENAME      "${VERSION_NAME}"
)

# ============================================================================
# project use file
# ============================================================================

# ----------------------------------------------------------------------------
# configure project use file

configure_file ("${PROJECT_USE_TEMPLATE}"
                "${PROJECT_BINARY_DIR}/${USE_FILE}" @ONLY)

# ----------------------------------------------------------------------------
# install project use file

get_filename_component (USE_DIR  "${USE_FILE}" PATH)
get_filename_component (USE_NAME "${USE_FILE}" NAME)

install (
  FILES       "${PROJECT_BINARY_DIR}/${USE_FILE}"
  DESTINATION "${CMAKE_INSTALL_PREFIX}/${USE_DIR}"
  RENAME      "${USE_NAME}"
)

