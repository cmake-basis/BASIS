##############################################################################
#! @file  FindMATLAB.cmake
#! @brief Find MATLAB installation.
#!
#! @par Input variables:
#! <table border="0">
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_DIR</td>
#!     <td>The installation directory of MATLAB.
#!         Can also be set as environment variable.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLABDIR</td>
#!     <td>Alternative environment variable for @p MATLAB_DIR.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_PATH_SUFFIXES</td>
#!     <td>Path suffixes which are used to find the proper MATLAB libraries.
#!         By default, this find module tries to determine the path suffix
#!         from the CMake variables which describe the system. For example,
#!         on 64-bit Unix-based systems, the libraries are searched in
#!         @p MATLAB_DIR/bin/glna64. Set this variable before the
#!         find_package() command if this find module fails to
#!         determine the correct location of the MATLAB libraries within
#!         the root directory.</td>
#!   </tr>
#! </table>
#!
#! @par Output variables:
#! <table border="0">
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_FOUND</td>
#!     <td>Whether the package was found and the following CMake
#!         variables are valid.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_INCLUDE_DIR</td>
#!     <td>Package include directories.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_INCLUDES</td>
#!     <td>Include directories including prerequisite libraries.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_mex_LIBRARY</td>
#!     <td>The MEX library of MATLAB.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_mx_LIBRARY</td>
#!     <td>The @c mx library of MATLAB.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_eng_LIBRARY</td>
#!     <td>The MATLAB engine library.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_LIBRARY</td>
#!     <td>All MATLAB libraries.</td>
#!   </tr>
#!   <tr>
#!     <td style="white-space:nowrap; vertical-align:top; padding-right:1em">
#!         @b MATLAB_LIBRARIES</td>
#!     <td>Package libraries and prerequisite libraries.</td>
#!   </tr>
#! </table>
#!
#! Copyright (c) 2011 University of Pennsylvania. All rights reserved.
#! See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#!
#! Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#!
#! @ingroup CMakeFindModules
##############################################################################

# ----------------------------------------------------------------------------
# initialize search
if (NOT MATLAB_DIR)
  if (NOT $ENV{MATLABDIR} STREQUAL "")
    set (MATLAB_DIR "$ENV{MATLABDIR}"  CACHE PATH "Installation prefix for MATLAB." FORCE)
  else ()
    set (MATLAB_DIR "$ENV{MATLAB_DIR}" CACHE PATH "Installation prefix for MATLAB." FORCE)
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
    elseif (CMAKE_GENERATOR MATCHES "Visual Studio 8")
      set (MATLAB_PATH_SUFFIXES "extern/lib/win32/microsoft/msvc80")
    elseif (CMAKE_GENERATOR MATCHES "Visual Studio 9")
      set (MATLAB_PATH_SUFFIXES "extern/lib/win32/microsoft/msvc90")
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
      set (MATLAB_PATH_SUFFIXES "bin/glnxa64")
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
        NAMES         ${LIB} lib${LIB}
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

mark_as_advanced (MATLAB_INCLUDE_DIR)
foreach (LIB ${MATLAB_LIBRARY_NAMES})
  mark_as_advanced (MATLAB_${LIB}_LIBRARY)
endforeach ()

set (MATLAB_LIBRARY)
foreach (LIB ${MATLAB_LIBRARY_NAMES})
  if (MATLAB_${LIB}_LIBRARY)
    list (APPEND MATLAB_LIBRARY "${MATLAB_${LIB}_LIBRARY}")
  endif ()
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

