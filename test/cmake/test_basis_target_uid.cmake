##############################################################################
# @file  test_basis_target_uid.cmake
# @brief Test basis_target_uid() and related functions.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# check arguments
if (NOT OUTPUT_DIR)
  message (FATAL_ERROR "OUTPUT_DIR not specified!")
endif ()

# ----------------------------------------------------------------------------
# include modules
include ("${MODULE_PATH}/CommonTools.cmake")

# ----------------------------------------------------------------------------
# set settings used by testee
set (CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "")
set (CMAKE_BUILD_TYPE "" CACHE STRING "")
set (CMAKE_C_FLAGS "" CACHE STRING "")
set (CMAKE_CXX_FLAGS "" CACHE STRING "")
foreach (C DEBUG RELEASE MINSIZEREL RELWITHDEBINFO)
  set (CMAKE_C_FLAGS_${C} "" CACHE STRING "")
  set (CMAKE_CXX_FLAGS_${C} "" CACHE STRING "")
  set (CMAKE_EXE_LINKER_FLAGS_${C} "" CACHE STRING "")
  set (CMAKE_MODULE_LINKER_FLAGS_${C} "" CACHE STRING "")
  set (CMAKE_SHARED_LINKER_FLAGS_${C} "" CACHE STRING "")
endforeach ()

set (BASIS_NO_SYSTEM_CHECKS TRUE)

include ("${MODULE_PATH}/BasisSettings.cmake")

set (PROJECT_NAME "test")
set (PROJECT_NAME_INFIX "${PROJECT_NAME}")
set (PROJECT_SOURCE_DIR "${OUTPUT_DIR}/test_basis_target_uid")
set (PROJECT_BINARY_DIR "${OUTPUT_DIR}/test_basis_target_uid-build")
set (CMAKE_SOURCE_DIR "${PROJECT_SOURCE_DIR}")
set (CMAKE_BINARY_DIR "${PROJECT_BINARY_DIR}")

basis_initialize_settings ()

# ----------------------------------------------------------------------------
# constants
set (SP "${BASIS_NAMESPACE_SEPARATOR}")

# ----------------------------------------------------------------------------
# simple tests
basis_target_uid (UID "target")
if (NOT "${UID}" STREQUAL "target")
  message (FATAL_ERROR "Expected 'target' got '${UID}'.")
endif ()
set (PROJECT_IS_MODULE TRUE)
basis_target_uid (UID "target")
if (NOT "${UID}" STREQUAL "test${SP}target")
  message (FATAL_ERROR "Expected 'test${SP}target' got '${UID}'.")
endif ()

# ----------------------------------------------------------------------------
# target name -> target UID -> target name
set (PROJECT_IS_MODULE FALSE)
basis_target_uid (UID "target")
basis_target_name (NAME "${UID}")
if (NOT "${NAME}" STREQUAL "target")
  message (FATAL_ERROR "Expected 'target' got '${NAME}'.")
endif ()

basis_target_uid (UID "module${SP}target")
basis_target_name (NAME "${UID}")
if (NOT "${NAME}" STREQUAL "module${SP}target")
  message (FATAL_ERROR "Expected 'module${SP}target' got '${NAME}'.")
endif ()
if (NOT NAME STREQUAL UID)
  message (FATAL_ERROR "Expected UID ('${UID}') to be equal to name ('${NAME}').")
endif ()

set (PROJECT_IS_MODULE TRUE)
basis_target_uid (UID "target")
if (NOT "${UID}" STREQUAL "test${SP}target")
  message (FATAL_ERROR "Expected 'test${SP}target' got '${UID}'.")
endif ()
basis_target_name (NAME "${UID}")
if (NOT "${NAME}" STREQUAL "target")
  message (FATAL_ERROR "Expected 'target' got '${NAME}'.")
endif ()

# ----------------------------------------------------------------------------
# target UID -> target name -> target UID
set (PROJECT_IS_MODULE FALSE)
basis_target_name (NAME "test${SP}target")
if (NOT "${NAME}" STREQUAL "target")
  message (FATAL_ERROR "Expected 'target' got '${NAME}'.")
endif ()
basis_target_uid (UID "${NAME}")
if (NOT "${UID}" STREQUAL "target")
  message (FATAL_ERROR "Expected 'target' got '${UID}'.")
endif ()

basis_target_name (NAME "module${SP}target")
if (NOT "${NAME}" STREQUAL "module${SP}target")
  message (FATAL_ERROR "Expected 'module${SP}target' got '${NAME}'.")
endif ()
basis_target_uid (UID "${NAME}")
if (NOT "${UID}" STREQUAL "module${SP}target")
  message (FATAL_ERROR "Expected 'test${SP}module${SP}target' got '${UID}'.")
endif ()

set (PROJECT_IS_MODULE TRUE)
basis_target_name (NAME "test${SP}target")
basis_target_uid (UID "${NAME}")
if (NOT "${UID}" STREQUAL "test${SP}target")
  message (FATAL_ERROR "Expected 'test${SP}target' got '${UID}'.")
endif ()
