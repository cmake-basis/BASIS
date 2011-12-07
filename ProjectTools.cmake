##############################################################################
# @file  ProjectTools.cmake
# @brief Definition of main project tools.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# meta-data
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Defines project meta-data, i.e., attributes.
#
# Any BASIS project has to call this macro in the file BasisProject.cmake
# located in the top level directory of the source tree in order to define
# the project attributes required by BASIS to setup the build system.
# Moreover, if the BASIS project is a module of another BASIS project, this
# file and the variables set by this macro are used by the super-project to
# identify its modules and the dependencies among them.
#
# @par Project version:
# The version number consists of three components: the major version number,
# the minor version number, and the patch number. The format of the version
# string is "&lt;major&gt;.&lt;minor&gt;.&lt;patch&gt;", where the minor version
# number and patch number default to 0 if not given. Only digits are allowed
# except of the two separating dots.
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
# @par Dependencies:
# Dependencies on other BASIS projects, which can be subprojects of the same
# BASIS super-project, as well as dependencies on external packages such as ITK
# have to be defined here using the DEPENDS argument option. This will be used
# by a super-project to ensure that the dependencies among its subprojects are
# resolved properly. For each external dependency, the BASIS functions
# basis_find_package() and basis_use_package() are invoked by
# basis_project_initialize(). If an external package is not CMake aware and
# additional CMake code shall be executed to include the settings of the external
# package (which is usually done in a so-called Use<Pkg>.cmake file if the
# package would be CMake aware), such code should be added to the Settings.cmake
# file of the project.
#
# @param [in] ARGN This list is parsed for the following arguments:
# @par
# <table border="0">
#   <tr>
#     @tp @b NAME name @endtp
#     <td>The name of the project.</td>
#   </tr>
#   <tr>
#     @tp @b VERSION major[.minor[.patch]] @endtp
#     <td>Project version string. Defaults to "1.0.0"</td>
#   </tr>
#   <tr>
#     @tp @b DESCRIPTION description @endtp
#     <td>Package description, used for packing. If multiple arguments are given,
#         they are concatenated using one space character as delimiter.</td>
#   </tr>
#   <tr>
#     @tp @b PACKAGE_VENDOR name @endtp
#     <td>The vendor of this package, used for packaging. If multiple arguments
#         are given, they are concatenated using one space character as delimiter.
#         Default: "SBIA Group at University of Pennsylvania".</td>
#   </tr>
#   <tr>
#     @tp @b DEPENDS name[, name] @endtp
#     <td>List of dependencies, i.e., either names of other BASIS (sub)projects
#         or names of external packages.</td>
#   </tr>
#   <tr>
#     @tp @b OPTIONAL_DEPENDS name[, name] @endtp
#     <td>List of dependencies, i.e., either names of other BASIS (sub)projects
#         or names of external packages which are used only if available.</td>
#   </tr>
#   <tr>
#     @tp @b TEST_DEPENDS name[, name] @endtp
#     <td>List of dependencies, i.e., either names of other BASIS (sub)projects
#         or names of external packages which are only required by the tests.</td>
#   </tr>
#   <tr>
#     @tp @b OPTIONAL_TEST_DEPENDS name[, name] @endtp
#     <td>List of dependencies, i.e., either names of other BASIS (sub)projects
#         or names of external packages which are used only by the tests if available.</td>
#   </tr>
# </table>
#
# @returns Sets the following non-cached CMake variables:
# @retval PROJECT_NAME                    @c NAME argument.
# @retval PROJECT_VERSION                 @c VERSION argument.
# @retval PROJECT_DESCRIPTION             Concatenated @c DESCRIPTION arguments.
# @retval PROJECT_PACKAGE_VENDOR          Concatenated @c PACKAGE_VENDOR argument.
# @retval PROJECT_DEPENDS                 @c DEPENDS arguments.
# @retval PROJECT_OPTIONAL_DEPENDS        @c OPTIONAL_DEPENDS arguments.
# @retval PROJECT_TEST_DEPENDS            @c TEST_DEPENDS arguments.
# @retval PROJECT_OPTIONAL_TEST_DEPENDS   @c OPTIONAL_TEST_DEPENDS arguments.
#
# @ingroup CMakeAPI
macro (basis_project)
  # parse arguments and/or include project settings file
  CMAKE_PARSE_ARGUMENTS (
    PROJECT
      ""
      "NAME;VERSION"
      "DESCRIPTION;PACKAGE_VENDOR;DEPENDS;OPTIONAL_DEPENDS;TEST_DEPENDS;OPTIONAL_TEST_DEPENDS"
    ${ARGN}
  )

  # check required project attributes or set default values
  if (NOT PROJECT_NAME)
    message (FATAL_ERROR "basis_project(): Project name not specified!")
  endif ()
  if (NOT PROJECT_NAME MATCHES "^([a-z][a-z0-9]*|[A-Z][a-zA-Z0-9]*)")
    message (FATAL_ERROR "basis_project(): Invalid project name!\n\n"
                         "Please choose a project name with either only captial "
                         "letters in case of an acronym or a name with mixed case, "
                         "but starting with a captial letter.\n\n"
                         "Note that numbers are allowed, but not as first character. "
                         "Further, do not use characters such as '_' or '-' to "
                         "separate parts of the project name. Instead, use the "
                         "upper camel case notation "
                         "(see http://en.wikipedia.org/wiki/CamelCase#Variations_and_synonyms).")
  endif ()
  if (NOT PROJECT_IS_MODULE)
    set (BASIS_PROJECT_NAME "${PROJECT_NAME}")
  endif ()

  if (PROJECT_VERSION)
    if (NOT PROJECT_VERSION MATCHES "^[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?(rc[0-9]+|[a-z])?$")
      message (FATAL_ERROR "basis_project(): Invalid version ${PROJECT_VERSION}!")
    endif ()
    if (PROJECT_IS_MODULE)
      if (PROJECT_VERSION MATCHES "^0+(\\.0+)?(\\.0+)?$")
        set (PROJECT_VERSION "${BASIS_PROJECT_VERSION}")
      endif ()
    else ()
      set (BASIS_PROJECT_VERSION "${PROJECT_VERSION}")
    endif ()
  else ()
    if (PROJECT_IS_MODULE)
      set (PROJECT_VERSION "${BASIS_PROJECT_VERSION}")
    else ()
      message (FATAL_ERROR "basis_project(): Project version not specified!")
    endif ()
  endif ()

  if (PROJECT_DESCRIPTION)
    basis_list_to_string (PROJECT_DESCRIPTION ${PROJECT_DESCRIPTION})
  else ()
    set (PROJECT_DESCRIPTION "")
  endif ()

  if (PROJECT_PACKAGE_VENDOR)
    basis_list_to_string (PROJECT_PACKAGE_VENDOR ${PROJECT_PACKAGE_VENDOR})
    if (NOT PROJECT_IS_MODULE)
      set (BASIS_PROJECT_PACKAGE_VENDOR "${PROJECT_PACKAGE_VENDOR}")
    endif ()
  elseif (PROJECT_IS_MODULE)
    set (PROJECT_PACKAGE_VENDOR "${BASIS_PROJECT_PACKAGE_VENDOR}")
  else ()
    set (PROJECT_PACKAGE_VENDOR "SBIA Group at University of Pennsylvania")
  endif ()

  # let basis_project_impl() know that basis_project() was called
  set (BASIS_basis_project_CALLED TRUE)
