##############################################################################
# \file  BasisProject.cmake
# \brief Settings, functions and macros used by any BASIS project.
#
# This is the main module that is included by BASIS projects. Most of the other
# BASIS CMake modules are included by this main module and hence do not need
# to be included separately.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# CMake version and policies
# ============================================================================

cmake_minimum_required (VERSION 2.8.2)

# Add policies introduced with CMake versions newer than the one specified
# above. These policies would otherwise trigger a policy not set warning by
# newer CMake versions.

if (POLICY CMP0016)
  cmake_policy (SET CMP0016 NEW)
endif ()

if (POLICY CMP0017)
  cmake_policy (SET CMP0017 NEW)
endif ()

# ============================================================================
# modules
# ============================================================================

# append CMake module path of BASIS to CMAKE_MODULE_PATH
set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}")

# The CMakeParseArguments.cmake CMake module was added to CMake since version
# 2.8.4 which just recenlty was released when the following macros and
# functions were first implemented. In order to support also previous CMake
# versions, a copy of the CMakeParseArguments.cmake module was added to the
# BASIS Core CMake modules.
include ("${CMAKE_CURRENT_LIST_DIR}/CMakeParseArguments.cmake")

# The ExternalData.cmake module is yet only part of ITK.
include ("${CMAKE_CURRENT_LIST_DIR}/ExternalData.cmake")

# BASIS modules
include ("${CMAKE_CURRENT_LIST_DIR}/BasisSettings.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/BasisCommonTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/BasisSubversionTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/BasisDocTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/BasisMatlabTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/BasisTargetTools.cmake")

# ============================================================================
# initialize/finalize major components
# ============================================================================

# ****************************************************************************
# \brief Initialize project, calls CMake's project () command.
#
# Any BASIS project has to call this macro in the beginning of its root CMake
# configuration file. Further, the macro basis_project_finalize () has to be
# called at the end of the file.
#
# The version number consists of three components: the major version number,
# the minor version number, and the patch number. The format of the version
# string is "Major.Minor.Patch", where the minor version number and patch
# number default to 0 if not given. Only digits are allowed except of the
# two separating dots.
#
# - A change of the major version number indicates changes of the softwares
#   API (and ABI) and/or its behavior and/or the change or addition of major
#   features.
#
# - A change of the minor version number indicates changes that are not only
#   bug fixes and no major changes. Hence, changes of the API but not the ABI.
#
# - A change of the patch number indicates changes only related to bug fixes
#   which did not change the softwares API. It is the least important component
#   of the version number.
#
# The default settings set by BasisSettings.cmake can be overwritten by the
# file Settings.cmake in the PROJECT_CONFIG_DIR. This file is included by
# this macro after the project was initialized and before dependencies on
# other packages were resolved.
#
# Dependencies on other packages should be resolved via find_package () or
# find_sbia_package () commands in the Depends.cmake file which as well has to
# be located in PROJECT_CONFIG_DIR (note that this variable may be modified
# within the Settings.cmake file). The Depends.cmake file is included by this
# macro if present after the inclusion of the Settings.cmake file.
#
# Each BASIS project further has to have a README file in the root directory
# of the software component. This file is the root documentation file which
# refers the user to the further documentation files in PROJECT_DOC_DIR.
# A different name for the readme file can be set in the Settings.cmake file.
#
# A COPYING file with the copyright and license notices must be present in
# the root directory of the source tree. The name of this file can be
# changed in the Settings.cmake file.
#
# As the BasisTest.cmake module has to be included after the project ()
# command was used, this module is not included by the CMake use file of
# BASIS. Instead, it is included by this macro.
#
# The CMake module BasisUpdate.cmake realizes a feature referred to as
# "(automatic) file update". This feature is initialized by this macro and
# finalized by the corresponding basis_project_finalize () macro.
# As the CTest configuration file is usually maintained by the maintainer of
# the BASIS package and not the project developer, this file, if present in
# the project's source directory, is updated if the template was modified.
# If you experience problems with the automatic file update, contact the
# maintainer of the BASIS package and consider to disable the automatic file
# update for single files  by adding their path relative to the project's
# source directory to BASIS_UPDATE_EXCLUDE in the Settings.cmake file of
# your project. For example, to prevent the automatic udpate of the CTest
# configuration file, add "CTestConfig.cmake" to the list BASIS_UPDATE_EXCLUDE.
#
# \see basis_project_finalize ()
#
# \param [in] ARGVN This list is parsed for the following arguments.
#                   Moreover, any of these arguments can be specified
#                   in the file PROJECT_CONFIG_DIR/Settings.cmake
#                   instead with the prefix PROJECT_*, e.g.,
#                   "set (PROJECT_VERSION 1.0.0)".
#
#   NAME                 The name of the project.
#   VERSION              Project version string, i.e., "<major>(.<minor>(.<patch>))".
#   DESCRIPTION          Package description, used for packing.
#   PACKAGE_VENDOR       The vendor of this package, used for packaging.
#                        Defaults to "SBIA Group at University of Pennsylvania".
#   WELCOME_FILE         Welcome file used for installer.
#   README_FILE          Readme file. Defaults to PROJECT_SOURCE_DIR/README.
#   LICENSE_FILE         File containing copyright and license notices.
#                        Defaults to PROJECT_SOURCE_DIR/LICENSE.
#   REDIST_LICENSE_FILES Additional license files of other packages
#                        redistributed as part of this project.
#                        These licenses will be installed along with the
#                        project's LICENSE_FILE. By default, all files which
#                        match the regular expression
#                        "^PROJECT_SOURCE_DIR/LICENSE-.+" are considered.
#
# \note The DESCRIPTION and PACKAGE_VENDOR arguments can be lists of strings
#       which are concatenated to one string.

