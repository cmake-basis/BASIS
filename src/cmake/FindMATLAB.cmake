##############################################################################
# \file  FindMATLAB.cmake
# \brief Find MATLAB installation.
#
# Input variables:
#
#   MATLAB_DIR             The installation directory of MATLAB.
#                          Can also be set as environment variable.
#   MATLABDIR              Alternative environment variable for MATLAB_DIR.
#   MATLAB_PATH_SUFFIXES   Path suffixes which are used to find the
#                          proper MATLAB libraries. By default, this
#                          find module tries to determine the path
#                          suffix from the CMake variables which describe
#                          the system. For example, on 64-bit UNIX, the
#                          libraries are searched in MATLAB_DIR/bin/glna64.
#                          Set this variable before the find_package ()
#                          command if this find module fails to
#                          determine the correct location of the
#                          MATLAB libraries underneath the root directory.
#
# Sets the following CMake variables:
#
#   MATLAB_FOUND         Whether the package was found and the following CMake
#                        variables are valid.
#   MATLAB_INCLUDE_DIR   Package include directories.
#   MATLAB_INCLUDES      Include directories including prerequisite libraries.
#   MATLAB_mex_LIBRARY   The MEX library of MATLAB.
#   MATLAB_mx_LIBRARY    The mx library of MATLAB.
#   MATLAB_eng_LIBRARY   The MATLAB engine library.
#   MATLAB_LIBRARY       All MATLAB libraries.
#   MATLAB_LIBRARIES     Package libraries and prerequisite libraries.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# initialize search
if (NOT MATLAB_DIR)
  if ($ENV{MATLABDIR})
    set (MATLAB_DIR "$ENV{MATLABDIR}"  CACHE PATH "Installation prefix for MATLAB.")
  else ()
    set (MATLAB_DIR "$ENV{MATLAB_DIR}" CACHE PATH "Installation prefix for MATLAB.")
  endif ()
endif ()

if (NOT MATLAB_PATH_SUFFIXES)
  if (WIN32)
    if (CMAKE_GENERATOR MATCHES "Visual Studio 6")
      set (MATLAB_PATH_SUFFIXES "extern/lib/win32/microsoft/msvc60")
    elseif (CMAKE_GENERATOR MATCHES "Visual Studio 7")
      # assume people are generally using 7.1,
      # if using 7.0 need to link to: extern/lib/win32/microsoft/msvc70
      set (MATLAB_PATH_SUFFIXES "extern/lib/win32/microsoft/msvc71")
    elseif (CMAKE_GENERATOR MATCHES "Borland")
      # assume people are generally using 5.4
      # if using 5.0 need to link to: ../extern/lib/win32/microsoft/bcc50
      # if using 5.1 need to link to: ../extern/lib/win32/microsoft/bcc51
      set (MATLAB_PATH_SUFFIXES "extern/lib/win32/microsoft/bcc54")
    endif ()
  else ()
    if (CMAKE_SIZE_OF_VOID_P EQUAL 4)
      set (MATLAB_PATH_SUFFIXES "bin/glnx86")
    else ()
      set (MATLAB_PATH_SUFFIXES "bin/glna64")
    endif ()
  endif ()
endif ()

set (MATLAB_LIBRARY_NAMES "mex" "mx" "eng")

# ----------------------------------------------------------------------------
# find paths/files
if (MATLAB_DIR)

  find_path (
    MATLAB_INCLUDE_DIR
      NAMES         mex.h
      HINTS         "${MATLAB_DIR}"
      PATH_SUFFIXES "extern/include"
      DOC           "Include directory for MATLAB libraries."
      NO_DEFAULT_PATH
  )

  foreach (LIB ${MATLAB_LIBRARY_NAMES})
    find_library (
      MATLAB_${LIB}_LIBRARY
        NAMES         ${LIB}
        HINTS         "${MATLAB_DIR}"
        PATH_SUFFIXES ${MATLAB_PATH_SUFFIXES}
        DOC           "MATLAB ${LIB} link library."
        NO_DEFAULT_PATH
    )
  endforeach ()

else ()

  find_path (
    MATLAB_INCLUDE_DIR
      NAMES mex.h
      HINTS ENV C_INCLUDE_PATH ENV CXX_INCLUDE_PATH
      DOC   "Include directory for MATLAB libraries."
  )

  foreach (LIB ${MATLAB_LIBRARY_NAMES})
    find_library (
      MATLAB_${LIB}_LIBRARY
        NAMES         ${LIB}
        HINTS ENV LD_LIBRARY_PATH
        DOC           "MATLAB ${LIB} link library."
    )
  endforeach ()

endif ()

set (MATLAB_LIBRARY)
foreach (LIB ${MATLAB_LIBRARY_NAMES})
  if (MATLAB_${LIB}_LIBRARY)
    list (APPEND MATLAB_LIBRARY "${MATLAB_${LIB}_LIBRARY}")
endforeach ()

# ----------------------------------------------------------------------------
# prerequisite libraries
set (MATLAB_INCLUDES  "${MATLAB_INCLUDE_DIR}")
set (MATLAB_LIBRARIES "${MATLAB_LIBRARY}")

# ----------------------------------------------------------------------------
# aliases / backwards compatibility
set (MATLAB_INCLUDE_DIRS "${MATLAB_INCLUDES}")

# ----------------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set *_FOUND to TRUE
# if all listed variables are found or TRUE
include (FindPackageHandleStandardArgs)

set (MATLAB_LIBRARY_VARS)
foreach (LIB ${MATLAB_LIBRARY_NAMES})
  list (APPEND MATLAB_LIBRARY_VARS "MATLAB_${LIB}_LIBRARY")
endforeach ()

find_package_handle_standard_args (
  MATLAB
# MESSAGE
    DEFAULT_MSG
# VARIABLES
    MATLAB_INCLUDE_DIR
    ${MATLAB_LIBRARY_VARS}
)

