##############################################################################
# \file  FindBASIS.cmake
# \brief Find BASIS package or specific components only.
#
# Input variables:
#
#   BASIS_DIR          The BASIS package files are searched under the
#                      specified root directory. If they are not found
#                      there, the default search paths are considered.
#                      This variable can also be set as environment variable.
#
# Sets the following CMake variables:
#
#   BASIS_FOUND        Whether the BASIS package was found and the
#                      following CMake variables are valid.
#   BASIS_INCLUDE_DIR  Cached include directory/ies.
#   BASIS_INCLUDE_DIRS Alias for BASIS_INCLUDE_DIR (not cached).
#   BASIS_INCLUDES     Alias for BASIS_INCLUDE_DIR (not cached).
#   BASIS_LIB          Path of BASIS libraries.
#   BASIS_LIBRARY      Alias for BASIS_LIB (not cached).
#   BASIS_LIBRARIES    Path of BASIS libraries and prerequisite libraries.
#
# Moreover, if BASIS_FIND_COMPONENTS was specified, it sets the above
# variables separately for each component listed, where the component
# name is given in BASIS_FIND_COMPONENTS is used as infix after BASIS_.
# For example, the variable BASIS_Core_FOUND determines whether the
# BASIS Core was found or not.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# CMake policies
# ============================================================================

cmake_policy (SET CMP0017 NEW)

# ============================================================================
# initialize search
# ============================================================================



# ============================================================================
# find paths/files
# ============================================================================

# \todo

# ============================================================================
# reset CMake variables
# ============================================================================



# ============================================================================
# aliases / backwards compatibility
# ============================================================================

if (BASIS_INCLUDE_DIR)
  set (BASIS_INCLUDE_DIRS "${BASIS_INCLUDE_DIR}")
  set (BASIS_INCLUDES     "${BASIS_INCLUDE_DIR}")
endif ()

if (BASIS_LIB)
  set (BASIS_LIBRARY "${BASIS_LIB}")
endif ()

if (BASIS_LIB)
  set (
    BASIS_LIBRARIES
      "${BASIS_LIB}"
  )
endif ()

# ============================================================================
# found ?
# ============================================================================

# handle the QUIETLY and REQUIRED arguments and set *_FOUND to TRUE
# if all listed variables are found or TRUE

include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (
  BASIS
  #MESSAGE
    DEFAULT_MSG
  #VARIABLES
    BASIS_MODULE_PATH
    BASIS_INCLUDE_DIR
    BASIS_LIB
)

