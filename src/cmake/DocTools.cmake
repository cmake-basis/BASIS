##############################################################################
# @file  DocTools.cmake
# @brief Tools related to gnerating or adding software documentation.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_DOCTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_DOCTOOLS_INCLUDED TRUE)
endif ()


# get directory of this file
#
# Note: This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# options
# ============================================================================

# The following options are only enabled when at least one doc or changelog
# target were added. Otherwise, there is nothing to build.

## @addtogroup CMakeAPI
#  @{

## @brief Enable/Disable build of documentation target as part of ALL.
#
# This option is only available when the project adds at least one
# documentation target using the function basis_add_doc().
if (NOT DEFINED BUILD_DOCUMENTATION)
  set (BUILD_DOCUMENTATION)
endif ()

## @brief Enable/Disable build of changelog target as part of ALL.
#
# This option is only available when the project adds at least one
# ChangeLog target using the function basis_add_doc().
if (NOT DEFINED BUILD_CHANGELOG)
  set (BUILD_CHANGELOG)
endif ()

## @}

# ============================================================================
# used programs
# ============================================================================

# Doxygen - API documentation
find_package (Doxygen)

## @brief Command svn2cl which is used to generate a ChangeLog from the Subversion log.
find_program (
  BASIS_CMD_SVN2CL
    NAMES svn2cl
    DOC   "The command line tool svn2cl."
)
mark_as_advanced (BASIS_CMD_SVN2CL)

## @brief The Python interpreter.
find_program (
  BASIS_CMD_PYTHON
    NAMES python
    DOC   "The Python interpreter."
)
mark_as_advanced (BASIS_CMD_PYTHON)

## @brief The Perl interpreter.
find_program (
  BASIS_CMD_PERL
    NAMES perl
    DOC   "The Perl interpreter."
)
mark_as_advanced (BASIS_CMD_PERL)

# ============================================================================
# settings
# ============================================================================

## @addtogroup CMakeUtilities
#  @{

## @brief Default Doxygen input filter.
set (BASIS_DOXYGEN_INPUT_FILTER "${BASIS_CMD_PERL} '-I${CMAKE_CURRENT_LIST_DIR}' ${CMAKE_CURRENT_LIST_DIR}/doxygen-filter.pl")

## @brief Doxygen filter used to process Python scripts.
set (BASIS_DOXYGEN_FILTER_PYTHON "${BASIS_CMD_PYTHON} ${CMAKE_CURRENT_LIST_DIR}/doxygen-python-filter.py -f")
## @brief Doxygen filter used to process Perl scripts.
set (BASIS_DOXYGEN_FILTER_PERL "${BASIS_CMD_PERL} '-I${CMAKE_CURRENT_LIST_DIR}' ${CMAKE_CURRENT_LIST_DIR}/doxygen-filter.pl")
## @brief Doxygen filter used to process JavaScript files.
set (BASIS_DOXYGEN_FILTER_JAVASCRIPT "${BASIS_CMD_PERL} '-I${CMAKE_CURRENT_LIST_DIR}' ${CMAKE_CURRENT_LIST_DIR}/doxygen-filter.pl")
## @brief Doxygen filter used to process CMake scripts.
set (BASIS_DOXYGEN_FILTER_CMAKE "${BASIS_CMD_PYTHON} ${CMAKE_CURRENT_LIST_DIR}/doxygen-cmake-filter.py")
## @brief Doxygen filter used to process BASH scripts.
set (BASIS_DOXYGEN_FILTER_BASH "${BASIS_CMD_PYTHON} ${CMAKE_CURRENT_LIST_DIR}/doxygen-bash-filter.py")
## @brief Doxygen filter used to process MATLAB scripts.
set (BASIS_DOXYGEN_FILTER_MATLAB "${BASIS_CMD_PERL} ${CMAKE_CURRENT_LIST_DIR}/doxygen-matlab-filter.pl")

