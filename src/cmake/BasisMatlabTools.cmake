##############################################################################
# \file  BasisMatlabTools.cmake
# \brief Enables use of MATLAB Compiler and build of MEX-files.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

if (__BASIS_MATLABTOOLS_INCLUDED)
  return ()
else ()
  set (__BASIS_MATLABTOOLS_INCLUDED TRUE)
endif ()


# get directory of this file
#
# \note This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# options
# ============================================================================

option (
  BASIS_MCC_MATLAB_MODE
  "Prefer MATLAB mode over standalone mode to invoke MATLAB Compiler."
  "ON" # prefer as it releases the license immediately once done
)

mark_as_advanced (BASIS_MCC_MATLAB_MODE)

# ============================================================================
# build configuration
# ============================================================================

set (
  BASIS_MCC_FLAGS
    "-v -R -singleCompThread"
  CACHE STRING
    "Common MATLAB Compiler flags (separated by ' '; use '\\' to mask ' ')."
)

set (
  BASIS_MEX_FLAGS
    "-v"
  CACHE STRING
    "Common MEX switches (separated by ' '; use '\\' to mask ' ')."
)

set (BASIS_MCC_TIMEOUT "600" CACHE STRING "Timeout for MATLAB Compiler execution")
set (BASIS_MEX_TIMEOUT "600" CACHE STRING "Timeout for MEX script execution")

mark_as_advanced (BASIS_MCC_FLAGS)
mark_as_advanced (BASIS_MEX_FLAGS)
mark_as_advanced (BASIS_MCC_TIMEOUT)
mark_as_advanced (BASIS_MEX_TIMEOUT)

# ============================================================================
# find programs
# ============================================================================

# The script used to invoke the MATLAB Compiler in MATLAB mode.
set (BASIS_SCRIPT_MCC "${CMAKE_CURRENT_LIST_DIR}/runmcc.m")

find_program (
  BASIS_CMD_MATLAB
    NAMES matlab
    DOC "The MATLAB application (matlab)."
)

mark_as_advanced (BASIS_CMD_MATLAB)

find_program (
  BASIS_CMD_MCC
    NAMES mcc
    DOC "The MATLAB Compiler (mcc)."
)

mark_as_advanced (BASIS_CMD_MCC)

find_program (
  BASIS_CMD_MEXEXT
    NAMES mexext
    DOC "The MEXEXT script of MATLAB (mexext)."
)

mark_as_advanced (BASIS_CMD_MEXEXT)

find_program (
  BASIS_CMD_MEX
    NAMES mex
    DOC "The MEX-file generator of MATLAB (mex)."
)

mark_as_advanced (BASIS_CMD_MEX)

# ============================================================================
# utilities
# ============================================================================

# ****************************************************************************
# \brief Determine extension of MEX-files for this architecture.
#
# \param [out] EXT The extension of MEX-files (excluding '.'). If the CMake
#                  variable MEX_EXT is set, its value is returned. Otherwise,
#                  this function tries to determine it from the system
#                  information. If the extension could not be determined,
#                  an empty string is returned.
#                  If this argument is not given, the extension is cached
#                  as the MEX_EXT variable.

