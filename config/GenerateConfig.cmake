##############################################################################
# \file  CMakeLists.txt
# \brief Configures and installs configuration files of SBIA @PROJECT_NAME@ package.
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

# include directories
set (INCLUDE_DIR "")



if (INCLUDE_DIR)
  list (REMOVE_DUPLICATES INCLUDE_DIR)
endif ()

# path to CMake modules
set (MODULE_PATH "${SOFTWARE_SOURCE_DIR}/src/cmake")

# ----------------------------------------------------------------------------
# configure project configuration file for build tree

configure_file ("${PROJECT_CONFIG_TEMPLATE}"
                "${PROJECT_BINARY_DIR}/${CONFIG_FILE}" @ONLY)

# ----------------------------------------------------------------------------
# install tree related configuration

# include directories
set (INCLUDE_DIR "")



if (INCLUDE_DIR)
  list (REMOVE_DUPLICATES INCLUDE_DIR)
endif ()

# path to CMake modules
set (MODULE_PATH "\${CMAKE_CURRENT_LIST_DIR}")

# ----------------------------------------------------------------------------
# configure project configuration file for install tree

configure_file ("${PROJECT_CONFIG_TEMPLATE}"
                "${PROJECT_BINARY_DIR}/${CONFIG_FILE}.install" @ONLY)

# ----------------------------------------------------------------------------
# install project configuration file

get_filename_component (CONFIG_DIR  "${CONFIG_FILE}" PATH)
get_filename_component (CONFIG_NAME "${CONFIG_FILE}" NAME)

if (NOT CONFIG_DIR)
  set (CONFIG_DIR ".")
endif ()

install (
  FILES       "${PROJECT_BINARY_DIR}/${CONFIG_FILE}.install"
  DESTINATION "${CONFIG_DIR}"
  RENAME      "${CONFIG_NAME}"
)

# ============================================================================
# project version file
# ============================================================================

# ----------------------------------------------------------------------------
# configure project configuration version file

configure_file ("${PROJECT_VERSION_TEMPLATE}"
                "${PROJECT_BINARY_DIR}/${VERSION_FILE}" @ONLY)

# ----------------------------------------------------------------------------
# install project configuration version file

get_filename_component (VERSION_DIR  "${VERSION_FILE}" PATH)
get_filename_component (VERSION_NAME "${VERSION_FILE}" NAME)

if (NOT VERSION_DIR)
  set (VERSION_DIR ".")
endif ()

install (
  FILES       "${PROJECT_BINARY_DIR}/${VERSION_FILE}"
  DESTINATION "${VERSION_DIR}"
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

if (NOT USE_DIR)
  set (USE_DIR ".")
endif ()

install (
  FILES       "${PROJECT_BINARY_DIR}/${USE_FILE}"
  DESTINATION "${USE_DIR}"
  RENAME      "${USE_NAME}"
)

