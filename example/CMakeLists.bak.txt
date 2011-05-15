##############################################################################
# \file  CMakeLists.txt
# \brief CMakeLists.txt file to generate example projects.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# constants
# ============================================================================

# the following directories have to match the directories defined in
# ../src/template/CMakeLists.txt
set (EXAMPLE_SRC_DIR "src")

# ============================================================================
# helpers
# ============================================================================

# ****************************************************************************
# \brief Creates an example project from the specified source files.
#
# This helper function is used to instantiate example projects from the
# SRC package's project template during the build of the SRC package itself.
# By creating the example projects during the build of SRC, the examples are
# guaranteed to by in sync with the actual project template. Otherwise, the
# example projects tend to get outdated, respectively, keeping them up-to-date
# has to be done manually every time the template is modified.

function (create_example EXAMPLE)
  sbia_target_uid (CREATESCRIPT createproject)

  CMAKE_PARSE_ARGUMENTS (ARG "" "DESCRIPTION" "" ${ARGN})

  add_custom_target (
    ${EXAMPLE}
    COMMAND "${CREATESCRIPT}" "${EXAMPLE}"
            -t "${PROJECT_MAJOR_VERSION}"
            -d "\"${ARGN_DESCRIPTION}\""
            -r "\"${PROJECT_BINARY_DIR}/example/${EXAMPLE}-src\""
    COMMENT "Creating example project ${EXAMPLE}..."
  )

  add_dependencies (${EXAMPLE} ${CREATESCRIPT})

  add_custom_command (
    TARGET ${EXAMPLE} PRE_BUILD
    COMMAND "${CMAKE_COMMAND}"
            -E remove_directory "${PROJECT_BINARY_DIR}/example/${EXAMPLE}-src"
    COMMENT "Removing directory ${PROJECT_BINARY_DIR}/example/${EXAMPLE}-src"
  )
endfunction ()

# ============================================================================
# examples
# ============================================================================

# ----------------------------------------------------------------------------
# SimpleExample

create_example (
  SimpleExample
  DESCRIPTION
    "This is a simple example project."
  SRC_FILES
    CMakeLists.txt
    greetings.cpp
    greetingsInPython.py
    greetingsInPerl.pl
    greetingsInBASH.sh
)

# ============================================================================
# subdirectories
# ============================================================================

# DO NOT traverse into folders which contain the source files of the
# example projects! The CMakeLists.txt files in these folders will be copied
# to the created example projects in the build and install tree.