function (basis_mexext)
  # default return value
  set (MEXEXT "${MEX_EXT}")

  # use MEXEXT if possible
  if (NOT MEXEXT AND BASIS_CMD_MEXEXT)
    execute_process (
      COMMAND         "${BASIS_CMD_MEXEXT}"
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
    if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
      if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
        set (MEXEXT "mexa64")
      elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86" OR
              ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
        set (MEXEXT "mexglx")
      endif ()
    elseif (${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
      if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
        set (MEXEXT "mexw64")
      elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86" OR
              ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
        set (MEXEXT "mexw32")
      endif ()
    elseif (${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
      set (MEXEXT "mexaci")
    elseif (${CMAKE_SYSTEM_NAME} STREQUAL "SunOS")
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

# ****************************************************************************
# \brief This function writes a MATLAB M-file with addpath () statements.
#
# This function writes the MATLAB M-file addpaths.m into the root directory
# of the build tree which contains an addpath () statement for each
# directory that was added via basis_include_directories ().

function (basis_create_addpaths_mfile)
  set (MFILE "${CMAKE_CURRENT_BINARY_DIR}/Add${PROJECT_NAME}Paths.m")

  file (WRITE "${MFILE}" "% DO NOT edit. This file is automatically generated by BASIS.\n")
  foreach (P ${BASIS_INCLUDE_DIRECTORIES})
    file (APPEND "${MFILE}" "addpath ('${P}');\n")
  endforeach ()
endfunction ()

# ============================================================================
# MEX target
# ============================================================================

# ****************************************************************************
# \brief Add MEX target.
#
# This function is used to add a shared library target which is built
# using the MATLAB MEX script (mex). It is invoked by basis_add_library ().
# Thus, it is recommended to use this function instead.
#
# An install command for the added library target is added by this function
# as well. The MEX-file will be installed as part of the RUNTIME_COMPONENT
# in the directory INSTALL_LIBRARY_DIR on UNIX systems and INSTALL_RUNTIME_DIR
# on Windows.
#
# \note The custom build command is not added yet by this function.
#       Only a custom target which stores all the information required to
#       setup this build command is added. The custom command is added
#       by either basis_project_finalize () or basis_superproject_finalize ().
#       This way, the properties such as the OUTPUT_NAME of the custom
#       target can be still modified.
#
# \see basis_add_library ()
#
# \param [in] TARGET_NAME Name of the target.
# \param [in] ARGN        Remaining arguments such as in particular the
#                         input source files.
#
#   COMPONENT   Name of the component. Defaults to BASIS_LIBRARY_COMPONENT.

function (basis_add_mex_target TARGET_NAME)
  basis_check_target_name ("${TARGET_NAME}")
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      ""
      "COMPONENT"
      ""
    ${ARGN}
  )

  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "${BASIS_LIBRARY_COMPONENT}")
  endif ()
  if (NOT ARGN_COMPONENT)
    set (ARGN_COMPONENT "Unspecified")
  endif ()

  message (STATUS "Adding MEX-file ${TARGET_UID}...")

  # required commands available ?
  if (NOT BASIS_CMD_MEX)
    message (FATAL_ERROR "MATLAB MEX script (mex) not found. It is required to build target ${TARGET_UID}."
                         "Set BASIS_CMD_MEX manually and try again.")
  endif ()
 
  # MEX flags
  basis_mexext (MEXEXT)

  set (SOURCES)
  foreach (SOURCE ${ARGN_UNPARSED_ARGUMENTS})
    get_filename_component (ABSPATH "${SOURCE}" ABSOLUTE)
    list (APPEND SOURCES "${ABSPATH}")
  endforeach ()

  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${SOURCES})

  # set target properties required by basis_add_mex_target_finalize ()
  set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      TYPE                      "LIBRARY"
      BASIS_TYPE                "MEX"
      PREFIX                    ""
      SUFFIX                    ".${MEXEXT}"
      VERSION                   "${PROJECT_VERSION}"
      SOVERSION                 "${PROJECT_SOVERSION}"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${CMAKE_CURRENT_BINARY_DIR}"
      RUNTIME_OUTPUT_DIRECTORY  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
      LIBRARY_OUTPUT_DIRECTORY  "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
      RUNTIME_INSTALL_DIRECTORY "${RUNTIME_INSTALL_DIR}"
      LIBRARY_INSTALL_DIRECTORY "${INSTALL_LIBRARY_DIR}"
      INCLUDE_DIRECTORIES       "${BASIS_INCLUDE_DIRECTORIES}"
      LINK_DIRECTORIES          "${BASIS_LINK_DIRECTORIES}"
      COMPILE_FLAGS             "${BASIS_MEX_FLAGS}"
      LINK_FLAGS                ""
      LINK_DEPENDS              ""
      LIBRARY_COMPONENT         "${ARGN_COMPONENT}"
  )

  # add target to list of targets
  set (
    BASIS_TARGETS "${BASIS_TARGETS};${TARGET_UID}"
    CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE
  )

  message (STATUS "Adding MEX-file ${TARGET_UID}... - done")
endfunction ()

# ****************************************************************************
# \brief Finalizes addition of MEX target.
#
# This function uses the properties of the custom MEX-file target added by
# basis_add_mex_target () to create the custom build command and adds this
# build command as dependency of this added target.
#
# \see basis_add_mex_target ()
#
# \param [in] TARGET_UID "Global" target name. If this function is used
#                        within the same project as basis_add_mcc_target (),
#                        the "local" target name may be given alternatively.

function (basis_add_mex_target_finalize TARGET_UID)
  # if used within (sub-)project itself, allow user to specify "local" target name
  basis_target_uid (TARGET_UID "${TARGET_UID}")

  # finalized before ?
  if (TARGET "${TARGET_UID}+")
    return ()
  endif ()

  # does this target exist ?
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown target ${TARGET_UID}.")
    return ()
  endif ()

  # get target properties
  basis_target_name (TARGET_NAME ${TARGET_UID})

  set (
    PROPERTIES
      "TYPE"
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
      "INCLUDE_DIRECTORIES"
      "LINK_DIRECTORIES"
      "SOURCES"
      "COMPILE_FLAGS"
      "LINK_DEPENDS"
      "LINK_FLAGS"
      "LIBRARY_COMPONENT"
  )

  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()

  if (NOT BASIS_TYPE MATCHES "^MEX$")
    message (FATAL_ERROR "Target ${TARGET_UID} has invalid BASIS_TYPE: ${BASIS_TYPE}")
  endif ()

  message (STATUS "Adding build command for MEX-file ${TARGET_UID}...")

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
    basis_target_uid (UID "${LIB}")
    if (TARGET ${UID})
      get_target_property (LIB_FILE ${UID} "LOCATION")
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

  list (APPEND MEX_ARGS "CC=${CC}"   "CFLAGS=${CFLAGS}")         # C compiler and flags
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
  foreach (INCLUDE_PATH ${INCLUDE_DIRECTORIES})                  # include directories
    list (FIND MEX_ARGS "-I${INCLUDE_PATH}" IDX)                 # as specified via
    if (INCLUDE_PATH AND IDX EQUAL -1)                           # basis_include_directories ()
      list (APPEND MEX_ARGS "-I${INCLUDE_PATH}")
    endif ()
  endforeach ()
  foreach (LIBRARY_PATH ${LINK_DIRECTORIES})                     # link directories
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
  set (BUILD_CMD      "${BASIS_CMD_MEX}" ${MEX_ARGS})
  set (BUILD_LOG      "${BUILD_DIR}/mexBuild.log")
  set (BUILD_OUTPUT   "${LIBRARY_OUTPUT_DIRECTORY}/${OUTPUT_NAME}")

  # relative paths used for comments of commands
  file (RELATIVE_PATH REL "${CMAKE_BINARY_DIR}" "${BUILD_DIR}/${OUTPUT_NAME}")

  # add custom command to build executable using MATLAB Compiler
  add_custom_command (
    OUTPUT "${BUILD_OUTPUT}"
    # rebuild when input sources were modified
    DEPENDS ${DEPENDS}
    # invoke MEX script, wrapping the command in CMake execute_process ()
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

  # add custom target
  add_custom_target (
    ${TARGET_UID}+
    DEPENDS "${BUILD_OUTPUT}"
    SOURCES ${SOURCES}
  )

  add_dependencies (${TARGET_UID} ${TARGET_UID}+)

  # cleanup on "make clean"
  set_property (
    DIRECTORY
    APPEND PROPERTY
      ADDITIONAL_MAKE_CLEAN_FILES
        "${BUILD_DIR}/${OUTPUT_NAME}"
        "${BUILD_OUTPUT}"
        "${BUILD_LOG}"
  )

  # install target
  install (
    FILES       "${BUILD_OUTPUT}"
    DESTINATION "${LIBRARY_INSTALL_DIRECTORY}"
    COMPONENT   "${LIBRARY_COMPONENT}"
  )

  message (STATUS "Adding build command for MEX-file ${TARGET_UID}... - done")
endfunction ()

# ============================================================================
# MATLAB Compiler target
# ============================================================================

# ****************************************************************************
# \brief Add MATLAB Compiler target.
#
# This function is used to add an executable or library target which is built
# using the MATLAB Compilier (MCC). It is invoked by basis_add_executable ()
# or basis_add_library (), respectively, when at least one M-file is given
# as source file. Thus, it is recommended to use these functions instead.
#
# An install command for the added executable or library target is added by
# this function as well. The executable will be installed as part of the
# RUNTIME_COMPONENT in the directory INSTALL_RUNTIME_DIR. The runtime
# library will be installed as part of the RUNTIME_COMPONENT in the directory
# INSTALL_LIBRARY_DIR on UNIX systems and INSTALL_RUNTIME_DIR on Windows.
# Static/import libraries will be installed as part of the LIBRARY_COMPONENT
# in the directory INSTALL_ARCHIVE_DIR.
#
# \note The custom build command is not added yet by this function.
#       Only a custom target which stores all the information required to
#       setup this build command is added. The custom command is added
#       by either basis_project_finalize () or basis_superproject_finalize ().
#       This way, the properties such as the OUTPUT_NAME of the custom
#       target can be still modified.
#
# \see basis_add_executable ()
# \see basis_add_library ()
#
# \param [in] TARGET_NAME Name of the target.
# \param [in] ARGN        Remaining arguments such as in particular the
#                         input source files.
#
#   TYPE                Type of the target. Either EXECUTABLE (default) or LIBRARY.
#   COMPONENT           Name of the component. Defaults to
#                       BASIS_RUNTIME_COMPONENT if TYPE is EXECUTABLE or
#                       BASIS_LIBRARY_COMPONENT, otherwise.
#   RUNTIME_COMPONENT   Name of runtime component. Defaults to COMPONENT
#                       if specified or BASIS_RUNTIME_COMPONENT, otherwise.
#   LIBRARY_COMPONENT   Name of library component. Defaults to COMPONENT
#                       if specified or BASIS_LIBRARY_COMPONENT, otherwise.
#   LIBEXEC             Specifies that the built executable is an auxiliary
#                       executable called by other executables only.
#   TEST                Specifies that the built executable is a test executable.
#                       If LIBEXEC is given as well, it will be ignored.


function (basis_add_mcc_target TARGET_NAME)
  basis_check_target_name ("${TARGET_NAME}")
  basis_target_uid (TARGET_UID "${TARGET_NAME}")

  # parse arguments
  CMAKE_PARSE_ARGUMENTS (
    ARGN
      "LIBEXEC;TEST"
      "TYPE;COMPONENT;RUNTIME_COMPONENT;LIBRARY_COMPONENT"
      ""
    ${ARGN}
  )

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
    if (ARGN_TYPE STREQUAL "EXECUTABLE")
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

  if (ARGN_TYPE STREQUAL "LIBRARY")
    message (STATUS "Adding MATLAB library ${TARGET_UID}...")
    message (FATAL_ERROR "Build of MATLAB library from M-files not yet supported.")
    message (STATUS "Adding MATLAB library ${TARGET_UID}... - failed")
  else ()
    message (STATUS "Adding MATLAB executable ${TARGET_UID}...")
  endif ()

  # required commands available ?
  if (NOT BASIS_CMD_MCC)
    message (FATAL_ERROR "MATLAB Compiler not found. It is required to build target ${TARGET_UID}."
                         "Set BASIS_CMD_MCC manually and try again.")
  endif ()
 
  # MCC flags
  set (COMPILE_FLAGS)

  if (BASIS_MCC_FLAGS)
    string (REPLACE "\\ "    "&nbsp;" COMPILE_FLAGS "${BASIS_MCC_FLAGS}")
    string (REPLACE " "      ";"      COMPILE_FLAGS "${COMPILE_FLAGS}")
    string (REPLACE "&nbsp;" " "      COMPILE_FLAGS "${COMPILE_FLAGS}")
  endif ()

  # get list of target arguments
  set (SOURCES)
  set (LINK_DEPENDS)

  foreach (ARG ${ARGN_UNPARSED_ARGUMENTS})
    basis_target_uid (UID "${ARG}")
    if (TARGET ${UID})
      list (APPEND LINK_DEPENDS "${UID}")
    else ()
      if (NOT IS_ABSOLUTE)
        set (ARG "${CMAKE_CURRENT_SOURCE_DIR}/${ARG}")
      endif ()
      list (APPEND SOURCES "${ARG}")
    endif ()
  endforeach ()

  # add custom target
  add_custom_target (${TARGET_UID} ALL SOURCES ${SOURCES})

  # set target properties required by basis_add_mcc_target_finalize ()
  if (ARGN_TYPE STREQUAL "LIBRARY")
    set (TYPE "MCC_LIBRARY")
  else ()
    if (ARGN_TEST)
      set (RUNTIME_INSTALL_DIR "")
      set (TYPE                "MCC_TEST")
    elseif (ARGN_LIBEXEC)
      set (RUNTIME_INSTALL_DIR "${INSTALL_LIBEXEC_DIR}")
      set (TPYE                "MCC_LIBEXEC")
    else ()
      set (RUNTIME_INSTALL_DIR "${INSTALL_RUNTIME_DIR}")
      set (TYPE                "MCC_EXEC")
    endif ()
  endif ()

  set_target_properties (
    ${TARGET_UID}
    PROPERTIES
      TYPE                      "${ARGN_TYPE}"
      BASIS_TYPE                "${TYPE}"
      VERSION                   "${PROJECT_VERSION}"
      SOVERSION                 "${PROJECT_SOVERSION}"
      SOURCE_DIRECTORY          "${CMAKE_CURRENT_SOURCE_DIR}"
      BINARY_DIRECTORY          "${CMAKE_CURRENT_BINARY_DIR}"
      RUNTIME_OUTPUT_DIRECTORY  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
      LIBRARY_OUTPUT_DIRECTORY  "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
      RUNTIME_INSTALL_DIRECTORY "${RUNTIME_INSTALL_DIR}"
      LIBRARY_INSTALL_DIRECTORY "${INSTALL_LIBRARY_DIR}"
      INCLUDE_DIRECTORIES       "${BASIS_INCLUDE_DIRECTORIES}"
      COMPILE_FLAGS             "${COMPILE_FLAGS}"
      LINK_DEPENDS              "${LINK_DEPENDS}"
      RUNTIME_COMPONENT         "${ARGN_RUNTIME_COMPONENT}"
      LIBRARY_COMPONENT         "${ARGN_LIBRARY_COMPONENT}"
  )

  # add target to list of targets
  set (
    BASIS_TARGETS "${BASIS_TARGETS};${TARGET_UID}"
    CACHE INTERNAL "${BASIS_TARGETS_DOC}" FORCE
  )

  if (ARGN_TYPE STREQUAL "LIBRARY")
    message (STATUS "Adding MATLAB library ${TARGET_UID}... - done")
  else ()
    message (STATUS "Adding MATLAB executable ${TARGET_UID}... - done")
  endif ()
endfunction ()

# ****************************************************************************
# \brief Finalizes addition of MATLAB Compiler target.
#
# This function uses the properties of the custom MATLAB Compiler target
# added by basis_add_mcc_target () to create the custom build command and
# adds this build command as dependency of this added target.
#
# \see basis_add_mcc_target ()
#
# \param [in] TARGET_UID "Global" target name. If this function is used
#                        within the same project as basis_add_mcc_target (),
#                        the "local" target name may be given alternatively.

function (basis_add_mcc_target_finalize TARGET_UID)
  # if used within (sub-)project itself, allow user to specify "local" target name
  basis_target_uid (TARGET_UID "${TARGET_UID}")

  # finalized before ?
  if (TARGET "${TARGET_UID}+")
    return ()
  endif ()

  # does this target exist ?
  if (NOT TARGET "${TARGET_UID}")
    message (FATAL_ERROR "Unknown target ${TARGET_UID}.")
    return ()
  endif ()

  # get target properties
  basis_target_name (TARGET_NAME ${TARGET_UID})

  set (
    PROPERTIES
      "TYPE"
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
      "INCLUDE_DIRECTORIES"
      "SOURCES"
      "COMPILE_FLAGS"
      "LINK_DEPENDS"
      "RUNTIME_COMPONENT"
      "LIBRARY_COMPONENT"
  )

  foreach (PROPERTY ${PROPERTIES})
    get_target_property (${PROPERTY} ${TARGET_UID} ${PROPERTY})
  endforeach ()

  if (NOT BASIS_TYPE MATCHES "^MCC_EXEC$|^MCC_LIBEXEC$|^MCC_TEST$|^MCC_LIBRARY$")
    message (FATAL_ERROR "Target ${TARGET_UID} has invalid BASIS_TYPE: ${BASIS_TYPE}")
  endif ()

  # \todo The TYPE property seemed to be set to "UTILITY" by CMake.
  #       Check if this is true or if there is a bug in BASIS.
  if ("${BASIS_TYPE}" STREQUAL "MCC_LIBRARY")
    set (TYPE "LIBRARY")
  else ()
    set (TYPE "EXECUTABLE")
  endif ()

  if (TYPE STREQUAL "LIBRARY")
    message (STATUS "Adding build command for MATLAB library ${TARGET_UID}...")
  elseif (TYPE STREQUAL "EXECUTABLE")
    message (STATUS "Adding build command for MATLAB executable ${TARGET_UID}...")
  else ()
    message (FATAL_ERROR "Target ${TARGET_UID} has invalid TYPE: ${TYPE}")
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
    basis_target_uid (UID "${LIB}")
    if (TARGET ${UID})
      get_target_property (LIB_FILE ${UID} "LOCATION")
      list (APPEND DEPENDS ${UID})
    else ()
      set (LIB_FILE "${LIB}")
    endif ()
    list (APPEND LINK_LIBS "${LIB_FILE}")
  endforeach ()

  # assemble build command
  set (MCC_ARGS ${COMPILE_FLAGS})                    # user specified flags
  foreach (INCLUDE_PATH ${INCLUDE_DIRECTORIES})      # add directories added via
    list (FIND MCC_ARGS "${INCLUDE_PATH}" IDX)       # basis_include_directories ()
    if (EXISTS INCLUDE_PATH AND IDX EQUAL -1)               # function to search path
      list (APPEND MCC_ARGS "-I" "${INCLUDE_PATH}")
    endif ()
  endforeach ()
  list (FIND INCLUDE_DIRECTORIES "${SOURCE_DIRECTORY}" IDX)
  if (IDX EQUAL -1)
    # add current source directory to search path,
    # needed for build in MATLAB mode as working directory
    # differs from the current source directory then
    list (APPEND MCC_ARGS "-I" "${SOURCE_DIRECTORY}")
  endif ()
  if (TYPE STREQUAL "LIBRARY")
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
  set (BUILD_CMD      "${BASIS_CMD_MCC}" ${MCC_ARGS})
  set (BUILD_LOG      "${BUILD_DIR}/mccBuild.log")
  set (WORKING_DIR    "${SOURCE_DIRECTORY}")
  set (MATLAB_MODE    OFF)

  # build command for invocation of MATLAB Compiler in MATLAB mode
  if (BASIS_MCC_MATLAB_MODE)
    set (MATLAB_MODE ON)

    if (NOT BASIS_CMD_MATLAB)
      message (WARNING "MATLAB not found. It is required to build target ${TARGET_UID} in MATLAB mode."
                       " Set BASIS_CMD_MATLAB manually and try again or set BASIS_MCC_MATLAB_MODE to OFF."
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
          "${BASIS_CMD_MATLAB}" # run MATLAB
          "-nosplash"           # do not display splash screen on start up
          "-nodesktop"          # run in command line mode
          #"-nojvm"              # we do not need the Java Virtual Machine
          "-r" "${MATLAB_CMD}"  # MATLAB command which invokes MATLAB Compiler
      )
    endif ()
  endif ()

  # relative paths used for comments of commands
  file (RELATIVE_PATH REL "${CMAKE_BINARY_DIR}" "${BUILD_DIR}/${OUTPUT_NAME}")

  # output files of build command
  if (TYPE STREQUAL "LIBRARY")
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
  add_custom_target (
    ${TARGET_UID}+
    DEPENDS ${BUILD_OUTPUT}
    SOURCES ${SOURCES}
  )

  add_dependencies (${TARGET_UID} ${TARGET_UID}+)

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

  if (TYPE STREQUAL "LIBRARY")
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

  # install target
  if (TYPE STREQUAL "LIBRARY")
    # \todo
  else ()
    if (BASIS_TYPE STREQUAL "MCC_TEST")
      # \todo Install selected test executables
    else ()
      install (
        PROGRAMS    ${BUILD_OUTPUT}
        DESTINATION "${RUNTIME_INSTALL_DIRECTORY}"
        COMPONENT   "${RUNTIME_COMPONENT}"
      )
    endif ()
  endif ()

  if (TYPE STREQUAL "LIBRARY")
    message (STATUS "Adding build command for MATLAB library ${TARGET_UID}... - done")
  else ()
    message (STATUS "Adding build command for MATLAB executable ${TARGET_UID}... - done")
  endif ()
endfunction ()

