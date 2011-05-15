##############################################################################
# \file  BasisDocTools.cmake
# \brief Tools related to gnerating or adding software documentation.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

if (NOT BASIS_DOCTOOLS_INCLUDED)
set (BASIS_DOCTOOLS_INCLUDED 1)


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# options
# ============================================================================

option (BUILD_DOC       "Whether to generate the (API) documentation" "ON")
option (BUILD_CHANGELOG "Whether to generate the ChangeLog (requires SVN working copy and possibly user interaction)" "ON")

if (NOT TARGET doc)
  mark_as_advanced (BUILD_DOC)
endif ()

if (NOT TARGET changelog)
  mark_as_advanced (BUILD_CHANGELOG)
endif ()

# ============================================================================
# used programs
# ============================================================================

# Doxygen - API documentation
find_package (Doxygen)

# svn2cl - ChangeLog
find_program (
  BASIS_CMD_SVN2CL
    NAMES svn2cl
    DOC   "The command line tool svn2cl."
)

mark_as_advanced (BASIS_CMD_SVN2CL)

# ============================================================================
# adding / generating documentation
# ============================================================================

# ****************************************************************************
# \brief Adds documentation target.
#
# This function is especially used to add a custom target to the "doc" target
# which is used to generate documentation from input files such as in
# particular source code files. Other documentation files such as HTML, Word,
# or PDF documents can be added as well using this function. A component
# as part of which this documentation shall be installed can be specified.
#
# The documentation files are installed in/as INSTALL_DOC_DIR/DOC_NAME as part
# of the component specified by the COMPONENT option.
#
# \note If the option BUILD_DOC is not defined or does not evaluate to true,
#       only documentation generated with the NONE generator is build and
#       installed.
#
# Example:
#
# \code
# basis_add_doc (UserManual.pdf)
# basis_add_doc (DeveloperManual.docx COMPONENT dev)
# basis_add_doc (SourceManual.html    COMPONENT src)
# \endcode
#
# \param [in] TARGET_NAME Name of the documentation target or file.
# \param [in] ARGN        Further options which are given as pairs
#                         "OPTION_NAME <OPTION_VALUE>".
#
# Common options:
#
# COMPONENT Name of the component this documentation belongs to.
# GENERATOR Documentation generator, where the case of the generator name is
#           ignored, i.e., "Doxygen", "DOXYGEN", "doxYgen" are all valid
#           arguments which select the DOXYGEN generator. The arguments for the
#           the different supported generators are documented below.
#           The default generator is "NONE". The NONE generator simply installs
#           the document with the filename TARGET_NAME and has no own options.
#
# Generator: DOXYGEN
# 
# Example:
#
# \code
# basis_add_doc (
#   API
#   GENERATOR Doxygen
#     DOXYFILE        "Doxyfile.in"
#     PROJECT_NAME    "${PROJECT_NAME}"
#     PROJECT_VERSION "${PROJECT_VERSION}"
#   COMPONENT dev
# )
# \endcode
#
# Options of DOXYGEN generator:
#
# \see http://www.stack.nl/~dimitri/doxygen/config.html
#
# DOXYFILE         Name of the template Doxyfile.
# PROJECT_NAME     Value for Doxygen's PROJECT_NAME tag which is used
#                  to specify the project name.
#                  Default: "PROJECT_NAME".
# PROJECT_NUMBER   Value for Doxygen's PROJECT_NUMBER tag which is used
#                  to specify the project version number.
#                  Default: PROJECT_VERSION.
# INPUT            Value for Doxygen's INPUT tag which is used to
#                  specify input directories/files.
#                  Default: "PROJECT_SOURCE_DIR/Code;PROJECT_BINARY_DIR/Code".
# FILTER_PATTERNS  Value for Doxygen's FILTER_PATTERNS tag which
#                  can be used to specify filters on a per file
#                  pattern basis.
# EXCLUDE          Value for Doxygen's EXCLUDE tag which can be used
#                  to specify files and/or directories that should 
#                  excluded from the INPUT source files.
#                  Default: ""
# OUTPUT_DIRECTORY Value for Doxygen's OUTPUT_DIRECTORY tag which
#                  can be used to specify the output directory.
#                  Default: "CMAKE_CURRENT_BINARY_DIR/TARGET_NAME".
# GENERATE_HTML    If given, Doxygen's GENERATE_HTML tag is set to "YES", otherwise "NO".
# GENERATE_LATEX   If given, Doxygen's GENERATE_LATEX tag is set to "YES", otherwise "NO".
# GENERATE_RTF     If given, Doxygen's GENERATE_RTF tag is set to "YES", otherwise "NO".
# GENERATE_MAN     If given, Doxygen's GENERATE_MAN tag is set to "YES", otherwise "NO".
#
# Generator: SVN2CL
#
# Example:
#
# \code
# basis_add_doc (
#   ChangeLog
#   GENERATOR svn2cl
#   COMPONENT dev
# )
# \endcode
#