endmacro ()


## @addtogroup CMakeUtilities
# @{


# ============================================================================
# initialization
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Ensure certain requirements on build tree.
#
# Requirements:
# - Root of build tree must not be root of source tree.
#
# @param [in] ARGN Not used.
#
# @returns Nothing.
macro (basis_buildtree_asserts)
  string (TOLOWER "${CMAKE_SOURCE_DIR}" SOURCE_ROOT)
  string (TOLOWER "${CMAKE_BINARY_DIR}" BUILD_ROOT)
  if ("${BUILD_ROOT}" STREQUAL "${SOURCE_ROOT}")
    message(FATAL_ERROR "This project should not be configured & build in the "
                        "source directory:\n"
                        "  ${CMAKE_SOURCE_DIR}\n"
                        "You must run CMake in a separate build directory.")
  endif()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Ensure certain requirements on install tree.
#
# Requirements:
# - Prefix must be an absolute path.
# - Install tree must be different from source and build tree.
#
# @param [in] ARGN Not used.
#
# @returns Nothing.
macro (basis_installtree_asserts)
  if (NOT IS_ABSOLUTE "${INSTALL_PREFIX}")
    message (FATAL_ERROR "INSTALL_PREFIX must be an absolute path!")
  endif ()
  string (TOLOWER "${CMAKE_SOURCE_DIR}" SOURCE_ROOT)
  string (TOLOWER "${CMAKE_BINARY_DIR}" BUILD_ROOT)
  string (TOLOWER "${INSTALL_PREFIX}"   INSTALL_ROOT)
  if ("${INSTALL_ROOT}" MATCHES "${BUILD_ROOT}|${SOURCE_ROOT}")
    message (FATAL_ERROR "The current INSTALL_PREFIX points at the source or build tree:\n"
                         "  ${INSTALL_PREFIX}\n"
                         "This is not permitted by this project. "
                         "Please choose another installation prefix."
    )
  endif()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Initialize project modules.