## @brief Default Doxygen filter patterns.
set (
  BASIS_DOXYGEN_FILTER_PATTERNS
    "*.cmake=\\\"${BASIS_DOXYGEN_FILTER_CMAKE}\\\""
    "*.cmake.in=\\\"${BASIS_DOXYGEN_FILTER_CMAKE}\\\""
    "*.ctest=\\\"${BASIS_DOXYGEN_FILTER_CMAKE}\\\""
    "*.ctest.in=\\\"${BASIS_DOXYGEN_FILTER_CMAKE}\\\""
    "CMakeLists.txt=\\\"${BASIS_DOXYGEN_FILTER_CMAKE}\\\""
    "*.sh=\\\"${BASIS_DOXYGEN_FILTER_BASH}\\\""
    "*.sh.in=\\\"${BASIS_DOXYGEN_FILTER_BASH}\\\""
    "*.m=\\\"${BASIS_DOXYGEN_FILTER_MATLAB}\\\""
    "*.m.in=\\\"${BASIS_DOXYGEN_FILTER_MATLAB}\\\""
    "*.py=" # TODO Python filer disabled because it does not work properly
)

## @brief Default Doxygen configuration.
set (BASIS_DOXYGEN_DOXYFILE "${CMAKE_CURRENT_LIST_DIR}/Doxyfile.in")

## @}

# ============================================================================
# helper
# ============================================================================

## @addtogroup CMakeUtilities
#  @{

##############################################################################
# @brief Add a custom @c doc target along with a build switch.
#
# This helper function is used by basis_add_doc() to add the custom @c doc
# target which is optionally build when the @c ALL target is build.
# Therefore, the @c BUILD_DOCUMENTATION option switch is added if this
# variable is not yet defined which is by default off. The user can then
# choose to build the documentation when the @c ALL target is build.
# In any case can the documentation be build by building the @c doc target.
#
# @returns Adds the custom target @c doc and the option @c BUILD_DOCUMENTATION
#          if either of these does not exist yet.

function (basis_add_doc_target)
  if (NOT TARGET doc)
    if (NOT DEFINED BUILD_DOCUMENTATION)
      set (
        BUILD_DOCUMENTATION "NO"
        CACHE BOOL
          "Whether to generate the (API) documentation as part of the ALL target."
        FORCE
      )
      mark_as_advanced (BUILD_DOCUMENTATION)
    endif ()
    if (BUILD_DOCUMENTATION)
      add_custom_target (doc ALL)
    else ()
      add_custom_target (doc)
    endif ()
  endif ()
endfunction ()

##############################################################################
# @brief Add a custom @c changelog target along with a build switch.
#
# This helper function is used by basis_add_doc() to add the custom
# @c changelog target which is optionally build when the @c ALL target is
# build. Therefore, the @c BUILD_CHANGELOG option switch is added if this
# variable is not yet defined which is by default off. The user can then
# choose to build the ChangeLog when the @c ALL target is build.
# In any case can the ChangeLog be build by building the @c changelog target.
#
# @returns Adds the custom target @c changelog and the option
#          @c BUILD_CHANGELOG if either of these does not exist yet.

function (basis_add_changelog_target)
  if (NOT TARGET changelog)
    if (NOT DEFINED BUILD_CHANGELOG)
      set (
        BUILD_CHANGELOG "NO"
        CACHE BOOL
          "Whether to generate the ChangeLog as part of the ALL target."
        FORCE
      )
      mark_as_advanced (BUILD_CHANGELOG)
    endif ()
    if (BUILD_CHANGELOG)
      add_custom_target (changelog ALL)
    else ()
      add_custom_target (changelog)
    endif ()
  endif ()
endfunction ()

## @}

# ============================================================================
# adding / generating documentation
# ============================================================================

