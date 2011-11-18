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

# ============================================================================
# settings
# ============================================================================

## @addtogroup CMakeUtilities
#  @{

## @brief Default Doxygen configuration.
set (BASIS_DOXYGEN_DOXYFILE "${CMAKE_CURRENT_LIST_DIR}/Doxyfile.in")

## @}

# ============================================================================
# helper
# ============================================================================

## @addtogroup CMakeUtilities
#  @{

##############################################################################
# @brief Get default Doxygen filter patterns.
#
# @param [out] FILTER_PATTERNS List of default Doxygen filter patterns.

function (basis_default_doxygen_filters FILTER_PATTERNS)
  set (PATTERNS)

  macro (register_filter FILTER)
    basis_target_uid (TARGET_UID "${FILTER}")
    if (TARGET "${TARGET_UID}")
      basis_get_target_location (FILTER_PATH "${TARGET_UID}" ABSOLUTE)
      foreach (ARG ${ARGN})
        list (APPEND PATTERNS "${ARG}=${FILTER_PATH}")
      endforeach ()
    endif ()
  endmacro ()

  register_filter (
    basis${BASIS_NAMESPACE_SEPARATOR}doxyfilter-cmake
      "CMakeLists.txt"
      "*.cmake"
      "*.cmake.in"
      "*.ctest"
      "*.ctest.in"
  )

  register_filter (
    basis${BASIS_NAMESPACE_SEPARATOR}doxyfilter-bash
      "*.sh"
      "*.sh.in"
  )

  register_filter (
    basis${BASIS_NAMESPACE_SEPARATOR}doxyfilter-matlab
      "*.m"
      "*.m.in"
  )

  # TODO Python filer disabled because it does not work properly
