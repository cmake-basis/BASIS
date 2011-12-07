##############################################################################
# @file  MatlabTools.cmake
# @brief Enables use of MATLAB Compiler and build of MEX-files.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeTools
##############################################################################

if (__BASIS_MATLABTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_MATLABTOOLS_INCLUDED TRUE)
endif ()


# ============================================================================
# options
# ============================================================================

## @addtogroup BasisSettings
#  @{


## @brief Enable/Disable invocation of MATLAB Compiler in MATLAB mode.
option (
  BASIS_MCC_MATLAB_MODE
  "Prefer MATLAB mode over standalone mode to invoke MATLAB Compiler."
  "ON" # prefer as it releases the license immediately once done
)

mark_as_advanced (BASIS_MCC_MATLAB_MODE)


## @}
# end of Doxygen group


# ============================================================================
# build configuration
# ============================================================================

## @addtogroup BasisSettings
#  @{


## @brief Script used to invoke the MATLAB Compiler in MATLAB mode.
set (BASIS_SCRIPT_MCC "${CMAKE_CURRENT_LIST_DIR}/runmcc.m")

## @brief Compile flags used to build MATLAB Compiler targets.
set (
  BASIS_MCC_FLAGS
    "-v -R -singleCompThread"
  CACHE STRING
    "Common MATLAB Compiler flags (separated by ' '; use '\\' to mask ' ')."
)

## @brief Compile flags used to build MEX-files using the MEX script.
set (
  BASIS_MEX_FLAGS
    "-v"
  CACHE STRING
    "Common MEX switches (separated by ' '; use '\\' to mask ' ')."
)

## @brief Timeout for building MATLAB Compiler targets.
set (BASIS_MCC_TIMEOUT "600" CACHE STRING "Timeout for MATLAB Compiler execution")
## @brief Timeout for building MEX-file targets.
set (BASIS_MEX_TIMEOUT "600" CACHE STRING "Timeout for MEX script execution")

mark_as_advanced (BASIS_MCC_FLAGS)
mark_as_advanced (BASIS_MEX_FLAGS)
mark_as_advanced (BASIS_MCC_TIMEOUT)
mark_as_advanced (BASIS_MEX_TIMEOUT)


## @}
# end of Doxygen group


# ============================================================================
# utilities
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Determine version of MATLAB installation.
#
# @param [out] VERSION Value returned by the "version" command of MATLAB or
#                      an empty string if execution of MATLAB failed.
#
# @returns Sets the variable named by @p VERSION to the full MATLAB version.
#
# @ingroup CMakeUtilities
function (basis_get_full_matlab_version VERSION)
  if (NOT MATLAB_EXECUTABLE)
    message (FATAL_ERROR "MATLAB_EXECUTABLE not found. Forgot to add MATLAB as dependency?")
  endif ()

  set (OUTPUT_FILE "${CMAKE_BINARY_DIR}/MatlabVersion.txt")
  # run matlab command to write return value of "version" command to text file
  if (NOT EXISTS "${OUTPUT_FILE}")
    set (CMD "${MATLAB_EXECUTABLE}" "-nodesktop" "-nosplash")
    if (WIN32)
      list (APPEND CMD "-automation")
    endif ()
    list (APPEND CMD "-r")
    set (MATLAB_CMD
      "fid = fopen ('${OUTPUT_FILE}', 'w')"
      "fprintf (fid, '%s', version)"
      "fclose (fid)"
      "exit"
    )
    message (STATUS "Determining MATLAB version...")
    execute_process (
      COMMAND         ${CMD} "${MATLAB_CMD}"
      RESULT_VARIABLE RETVAL
      OUTPUT_QUIET
      ERROR_QUIET
    )
    if (NOT RETVAL EQUAL 0)
      set (VERSION "" PARENT_SCOPE)
      message (STATUS "Determining MATLAB version... - failed")
      return ()
    endif ()
    message (STATUS "Determining MATLAB version... - done")
  endif ()
  # read MATLAB version from text file
  file (READ "${OUTPUT_FILE}" VERSION)
  # return
  set (VERSION "${VERSION}" PARENT_SCOPE)
endfunction ()

