##############################################################################
# @file  ProjectTools.cmake
# @brief Definition of main project tools.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# meta-data
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Check meta-data and set defaults.
#
# @sa basis_project()
# @sa basis_slicer_module()
macro (basis_project_check_metadata)
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

# ----------------------------------------------------------------------------
## @brief Define project meta-data, i.e., attributes.
#
# Any BASIS project has to call this macro in the file BasisProject.cmake
# located in the top level directory of the source tree in order to define
# the project attributes required by BASIS to setup the build system.
# Moreover, if the BASIS project is a module of another BASIS project, this
# file and the variables set by this macro are used by the top-level project to
# identify its modules and the dependencies among them.
#
# @par Project version:
# The version number consists of three components: the major version number,
# the minor version number, and the patch number. The format of the version
# string is "<major>.<minor>.<patch>", where the minor version number and patch
# number default to "0" if not given. Only digits are allowed except of the two
# separating dots.
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
# BASIS top-level project, as well as dependencies on external packages such as ITK
# have to be defined here using the @p DEPENDS argument option. This will be used
# by a top-level project to ensure that the dependencies among its subprojects are
# resolved properly. For each external dependency, the BASIS functions
# basis_find_package() and basis_use_package() are invoked by
# basis_project_initialize(). If an external package is not CMake aware and
# additional CMake code shall be executed to include the settings of the external
# package (which is usually done in a so-called <tt>Use&lt;Pkg&gt;.cmake</tt> file
# if the package would be CMake aware), such code should be added to the
# <tt>Settings.cmake</tt> file of the project.
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
  CMAKE_PARSE_ARGUMENTS (
    PROJECT
      ""
      "${BASIS_METADATA_LIST_SINGLE}"
      "${BASIS_METADATA_LIST_MULTI}"
    ${ARGN}
  )
  basis_project_check_metadata ()
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
  if ("${INSTALL_ROOT}" STREQUAL "${BUILD_ROOT}" OR "${INSTALL_ROOT}" STREQUAL "${SOURCE_ROOT}")
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
    # remember if module depends on Slicer - used by basis_find_packages()
    if (PROJECT_IS_SLICER_MODULE)
      foreach (_D IN LISTS BASIS_SLICER_METADATA_LIST)
          if (DEFINED PROJECT_${_D})
            set (${PROJECT_NAME}_${_D} "${PROJECT_${_D}}" PARENT_SCOPE)
          endif ()
      endforeach ()
      set (${PROJECT_NAME}_IS_SLICER_MODULE TRUE PARENT_SCOPE)
    else ()
      set (${PROJECT_NAME}_IS_SLICER_MODULE FALSE PARENT_SCOPE)
    endif ()
    # do not use MODULE instead of PROJECT_NAME in this function as it is not
    # set in the scope of this function but its parent scope only
    set (MODULE "${PROJECT_NAME}" PARENT_SCOPE)
  endfunction ()

  set (PROJECT_MODULES)
  foreach (F IN LISTS MODULE_INFO_FILES)
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
# Configure public header files whose file name ends with the .in.
# Moreover, if @c BASIS_COPY_INCLUDES_TO_BINARY_DIR is @c TRUE, this function
# copies all other files to the build tree as well, using the same relative
# paths as will be used for the installation.
#
# @sa BASIS_CONFIGURE_INCLUDES
function (basis_configure_public_headers)
  # --------------------------------------------------------------------------
  # settings

  # log file which lists the configured header files
  set (CMAKE_FILE "${PROJECT_BINARY_DIR}/${PROJECT_NAME}PublicHeaders.cmake")
  # cache of currently defined CMake variables
  set (CACHE_FILE "${PROJECT_BINARY_DIR}/${PROJECT_NAME}PublicHeadersCache.txt")

  # considered extensions
  set (
    EXTENSIONS
      ".h"
      ".hh"
      ".hpp"
      ".hxx"
      ".inl"
      ".txx"
      ".inc"
  )

  # considered include directories
  basis_get_relative_path (INCLUDE_DIR "${PROJECT_SOURCE_DIR}" "${PROJECT_INCLUDE_DIR}")
  set (INCLUDE_DIRS "${PROJECT_SOURCE_DIR}/${INCLUDE_DIR}")

  # dump currently defined CMake variables such that these can be used to
  # configure the .in header files during the build step
  basis_dump_variables ("${CACHE_FILE}")

  # --------------------------------------------------------------------------
  # common arguments to following commands
  # Attention: Arguments which have a CMake list as value cannot be set this way,
  #            i.e., the arguments PROJECTS_INCLUDE_DIRS and EXTENSIONS.
  set (COMMON_ARGS
    -D "BINARY_INCLUDE_DIR=${BINARY_INCLUDE_DIR}"
    -D "INCLUDE_PREFIX=${INCLUDE_PREFIX}"
    -D "AUTO_PREFIX_INCLUDES=${BASIS_AUTO_PREFIX_INCLUDES}"
    -D "VARIABLE_NAME=PUBLIC_HEADERS"
  )

  # --------------------------------------------------------------------------
  # clean up last run before the error because a file was added/removed
  file (REMOVE "${CMAKE_FILE}.tmp")
  file (REMOVE "${CMAKE_FILE}.updated")
  if (EXISTS "${CMAKE_FILE}")
    # required to be able to remove now obsolete files from the build tree
    file (RENAME "${CMAKE_FILE}" "${CMAKE_FILE}.tmp")
  endif ()

  # --------------------------------------------------------------------------
  # configure public header files
  if (BASIS_VERBOSE)
    message (STATUS "Configuring public header files...")
  endif ()

  execute_process (
    COMMAND "${CMAKE_COMMAND}" ${COMMON_ARGS}
            -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
            -D "EXTENSIONS=${EXTENSIONS}"
            -D "INCLUDES_CHECK_EXCLUDE=${BASIS_INCLUDES_CHECK_EXCLUDE}"
            -D "INCLUDE_FILE=${CACHE_FILE}"
            -D "CMAKE_FILE=${CMAKE_FILE}"
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

  # remove header files from build tree which were copied there before but
  # are part of a now disabled module or were simply removed from the source tree
  if (EXISTS "${CMAKE_FILE}.tmp")
    execute_process (
      # Compare current list of headers to list of previously configured files.
      # If the lists differ, this command removes files which have been removed
      # from the directory tree with root PROJECT_INCLUDE_DIR also from the
      # tree with root directory BINARY_INCLUDE_DIR.
      COMMAND "${CMAKE_COMMAND}" ${COMMON_ARGS}
              -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
              -D "OUTPUT_FILE=${CMAKE_FILE}.tmp"
              -D "REFERENCE_FILE=${CMAKE_FILE}"
              -P "${BASIS_MODULE_PATH}/CheckPublicHeaders.cmake"
      VERBATIM
    )
    file (REMOVE "${CMAKE_FILE}.tmp")
    if (NOT RT EQUAL 0)
      message (FATAL_ERROR "Failed to remove obsolete header files from build tree."
                           " Remove the ${BINARY_INCLUDE_DIR} directory and re-run CMake.")
    endif ()
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
  set (ERRORMSG "You have either added, removed, or renamed a public header file")
  if (NOT BASIS_AUTO_PREFIX_INCLUDES)
    list (APPEND ERRORMSG " with a .in suffix in the file name")
  endif ()
  list (APPEND ERRORMSG ". Therefore, the build system needs to be"
                        " re-configured. Either try to build again which will"
                        " trigger CMake and re-configure the build system or"
                        " run CMake manually.")
  basis_list_to_string (ERRORMSG ${ERRORMSG})

  # custom command which globs the files in the project's include directory
  set (COMMENT "Checking if public header files were added or removed")
  if (PROJECT_IS_MODULE)
    set (COMMENT "${COMMENT} to ${PROJECT_NAME} module")
  endif ()
  add_custom_command (
    OUTPUT  "${CMAKE_FILE}.tmp"
    COMMAND "${CMAKE_COMMAND}" ${COMMON_ARGS}
            -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
            -D "EXTENSIONS=${EXTENSIONS}"
            -D "INCLUDES_CHECK_EXCLUDE=${BASIS_INCLUDES_CHECK_EXCLUDE}"
            -D "CMAKE_FILE=${CMAKE_FILE}.tmp"
            -D "PREVIEW=TRUE" # do not actually configure the files
            -P "${BASIS_MODULE_PATH}/ConfigureIncludeFiles.cmake"
    COMMENT "${COMMENT}"
    VERBATIM
  )

  # custom target to detect whether a file was added or removed
  basis_make_target_uid (CHECK_HEADERS_TARGET headers_check)
  if (PROJECT_IS_MODULE)
    set (CHECK_HEADERS_TARGET "${CHECK_HEADERS_TARGET}_${PROJECT_NAME_LOWER}")
  endif ()
  add_custom_target (
    ${CHECK_HEADERS_TARGET} ALL
    # trigger execution of custom command that generates the list
    # of current files in the project's include directory
    DEPENDS "${CMAKE_FILE}.tmp"
    # Compare current list of headers to list of previously configured files.
    # If the lists differ, the build of this target fails with the given error message.
    COMMAND "${CMAKE_COMMAND}" ${COMMON_ARGS}
            -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
            -D "OUTPUT_FILE=${CMAKE_FILE}"
            -D "REFERENCE_FILE=${CMAKE_FILE}.tmp"
            -D "ERRORMSG=${ERRORMSG}"
            -D "REMOVE_FILES_IF_DIFFERENT=TRUE" # triggers reconfigure on next build
            -P "${BASIS_MODULE_PATH}/CheckPublicHeaders.cmake"
    # remove temporary file again to force its regeneration
    COMMAND "${CMAKE_COMMAND}" -E remove "${CMAKE_FILE}.tmp"
    VERBATIM
  )
  if (PROJECT_IS_MODULE)
    basis_add_dependencies (headers_check ${CHECK_HEADERS_TARGET})
  endif ()

  # --------------------------------------------------------------------------
  # add build command to re-configure public header files
  if (PUBLIC_HEADERS)
    set (COMMENT "Configuring public header files")
    if (PROJECT_IS_MODULE)
      set (COMMENT "${COMMENT} of ${PROJECT_NAME} module")
    endif ()
    add_custom_command (
      OUTPUT  "${CMAKE_FILE}.updated" # do not use same file as included
                                      # before otherwise CMake will re-configure
                                      # the build system next time
      COMMAND "${CMAKE_COMMAND}" ${COMMON_ARGS}
              -D "PROJECT_INCLUDE_DIRS=${INCLUDE_DIRS}"
              -D "EXTENSIONS=${EXTENSIONS}"
              -D "INCLUDES_CHECK_EXCLUDE=${BASIS_INCLUDES_CHECK_EXCLUDE}"
              -D "INCLUDE_FILE=${CACHE_FILE}"
              -P "${BASIS_MODULE_PATH}/ConfigureIncludeFiles.cmake"
      COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_FILE}.updated"
      DEPENDS ${PUBLIC_HEADERS}
      COMMENT "${COMMENT}"
      VERBATIM
    )
    basis_make_target_uid (CONFIGURE_HEADERS_TARGET headers)
    if (PROJECT_IS_MODULE)
      set (CONFIGURE_HEADERS_TARGET "${CONFIGURE_HEADERS_TARGET}_${PROJECT_NAME_LOWER}")
    endif ()
    add_custom_target (
      ${CONFIGURE_HEADERS_TARGET} ALL
      DEPENDS ${CHECK_HEADERS_TARGET} "${CMAKE_FILE}.updated"
      SOURCES ${PUBLIC_HEADERS}
    )
    if (PROJECT_IS_MODULE)
      basis_add_dependencies (headers ${CONFIGURE_HEADERS_TARGET})
    endif ()
  endif ()

  # --------------------------------------------------------------------------
  # add include directories
  if (NOT BASIS_AUTO_PREFIX_INCLUDES)
    basis_include_directories (BEFORE "${PROJECT_INCLUDE_DIR}")
  endif ()
  basis_include_directories (BEFORE "${BINARY_INCLUDE_DIR}")
  # Attention: BASIS includes public header files which are named the
  #            same as system-wide header files. Therefore, avoid to add
  #            include/sbia/basis/ to the include search path.
  if (NOT PROJECT_NAME MATCHES "^BASIS$")
    basis_include_directories (BEFORE "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}")
    if (NOT BASIS_AUTO_PREFIX_INCLUDES)
      basis_include_directories (BEFORE "${PROJECT_INCLUDE_DIR}/${INCLUDE_PREFIX}")
    endif ()
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
        if (F MATCHES "COPYING")
          install (
            FILES       "${PROJECT_BINARY_DIR}/${F}.txt"
            DESTINATION "${INSTALL_DOC_DIR}"
            RENAME      "${N}"
            OPTIONAL
          )
        endif ()
      endif ()
    elseif (NOT F MATCHES "WELCOME" AND NOT PROJECT_IS_MODULE)
      message (FATAL_ERROR "Project requires a ${F}.txt file in ${PROJECT_SOURCE_DIR}!")
    endif ()
  endforeach ()
  set (PROJECT_LICENSE_FILE "${PROJECT_COPYING_FILE}") # compatibility with Slicer
