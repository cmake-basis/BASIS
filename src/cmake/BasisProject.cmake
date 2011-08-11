##############################################################################
# @file  BasisProject.cmake
# @brief Settings, functions and macros used by BASIS project.
#
# This is the main module that is included by BASIS projects. Most of the other
# BASIS CMake modules are included by this main module and hence do not need
# to be included separately. In particular, all CMake modules which are part
# of BASIS and whose name does not include the prefix "Basis" are not
# supposed to be included directly by a project that makes use of BASIS.
# Only the modules with the prefix "Basis" should be included directly.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeAPI
##############################################################################

# ============================================================================
# CMake version and policies
# ============================================================================

cmake_minimum_required (VERSION 2.8.4)

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
set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}" ${CMAKE_MODULE_PATH})

# The ExternalData.cmake module is yet only part of ITK.
include ("${CMAKE_CURRENT_LIST_DIR}/ExternalData.cmake")

# BASIS settings
include ("${CMAKE_CURRENT_LIST_DIR}/Settings.cmake")

# BASIS modules
include ("${CMAKE_CURRENT_LIST_DIR}/CommonTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/DocTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/InstallationTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/MatlabTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/SubversionTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/TargetTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/UtilitiesTools.cmake")

# ============================================================================
# initialize/finalize project
# ============================================================================

## @addtogroup CMakeAPI
#  @{

##############################################################################
# @brief Initialize project, calls CMake's project() command.
#
# Any BASIS project has to call this macro in the beginning of its root CMake
# configuration file. Further, the macro basis_project_finalize() has to be
# called at the end of the file.
#
# @par Project version:
# The version number consists of three components: the major version number,
# the minor version number, and the patch number. The format of the version
# string is "<major>.<minor>.<patch>", where the minor version number and
# patch number default to 0 if not given. Only digits are allowed except of
# the two separating dots.
# @n
# - A change of the major version number indicates changes of the softwares
#   @api (and @abi) and/or its behavior and/or the change or addition of major
#   features.
# - A change of the minor version number indicates changes that are not only
#   bug fixes and no major changes. Hence, changes of the @api but not the @abi.
# - A change of the patch number indicates changes only related to bug fixes
#   which did not change the softwares @api. It is the least important component
#   of the version number.
#
# @par Build settings:
# The default settings set by the Settings.cmake file of BASIS can be
# overwritten in the file Settings.cmake in the @c PROJECT_CONFIG_DIR. This file
# is included by this macro after the project was initialized and before
# dependencies on other packages were resolved.
#
# @par Dependencies:
# Dependencies on other packages should be resolved via find_package() or
# find_basis_package() commands in the Depends.cmake file which as well has to
# be located in @c PROJECT_CONFIG_DIR (note that this variable may be modified
# within the Settings.cmake file). The Depends.cmake file is included by this
# macro if present after the inclusion of the Settings.cmake file.
#
# @par Default documentation:
# Each BASIS project further has to have a README(.txt) file in the top
# directory of the software component. This file is the root documentation
# file which refers the user to the further documentation files in @c PROJECT_DOC_DIR.
# A different name for the readme file can be set in the Settings.cmake file.
# This is, however, not recommended.
# The same applies to the COPYING(.txt) file with the copyright and license
# notices which must be present in the top directory of the source tree as well.
#
# @par Miscellaneous
# As the BasisTest.cmake module has to be included after the project()
# command was used, it is not included by the CMake BASIS package use file.
# Instead, it is included by this macro.
#
# @sa basis_project_finalize()
#
# @param [in] ARGN This list is parsed for the following arguments.
#                  Moreover, any of these arguments can be specified
#                  in the file @c PROJECT_CONFIG_DIR/Settings.cmake
#                  instead with the prefix PROJECT_, e.g.,
#                  "set (PROJECT_VERSION 1.0)".
# @par
# <table border="0">
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b NAME name</td>
#     <td>The name of the project.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b VERSION major[.minor[.patch]]</td>
#     <td>Project version string. Defaults to "1.0.0"</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b DESCRIPTION description</td>
#     <td>Package description, used for packing. If multiple arguments are given,
#         they are concatenated using one space character as delimiter.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b PACKAGE_VENDOR name</td>
#     <td>The vendor of this package, used for packaging. If multiple arguments
#         are given, they are concatenated using one space character as delimiter.
#         Default: "SBIA Group at University of Pennsylvania".</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b WELCOME_FILE file</td>
#     <td>Welcome file used for installer.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b README_FILE file</td>
#     <td>Readme file. Default: @c PROJECT_SOURCE_DIR/README.txt.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b LICENSE_FILE file</td>
#     <td>File containing copyright and license notices.
#         Default: @c PROJECT_SOURCE_DIR/COPYING.txt.</td>
#   </tr>
#   <tr>
#     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#         @b REDIST_LICENSE_FILES file1 [file2 ...]</td>
#     <td>Additional license files of other packages redistributed as part
#         of this project. These licenses will be installed along with the
#         project's LICENSE_FILE. Default: All files which match the
#         regular expression "^PROJECT_SOURCE_DIR/COPYING-.+" are considered.</td>
#   </tr>
# </table>
#
# @returns Sets the following non-cached CMake variables:
# @retval DEFAULT_SOURCES        List of default auxiliary sources generated by this macro.
# @retval DEFAULT_HEADERS        List of default auxiliary headers generated by this macro.
# @retval DEFAULT_PUBLIC_HEADERS List of public default auxiliary headers
#                                generated by this macro.
# @retval PROJECT_*              Project attributes as given as arguments to this macro
#                                or set in @c PROJECT_CONFIG_DIR/Settings.cmake.
# @retval PROJECT_NAME_LOWER     Project name in all lowercase letters.
# @retval PROJECT_NAME_UPPER     Project name in all uppercase letters.
# @retval PROJECT_REVISION       Revision number of Subversion controlled source tree
#                                or 0 if the source tree is not revision controlled.
# @retval PROJECT_*_DIR          Configured and absolute paths of project source tree.
# @retval BINARY_*_DIR           Absolute paths of directories in binary tree
#                                corresponding to the @c PROJECT_*_DIR directories.
# @retval INSTALL_*_DIR          Configured paths of installation relative to INSTALL_PREFIX.