# ----------------------------------------------------------------------------
## @brief Determine version of MATLAB installation.
#
# @param [out] ARGN The first argument ARGV0 is set to the version of the
#                   MATLAB installation, i.e., "7.9.0", for example, or an
#                   empty string if execution of MATLAB failed.
#                   If no output variable name is specified, the variable
#                   MATLAB_VERSION is added to the cache if not present yet.
#                   Note that if no output variable is given and MATLAB_VERSION
#                   is already set, nothing is done.
#
# @returns Sets the variable named by the first argument to the determined
#          MATLAB version.
#
# @ingroup CMakeUtilities
function (basis_get_matlab_version)
  if (ARGC GREATER 1)
    message (FATAL_ERROR "basis_get_matlab_version (): Invalid number of arguments.")
  endif ()
  if (ARGC EQUAL 0 AND MATLAB_VERSION)
    return ()
  endif ()
  basis_get_full_matlab_version (VERSION)
  if (VERSION MATCHES "^([0-9]+\\.[0-9]+\\.[0-9]+)")
    set (VERSION "${CMAKE_MATCH_1}")
  else ()
    set (VERSION "")
  endif ()
  if (ARGC EQUAL 1)
    set (${ARGV0} "${VERSION}" PARENT_SCOPE)
  else ()
    set (MATLAB_VERSION "${VERSION}" CACHE STRING "The version string of the MATLAB installation." FORCE)
    mark_as_advanced (MATLAB_VERSION)
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Determine release version of MATLAB installation.
#
# @param [out] ARGN The first argument ARGV0 is set to the release version of
#                   the MATLAB installation, i.e., "R2009b", for example,
#                   or an empty string if execution of MATLAB failed.
#                   If no output variable name is specified, the variable
#                   MATLAB_RELEASE is added to the cache if not present yet.
#                   Note that if no output variable is given and MATLAB_RELEASE
#                   is already set, nothing is done.
#
# @returns Sets the variable named by the first argument to the release version
#          of MATLAB.
#
# @ingroup CMakeUtilities
function (basis_get_matlab_release)
  if (ARGC GREATER 1)
    message (FATAL_ERROR "basis_get_matlab_release (): Invalid number of arguments.")
  endif ()
  if (ARGC EQUAL 0 AND MATLAB_RELEASE)
    return ()
  endif ()
  basis_get_full_matlab_version (VERSION)
  if (VERSION MATCHES ".*\\\((.+)\\\)")
    set (RELEASE "${CMAKE_MATCH_1}")
  else ()
    set (RELEASE "")
  endif ()
  if (ARGC EQUAL 1)
    set (${ARGV0} "${RELEASE}" PARENT_SCOPE)
  else ()
    set (MATLAB_RELEASE "${RELEASE}" CACHE STRING "The release version of the MATLAB installation." FORCE)
    mark_as_advanced (MATLAB_RELEASE)
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Determine extension of MEX-files for this architecture.
#
# @param [out] ARGN The first argument ARGV0 is set to the extension of
#                   MEX-files (excluding '.'). If the CMake variable MEX_EXT
#                   is set, its value is returned. Otherwise, this function
#                   tries to determine it from the system information.
#                   If the extension could not be determined, an empty string
#                   is returned. If no argument is given, the extension is
#                   cached as the variable MEX_EXT.
#
# @returns Sets the variable named by the first argument to the
#          platform-specific extension of MEX-files.
#
# @ingroup CMakeUtilities
function (basis_mexext)
  # default return value
  set (MEXEXT "${MEX_EXT}")

  # use MEXEXT if possible
  if (NOT MEXEXT AND MATLAB_MEXEXT_EXECUTABLE)
    execute_process (
      COMMAND         "${MATLAB_MEXEXT_EXECUTABLE}"
      RESULT_VARIABLE RETVAL
      OUTPUT_VARIABLE MEXEXT
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if (RETVAL)
      set (MEXEXT "")
    endif ()
  endif ()

  # otherwise, determine extension given CMake variables describing the system
  if (NOT MEXEXT)
    if (CMAKE_SYSTEM_NAME MATCHES "Linux")
      if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        set (MEXEXT "mexa64")
      elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "x86" OR
              CMAKE_SYSTEM_PROCESSOR MATCHES "i686")
        set (MEXEXT "mexglx")
      endif ()
    elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
      if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        set (MEXEXT "mexw64")
      elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "x86" OR
              CMAKE_SYSTEM_PROCESSOR MATCHES "i686")
        set (MEXEXT "mexw32")
      endif ()
    elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
      if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        set (MEXEXT "mexaci64")
      else ()
        set (MEXEXT "mexaci")
      endif ()
    elseif (CMAKE_SYSTEM_NAME MATCHES "SunOS")
      set (MEXEXT "mexs64")
    endif ()
  endif ()

  # return value
  if (ARGC GREATER 0)
    set ("${ARGV0}" "${MEXEXT}" PARENT_SCOPE)
  else ()
    if (NOT DEFINED MEX_EXT)
      set (MARKIT 1)
    else ()
      set (MARKIT 0)
    endif ()
    set (MEX_EXT "${MEXEXT}" CACHE STRING "The extension of MEX-files for this architecture." FORCE)
    if (MARKIT)
      mark_as_advanced (MEX_EXT)
    endif ()
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief This function writes a MATLAB M-file with addpath() statements.
#
# This function writes an MATLAB M-file into the top directory of the build
# tree which contains an addpath() statement for each directory that was added
# via basis_include_directories().
#
# @returns Creates file add_\<project\>_paths.m in the current binary directory.
#
# @ingroup CMakeUtilities
function (basis_create_addpaths_mfile)
  set (MFILE "${CMAKE_CURRENT_BINARY_DIR}/add_${PROJECT_NAME_LOWER}_paths.m")
  file (WRITE "${MFILE}" "% DO NOT edit. This file is automatically generated by BASIS.\n")
  basis_get_project_property (INCLUDE_DIRS PROPERTY PROJECT_INCLUDE_DIRS)
  foreach (P IN LISTS INCLUDE_DIRS)
    file (APPEND "${MFILE}" "addpath ('${P}');\n")
  endforeach ()
endfunction ()

