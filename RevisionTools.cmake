##############################################################################
# @file  RevisionTools.cmake
# @brief CMake functions and macros related to revision control systems.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_REVISIONTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_REVISIONTOOLS_INCLUDED TRUE)
endif ()


# ============================================================================
# required commands
# ============================================================================

find_package (Subversion QUIET)
find_package (Git        QUIET)


## @addtogroup CMakeUtilities
#  @{


# ============================================================================
# Subversion
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Get current revision of file or directory.
#
# @param [in]  URL  Absolute path of directory or file. May also be a URL to the
#                   directory or file in the repository. A leading "file://" is
#                   automatically removed such that the svn command treats it as a
#                   local path.
# @param [out] REV  The revision number of URL. If URL is not under revision
#                   control or Subversion_SVN_EXECUTABLE is invalid, "0" is returned.
#
# @returns Sets @p REV to the revision of the working copy/repository
#          at URL @p URL.
function (basis_svn_get_revision URL REV)
  set (OUT 0)
  if (Subversion_SVN_EXECUTABLE)
    # remove "file://" from URL
    string (REGEX REPLACE "file://" "" TMP "${URL}")
    # retrieve SVN info
    execute_process (
      COMMAND         "${Subversion_SVN_EXECUTABLE}" info "${TMP}"
      OUTPUT_VARIABLE OUT
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if (BASIS_DEBUG)
      message ("** basis_svn_get_revision()")
      message ("**   svn info: ${OUT}")
    endif ()
    # extract revision
    if (OUT MATCHES "^(.*\n)?Revision: ([^\n]+).*" AND NOT CMAKE_MATCH_2 STREQUAL "")
      set (OUT "${CMAKE_MATCH_2}")
    else ()
      set (OUT 0)
    endif ()
  endif ()
  # return
  set ("${REV}" "${OUT}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get revision number when directory or file was last changed.
#
# @param [in]  URL  Absolute path of directory or file. May also be a URL to the
#                   directory or file in the repository. A leading "file://" is
#                   automatically removed such that the svn command treats it as a
#                   local path.
# @param [out] REV  Revision number when URL was last modified. If URL is not
#                   under Subversion control or Subversion_SVN_EXECUTABLE is invalid,
#                   "0" is returned.
#
# @returns Sets @p REV to revision number at which the working copy/repository
#          specified by the URL @p URL was last modified.
function (basis_svn_get_last_changed_revision URL REV)
  set (OUT 0)
  if (Subversion_SVN_EXECUTABLE)
    # remove "file://" from URL
    string (REGEX REPLACE "file://" "" TMP "${URL}")
    # retrieve SVN info
    execute_process (
      COMMAND         "${Subversion_SVN_EXECUTABLE}" info "${TMP}"
      OUTPUT_VARIABLE OUT
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if (BASIS_DEBUG)
      message ("** basis_svn_get_revision()")
      message ("**   svn info: ${OUT}")
    endif ()
    # extract last changed revision
    if (OUT MATCHES "^(.*\n)?Last Changed Rev: ([^\n]+).*" AND NOT CMAKE_MATCH_2 STREQUAL "")
      set (OUT "${CMAKE_MATCH_2}")
    else ()
      set (OUT 0)
    endif ()
  endif ()
  # return
  set ("${REV}" "${OUT}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Get status of revision controlled file.
#
# @param [in]  URL    Absolute path of directory or file. May also be a URL to
#                     the directory or file in the repository.
#                     A leading "file://" will be removed such that the svn
#                     command treats it as a local path.
# @param [out] STATUS The status of URL as returned by 'svn status'.
#                     If the local directory or file is unmodified, an
#                     empty string is returned. An empty string is also
#                     returned when Subversion_SVN_EXECUTABLE is invalid.
#
# @returns Sets @p STATUS to the output of the <tt>svn info</tt> command.
function (basis_svn_status URL STATUS)
  if (Subversion_SVN_EXECUTABLE)
    # remove "file://" from URL
    string (REGEX REPLACE "file://" "" TMP "${URL}")

    # retrieve SVN status of URL
    execute_process (
      COMMAND         "${Subversion_SVN_EXECUTABLE}" status "${TMP}"
      OUTPUT_VARIABLE OUT
      ERROR_QUIET
    )

    # return
    set ("${STATUS}" "${OUT}" PARENT_SCOPE)
  else ()
    set ("${STATUS}" "" PARENT_SCOPE)
  endif ()
endfunction ()

# ============================================================================
# Git
# ============================================================================



## @}
# end of Doxygen group
