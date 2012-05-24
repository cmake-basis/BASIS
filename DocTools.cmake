##############################################################################
# @file  DocTools.cmake
# @brief Tools related to gnerating or adding software documentation.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
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
# settings
# ============================================================================

## @addtogroup CMakeUtilities
#  @{


## @brief Default Doxygen configuration.
set (BASIS_DOXYGEN_DOXYFILE "${CMAKE_CURRENT_LIST_DIR}/Doxyfile.in")

## @brief Default Sphinx configuration.
set (BASIS_SPHINX_CONFIG "${CMAKE_CURRENT_LIST_DIR}/sphinx_conf.py")

## @brief Default Sphinx layout.
set (BASIS_SPHINX_LAYOUT "${CMAKE_CURRENT_LIST_DIR}/sphinx_layout.html")

## @brief Default Sphinx style.
set (BASIS_SPHINX_STYLE "${CMAKE_CURRENT_LIST_DIR}/sphinx_sbia.css")


## @}
# end of Doxygen group


# ============================================================================
# adding / generating documentation
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add documentation target.
#
# This function is especially used to add a custom target to the "doc" target
# which is used to generate documentation from input files such as in
# particular source code files and documentation files marked up using one
# of the supported lightweight markup languages. Other documentation files
# such as HTML, Word, or PDF documents can be added as well using this function.
#
# The supported generators are:
# <table border="0">
#   <tr>
#     @tp @b None @endtp
#     <td>This generator simply installs the given file or all files within
#         the specified directory.</td>
#   </tr>
#   <tr>
#     @tp @b Doxygen @endtp
#     <td>Used to generate API documentation from in-source code comments and
#         other related files marked up using Doxygen comments. See
#         basis_add_doxygen_doc() for more details.</td>
#   </tr>
#   <tr>
#     @tp @b Sphinx @endtp
#     <td>Used to generate documentation such as a web site from reStructuredText.
#         See basis_add_sphinx_doc() for more details.</td>
#   </tr>
# </table>
#
# @param [in] TARGET_NAME Name of the documentation target or file.
# @param [in] GENERATOR   Documentation generator, where the case of the
#                         generator name is ignored, i.e., @c Doxygen, @c DOXYGEN,
#                         @c doxYgen are all valid arguments which select the
#                         @c Doxygen generator. Defaults to the @c None generator.</td>
# @param [in] ARGN        Additional arguments for the particular generator.
#
# @returns Adds a custom target @p TARGET_NAME for the generation of the
#          documentation.
#
# @sa basis_install_doc()
# @sa basis_add_doxygen_doc()
# @sa basis_add_sphinx_doc()
#
# @ingroup CMakeAPI
function (basis_add_doc TARGET_NAME)
  CMAKE_PARSE_ARGUMENTS (ARGN "" "GENERATOR" "" ${ARGN})
  if (NOT ARGN_GENERATOR)
    set (ARGN_GENERATOR "NONE")
  else ()
    string (TOUPPER "${ARGN_GENERATOR}" ARGN_GENERATOR)
  endif ()
  if (ARGN_GENERATOR MATCHES "NONE")
    basis_install_doc (${TARGET_NAME})
  elseif (ARGN_GENERATOR MATCHES "DOXYGEN")
    basis_add_doxygen_doc (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS})
  elseif (ARGN_GENERATOR MATCHES "SPHINX")
    basis_add_sphinx_doc (${TARGET_NAME} ${ARGN_UNPARSED_ARGUMENTS})
  else ()
    message (FATAL_ERROR "Unknown documentation generator: ${ARGN_GENERATOR}.")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Install documentation file(s).