# ============================================================================
# MEX target
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add MEX target.
#
# This function is used to add a shared library target which is built
# using the MATLAB MEX script (mex). It is invoked by basis_add_library().
# Thus, it is recommended to use this function instead.
#
# An install command for the added library target is added by this function
# as well. The MEX-file will be installed as part of the @p COMPONENT
# in the directory INSTALL_LIBRARY_DIR on UNIX systems and INSTALL_RUNTIME_DIR
# on Windows.
#
# @note The custom build command is not added yet by this function.
#       Only a custom target which stores all the information required to
#       setup this build command is added. The custom command is added
#       by either basis_project_finalize() or basis_superproject_finalize().
#       This way, the properties such as the OUTPUT_NAME of the custom
#       target can be still modified.
#
# @param [in] TARGET_NAME Name of the target. If a source file is given
#                         as first argument, the build target name is derived
#                         from the name of this source file.
# @param [in] ARGN        Remaining arguments such as in particular the
#                         input source files. Moreover, the following arguments
#                         are parsed:
# @par
# <table border="0">
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of the component. Default: @c BASIS_LIBRARY_COMPONENT.</td>
#   </tr>
#   <tr>
#     @tp @b MFILE file @endtp
#     <td>MATLAB source file with function prototype and documentation of MEX-file.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export the target.</td>
#   </tr>
# </table>
#
# @returns Adds custom target to build MEX-file using the MEX script.
#
# @sa basis_add_library()
#
# @ingroup CMakeUtilities
function (basis_add_mex_target TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "NO_EXPORT"
      "COMPONENT;MFILE"
      ""
    ${ARGN}
  )

  if (NOT ARGN_NO_EXPORT)
    set (ARGN_NO_EXPORT FALSE)
  endif ()

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (ARGN_MFILE)
    get_filename_component (ARGN_MFILE "${ARGN_MFILE}" ABSOLUTE)
  endif ()

  set (SOURCES)
  get_filename_component (S "${TARGET_NAME}" ABSOLUTE)
  if (NOT ARGN_UNPARSED_ARGUMENTS OR EXISTS "${S}")
    list (APPEND ARGN_UNPARSED_ARGUMENTS "${TARGET_NAME}")
    basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME_WE)
  endif ()
  foreach (SOURCE ${ARGN_UNPARSED_ARGUMENTS})
    get_filename_component (P "${SOURCE}" ABSOLUTE)
    list (APPEND SOURCES "${P}")
  endforeach ()

  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")

  if (BASIS_VERBOSE)
    message (STATUS "Adding MEX-file ${TARGET_UID}...")
  endif ()

  # required commands available ?
  if (NOT MATLAB_MEX_EXECUTABLE)
    message (FATAL_ERROR "MATLAB MEX script (mex) not found. It is required to build target ${TARGET_UID}."
                         " Forgot to add MATLAB as dependency? Otherwise, set MATLAB_MEX_EXECUTABLE manually and try again.")
  endif ()
 
  # MEX flags
  basis_mexext (MEXEXT)

  # configure .in source files
  basis_configure_sources (SOURCES ${SOURCES})

  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${SOURCES})

  # set target properties required by basis_add_mex_target_finalize ()
  get_directory_property (INCLUDE_DIRS INCLUDE_DIRECTORIES)
  get_directory_property (LINK_DIRS LINK_DIRECTORIES)

  _set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      BASIS_TYPE                "MEX"
      PREFIX                    ""
      SUFFIX                    ".${MEXEXT}"
      VERSION                   "${PROJECT_VERSION}"
      SOVERSION                 "${PROJECT_SOVERSION}"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${CMAKE_CURRENT_BINARY_DIR}"
      RUNTIME_OUTPUT_DIRECTORY  "${BINARY_RUNTIME_DIR}"
      LIBRARY_OUTPUT_DIRECTORY  "${BINARY_LIBRARY_DIR}"
      RUNTIME_INSTALL_DIRECTORY "${RUNTIME_INSTALL_DIR}"
      LIBRARY_INSTALL_DIRECTORY "${INSTALL_LIBRARY_DIR}"
      BASIS_INCLUDE_DIRECTORIES "${INCLUDE_DIRS}"
      BASIS_LINK_DIRECTORIES    "${LINK_DIRS}"
      COMPILE_FLAGS             "${BASIS_MEX_FLAGS}"
      LINK_FLAGS                ""
      LINK_DEPENDS              ""
      LIBRARY_COMPONENT         "${ARGN_COMPONENT}"
      MFILE                     "${ARGN_MFILE}"
      TEST                      "0" # MEX-files cannot be used for testing only yet
      NO_EXPORT                 "${ARGN_NO_EXPORT}"
  )

  # add target to list of targets
  basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET_UID}")

  if (BASIS_VERBOSE)
    message (STATUS "Adding MEX-file ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Finalize addition of MEX target.
#
# This function uses the properties of the custom MEX-file target added by
# basis_add_mex_target() to create the custom build command and adds this
# build command as dependency of this added target.
#
# @param [in] TARGET_UID "Global" target name. If this function is used
#                        within the same project as basis_add_mex_target(),
#                        the "local" target name may be given alternatively.
#
# @returns Adds custom targets corresponding to the custom target added by
#          basis_add_mex_target() which actually perform the invocation of
#          the MEX script.
#
# @sa basis_add_mex_target()
#
# @ingroup CMakeUtilities
function (basis_add_mex_target_finalize TARGET_UID)
  # if used within (sub-)project itself, allow user to specify "local" target name
  basis_get_target_uid (TARGET_UID "${TARGET_UID}")

  # finalized before ?
  if (TARGET "_${TARGET_UID}")
    return ()
  endif ()

  # does this target exist ?
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown target ${TARGET_UID}.")
    return ()
  endif ()

  # get target properties
  basis_get_target_name (TARGET_NAME ${TARGET_UID})

  set (
    PROPERTIES
      "BASIS_TYPE"
      "SOURCE_DIRECTORY"
      "BINARY_DIRECTORY"
      "RUNTIME_OUTPUT_DIRECTORY"
      "LIBRARY_OUTPUT_DIRECTORY"
      "RUNTIME_INSTALL_DIRECTORY"
      "LIBRARY_INSTALL_DIRECTORY"
      "PREFIX"
      "OUTPUT_NAME"
      "SUFFIX"
      "VERSION"
      "SOVERSION"
      "BASIS_INCLUDE_DIRECTORIES"
      "BASIS_LINK_DIRECTORIES"
      "SOURCES"
      "COMPILE_FLAGS"
      "LINK_DEPENDS"
      "LINK_FLAGS"
      "LIBRARY_COMPONENT"
      "MFILE"
      "TEST"
      "NO_EXPORT"
  )

  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()

  if (NOT BASIS_TYPE MATCHES "^MEX$")
    message (FATAL_ERROR "Target ${TARGET_UID} has invalid BASIS_TYPE: ${BASIS_TYPE}")
  endif ()

  if (BASIS_VERBOSE)
    message (STATUS "Adding build command for MEX-file ${TARGET_UID}...")
  endif ()

  # build directory
  list (GET SOURCES 0 BUILD_DIR)
  set (BUILD_DIR "${BUILD_DIR}.dir")

  list (REMOVE_AT SOURCES 0)

  # output name
  if (NOT OUTPUT_NAME)
    set (OUTPUT_NAME "${TARGET_NAME}")
  endif ()
  if (PREFIX)
    set (OUTPUT_NAME "${PREFIX}${OUTPUT_NAME}")
  endif ()
  if (SUFFIX)
    set (OUTPUT_NAME "${OUTPUT_NAME}${SUFFIX}")
  endif ()

  # initialize dependencies of custom build command
  set (DEPENDS ${SOURCES})

  # get list of libraries to link to
  set (LINK_LIBS)

  foreach (LIB ${LINK_DEPENDS})
    basis_get_target_uid (UID "${LIB}")
    if (TARGET ${UID})
      basis_get_target_location (LIB_FILE ${UID} ABSOLUTE)
      list (APPEND DEPENDS ${UID})
    else ()
      set (LIB_FILE "${LIB}")
    endif ()
    list (APPEND LINK_LIBS "${LIB_FILE}")
  endforeach ()

  get_filename_component (OUTPUT_NAME_WE "${OUTPUT_NAME}" NAME_WE)

  # decompose user supplied MEX switches
  macro (extract VAR)
    string (REGEX REPLACE "${VAR}=\"([^\"]+)\"|${VAR}=([^\" ])*" "" COMPILE_FLAGS "${COMPILE_FLAGS}")
    if (CMAKE_MATCH_1)
      set (${VAR} "${CMAKE_MATCH_1}")
    elseif (CMAKE_MATCH_2)
      set (${VAR} "${CMAKE_MATCH_2}")
    else ()
      set (${VAR})
    endif ()
  endmacro ()

  extract (CC)
  extract (CFLAGS)
  extract (CXX)
  extract (CXXFLAGS)
  extract (CLIBS)
  extract (CXXLIBS)
  extract (LD)
  extract (LDFLAGS)

  if (LINK_FLAGS)
    set (LDFLAGS "${LDFLAGS} ${LINK_FLAGS}")
  endif ()

  # set defaults for not provided options
  if (NOT CC)
    set (CC "${CMAKE_C_COMPILER}")
  endif ()
  if (NOT CFLAGS)
    set (CFLAGS "${CMAKE_C_FLAGS}")
  endif ()
  if (NOT CFLAGS MATCHES "( |^)-fPIC( |$)")
    set (CFLAGS "-fPIC ${CFLAGS}")
  endif ()
  if (NOT CXX)
    set (CXX "${CMAKE_CXX_COMPILER}")
  endif ()
  if (NOT CXXFLAGS)
    set (CXXFLAGS "${CMAKE_CXX_FLAGS}")
  endif ()
  if (NOT CXXFLAGS MATCHES "( |^)-fPIC( |$)")
    set (CXXFLAGS "-fPIC ${CXXFLAGS}")
  endif ()

  # We chose to use CLIBS and CXXLIBS instead of the -L and -l switches
  # to add also link libraries added via basis_target_link_libraries ()
  # because the MEX script will not use these arguments if CLIBS or CXXLIBS
  # is set. Moreover, the -l switch can only be used to link to a shared
  # library and not a static one (on UNIX).
  #foreach (LIB ${LINK_LIBS})
  #  if (LIB MATCHES "[/\\\.]")
  #    set (CXXLIBS "${CXXLIBS} ${LIB}")
  #  endif ()
  #endforeach ()

  # get remaining switches
  basis_string_to_list (MEX_USER_ARGS "${COMPILE_FLAGS}")

  # assemble MEX switches
  set (MEX_ARGS)

  list (APPEND MEX_ARGS "CC=${CC}" "CFLAGS=${CFLAGS}")         # C compiler and flags
  if (CLIBS)
    list (APPEND MEX_ARGS "CLIBS=${CLIBS}")                      # C link libraries
  endif ()
  list (APPEND MEX_ARGS "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS}")     # C++ compiler and flags
  if (CXXLIBS)
    list (APPEND MEX_ARGS "CXXLIBS=${CXXLIBS}")                  # C++ link libraries
  endif ()
  if (LD)
    list (APPEND MEX_ARGS "LD=${LD}")
  endif ()
  if (LDFLAGS)
    list (APPEND MEX_ARGS "LDFLAGS=${LDFLAGS}")
  endif ()
  list (APPEND MEX_ARGS "-outdir" "${BUILD_DIR}")                # output directory
  list (APPEND MEX_ARGS "-output" "${OUTPUT_NAME_WE}")           # output name (w/o extension)
  foreach (INCLUDE_PATH ${BASIS_INCLUDE_DIRECTORIES})            # include directories
    list (FIND MEX_ARGS "-I${INCLUDE_PATH}" IDX)                 # as specified via
    if (INCLUDE_PATH AND IDX EQUAL -1)                           # basis_include_directories ()
      list (APPEND MEX_ARGS "-I${INCLUDE_PATH}")
    endif ()
  endforeach ()
  foreach (LIBRARY_PATH ${BASIS_LINK_DIRECTORIES})               # link directories
    list (FIND MEX_ARGS "-L${LIBRARY_PATH}" IDX)                 # as specified via
    if (LIBRARY_PATH AND IDX EQUAL -1)                           # basis_link_directories ()
      list (APPEND MEX_ARGS "-L${LIBRARY_PATH}")
    endif ()
  endforeach ()
  foreach (LIBRARY ${LINK_LIBS})                                 # link libraries
    get_filename_component (LINK_DIR "${LIBRARY}" PATH)         # as specified via
    get_filename_component (LINK_LIB "${LIBRARY}" NAME_WE)      # basis_target_link_libraries ()
    string (REGEX REPLACE "^-l" "" LINK_LIB "${LINK_LIB}")
    if (UNIX)
      string (REGEX REPLACE "^lib" "" LINK_LIB "${LINK_LIB}")
    endif ()
    list (FIND MEX_ARGS "-L${LINK_DIR}" IDX)
    if (LINK_DIR AND IDX EQUAL -1)
      list (APPEND MEX_ARGS "-L${LINK_DIR}")
    endif ()
    list (FIND MEX_ARGS "-l${LINK_LIB}" IDX)
    if (LINK_LIB AND IDX EQUAL -1)
      list (APPEND MEX_ARGS "-l${LINK_LIB}")
    endif ()
  endforeach ()
  list (APPEND MEX_ARGS ${MEX_USER_ARGS})                        # other user switches
  list (APPEND MEX_ARGS ${SOURCES})                              # source files

  # build command for invocation of MEX script
  set (BUILD_CMD     "${MATLAB_MEX_EXECUTABLE}" ${MEX_ARGS})
  set (BUILD_LOG     "${BUILD_DIR}/mexBuild.log")
  set (BUILD_OUTPUT  "${LIBRARY_OUTPUT_DIRECTORY}/${OUTPUT_NAME}")
  set (BUILD_OUTPUTS "${BUILD_OUTPUT}")

  if (MFILE)
    set (BUILD_MFILE "${LIBRARY_OUTPUT_DIRECTORY}/${OUTPUT_NAME_WE}.m")
    list (APPEND BUILD_OUTPUTS "${BUILD_MFILE}")
  else ()
    set (BUILD_MFILE)
  endif ()

  # relative paths used for comments of commands
  file (RELATIVE_PATH REL "${CMAKE_BINARY_DIR}" "${BUILD_DIR}/${OUTPUT_NAME}")

  # add custom command to build executable using MEX script
  add_custom_command (
    OUTPUT "${BUILD_OUTPUT}"
    # rebuild when input sources were modified
    DEPENDS ${DEPENDS}
    # invoke MEX script, wrapping the command in CMake execute_process()
    # command allows for inspection of command output for error messages
    # and specification of timeout
    COMMAND "${CMAKE_COMMAND}"
            "-DCOMMAND=${BUILD_CMD}"
            "-DWORKING_DIRECTORY=${BUILD_DIR}"
            "-DTIMEOUT=${BASIS_MEX_TIMEOUT}"
            "-DERROR_EXPRESSION=[E|e]rror"
            "-DOUTPUT_FILE=${BUILD_LOG}"
            "-DERROR_FILE=${BUILD_LOG}"
            "-DVERBOSE=OFF"
            "-DLOG_ARGS=ON"
            "-P" "${BASIS_SCRIPT_EXECUTE_PROCESS}"
    # post-build command
    COMMAND "${CMAKE_COMMAND}" -E copy   "${BUILD_DIR}/${OUTPUT_NAME}" "${BUILD_OUTPUT}"
    COMMAND "${CMAKE_COMMAND}" -E remove "${BUILD_DIR}/${OUTPUT_NAME}"
    # inform user where build log can be found
    COMMAND "${CMAKE_COMMAND}" -E echo "Build log written to ${BUILD_LOG}"
    # comment
    COMMENT "Building MEX-file ${REL}..."
    VERBATIM
  )

  if (BUILD_MFILE)
    add_custom_command (
      OUTPUT  "${BUILD_MFILE}"
      DEPENDS "${MFILE}"
      COMMAND "${CMAKE_COMMAND}" -E copy "${MFILE}" "${BUILD_MFILE}"
      COMMENT "Copying M-file of MEX-file ${REL}..."
    )
  endif ()

  # add custom target
  if (TARGET "_${TARGET_UID}")
    message (FATAL_ERROR "There is another target named _${TARGET_UID}. "
                         "BASIS uses target names starting with an underscore "
                         "for custom targets which are required to build MEX-files. "
                         "Do not use leading underscores in target names.")
  endif ()

  add_custom_target (
    _${TARGET_UID}
    DEPENDS ${BUILD_OUTPUTS}
    SOURCES ${SOURCES}
  )

  add_dependencies (${TARGET_UID} _${TARGET_UID})

  # cleanup on "make clean"
  set_property (
    DIRECTORY
    APPEND PROPERTY
      ADDITIONAL_MAKE_CLEAN_FILES
        "${BUILD_DIR}/${OUTPUT_NAME}"
        "${BUILD_OUTPUTS}"
        "${BUILD_LOG}"
  )

  # install MEX-file
  if (NOT NO_EXPORT)
    if (TEST)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    else ()
      basis_set_project_property (APPEND PROPERTY CUSTOM_EXPORT_TARGETS "${TARGET_UID}")
    endif ()
  endif ()

  install (
    FILES       ${BUILD_OUTPUTS}
    DESTINATION "${LIBRARY_INSTALL_DIRECTORY}"
    COMPONENT   "${LIBRARY_COMPONENT}"
  )

  if (BASIS_VERBOSE)
    message (STATUS "Adding build command for MEX-file ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ============================================================================
# MATLAB Compiler target
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Add MATLAB Compiler target.
#
# This function is used to add an executable or library target which is built
# using the MATLAB Compiler (MCC). It is invoked by basis_add_executable()
# or basis_add_library(), respectively, when at least one M-file is given
# as source file. Thus, it is recommended to use these functions instead.
#
# An install command for the added executable or library target is added by
# this function as well. The executable will be installed as part of the
# @p RUNTIME_COMPONENT in the directory @c INSTALL_RUNTIME_DIR. The runtime
# library will be installed as part of the @p RUNTIME_COMPONENT in the directory
# @c INSTALL_LIBRARY_DIR on UNIX systems and @c INSTALL_RUNTIME_DIR on Windows.
# Static/import libraries will be installed as part of the @p LIBRARY_COMPONENT
# in the directory @c INSTALL_ARCHIVE_DIR.
#
# @note The custom build command is not added yet by this function.
#       Only a custom target which stores all the information required to
#       setup this build command is added. The custom command is added
#       by either basis_project_finalize() or basis_superproject_finalize().
#       This way, the properties such as the @c OUTPUT_NAME of the custom
#       target can be still modified.
#
# @note If this function is used within the @c PROJECT_TESTING_DIR, the built
#       executable is output to the @c BINARY_TESTING_DIR directory tree instead.
#       Moreover, no installation rules are added. Test executables are further
#       not exported, regardless of whether NO_EXPORT is given or not.
#
# @param [in] TARGET_NAME Name of the target. If a source file is given
#                         as first argument, the build target name is derived
#                         from the name of this source file.
# @param [in] ARGN        Remaining arguments such as in particular the
#                         input source files. Moreover, the following arguments
#                         are parsed:
# @par
# <table border="0">
#   <tr>
#     @tp @b TYPE type @endtp
#     <td>Type of the target. Either @c EXECUTABLE (default) or @c LIBRARY.</td>
#   </tr>
#   <tr>
#     @tp @b COMPONENT name @endtp
#     <td>Name of the component. Default: @c BASIS_RUNTIME_COMPONENT if
#         @p TYPE is @c EXECUTABLE or @c BASIS_LIBRARY_COMPONENT, otherwise.</td>
#   </tr>
#   <tr>
#     @tp @b RUNTIME_COMPONENT name @endtp
#     <td>Name of runtime component. Default: @p COMPONENT if specified or
#         @c BASIS_RUNTIME_COMPONENT, otherwise.</td>
#   </tr>
#   <tr>
#     @tp @b LIBRARY_COMPONENT name @endtp
#     <td>Name of library component. Default: @p COMPONENT if specified or
#         @c BASIS_LIBRARY_COMPONENT, otherwise.</td>
#   </tr>
#   <tr>
#     @tp @b LIBEXEC @endtp
#     <td>Specifies that the built executable is an auxiliary executable
#         called by other executables only.</td>
#   </tr>
#   <tr>
#     @tp @b NO_EXPORT @endtp
#     <td>Do not export the target.</td>
#   </tr>
# </table>
#
# @returns Adds custom target which builds depending on the @p TYPE argument
#          either an executable or a shared library using the MATLAB Compiler.
#
# @sa basis_add_executable()
# @sa basis_add_library()
#
# @ingroup CMakeUtilities
function (basis_add_mcc_target TARGET_NAME)
  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "LIBEXEC;TEST;NO_EXPORT"
      "TYPE;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT"
      ""
    ${ARGN}
  )

  basis_sanitize_for_regex (R "${PROJECT_TESTING_DIR}")
  if (CMAKE_CURRENT_SOURCE_DIR MATCHES "^${R}")
    set (ARGN_TEST TRUE)
  else ()
    if (ARGN_TEST)
      message (FATAL_ERROR "Executable ${TARGET_NAME} cannot have TEST property!"
                           "If it is a test executable, put it in ${PROJECT_TESTING_DIR}.")
    endif ()
    set (ARGN_TEST FALSE)
  endif ()

  if (ARGN_TEST)
    set (ARGN_NO_EXPORT TRUE)
  endif ()
  if (NOT ARGN_NO_EXPORT)
    set (ARGN_NO_EXPORT FALSE)
  endif ()

  if (NOT ARGN_TYPE)
    set (ARGN_TYPE "EXECUTABLE")
  else ()
    string (TOUPPER "${ARGN_TYPE}" ARGN_TYPE)
  endif ()

  if (NOT ARGN_TYPE MATCHES "^EXECUTABLE$|^LIBRARY$")
    message (FATAL_ERROR "Invalid type for MCC target ${TARGET_NAME}: ${ARGN_TYPE}")
  endif ()

  if (NOT ARGN_LIBRARY_COMPONENT AND ARGN_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "${ARGN_COMPONENT}")
  endif ()
  if (NOT ARGN_RUNTIME_COMPONENT AND ARGN_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "${ARGN_COMPONENT}")
  endif ()

  if (NOT ARGN_COMPONENT)
    if (ARGN_TYPE MATCHES "EXECUTABLE")
      set (ARGN_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
    else ()
      set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
    endif ()
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  if (NOT ARGN_LIBRARY_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()
  if (NOT ARGN_LIBRARY_COMPONENT)
    set (ARGN_LIBRARY_COMPONENT "Unspecified")
  endif ()

  if (NOT ARGN_RUNTIME_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "${BASIS_RUNTIME_COMPONENT}")
  endif ()
  if (NOT ARGN_RUNTIME_COMPONENT)
    set (ARGN_RUNTIME_COMPONENT "Unspecified")
  endif ()

  set (SOURCES)
  get_filename_component (S "${TARGET_NAME}" ABSOLUTE)
  if (NOT ARGN_UNPARSED_ARGUMENTS OR EXISTS "${S}")
    list (APPEND ARGN_UNPARSED_ARGUMENTS "${TARGET_NAME}")
    basis_get_source_target_name (TARGET_NAME "${TARGET_NAME}" NAME_WE)
  endif ()
  foreach (ARG ${ARGN_UNPARSED_ARGUMENTS})
    get_filename_component (SOURCE "${ARG}" ABSOLUTE)
    list (APPEND SOURCES "${SOURCE}")
  endforeach ()

  # check target name
  basis_check_target_name ("${TARGET_NAME}")
  basis_make_target_uid (TARGET_UID "${TARGET_NAME}")

  if (BASIS_VERBOSE)
    if (ARGN_TYPE MATCHES "LIBRARY")
      message (STATUS "Adding MATLAB library ${TARGET_UID}...")
      message (FATAL_ERROR "Build of MATLAB library from M-files not yet supported.")
      message (STATUS "Adding MATLAB library ${TARGET_UID}... - failed")
    else ()
      message (STATUS "Adding MATLAB executable ${TARGET_UID}...")
    endif ()
  endif ()

  # required commands available ?
  if (NOT MATLAB_MCC_EXECUTABLE)
    message (FATAL_ERROR "MATLAB Compiler not found. It is required to build target ${TARGET_UID}."
                         " Forgot to add MATLAB as dependency? Otherwise, set MATLAB_MCC_EXECUTABLE manually and try again.")
  endif ()
 
  # MCC flags
  set (COMPILE_FLAGS)

  if (BASIS_MCC_FLAGS)
    string (REPLACE "\\ "    "&nbsp;" COMPILE_FLAGS "${BASIS_MCC_FLAGS}")
    string (REPLACE " "      ";"      COMPILE_FLAGS "${COMPILE_FLAGS}")
    string (REPLACE "&nbsp;" " "      COMPILE_FLAGS "${COMPILE_FLAGS}")
  endif ()

  # configure .in source files
  basis_configure_sources (SOURCES ${SOURCES})

  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${SOURCES})

  # set target properties required by basis_add_mcc_target_finalize ()
  if (ARGN_TYPE MATCHES "LIBRARY")
    set (TYPE "MCC_LIBRARY")
  else ()
    set (TYPE "MCC_EXECUTABLE")
    if (ARGN_TEST)
      set (RUNTIME_INSTALL_DIR "")
      set (RUNTIME_OUTPUT_DIR  "${TESTING_RUNTIME_DIR}")
    elseif (ARGN_LIBEXEC)
      set (RUNTIME_INSTALL_DIR "${INSTALL_LIBEXEC_DIR}")
      set (RUNTIME_OUTPUT_DIR  "${BINARY_LIBEXEC_DIR}")
    else ()
      set (RUNTIME_INSTALL_DIR "${INSTALL_RUNTIME_DIR}")
      set (RUNTIME_OUTPUT_DIR  "${BINARY_RUNTIME_DIR}")
    endif ()
  endif ()

  get_directory_property (INCLUDE_DIRS INCLUDE_DIRECTORIES)
  get_directory_property (LINK_DIRS LINK_DIRECTORIES)

  _set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      BASIS_TYPE                "${TYPE}"
      VERSION                   "${PROJECT_VERSION}"
      SOVERSION                 "${PROJECT_SOVERSION}"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${CMAKE_CURRENT_BINARY_DIR}"
      RUNTIME_OUTPUT_DIRECTORY  "${RUNTIME_OUTPUT_DIR}"
      LIBRARY_OUTPUT_DIRECTORY  "${BINARY_LIBRARY_DIR}"
      RUNTIME_INSTALL_DIRECTORY "${RUNTIME_INSTALL_DIR}"
      LIBRARY_INSTALL_DIRECTORY "${INSTALL_LIBRARY_DIR}"
      BASIS_INCLUDE_DIRECTORIES "${INCLUDE_DIRS}"
      BASIS_LINK_DIRECTORIES    "${LINK_DIRS}"
      COMPILE_FLAGS             "${COMPILE_FLAGS}"
      LINK_DEPENDS              ""
      RUNTIME_COMPONENT         "${ARGN_RUNTIME_COMPONENT}"
      LIBRARY_COMPONENT         "${ARGN_LIBRARY_COMPONENT}"
      NO_EXPORT                 "${ARGN_NO_EXPORT}"
  )

  if (ARGN_LIBEXEC)
    _set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 1)
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES LIBEXEC 0)
  endif ()

  if (ARGN_TEST)
    _set_target_properties (${TARGET_UID} PROPERTIES TEST 1)
  else ()
    _set_target_properties (${TARGET_UID} PROPERTIES TEST 0)
  endif ()

  # add target to list of targets
  basis_set_project_property (APPEND PROPERTY TARGETS "${TARGET_UID}")

  if (BASIS_VERBOSE)
    if (ARGN_TYPE MATCHES "LIBRARY")
      message (STATUS "Adding MATLAB library ${TARGET_UID}... - done")
    else ()
      message (STATUS "Adding MATLAB executable ${TARGET_UID}... - done")
    endif ()
  endif ()
