##############################################################################
# @file  InstallationTools.cmake
# @brief CMake functions used for installation.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeUtilities
##############################################################################

## @addtogroup CMakeUtilities
# @{

# ============================================================================
# Links
# ============================================================================

##############################################################################
# @brief Add installation command for creation of a symbolic link.
#
# @param [in] OLD  The value of the symbolic link.
# @param [in] NEW  The name of the symbolic link.
#
# @returns Adds installation command for creating the symbolic link @p NEW.

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

##############################################################################
# @brief Adds installation command for creation of symbolic links.
#
# This function creates for each main executable a symbolic link directly
# in the directory @c INSTALL_PREFIX/bin if @c INSTALL_SINFIX is not an empty
# string and the software is installed on a Unix-based system, i.e., one which
# supports the creation of symbolic links.
#
# @returns Adds installation command for creation of symbolic links in the
#          installation tree.

function (basis_install_links)
  if (NOT UNIX)
    return ()
  endif ()

  # main executables
  foreach (TARGET_UID ${BASIS_TARGETS})
    get_target_property (IMPORTED ${TARGET_UID} "IMPORTED")

    if (NOT IMPORTED)
      get_target_property (BASIS_TYPE ${TARGET_UID} "BASIS_TYPE")
      get_target_property (LIBEXEC    ${TARGET_UID} "LIBEXEC")
      get_target_property (NOEXEC     ${TARGET_UID} "NOEXEC")
      get_target_property (TEST       ${TARGET_UID} "TEST")

      if (
        BASIS_TYPE MATCHES "^EXECUTABLE$|^MCC_EXECUTABLE$|^SCRIPT$"
        AND NOT LIBEXEC AND NOT NOEXEC AND NOT TEST
      )
        get_target_property (SYMLINK_NAME ${TARGET_UID} "SYMLINK_NAME")
        if (NOT "${SYMLINK_NAME}" STREQUAL "NONE")
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

          basis_install_link (
            "${INSTALL_DIR}/${OUTPUT_NAME}"
            "bin/${SYMLINK_NAME}"
          )
        endif ()
      endif ()
    endif ()
  endforeach ()

  # documentation
  # Note: Not all CPack generators preserve symbolic links to directories
  # Note: This is not part of the filesystem hierarchy standard of Linux,
  #       but of the standard of certain distributions including Ubuntu.
  basis_install_link (
    "${INSTALL_DOC_DIR}"
    "share/doc/${INSTALL_SINFIX}"
  )
endfunction ()

# ============================================================================
# Deinstallation
# ============================================================================

##############################################################################
# @brief Add uninstall target.
#
# @author Pau Garcia i Quiles, modified by the SBIA Group
# @sa     http://www.cmake.org/pipermail/cmake/2007-May/014221.html
#
# Unix version works with any SUS-compliant operating system, as it needs
# only Bourne Shell features Win32 version works with any Windows which
# supports extended cmd.exe syntax (Windows NT 4.0 and newer, maybe Windows
# NT 3.x too).
#
# @returns Adds the custom target @c uninstall.

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

## @}