#
# This function either adds an installation rule for a single documentation
# file or a directory containing multiple documentation files.
#
# Example:
# @code
# basis_install_doc ("User Manual.pdf" OUTPUT_NAME "BASIS User Manual.pdf")
# basis_install_doc (DeveloperManual.docx COMPONENT dev)
# basis_install_doc (SourceManual.html    COMPONENT src)
# @endcode
#
# @param [in] SOURCE Documentation file or directory to install.
# @param [in] ARGN   List of optional arguments. Valid arguments are:
# @par
# <table border="0">
#   <tr>
#     @tp @b COMPONENT component @endtp
#     <td>Name of the component this documentation belongs to.
#         Defaults to @c BASIS_RUNTIME_COMPONENT.</td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION dir @endtp
#     <td>Installation directory prefix. Defaults to @c INSTALL_DOC_DIR.</td>
#   </tr>
#   <tr>
#     @tp @b OUTPUT_NAME name @endtp
#     <td>Name of file or directory after installation.</td>
#   </tr>
# </table>
#
# @sa basis_add_doc()
function (basis_install_doc SOURCE)
  CMAKE_PARSE_ARGUMENTS (ARGN "" "COMPONENT;DESTINATION;OUTPUT_NAME" "" ${ARGN})

  if (NOT ARGN_DESTINATION)
    set (ARGN_DESTINATION "${INSTALL_DOC_DIR}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()
  if (NOT ARGN_OUTPUT_NAME)
    basis_get_filename_component (ARGN_OUTPUT_NAME "${SOURCE}" NAME)
  endif ()

  basis_get_relative_path (
    RELPATH
      "${CMAKE_SOURCE_DIR}"
      "${CMAKE_CURRENT_SOURCE_DIR}/${ARGN_OUTPUT_NAME}"
  )

  if (BASIS_VERBOSE)
    message (STATUS "Adding documentation ${RELPATH}...")
  endif ()

  if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}")
    basis_install_directory (
      "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}/"
      "${ARGN_DESTINATION}/${ARGN_OUTPUT_NAME}"
      COMPONENT "${ARGN_COMPONENT}"
    )
  else ()
    install (
      FILES       "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}"
      DESTINATION "${ARGN_DESTINATION}"
      COMPONENT   "${ARGN_COMPONENT}"
      RENAME      "${ARGN_OUTPUT_NAME}"
    )
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Adding documentation ${RELPATH}... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add documentation to be generated by Doxygen.
#
# This function adds a build target to generate documentation from in-source
# code comments and other related project pages using the
# <a href="http://www.stack.nl/~dimitri/doxygen/index.html">Doxygen</a> tool.
#
# @param [in] TARGET_NAME Name of the documentation target.
# @param [in] ARGN        List of arguments. The valid arguments are:
# @par
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
#         Default: @c PROJECT_VERSION_AND_REVISION.</td>
#   </tr>
#   <tr>
#     @tp @b INPUT path1 [path2 ...] @endtp
#     <td>Value for Doxygen's @c INPUT tag which is used to specify input
#         directories/files. Any given input path is added to the default
#         input paths.@n
#         Default: @c PROJECT_CODE_DIR, @c BINARY_CODE_DIR,
#                  @c PROJECT_INCLUDE_DIR, @c BINARY_INCLUDE_DIR.</td>
#   </tr>
#   <tr>
#     @tp @b INPUT_FILTER filter @endtp
#     <td>
#       Value for Doxygen's @c INPUT_FILTER tag which can be used to
#       specify a default filter for all input files.@n
#       Default: @c doxyfilter of BASIS.
#     </td>
#   <tr>
#     @tp @b FILTER_PATTERNS pattern1 [pattern2...] @endtp
#     <td>Value for Doxygen's @c FILTER_PATTERNS tag which can be used to
#         specify filters on a per file pattern basis.@n
#         Default: None.</td>
#   </tr>
#   <tr>
#     @tp @b INCLUDE_PATH path1 [path2...] @endtp
#     <td>Doxygen's @c INCLUDE_PATH tag can be used to specify one or more
#         directories that contain include files that are not input files
#         but should be processed by the preprocessor. Any given directories
#         are appended to the default include path considered.
#         Default: Directories added by basis_include_directories().</td>
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
#     @tp @b COLS_IN_ALPHA_INDEX n @endtp
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
# documentation of the Doxygen tags. If none of the <tt>GENERATE_&lt;*&gt;</tt>
# options is given, @c GENERATE_HTML is set to @c YES.
# @n@n
# Example:
# @code
# basis_add_doxygen_doc (
#   api
#   DOXYFILE        "Doxyfile.in"
#   PROJECT_NAME    "${PROJECT_NAME}"
#   PROJECT_VERSION "${PROJECT_VERSION}"
#   COMPONENT       dev
# )
# @endcode
#
# @sa basis_add_doc()
function (basis_add_doxygen_doc TARGET_NAME)
  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  string (TOLOWER "${TARGET_NAME}" TARGET_NAME_LOWER)
  # verbose output
  if (BASIS_VERBOSE)
    message (STATUS "Adding documentation ${TARGET_UID}...")
  endif ()
  # find Doxygen
  find_package (Doxygen QUIET)
  if (NOT DOXYGEN_EXECUTABLE)
    if (BUILD_DOCUMENTATION)
      message (FATAL_ERROR "Doxygen not found! Either install Doxygen and/or set DOXYGEN_EXECUTABLE or disable BUILD_DOCUMENTATION.")
    endif ()
    message (STATUS "Doxygen not found. Generation of ${TARGET_UID} documentation disabled.")
    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_UID}... - skipped")
    endif ()
    return ()
  endif ()
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    DOXYGEN
      "GENERATE_HTML;GENERATE_LATEX;GENERATE_RTF;GENERATE_MAN"
      "COMPONENT;DESTINATION;DOXYFILE;TAGFILE;PROJECT_NAME;PROJECT_NUMBER;OUTPUT_DIRECTORY;COLS_IN_ALPHA_INDEX"
      "INPUT;INPUT_FILTER;FILTER_PATTERNS;EXCLUDE_PATTERNS;INCLUDE_PATH"
      ${ARGN_UNPARSED_ARGUMENTS}
  )
  # default destination
  if (NOT DOXYGEN_DESTINATION)
    if (NOT INSTALL_APIDOC_DIR)
      set (
        INSTALL_APIDOC_DIR "${INSTALL_DOC_DIR}/${TARGET_NAME_LOWER}"
        CACHE PATH
          "Installation directory of API documentation."
      )
      mark_as_advanced (INSTALL_APIDOC_DIR)
    endif ()
    set (DOXYGEN_DESTINATION "${INSTALL_APIDOC_DIR}")
  endif ()
  # default component
  if (NOT DOXYGEN_COMPONENT)
    set (DOXYGEN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()
  if (NOT DOXYGEN_COMPONENT)
    set (DOXYGEN_COMPONENT "Unspecified")
  endif ()
  # configuration file
  if (NOT DOXYGEN_DOXYFILE)
    set (DOXYGEN_DOXYFILE "${BASIS_DOXYGEN_DOXYFILE}")
  endif ()
  if (NOT EXISTS "${DOXYGEN_DOXYFILE}")
    message (FATAL_ERROR "Missing option DOXYGEN_FILE or Doxyfile ${DOXYGEN_DOXYFILE} does not exist.")
  endif ()
  # project name
  if (NOT DOXYGEN_PROJECT_NAME)
    set (DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
  endif ()
  if (NOT DOXYGEN_PROJECT_NUMBER)
    set (DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION_AND_REVISION}")
  endif ()
  # standard input files
  list (APPEND DOXYGEN_INPUT "${PROJECT_SOURCE_DIR}/BasisProject.cmake")
  if (EXISTS "${PROJECT_CONFIG_DIR}/Depends.cmake")
    list (APPEND DOXYGEN_INPUT "${PROJECT_CONFIG_DIR}/Depends.cmake")
  endif ()
  if (EXISTS "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Directories.cmake")
    list (APPEND DOXYGEN_INPUT "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Directories.cmake")
  endif ()
  if (EXISTS "${BINARY_CONFIG_DIR}/BasisSettings.cmake")
    list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/BasisSettings.cmake")
  endif ()
  if (EXISTS "${BINARY_CONFIG_DIR}/ProjectSettings.cmake")
    list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/ProjectSettings.cmake")
  endif ()
  if (EXISTS "${BINARY_CONFIG_DIR}/Settings.cmake")
    list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/Settings.cmake")
  elseif (EXISTS "${PROJECT_CONFIG_DIR}/Settings.cmake")
    list (APPEND DOXYGEN_INPUT "${PROJECT_CONFIG_DIR}/Settings.cmake")
  endif ()
  if (EXISTS "${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake")
    list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/BasisScriptConfig.cmake")
  endif ()
  if (EXISTS "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
    list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/ScriptConfig.cmake")
  endif ()
  if (EXISTS "${PROJECT_CONFIG_DIR}/ConfigSettings.cmake")
    list (APPEND DOXYGEN_INPUT "${PROJECT_CONFIG_DIR}/ConfigSettings.cmake")
  endif ()
  if (EXISTS "${PROJECT_SOURCE_DIR}/CTestConfig.cmake")
    list (APPEND DOXYGEN_INPUT "${PROJECT_SOURCE_DIR}/CTestConfig.cmake")
  endif ()
  if (EXISTS "${PROJECT_BINARY_DIR}/CTestCustom.cmake")
    list (APPEND DOXYGEN_INPUT "${PROJECT_BINARY_DIR}/CTestCustom.cmake")
  endif ()
  # package configuration files - only exist *after* this function executed
  list (APPEND DOXYGEN_INPUT "${BINARY_CONFIG_DIR}/${PROJECT_NAME}Config.cmake")
  list (APPEND DOXYGEN_INPUT "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")
  list (APPEND DOXYGEN_INPUT "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Use.cmake")
  # input directories
  if (NOT BASIS_AUTO_PREFIX_INCLUDES AND EXISTS "${PROJECT_INCLUDE_DIR}")
    list (APPEND DOXYGEN_INPUT "${PROJECT_INCLUDE_DIR}")
  endif ()
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
  # add .dox files as input
  file (GLOB_RECURSE DOX_FILES "${PROJECT_DOC_DIR}/*.dox")
  list (SORT DOX_FILES) # alphabetic order
  list (APPEND DOXYGEN_INPUT ${DOX_FILES})
  # add .dox files of BASIS modules
  if (PROJECT_NAME MATCHES "^BASIS$")
    set (FilesystemHierarchyStandardPageRef "@ref FilesystemHierarchyStandard")
    set (BuildOfScriptTargetsPageRef        "@ref BuildOfScriptTargets")
  else ()
    set (FilesystemHierarchyStandardPageRef "Filesystem Hierarchy Standard")
    set (BuildOfScriptTargetsPageRef        "build of script targets")
  endif ()
  configure_file(
    "${BASIS_MODULE_PATH}/Modules.dox.in"
    "${CMAKE_CURRENT_BINARY_DIR}/BasisModules.dox" @ONLY)
  list (APPEND DOXYGEN_INPUT "${CMAKE_CURRENT_BINARY_DIR}/BasisModules.dox")
  # add .dox files of used BASIS utilities
  list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/Utilities.dox")
  list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/CxxUtilities.dox")
  foreach (L IN ITEMS Cxx Java Python Perl Bash Matlab)
    string (TOUPPER "${L}" U)
    if (U MATCHES "CXX")
      if (BASIS_UTILITIES_ENABLED MATCHES "CXX")
        set (PROJECT_USES_CXX_UTILITIES TRUE)
      else ()
        set (PROJECT_USES_CXX_UTILITIES FALSE)
      endif ()
    else ()
      basis_get_project_property (USES_${U}_UTILITIES PROPERTY PROJECT_USES_${U}_UTILITIES)
    endif ()
    if (USES_${U}_UTILITIES)
      list (FIND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/Utilities.dox" IDX)
      if (IDX EQUAL -1)
        list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/Utilities.dox")
      endif ()
      list (APPEND DOXYGEN_INPUT "${BASIS_MODULE_PATH}/${L}Utilities.dox")
    endif ()
  endforeach ()
  # include path
  basis_get_project_property (INCLUDE_DIRS PROPERTY PROJECT_INCLUDE_DIRS)
  foreach (D IN LISTS INCLUDE_DIRS)
    list (FIND DOXYGEN_INPUT "${D}" IDX)
    if (IDX EQUAL -1)
      list (APPEND DOXYGEN_INCLUDE_PATH "${D}")
    endif ()
  endforeach ()
  basis_list_to_delimited_string (
    DOXYGEN_INCLUDE_PATH "\"\nINCLUDE_PATH          += \"" ${DOXYGEN_INCLUDE_PATH}
  )
  set (DOXYGEN_INCLUDE_PATH "\"${DOXYGEN_INCLUDE_PATH}\"")
  # make string from DOXYGEN_INPUT - after include path was set
  basis_list_to_delimited_string (
    DOXYGEN_INPUT "\"\nINPUT                 += \"" ${DOXYGEN_INPUT}
  )
  set (DOXYGEN_INPUT "\"${DOXYGEN_INPUT}\"")
  # input filters
  if (NOT DOXYGEN_INPUT_FILTER)
    basis_get_target_uid (DOXYFILTER "${BASIS_NAMESPACE_LOWER}.basis.doxyfilter")
    if (TARGET "${DOXYFILTER}")
      basis_get_target_location (DOXYGEN_INPUT_FILTER "${DOXYFILTER}" ABSOLUTE)
    endif ()
  else ()
    set (DOXYFILTER)
  endif ()
  if (DOXYGEN_INPUT_FILTER)
    if (WIN32)
      # Doxygen on Windows (XP, 32-bit) (at least up to version 1.8.0) seems
      # to have a problem of not calling filters which have a space character
      # in their file path correctly. The doxyfilter.bat Batch program is used
      # as a wrapper for the actual filter which is part of the BASIS build.
      # As this file is in the working directory of Doxygen, it can be
      # referenced relative to this working directory, i.e., without file paths.
      # The Batch program itself then calls the actual Doxygen filter with proper
      # quotes to ensure that spaces in the file path are handled correctly.
      # The file extension .bat shall distinguish this wrapper script from the actual
      # doxyfilter.cmd which is generated by BASIS on Windows.
      configure_file ("${BASIS_MODULE_PATH}/doxyfilter.bat.in" "doxyfilter.bat" @ONLY)
      set (DOXYGEN_INPUT_FILTER "doxyfilter.bat")
    endif ()
  endif ()
  basis_list_to_delimited_string (
    DOXYGEN_FILTER_PATTERNS "\"\nFILTER_PATTERNS       += \"" ${DOXYGEN_FILTER_PATTERNS}
  )
  if (DOXYGEN_FILTER_PATTERNS)
    set (DOXYGEN_FILTER_PATTERNS "\"${DOXYGEN_FILTER_PATTERNS}\"")
  endif ()
  # exclude patterns
  list (APPEND DOXYGEN_EXCLUDE_PATTERNS "cmake_install.cmake")
  list (APPEND DOXYGEN_EXCLUDE_PATTERNS "CTestTestfile.cmake")
  basis_list_to_delimited_string (
    DOXYGEN_EXCLUDE_PATTERNS "\"\nEXCLUDE_PATTERNS      += \"" ${DOXYGEN_EXCLUDE_PATTERNS}
  )
  set (DOXYGEN_EXCLUDE_PATTERNS "\"${DOXYGEN_EXCLUDE_PATTERNS}\"")
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
  # HTML style
  set (DOXYGEN_HTML_STYLESHEET "${BASIS_MODULE_PATH}/doxygen_sbia.css")
  set (DOXYGEN_HTML_HEADER     "${BASIS_MODULE_PATH}/doxygen_header.html")
  set (DOXYGEN_HTML_FOOTER     "${BASIS_MODULE_PATH}/doxygen_footer.html")
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
  set (DOXYFILE "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile.${TARGET_NAME_LOWER}")
  configure_file ("${DOXYGEN_DOXYFILE}" "${DOXYFILE}" @ONLY)
  # add target
  set (LOGOS)
  if (DOXYGEN_HTML_OUTPUT)
    set (LOGOS "${DOXYGEN_OUTPUT_DIRECTORY}/html/logo_sbia.png"
               "${DOXYGEN_OUTPUT_DIRECTORY}/html/logo_penn.png")
    add_custom_command (
      OUTPUT   ${LOGOS}
      COMMAND "${CMAKE_COMMAND}" -E copy
                "${BASIS_MODULE_PATH}/logo_sbia.png"
                "${DOXYGEN_OUTPUT_DIRECTORY}/html/logo_sbia.png"
      COMMAND "${CMAKE_COMMAND}" -E copy
                "${BASIS_MODULE_PATH}/logo_penn.gif"
                "${DOXYGEN_OUTPUT_DIRECTORY}/html/logo_penn.gif"
      COMMENT "Copying logos to ${DOXYGEN_OUTPUT_DIRECTORY}/html/..."
    )
  endif ()

  add_custom_target (
    ${TARGET_UID} "${DOXYGEN_EXECUTABLE}" "${DOXYFILE}"
    DEPENDS ${LOGOS}
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    COMMENT "Building documentation ${TARGET_UID}..."
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
  # The Doxygen filter, if a build target of this project, has to be build
  # before the documentation can be generated.
  if (TARGET "${DOXYFILTER}")
    add_dependencies (${TARGET_UID} ${DOXYFILTER})
  endif ()
  # The public header files shall be configured/copied before.
  if (TARGET headers)
    add_dependencies (${TARGET_UID} headers)
  endif ()
  # The documentation shall be build after all other executable and library
  # targets have been build. For example, a .py.in script file shall first
  # be "build", i.e., configured before the documentation is being generated
  # from the configured .py file.
  basis_get_project_property (TARGETS PROPERTY TARGETS)
  foreach (_UID ${TARGETS})
    get_target_property (BASIS_TYPE ${_UID} "BASIS_TYPE")
    if (BASIS_TYPE MATCHES "SCRIPT|EXECUTABLE|LIBRARY")
      add_dependencies (${TARGET_UID} ${_UID})
    endif ()
  endforeach ()
  # add target as dependency to doc target
  if (NOT TARGET doc)
    if (BUILD_DOCUMENTATION)
      add_custom_target (doc ALL)
    else ()
      add_custom_target (doc)
    endif ()
  endif ()
  add_dependencies (doc ${TARGET_UID})
  # install documentation
  install (
    CODE
      "
      set (INSTALL_PREFIX \"${DOXYGEN_DESTINATION}\")
      if (NOT IS_ABSOLUTE \"\${INSTALL_PREFIX}\")
        set (INSTALL_PREFIX \"${INSTALL_PREFIX}/\${INSTALL_PREFIX}\")
      endif ()

      macro (install_doxydoc DIR)
        file (
          GLOB_RECURSE
            FILES
          RELATIVE \"${DOXYGEN_OUTPUT_DIRECTORY}\"
            \"${DOXYGEN_OUTPUT_DIRECTORY}/\${DIR}/*\"
        )
        foreach (F IN LISTS FILES)
          execute_process (
            COMMAND \"${CMAKE_COMMAND}\" -E compare_files
                \"${DOXYGEN_OUTPUT_DIRECTORY}/\${F}\"
                \"\${INSTALL_PREFIX}/\${F}\"
            RESULT_VARIABLE RC
            OUTPUT_QUIET
            ERROR_QUIET
          )
          if (RC EQUAL 0)
            message (STATUS \"Up-to-date: \${INSTALL_PREFIX}/\${F}\")
          else ()
            message (STATUS \"Installing: \${INSTALL_PREFIX}/\${F}\")
            execute_process (
              COMMAND \"${CMAKE_COMMAND}\" -E copy_if_different
                  \"${DOXYGEN_OUTPUT_DIRECTORY}/\${F}\"
                  \"\${INSTALL_PREFIX}/\${F}\"
              RESULT_VARIABLE RC
              OUTPUT_QUIET
              ERROR_QUIET
            )
            if (RC EQUAL 0)
              list (APPEND CMAKE_INSTALL_MANIFEST_FILES \"\${INSTALL_PREFIX}/\${F}\")
            else ()
              message (STATUS \"Failed to install \${INSTALL_PREFIX}/\${F}\")
            endif ()
          endif ()
        endforeach ()
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
  # done
  if (BASIS_VERBOSE)
    message (STATUS "Adding documentation ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add documentation target to be generated by Sphinx.
#
# @sa basis_add_doc()
function (basis_add_sphinx_doc TARGET_NAME)
  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")
  string (TOLOWER "${TARGET_NAME}" TARGET_NAME_LOWER)
  # verbose output
  if (BASIS_VERBOSE)
    message (STATUS "Adding documentation ${TARGET_UID}...")
  endif ()
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      ""
      "COMPONENT;DESTINATION;BUILDER;CONFIG_FILE;SOURCE_DIRECTORY;OUTPUT_DIRECTORY;TAG;LOGO;COPYRIGHT"
      "ASSIGNMENTS;STATIC;TEMPLATES;CONFIG;INPUT;EXCLUDE_PATTERNS;PAGES"
      ${ARGN}
  )
  # builder
  if (NOT ARGN_BUILDER)
    set (ARGN_BUILDER "dirhtml")
  else ()
    string (TOLOWER "${ARGN_BUILDER}" ARGN_BUILDER)
  endif ()
  if (NOT ARGN_BUILDER MATCHES "^(apidoc|html|dirhtml|singlehtml|latex|man)$")
    message (FATAL_ERROR "Unknown/unsupported Sphinx builder: ${ARGN_BUILDER}")
  endif ()
  # find Sphinx
  find_package (Sphinx)
  if (BUILD_DOCUMENTATION)
    set (ERRMSGTYP "FATAL_ERROR")
    set (ERRMSG    "failed")
  else ()
    set (ERRMSGTYP "STATUS")
    set (ERRMSG    "skipped")
  endif ()
  if (ARGN_BUILDER MATCHES "apidoc")
    if (NOT Sphinx-apidoc_EXECUTABLE)
      message (FATAL_ERROR "Generation of API documentation using Sphinx not supported yet! Consider the use of Doxygen instead.")
      if (BUILD_DOCUMENTATION)
        message (FATAL_ERROR "Command sphinx-apidoc not found! Either install Sphinx and/or set Sphinx-apidoc_EXECUTABLE or disable BUILD_DOCUMENTATION.")
      endif ()
      message (STATUS "Command sphinx-apidoc not found. Generation of ${TARGET_UID} documentation disabled.")
      set (SPHINX_FOUND FALSE)
    endif ()
  elseif (NOT Sphinx-build_EXECUTABLE)
    if (BUILD_DOCUMENTATION)
      message (FATAL_ERROR "Command sphinx-build not found! Either install Sphinx and/or set Sphinx-build_EXECUTABLE or disable BUILD_DOCUMENTATION.")
    endif ()
    message (STATUS "Command sphinx-build not found. Generation of ${TARGET_UID} documentation disabled.")
    set (SPHINX_FOUND FALSE)
  endif ()
  if (NOT SPHINX_FOUND)
    if (BASIS_VERBOSE)
      message (STATUS "Adding documentation ${TARGET_UID}... - skipped")
    endif ()
    return ()
  endif ()
  # source directory
  if (NOT ARGN_SOURCE_DIRECTORY)
    set (ARGN_SOURCE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  elseif (NOT IS_ABSOLUTE "${ARGN_SOURCE_DIRECTORY}")
    get_filename_component (ARGN_SOURCE_DIRECTORY "${ARGN_SOURCE_DIRECTORY}" ABSOLUTE)
  endif ()
  # build directory
  if (NOT ARGN_OUTPUT_DIRECTORY)
    set (ARGN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html")
  elseif (NOT IS_ABSOLUTE "${ARGN_OUTPUT_DIRECTORY}")
    set (ARGN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${ARGN_OUTPUT_DIRECTORY}")
  endif ()
  # configuration directory
  set (BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_UID}.dir")
  # template files
  file (GLOB TEMPLATE_FILES "${ARGN_SOURCE_DIRECTORY}/templates/*")
  list (APPEND TEMPLATE_FILES ${ARGN_TEMPLATES})
  set (USE_DEFAULT_LAYOUT TRUE)
  foreach (F IN LISTS TEMPLATE_FILES)
    get_filename_component (N "${F}" NAME)
    configure_file ("${F}" "${BUILD_DIR}/templates/${N}" COPYONLY)
    if (N MATCHES "^layout\\.html$")
      set (USE_DEFAULT_LAYOUT FALSE)
    endif ()
  endforeach ()
  if (USE_DEFAULT_LAYOUT)
    configure_file ("${BASIS_SPHINX_LAYOUT}" "${BUILD_DIR}/templates/layout.html" COPYONLY)
  endif ()
  # static files
  file (GLOB_RECURSE STATIC_FILES RELATIVE "${ARGN_SOURCE_DIRECTORY}/static" "${ARGN_SOURCE_DIRECTORY}/static/*")
  list (APPEND STATIC_FILES ${ARGN_STATIC})
  set (USE_DEFAULT_STYLE TRUE)
  foreach (F IN LISTS STATIC_FILES)
    get_filename_component (N "${F}" NAME)
    if (IS_ABSOLUTE "${F}")
      configure_file ("${F}" "${BUILD_DIR}/static/${N}" COPYONLY)
    else ()
      configure_file ("${ARGN_SOURCE_DIRECTORY}/static/${F}" "${BUILD_DIR}/static/${F}" COPYONLY)
    endif ()
    if (N MATCHES "^default\\.css$")
      set (USE_DEFAULT_LAYOUT FALSE)
    elseif (NOT ARGN_LOGO AND N MATCHES "^logo\\.")
      set (ARGN_LOGO "${F}")
    endif ()
  endforeach ()
  if (USE_DEFAULT_STYLE)
    configure_file ("${BASIS_SPHINX_STYLE}" "${BUILD_DIR}/static/default.css" COPYONLY)
  endif ()
  # configuration settings
  if (ARGN_COPYRIGHT)
    set (COPYRIGHT "${ARGN_COPYRIGHT}")
  else ()
    set (COPYRIGHT "University of Pennsylvania")
  endif ()
  if (NOT ARGN_LOGO)
    if (EXISTS "${ARGN_SOURCE_DIRECTORY}/logo.png")
      set (ARGN_LOGO "${ARGN_SOURCE_DIRECTORY}/logo.png")
    elseif (EXISTS "${ARGN_SOURCE_DIRECTORY}/logo.gif")
      set (ARGN_LOGO "${ARGN_SOURCE_DIRECTORY}/logo.gif")
    endif ()
  endif ()
  if (ARGN_LOGO)
    if (NOT EXISTS "${ARGN_LOGO}")
      message (FATAL_ERROR "Missing project logo file ${ARGN_LOGO} used by documentation target ${TARGET_UID}!")
    endif ()
    get_filename_component (N "${ARGN_LOGO}" NAME)
    configure_file ("${ARGN_LOGO}" "${BUILD_DIR}/static/${N}" COPYONLY)
    set (LOGO "'_static/${N}'")
  else ()
    set (LOGO "None")
  endif ()
  set (PAGES) # ordered Python array of (linkname, page) tuples
  foreach (P ${ARGN_PAGES}) # no empty entries
    if (PAGES)
      set (PAGES "${PAGES}, ")
    else ()
      set (PAGES "[")
    endif ()
    if (P MATCHES "(.*):(.*)")
      set (PAGES "${PAGES}('${CMAKE_MATCH_1}', '${CMAKE_MATCH_2}')")
    elseif (P MATCHES "^index$")
      set (PAGES "${PAGES}('home', '${P}')")
    else ()
      set (PAGES "${PAGES}('${P}', '${P}')")
    endif ()
  endforeach ()
  if (PAGES)
    set (PAGES "${PAGES}]")
  else ()
    set (PAGES "{'home': 'index'}")
  endif ()
  # configuration file
  if (NOT ARGN_CONFIG_FILE)
    set (ARGN_CONFIG_FILE "${BASIS_SPHINX_CONFIG}")
  endif ()
  get_filename_component (ARGN_CONFIG_FILE "${ARGN_CONFIG_FILE}" ABSOLUTE)
  if (EXISTS "${ARGN_CONFIG_FILE}")
    configure_file ("${ARGN_CONFIG_FILE}" "${BUILD_DIR}/conf.py" @ONLY)
  elseif (EXISTS "${ARGN_CONFIG_FILE}.in")
    configure_file ("${ARGN_CONFIG_FILE}.in" "${BUILD_DIR}/conf.py" @ONLY)
  else ()
    message (FATAL_ERROR "Missing Sphinx configuration file ${ARGN_CONFIG_FILE}!")
  endif ()
  # add target to copy default logos
  set (LOGOS "${BUILD_DIR}/static/logo_sbia.png"
             "${BUILD_DIR}/static/logo_penn.gif")
  add_custom_command (
    OUTPUT   ${LOGOS}
    COMMAND "${CMAKE_COMMAND}" -E copy
                "${BASIS_MODULE_PATH}/logo_sbia.png"
                "${BUILD_DIR}/static/logo_sbia.png"
    COMMAND "${CMAKE_COMMAND}" -E copy
                "${BASIS_MODULE_PATH}/logo_penn.gif"
                "${BUILD_DIR}/static/logo_penn.gif"
    COMMENT "Copying logos to directory of static files..."
  )
  # compile additional sphinx-build command arguments
  set (ARGS)
  list (LENGTH ARGN_CONFIG LEN)
  while (LEN GREATER 1)
    list (GET ARGN_CONFIG 0 SETTING)
    list (GET ARGN_CONFIG 1 VALUE)
    string (TOLOWER "${SETTING}" SETTING)
    list (APPEND ARGS "-D" "${SETTING}=${VALUE}")
    list (REMOVE_AT ARGN_CONFIG 0 1)
    list (LENGTH ARGN_CONFIG LEN)
  endwhile ()
  if (LEN GREATER 0)
    message (FATAL_ERROR "Too many/few arguments for CONFIG option given!")
  endif ()
  list (LENGTH ARGN_ASSIGNMENTS LEN)
  while (LEN GREATER 1)
    list (GET ARGN_ASSIGNMENTS 0 NAME)
    list (GET ARGN_ASSIGNMENTS 1 VALUE)
    list (APPEND ARGS "-A" "${NAME}=${VALUE}")
    list (REMOVE_AT ARGN_ASSIGNMENTS 0 1)
    list (LENGTH ARGN_ASSIGNMENTS LEN)
  endwhile ()
  if (LEN GREATER 0)
    message (FATAL_ERROR "Too many/few arguments for ASSIGNMENTS given!")
  endif ()
  if (NOT BASIS_VERBOSE)
    list (APPEND ARGS "-q")
  endif ()
  if (ARGN_TAG)
    list (APPEND ARGS "-t" "${ARGN_TAG}")
  endif ()
  # add target to build documentation
  add_custom_target (
    ${TARGET_UID} "${Sphinx-build_EXECUTABLE}" -a -N -n ${ARGS}
        -c "${BUILD_DIR}"
        -d "${BUILD_DIR}/doctrees"
        "${ARGN_SOURCE_DIRECTORY}"
        "${ARGN_OUTPUT_DIRECTORY}"
    DEPENDS ${LOGOS}
    WORKING_DIRECTORY "${BUILD_DIR}"
    COMMENT "Building documentation ${TARGET_UID}..."
  )
  # add target as dependency to doc target
  if (NOT TARGET doc)
    if (BUILD_DOCUMENTATION)
      add_custom_target (doc ALL)
    else ()
      add_custom_target (doc)
    endif ()
  endif ()
  add_dependencies (doc ${TARGET_UID})
  # cleanup on "make clean"
  set_property (
    DIRECTORY
    APPEND PROPERTY
      ADDITIONAL_MAKE_CLEAN_FILES
        "${BUILD_DIR}/doctrees"
        "${ARGN_OUTPUT_DIRECTORY}/html"
  )
  # install documentation
  # TODO
endfunction ()

# ============================================================================
# change log
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add target for generation of ChangeLog file.
#
# The ChangeLog is either generated from the Subversion or Git log depending
# on which revision control system is used by the project. Moreover, the
# project's source directory must be either a Subversion working copy or
# the root of a Git repository, respectively. In case of Subversion, if the
# command-line tool svn2cl(.sh) is installed, it is used to output a nicer
# formatted change log.
function (basis_add_changelog)
  basis_make_target_uid (TARGET_UID "changelog")

  option (BUILD_CHANGELOG "Request build and/or installation of the ChangeLog." OFF)
  mark_as_advanced (BUILD_CHANGELOG)
  set (CHANGELOG_FILE "${PROJECT_BINARY_DIR}/ChangeLog")

  if (BASIS_VERBOSE)
    message (STATUS "Adding ChangeLog...")
  endif ()

  if (BUILD_CHANGELOG)
    set (_ALL "ALL")
  else ()
    set (_ALL)
  endif ()

  set (DISABLE_BUILD_CHANGELOG FALSE)

  # --------------------------------------------------------------------------
  # generate ChangeLog from Subversion history
  if (EXISTS "${PROJECT_SOURCE_DIR}/.svn")
    find_package (Subversion QUIET)
    if (Subversion_FOUND)

      if (_ALL)
        message ("Generation of ChangeLog enabled as part of ALL."
                 " Be aware that the ChangeLog generation from the Subversion"
                 " commit history can take several minutes and may require the"
                 " input of your Subversion repository credentials during the"
                 " build. If you would like to build the ChangeLog separate"
                 " from the rest of the software package, disable the option"
                 " BUILD_CHANGELOG. You can then build the changelog target"
                 " separate from ALL.")
      endif ()

      # using svn2cl command
      find_program (
        SVN2CL_EXECUTABLE
          NAMES svn2cl svn2cl.sh
          DOC   "The command line tool svn2cl."
      )
      mark_as_advanced (SVN2CL_EXECUTABLE)
      if (SVN2CL_EXECUTABLE)
        add_custom_target (
          ${TARGET_UID} ${_ALL}
          COMMAND "${SVN2CL_EXECUTABLE}"
              "--output=${CHANGELOG_FILE}"
              "--linelen=79"
              "--reparagraph"
              "--group-by-day"
              "--include-actions"
              "--separate-daylogs"
              "${PROJECT_SOURCE_DIR}"
          COMMAND "${CMAKE_COMMAND}"
              "-DCHANGELOG_FILE:FILE=${CHANGELOG_FILE}" -DINPUTFORMAT=SVN2CL
              -P "${BASIS_MODULE_PATH}/PostprocessChangeLog.cmake"
          WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
          COMMENT "Generating ChangeLog from Subversion log (using svn2cl)..."
        )
      # otherwise, use svn log output directly
      else ()
        add_custom_target (
          ${TARGET_UID} ${_ALL}
          COMMAND "${CMAKE_COMMAND}"
              "-DCOMMAND=${Subversion_SVN_EXECUTABLE};log"
              "-DWORKING_DIRECTORY=${PROJECT_SOURCE_DIR}"
              "-DOUTPUT_FILE=${CHANGELOG_FILE}"
              -P "${BASIS_SCRIPT_EXECUTE_PROCESS}"
          COMMAND "${CMAKE_COMMAND}"
              "-DCHANGELOG_FILE:FILE=${CHANGELOG_FILE}" -DINPUTFORMAT=SVN
              -P "${BASIS_MODULE_PATH}/PostprocessChangeLog.cmake"
          COMMENT "Generating ChangeLog from Subversion log..."
          VERBATIM
        )
      endif ()

    else ()
      message (STATUS "Project is SVN working copy but Subversion executable was not found."
                      " Generation of ChangeLog disabled.")
      set (DISABLE_BUILD_CHANGELOG TRUE)
    endif ()

  # --------------------------------------------------------------------------
  # generate ChangeLog from Git log
  elseif (EXISTS "${PROJECT_SOURCE_DIR}/.git")
    find_package (Git QUIET)
    if (GIT_FOUND)

      add_custom_target (
        ${TARGET_UID} ${_ALL}
        COMMAND "${CMAKE_COMMAND}"
            "-DCOMMAND=${GIT_EXECUTABLE};log;--date-order;--date=short;--pretty=format:%ad\ \ %an%n%n%w(79,8,10)* %s%n%n%b%n"
            "-DWORKING_DIRECTORY=${PROJECT_SOURCE_DIR}"
            "-DOUTPUT_FILE=${CHANGELOG_FILE}"
            -P "${BASIS_SCRIPT_EXECUTE_PROCESS}"
        COMMAND "${CMAKE_COMMAND}"
            "-DCHANGELOG_FILE=${CHANGELOG_FILE}" -DINPUTFORMAT=GIT
            -P "${BASIS_MODULE_PATH}/PostprocessChangeLog.cmake"
        COMMENT "Generating ChangeLog from Git log..."
        VERBATIM
      )

    else ()
      message (STATUS "Project is Git repository but Git executable was not found."
                      " Generation of ChangeLog disabled.")
      set (DISABLE_BUILD_CHANGELOG TRUE)
    endif ()

  # --------------------------------------------------------------------------
  # neither SVN nor Git repository
  else ()
    message (STATUS "Project is neither SVN working copy nor Git repository."
                    " Generation of ChangeLog disabled.")
    set (DISABLE_BUILD_CHANGELOG TRUE)
  endif ()

  # --------------------------------------------------------------------------
  # disable changelog target
  if (DISABLE_BUILD_CHANGELOG)
    set (BUILD_CHANGELOG OFF CACHE INTERNAL "" FORCE)
    if (BASIS_VERBOSE)
      message (STATUS "Adding ChangeLog... - skipped")
    endif ()
    return ()
  endif ()

  # --------------------------------------------------------------------------
  # cleanup on "make clean"
  set_property (DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CHANGELOG_FILE}")

  # --------------------------------------------------------------------------
  # install ChangeLog
  install (
    FILES       "${CHANGELOG_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
    COMPONENT   "${BASIS_RUNTIME_COMPONENT}"
    OPTIONAL
  )

  if (BASIS_VERBOSE)
    message (STATUS "Adding ChangeLog... - done")
  endif ()
endfunction ()
