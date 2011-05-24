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
set (BASIS_DOCTOOLS_INCLUDED 1 CACHE INTERNAL "BasisDocTools.cmake" FORCE)


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# options
# ============================================================================

# The following options are only enabled when at least one doc or changelog
# target were added. Otherwise, there is nothing to build.

if (NOT DEFINED BUILD_DOCUMENTATION)
  set (BUILD_DOCUMENTATION)
endif ()

if (NOT DEFINED BUILD_CHANGELOG)
  set (BUILD_CHANGELOG)
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

# Doxygen filters
find_file (
  DOXYGEN_FILTER_BASH
    NAMES bash2cpp.pl
    HINTS "${CMAKE_CURRENT_LIST_DIR}"
    DOC   "Filter used by default by Doxygen to convert shell scripts (bash2cpp.pl)."
    NO_DEFAULT_PATH
)

mark_as_advanced (DOXYGEN_FILTER_BASH)

find_file (
  DOXYGEN_FILTER_MATLAB
    NAMES matlab2cpp.pl
    HINTS "${CMAKE_CURRENT_LIST_DIR}"
    DOC   "Filter used by default by Doxygen to convert MATLAB scripts (matlab2cpp.pl)."
    NO_DEFAULT_PATH
)

mark_as_advanced (DOXYGEN_FILTER_MATLAB)

# ============================================================================
# settings
# ============================================================================

set (DOXYGEN_FILTER_PATTERNS "")

if (DOXYGEN_FILTER_BASH)
  list (APPEND DOXYGEN_FILTER_PATTERNS "*.sh=${DOXYGEN_FILTER_BASH}")
endif ()

if (DOXYGEN_FILTER_MATLAB)
  list (APPEND DOXYGEN_FILTER_PATTERNS "*.m=${DOXYGEN_FILTER_MATLAB}")
endif ()

basis_list_to_string (DOXYGEN_FILTER_PATTERNS ${DOXYGEN_FILTER_PATTERNS})

find_file (
  DOXYGEN_DOXYFILE
    NAMES Doxyfile.in
    HINTS "${CMAKE_CURRENT_LIST_DIR}"
    DOC   "Default doxyfile template used for Doxygen (Doxyfile.in)."
    NO_DEFAULT_PATH
)

mark_as_advanced (DOXYGEN_DOXYFILE)

# ============================================================================
# helper
# ============================================================================

# ****************************************************************************
# \brief Adds a custom 'doc' target along with a build switch.

function (basis_add_doc_target)
  if (NOT TARGET doc)
    if (NOT DEFINED BUILD_DOCUMENTATION)
      set (
        BUILD_DOCUMENTATION "NO"
        CACHE BOOL
          "Whether to generate the (API) documentation."
        FORCE
      )
    endif ()
    if (BUILD_DOCUMENTATION)
      add_custom_target (doc ALL)
    else ()
      add_custom_target (doc)
    endif ()
  endif ()
endfunction ()

# ****************************************************************************
# \brief Adds a custom 'changelog' target along with a build switch.

function (basis_add_changelog_target)
  if (NOT TARGET changelog)
    if (NOT DEFINED BUILD_CHANGELOG)
      set (
        BUILD_CHANGELOG "NO"
        CACHE BOOL
          "Whether to generate the ChangeLog."
        FORCE
      )
    endif ()
    if (BUILD_CHANGELOG)
      add_custom_target (changelog ALL)
    else ()
      add_custom_target (changelog)
    endif ()
  endif ()
endfunction ()

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
#           Defaults to BASIS_LIBRARY_COMPONENT for documentation generated
#           from in-source comments and BASIS_RUNTIME_COMPONENT, otherwise.
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
#                  pattern basis. Defaults to BASIS_DOXYGEN_FILTER_PATTERNS.
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

  # generator name is case insensitive
  string (TOUPPER "${ARGN_GENERATOR}" ARGN_GENERATOR)

  # default component
  if (ARGN_GENERATOR STREQUAL "DOXYGEN")
    if (NOT ARGN_COMPONENT)
      set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
    endif ()
  else ()
    if (NOT ARGN_COMPONENT)
      set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
    endif ()
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  # --------------------------------------------------------------------------
  # generator: NONE
  # --------------------------------------------------------------------------

  if ("${ARGN_GENERATOR}" STREQUAL "NONE")

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

  elseif ("${ARGN_GENERATOR}" STREQUAL "DOXYGEN")

    message (STATUS "Adding documentation ${TARGET_UID}...")

    # Doxygen found ?
    if (BUILD_DOCUMENTATION)
      set (ERRMSGTYP "")
      set (ERRMSG    "failed")
    else ()
      set (ERRMSGTYP "STATUS")
      set (ERRMSG    "skipped")
    endif ()

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
      set (DOXYGEN_DOXYFILE "${BASIS_DOXYGEN_DOXYFILE}")
    endif ()
    if (NOT EXISTS "${DOXYGEN_DOXYFILE}")
      message (FATAL_ERROR "Missing option DOXYGEN_FILE or Doxyfile ${DOXYGEN_DOXYFILE} does not exist.")
    endif ()

    if (NOT DOXYGEN_PROJECT_NAME)
      set (DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
    endif ()
    if (NOT DOXYGEN_PROJECT_NUMBER)
      set (DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION}")
    endif ()
    if (NOT DOXYGEN_INPUT)
      file (RELATIVE_PATH CODE_DIR "${PROJECT_SOURCE_DIR}" "${PROJECT_CODE_DIR}")
      set (DOXYGEN_INPUT "${PROJECT_CODE_DIR}" "${PROJECT_BINARY_DIR}/${CODE_DIR}")
    endif ()
    if (NOT DOXYGEN_FILTER_PATTERNS)
      set (DOXYGEN_FILTER_PATTERNS "${BASIS_DOXYGEN_FILTER_PATTERNS}")
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

    # click & jump in emacs and Visual Studio
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
    basis_add_doc_target ()

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

  elseif ("${ARGN_GENERATOR}" STREQUAL "SVN2CL")

    message (STATUS "Adding documentation ${TARGET_UID}...")

    if (BUILD_CHANGELOG)
      set (ERRMSGTYP "")
      set (ERRMSG    "failed")
    else ()
      set (ERRMSGTYP "STATUS")
      set (ERRMSG    "skipped")
    endif ()

    # svn2cl found?
    if (NOT BASIS_CMD_SVN2CL)
      message (${ERRMSGTYP} "svn2cl not found. Skipping build of ${TARGET_UID}.")
      message (STATUS "Adding documentation ${TARGET_UID}... - ${ERRMSG}")
      return ()
    endif ()

    # source tree is a Subversion working copy?
    basis_svn_get_revision ("${PROJECT_SOURCE_DIR}" REV)

    if (NOT REV)
      message (${ERRMSGTYP} "Project is not under SVN control. Skipping build of ${TARGET_UID}.")
      message (STATUS "Adding documentation ${TARGET_UID}... - ${ERRMSG}")
      return ()
    endif ()

    # svn2cl command arguments
    # \todo parse arguments
    set (SVN2CL_PATH             "${PROJECT_SOURCE_DIR}")
    set (SVN2CL_OUTPUT           "${PROJECT_BINARY_DIR}/${TARGET_NAME}")
    set (SVN2CL_AUTHORS          "${PROJECT_AUTHORS_FILE}")
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
    basis_add_changelog_target ()

    add_dependencies (changelog ${TARGET_UID})

    # install documentation
    install (
      FILES       "${SVN2CL_OUTPUT}"
      DESTINATION "${INSTALL_DOC_DIR}"
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

