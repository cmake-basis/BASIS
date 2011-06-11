##############################################################################
# \file  CMakeLists.txt
# \brief Build configuration to example projects.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# helpers
# ============================================================================

# ****************************************************************************
# \brief Creates an example project from the specified source files.
#
# This helper function is used to instantiate example projects from the BASIS
# project template during the build of the BASIS package itself.
# By creating the example projects during the build of BASIS, the examples are
# guaranteed to by in sync with the actual project template. Otherwise, the
# example projects tend to get outdated, respectively, keeping them up-to-date
# has to be done manually every time the template is modified.

function (create_example EXAMPLE)
  basis_target_uid (CREATESCRIPT basisproject)

  CMAKE_PARSE_ARGUMENTS (ARG "" "DESCRIPTION" "" ${ARGN})

  # instantiate project template
  add_custom_target (
    ${EXAMPLE}
    COMMAND "${CREATESCRIPT}"
            "${EXAMPLE}"
            -d "\"${ARGN_DESCRIPTION}\""
            -r "\"${PROJECT_BINARY_DIR}/example/${EXAMPLE}-source\""
    COMMENT "Creating example project ${EXAMPLE}..."
  )

  add_dependencies (${EXAMPLE} ${CREATESCRIPT})

  # copy example files
  get_filename_component (SOURCE_DIR "${PROJECT_SOURCE_DIR}" NAME)
  message ("Source directory name: ${SOURCE_DIR}")
  if (EXISTS ${PROJECT_EXAMPLE_DIR}/${EXAMPLE}/${SOURCE_DIR})
  endif ()
endfunction ()

# ============================================================================
# examples
# ============================================================================

# ----------------------------------------------------------------------------
# HelloWorld

create_example (
  HelloWorld
  DESCRIPTION "The typical Hello World example."
)

# ----------------------------------------------------------------------------
# SimpleExample

#create_example (
#  SimpleExample
#  DESCRIPTION
#    "This is a simple example project."
#  SRC_FILES
#    CMakeLists.txt
#    greetings.cpp
#    greetingsInPython.py
#    greetingsInPerl.pl
#    greetingsInBASH.sh
#)

# ============================================================================
# subdirectories
# ============================================================================

# DO NOT traverse into folders which contain the source files of the
# example projects! The CMakeLists.txt files in these folders will be copied
# to the created example projects in the build and install tree.