endmacro ()

# ----------------------------------------------------------------------------
## @brief Get build time stamp.
#
# The build time stamp is used as an alternative to the version and revision
# information in @c PROJECT_RELEASE if version is invalid, i.e., set to 0.0.0
# as is the case for development branches, and now revision from a revision
# control system is available.
function (basis_get_build_timestamp TIMESTAMP)
  if (WIN32)
    execute_process (
      COMMAND "${BASIS_MODULE_PATH}/buildtimestamp.cmd"
      RESULT_VARIABLE RT
      OUTPUT_VARIABLE BUILD_TIMESTAMP
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  else ()
    execute_process (
      COMMAND "date" -u "+%Y.%m.%d (%H:%M UTC)"
      RESULT_VARIABLE RT
      OUTPUT_VARIABLE BUILD_TIMESTAMP
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  endif ()
  if (RT EQUAL 0)
    set (${TIMESTAMP} "${BUILD_TIMESTAMP}" PARENT_SCOPE)
  else ()
    set (${TIMESTAMP} PARENT_SCOPE)
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Initialize project, calls CMake's project() command.
#
# @sa basis_project()
# @sa basis_project_impl()
#
# @returns Sets the following non-cached CMake variables:
# @retval PROJECT_NAME_LOWER Project name in all lowercase letters.
# @retval PROJECT_NAME_UPPER Project name in all uppercase letters.
# @retval PROJECT_NAME_INFIX Project name used as infix for installation
#                            directories and namespace identifiers.
#                            In particular, the project name in either
#                            all lowercase or mixed case starting with
#                            an uppercase letter depending on whether
#                            the @c PROJECT_NAME has mixed case or not.
# @retval PROJECT_REVISION   Revision number of Subversion controlled
#                            source tree or 0 if the source tree is
#                            not under revision control.
# @retval PROJECT_RELEASE    A string of project version and revision
#                            that can be used for the output of
#                            version information. The format of this
#                            string is either one of the following:
#                            - "v1.0.0 (r42)"
#                            - "v1.0.0" (if revision unknown)
#                            - "r42"    (if version is 0.0.0)
#                            - ""       (otherwise)
macro (basis_project_initialize)
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
  # project()
  project ("${PROJECT_NAME}")

  # work-around for issue with CMAKE_PROJECT_NAME always being set to 'Project'
  if ("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    set_property (CACHE CMAKE_PROJECT_NAME PROPERTY VALUE "${PROJECT_NAME}")
  endif ()

  # convert project name to upper and lower case only, respectively
  string (TOUPPER "${PROJECT_NAME}" PROJECT_NAME_UPPER)
  string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWER)

  # This variable is in particular used in the Directories.cmake.in template
  # file to separate the files of modules of a project from each other
  # if BASIS_USE_MODULE_NAMESPACES is set to ON.
  if (WIN32)
    # Windows users prefer mixed case directory names
    set (PROJECT_NAME_INFIX "${PROJECT_NAME}")
  else ()
    # Unix users often prefer lowercase directory names
    set (PROJECT_NAME_INFIX "${PROJECT_NAME_LOWER}")
  endif ()

  # get revision of project
  #
  # Note: Use revision when branch, i.e., either trunk, a branch, or a tag
  #       has been modified last. For tags, this should in particular
  #       correspond to the revision when the tag was created.
  if (BASIS_NO_REVISION_INFO)
    set (PROJECT_REVISION 0)
  else ()
    basis_svn_get_last_changed_revision ("${PROJECT_SOURCE_DIR}" PROJECT_REVISION)
  endif ()

  # extract version numbers from version string
  basis_version_numbers (
    "${PROJECT_VERSION}"
      PROJECT_VERSION_MAJOR
      PROJECT_VERSION_MINOR
      PROJECT_VERSION_PATCH
  )

  set (PROJECT_SOVERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")

  # version information string
  if (PROJECT_VERSION MATCHES "^0+(\\.0+)?(\\.0+)?")
    if (PROJECT_REVISION)
      set (PROJECT_RELEASE "r${PROJECT_REVISION}")
    else ()
      basis_get_build_timestamp (BUILD_TIMESTAMP)
      if (BUILD_TIMESTAMP)
        set (PROJECT_RELEASE "b${BUILD_TIMESTAMP}")
      else ()
        set (PROJECT_RELEASE "")
      endif ()
    endif ()
  else ()
    set (PROJECT_RELEASE "v${PROJECT_VERSION}")
    if (PROJECT_REVISION)
      set (PROJECT_RELEASE "${PROJECT_RELEASE} (r${PROJECT_REVISION})")
    endif ()
  endif ()

  set (PROJECT_VERSION_AND_REVISION "${PROJECT_RELEASE}") # backwards compatibility to BASIS < 1.3

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
    message (STATUS "  Name:    ${PROJECT_NAME}")
    message (STATUS "  Release: ${PROJECT_RELEASE}")
  endif ()

  # --------------------------------------------------------------------------
  # reset project properties - *after* PROJECT_NAME was set

  # The following variables are used across BASIS macros and functions. They
  # in particular remember information added by one function or macro which
  # is required by another function or macro.
  #
  # These variables need to be properties such that they can be set in
  # subdirectories. Moreover, they have to be assigned with the project's
  # root source directory such that a top-level project's properties are restored
  # after this subproject is finalized such that the top-level project itself can
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
endmacro ()

# ----------------------------------------------------------------------------
## @brief Initialize project settings.
macro (basis_initialize_settings)
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
    "${BASIS_MODULE_PATH}/ProjectSettings.cmake.in"
    "${BINARY_CONFIG_DIR}/ProjectSettings.cmake"
    @ONLY
  )

  include ("${BINARY_CONFIG_DIR}/ProjectSettings.cmake" NO_POLICY_SCOPE)
endmacro ()

# ----------------------------------------------------------------------------
## @brief Find packages this project depends on.
macro (basis_find_packages)
  set (BASIS_SET_TARGET_PROPERTIES_IMPORT TRUE) # see set_target_properties()

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

  # Attention: This function is used before the Directories.cmake.in and
  #            Settings.cmake.in files were configured and included.
  include ("${PROJECT_CONFIG_DIR}/Depends.cmake" OPTIONAL)

  # --------------------------------------------------------------------------
  # optional dependencies - first in case a newer version of a package
  #                         can optionally be used, but at least an older
  #                         one is required
  foreach (P IN LISTS PROJECT_OPTIONAL_DEPENDS)
    basis_find_package ("${P}" QUIET)
    basis_use_package ("${P}")
  endforeach ()

  # --------------------------------------------------------------------------
  # optional test dependencies
  if (BUILD_TESTING)
    foreach (P IN LISTS PROJECT_OPTIONAL_TEST_DEPENDS)
      basis_find_package ("${P}" QUIET)
      basis_use_package ("${P}")
    endforeach ()
  endif ()

  # --------------------------------------------------------------------------
  # required dependencies
  foreach (P IN LISTS PROJECT_DEPENDS)
    basis_find_package ("${P}" REQUIRED)
    basis_use_package ("${P}"  REQUIRED)
  endforeach ()

  # --------------------------------------------------------------------------
  # test dependencies
  if (BUILD_TESTING)
    foreach (P IN LISTS PROJECT_TEST_DEPENDS)
      basis_find_package ("${P}") # do not use REQUIRED here to be able to show
      basis_use_package ("${P}")  # error message below
      basis_tokenize_dependency ("${P}" P VER CMPS)
      string (TOUPPER "${P}" U)
      if (NOT ${P}_FOUND AND NOT ${U}_FOUND)
        message (FATAL_ERROR "Could not find package ${P}! It is required by "
                             "the tests of ${PROJECT_NAME}. Either specify "
                             "package location manually and try again or "
                             "disable testing by setting BUILD_TESTING to OFF.")
        
      endif ()
      unset (U)
      unset (VER)
      unset (CMPS)
    endforeach ()
  endif ()

  unset (P)

  set (BASIS_SET_TARGET_PROPERTIES_IMPORT FALSE) # see set_target_properties()
endmacro ()

# ============================================================================
# finalization
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add installation rules for public header files.
macro (basis_install_public_headers)
  # install public header files from source tree
  if (NOT BASIS_AUTO_PREFIX_INCLUDES AND EXISTS "${PROJECT_INCLUDE_DIR}")
    basis_install_directory (
      "${PROJECT_INCLUDE_DIR}"
      "${INSTALL_INCLUDE_DIR}"
      PATTERN "*.in" EXCLUDE
    )
  endif ()
  # install configured public header files, excluding BASIS utilities
  file (GLOB_RECURSE _CONFIGURED_PUBLIC_HEADERS "${BINARY_INCLUDE_DIR}/*")
  list (REMOVE_ITEM _CONFIGURED_PUBLIC_HEADERS "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}basis.h")
  if (_CONFIGURED_PUBLIC_HEADERS)
    basis_install_directory (
      "${BINARY_INCLUDE_DIR}"
      "${INSTALL_INCLUDE_DIR}"
      REGEX "/${INCLUDE_PREFIX}basis\\.h$" EXCLUDE
    )
  endif ()
  # "parse" public header files to check if C++ BASIS utilities are included
  if (NOT BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES)
    # get list of all public header files of project
    set (_PUBLIC_HEADERS)
    if (NOT BASIS_CONFIGURE_INCLUDES)
      file (GLOB_RECURSE _PUBLIC_HEADERS "${PROJECT_INCLUDE_DIR}/*.h")
    endif ()
    list (APPEND _PUBLIC_HEADERS ${_CONFIGURED_PUBLIC_HEADERS})
    # check include statements of each public header file
    foreach (_A IN LISTS _PUBLIC_HEADERS)
      basis_utilities_check (_B "${_A}" CXX)
      if (_B)
        set (BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES TRUE)
        break ()
      endif ()
    endforeach ()
    unset (_PUBLIC_HEADERS)
    unset (_A)
    unset (_B)
  endif ()
  unset (_CONFIGURED_PUBLIC_HEADERS)
  # install public headers of BASIS utilities (optional)
  if (BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES)
    get_filename_component (_A "${INCLUDE_PREFIX}" PATH)
    get_filename_component (_B "${INCLUDE_PREFIX}" NAME)
    install (
      FILES       "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}basis.h"
      DESTINATION "${INSTALL_INCLUDE_DIR}/${_A}"
      COMPONENT   "${BASIS_LIBRARY_COMPONENT}"
      RENAME      "${_B}basis.h"
    )
    unset (_A)
    unset (_B)
  endif ()
endmacro ()

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
    basis_install_public_headers()
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
    # configure BASIS utilities
    basis_configure_utilities ()
    # finalize addition of custom targets
    basis_add_custom_finalize ()
    basis_add_init_py_target ()
    # add installation rule to register package with CMake
    if (BASIS_REGISTER)
      basis_register_package ()
    endif ()
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
## @brief Implementation of root <tt>CMakeLists.txt</tt> file of BASIS project.
#
# This macro implements the entire logic of the top-level
# <tt>CMakeLists.txt</tt> file. At first, the project is initialized and the
# BASIS settings configured using the project information given in the
# <tt>BasisProject.cmake</tt> file which must be located in the same directory.
# The, the code in the <tt>CMakeLists.txt</tt> files in the subdirectories is
# executed in order. At the end, the configuration of the build system is
# finalized, including in particular also the addition of custom build targets
# which perform the actual build of custom build targets such as the ones build
# using the MATLAB Compiler.
#
# @sa BasisProject.cmake
# @sa basis_project()
#
# @ingroup CMakeAPI
macro (basis_project_impl)
  # --------------------------------------------------------------------------
  # initialize project
  basis_project_initialize ()

  # --------------------------------------------------------------------------
  # load information of modules
  if (NOT PROJECT_IS_MODULE)
    basis_project_modules ()
  endif ()

  if (BASIS_DEBUG)
    basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterDetectionOfModules.cmake")
  endif ()

  # --------------------------------------------------------------------------
  # initialize Slicer module
  basis_slicer_module_initialize ()

  # --------------------------------------------------------------------------
  # Python

  # In case of a Slicer Extension, the UseSlicer.cmake file of Slicer (>= 4.0)
  # will set PYTHON_EXECUTABLE and requires us not to set this variable before
  # the UseSlicer.cmake file has been included. Hence, we set this variable
  # here only if it has not been set by Slicer, but before any PythonInterp
  # dependency declared by this package such that the Python interpreter
  # configured while building BASIS is used to avoid conflicts of different
  # versions used to compile the Python utilities (if BASIS_COMPILE_SCRIPTS
  # was set to ON) and the one used to configure/build this package.
  #
  # Note: The PYTHON_EXECUTABLE variable has to be cached such that
  #       PythonInterp.cmake does not look for the interpreter itself.
  if (BASIS_PYTHON_EXECUTABLE)
    set (
      PYTHON_EXECUTABLE
        "${BASIS_PYTHON_EXECUTABLE}"
      CACHE PATH
        "The Python interpreter."
    )
    mark_as_advanced (PYTHON_EXECUTABLE)
  endif ()
  # Note that PERL_EXECUTABLE and BASH_EXECUTABLE are set in BASISUse.cmake.

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
  # initialize settings
  basis_initialize_settings ()

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
    if (BUILD_TESTING AND NOT EXISTS "${PROJECT_SOURCE_DIR}/CTestConfig.cmake")
      message (WARNING "Missing CTestConfig.cmake file in top directory of source tree!"
                       " You will not be able to submit test results to the CDash dashboard.")
    endif ()
  endif ()

  # --------------------------------------------------------------------------
  # public header files
  basis_include_directories (BEFORE "${PROJECT_CODE_DIR}")
  basis_configure_public_headers ()

  # --------------------------------------------------------------------------
  # write dummy source files - required to by-pass CMake errors
  if (NOT PROJECT_IS_MODULE)
    basis_write_dummy_utilities ()
    basis_include_directories (BEFORE "${BINARY_INCLUDE_DIR}" "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}")
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

  # build software tests
  if (EXISTS "${PROJECT_TESTING_DIR}" AND BUILD_TESTING)
   add_subdirectory ("${PROJECT_TESTING_DIR}")
  endif ()

  # build/install example application
  if (EXISTS "${PROJECT_EXAMPLE_DIR}" AND BUILD_EXAMPLE)
    add_subdirectory ("${PROJECT_EXAMPLE_DIR}")
  endif ()

  # build/install package documentation
  if (EXISTS "${PROJECT_DOC_DIR}" AND BUILD_DOCUMENTATION)
    add_subdirectory ("${PROJECT_DOC_DIR}")
  endif ()

  if (BASIS_DEBUG)
    basis_dump_variables ("${PROJECT_BINARY_DIR}/VariablesAfterSubdirectories.cmake")
  endif ()

  # ----------------------------------------------------------------------------
  # change log
  if (NOT PROJECT_IS_MODULE)
    basis_add_changelog ()
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
