##############################################################################
# @file  BasisUpdate.cmake
# @brief Implements automatic file udpate feature (deprecated).
#
# @note The automatic file update works well and the implementation is fine.
#       However, its use became more and more obsolete during the enhancement
#       of BASIS and the development of a more advanced project tool
#       (basisproject.py). Moreover, the update of project files during the
#       configuration of the build system was controversy.
#
# This file provides functions which implement the automatic file update
# of project files from the corresponding template files which they were
# instantiated from. Instead of the need to manually copy files and/or parts
# of files from the updated project template to each project that was
# instantiated from this particular template, the projects themselves check
# for the availibility of updated template files during the configure step
# of CMake and apply the updates if possible and desired by the user.
# The automatic file update mechanism can be configured to have the user decide
# for each or all files whether an available update may be applied or not.
# Further, updates will only be applied if it is guaranteed that these changes
# can be easily reverted.
#
# The automatic file update feature is only enabled when
#
# 1. The option @c BASIS_UPDATE, which is added by this module, is enabled.
#
# 2. @c BASIS_TEMPLATE_URL is a valid URL to the local root directory or
#    repository root directory of the BASIS project template, respectively,
#    Note that local directories must be prefixed by "file://".
#
# 3. The Python interpreter "python" was found and thus the variable
#    @c BASIS_CMD_PYTHON is set.
#
# 4. The script used to merge the content of the template with the existing
#    project files has to be in the same directory as this CMake module.
#
# 5. The project itself has to be under revision control, in particular,
#    a valid Subversion working copy. This is required to ensure that changes
#    applied during the automatic file udpate can be reverted.
#
# When this module is included, it adds the advanced option @c BASIS_UPDATE_AUTO
# which is @c ON by default. If @c BASIS_UPDATE_AUTO is @c ON, files are updated
# automatically without interacting with the user to get confirmation for file
# update. If a project file contains local modifications or is not under
# revision control, the udpate will not be performed automatically in any case.
# Moreover, files which are listed with their path relative to the project
# source directory in @c BASIS_UPDATE_EXCLUDE are excluded from the automatic file
# update.
#
# Copyright (c) 2011-2012, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_UPDATE_INCLUDED)
  return ()
else ()
  set (__BASIS_UPDATE_INCLUDED TRUE)
endif ()


# ============================================================================
# options
# ============================================================================

## @brief Enable/Disable update of files.
option (BASIS_UPDATE "Whether the automatic file update is enabled" "ON")
## @brief Enable/Disable automatic non-interactive update of files.
option (BASIS_UPDATE_AUTO "Whether files may be updated automatically without confirmation" "ON")

mark_as_advanced (BASIS_UPDATE)
mark_as_advanced (BASIS_UPDATE_AUTO)

# ============================================================================
# required modules
# ============================================================================

include ("${CMAKE_CURRENT_LIST_DIR}/CommonTools.cmake")
include ("${CMAKE_CURRENT_LIST_DIR}/RevisionTools.cmake")

# ============================================================================
# required commands
# ============================================================================

## @brief The Python interpreter command.
find_program (BASIS_CMD_PYTHON NAMES python DOC "Python interpreter (python).")
mark_as_advanced (BASIS_CMD_PYTHON)