macro (basis_project_initialize)
  # set common CMake variables which would not be valid before project ()
  # such that they can be used in the Settings.cmake file, for example
  set (PROJECT_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  set (PROJECT_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}")

  # clear project attributes of CMake defaults or superproject
  set (PROJECT_NAME)
  set (PROJECT_VERSION)
  set (PROJECT_DESCRIPTION)
  set (PROJECT_PACKAGE_VENDOR)
  set (PROJECT_AUTHORS_FILE)
  set (PROJECT_WELCOME_FILE)
  set (PROJECT_README_FILE)
  set (PROJECT_INSTALL_FILE)
  set (PROJECT_LICENSE_FILE)
  set (PROJECT_REDIST_LICENSE_FILES)

  # parse arguments and/or include project settings file
  CMAKE_PARSE_ARGUMENTS (
    PROJECT
      ""
      "NAME;VERSION;AUTHORS_FILE;README_FILE;INSTALL_FILE;LICENSE_FILE"
      "DESCRIPTION;PACKAGE_VENDOR;REDIST_LICENSE_FILES"
    ${ARGN}
  )

  # check required project attributes or set default values
  if (NOT PROJECT_NAME)
    message (FATAL_ERROR "Project name not specified.")
  endif ()

  if (NOT PROJECT_VERSION)
    set (PROJECT_VERSION "0.0.0")
  endif ()

  if (PROJECT_PACKAGE_VENDOR)
    basis_list_to_string (PROJECT_PACKAGE_VENDOR ${PROJECT_PACKAGE_VENDOR})
  else ()
    set (PROJECT_PACKAGE_VENDOR "SBIA Group at University of Pennsylvania")
  endif ()

  if (PROJECT_DESCRIPTION)
    basis_list_to_string (PROJECT_DESCRIPTION ${PROJECT_DESCRIPTION})
  else ()
    set (PROJECT_DESCRIPTION "")
  endif ()

  if (NOT PROJECT_AUTHORS_FILE)
    set (PROJECT_AUTHORS_FILE "${PROJECT_SOURCE_DIR}/AUTHORS")
  endif ()

  if (NOT PROJECT_README_FILE)
    set (PROJECT_README_FILE "${PROJECT_SOURCE_DIR}/README")
  endif ()
  if (NOT EXISTS "${PROJECT_README_FILE}")
    message (FATAL_ERROR "Project ${PROJECT_NAME} is missing a README file.")
  endif ()

  if (NOT PROJECT_INSTALL_FILE)
    set (PROJECT_INSTALL_FILE "${PROJECT_SOURCE_DIR}/INSTALL")
  endif ()

  if (NOT PROJECT_LICENSE_FILE)
    set (PROJECT_LICENSE_FILE "${PROJECT_SOURCE_DIR}/COPYING")
  endif ()
  if (NOT EXISTS "${PROJECT_LICENSE_FILE}")
    message (FATAL_ERROR "Project ${PROJECT_NAME} is missing a COPYING file.")
  endif ()

  if (NOT PROJECT_REDIST_LICENSE_FILES)
    file (GLOB PROJECT_REDIST_LICENSE_FILES "${PROJECT_SOURCE_DIR}/COPYING-*")
  endif ()

  # start CMake project
  project ("${PROJECT_NAME}" CXX)

  set (CMAKE_PROJECT_NAME "${PROJECT_NAME}") # variable used by CPack

  # convert project name to upper and lower case only, respectively
  string (TOUPPER "${PROJECT_NAME}" PROJECT_NAME_UPPER)
  string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWER)

  # extract version numbers from version string
  basis_version_numbers (
    "${PROJECT_VERSION}"
      PROJECT_VERSION_MAJOR
      PROJECT_VERSION_MINOR
      PROJECT_VERSION_PATCH
  )

  # combine version numbers to version strings (also ensures consistency)
  set (PROJECT_VERSION   "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
  set (PROJECT_SOVERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")

  # get project revision
  basis_svn_get_revision ("${PROJECT_SOURCE_DIR}" PROJECT_REVISION)

  # print project information
  if (BASIS_VERBOSE)
    message (STATUS "Project:")
    message (STATUS "  Name      = ${PROJECT_NAME}")
    message (STATUS "  Version   = ${PROJECT_VERSION}")
    message (STATUS "  SoVersion = ${PROJECT_SOVERSION}")
    if (PROJECT_REVISION)
    message (STATUS "  Revision  = ${PROJECT_REVISION}")
    else ()
    message (STATUS "  Revision  = n/a")
    endif ()
  endif ()

  # instantiate project directory structure
  basis_initialize_directories ()
 
  # add project config directory to CMAKE_MODULE_PATH
  set (CMAKE_MODULE_PATH "${PROJECT_CONFIG_DIR}" ${CMAKE_MODULE_PATH})

  # include project specific settings
  if (EXISTS "${PROJECT_CONFIG_DIR}/ScriptConfig.cmake.in")
    set (DEFAULT_SCRIPT_CONFIG_FILE "${PROJECT_CONFIG_DIR}/ScriptConfig.cmake.in")
  endif ()

  include ("${PROJECT_CONFIG_DIR}/Settings.cmake" OPTIONAL)

  # enable testing
  include ("${BASIS_MODULE_PATH}/BasisTest.cmake")

  # resolve dependencies
  include ("${PROJECT_CONFIG_DIR}/Depends.cmake" OPTIONAL)

  basis_include_directories (BEFORE "${PROJECT_CODE_DIR}")
  basis_include_directories (BEFORE "${PROJECT_INCLUDE_DIR}")
  basis_include_directories (BEFORE "${PROJECT_INCLUDE_DIR}/sbia/${PROJECT_NAME_LOWER}")

  # authors, readme, install and license files
  get_filename_component (AUTHORS "${PROJECT_AUTHORS_FILE}" NAME)
  get_filename_component (README  "${PROJECT_README_FILE}" NAME)
  get_filename_component (INSTALL "${PROJECT_INSTALL_FILE}" NAME)
  get_filename_component (LICENSE "${PROJECT_LICENSE_FILE}" NAME)

  if (NOT "${PROJECT_BINARY_DIR}" STREQUAL "${PROJECT_SOURCE_DIR}")
    configure_file ("${PROJECT_README_FILE}" "${PROJECT_BINARY_DIR}/${README}" COPYONLY)
    configure_file ("${PROJECT_LICENSE_FILE}" "${PROJECT_BINARY_DIR}/${LICENSE}" COPYONLY)
    if (EXISTS "${PROJECT_AUTHORS_FILE}")
      configure_file ("${PROJECT_AUTHORS_FILE}" "${PROJECT_BINARY_DIR}/${AUTHORS}" COPYONLY)
    endif ()
    if (EXISTS "${PROJECT_INSTALL_FILE}")
      configure_file ("${PROJECT_INSTALL_FILE}" "${PROJECT_BINARY_DIR}/${INSTALL}" COPYONLY)
    endif ()
  endif ()

  install (
    FILES       "${PROJECT_README_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
  )

  install (
    FILES       "${PROJECT_AUTHORS_FILE}" "${PROJECT_INSTALL_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
    OPTIONAL
  )

  if (IS_SUBPROJECT)
    execute_process (
      COMMAND "${CMAKE_COMMAND}"
              -E compare_files "${CMAKE_SOURCE_DIR}/${LICENSE}" "${PROJECT_LICENSE_FILE}"
      RESULT_VARIABLE INSTALL_LICENSE
    )

    if (INSTALL_LICENSE)
      install (
        FILES       "${PROJECT_LICENSE_FILE}"
        DESTINATION "${INSTALL_DOC_DIR}"
        RENAME      "${LICENSE}-${PROJECT_NAME}"
      )
      file (
        APPEND "${CMAKE_BINARY_DIR}/${LICENSE}"
        "\n\n------------------------------------------------------------------------------\n"
        "See ${LICENSE}-${PROJECT_NAME} file for\n"
        "copyright and license notices of the ${PROJECT_NAME} package.\n"
        "------------------------------------------------------------------------------\n"
      )
      install (
        FILES       "${CMAKE_BINARY_DIR}/${LICENSE}"
        DESTINATION "${INSTALL_DOC_DIR}"
      )
    endif ()

    set (INSTALL_LICENSE)
  else ()
    install (
      FILES       "${PROJECT_LICENSE_FILE}"
      DESTINATION "${INSTALL_DOC_DIR}"
    )
  endif ()

  if (PROJECT_REDIST_LICENSE_FILES)
    install (
      FILES       "${PROJECT_REDIST_LICENSE_FILES}"
      DESTINATION "${INSTALL_DOC_DIR}"
    )
  endif ()

  set (AUTHORS)
  set (README)
  set (INSTALL)
  set (LICENSE)

  # configure default auxiliary source files
  basis_configure_auxiliary_sources (
    DEFAULT_SOURCES
    DEFAULT_HEADERS
    DEFAULT_PUBLIC_HEADERS
  )

  set (DEFAULT_INCLUDE_DIRS)
  foreach (SOURCE ${DEFAULT_HEADERS})
    get_filename_component (TMP "${SOURCE}" PATH)
    list (APPEND DEFAULT_INCLUDE_DIRS "${TMP}")
    set (TMP)
  endforeach ()
  set (SOURCE)
  if (DEFAULT_INCLUDE_DIRS)
    list (REMOVE_DUPLICATES DEFAULT_INCLUDE_DIRS)
  endif ()
  if (DEFAULT_INCLUDE_DIRS)
    basis_include_directories (BEFORE ${DEFAULT_INCLUDE_DIRS})
  endif ()

  if (DEFAULT_SOURCES)
    source_group ("Default" FILES ${DEFAULT_SOURCES} ${DEFAULT_HEADERS})
  endif ()

  # install public headers
  install (
    DIRECTORY   "${PROJECT_INCLUDE_DIR}/"
    DESTINATION "${INSTALL_INCLUDE_DIR}"
    OPTIONAL
    PATTERN     ".svn" EXCLUDE
    PATTERN     ".git" EXCLUDE
  )

  install (
    FILES       ${DEFAULT_PUBLIC_HEADERS}
    DESTINATION "${INSTALL_INCLUDE_DIR}/sbia/${PROJECT_NAME_LOWER}"
    COMPONENT   "${BASIS_LIBRARY_COMPONENT}"
  )
endmacro ()

# ****************************************************************************
# \brief Finalize project build configuration.
#
# This macro has to be called at the end of the root CMakeLists.txt file of
# each BASIS project initialized by basis_project ().
#
# The project configuration files are generated by including the CMake script
# PROJECT_CONFIG_DIR/GenerateConfig.cmake when this file exists or using
# the default script of BASIS.
#
# \see basis_project ()

macro (basis_project_finalize)
  # if project uses MATLAB
  if (MATLAB_FOUND)
    basis_create_addpaths_mfile ()
  endif ()

  # finalize addition of custom targets
  # \note Should be done for each (sub-)project as the finalize functions
  #       might make use of the PROJECT_* variables.
  basis_add_custom_finalize ()

  # finalize (super-)project
  if (NOT IS_SUBPROJECT)
    # create and add execname executable
    #basis_add_execname ()
    # add uninstall target
    basis_add_uninstall ()

    if (INSTALL_LINKS)
      basis_install_links ()
    endif ()
  endif ()

  # generate configuration files
  if (EXISTS "${PROJECT_CONFIG_DIR}/GenerateConfig.cmake")
    include ("${PROJECT_CONFIG_DIR}/GenerateConfig.cmake")
  else ()
    include ("${BASIS_MODULE_PATH}/GenerateConfig.cmake")
  endif ()

  # package software
  include ("${BASIS_MODULE_PATH}/BasisPack.cmake")
endmacro ()

# ============================================================================
# auxiliary source files
# ============================================================================

# ****************************************************************************
# \brief Configure default auxiliary source files.
#
# This function configures the following default auxiliary source files
# which can be used by the projects which are making use of BASIS.
#
#   - config.h    This file is intended to be included by all source files.
#                 Hence, other projects will indirectly include this file when
#                 they use a library of this project. Therefore, it is
#                 important to avoid potential name conflicts.
#
#   - mainaux.h   This file is intended to be included by .(c|cc|cpp|cxx) files
#                 only which contain the definition of the main () function.
#                 It shall not be included by any other source file!
#
# \note If there exists a *.in file of the corresponding source file in the
#       PROJECT_CONFIG_DIR, it will be used as template. Otherwise, the
#       template file of BASIS is used.
#
# \param [out] SOURCES        Configured auxiliary source files.
# \param [out] HEADERS        Configured auxiliary header files.
# \param [out] PUBLIC_HEADERS Auxiliary headers that should be installed.

function (basis_configure_auxiliary_sources SOURCES HEADERS PUBLIC_HEADERS)
  set (SOURCES_OUT        "")
  set (HEADERS_OUT        "")
  set (PUBLIC_HEADERS_OUT "")

  # get binary output directories
  file (RELATIVE_PATH TMP "${PROJECT_SOURCE_DIR}" "${PROJECT_CODE_DIR}")
  set (BINARY_CODE_DIR "${PROJECT_BINARY_DIR}/${TMP}")
  file (RELATIVE_PATH TMP "${PROJECT_SOURCE_DIR}" "${PROJECT_INCLUDE_DIR}")
  set (BINARY_INCLUDE_DIR "${PROJECT_BINARY_DIR}/${TMP}")

  # configure private auxiliary source files
  set (
    SOURCES_NAMES
      "config.cc"
      "mainaux.h"
  )

  foreach (SOURCE ${SOURCES_NAMES})
    set (TEMPLATE "${PROJECT_CODE_DIR}/${SOURCE}.in")
    if (NOT EXISTS "${TEMPLATE}")
      set (TEMPLATE "${BASIS_MODULE_PATH}/${SOURCE}.in")
    endif ()
    set  (SOURCE_OUT "${BINARY_CODE_DIR}/${SOURCE}")
    configure_file ("${TEMPLATE}" "${SOURCE_OUT}" @ONLY)
    if (SOURCE MATCHES ".h$")
      list (APPEND HEADERS_OUT "${SOURCE_OUT}")
    else ()
      list (APPEND SOURCES_OUT "${SOURCE_OUT}")
    endif ()
  endforeach ()

  # configure public auxiliary header files
  set (
    SOURCES_NAMES
      "config.h"
  )

  foreach (SOURCE ${SOURCES_NAMES})
    set (TEMPLATE "${PROJECT_INCLUDE_DIR}/sbia/${PROJECT_NAME_LOWER}/${SOURCE}.in")
    if (NOT EXISTS "${TEMPLATE}")
      set (TEMPLATE "${BASIS_MODULE_PATH}/${SOURCE}.in")
    endif ()
    set  (SOURCE_OUT "${BINARY_INCLUDE_DIR}/sbia/${PROJECT_NAME_LOWER}/${SOURCE}")
    configure_file ("${TEMPLATE}" "${SOURCE_OUT}" @ONLY)
    list (APPEND PUBLIC_HEADERS_OUT "${SOURCE_OUT}")
  endforeach ()

  list (APPEND HEADERS ${PUBLIC_HEADERS_OUT})

  # return
  set (${SOURCES}        "${SOURCES_OUT}"        PARENT_SCOPE)
  set (${HEADERS}        "${HEADERS_OUT}"        PARENT_SCOPE)
  set (${PUBLIC_HEADERS} "${PUBLIC_HEADERS_OUT}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# set/get any property
# ============================================================================

# ****************************************************************************
# \brief Replaces CMake's set_property () command.

function (basis_set_property SCOPE)
  if (SCOPE MATCHES "^TARGET$|^TEST$")
    set (IDX 0)
    foreach (ARG ${ARGN})
      if (ARG MATCHES "^APPEND$|^PROPERTY$")
        break ()
      endif ()
      if (SCOPE STREQUAL "TEST")
        basis_test_uid (UID "${ARG}")
      else ()
        basis_target_uid (UID "${ARG}")
      endif ()
      list (REMOVE_AT ARGN ${IDX})
      list (INSERT ARGN ${IDX} "${UID}")
      math (EXPR IDX "${IDX} + 1")
    endforeach ()
  endif ()
  set_property (${ARGN})
endfunction ()

# ****************************************************************************
# \brief Replaces CMake's get_property () command.

function (basis_get_property VAR SCOPE ELEMENT)
  if (SCOPE STREQUAL "TARGET")
    basis_target_uid (ELEMENT "${ELEMENT}")
  elseif (SCOPE STREQUAL "TEST")
    basis_test_uid (ELEMENT "${ELEMENT}")
  endif ()
  get_property (VALUE ${SCOPE} ${ELEMENT} ${ARGN})
  set ("${VAR}" "${VALUE}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# execname
# ============================================================================

# ****************************************************************************
# \brief Create source code of execname command and add executable target.
#
# \see basis_create_execname
#
# \param [in] TARGET_NAME Name of target. Defaults to "execname".

function (basis_add_execname)
  if (ARGC GREATER 1)
    message (FATAL_ERROR "Too many arguments given for function basis_add_execname ().")
  endif ()

  if (ARGC GREATER 0)
    set (TARGET_UID "${ARGV1}")
  else ()
    set (TARGET_UID "execname")
  endif ()

  # create source code
  basis_create_execname (SOURCES)

  # add executable target
  add_executable (${TARGET_UID} ${SOURCES})
endfunction ()

# ****************************************************************************
# \brief Create source code of execname target.
#
# The source file of the executable which is build by this target is
# configured using BASIS_TARGETS and the properties BASIS_TYPE, PREFIX,
# OUTPUT_NAME, and SUFFIX of these targets. The purpose of the built executable
# is to map CMake target names to their executable output names.
#
# Within source code of a certain project, other SBIA executables are called
# only indirectly using the target name which must be fixed and unique within
# the lab. The output name of these targets may however vary and depend on
# whether the project is build as part of a superproject or not. Each BASIS
# CMake function may adjust the output name in order to resolve name
# conflicts with other targets or SBIA executables.
#
# The idea is that a target name is supposed to be stable and known to the
# developer as soon as the target is added to a CMakeLists.txt file, while
# the name of the actual executable file is not known a priori as it is set
# by the BASIS CMake functions during the configure step. Thus, the developer
# should not rely on a particular name of the executable, but on the name of
# the corresponding CMake target.
#
# The execname target implements the calling conventions specified in the
# design Conventions document in the 'doc' directory.
#
# Example template file snippet:
#
# \code
# //! Number of targets.
# const int numberOfTargets = @NUMBER_OF_TARGETS@;
#
# //! Map which maps target names to executable names.
# const char * const targetNameToOutputNameMap [numberOfTargets][2] =
# {
# @TARGET_NAME_TO_OUTPUT_NAME_MAP@
# };
# \endcode
#
# Example usage:
#
# \code
# execname TargetA@ProjectA
# execname TargetA@ProjectB
# execname --namespace ProjectA TargetA
# \endcode
#
# \param [out] SOURCES List of generated source files.
# \param [in]  ARGN    The remaining list of arguments is parsed for the
#                      following options:
#
#    BASENAME Basename of generated source file.
#             If not given, the basename of the template source file is used.
#    TEMPLATE Template source file. If not specified, the default template
#             which is part of the SBIA CMake Modules package is used.

function (basis_create_execname SOURCES)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (ARGN "" "BASENAME;TEMPLATE" "" ${ARGN})

  if (NOT ARGN_TEMPLATE)
    set (ARGN_TEMPLATE "${BASIS_MODULE_PATH}/execname.cpp.in")
  endif ()

  if (NOT ARGN_BASENAME)
    get_filename_component (ARGN_BASENAME "${ARGN_TEMPLATE}" NAME_WE)
    string (REGEX REPLACE "\\.in$"          ""    ARGN_BASENAME "${ARGN_BASENAME}")
    string (REGEX REPLACE "\\.in\(\\..*\)$" "\\1" ARGN_BASENAME "${ARGN_BASENAME}")
  endif ()

  # output name
  set (SOURCE_FILE "${CMAKE_CURRENT_BINARY_DIR}/${ARGN_BASENAME}.cpp")

  # create initialization code of target name to executable name map
  set (NUMBER_OF_TARGETS "0")
  set (TARGET_NAME_TO_EXECUTABLE_NAME_MAP)

  foreach (TARGET_UID ${BASIS_TARGETS})
    get_target_property (BASIS_TYPE "${TARGET_UID}" "BASIS_TYPE")
  
    if (BASIS_TYPE MATCHES "EXECUTABLE|SCRIPT")
      get_target_property (OUTPUT_NAME "${TARGET_UID}" "OUTPUT_NAME")
  
      if (NOT OUTPUT_NAME)
        set (OUTPUT_NAME "${TARGET_UID}")
      endif ()
  
      set (EXECUTABLE_NAME "${PREFIX}${OUTPUT_NAME}${SUFFIX}")

      if (TARGET_NAME_TO_EXECUTABLE_NAME_MAP)
        set (TARGET_NAME_TO_EXECUTABLE_NAME_MAP "${TARGET_NAME_TO_EXECUTABLE_NAME_MAP},\n")
      endif ()
      set (TARGET_NAME_TO_EXECUTABLE_NAME_MAP "${TARGET_NAME_TO_EXECUTABLE_NAME_MAP}    {\"${TARGET_UID}\", \"${EXECUTABLE_NAME}\"}")

      math (EXPR NUMBER_OF_TARGETS "${NUMBER_OF_TARGETS} + 1")
    endif ()
  endforeach ()

  # configure source file
  configure_file ("${ARGN_TEMPLATE}" "${SOURCE_FILE}" @ONLY)

  # return
  set (SOURCES "${SOURCE_FILE}" PARENT_SCOPE)
endfunction ()

# ============================================================================
# installation
# ============================================================================

# ****************************************************************************
# \brief Install symbolic link.
#
# \param [in] OLD The value of the symbolic link.
# \param [in] NEW The name of the symbolic link.

function (basis_install_link OLD NEW)
  set (CMD_IN
    "
    set (OLD \"@OLD@\")
    set (NEW \"@NEW@\")


    if (NOT IS_ABSOLUTE \"\${OLD}\")
      set (OLD \"\${CMAKE_INSTALL_PREFIX}/\${OLD}\")
    endif ()
    if (NOT IS_ABSOLUTE \"\${NEW}\")
      set (NEW \"\${CMAKE_INSTALL_PREFIX}/\${NEW}\")
    endif ()

    if (IS_SYMLINK \"\${NEW}\")
      file (REMOVE \"\${NEW}\")
    endif ()

    if (EXISTS \"\${NEW}\")
      message (STATUS \"Skipping: \${NEW} -> \${OLD}\")
    else ()
      message (STATUS \"Installing: \${NEW} -> \${OLD}\")

      get_filename_component (SYMDIR \"\${NEW}\" PATH)

      file (RELATIVE_PATH OLD \"\${SYMDIR}\" \"\${OLD}\")

      if (NOT EXISTS \${SYMDIR})
        file (MAKE_DIRECTORY \"\${SYMDIR}\")
      endif ()

      execute_process (
        COMMAND \"${CMAKE_COMMAND}\" -E create_symlink \"\${OLD}\" \"\${NEW}\"
        RESULT_VARIABLE RETVAL
      )

      if (NOT RETVAL EQUAL 0)
        message (ERROR \"Failed to create (symbolic) link \${NEW} -> \${OLD}\")
      endif ()
    endif ()
    "
  )

  string (CONFIGURE "${CMD_IN}" CMD @ONLY)
  install (CODE "${CMD}")
endfunction ()

# ****************************************************************************
# \brief Create symbolic links to main executables.
#
# This function creates for each main executable a symbolic link directly
# under CMAKE_INSTALL_PREFIX/bin if INSTALL_SINFIX is not an empty string and the
# software is installed on a UNIX-based system, i.e., one which supports the
# creation of symbolic links.

function (basis_install_links)
  if (NOT UNIX)
    return ()
  endif ()

  # main executables
  foreach (TARGET_UID ${BASIS_TARGETS})
    get_target_property (BASIS_TYPE  ${TARGET_UID} "BASIS_TYPE")

    if (BASIS_TYPE MATCHES "^EXEC$|^MCC_EXEC$|^SCRIPT$")
      get_target_property (OUTPUT_NAME ${TARGET_UID} "OUTPUT_NAME")

      if (NOT OUTPUT_NAME)
        basis_target_name (OUTPUT_NAME ${TARGET_UID})
      endif ()
      get_target_property (INSTALL_DIR ${TARGET_UID} "RUNTIME_INSTALL_DIRECTORY")

      basis_install_link (
        "${INSTALL_DIR}/${OUTPUT_NAME}"
        "bin/${OUTPUT_NAME}"
      )
    endif ()
  endforeach ()

  # documentation
  # \note Not all CPack generators preserve symbolic links to directories
  # \note This is not part of the filesystem hierarchy standard of Linux,
  #       but of the standard of certain distributions including Ubuntu.
  basis_install_link (
    "${INSTALL_DOC_DIR}"
    "share/doc/${INSTALL_SINFIX}"
  )
endfunction ()

# ****************************************************************************
# \brief Add uninstall target.
#
# Unix version works with any SUS-compliant operating system, as it needs
# only Bourne Shell features Win32 version works with any Windows which
# supports extended cmd.exe syntax (Windows NT 4.0 and newer, maybe Windows
# NT 3.x too).
#
# \author Pau Garcia i Quiles, modified by the SBIA Group
# \see    http://www.cmake.org/pipermail/cmake/2007-May/014221.html

function (basis_add_uninstall)
  if (WIN32)
    add_custom_target (
      uninstall
        \"FOR /F \"tokens=1* delims= \" %%f IN \(${CMAKE_BINARY_DIR}/install_manifest.txt"}\)\" DO \(
            IF EXIST %%f \(
              del /q /f %%f"
            \) ELSE \(
               echo Problem when removing %%f - Probable causes: File already removed or not enough permissions
             \)
         \)
      VERBATIM
    )
  else ()
    # Unix
    add_custom_target (
      uninstall
        cat "${CMAKE_BINARY_DIR}/install_manifest.txt"
          | while read f \; do if [ -e \"\$\${f}\" ]; then rm \"\$\${f}\" \; else echo \"Problem when removing \"\$\${f}\" - Probable causes: File already removed or not enough permissions\" \; fi\; done
      COMMENT Uninstalling...
    )
  endif ()
endfunction ()