macro (basis_project_initialize)
  # set common CMake variables which would not be valid before project()
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
    basis_list_to_delimited_string (PROJECT_PACKAGE_VENDOR " " ${PROJECT_PACKAGE_VENDOR})
  else ()
    set (PROJECT_PACKAGE_VENDOR "SBIA Group at University of Pennsylvania")
  endif ()

  if (PROJECT_DESCRIPTION)
    basis_list_to_delimited_string (PROJECT_DESCRIPTION " " ${PROJECT_DESCRIPTION})
  else ()
    set (PROJECT_DESCRIPTION "")
  endif ()

  if (NOT PROJECT_AUTHORS_FILE)
    if (EXISTS "${PROJECT_SOURCE_DIR}/AUTHORS.txt")
      set (PROJECT_AUTHORS_FILE "${PROJECT_SOURCE_DIR}/AUTHORS.txt")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/AUTHORS")
      set (PROJECT_AUTHORS_FILE "${PROJECT_SOURCE_DIR}/AUTHORS")
    endif ()
  elseif (NOT EXISTS "${PROJECT_AUTHORS_FILE}")
    message (FATAL_ERROR "Specified project AUTHORS file does not exist.")
  endif ()

  if (NOT PROJECT_README_FILE)
    if (EXISTS "${PROJECT_SOURCE_DIR}/README.txt")
      set (PROJECT_README_FILE "${PROJECT_SOURCE_DIR}/README.txt")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/README")
      set (PROJECT_README_FILE "${PROJECT_SOURCE_DIR}/README")
    else ()
      message (FATAL_ERROR "Project ${PROJECT_NAME} is missing a README file.")
    endif ()
  elseif (NOT EXISTS "${PROJECT_README_FILE}")
    message (FATAL_ERROR "Specified project README file does not exist.")
  endif ()

  if (NOT PROJECT_INSTALL_FILE)
    if (EXISTS "${PROJECT_SOURCE_DIR}/INSTALL.txt")
      set (PROJECT_INSTALL_FILE "${PROJECT_SOURCE_DIR}/INSTALL.txt")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/INSTALL")
      set (PROJECT_INSTALL_FILE "${PROJECT_SOURCE_DIR}/INSTALL")
    endif ()
  elseif (NOT EXISTS "${PROJECT_INSTALL_FILE}")
    message (FATAL_ERROR "Specified project INSTALL file does not exist.")
  endif ()

  if (NOT PROJECT_LICENSE_FILE)
    if (EXISTS "${PROJECT_SOURCE_DIR}/COPYING.txt")
      set (PROJECT_LICENSE_FILE "${PROJECT_SOURCE_DIR}/COPYING.txt")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/COPYING")
      set (PROJECT_LICENSE_FILE "${PROJECT_SOURCE_DIR}/COPYING")
    else ()
      message (FATAL_ERROR "Project ${PROJECT_NAME} is missing a COPYING file.")
    endif ()
  elseif (NOT EXISTS "${PROJECT_LICENSE_FILE}")
    message (FATAL_ERROR "Specified project license file does not exist.")
  endif ()

  if (NOT PROJECT_REDIST_LICENSE_FILES)
    file (GLOB PROJECT_REDIST_LICENSE_FILES "${PROJECT_SOURCE_DIR}/COPYING-*")
  endif ()

  # start CMake project
  project ("${PROJECT_NAME}")

  set (CMAKE_PROJECT_NAME "${PROJECT_NAME}") # variable used by CPack

  # convert project name to upper and lower case only, respectively
  string (TOUPPER "${PROJECT_NAME}" PROJECT_NAME_UPPER)
  string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWER)

  # get current revision of project
  basis_svn_get_revision ("${PROJECT_SOURCE_DIR}" PROJECT_REVISION)

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
  get_filename_component (AUTHORS "${PROJECT_AUTHORS_FILE}" NAME_WE)
  get_filename_component (README  "${PROJECT_README_FILE}"  NAME_WE)
  get_filename_component (INSTALL "${PROJECT_INSTALL_FILE}" NAME_WE)
  get_filename_component (LICENSE "${PROJECT_LICENSE_FILE}" NAME_WE)

  get_filename_component (AUTHORS_EXT "${PROJECT_AUTHORS_FILE}" EXT)
  get_filename_component (README_EXT  "${PROJECT_README_FILE}"  EXT)
  get_filename_component (INSTALL_EXT "${PROJECT_INSTALL_FILE}" EXT)
  get_filename_component (LICENSE_EXT "${PROJECT_LICENSE_FILE}" EXT)

  if (WIN32)
    if (NOT AUTHORS_EXT)
      set (AUTHORS_EXT ".txt")
    endif ()
    if (NOT README_EXT)
      set (README_EXT ".txt")
    endif ()
    if (NOT INSTALL_EXT)
      set (INSTALL_EXT ".txt")
    endif ()
    if (NOT LICENSE_EXT)
      set (LICENSE_EXT ".txt")
    endif ()
  else ()
    if (AUTHORS_EXT STREQUAL ".txt")
      set (AUTHORS_EXT "")
    endif ()
    if (README_EXT STREQUAL ".txt")
      set (README_EXT "")
    endif ()
    if (INSTALL_EXT STREQUAL ".txt")
      set (INSTALL_EXT "")
    endif ()
    if (LICENSE_EXT STREQUAL ".txt")
      set (LICENSE_EXT "")
    endif ()
  endif ()

  set (AUTHORS "${AUTHORS}${AUTHORS_EXT}")
  set (README  "${README}${README_EXT}")
  set (INSTALL "${INSTALL}${INSTALL_EXT}")
  set (LICENSE "${LICENSE}${LICENSE_EXT}")

  if (NOT "${PROJECT_BINARY_DIR}" STREQUAL "${PROJECT_SOURCE_DIR}")
    configure_file ("${PROJECT_README_FILE}" "${PROJECT_BINARY_DIR}/${README}" COPYONLY)
    configure_file ("${PROJECT_LICENSE_FILE}" "${PROJECT_BINARY_DIR}/${LICENSE}" COPYONLY)
    if (PROJECT_AUTHORS_FILE)
      configure_file ("${PROJECT_AUTHORS_FILE}" "${PROJECT_BINARY_DIR}/${AUTHORS}" COPYONLY)
    endif ()
    if (PROJECT_INSTALL_FILE)
      configure_file ("${PROJECT_INSTALL_FILE}" "${PROJECT_BINARY_DIR}/${INSTALL}" COPYONLY)
    endif ()
  endif ()

  install (
    FILES       "${PROJECT_README_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
    RENAME      "${README}"
  )

  if (PROJECT_AUTHORS_FILE)
    install (
      FILES       "${PROJECT_AUTHORS_FILE}"
      DESTINATION "${INSTALL_DOC_DIR}"
      RENAME      "${AUTHORS}"
    )
  endif ()

  if (PROJECT_INSTALL_FILE)
    install (
      FILES       "${PROJECT_INSTALL_FILE}"
      DESTINATION "${INSTALL_DOC_DIR}"
      RENAME      "${INSTALL}"
    )
  endif ()

  if (IS_SUBPROJECT)
    execute_process (
      COMMAND "${CMAKE_COMMAND}"
              -E compare_files "${CMAKE_SOURCE_DIR}/${LICENSE}" "${PROJECT_LICENSE_FILE}"
      RESULT_VARIABLE INSTALL_LICENSE
    )

    if (INSTALL_LICENSE)
      if (WIN32)
        get_filename_component (LICENSE "${LICENSE}" NAME_WE)
      endif ()
      set (PROJECT_LICENSE "${LICENSE}-${PROJECT_NAME}")
      if (WIN32)
        set (PROJECT_LICENSE "${PROJECT_LICENSE}.txt")
      endif ()

      install (
        FILES       "${PROJECT_LICENSE_FILE}"
        DESTINATION "${INSTALL_DOC_DIR}"
        RENAME      "${PROJECT_LICENSE}"
      )
      file (
        APPEND "${CMAKE_BINARY_DIR}/${LICENSE}"
        "\n\n------------------------------------------------------------------------------\n"
        "See ${PROJECT_LICENSE} file for\n"
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
      RENAME      "${LICENSE}"
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

  set (AUTHORS_EXT)
  set (README_EXT)
  set (INSTALL_EXT)
  set (LICENSE_EXT)

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

##############################################################################
# @brief Finalize project build configuration.
#
# This macro has to be called at the end of the root CMakeLists.txt file of
# each BASIS project initialized by basis_project().
#
# The project configuration files are generated by including the CMake script
# PROJECT_CONFIG_DIR/GenerateConfig.cmake when this file exists or using
# the default script of BASIS.
#
# @sa basis_project_initialize()
#
# @returns Finalizes addition of custom build targets, i.e., adds the
#          custom targets which actually perform the build of these targets.
#          See basis_add_custom_finalize() function.

macro (basis_project_finalize)
  # if project uses MATLAB
  if (MATLAB_FOUND)
    basis_create_addpaths_mfile ()
  endif ()

  # finalize (super-)project
  if (NOT IS_SUBPROJECT)
    # configure constructor of ExecutableTargetInfo
    basis_configure_ExecutableTargetInfo ()
    # add standard BASH utilities
    basis_add_stdaux_bash_script ()
    # add uninstall target
    basis_add_uninstall ()

    if (INSTALL_LINKS)
      basis_install_links ()
    endif ()
  endif ()

  # finalize addition of custom targets
  #
  # Note: Should be done for each (sub-)project as the finalize functions
  #       might make use of the PROJECT_* variables.
  basis_add_custom_finalize ()

  # generate configuration files
  if (EXISTS "${PROJECT_CONFIG_DIR}/GenerateConfig.cmake")
    include ("${PROJECT_CONFIG_DIR}/GenerateConfig.cmake")
  else ()
    include ("${BASIS_MODULE_PATH}/GenerateConfig.cmake")
  endif ()

  # package software
  include ("${BASIS_MODULE_PATH}/BasisPack.cmake")
endmacro ()

## @}