#
# Most parts of this macro were copied from the ITK4 project
# (http://www.vtk.org/Wiki/ITK_Release_4), in particular, the top-level
# CMakeLists.txt file. This file does not state any specific license, but
# the ITK package itself is released under the Apache License Version 2.0,
# January 2004 (http://www.apache.org/licenses/).
#
# @attention At this point, the project-specific variables have not been
#            set yet. For example, use @c CMAKE_CURRENT_SOURCE_DIR instead of
#            @c PROJECT_SOURCE_DIR.
macro (basis_project_modules)
  # --------------------------------------------------------------------------
  # reset variables
  set (PROJECT_MODULES)
  set (PROJECT_MODULES_ENABLED)
  set (PROJECT_MODULES_DISABLED)

  # --------------------------------------------------------------------------
  # load module DAG

  # glob BasisProject.cmake files in modules subdirectory
  file (
    GLOB
      MODULE_INFO_FILES
    RELATIVE
      "${CMAKE_CURRENT_SOURCE_DIR}"
      "${CMAKE_CURRENT_SOURCE_DIR}/modules/*/BasisProject.cmake"
  )

  # use function scope to avoid overwriting of this project's variables
  function (basis_module_info F)
    set (PROJECT_IS_MODULE TRUE)
    set (BASIS_basis_project_CALLED FALSE)
    include ("${CMAKE_CURRENT_SOURCE_DIR}/${F}")
    # make sure that basis_project() was called
    if (NOT BASIS_basis_project_CALLED)
      message (FATAL_ERROR "basis_module_info(): Missing basis_project() command in ${F}!")
    endif ()
    # remember dependencies
    set (${PROJECT_NAME}_DEPENDS "${PROJECT_DEPENDS}" PARENT_SCOPE)
    set (${PROJECT_NAME}_OPTIONAL_DEPENDS "${PROJECT_OPTINOAL_DEPENDS}" PARENT_SCOPE)
    set (${PROJECT_NAME}_TEST_DEPENDS "${PROJECT_TEST_DEPENDS}" PARENT_SCOPE)
    set (${PROJECT_NAME}_OPTIONAL_TEST_DEPENDS "${PROJECT_OPTIONAL_TEST_DEPENDS}" PARENT_SCOPE)
    set (${PROJECT_NAME}_DECLARED TRUE PARENT_SCOPE)
    # do not use MODULE instead of PROJECT_NAME in this function as it is not
    # set in the scope of this function but its parent scope only
    set (MODULE "${PROJECT_NAME}" PARENT_SCOPE)
  endfunction ()

  set (PROJECT_MODULES)
  foreach (F ${MODULE_INFO_FILES})
    basis_module_info (${F})
    list (APPEND PROJECT_MODULES ${MODULE})
    get_filename_component (${MODULE}_BASE ${F} PATH)
    set (MODULE_${MODULE}_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${${MODULE}_BASE}")
    # use module name as subdirectory name such that the default package
    # configuration file knows where to find the module configurations
    set (MODULE_${MODULE}_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/modules/${MODULE}")
    # help modules to find each other using basis_find_package()
    set (${MODULE}_DIR "${MODULE_${MODULE}_BINARY_DIR}")
  endforeach()
  unset (MODULE)

  # validate the module DAG to identify cyclic dependencies
  macro (basis_module_check MODULE NEEDED_BY STACK)
    if (${MODULE}_DECLARED)
      if (${MODULE}_CHECK_STARTED AND NOT ${MODULE}_CHECK_FINISHED)
        # we reached a module while traversing its own dependencies recursively
        set (MSG "")
        foreach (M ${STACK})
          set (MSG " ${M} =>${MSG}")
          if ("${M}" STREQUAL "${MODULE}")
            break ()
          endif ()
        endforeach ()
        message (FATAL_ERROR "Module dependency cycle detected:\n ${MSG} ${MODULE}")
      elseif (NOT ${MODULE}_CHECK_STARTED)
        # traverse dependencies of this module
        set (${MODULE}_CHECK_STARTED TRUE)
        foreach (D IN LISTS ${MODULE}_DEPENDS)
          basis_module_check (${D} ${MODULE} "${MODULE};${STACK}")
        endforeach ()
        set (${MODULE}_CHECK_FINISHED TRUE)
      endif ()
    endif ()
  endmacro ()

  foreach (MODULE ${PROJECT_MODULES})
    basis_module_check ("${MODULE}" "" "")
  endforeach ()

  # --------------------------------------------------------------------------
  # determine list of enabled modules

  # provide an option for all modules
  if (PROJECT_MODULES)
    option (BUILD_ALL_MODULES "Request to build all modules." OFF)
  endif ()

  # provide an option for each module
  foreach (MODULE ${PROJECT_MODULES})
    option (MODULE_${MODULE} "Request building module ${MODULE}." OFF)
    if (${MODULE}_EXCLUDE_FROM_ALL)
      set (${MODULE}_IN_ALL FALSE)
    else ()
      set (${MODULE}_IN_ALL ${BUILD_ALL_MODULES})
    endif ()
  endforeach ()

  # follow dependencies
  macro (basis_module_enable MODULE NEEDED_BY)
    if (${MODULE}_DECLARED)
      if (NOT "${NEEDED_BY}" STREQUAL "")
        list (APPEND ${MODULE}_NEEDED_BY "${NEEDED_BY}")
      endif ()
      if (NOT ${MODULE}_ENABLED)
        if ("${NEEDED_BY}" STREQUAL "")
          set (${MODULE}_NEEDED_BY)
        endif ()
        set (${MODULE}_ENABLED TRUE)
        foreach (D IN LISTS ${MODULE}_DEPENDS)
          basis_module_enable (${D} ${MODULE})
        endforeach ()
      endif ()
    endif ()
  endmacro ()

  foreach (MODULE ${PROJECT_MODULES})
    if (MODULE_${MODULE} OR ${MODULE}_IN_ALL)
      basis_module_enable ("${MODULE}" "")
    endif ()
  endforeach ()

  # build final list of enabled modules
  set (PROJECT_MODULES_ENABLED "")
  set (PROJECT_MODULES_DISABLED "")
  foreach (MODULE ${PROJECT_MODULES})
    if (${MODULE}_DECLARED)
      if (${MODULE}_ENABLED)
        list (APPEND PROJECT_MODULES_ENABLED ${MODULE})
      else ()
        list (APPEND PROJECT_MODULES_DISABLED ${MODULE})
      endif ()
    endif ()
  endforeach ()
  list (SORT PROJECT_MODULES_ENABLED) # Deterministic order.
  list (SORT PROJECT_MODULES_DISABLED) # Deterministic order.

  # order list to satisfy dependencies
  include (${BASIS_MODULE_PATH}/TopologicalSort.cmake)
  topological_sort (PROJECT_MODULES_ENABLED "" "_DEPENDS")

  # remove external dependencies
  set (L)
  foreach (MODULE ${PROJECT_MODULES_ENABLED})
    if (${MODULE}_DECLARED)
      list (APPEND L "${MODULE}")
    endif ()
  endforeach ()
  set (PROJECT_MODULES_ENABLED "${L}")
  unset (L)

  # report what will be built
  if (PROJECT_MODULES_ENABLED)
    message (STATUS "Enabled modules [${PROJECT_MODULES_ENABLED}].")
  endif ()

  # turn options ON for modules that are required by other modules
  foreach (MODULE ${PROJECT_MODULES})
    if (DEFINED MODULE_${MODULE} # there was an option for the user
        AND NOT MODULE_${MODULE} # user did not set it to ON themself
        AND NOT ${MODULE}_IN_ALL # BUILD_ALL_MODULES was not set ON
        AND ${MODULE}_NEEDED_BY) # module is needed by other module(s)
      set (MODULE_${MODULE} ON CACHE BOOL "Request building module ${MODULE}." FORCE)
      message ("Enabled module ${MODULE}, needed by [${${MODULE}_NEEDED_BY}].")
    endif ()
  endforeach ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Configure public header files.
#
# Copy public header files to build tree using the same relative paths
# as will be used for the installation. We need to use configure_file()
# here such that the header files in the build tree are updated whenever
# the source header file was modified. Moreover, this gives us a chance to
# configure header files with the .in suffix.
#
# @note This function configures also the public header files of the modules
#       already. Hence, it must not be called if this project is a module.
function (basis_configure_public_headers)
  # --------------------------------------------------------------------------
  # settings

  # log file which lists the configured header files
  set (CMAKE_FILE "${CMAKE_CURRENT_BINARY_DIR}/PublicHeaders.cmake")

  # considered extensions
  set (
    EXTENSIONS
      ".h"
      ".hh"
      ".hpp"
      ".hxx"
      ".inl"
      ".txx"
  )

  # considered include directories
  basis_get_relative_path (INCLUDE_DIR "${PROJECT_SOURCE_DIR}" "${PROJECT_INCLUDE_DIR}")
  set (INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/${INCLUDE_DIR}")
  if (NOT PROJECT_IS_MODULE AND NOT BASIS_USE_MODULE_NAMESPACES)
    # If module namespace are used, each module is taking care of its own headers.
    # Otherwise, the top-level project collects the headers and puts them into its
    # namespace. Note that INCLUDE_PREFIX is set in the BASIS Settings.cmake file.
    foreach (M IN LISTS PROJECT_MODULES_ENABLED)
      list (APPEND INCLUDE_DIRS "${MODULE_${M}_SOURCE_DIR}/${INCLUDE_DIR}")
    endforeach ()
  endif ()

  # dump currently defined CMake variables such that these can be used in .h.in files
  basis_dump_variables ("${PROJECT_BINARY_DIR}/PublicHeadersVariables.cmake")

  # --------------------------------------------------------------------------
  # clean up last run before the error because a file was added/removed

  file (REMOVE "${CMAKE_FILE}")
  file (REMOVE "${CMAKE_FILE}.tmp")
  file (REMOVE "${CMAKE_FILE}.updated")

  # --------------------------------------------------------------------------
  # configure public header files already during the configure step
  if (BASIS_VERBOSE)
    message (STATUS "Configuring public header files...")
  endif ()

  execute_process (
    COMMAND "${CMAKE_COMMAND}"
            -D "INCLUDE_FILE=${PROJECT_BINARY_DIR}/PublicHeadersVariables.cmake"
            -D "BASE_INCLUDE_DIR=${PROJECT_INCLUDE_DIR}"
            -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
            -D "BINARY_INCLUDE_DIR=${BINARY_INCLUDE_DIR}"
            -D "INCLUDE_PREFIX=${INCLUDE_PREFIX}"
            -D "EXTENSIONS=${EXTENSIONS}"
            -D "CMAKE_FILE=${CMAKE_FILE}"
            -D "VARIABLE_NAME=PUBLIC_HEADERS"
            -P "${BASIS_MODULE_PATH}/ConfigureIncludeFiles.cmake"
    RESULT_VARIABLE RT
  )

  if (RT EQUAL 0)
    execute_process (
      COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_FILE}.updated"
    )
  else ()
    message (FATAL_ERROR "Failed to configure public header files!")
  endif ()

  if (NOT EXISTS "${CMAKE_FILE}")
    message (FATAL_ERROR "File ${CMAKE_FILE} not generated as it should have been!")
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Configuring public header files... - done")
  endif ()

  # We need a list of the configured files to add them as dependency of the
  # custom build targets such that these get re-build whenever a file changed.
  # Additionally, including this file here which is modified whenever a
  # header file is added or removed triggeres a re-configuration of the
  # build system which is required to re-execute this function and adjust
  # these custom build targets.

  include ("${CMAKE_FILE}")

  # --------------------------------------------------------------------------
  # check if any header was added or removed (always out-of-date)

  # error message displayed when a file was added or removed which requires
  # a reconfiguration of the build system
  set (ERRORMSG "You have either added, removed, or renamed a public header file. "
                "Therefore, the build system needs to be re-configured. "
                "Either try to build again which will trigger CMake to "
                "re-configure the build system or run CMake manually.")
  basis_list_to_string (ERRORMSG ${ERRORMSG})

  # custom command which globs the files in the project's include directory
  add_custom_command (
    OUTPUT  "${CMAKE_FILE}.tmp"
    COMMAND "${CMAKE_COMMAND}"
            -D "BASE_INCLUDE_DIR=${PROJECT_INCLUDE_DIR}"
            -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
            -D "BINARY_INCLUDE_DIR=${BINARY_INCLUDE_DIR}"
            -D "INCLUDE_PREFIX=${INCLUDE_PREFIX}"
            -D "EXTENSIONS=${EXTENSIONS}"
            -D "CMAKE_FILE=${CMAKE_FILE}.tmp"
            -D "VARIABLE_NAME=PUBLIC_HEADERS"
            -D "PREVIEW=TRUE" # do not actually configure the files
            -P "${BASIS_MODULE_PATH}/ConfigureIncludeFiles.cmake"
    COMMENT "Checking if public header files were added or removed"
    VERBATIM
  )

  # custom target to detect whether a file was added or removed
  basis_make_target_uid (CHECK_HEADERS_TARGET headers_check)
  add_custom_target (
    ${CHECK_HEADERS_TARGET}
    # trigger execution of custom command that generates the list
    # of current files in the project's include directory
    DEPENDS "${CMAKE_FILE}.tmp"
    # compare current list of header to list of previously configured files
    # if the lists differ, remove the CMAKE_FILE which was included in
    # this function such that CMake re-configures the build system
    COMMAND "${CMAKE_COMMAND}"
            -D "OUTPUT_FILE=${CMAKE_FILE}"
            -D "REFERENCE_FILE=${CMAKE_FILE}.tmp"
            -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
            -D "BINARY_INCLUDE_DIR=${BINARY_INCLUDE_DIR}"
            -D "INCLUDE_PREFIX=${INCLUDE_PREFIX}"
            -D "ERRORMSG=${ERRORMSG}"
            -P "${BASIS_MODULE_PATH}/CheckPublicHeaders.cmake"
    # remove temporary file again to force its regeneration
    COMMAND "${CMAKE_COMMAND}" -E remove "${CMAKE_FILE}.tmp"
    VERBATIM
  )

  # --------------------------------------------------------------------------
  # add build command to re-configure public header files
  if (PUBLIC_HEADERS)
    add_custom_command (
      OUTPUT  "${CMAKE_FILE}.updated" # do not use same file as included
                                      # before otherwise CMake will re-configure
                                      # the build system next time
      COMMAND "${CMAKE_COMMAND}"
              -D "INCLUDE_FILE=${PROJECT_BINARY_DIR}/PublicHeadersVariables.cmake"
              -D "BASE_INCLUDE_DIR=${PROJECT_INCLUDE_DIR}"
              -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
              -D "BINARY_INCLUDE_DIR=${BINARY_INCLUDE_DIR}"
              -D "INCLUDE_PREFIX=${INCLUDE_PREFIX}"
              -D "EXTENSIONS=${EXTENSIONS}"
              -P "${BASIS_MODULE_PATH}/ConfigureIncludeFiles.cmake"
      COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_FILE}.updated"
      DEPENDS ${PUBLIC_HEADERS}
      COMMENT "Configuring public header files"
      VERBATIM
    )

    basis_make_target_uid (CONFIGURE_HEADERS_TARGET headers)
    add_custom_target (
      ${CONFIGURE_HEADERS_TARGET} ALL
      DEPENDS ${CHECK_HEADERS_TARGET} "${CMAKE_FILE}.updated"
      SOURCES ${PUBLIC_HEADERS}
    )
  endif ()

  # --------------------------------------------------------------------------
  # add directory of configured headers to include search path
  basis_include_directories (BEFORE "${BINARY_INCLUDE_DIR}")

  # Attention: BASIS includes public header files which are named the
  #            same as system-wide header files. Therefore, avoid to add
  #            include/sbia/basis/ to the include search path.
  if (NOT PROJECT_NAME MATCHES "^BASIS$")
    basis_include_directories (BEFORE "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Configure root documentation files.
#
# The root documentation files are located in the top-level directory of the
# project's source tree. These are, in particular, the
# * @c AUTHORS.txt file with information on the authors of the software,
# * @c COPYING.txt file with copyright and licensing information,
# * @c README.txt file,
# * @c INSTALL.txt file with build and installation instructions,
# * @c WELCOME.txt file with text used as welcome text of the installer.
# where the top-level project requires all of these files except of the
# @c WELCOME.txt file which defaults to the readme file. Modules of a project
# usually do not include any of these files. Otherwise, the content of the
# module's documentation file is appended to the corresponding file of the
# top-level project.
macro (basis_configure_root_documentation_files)
  foreach (F AUTHORS COPYING README INSTALL WELCOME)
    if (EXISTS "${PROJECT_SOURCE_DIR}/${F}.txt")
      set (PROJECT_${F}_FILE "${PROJECT_SOURCE_DIR}/${F}.txt")
      if (PROJECT_IS_MODULE)
        file (READ "${PROJECT_${F}_FILE}" T)
        file (
          APPEND "${BASIS_PROJECT_${F}_FILE}"
          "\n\n\n"
          "------------------------------------------------------------------------------\n"
          "${PROJECT_NAME} Module\n"
          "------------------------------------------------------------------------------\n"
          "${T}"
        )
      else ()
        set (BASIS_PROJECT_${F}_FILE "${PROJECT_BINARY_DIR}/${F}.txt")
        # do not use configure_file() to copy the file, otherwise CMake will
        # update the build system only because we modified this file in the if-clause
        execute_process (COMMAND "${CMAKE_COMMAND}" -E copy "${PROJECT_${F}_FILE}" "${BASIS_PROJECT_${F}_FILE}")
        # use extension on Windows, but leave it out on Unix
        get_filename_component (N "${F}" NAME_WE)
        get_filename_component (E "${F}" EXT)
        if (WIN32)
          if (NOT E)
            set (E ".txt")
          endif ()
        else ()
          if ("${E}" STREQUAL ".txt")
            set (E "")
          endif ()
        endif ()
        set (N "${N}${E}")
        # install file
        install (
          FILES       "${PROJECT_BINARY_DIR}/${F}.txt"
          DESTINATION "${INSTALL_DOC_DIR}"
          RENAME      "${N}"
          OPTIONAL
        )
      endif ()
    elseif (NOT F MATCHES "WELCOME" AND NOT PROJECT_IS_MODULE)
      message (FATAL_ERROR "Project requires a ${F}.txt file in ${PROJECT_SOURCE_DIR}!")
    endif ()
  endforeach ()
endmacro ()

# ----------------------------------------------------------------------------
## @brief Initialize project, calls CMake's project() command.
#
# @par Default documentation:
# Each BASIS project has to have a README.txt file in the top directory of the
# software component. This file is the root documentation file which refers the
# user to the further documentation files in @c PROJECT_DOC_DIR.
# The same applies to the COPYING.txt file with the copyright and license
# notices which must be present in the top directory of the source tree as well.
#
# @sa basis_project()
# @sa basis_project_impl()
#
# @returns Sets the following non-cached CMake variables:
# @retval PROJECT_NAME_LOWER             Project name in all lowercase letters.
# @retval PROJECT_NAME_UPPER             Project name in all uppercase letters.
# @retval PROJECT_NAME_INFIX             Project name used as infix for installation
#                                        directories and namespace identifiers.
#                                        In particular, the project name in either
#                                        all lowercase or mixed case starting with
#                                        an uppercase letter depending on whether
#                                        the @c PROJECT_NAME has mixed case or not.
# @retval PROJECT_REVISION               Revision number of Subversion controlled
#                                        source tree or 0 if the source tree is
#                                        not under revision control.
# @retval PROJECT_VERSION_AND_REVISION   A string of project version and revision
#                                        that can be used for the output of
#                                        version information. The format of this
#                                        string is either one of the following:
#                                          - "version 1.0.0 (revision 42)"
#                                          - "version 1.0.0" (if revision unknown)
#                                          - "revision 42" (if version is 0.0.0)
#                                          - "version unknown" (otherwise)
macro (basis_project_initialize)
  # --------------------------------------------------------------------------
  # Slicer extension

  # Unfortunately, Slicer invokes the project() command in the SlicerConfig.cmake
  # file. Furthermore, it must be the first package to be included. Therefore,
  # scan dependencies for Slicer, which is an indicator that this project is
  # an extension for Slicer and look for it here already.

  list (FIND PROJECT_DEPENDS "Slicer" IDX)
  if (IDX EQUAL -1)
    # A module that only optionally can be a Slicer Extension by itself
    # shall not be build as Slicer Extension if this project is not an
    # extension for Slicer. Only a project can be a Slicer Extension.
    if (NOT PROJECT_IS_MODULE)
      list (FIND PROJECT_OPTIONAL_DEPENDS "Slicer" IDX)
      if (NOT IDX EQUAL -1)
        basis_find_package ("Slicer" QUIET)
        if (Slicer_FOUND)
          basis_use_package ("Slicer")
        endif ()
      endif ()
    endif ()
  else ()
    # If a module requires Slicer, the top-level project must be a
    # Slicer Extension and hence specify Slicer as a dependency.
    if (PROJECT_IS_MODULE AND NOT Slicer_FOUND)
      message (FATAL_ERROR "Module ${PROJECT_NAME} requires Slicer, which "
                           "indicates it is a Slicer Extension. Therefore, "
                           "the top-level project must be a Slicer Extension "
                           "as well and declare Slicer as a dependency such "
                           "that the configuration file of the Slicer package "
                           "is included before the modules are being configured.")
    endif ()
    basis_find_package ("Slicer" REQUIRED)
    if (Slicer_FOUND)
      basis_use_package ("Slicer")
    else ()
      message (FATAL_ERROR "Package Slicer not found!")
      return ()
    endif ()
  endif ()

  # --------------------------------------------------------------------------
  # project()

  # note that in particular SlicerConfig.cmake will invoke project() by itself
  if (NOT PROJECT_SOURCE_DIR OR NOT "${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    project ("${PROJECT_NAME}")
  endif ()

  set (CMAKE_PROJECT_NAME "${PROJECT_NAME}") # variable used by CPack

  # convert project name to upper and lower case only, respectively
  string (TOUPPER "${PROJECT_NAME}" PROJECT_NAME_UPPER)
  string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWER)

  # This variable is in particular used in the Directories.cmake.in template
  # file to separate the files of modules of a project from each other
  # if BASIS_USE_MODULE_NAMESPACES is set to ON.
  if (WINDOWS)
    # Windows users prefer mixed case directory names
    set (PROJECT_NAME_INFIX "${PROJECT_NAME}")
  else ()
    # Unix users often prefer lowercase directory names
    set (PROJECT_NAME_INFIX "${PROJECT_NAME_LOWER}")
  endif ()

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

  # version information string
  if (PROJECT_VERSION MATCHES "^0+(\\.0+)?(\\.0+)?")
    if (PROJECT_REVISION)
      set (PROJECT_VERSION_AND_REVISION "revision ${PROJECT_REVISION}")
    else ()
      if (UNIX)
        execute_process (
          COMMAND "date" -u "+%Y.%m.%d (%H:%M UTC)"
          RESULT_VARIABLE RT
          OUTPUT_VARIABLE BUILD
          ERROR_QUIET
          OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if (RT EQUAL 0)
          set (PROJECT_VERSION_AND_REVISION "build ${BUILD}")
        else ()
          set (PROJECT_VERSION_AND_REVISION "version unknown")
        endif ()
      else ()
        set (PROJECT_VERSION_AND_REVISION "version unknown")
      endif ()
    endif ()
  else ()
    set (PROJECT_VERSION_AND_REVISION "version ${PROJECT_VERSION}")
    if (PROJECT_REVISION)
      set (PROJECT_VERSION_AND_REVISION "${PROJECT_VERSION_AND_REVISION} (revision ${PROJECT_REVISION})")
    endif ()
  endif ()

  # version number for use in Perl modules
  set (PROJECT_VERSION_PERL "${PROJECT_VERSION_MAJOR}")
  if (PROJECT_VERSION_MAJOR LESS 10)
    set (PROJECT_VERSION_PERL "${PROJECT_VERSION_PERL}.0${PROJECT_VERSION_MINOR}")
  else ()
    set (PROJECT_VERSION_PERL "${PROJECT_VERSION_PERL}.${PROJECT_VERSION_MINOR}")
  endif ()
  if (PROJECT_VERSION_PATCH LESS 10)
    set (PROJECT_VERSION_PERL "${PROJECT_VERSION_PERL}_0${PROJECT_VERSION_PATCH}")
  else ()
    set (PROJECT_VERSION_PERL "${PROJECT_VERSION_PERL}_${PROJECT_VERSION_PATCH}")
  endif ()

  # print project information
  if (BASIS_VERBOSE AND NOT PROJECT_IS_MODULE)
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

  # --------------------------------------------------------------------------
  # settings

  # configure and include BASIS directory structure
  configure_file (
    "${BASIS_MODULE_PATH}/Directories.cmake.in"
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Directories.cmake"
    @ONLY
  )

  include ("${PROJECT_BINARY_DIR}/${PROJECT_NAME}Directories.cmake")

  # include project specific settings
  #
  # This file enables the project to modify the default behavior of BASIS,
  # but only if BASIS allows so as the BASIS settings are included afterwards.
  if (EXISTS "${PROJECT_CONFIG_DIR}/Settings.cmake.in")
    configure_file (
      "${PROJECT_CONFIG_DIR}/Settings.cmake.in"
      "${BINARY_CONFIG_DIR}/Settings.cmake"
      @ONLY
    )
    include ("${BINARY_CONFIG_DIR}/Settings.cmake" NO_POLICY_SCOPE)
  else ()
    include ("${PROJECT_CONFIG_DIR}/Settings.cmake" NO_POLICY_SCOPE OPTIONAL)
  endif ()

  # configure and include BASIS settings
  configure_file (
    "${BASIS_MODULE_PATH}/Settings.cmake.in"
    "${BINARY_CONFIG_DIR}/BasisSettings.cmake"
    @ONLY
  )

  include ("${BINARY_CONFIG_DIR}/BasisSettings.cmake" NO_POLICY_SCOPE)
endmacro ()

# ----------------------------------------------------------------------------
## @brief Find packages this project depends on.
macro (basis_find_packages)
  # Attention: This function is used before the Directories.cmake.in and
  #            Settings.cmake.in files were configured and included.
  set (PROJECT_CONFIG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/config")

  # --------------------------------------------------------------------------
  # add project config directory to CMAKE_MODULE_PATH
  set (CMAKE_MODULE_PATH "${PROJECT_CONFIG_DIR}" ${CMAKE_MODULE_PATH})

  # --------------------------------------------------------------------------
  # Depends.cmake

  # This file is in particular of interest if a dependency is required if
  # certain modules are enabled, but not others.
  #
  # For example, if a module is a Slicer extension which integrates the tools
  # of other modules as extension for Slicer, the package configuration of
  # Slicer has to be included first and hence, in this case Slicer must be
  # added as dependency of the top-level project. Not so, however, if the Slicer
  # extension module is not enabled. Thus, the top-level project can look for
  # Slicer using basis_find_package() only if the Slicer Extension module
  # is enabled. It can check for this using the variable <Module>_ENABLED or
  # the list PROJECT_MODULES_ENABLED.

  # Attention: This function is used before the Directories.cmake.in and
  #            Settings.cmake.in files were configured and included.
  include ("${PROJECT_CONFIG_DIR}/Depends.cmake" OPTIONAL)

  # --------------------------------------------------------------------------
  # required dependencies
  foreach (P IN LISTS PROJECT_DEPENDS)
    if ("${P}" STREQUAL "Slicer")
      if (NOT EXTENSION_NAME)
        set (EXTENSION_NAME "${PROJECT_NAME}")
      endif ()
    endif ()
    basis_find_package ("${P}" REQUIRED)
    string (TOUPPER "${P}" U)
    if (${P}_FOUND OR ${U}_FOUND)
      basis_use_package ("${P}")
    else ()
      if (BASIS_DEBUG)
        basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterFind${P}.cmake")
      endif ()
      message (FATAL_ERROR "Package ${P} not found!")
    endif ()
  endforeach ()

  # --------------------------------------------------------------------------
  # optional dependencies
  foreach (P IN LISTS PROJECT_OPTIONAL_DEPENDS)
    if ("${P}" STREQUAL "Slicer")
      if (NOT EXTENSION_NAME)
        set (EXTENSION_NAME "${PROJECT_NAME}")
      endif ()
    endif ()
    basis_find_package ("${P}" QUIET)
    string (TOUPPER "${P}" U)
    if (${P}_FOUND OR ${U}_FOUND)
      basis_use_package ("${P}")
    endif ()
  endforeach ()

  # --------------------------------------------------------------------------
  # test dependencies
  if (BUILD_TESTING)
    foreach (P IN LISTS PROJECT_TEST_DEPENDS)
      basis_find_package ("${P}")
      string (TOUPPER "${P}" U)
      if (${P}_FOUND OR ${U}_FOUND)
        basis_use_package ("${P}")
      else ()
        if (BASIS_DEBUG)
          basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterFind${P}.cmake")
        endif ()
        message (FATAL_ERROR "Could not find package ${P}! It is required by "
                             "the tests of ${PROJECT_NAME}. Either specify "
                             "package location manually and try again or "
                             "disable testing by setting BUILD_TESTING to OFF.")
      endif ()
    endforeach ()
  endif ()

  # --------------------------------------------------------------------------
  # optional test dependencies
  if (BUILD_TESTING)
    foreach (P IN LISTS PROJECT_OPTIONAL_TEST_DEPENDS)
      basis_find_package ("${P}" QUIET)
      string (TOUPPER "${P}" U)
      if (${P}_FOUND OR ${U}_FOUND)
        basis_use_package ("${P}")
      endif ()
    endforeach ()
  endif ()
endmacro ()

# ============================================================================
# finalization
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Finalize build configuration of project.
#
# This macro has to be called at the end of the root CMakeLists.txt file of
# each BASIS project initialized by basis_project().
#
# The project configuration files are generated by including the CMake script
# PROJECT_CONFIG_DIR/GenerateConfig.cmake when this file exists or using
# the default script of BASIS.
#
# @returns Finalizes addition of custom build targets, i.e., adds the
#          custom targets which actually perform the build of these targets.
#          See basis_add_custom_finalize() function.
#
# @sa basis_project_initialize()
macro (basis_project_finalize)
  # write convenience file to setup MATLAB environment
  if (MATLAB_FOUND)
    basis_create_addpaths_mfile ()
  endif ()

  # --------------------------------------------------------------------------
  # module

  if (PROJECT_IS_MODULE)

    # finalize addition of custom targets
    #
    # Note: Should be done for each module as the finalize functions
    #       might use the PROJECT_* variables.
    basis_add_custom_finalize ()
    # generate configuration files
    include ("${BASIS_MODULE_PATH}/GenerateConfig.cmake")

  # --------------------------------------------------------------------------
  # project

  else ()

    # install public headers
    install (
      DIRECTORY   "${BINARY_INCLUDE_DIR}/"
      DESTINATION "${INSTALL_INCLUDE_DIR}"
      OPTIONAL
      PATTERN     ".svn" EXCLUDE
      PATTERN     ".git" EXCLUDE
    )
    # "parse" public header files to check if C++ BASIS utilities are included
    if (BASIS_UTILITIES_PUBLIC_HEADERS)
      set (PUBLIC_HEADERS)
      if (PROJECT_INCLUDE_DIR AND NOT BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES)
        file (GLOB_RECURSE PUBLIC_HEADERS "${PROJECT_INCLUDE_DIR}/*.h")
      endif ()
      set (REGEX)
      foreach (P ${BASIS_UTILITIES_PUBLIC_HEADERS})
        basis_get_relative_path (H "${BINARY_INCLUDE_DIR}" "${P}")
        if (NOT REGEX)
          set (REGEX "#include +[<\"](${H}")
        else ()
          set (REGEX "${REGEX}|${H}")
        endif ()
      endforeach ()
      if (REGEX AND PUBLIC_HEADERS)
        set (REGEX "${REGEX})[>\"]")
        foreach (P ${PUBLIC_HEADERS})
          file (READ "${P}" C)
          if (C MATCHES "${REGEX}")
            set (BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES TRUE)
            break ()
          endif ()
        endforeach ()
      endif ()
      # install public headers of C++ utilities
      if (BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES)
        install (
          FILES       ${BASIS_UTILITIES_PUBLIC_HEADERS}
          DESTINATION "${INSTALL_INCLUDE_DIR}/sbia/${PROJECT_NAME_LOWER}"
          COMPONENT   "${BASIS_LIBRARY_COMPONENT}"
        )
      endif ()
    endif ()
    # inherit PROJECT_USES_*_UTILITIES properties from modules
    foreach (L IN ITEMS PYTHON PERL BASH)
      foreach (M IN LISTS PROJECT_MODULES_ENABLED)
        basis_get_project_property (P ${M} PROJECT_USES_${L}_UTILITIES)
        if (P)
          basis_set_project_property (PROPERTY PROJECT_USES_${L}_UTILITIES TRUE)
          break ()
        endif ()
      endforeach ()
    endforeach ()
    # configure auxiliary modules
    basis_configure_auxiliary_modules ()
    # configure ExecutableTargetInfo modules
    basis_configure_ExecutableTargetInfo ()
    # finalize addition of custom targets
    basis_add_custom_finalize ()
    # generate configuration files
    include ("${BASIS_MODULE_PATH}/GenerateConfig.cmake")
    # package software
    include ("${BASIS_MODULE_PATH}/BasisPack.cmake")

  endif ()
endmacro ()


## @}
# end of Doxygen group

# ============================================================================
# root CMakeLists.txt implementation
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Implementation of root CMakeLists.txt file of BASIS project.
#
# This macro implements the entire logic of the top-level CMakeLists.txt file.
# At first, the project is initialized and the BASIS settings configured using
# the project information given in the BasisProject.cmake file which must be
# located in the same directory. The, the code in the CMakeLists.txt files
# in the subdirectories is executed in order. At the end, the configuration
# of the build system is finalized, including in particular also the addition
# of custom build targets which perform the actual build of custom build
# targets such as the ones build using the MATLAB Compiler.
#
# @sa BasisProject.cmake
# @sa basis_project()
#
# @ingroup CMakeAPI
macro (basis_project_impl)
  # --------------------------------------------------------------------------
  # CMake version and policies
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

  # --------------------------------------------------------------------------
  # reset

  # only set if not set by top-level project before configuring a module
  basis_set_if_empty (PROJECT_IS_MODULE FALSE)

  # hide it here to avoid that it shows up in the GUI on error
  set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE INTERNAL "" FORCE)

  # --------------------------------------------------------------------------
  # project meta-data
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/BasisProject.cmake")
    set (BASIS_basis_project_CALLED FALSE)
    include ("${CMAKE_CURRENT_SOURCE_DIR}/BasisProject.cmake")
    if (NOT BASIS_basis_project_CALLED)
      message (FATAL_ERROR "Missing basis_project() command in BasisProject.cmake!")
    endif ()
  else ()
    message (FATAL_ERROR "Missing BasisProject.cmake file!")
  endif ()

  # --------------------------------------------------------------------------
  # reset project properties - *after* PROJECT_NAME was set

  # The following variables are used across BASIS macros and functions. They
  # in particular remember information added by one function or macro which
  # is required by another function or macro.
  #
  # These variables need to be properties such that they can be set in
  # subdirectories. Moreover, they have to be assigned with the project's
  # root source directory such that a super-project's properties are restored
  # after this subproject is finalized such that the super-project itself can
  # be finalized properly.
  #
  # Attention: In particular the IMPORTED_* properties are already used
  #            during the import of targets when including the use files of
  #            external packages. Hence, this property has to be reset before.

  # see basis_add_imported_target()
  basis_set_project_property (PROPERTY IMPORTED_TARGETS "")
  basis_set_project_property (PROPERTY IMPORTED_TYPES "")
  basis_set_project_property (PROPERTY IMPORTED_LOCATIONS "")
  basis_set_project_property (PROPERTY IMPORTED_RANKS "")
  # see basis_include_directories()
  basis_set_project_property (PROPERTY PROJECT_INCLUDE_DIRS "")
  # see add_executable(), add_library()
  basis_set_project_property (PROPERTY TARGETS "")
  # see basis_add_*() functions
  basis_set_project_property (PROPERTY EXPORT_TARGETS "")
  basis_set_project_property (PROPERTY CUSTOM_EXPORT_TARGETS "")
  basis_set_project_property (PROPERTY TEST_EXPORT_TARGETS "")
  # see basis_add_script()
  basis_set_project_property (PROPERTY PROJECT_USES_PYTHON_UTILITIES FALSE)
  basis_set_project_property (PROPERTY PROJECT_USES_PERL_UTILITIES   FALSE)
  basis_set_project_property (PROPERTY PROJECT_USES_BASH_UTILITIES   FALSE)
  # yet unused
  basis_set_project_property (PROPERTY PROJECT_USES_JAVA_UTILITIES   FALSE)
  basis_set_project_property (PROPERTY PROJECT_USES_MATLAB_UTILITIES FALSE)

  # --------------------------------------------------------------------------
  # load information of modules
  if (NOT PROJECT_IS_MODULE)
    basis_project_modules ()
  endif ()

  if (BASIS_DEBUG)
    basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterDetectionOfModules.cmake")
  endif ()

  # --------------------------------------------------------------------------
  # find packages

  # any package use file must be included after PROJECT_NAME was set as the
  # imported targets are added to the <Project>_TARGETS property using
  # basis_set_project_property() in add_executable() and add_library()
  if (BASIS_USE_FILE)
    include ("${BASIS_USE_FILE}" NO_POLICY_SCOPE)
  endif ()
  basis_find_packages ()

  if (BASIS_DEBUG)
    basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterFindDependencies.cmake")
  endif ()

  # --------------------------------------------------------------------------
  # initialize project
  basis_project_initialize ()

  # --------------------------------------------------------------------------
  # assertions
  basis_buildtree_asserts ()
  basis_installtree_asserts ()

  # --------------------------------------------------------------------------
  # root documentation files
  basis_configure_root_documentation_files ()

  # --------------------------------------------------------------------------
  # enable testing
  if (NOT PROJECT_IS_MODULE)
    include ("${BASIS_MODULE_PATH}/BasisTest.cmake")
    basis_disable_testing_if_no_tests ()
  endif ()

  # --------------------------------------------------------------------------
  # public header files
  basis_include_directories (BEFORE "${PROJECT_CODE_DIR}")
  if (NOT PROJECT_IS_MODULE OR BASIS_USE_MODULE_NAMESPACES)
    basis_configure_public_headers ()
  endif ()

  # --------------------------------------------------------------------------
  # pre-configure C++ utilities
  if (NOT PROJECT_IS_MODULE)
    basis_configure_auxiliary_sources (
      BASIS_UTILITIES_SOURCES
      BASIS_UTILITIES_HEADERS
      BASIS_UTILITIES_PUBLIC_HEADERS
    )

    basis_use_auxiliary_sources (
      BASIS_UTILITIES_SOURCES
      BASIS_UTILITIES_HEADERS
    )
  endif ()

  # --------------------------------------------------------------------------
  # top-level project settings
  if (NOT PROJECT_IS_MODULE)
    # used to only build one global BASIS utilities library for all modules
    set (BASIS_PROJECT_NAME            "${PROJECT_NAME}")
    set (BASIS_PROJECT_NAMESPACE_CMAKE "${PROJECT_NAMESPACE_CMAKE}")
    set (BASIS_BINARY_ARCHIVE_DIR      "${BINARY_ARCHIVE_DIR}")
    set (BASIS_INSTALL_ARCHIVE_DIR     "${INSTALL_ARCHIVE_DIR}")
  endif ()

  # --------------------------------------------------------------------------
  # subdirectories
  if (BASIS_DEBUG)
    basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterInitialization.cmake")
  endif ()

  # build modules
  if (NOT PROJECT_IS_MODULE)
    foreach (MODULE IN LISTS PROJECT_MODULES_ENABLED)
      if (BASIS_VERBOSE)
        message (STATUS "Configuring module ${MODULE}...")
      endif ()
      set (PROJECT_IS_MODULE TRUE)
      add_subdirectory ("${MODULE_${MODULE}_SOURCE_DIR}" "${MODULE_${MODULE}_BINARY_DIR}")
      set (PROJECT_IS_MODULE FALSE)
      if (BASIS_VERBOSE)
        message (STATUS "Configuring module ${MODULE}... - done")
      endif ()
    endforeach ()
  endif ()

  # build source code
  if (EXISTS "${PROJECT_CODE_DIR}")
    add_subdirectory ("${PROJECT_CODE_DIR}")
  endif ()

  # install auxiliary data files
  if (EXISTS "${PROJECT_DATA_DIR}")
    add_subdirectory ("${PROJECT_DATA_DIR}")
  endif ()

  # build/install package documentation
  if (EXISTS "${PROJECT_DOC_DIR}" AND BUILD_DOCUMENTATION)
    add_subdirectory ("${PROJECT_DOC_DIR}")
  endif ()

  # build/install example application
  if (EXISTS "${PROJECT_EXAMPLE_DIR}" AND BUILD_EXAMPLE)
    add_subdirectory ("${PROJECT_EXAMPLE_DIR}")
  endif ()

  # build software tests
  if (EXISTS "${PROJECT_TESTING_DIR}" AND BUILD_TESTING)
   add_subdirectory ("${PROJECT_TESTING_DIR}")
  endif ()

  if (BASIS_DEBUG)
    basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterSubdirectories.cmake")
  endif ()

  # --------------------------------------------------------------------------
  # finalize
  basis_project_finalize ()

  # install symbolic links
  if (INSTALL_LINKS)
    basis_install_links ()
    # documentation
    # Note: Not all CPack generators preserve symbolic links to directories
    # Note: This is not part of the filesystem hierarchy standard of Linux,
    #       but of the standard of certain distributions including Ubuntu.
    #if (NOT PROJECT_IS_MODULE AND INSTALL_SINFIX AND BASIS_INSTALL_SINFIX)
    #  basis_install_link (
    #    "${INSTALL_DOC_DIR}"
    #    "share/doc/${BASIS_INSTALL_SINFIX}"
    #  )
    #endif ()
  endif ()

  if (NOT PROJECT_IS_MODULE)
    # add uninstall target
    basis_add_uninstall ()
    # add code to generate uninstaller at the end of the installation
    #
    # Attention: This must be done at last and using a add_subdirector() call
    #            such that the code is executed by the root cmake_install.cmake
    #            at last!
    add_subdirectory ("${BASIS_MODULE_PATH}/uninstall" "${PROJECT_BINARY_DIR}/uninstall")
  endif ()

  if (BASIS_DEBUG)
    basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterFinalization.cmake")
  endif ()
endmacro ()