function (basis_add_doc TARGET_NAME)
  basis_check_target_name ("${TARGET_NAME}")
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # --------------------------------------------------------------------------
  # default common options
  # --------------------------------------------------------------------------

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "GENERATOR;COMPONENT" "" ${ARGN})

  if (NOT ARGN_GENERATOR)
    set (ARGN_GENERATOR "NONE")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_DEFAULT_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  # generator name is case insensitive
  string (TOUPPER "${ARGN_GENERATOR}" ARGN_GENERATOR)

  # --------------------------------------------------------------------------
  # generator: NONE
  # --------------------------------------------------------------------------

  if (ARGN_GENERATOR STREQUAL "NONE")

    message (STATUS "Adding documentation ${TARGET_UID}...")

    # install documentation file
    install (
      FILES       "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}"
      DESTINATION "${INSTALL_DOC_DIR}"
      COMPONENT   "${ARGN_COMPONENT}"
    )

    message (STATUS "Adding documentation ${TARGET_UID}... - done")

  # --------------------------------------------------------------------------
  # generator: DOXYGEN
  # --------------------------------------------------------------------------

  elseif (ARGN_GENERATOR STREQUAL "DOXYGEN")

    message (STATUS "Adding documentation ${TARGET_UID}...")

    if (BUILD_DOC)
      set (ERRMSGTYP "")
      set (ERRMSG    "failed")
    else ()
      set (ERRMSGTYP "STATUS")
      set (ERRMSG    "skipped")
    endif ()

    # Doxygen found ?
    if (NOT DOXYGEN_EXECUTABLE)
      message (${ERRMSGTYP} "Doxygen not found. Skipping build of ${TARGET_UID}.")
      message (STATUS "Adding documentation ${TARGET_UID}... - ${ERRMSG}")
      return ()
    endif ()

    # lower target name is used by default for installation folder
    string (TOLOWER "${TARGET_NAME}" TARGET_NAME_LOWER)

    # parse arguments
    CMAKE_PARSE_ARGUMENTS (
      DOXYGEN
        "GENERATE_HTML;GENERATE_LATEX;GENERATE_RTF;GENERATE_MAN"
        "DOXYFILE;PROJECT_NAME;PROJECT_NUMBER;OUTPUT_DIRECTORY"
        "INPUT;FILTER_PATTERNS;EXCLUDE"
        ${ARGN_UNPARSED_ARGUMENTS}
    )
 
    if (NOT DOXYGEN_DOXYFILE)
      message (FATAL_ERROR "basis_add_doc (): Missing option DOXYFILE.")
    endif ()
    if (NOT EXISTS "${DOXYGEN_DOXYFILE}")
      message (FATAL_ERROR "Input Doxyfile ${DOXYGEN_DOXYFILE} not found.")
    endif ()

    if (NOT DOXYGEN_PROJECT_NAME)
      set (DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
    endif ()
    if (NOT DOXYGEN_PROJECT_NUMBER)
      set (DOXYGEN_PROJECT_NUMBER "${PROJECT_NUMBER}")
    endif ()
    if (NOT DOXYGEN_INPUT)
      set (DOXYGEN_INPUT "${PROJECT_SOURCE_DIR}/Code" "${PROJECT_BINARY_DIR}/Code")
    endif ()
    if (NOT DOXYGEN_FILTER_PATTERNS)
      set (DOXYGEN_FILTER_PATTERNS "")
    endif ()
    if (NOT DOXYGEN_EXCLUDE)
      set (DOXYGEN_EXCLUDE "")
    endif ()
    if (NOT DOXYGEN_OUTPUT_DIRECTORY)
      set (DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}")
    endif ()

    set (GENERATE_DEFAULT 1)
    foreach (FMT HTML LATEX RTF MAN)
      set (VAR DOXYGEN_GENERATE_${FMT})
      if (${VAR})
        set (${VAR} "YES")
        set (GENERATE_DEFAULT 0)
      else ()
        set (${VAR} "NO")
      endif ()
    endforeach ()
    if (GENERATE_DEFAULT)
      set (DOXYGEN_GENERATE_HTML "YES")
    endif ()
 
    set (TMP)
    foreach (DIR ${DOXYGEN_INPUT})
      set (TMP "${TMP} \"${DIR}\"")
    endforeach ()
    set (DOXYGEN_INPUT "${TMP}")
    set (TMP)

    # click & jump in Emacs and Visual Studio
    if (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
      set (DOXYGEN_WARN_FORMAT "\"$file($line) : $text \"")
    else ()
      set (DOXYGEN_WARN_FORMAT "\"$file:$line: $text \"")
    endif ()

    # configure Doxyfile
    set (DOXYFILE "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}.doxy")
    configure_file ("${DOXYGEN_DOXYFILE}" "${DOXYFILE}" @ONLY)

    # add target
    add_custom_target (${TARGET_UID} COMMAND "${DOXYGEN_EXECUTABLE}" "${DOXYFILE}")

    # cleanup on "make clean"
    set_property (
      DIRECTORY
      APPEND PROPERTY
        ADDITIONAL_MAKE_CLEAN_FILES
          "${DOXYGEN_OUTPUT_DIRECTORY}/html"
          "${DOXYGEN_OUTPUT_DIRECTORY}/latex"
          "${DOXYGEN_OUTPUT_DIRECTORY}/rtf"
          "${DOXYGEN_OUTPUT_DIRECTORY}/man"
    )

    # add target as dependency to doc target
    if (NOT TARGET doc)
      if (BUILD_DOC)
        add_custom_target (doc ALL)
      else ()
        add_custom_target (doc)
      endif ()
      mark_as_advanced (BUILD_DOC CLEAR)
    endif ()

    add_dependencies (doc ${TARGET_UID})

    # install documentation
    install (
      DIRECTORY       "${DOXYGEN_OUTPUT_DIRECTORY}/"
      DESTINATION     "${INSTALL_DOC_DIR}/${TARGET_NAME_LOWER}"
      COMPONENT       "${ARGN_COMPONENT}"
      FILES_MATCHING
      PATTERN         html/*
      PATTERN         latex/*
      PATTERN         rtf/*
      PATTERN         man/*
      # exclude directories as FILES_MATCHING does not do this
      PATTERN         CMakeFiles EXCLUDE # some CMake files
      PATTERN         .svn       EXCLUDE # for in-source builds
      PATTERN         .git       EXCLUDE # for in-source builds
    )

    message (STATUS "Adding documentation ${TARGET_UID}... - done")

  # --------------------------------------------------------------------------
  # generator: svn2cl
  # --------------------------------------------------------------------------

  elseif (ARGN_GENERATOR STREQUAL "SVN2CL")

    message (STATUS "Adding documentation ${TARGET_UID}...")

    if (BUILD_CHANGELOG)
      set (ERRMSGTYP "")
      set (ERRMSG    "failed")
    else ()
      set (ERRMSGTYP "STATUS")
      set (ERRMSG    "skipped")
    endif ()

    if (NOT BASIS_CMD_SVN2CL)
      message (${ERRMSGTYP} "Could not find svn2cl installation. Skipping build of ${TARGET_UID}.")
      message (STATUS "Adding documentation ${TARGET_UID}... - ${ERRMSG}")
      return ()
    endif ()

    basis_svn_get_revision ("${PROJECT_SOURCE_DIR}" REV)

    if (NOT REV)
      message (${ERRMSGTYP} "Project is not under SVN control. Skipping build of ${TARGET_UID}.")
      message (STATUS "Adding documentation ${TARGET_UID}... - ${ERRMSG}")
      return ()
    endif ()

    # svn2cl command arguments
    set (SVN2CL_PATH             "${PROJECT_SOURCE_DIR}")
    set (SVN2CL_OUTPUT           "${PROJECT_BINARY_DIR}/${TARGET_NAME}")
    set (SVN2CL_AUTHORS          "${PROJECT_SOURCE_DIR}/Authors")
    set (SVN2CL_LINELEN          79)
    set (SVN2CL_REPARAGRAPH      0)
    set (SVN2CL_INCLUDE_ACTIONS  1)
    set (SVN2CL_INCLUDE_REV      1)
    set (SVN2CL_BREAK_BEFORE_MSG 1)
    set (SVN2CL_GROUP_BY_DAY     1)

    set (SVN2CL_ARGS "--output=${SVN2CL_OUTPUT}")
    if (SVN2CL_LINELEN)
      list (APPEND SVN2CL_ARGS "--linelen=${SVN2CL_LINELEN}")
    endif ()
    if (SVN2CL_REPARAGRAPH)
      list (APPEND SVN2CL_ARGS "--reparagraph")
    endif ()
    if (SVN2CL_INCLUDE_ACTIONS)
      list (APPEND SVN2CL_ARGS "--include-actions")
    endif ()
    if (SVN2CL_BREAK_BEFORE_MSG)
      list (APPEND SVN2CL_ARGS "--break-before-msg=${SVN2CL_BREAK_BEFORE_MSG}")
    endif ()
    if (SVN2CL_GROUP_BY_DAY)
      list (APPEND SVN2CL_ARGS "--group-by-day")
    endif ()

    if (EXISTS "${SVN2CL_AUTHORS}")
      list (APPEND SVN2CL_ARGS "--authors=${SVN2CL_AUTHORS}")
    elseif (EXISTS "${SVN2CL_AUTHORS}.xml")
      list (APPEND SVN2CL_ARGS "--authors=${SVN2CL_AUTHORS}.xml")
    elseif (EXISTS "${SVN2CL_AUTHORS}.txt")
      list (APPEND SVN2CL_ARGS "--authors=${SVN2CL_AUTHORS}.txt")
    endif ()

    # add target
    add_custom_target (
      ${TARGET_UID}
      COMMAND           "${BASIS_CMD_SVN2CL}" ${SVN2CL_ARGS} "${SVN2CL_PATH}"
      WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
      COMMENT           "Generating ${TARGET_UID} from SVN log..."
    )

    # cleanup on "make clean"
    set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${SVN2CL_OUTPUT}")

    # add target as dependency to changelog target
    if (NOT TARGET changelog)
      if (BUILD_CHANGELOG)
        add_custom_target (changelog ALL)
      else ()
        add_custom_target (changelog)
      endif ()
      mark_as_advanced (BUILD_CHANGELOG CLEAR)
    endif ()

    add_dependencies (changelog ${TARGET_UID})

    # install documentation
    install (
      FILES       "${SVN2CL_OUTPUT}"
      DESTINATION "${CMAKE_INSTALL_PREFIX}"
      COMPONENT   "${ARGN_COMPONENT}"
      OPTIONAL
    )

    message (STATUS "Adding documentation ${TARGET_UID}... - done")

  # --------------------------------------------------------------------------
  # generator: unknown
  # --------------------------------------------------------------------------

  else ()
    message (FATAL_ERROR "Unknown documentation generator: ${ARGN_GENERATOR}.")
  endif ()
endfunction ()


endif (NOT BASIS_DOCTOOLS_INCLUDED)

