##############################################################################
# @file  InstallationTools.cmake
# @brief CMake functions used for installation.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

## @addtogroup CMakeUtilities
# @{


# ============================================================================
# Installation
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Specify rules to run at install time.
#
# This function replaces CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:install">
# install()</a> command.
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:install
#
# @ingroup CMakeAPI
function (basis_install)
  install (${ARGN})
endfunction ()

# ----------------------------------------------------------------------------
## @brief Install content of source directory excluding typical files.
#
# Files which are excluded are typical backup files, system files, files
# from revision control systems, and CMakeLists.txt files.
#
# Example:
# @code
# basis_install_directory("${INSTALL_DATA_DIR}")
# basis_install_directory(. "${INSTALL_DATA_DIR}")
# basis_install_directory("${CMAKE_CURRENT_SOURCE_DIR}" "${INSTALL_DATA_DIR}")
# basis_install_directory(images "${INSTALL_DATA_DIR}/images")
# @endcode
#
# @param [in] ARGN The first two arguments are extracted from the beginning
#                  of this list in the named order (without option name),
#                  and the remaining arguments are passed on to CMake's
#                  <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:install">
#                  <tt>install(DIRECTORY)</tt></a> command.
# @par
# <table border="0">
#   <tr>
#     @tp @b SOURCE @endtp
#     <td>Source directory. Defaults to current source directory
#         if only one argument, the @p DESTINATION, is given./td>
#   </tr>
#   <tr>
#     @tp @b DESTINATION @endtp
#     <td>Destination directory.</td>
#   </tr>
# </table>
#
# @sa http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:install
#
# @ingroup CMakeAPI
function (basis_install_directory)
  if (ARGC EQUAL 1)
    set (SOURCE      "${CMAKE_CURRENT_SOURCE_DIR}")
    set (DESTINATION "${ARGV0}")
    set (OPTIONS     "${ARGV}")
    list (REMOVE_AT OPTIONS 0)
  elseif (ARGC GREATER 1)
    set (SOURCE      "${ARGV0}")
    set (DESTINATION "${ARGV1}")
    set (OPTIONS     "${ARGV}")
    list (REMOVE_AT OPTIONS 0 1)
  else ()
    message (FATAL_ERROR "Too few arguments given!")
  endif ()
  basis_sanitize_for_regex (REGEX "${PROJECT_SOURCE_DIR}")
  if (IS_ABSOLUTE "${DESTINATION}")
    set (DESTINATION_ABSDIR "${DESTINATION}")
  else ()
    set (DESTINATION_ABSDIR "${INSTALL_PREFIX}/${DESTINATION}")
  endif ()
  if ("${DESTINATION_ABSDIR}" MATCHES "^${REGEX}")
    message (FATAL_ERROR "Installation directory ${DESTINATION_ABSDIR} is inside the project source tree!")
  endif ()
  install (
    DIRECTORY   "${SOURCE}/"
    DESTINATION "${DESTINATION}"
    ${OPTIONS}
    PATTERN     CMakeLists.txt EXCLUDE
    PATTERN     *~             EXCLUDE
    PATTERN     .svn           EXCLUDE
    PATTERN     .git           EXCLUDE
    PATTERN     .DS_Store      EXCLUDE
  )
endfunction ()