##############################################################################
# @brief Add documentation target.
#
# This function is especially used to add a custom target to the "doc" target
# which is used to generate documentation from input files such as in
# particular source code files. Other documentation files such as HTML, Word,
# or PDF documents can be added as well using this function. A component
# as part of which this documentation shall be installed can be specified.
#
# @param [in] TARGET_NAME Name of the documentation target or file.
# @param [in] ARGN        List of arguments. The valid arguments are:
# @par
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">@b COMPONENT name</td>
#     <td>Name of the component this documentation belongs to.
#         Defaults to @c BASIS_LIBRARY_COMPONENT for documentation generated
#         from in-source comments and @c BASIS_RUNTIME_COMPONENT, otherwise.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">@b GENERATOR generator</td>
#     <td>Documentation generator, where the case of the generator name is
#         ignored, i.e., @c Doxygen, @c DOXYGEN, @c doxYgen are all valid
#         arguments which select the @c Doxygen generator. The parameters for the
#         different supported generators are documented below.
#         The default generator is @c None. The @c None generator simply installs
#         the document with the filename @c TARGET_NAME and has no own options.</td>
#   </tr>
# </table>
#
# @par Generator: None
# @n
# The documentation files are installed in/as <tt>INSTALL_DOC_DIR/TARGET_NAME</tt>
# as part of the component specified by the @c COMPONENT option.
# @n@n
# Example:
# @code
# basis_add_doc (UserManual.pdf)
# basis_add_doc (DeveloperManual.docx COMPONENT dev)
# basis_add_doc (SourceManual.html    COMPONENT src)
# @endcode
#
# @par Generator: Doxygen
# @n
# Uses the <a href="http://www.stack.nl/~dimitri/doxygen/index.html">Doxygen</a> tool
# to generate the documentation from in-source code comments.
# @n@n
# <table border="0">
#   <tr>
#     @tp @b DOXYFILE file @endtp
#     <td>Name of the template Doxyfile.</td>
#   </tr>
#   <tr>
#     @tp @b PROJECT_NAME name @endtp
#     <td>Value for Doxygen's @c PROJECT_NAME tag which is used to
#         specify the project name.@n
#         Default: @c PROJECT_NAME.</td>
#   </tr>
#   <tr>
#     @tp @b PROJECT_NUMBER version @endtp
#     <td>Value for Doxygen's @c PROJECT_NUMBER tag which is used
#         to specify the project version number.@n
#         Default: @c PROJECT_VERSION.</td>
#   </tr>
#   <tr>
#     @tp @b INPUT path1 [path2 ...] @endtp
#     <td>Value for Doxygen's @c INPUT tag which is used to specify input
#         directories/files.@n
#         Default: @c PROJECT_CODE_DIR    @c BINARY_CODE_DIR
#                  @c PROJECT_INCLUDE_DIR @c BINARY_INCLUDE_DIR.</td>
#   </tr>
#   <tr>
#     @tp @b INPUT_FILTER @endtp
#     <td>
#       Value for Doxygen's @c INPUT_FILTER tag which can be used to
#       specify a default filter for all input files. Set to either one of
#       @c None, @c NONE, or @c none to use no input filter.@n
#       Default: @c BASIS_DOXYGEN_INPUT_FILTER.
#     </td>
#   <tr>
#     @tp @b FILTER_PATTERNS pattern1 [pattern2 ...]</td> @endtp
#     <td>Value for Doxygen's @c FILTER_PATTERNS tag which can be used to
#         specify filters on a per file pattern basis.@n
#         Default: @c BASIS_DOXYGEN_FILTER_PATTERNS.</td>
#   </tr>
#   <tr>
#     @tp @b EXCLUDE_PATTERNS pattern1 [pattern2 ...] @endtp
#     <td>Additional patterns used for Doxygen's @c EXCLUDE_PATTERNS tag
#         which can be used to specify files and/or directories that
#         should be excluded from the INPUT source files.@n
#         Default: No exclude patterns.</td>
#   </tr>
#   <tr>
#     @tp @b OUTPUT_DIRECTORY dir @endtp
#     <td>Value for Doxygen's @c OUTPUT_DIRECTORY tag which can be used to
#         specify the output directory.@n
#         Default: <tt>CMAKE_CURRENT_BINARY_DIR/TARGET_NAME</tt>.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATE_HTML @endtp
#     <td>If given, Doxygen's @c GENERATE_HTML tag is set to YES, otherwise NO.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATE_LATEX @endtp
#     <td>If given, Doxygen's @c GENERATE_LATEX tag is set to YES, otherwise NO.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATE_RTF @endtp
#     <td>If given, Doxygen's @c GENERATE_RTF tag is set to YES, otherwise NO.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATE_MAN @endtp
#     <td>If given, Doxygen's @c GENERATE_MAN tag is set to YES, otherwise NO.</td>
#   </tr>
# </table>
# @n
# See <a href="http://www.stack.nl/~dimitri/doxygen/config.html">here</a> for a
# documentation of the Doxygen tags.
# @n@n
# Example:
# @code
# basis_add_doc (
#   API
#   GENERATOR Doxygen
#     DOXYFILE        "Doxyfile.in"
#     PROJECT_NAME    "${PROJECT_NAME}"
#     PROJECT_VERSION "${PROJECT_VERSION}"
#   COMPONENT dev
# )
# @endcode
#
# @par Generator: svn2cl
# @n
# Uses the <a href="http://arthurdejong.org/svn2cl/"><tt>svn2cl</tt></a> command-line
# tool to generate a ChangeLog from the Subversion log. Herefore, the project
# source tree must be a Subversion working copy and access to the Subversion
# repository is required. Note that generating the ChangeLog from the Subversion
# log is timely expensive and may require user interaction in order to provide
# the credentials to the Subversion repository.
# @n@n
# Example:
# @code
# basis_add_doc (
#   ChangeLog
#   GENERATOR svn2cl
#   COMPONENT dev
# )
# @endcode
#
# @returns Adds a custom target @p TARGET_NAME for the generation of the
#          documentation or configures the given file in case of the @c None
#          generator.
#
# @ingroup CMakeAPI

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

    # install documentation directory
    if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}")
      install (
        DIRECTORY   "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}"
        DESTINATION "${INSTALL_DOC_DIR}"
        COMPONENT   "${ARGN_COMPONENT}"
        PATTERN     ".svn" EXCLUDE
        PATTERN     ".git" EXCLUDE
        PATTERN     "*~"   EXCLUDE
      )
    # install documentation file
    else ()
      install (
        FILES       "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}"
        DESTINATION "${INSTALL_DOC_DIR}"
        COMPONENT   "${ARGN_COMPONENT}"
      )
    endif ()

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
        "INPUT;INPUT_FILTER;FILTER_PATTERNS;EXCLUDE_PATTERNS"
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
      set (
        DOXYGEN_INPUT
          "${BINARY_INCLUDE_DIR}"
          "${BINARY_CODE_DIR}"
          "${PROJECT_INCLUDE_DIR}"
          "${PROJECT_CODE_DIR}"
      )
    endif ()
    basis_list_to_delimited_string (DOXYGEN_INPUT " " ${DOXYGEN_INPUT})
    if (NOT DOXYGEN_INPUT_FILTER)
      set (DOXYGEN_INPUT_FILTER "${BASIS_DOXYGEN_INPUT_FILTER}")
    endif ()
    if (DOXYGEN_INPUT_FILTER MATCHES "^(None|NONE|none)$")
      set (DOXYGEN_INPUT_FILTER)
    endif ()
    if (NOT DOXYGEN_FILTER_PATTERNS)
      set (DOXYGEN_FILTER_PATTERNS "${BASIS_DOXYGEN_FILTER_PATTERNS}")
    endif ()
    basis_list_to_delimited_string (DOXYGEN_FILTER_PATTERNS " " ${DOXYGEN_FILTER_PATTERNS})
    if (NOT DOXYGEN_EXCLUDE_PATTERNS)
      set (DOXYGEN_EXCLUDE_PATTERNS "")
    endif ()
    basis_list_to_delimited_string (DOXYGEN_EXCLUDE_PATTERNS " " ${DOXYGEN_EXCLUDE_PATTERNS})
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
    add_custom_target (
      ${TARGET_UID}
      COMMAND "${DOXYGEN_EXECUTABLE}" "${DOXYFILE}"
      WORKING_DIRECTORY "${BASIS_MODULE_DIR}"
    )

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
    # TODO parse arguments
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