#  register_filter (
#    basis${BASIS_NAMESPACE_SEPARATOR}doxyfilter-python
#      "*.py"
#      "*.py.in"
#  )

  # return
  set ("${FILTER_PATTERNS}" "${PATTERNS}" PARENT_SCOPE)
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
#     @tp @b COMPONENT @endtp
#     <td>Name of the component this documentation belongs to.
#         Defaults to @c BASIS_LIBRARY_COMPONENT for documentation generated
#         from in-source comments and @c BASIS_RUNTIME_COMPONENT, otherwise.</td>
#   </tr>
#   <tr>
#     @tp @b GENERATOR generator @endtp
#     <td>Documentation generator, where the case of the generator name is
#         ignored, i.e., @c Doxygen, @c DOXYGEN, @c doxYgen are all valid
#         arguments which select the @c Doxygen generator. The parameters for the
#         different supported generators are documented below.
#         The default generator is @c None. The @c None generator simply installs
#         the document with the filename @c TARGET_NAME and has no own options.</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory prefix. Defaults to @c INSTALL_DOC_DIR or
#         <tt>INSTALL_DOC_DIR/&lt;target&gt;</tt> in case of the Doxygen generator,
#         where <tt>&lt;target&gt;</tt> is the @c TARGET_NAME in lowercase only.</td>
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
#         specify the output directory. The output files are written to
#         subdirectories named "html", "latex", "rtf", and "man".@n
#         Default: <tt>CMAKE_CURRENT_BINARY_DIR/TARGET_NAME</tt>.</td>
#   </tr>
#   <tr>
#     @tp @b COLS_IN_ALPHA_INDEX @endtp
#     <td>Number of columns in alphabetical index if @p GENERATE_HTML is @c YES.
#         Default: 3.</td>
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
# <table border="0">
#   <tr>
#     @tp @b AUTHORS authors @endtp
#     <td>Authors file for svn2cl which maps SVN user names to real names.
#         On each line, this files must have an entry such as
#         <tt>schuha@UPHS.PENNHEALTH.PRV:Andreas Schuh</tt>.
#         Default: @c BASIS_SVN_USERS_FILE, which is part of BASIS and lists all
#         SVN users at SBIA.</td>
#   </tr>
#   <tr>
#     @tp @b BREAK_BEFORE_MSG num @endtp
#     <td>.</td>
#   </tr>
#   <tr>
#     @tp @b GROUP_BY_DAY @endtp
#     <td>Group changelog entries by day.</td>
#   </tr>
#   <tr>
#     @tp @b INCLUDE_ACTIONS @endtp
#     <td>Add [ADD], [DEL], and [CPY] tags to files.</td>
#   </tr>
#   <tr>
#     @tp @b INCLUDE_REV @endtp
#     <td>Include revision numbers.</td>
#   </tr>
#   <tr>
#     @tp @b LINELEN num @endtp
#     <td>.</td>
#   </tr>
#   <tr>
#     @tp @b OUTPUT_NAME filename @endtp
#     <td>.</td>
#   </tr>
#   <tr>
#     @tp @b PATH dir @endtp
#     <td>Input directory path for <tt>svn log</tt>.</td>
#   </tr>
#   <tr>
#     @tp @b REPARAGRAPH @endtp
#     <td>Rewrap lines inside a paragraph.</td>
#   </tr>
#   <tr>
#     @tp @b SEPARATE_DAYLOGS @endtp
#     <td>Put a blank line between grouped by day entries.</td>
#   </tr>
#   <tr>
#     @tp @b SVN_ARGS @endtp
#     <td>Additional arguments for <tt>svn log</tt>.
#         See <tt>svn2cl --help</tt> for a list of arguments that can be
#         passed on to <tt>svn log</tt>.</td>
#   </tr>
# </table>
# @n
# See also <tt>svn2cl --help</tt> for a documentation of these options.
# @n@n
# Example:
# @code
# basis_add_doc (
#   ChangeLog
#   GENERATOR svn2cl
#   LINELEN   80
#   REPARAGRAPH
#   AUTHORS   svnusers.txt
#   GROUP_BY_DAY
#   BREAK_BEFORE_MSG 1
#   INCLUDE_ACTIONS
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
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "GENERATOR;COMPONENT;DESTINATION" "" ${ARGN})

  # default generator
  if (NOT ARGN_GENERATOR)
    set (ARGN_GENERATOR "NONE")
  else ()
    # generator name is case insensitive
    string (TOUPPER "${ARGN_GENERATOR}" ARGN_GENERATOR)
  endif ()

  # check target name
  if (NOT "${ARGN_GENERATOR}" STREQUAL "NONE")
    basis_check_target_name ("${TARGET_NAME}")
    basis_target_uid (TARGET_UID "${TARGET_NAME}")
  endif ()

  # lower target name is used, for example, for default DESTINATION
  string (TOLOWER "${TARGET_NAME}" TARGET_NAME_LOWER)

  # default destination
  if (NOT ARGN_DESTINATION)
    if ("${ARGN_GENERATOR}" STREQUAL "DOXYGEN")
      if (NOT INSTALL_APIDOC_DIR)
        basis_get_relative_path (APIDOC_DIR "${INSTALL_PREFIX}" "${INSTALL_DOC_DIR}/${TARGET_NAME_LOWER}")
        set (
          INSTALL_APIDOC_DIR "${APIDOC_DIR}"
          CACHE PATH
            "Installation directory of API documentation."
        )
        mark_as_advanced (INSTALL_APIDOC_DIR)
      endif ()
      set (ARGN_DESTINATION "${INSTALL_APIDOC_DIR}")
    else ()
      set (ARGN_DESTINATION "${INSTALL_DOC_DIR}")
    endif ()
  endif ()

  # default component
  if ("${ARGN_GENERATOR}" STREQUAL "DOXYGEN")
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

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_NAME}...")
    endif ()

    # install documentation directory
    if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}")
      install (
        DIRECTORY   "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}"
        DESTINATION "${ARGN_DESTINATION}"
        COMPONENT   "${ARGN_COMPONENT}"
        PATTERN     ".svn" EXCLUDE
        PATTERN     ".git" EXCLUDE
        PATTERN     "*~"   EXCLUDE
      )
    # install documentation file
    else ()
      install (
        FILES       "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}"
        DESTINATION "${ARGN_DESTINATION}"
        COMPONENT   "${ARGN_COMPONENT}"
      )
    endif ()

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_NAME}... - done")
    endif ()

  # --------------------------------------------------------------------------
  # generator: DOXYGEN
  # --------------------------------------------------------------------------

  elseif ("${ARGN_GENERATOR}" STREQUAL "DOXYGEN")

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_UID}...")
    endif ()

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
      if (BASIS_VERBOSE)
        message (STATUS "Adding documentation ${TARGET_UID}... - ${ERRMSG}")
      endif ()
      return ()
    endif ()

    # parse arguments
    CMAKE_PARSE_ARGUMENTS (
      DOXYGEN
        "GENERATE_HTML;GENERATE_LATEX;GENERATE_RTF;GENERATE_MAN"
        "DOXYFILE;TAGFILE;PROJECT_NAME;PROJECT_NUMBER;OUTPUT_DIRECTORY;COLS_IN_ALPHA_INDEX"
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
      if (PROJECT_VERSION_MAJOR GREATER 0 OR PROJECT_VERSION_MINOR GREATER 0)
        set (DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
      else ()
        set (DOXYGEN_PROJECT_NUMBER "")
      endif ()
    endif ()
    # input directories and files
    if (EXISTS "${BINARY_INCLUDE_DIR}")
      list (APPEND DOXYGEN_INPUT "${BINARY_INCLUDE_DIR}")
    endif ()
    if (EXISTS "${BINARY_CODE_DIR}")
      list (APPEND DOXYGEN_INPUT "${BINARY_CODE_DIR}")
    endif ()
    if (EXISTS "${PROJECT_CODE_DIR}")
      list (APPEND DOXYGEN_INPUT "${PROJECT_CODE_DIR}")
    endif ()
    basis_get_relative_path (INCLUDE_DIR "${PROJECT_SOURCE_DIR}" "${PROJECT_INCLUDE_DIR}")
    basis_get_relative_path (CODE_DIR    "${PROJECT_SOURCE_DIR}" "${PROJECT_CODE_DIR}")
    foreach (M IN LISTS PROJECT_MODULES_ENABLED)
      if (EXISTS "${PROJECT_MODULES_DIR}/${M}/${CODE_DIR}")
        list (APPEND DOXYGEN_INPUT "${PROJECT_MODULES_DIR}/${M}/${CODE_DIR}")
      endif ()
      if (EXISTS "${PROJECT_MODULES_DIR}/${M}/${INCLUDE_DIR}")
        list (APPEND DOXYGEN_INPUT "${BINARY_MODULES_DIR}/${M}/${INCLUDE_DIR}")
      endif ()
    endforeach ()
    foreach (L IN ITEMS Cxx Java Python Perl Bash Matlab)
      string (TOUPPER "${L}" U)
      if ("${L}" STREQUAL "Cxx")
        # note that the C++ utilities are always configured and available
        # even if not used, resp., no binary links to them
        set (PROJECT_USES_CXX_UTILITIES TRUE)
      else ()
        basis_get_project_property (PROJECT_USES_${U}_UTILITIES)
      endif ()
      if (PROJECT_USES_${U}_UTILITIES)
        list (FIND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/Utilities.dox" IDX)
        if (IDX EQUAL -1)
          list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/Utilities.dox")
        endif ()
        list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/${L}Utilities.dox")
      endif ()
    endforeach ()
    file (GLOB_RECURSE DOX_FILES "${PROJECT_DOC_DIR}/*.dox")
    list (APPEND DOXYGEN_INPUT ${DOX_FILES})
    basis_list_to_delimited_string (
      DOXYGEN_INPUT "\nINPUT                 += " ${DOXYGEN_INPUT}
    )
    # input filters
    if (NOT DOXYGEN_INPUT_FILTER)
      basis_target_uid (DOXYFILTER "basis${BASIS_NAMESPACE_SEPARATOR}doxyfilter")
      if (TARGET "${DOXYFILTER}")
        basis_get_target_location (DOXYGEN_INPUT_FILTER "${DOXYFILTER}" ABSOLUTE)
      endif ()
    endif ()
    if (DOXYGEN_INPUT_FILTER MATCHES "^(None|NONE|none)$")
      set (DOXYGEN_INPUT_FILTER)
    endif ()
    if (NOT DOXYGEN_FILTER_PATTERNS)
      basis_default_doxygen_filters (DOXYGEN_FILTER_PATTERNS)
    endif ()
    basis_list_to_delimited_string (
      DOXYGEN_FILTER_PATTERNS "\nFILTER_PATTERNS       +=" ${DOXYGEN_FILTER_PATTERNS}
    )
    # exclude patterns
    if (NOT DOXYGEN_EXCLUDE_PATTERNS)
      set (DOXYGEN_EXCLUDE_PATTERNS "")
    endif ()
    basis_list_to_delimited_string (
      DOXYGEN_EXCLUDE_PATTERNS "\nEXCLUDE_PATTERNS     += " ${DOXYGEN_EXCLUDE_PATTERNS}
    )
    # outputs
    if (NOT DOXYGEN_OUTPUT_DIRECTORY)
      set (DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME_LOWER}")
    endif ()
    if (DOXYGEN_TAGFILE MATCHES "^(None|NONE|none)$")
      set (DOXYGEN_TAGFILE)
    else ()
      set (DOXYGEN_TAGFILE "${DOXYGEN_OUTPUT_DIRECTORY}/doxygen.tags")
    endif ()
    set (NUMBER_OF_OUTPUTS 0)
    foreach (FMT HTML LATEX RTF MAN)
      set (VAR DOXYGEN_GENERATE_${FMT})
      if (${VAR})
        set (${VAR} "YES")
        math (EXPR NUMBER_OF_OUTPUTS "${NUMBER_OF_OUTPUTS} + 1")
      else ()
        set (${VAR} "NO")
      endif ()
    endforeach ()
    if (NUMBER_OF_OUTPUTS EQUAL 0)
      set (DOXYGEN_GENERATE_HTML "YES")
      set (NUMBER_OF_OUTPUTS 1)
    endif ()
    # other settings
    if (NOT DOXYGEN_COLS_IN_ALPHA_INDEX OR DOXYGEN_COLS_IN_ALPHA_INDEX MATCHES "[^0-9]")
      set (DOXYGEN_COLS_IN_ALPHA_INDEX 3)
    endif ()

    # set output paths relative to DOXYGEN_OUTPUT_DIRECTORY
    set (DOXYGEN_HTML_OUTPUT  "html")
    set (DOXYGEN_LATEX_OUTPUT "latex")
    set (DOXYGEN_RTF_OUTPUT   "rtf")
    set (DOXYGEN_MAN_OUTPUT   "man")

    # click & jump in emacs and Visual Studio
    if (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
      set (DOXYGEN_WARN_FORMAT "\"$file($line) : $text \"")
    else ()
      set (DOXYGEN_WARN_FORMAT "\"$file:$line: $text \"")
    endif ()

    # configure Doxyfile
    set (DOXYFILE "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME_LOWER}.doxy")
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

    # clean up / install tags file
    if (DOXYGEN_TAGFILE)
      set_property (
        DIRECTORY
        APPEND PROPERTY
          ADDITIONAL_MAKE_CLEAN_FILES
            "${DOXYGEN_TAGFILE}"
      )
    endif ()

    # add target as dependency to doc target
    if (NOT TARGET doc)
      add_custom_target (doc)
    endif ()

    add_dependencies (doc ${TARGET_UID})
    if (TARGET headers)
      add_dependencies (${TARGET_UID} headers)
    endif ()
    if (TARGET scripts)
      add_dependencies (${TARGET_UID} scripts)
    endif ()

    # install documentation
    install (
      CODE
        "
        set (INSTALL_PREFIX \"${ARGN_DESTINATION}\")
        if (NOT IS_ABSOLUTE \"\${INSTALL_PREFIX}\")
          set (INSTALL_PREFIX \"${INSTALL_PREFIX}/\${INSTALL_PREFIX}\")
        endif ()

        macro (install_doxydoc DIR)
          if (IS_DIRECTORY \"${DOXYGEN_OUTPUT_DIRECTORY}/\${DIR}\")
            execute_process (
              COMMAND \"${CMAKE_COMMAND}\" -E copy_directory
                  \"${DOXYGEN_OUTPUT_DIRECTORY}/\${DIR}\"
                  \"\${INSTALL_PREFIX}/\${DIR}\"
              RESULT_VARIABLE RC
            )
            if (RC EQUAL 0)
              message (STATUS \"Installing: \${INSTALL_PREFIX}/\${DIR}\")
            else ()
              message (STATUS \"Skipped: \${INSTALL_PREFIX}/\${DIR}\")
            endif ()

            list (APPEND CMAKE_INSTALL_MANIFEST_FILES \"\${INSTALL_PREFIX}/\${DIR}\")
          endif ()
        endmacro ()

        install_doxydoc (html)
        install_doxydoc (latex)
        install_doxydoc (rtf)
        install_doxydoc (man)

        if (EXISTS \"${DOXYGEN_TAGFILE}\")
          get_filename_component (DOXYGEN_TAGFILE_NAME \"${DOXYGEN_TAGFILE}\" NAME)
          execute_process (
            COMMAND \"${CMAKE_COMMAND}\" -E copy
              \"${DOXYGEN_TAGFILE}\"
              \"\${INSTALL_PREFIX}/\${DOXYGEN_TAGFILE_NAME}\"
          )
          list (APPEND CMAKE_INSTALL_MANIFEST_FILES \"\${INSTALL_PREFIX}/\${DOXYGEN_TAGFILE_NAME}\")
        endif ()
        "
    )

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_UID}... - done")
    endif ()

  # --------------------------------------------------------------------------
  # generator: svn2cl
  # --------------------------------------------------------------------------

  elseif ("${ARGN_GENERATOR}" STREQUAL "SVN2CL")

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_UID}...")
    endif ()

    # svn2cl found?
    if (NOT BASIS_CMD_SVN2CL)
      message (STATUS "svn2cl not found. Skipping build of ${TARGET_UID}.")
      if (BASIS_VERBOSE)
        message (STATUS "Adding documentation ${TARGET_UID}... - skipped")
      endif ()
      return ()
    endif ()

    # source tree is a Subversion working copy?
    basis_svn_get_revision ("${PROJECT_SOURCE_DIR}" REV)

    if (NOT REV)
      message (STATUS "Project is not under SVN control. Skipping build of ${TARGET_UID}.")
      if (BASIS_VERBOSE)
        message (STATUS "Adding documentation ${TARGET_UID}... - skipped")
      endif ()
      return ()
    endif ()

    # parse arguments
    CMAKE_PARSE_ARGUMENTS (
      SVN2CL
        "INCLUDE_ACTIONS;INCLUDE_REV;REPARAGRAPH;GROUP_BY_DAY;SEPARATE_DAYLOGS"
        "AUTHORS;BREAK_BEFORE_MSG;LINELEN;OUTPUT_NAME;PATH"
        "SVN_ARGS"
        ${ARGN_UNPARSED_ARGUMENTS}
    )

    if (SVN2CL_OUTPUT_NAME)
      set (SVN2CL_OUTPUT "${PROJECT_BINARY_DIR}/${SVN2CL_OUTPUT_NAME}")
    else ()
      set (SVN2CL_OUTPUT "${PROJECT_BINARY_DIR}/${TARGET_NAME}")
    endif ()

    if (NOT SVN2CL_PATH)
      set (SVN2CL_PATH "${PROJECT_SOURCE_DIR}")
    endif ()
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
    if (SVN2CL_INCLUDE_REV)
      list (APPEND SVN2CL_ARGS "--include-rev")
    endif ()
    if (SVN2CL_BREAK_BEFORE_MSG)
      list (APPEND SVN2CL_ARGS "--break-before-msg=${SVN2CL_BREAK_BEFORE_MSG}")
    endif ()
    if (SVN2CL_GROUP_BY_DAY)
      list (APPEND SVN2CL_ARGS "--group-by-day")
    endif ()
    if (SVN2CL_SEPARATE_DAY_LOGS)
      list (APPEND SVN2CL_ARGS "--separate-daylogs")
    endif ()
    if (SVN2CL_AUTHORS)
      list (APPEND SVN2CL_ARGS "--authors=${SVN2CL_AUTHORS}")
    elseif (EXISTS "${BASIS_SVN_USERS_FILE}")
      list (APPEND SVN2CL_ARGS "--authors=${BASIS_SVN_USERS_FILE}")
    endif ()
    if (SVN2CL_SVN_ARGS)
      list (APPEND SVN2CL_ARGS ${SVN2CL_SVN_ARGS})
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
      add_custom_target(changelog)
    endif ()

    add_dependencies (changelog ${TARGET_UID})

    # install documentation
    install (
      FILES       "${SVN2CL_OUTPUT}"
      DESTINATION "${ARGN_DESTINATION}"
      COMPONENT   "${ARGN_COMPONENT}"
      OPTIONAL
    )

    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_UID}... - done")
    endif ()

  # --------------------------------------------------------------------------
  # generator: unknown
  # --------------------------------------------------------------------------

  else ()
    message (FATAL_ERROR "Unknown documentation generator: ${ARGN_GENERATOR}.")
  endif ()
endfunction ()
