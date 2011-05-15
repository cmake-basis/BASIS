##############################################################################
# \file  CMakeLists.txt
# \brief Configures <Project>(Config|ConfigVersion|Use).cmake files.
#
# This CMake script configures the <Project>Config.cmake et al. files.
# Once for the build tree and once for the install tree. Variables with a
# _CONFIG suffix are replaced in the default template files by either the
# value for the build or the install tree, respectively.
#
# If present, this script includes the PROJECT_CONFIG_DIR/ConfigBuild.cmake
# and/or PROJECT_CONFIG_DIR/ConfigInstall.cmake file before configuring the
# Config.cmake.in template. If a file PROJECT_CONFIG_DIR/Config.cmake.in
# exists, it is used as template. Otherwise, the default template file is used.
#
# Similarly, if the file PROJECT_CONFIG_DIR/ConfigVersion.cmake.in exists,
# it is used as template for the <Project>ConfigVersion.cmake file. The same
# applies to Use.cmake.in.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# names of output files
# ============================================================================

# \attention This has to be done before configuring any files such that these
#            variables can be used by the template files.

set (CONFIG_FILE  "${BASIS_CONFIG_PREFIX}${PROJECT_NAME}Config.cmake")
set (VERSION_FILE "${BASIS_CONFIG_PREFIX}${PROJECT_NAME}ConfigVersion.cmake")
set (USE_FILE     "${BASIS_CONFIG_PREFIX}${PROJECT_NAME}Use.cmake")

# ============================================================================
# project configuration file
# ============================================================================

# ----------------------------------------------------------------------------
# choose template

if (EXISTS "${PROJECT_CONFIG_DIR}/Config.cmake.in")
  set (TEMPLATE "${PROJECT_CONFIG_DIR}/Config.cmake.in")
else ()
  set (TEMPLATE "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in")
endif ()

# ----------------------------------------------------------------------------
# build tree related configuration

include ("${CMAKE_CURRENT_LIST_DIR}/ConfigBuild.cmake")
include ("${PROJECT_CONFIG_DIR}/ConfigBuild.cmake" OPTIONAL)

if (INCLUDE_DIR_CONFIG)
  list (REMOVE_DUPLICATES INCLUDE_DIR_CONFIG)
endif ()

if (LIBRARY_CONFIG)
  list (REMOVE_DUPLICATES LIBRARY_CONFIG)
endif ()

# ----------------------------------------------------------------------------
# configure project configuration file for build tree

configure_file ("${TEMPLATE}" "${PROJECT_BINARY_DIR}/${CONFIG_FILE}" @ONLY)

# ----------------------------------------------------------------------------
# install tree related configuration

include ("${CMAKE_CURRENT_LIST_DIR}/ConfigInstall.cmake")
include ("${PROJECT_CONFIG_DIR}/ConfigInstall.cmake" OPTIONAL)

if (INCLUDE_DIR_CONFIG)
  list (REMOVE_DUPLICATES INCLUDE_DIR_CONFIG)
endif ()

if (LIBRARY_CONFIG)
  list (REMOVE_DUPLICATES LIBRARY_CONFIG)
endif ()

# ----------------------------------------------------------------------------
# configure project configuration file for install tree

configure_file ("${TEMPLATE}" "${PROJECT_BINARY_DIR}/${CONFIG_FILE}.install" @ONLY)

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
# choose template

if (EXISTS "${PROJECT_CONFIG_DIR}/ConfigVersion.cmake.in")
  set (TEMPLATE "${PROJECT_CONFIG_DIR}/ConfigVersion.cmake.in")
else ()
  set (TEMPLATE "${CMAKE_CURRENT_LIST_DIR}/ConfigVersion.cmake.in")
endif ()

# ----------------------------------------------------------------------------
# configure project configuration version file

configure_file ("${TEMPLATE}" "${PROJECT_BINARY_DIR}/${VERSION_FILE}" @ONLY)

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
# choose template

if (EXISTS "${PROJECT_CONFIG_DIR}/Use.cmake.in")
  set (TEMPLATE "${PROJECT_CONFIG_DIR}/Use.cmake.in")
else ()
  set (TEMPLATE "${CMAKE_CURRENT_LIST_DIR}/Use.cmake.in")
endif ()

# ----------------------------------------------------------------------------
# configure project use file

configure_file ("${TEMPLATE}" "${PROJECT_BINARY_DIR}/${USE_FILE}" @ONLY)

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