## @brief Script used to perform the update of a file.
set (BASIS_UPDATE_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/updatefile.py")

# ============================================================================
# initialization
# ============================================================================

##############################################################################
# @brief Initialize file update and update files already scheduled for update.
#
# This function has to be called before any basis_update() call. It performs
# the update of files already scheduled for updated during a previous CMake
# configure step and for which the user choose to update them by invoking the
# function basis_update_files(). Note that files are only udpated here if the
# interactive mode is enabled or if there are files which could not be updated
# automatically by the last execution of basis_update_finalize(). Otherwise,
# no files are updated by this function. Afterwards the update system is
# initialized for another iteration of CMake's configure step.
#
# Example:
#
# @code
# basis_update_initialize ()
# basis_update (CTestConfig.cmake)
# basis_update_finalize ()
# @endcode
#
# @sa basis_update()
# @sa basis_update_finalize()
# @sa basis_update_files()
#
# @returns Sets @c BASIS_UPDATE_INITIALIZED to indicate the the automatic
#          file update feature has been initialized.

function (basis_update_initialize)
  # initialize only if not done already
  if (BASIS_UPDATE_INITIALIZED)
    return ()
  endif ()

  mark_as_advanced (BASIS_UPDATE_SCRIPT)

  # check BASIS_TEMPLATE_URL
  set (BASIS_TEMPLATE_URL_VALID 0)

  if (BASIS_TEMPLATE_URL MATCHES "file://.*")
    string (REGEX REPLACE "file://" "" TMP "${BASIS_TEMPLATE_URL}")
    if (IS_DIRECTORY "${TMP}")
      set (BASIS_TEMPLATE_URL_VALID 1)
    endif ()
  elseif (BASIS_TEMPLATE_URL MATCHES "http.*://.*")
    basis_svn_get_revision (${BASIS_TEMPLATE_URL} REV)
    if (REV)
      set (BASIS_TEMPLATE_URL_VALID 1)
    endif ()
  endif ()
 
  # --------------------------------------------------------------------------
  # update enabled
  # --------------------------------------------------------------------------

  if (
        BASIS_UPDATE             # 1. update is enabled
    AND BASIS_TEMPLATE_URL_VALID # 2. valid template root dir
    AND BASIS_CMD_PYTHON         # 3. python interpreter found
    AND BASIS_UPDATE_SCRIPT      # 4. update script found
    AND PROJECT_REVISION         # 5. project is under revision control
  )

    # update files which were not updated during last configure run. Instead,
    # CMake variables where added which enabled the user to specify the files
    # which should be udpated
    basis_update_files ()

  # --------------------------------------------------------------------------
  # update disabled
  # --------------------------------------------------------------------------

  else ()

    if (BASIS_UPDATE)
      message ("File update not feasible.")

      if (BASIS_VERBOSE)
        message ("Variables related to (automatic) file update:

  BASIS_UPDATE        : ${BASIS_UPDATE}
  BASIS_UPDATE_AUTO   : ${BASIS_UPDATE_AUTO}
  BASIS_CMD_PYTHON    : ${BASIS_CMD_PYTHON}
  BASIS_UPDATE_SCRIPT : ${BASIS_UPDATE_SCRIPT}
  BASIS_TEMPLATE_URL  : ${BASIS_TEMPLATE_URL}
  PROJECT_REVISION    : ${PROJECT_REVISION}
")
      endif ()

      if (NOT BASIS_CMD_PYTHON)
        message ("=> Python interpreter not found.")
      endif ()
	  if (NOT BASIS_UPDATE_SCRIPT)
        message ("=> File update script not found.")
      endif ()
      if (NOT BASIS_TEMPLATE_URL_VALID)
        message ("=> Invalid BASIS_TEMPLATE_URL path.")
      endif()
      if (NOT PROJECT_REVISION)
        message ("=> Project is not under revision control.")
      endif ()

      message ("Setting BASIS_UPDATE to OFF.")
      set (BASIS_UPDATE "OFF" CACHE BOOL "Whether the automatic file update is enabled" FORCE)
    endif ()
 
  endif ()

  # DO NOT cache this variable
  set (BASIS_UPDATE_INITIALIZED 1)
endfunction ()

# ============================================================================
# update
# ============================================================================

##############################################################################
# @brief Checks for availibility of update and adds files for which an
#        updated template exists to BASIS_UPDATE_FILES.
#
# This function retrieves a copy of the latest revision of the corresponding
# template file of the project template from which this project was
# instantiated and caches it in the binary tree. If a cached copy is already
# available, the cached copy is used. Then, it checks whether the template
# contains any updated compared to the current project file, ignoring the
# content of customizable sections. If an udpate is available, the file
# is added to BASIS_UPDATE_FILE. The updates will be applied by either
# basis_update_initialize() if the interactive mode is enabled or by
# basis_update_finalize().
#
# Files which are listed with their path relative to the project source
# directory in BASIS_UPDATE_EXCLUDE are excluded from the automatic file
# update and will hence be skipped by this function.
#
# @sa basis_update_initialize()
# @sa basis_update_finalize()
#
# @param [in] FILENAME Name of project file in current source directory.
#
# @returns Nothing.

function (basis_update FILENAME)
  if (NOT BASIS_UPDATE)
    return ()
  endif ()

  # absolute path of project file
  set (CUR "${CMAKE_CURRENT_SOURCE_DIR}/${FILENAME}")

  # get path of file relative to project source directory
  file (RELATIVE_PATH REL "${PROJECT_SOURCE_DIR}" "${CUR}")

  # must be AFTER REL was set
  if (BASIS_VERBOSE)
    message (STATUS "Checking for update of file '${REL}'...")
  endif ()

  # skip file if excluded from file update
  if (BASIS_UPDATE_EXCLUDE)
    list (FIND BASIS_UPDATE_EXCLUDE "${CUR}" IDX)
    if (IDX EQUAL -1)
      list (FIND BASIS_UPDATE_EXCLUDE "${REL}" IDX)
    endif ()
    if (NOT IDX EQUAL -1)
      if (BASIS_VERBOSE)
        message (STATUS "Checking for update of file '${REL}'... - excluded")
      endif ()
      return ()
    endif ()
  endif ()

  # skip file if it is not under revision control
  if (EXISTS "${CUR}")
    basis_svn_get_last_changed_revision ("${CUR}" CURREV)

    if (CURREV EQUAL 0)
      if (BASIS_VERBOSE)
        message (STATUS "Checking for update of file '${REL}'... - file unversioned")
      endif ()

      return ()
    endif ()
  endif ()

  # retrieve template file
  basis_update_cached_template ("${REL}" TMP)             # file name of cached template file
  basis_update_template        ("${REL}" "${TMP}" RETVAL) # update cached template file

  if (NOT RETVAL)
    message (STATUS "Checking for update of file '${REL}'... - template missing")
    return ()
  endif ()

  # get currently cached list of files in BASIS_UPDATE_FILES
  set (FILES ${BASIS_UPDATE_FILES})

  # --------------------------------------------------------------------------
  # check if update of existing project file is available
  # --------------------------------------------------------------------------

  if (EXISTS "${CUR}")
    execute_process (
      COMMAND
        "${BASIS_CMD_PYTHON}" "${BASIS_UPDATE_SCRIPT}" -i "${CUR}" -t "${TMP}"
      RESULT_VARIABLE
        RETVAL
      OUTPUT_QUIET
      ERROR_QUIET
    )

    if (RETVAL EQUAL 0)
      list (APPEND FILES "${REL}")
    elseif (RETVAL EQUAL 2)

      if (FILES)
        list (REMOVE_ITEM FILES "${REL}")
      endif ()

      basis_update_option ("${REL}" OPT)

      if (DEFINED ${OPT})
        set (${OPT} "" CACHE INTERNAL "Unused option." FORCE)
      endif ()
    endif ()

    if (BASIS_VERBOSE)
      if (RETVAL EQUAL 0)
        message (STATUS "Checking for update of file '${REL}'... - update available")
      elseif (RETVAL EQUAL 2)
        message (STATUS "Checking for update of file '${REL}'... - up-to-date")
      else ()
        message (STATUS "Checking for update of file '${REL}'... - failed")
      endif ()
    endif ()

  # --------------------------------------------------------------------------
  # new files added to template
  # --------------------------------------------------------------------------

  else ()

    list (APPEND FILES "${REL}")

    if (BASIS_VERBOSE)
      message (STATUS "Checking for update of file '${REL}'... - file missing")
    endif ()

  endif ()

  # update cached variable BASIS_UPDATE_FILES
  set (BASIS_UPDATE_FILES ${FILES} CACHE INTERNAL "Files to be updated." FORCE)
endfunction ()

# ============================================================================
# finalization
# ============================================================================

##############################################################################
# @brief Adds file update options for user interaction or performs
#        file update immediately if quiet update enabled.
#
# @sa basis_update()
# @sa basis_update_initialize()
# @sa basis_update_finalize()
#
# @returns Nothing.

function (basis_update_finalize)
  if (NOT BASIS_UPDATE)
    return ()
  endif ()

  set (FILES ${BASIS_UPDATE_FILES})

  if (FILES)
    list (REMOVE_DUPLICATES FILES)
  endif ()

  # iterate over files added by basis_update ()
  foreach (REL ${FILES})

    # absolute path of project file
    set (CUR "${PROJECT_SOURCE_DIR}/${REL}")

    # name of cached template file
    basis_update_cached_template ("${REL}" TMP)

    # ------------------------------------------------------------------------
    # project file exists
    # ------------------------------------------------------------------------

    if (EXISTS "${CUR}")

      # check if it is under revision control and whether it has local modifications
      if (EXISTS "${CUR}")
        basis_svn_get_last_changed_revision (${CUR} CURREV)
        basis_svn_status                    (${CUR} CURSTATUS)
      endif ()

      basis_update_option ("${REL}" OPT) # name of file update option

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # quietly update file w/o user interaction
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      if (
            BASIS_UPDATE_AUTO          # 1. option BASIS_UPDATE_AUTO is ON
        AND CURREV GREATER 0           # 2. project file is under revision control
        AND "${CURSTATUS}" STREQUAL "" # 3. project file has no local modifications
      )
        if (BASIS_VERBOSE)
          message (STATUS "Updating file '${REL}'...")
        endif ()

        execute_process (
          COMMAND
            "${BASIS_CMD_PYTHON}" "${BASIS_UPDATE_SCRIPT}" -f -i "${CUR}" -t "${TMP}" -o "${CUR}"
          RESULT_VARIABLE
            RETVAL
          OUTPUT_QUIET
          ERROR_QUIET
        )

        if (RETVAL EQUAL 0 OR RETVAL EQUAL 2)
          list (REMOVE_ITEM FILES "${REL}")
          set (${OPT} "" CACHE INTERNAL "Unused option." FORCE)
        endif ()

        if (RETVAL EQUAL 0)
          message ("Updated file '${REL}'")
        elseif (NOT RETVAL EQUAL 2)
          message ("Failed to update file '${REL}'")
        endif ()

        if (BASIS_VERBOSE)
          if (RETVAL EQUAL 0)
            message (STATUS "Updating file '${REL}'... - done")
          elseif (RETVAL EQUAL 2)
            message (STATUS "Updating file '${REL}'... - up-to-date")
          else ()
            message (STATUS "Updating file '${REL}'... - failed")
          endif ()
        endif ()

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # add file update option (if not present yet)
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      else ()

        if ("${${OPT}}" STREQUAL "")
          # add option which user can modify to force update of file
          set (${OPT} "OFF" CACHE BOOL "Whether file '${REL}' should be updated." FORCE)
          # add BASIS_UPDATE_ALL option if not present
          if ("${UPDATE_ALL}" STREQUAL "")
            set (UPDATE_ALL "OFF" CACHE BOOL "Whether all files should be updated." FORCE)
          endif ()
        endif ()

        # inform user that file update is available
        message ("Update of file '${REL}' available.\nSet UPDATE_ALL or ${OPT} to ON if changes should be applied.")

      endif ()

    # ----------------------------------------------------------------------
    # project file non existent
    # ----------------------------------------------------------------------

    else ()

      if (BASIS_VERBOSE)
        message (STATUS "Adding file '${REL}'...")
      endif ()

      configure_file ("${TMP}" "${CUR}" COPYONLY)

      list (REMOVE_ITEM FILES "${REL}")
      set (${OPT} "" CACHE INTERNAL "Unused option." FORCE)

      message ("Added file '${REL}'. Do not forget to add it to the repository!")

      if (BASIS_VERBOSE)
        message (STATUS "Adding file '${REL}'... - done")
      endif ()

    endif ()

  endforeach ()

  if (NOT FILES)
    set (UPDATE_ALL "" CACHE INTERNAL "Unused option." FORCE)
  endif ()

  set (BASIS_UPDATE_FILES ${FILES} CACHE INTERNAL "Files to be updated." FORCE)
endfunction ()

# ============================================================================
# helpers
# ============================================================================

# ----------------------------------------------------------------------------
# common helpers
# ----------------------------------------------------------------------------

##############################################################################
# @brief Get name of file update option.
#
# The CMake variable name returned by this function is used as file update
# option which enables the user to select which files should be udpated.
#
# @sa basis_update_finalize()
# @sa basis_update_files()
#
# @param [in]  REL         Path of project file relative to project source directory.
# @param [out] OPTION_NAME Name of file update option.
#
# @returns Sets @p OPTION_NAME to the name of the CMake option variable.

function (basis_update_option REL OPTION_NAME)
  set (TMP "${REL}")
  string (REGEX REPLACE "\\.|\\\\|/|-" "_" TMP ${TMP})
  set (${OPTION_NAME} "UPDATE_${TMP}" PARENT_SCOPE)
endfunction ()

##############################################################################
# @brief Get filename of cached template file.
#
# @param [in]  REL      Path of project file relative to project source directory.
# @param [out] TEMPLATE Absolute path of cached template file in binary tree
#                       of project.
#
# @returns Sets @p TEMPLATE to the full path of the updated template file.

function (basis_update_cached_template REL TEMPLATE)
  # URL of template file
  set (SRC "${BASIS_TEMPLATE_URL}/${REL}")

  # get revision of template file. If no revision number can be determined,
  # we either did not find the svn client or the file referenced by SRC
  # is not a repository. However, if it is a working copy, we will still
  # get a revision number. Thus, we then need to check if SRC is a URL
  # starting with 'https://sbia-svn' or not (see below).
  basis_svn_get_last_changed_revision ("${SRC}" REV)

  if (REV GREATER 0)
    basis_svn_status ("${SRC}" STATUS)
    if (NOT "${STATUS}" STREQUAL "")
      set (REV "0") # under revision control, but locally modified
    endif ()
  else ()
    set (REV "-") # not under revision control (or non-existent)
  endif ()

  # file name of cached template file in binary tree of project
  set (${TEMPLATE} "${PROJECT_BINARY_DIR}/${REL}.rev${REV}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
# update helpers
# ----------------------------------------------------------------------------

##############################################################################
# @brief Removes cached template files from binary tree.
#
# This function is used by basis_update_template() to remove cached template
# copies of a particular file in the binary tree when no longer needed.
#
# @sa basis_update_template()
#
# @param [in] REL  Path of the project file whose template copies shall be
#                  removed relative to the project's source directory.
# @param [in] ARGN Absolute paths of cached template files to preserve.
#
# @returns Nothing.

function (basis_update_clear REL)
  # collect all cached template files
  file (GLOB FILES "${PROJECT_BINARY_DIR}/${REL}.rev*")
  # remove files which are to be preserved
  if (FILES)
    foreach (ARG ${ARGN})
      list (REMOVE_ITEM FILES ${ARG})
    endforeach ()
  endif ()
  # remove files
  if (FILES)
    file (REMOVE ${FILES})
  endif ()
endfunction ()

##############################################################################
# @brief Retrieves latest revision of template file.
#
# @param [in]  REL      Path of project/template file relative to project source tree.
# @param [in]  TEMPLATE Absolute path of cached template file in binary tree of project.
# @param [out] RETVAL   Boolean variable which indicates success or failure.
#
# @returns Sets @p RETVAL either to 1 or 0 whether or not the update was
#          successful or not, respectively.

function (basis_update_template REL TEMPLATE RETVAL)

  # URL of template file
  set (SRC "${BASIS_TEMPLATE_URL}/${REL}")

  # if template file is not under revision control or has local modifications
  # we cannot use caching as there is no unique revision number assigned
  if (TEMPLATE MATCHES ".*\\.rev[0|-]")

    # remove previously exported/downloaded template files
    basis_update_clear ("${REL}")

    # download template file from non-revision controlled template
    file (DOWNLOAD "${SRC}" "${TEMPLATE}" TIMEOUT 30 STATUS RET)
    list (GET RET 0 RET)

  # if cached file not available, retrieve it from repository or working copy
  elseif (NOT EXISTS "${TEMPLATE}")

    # remove previously exported/downloaded revisions
    basis_update_clear ("${REL}")

    # if template URL is SVN repository, export file using SVN client
    if ("${SRC}" MATCHES "^https://sbia-svn.*")
      execute_process (
        COMMAND         "${BASIS_CMD_SVN}" export "${SRC}" "${TEMPLATE}"
        TIMEOUT         30
        RESULT_VARIABLE RET
        OUTPUT_QUIET
        ERROR_QUIET
      )
    # otherwise, download file
    else ()
      file (DOWNLOAD "${SRC}" "${TEMPLATE}" TIMEOUT 30 STATUS RET)
      list (GET RET 0 RET)
    endif ()
  else ()
    basis_update_clear ("${REL}" "${TEMPLATE}")
	set (RET 0)
  endif ()

  # return value
  if (RET EQUAL 0)
    set (${RETVAL} 1 PARENT_SCOPE)
  else ()
    set (${RETVAL} 0 PARENT_SCOPE)
  endif ()
endfunction ()

##############################################################################
# @brief Update files listed in BASIS_UPDATE_FILES for which file
#        update option exists and is ON or UPDATE_ALL is ON.
#
# This function attempts to update all files in BASIS_UPDATE_FILES
# whose file update option is ON. If the option UPDATE_ALL is ON,
# the file update options of individual files are ignored and all files
# are updated. It is called by basis_update_initialize().
#
# The list BASIS_UPDATE_FILES is populated by the function basis_update()
# and the file update options for the listed files are added by
# basis_update_finalize() if BASIS_UPDATE_QUIET is OFF. Otherwise,
# the files are updated directly by basis_update_finalize() if possible.
#
# @sa basis_update_initialize()
# @sa basis_update_finalize()
#
# @returns Nothing.

function (basis_update_files)
  if (NOT BASIS_UPDATE)
    return ()
  endif ()

  set (FILES ${BASIS_UPDATE_FILES})

  if (FILES)
    list (REMOVE_DUPLICATES FILES)
  endif ()

  foreach (REL ${FILES})

    # absolute path of project file
    set (CUR "${PROJECT_SOURCE_DIR}/${REL}")

    # if project file exists, check if it is under revision control and
	# whether it has local modifications
    if (EXISTS "${CUR}")
      basis_svn_status (${CUR} CURSTATUS)
    else ()
      set (CURSTATUS "")
    endif ()

    # get name of cached template file
    basis_update_cached_template ("${REL}" TMP)

    # if cached template file exists...
    if (EXISTS "${TMP}")
 
      basis_update_option ("${REL}" OPT) # name of file update option

      # ...and file update option is ON
      if ("${${OPT}}" STREQUAL "ON" OR "${UPDATE_ALL}" STREQUAL "ON")

        if (BASIS_VERBOSE)
          message (STATUS "Updating file '${REL}'...")
        endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # project file has local modifications
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        if (NOT "${CURSTATUS}" STREQUAL "")

          message ("File '${REL}' has local modifications. Modifications must be committed or reverted before file can be updated.")

          if ("${${OPT}}" STREQUAL "ON")
            message ("Setting ${OPT} to OFF.")
            set (${OPT} "OFF" CACHE BOOL "Whether file '${REL}' should be updated." FORCE)
          endif ()

          if (BASIS_VERBOSE)
            message (STATUS "Updating file '${REL}'... - failed")
          endif ()

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # project file has NO local modifications
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        else ()

          execute_process (
            COMMAND
              "${BASIS_CMD_PYTHON}" "${BASIS_UPDATE_SCRIPT}" -f -i "${CUR}" -t "${TMP}" -o "${CUR}"
            RESULT_VARIABLE
              RETVAL
            OUTPUT_QUIET
            ERROR_QUIET
          )

          if (RETVAL EQUAL 0 OR RETVAL EQUAL 2)
            list (REMOVE_ITEM FILES "${REL}")
            set (${OPT} "" CACHE INTERNAL "Unused option." FORCE)
          endif ()

          if (RETVAL EQUAL 0)
            message ("Updated file '${REL}'")
          elseif (NOT RETVAL EQUAL 2)
            message ("Failed to update file '${REL}'")
          endif ()

          if (BASIS_VERBOSE)
            if (RETVAL EQUAL 0)
              message (STATUS "Updating file '${REL}'... - done")
            elseif (RETVAL EQUAL 2)
              message (STATUS "Updating file '${REL}'... - up-to-date")
            else ()
              message (STATUS "Updating file '${REL}'... - failed")
            endif ()
          endif ()
  
        endif ()
      endif ()
    endif ()

  endforeach ()

  set (BASIS_UPDATE_FILES ${FILES} CACHE INTERNAL "Files to be updated." FORCE)

  # reset option UPDATE_ALL
  if (FILES)
    if ("${UPDATE_ALL}" STREQUAL "ON")
      message ("Setting UPDATE_ALL to OFF.")
      set (UPDATE_ALL "OFF" CACHE BOOL "Whether all files should be updated." FORCE)
    endif ()
  else ()
    set (UPDATE_ALL "" CACHE INTERNAL "Unused option." FORCE)
  endif ()
endfunction ()