endfunction ()

# ----------------------------------------------------------------------------
## @brief Finalize addition of MATLAB Compiler target.
#
# This function uses the properties of the custom MATLAB Compiler target
# added by basis_add_mcc_target() to create the custom build command and
# adds this build command as dependency of this added target.
#
# @param [in] TARGET_UID "Global" target name. If this function is used
#                        within the same project as basis_add_mcc_target(),
#                        the "local" target name may be given alternatively.
#
# @returns Adds custom target(s) which actually performs the invocation
#          of the MATLAB Compiler using the values of the properties of
#          the target with UID @p TARGET_UID.
#
# @sa basis_add_mcc_target()
#
# @ingroup CMakeUtilities
function (basis_add_mcc_target_finalize TARGET_UID)
  # if used within (sub-)project itself, allow user to specify "local" target name
  basis_get_target_uid (TARGET_UID "${TARGET_UID}")

  # finalized before ?
  if (TARGET "_${TARGET_UID}")
    return ()
  endif ()

  # does this target exist ?
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown target ${TARGET_UID}.")
    return ()
  endif ()

  # get target properties
  basis_get_target_name (TARGET_NAME ${TARGET_UID})

  set (
    PROPERTIES
      "BASIS_TYPE"
      "SOURCE_DIRECTORY"
      "BINARY_DIRECTORY"
      "RUNTIME_OUTPUT_DIRECTORY"
      "LIBRARY_OUTPUT_DIRECTORY"
      "RUNTIME_INSTALL_DIRECTORY"
      "LIBRARY_INSTALL_DIRECTORY"
      "PREFIX"
      "OUTPUT_NAME"
      "SUFFIX"
      "VERSION"
      "SOVERSION"
      "BASIS_INCLUDE_DIRECTORIES"
      "BASIS_LINK_DIRECTORIES"
      "SOURCES"
      "COMPILE_FLAGS"
      "LINK_DEPENDS"
      "RUNTIME_COMPONENT"
      "LIBRARY_COMPONENT"
      "LIBEXEC"
      "TEST"
      "NO_EXPORT"
  )

  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()

  if (NOT BASIS_TYPE MATCHES "^MCC_")
    message (FATAL_ERROR "Target ${TARGET_UID} has invalid BASIS_TYPE: ${BASIS_TYPE}")
  endif ()

  if (BASIS_TYPE MATCHES "MCC_LIBRARY")
    set (TYPE "LIBRARY")
  else ()
    set (TYPE "EXECUTABLE")
  endif ()

  if (BASIS_VERBOSE)
    if (TYPE MATCHES "LIBRARY")
      message (STATUS "Adding build command for MATLAB library ${TARGET_UID}...")
    elseif (TYPE MATCHES "EXECUTABLE")
      message (STATUS "Adding build command for MATLAB executable ${TARGET_UID}...")
    else ()
      message (FATAL_ERROR "Target ${TARGET_UID} has invalid TYPE: ${TYPE}")
    endif ()
  endif ()

  # build directory
  list (GET SOURCES 0 BUILD_DIR)
  set (BUILD_DIR "${BUILD_DIR}.dir")

  list (REMOVE_AT SOURCES 0)

  # output name
  if (NOT OUTPUT_NAME)
    set (OUTPUT_NAME "${TARGET_NAME}")
  endif ()
  if (PREFIX)
    set (OUTPUT_NAME "${PREFIX}${OUTPUT_NAME}")
  endif ()
  if (SUFFIX)
    set (OUTPUT_NAME "${OUTPUT_NAME}${SUFFIX}")
  endif ()

  # initialize dependencies of custom build command
  set (DEPENDS ${SOURCES})

  # get list of libraries to link to (e.g., MEX-file)
  set (LINK_LIBS)

  foreach (LIB ${LINK_DEPENDS})
    basis_get_target_uid (UID "${LIB}")
    if (TARGET ${UID})
      basis_get_target_location (LIB_FILE ${UID} ABSOLUTE)
      list (APPEND DEPENDS ${UID})
    else ()
      set (LIB_FILE "${LIB}")
    endif ()
    list (APPEND LINK_LIBS "${LIB_FILE}")
  endforeach ()

  # assemble build command
  set (MCC_ARGS ${COMPILE_FLAGS})                     # user specified flags
  foreach (INCLUDE_PATH ${BASIS_INCLUDE_DIRECTORIES}) # add directories added via
    list (FIND MCC_ARGS "${INCLUDE_PATH}" IDX)        # basis_include_directories ()
    if (EXISTS "${INCLUDE_PATH}" AND IDX EQUAL -1)    # function to search path
      list (APPEND MCC_ARGS "-I" "${INCLUDE_PATH}")
    endif ()
  endforeach ()
  list (FIND BASIS_INCLUDE_DIRECTORIES "${SOURCE_DIRECTORY}" IDX)
  if (IDX EQUAL -1)
    # add current source directory to search path,
    # needed for build in MATLAB mode as working directory
    # differs from the current source directory then
    list (APPEND MCC_ARGS "-I" "${SOURCE_DIRECTORY}")
  endif ()
  if (TYPE MATCHES "LIBRARY")
    list (APPEND MCC_ARGS "-l")                       # build library
  else ()
    list (APPEND MCC_ARGS "-m")                       # build standalone application
  endif ()
  list (APPEND MCC_ARGS "-d" "${BUILD_DIR}")          # output directory
  list (APPEND MCC_ARGS "-o" "${OUTPUT_NAME}")        # output name
  list (APPEND MCC_ARGS ${SOURCES})                   # source (M-)files
  foreach (LIB ${LINK_LIBS})                          # link libraries, e.g. MEX-files
    list (FIND MCC_ARGS "${LIB}" IDX)
    if (LIB AND IDX EQUAL -1)
      list (APPEND MCC_ARGS "-a" "${LIB}")
    endif ()
  endforeach ()
  #list (APPEND MCC_ARGS ${LINK_LIBS})                 # link libraries, e.g. MEX-files

  # build command for invocation of MATLAB Compiler in standalone mode
  set (BUILD_CMD   "${MATLAB_MCC_EXECUTABLE}" ${MCC_ARGS})
  set (BUILD_LOG   "${BUILD_DIR}/mccBuild.log")
  set (WORKING_DIR "${SOURCE_DIRECTORY}")
  set (MATLAB_MODE OFF)

  # build command for invocation of MATLAB Compiler in MATLAB mode
  if (BASIS_MCC_MATLAB_MODE)
    set (MATLAB_MODE ON)

    if (NOT MATLAB_EXECUTABLE)
      message (WARNING "MATLAB executable not found. It is required to build target ${TARGET_UID} in MATLAB mode."
                       " Forgot to MATLAB as dependency? Otherwise, set MATLAB_EXECUTABLE manually and try again or set BASIS_MCC_MATLAB_MODE to OFF."
                       " Will build target ${TARGET_UID} in standalone mode instead.")
      set (MATLAB_MODE OFF)
    endif ()

    if (MATLAB_MODE)
      get_filename_component (WORKING_DIR "${BASIS_SCRIPT_MCC}" PATH)
      get_filename_component (MFUNC       "${BASIS_SCRIPT_MCC}" NAME_WE)

      set (MATLAB_CMD "${MFUNC} -q") # -q option quits MATLAB when build is finished
      foreach (MCC_ARG ${MCC_ARGS})
        set (MATLAB_CMD "${MATLAB_CMD} ${MCC_ARG}")
      endforeach ()

      set (
        BUILD_CMD
          "${MATLAB_EXECUTABLE}" # run MATLAB
          "-nosplash"            # do not display splash screen on start up
          "-nodesktop"           # run in command line mode
          #"-nojvm"              # we do not need the Java Virtual Machine
          "-r" "${MATLAB_CMD}"   # MATLAB command which invokes MATLAB Compiler
       )
    endif ()
  endif ()

  # relative paths used for comments of commands
  file (RELATIVE_PATH REL "${CMAKE_BINARY_DIR}" "${BUILD_DIR}/${OUTPUT_NAME}")

  # output files of build command
  if (TYPE MATCHES "LIBRARY")
    set (BUILD_OUTPUT "${LIBRARY_OUTPUT_DIRECTORY}/${OUTPUT_NAME}")

    set (
      POST_BUILD_COMMAND
        COMMAND "${CMAKE_COMMAND}" -E copy
                "${BUILD_DIR}/${OUTPUT_NAME}"
                "${LIBRARY_OUTPUT_DIRECTORY}/${OUTPUT_NAME}"
    )

    set (BUILD_COMMENT "Building MATLAB library ${REL}...")
  else ()
    set (BUILD_OUTPUT "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_NAME}")

    set (
      POST_BUILD_COMMAND
        COMMAND "${CMAKE_COMMAND}" -E copy
                "${BUILD_DIR}/${OUTPUT_NAME}"
                "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_NAME}"
    )

    set (BUILD_COMMENT "Building MATLAB executable ${REL}...")
  endif ()

  # add custom command to build executable using MATLAB Compiler
  add_custom_command (
    OUTPUT ${BUILD_OUTPUT}
    # rebuild when input sources were modified
    DEPENDS ${DEPENDS}
    # invoke MATLAB Compiler in either MATLAB or standalone mode
    # wrapping command in CMake execute_process () command allows for inspection
    # parsing of command output for error messages and specification of timeout
    COMMAND "${CMAKE_COMMAND}"
            "-DCOMMAND=${BUILD_CMD}"
            "-DWORKING_DIRECTORY=${WORKING_DIR}"
            "-DTIMEOUT=${BASIS_MCC_TIMEOUT}"
            "-DERROR_EXPRESSION=[E|e]rror"
            "-DOUTPUT_FILE=${BUILD_LOG}"
            "-DERROR_FILE=${BUILD_LOG}"
            "-DVERBOSE=OFF"
            "-DLOG_ARGS=ON"
            "-P" "${BASIS_SCRIPT_EXECUTE_PROCESS}"
    # post build command(s)
    ${POST_BUILD_COMMAND}
    # inform user where build log can be found
    COMMAND "${CMAKE_COMMAND}" -E echo "Build log written to ${BUILD_LOG}"
    # comment
    COMMENT "${BUILD_COMMENT}"
    VERBATIM
  )

  # add custom target
  if (TARGET "_${TARGET_UID}")
    message (FATAL_ERROR "There is another target named _${TARGET_UID}. "
                         "BASIS uses target names starting with an underscore "
                         "for custom targets which are required to build executables or "
                         "shared libraries from MATLAB source files. "
                         "Do not use leading underscores in target names.")
  endif ()

  add_custom_target (
    _${TARGET_UID}
    DEPENDS ${BUILD_OUTPUT}
    SOURCES ${SOURCES}
  )

  add_dependencies (${TARGET_UID} _${TARGET_UID})

  # cleanup on "make clean"
  set_property (
    DIRECTORY
    APPEND PROPERTY
      ADDITIONAL_MAKE_CLEAN_FILES
        ${BUILD_OUTPUT}
        "${BUILD_DIR}/${OUTPUT_NAME}.prj"
        "${BUILD_DIR}/mccExcludedFiles.log"
        "${BUILD_DIR}/mccBuild.log"
        "${BUILD_DIR}/readme.txt"
  )

  if (TYPE MATCHES "LIBRARY")
  else ()
    set_property (
      DIRECTORY
      APPEND PROPERTY
        ADDITIONAL_MAKE_CLEAN_FILES
          "${BUILD_DIR}/${OUTPUT_NAME}"
          "${BUILD_DIR}/run_${OUTPUT_NAME}.sh"
          "${BUILD_DIR}/${OUTPUT_NAME}_main.c"
          "${BUILD_DIR}/${OUTPUT_NAME}_mcc_component_data.c"
    )
  endif ()

  # export target
  if (NOT NO_EXPORT)
    if (TEST)
      basis_set_project_property (APPEND PROPERTY TEST_EXPORT_TARGETS "${TARGET_UID}")
    else ()
      basis_set_project_property (APPEND PROPERTY CUSTOM_EXPORT_TARGETS "${TARGET_UID}")
    endif ()
  endif ()

  # install executable or library
  if (TYPE MATCHES "LIBRARY")
    # TODO
  else ()
    if (TEST)
      # TODO Install (selected?) test executables
    else ()
      install (
        PROGRAMS    ${BUILD_OUTPUT}
        DESTINATION "${RUNTIME_INSTALL_DIRECTORY}"
        COMPONENT   "${RUNTIME_COMPONENT}"
      )
    endif ()
  endif ()

  if (BASIS_VERBOSE)
    if (TYPE MATCHES "LIBRARY")
      message (STATUS "Adding build command for MATLAB library ${TARGET_UID}... - done")
    else ()
      message (STATUS "Adding build command for MATLAB executable ${TARGET_UID}... - done")
    endif ()
  endif ()
endfunction ()