# ----------------------------------------------------------------------------
## @brief Add installation rule to create a symbolic link.
#
# Note that the installation rule will only be effective on a Unix-like
# system, i.e., one which supports the creation of a symbolic link.
#
# @param [in] OLD  The value of the symbolic link.
# @param [in] NEW  The name of the symbolic link.
#
# @returns Adds installation rule to create the symbolic link @p NEW.
#
# @ingroup CMakeAPI
function (basis_install_link OLD NEW)
  # Attention: CMAKE_INSTALL_PREFIX must be used instead of INSTALL_PREFIX.
  set (CMD_IN
    "
    set (OLD \"@OLD@\")
    set (NEW \"@NEW@\")

    if (NOT IS_ABSOLUTE \"\${OLD}\")
      set (OLD \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/\${OLD}\")
    endif ()
    if (NOT IS_ABSOLUTE \"\${NEW}\")
      set (NEW \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/\${NEW}\")
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
      else ()
        list (APPEND CMAKE_INSTALL_MANIFEST_FILES \"\${NEW}\")
      endif ()
    endif ()
    "
  )

  string (CONFIGURE "${CMD_IN}" CMD @ONLY)
  install (CODE "${CMD}")
endfunction ()

# ----------------------------------------------------------------------------
## @brief Adds installation rules to create default symbolic links.
#
# This function creates for each main executable a symbolic link directly
# in the directory @c INSTALL_PREFIX/bin if @c INSTALL_SINFIX is TRUE and the
# software is installed on a Unix-like system, i.e., one which
# supports the creation of symbolic links.
#
# @returns Adds installation command for creation of symbolic links in the
#          installation tree.
function (basis_install_links)
  if (NOT UNIX)
    return ()
  endif ()

  # main executables
  basis_get_project_property (TARGETS PROPERTY TARGETS)
  foreach (TARGET_UID ${TARGETS})
    get_target_property (IMPORTED ${TARGET_UID} "IMPORTED")

    if (NOT IMPORTED)
      get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")
      get_target_property (LIBEXEC    ${TARGET_UID} "LIBEXEC")
      get_target_property (TEST       ${TARGET_UID} "TEST")

      if (BASIS_TYPE MATCHES "EXECUTABLE" AND NOT LIBEXEC AND NOT TEST)
        get_target_property (SYMLINK_NAME ${TARGET_UID} "SYMLINK_NAME")
        if (NOT "${SYMLINK_NAME}" MATCHES "^none$|^None$|^NONE$")
          get_target_property (SYMLINK_PREFIX ${TARGET_UID} "SYMLINK_PREFIX")
          get_target_property (SYMLINK_SUFFIX ${TARGET_UID} "SYMLINK_SUFFIX")
          get_target_property (INSTALL_DIR    ${TARGET_UID} "RUNTIME_INSTALL_DIRECTORY")

          basis_get_target_location (OUTPUT_NAME ${TARGET_UID} NAME)

          if (NOT SYMLINK_NAME)
            set (SYMLINK_NAME "${OUTPUT_NAME}")
          endif ()
          if (SYMLINK_PREFIX)
            set (SYMLINK_NAME "${SYMLINK_PREFIX}${SYMLINK_NAME}")
          endif ()
          if (SYMLINK_SUFFIX)
            set (SYMLINK_NAME "${SYMLINK_NAME}${SYMLINK_SUFFIX}")
          endif ()

          # avoid creation of symbolic link if there would be a conflict with
          # the subdirectory in bin/ where the actual executables are installed
          if (INSTALL_SINFIX AND "${SYMLINK_NAME}" STREQUAL "${BASIS_INSALL_SINFIX}")
            message (STATUS \"Skipping: ${INSTALL_DIR}/${OUTPUT_NAME} -> ${INSTALL_PREFIX}/bin/${SYMLINK_NAME}\")
          else ()
            basis_install_link (
              "${INSTALL_DIR}/${OUTPUT_NAME}"
              "bin/${SYMLINK_NAME}"
            )
          endif ()
        endif ()
      endif ()
    endif ()
  endforeach ()
endfunction ()

# ============================================================================
# Package registration
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Register installed package with CMake.
#
# This function adds an entry to the CMake registry for packages with the
# path of the directory where the package configuration file is located in
# order to help CMake find the package.
#
# The uninstaller whose template can be found in cmake_uninstaller.cmake.in
# is responsible for removing the registry entry again.
function (basis_register_package)
  set (PKGDIR "${INSTALL_PREFIX}/${INSTALL_CONFIG_DIR}")
  # note: string(MD5) only available since CMake 2.8.7
  #string (MD5 PKGUID "${PKGDIR}")
  set (PKGUID "${BASIS_NAMESPACE_LOWER}-${PROJECT_NAME_LOWER}-${PROJECT_VERSION}")
  if (WINDOWS)
    install (CODE
      "execute_process (
         COMMAND reg add
                    \"HKEY_CURRENT_USER//Software//Kitware//CMake//Packages//${PROJECT_NAME}\"
                    /v \"${PKGUID}\" /d \"${PKGDIR}\" /t REG_SZ /f
       )"
    )
  elseif (IS_DIRECTORY "$ENV{HOME}")
    file (WRITE "${BINARY_CONFIG_DIR}/${PROJECT_NAME}RegistryFile" "${PKGDIR}")
    install (
      FILES       "${BINARY_CONFIG_DIR}/${PROJECT_NAME}RegistryFile"
      DESTINATION "$ENV{HOME}/.cmake/packages/${PROJECT_NAME_LOWER}"
      RENAME      "${PKGUID}"
    )
  endif ()
endfunction ()

# ============================================================================
# Deinstallation
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add uninstall target.
#
# @returns Adds the custom target @c uninstall and code to
#          <tt>cmake_install.cmake</tt> to install an uninstaller.
function (basis_add_uninstall)
  # add uninstall target
  configure_file (
    ${BASIS_MODULE_PATH}/cmake_uninstall.cmake.in
    ${PROJECT_BINARY_DIR}/cmake_uninstall.cmake
    @ONLY
  )
  add_custom_target (
    uninstall
    COMMAND ${CMAKE_COMMAND} -P "${PROJECT_BINARY_DIR}/cmake_uninstall.cmake"
    COMMENT "Uninstalling..."
  )
endfunction ()


## @}
# end of Doxygen group
