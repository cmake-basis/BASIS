##############################################################################
# \file  FindMOSEK.cmake
# \brief Find Mosek
#
# Input variables:
#
#   MOSEK_DIR                The Mosek package files are searched under
#                            the specified root directory. If they are not found
#                            there, the default search paths are considered.
#                            This variable can also be set as environment variable.
#
# Sets the following CMake variables:
#
#   MOSEK_FOUND                 Whether the package was found and the following CMake
#                               variables are valid.
#   MOSEK_INCLUDE_DIR           Package include directories.
#   MOSEK_LIBRARY               Package libraries.
#   MOSEK_MEX_R2009b_LIBRARY    Mex libraries for MATLAB R2009b
#   MOSEK_MEX_R2007a_LIBRARY    Mex libraries for MATLAB R2007a
#   MOSEK_MEX_R2006b_LIBRARY    Mex libraries for MATLAB R2006b
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################


# ----------------------------------------------------------------------------
# initialize search
if (NOT DEFINED MOSEK_DIR)
  set (MOSEK_DIR "" CACHE PATH "Installation prefix for MOSEK")
endif ()

#if (NOT DEFINED $ENV{MOSEKLM_LICENSE_FILE})
#  message(FATAL_ERROR  "you need to set an environment variable  MOSEKLM_LICENSE_FILE to the place your license file is located !") 
#endif ()


set (MOSEK_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})

if (MOSEK_SHARED_LIBRARIES)
  if (WIN32)
    set (CMAKE_FIND_LIBRARY_SUFFIXES .dll)    # I AM NOT SURE ABOUT THIS
  else ()
    set (CMAKE_FIND_LIBRARY_SUFFIXES .so)
  endif()
else ()
  if (WIN32)
    set (CMAKE_FIND_LIBRARY_SUFFIXES .lib)    # I AM NOT SURE ABOUT THIS
  else ()
    set (CMAKE_FIND_LIBRARY_SUFFIXES .a)     # I AM NOT SURE ABOUT THIS TOO
  endif()
endif ()

set (MOSEK_HINTS "HINTS ${MOSEK_DIR}" ENV Mosek_DIR ENV MOSEK_DIR ENV $ENV{MOSEKLM_LICENSE_FILE}/..)

#-------------------------------------------------------------
# find paths/files
find_path (
  MOSEK_INCLUDE_DIR
    NAMES         mosek.h
    ${MOSEK_HINTS}
    PATH_SUFFIXES "tools/platform/linux64x86/h"
    DOC           "Include directory for Mosek"
    NO_DEFAULT_PATH
)

find_path (
  MOSEK_INCLUDE_DIR
    NAMES mosek.h
    HINTS ENV C_INCLUDE_PATH ENV CXX_INCLUDE_PATH
    DOC   "Include directory for mosek"
)

find_library (
  MOSEK_LIBRARY
    NAMES         mosek64
    ${MOSEK_HINTS}
    PATH_SUFFIXES "tools/platform/linux64x86/bin"
    DOC           "Link library for Mosek "
    NO_DEFAULT_PATH
)

find_library (
  MOSEK_LIBRARY
    NAMES     mosek64
    HINTS ENV LD_LIBRARY_PATH
    DOC   "Link library for Mosek "
)

find_file (
  MOSEK_MEX_R2009b_LIBRARY
    NAMES         mosekopt.mexa64
    ${MOSEK_HINTS}
    PATH_SUFFIXES "toolbox/r2009b"
    DOC           "Link for MEX files for r2009b version of matlab"
    NO_DEFAULT_PATH
)

find_file (
  MOSEK_MEX_R2007a_LIBRARY
    NAMES         mosekopt.mexa64
    ${MOSEK_HINTS}
    PATH_SUFFIXES "toolbox/r2007a"
    DOC           "Link for MEX files for r2007a version of matlab"
    NO_DEFAULT_PATH
)

find_file (
  MOSEK_MEX_R2006b_LIBRARY
    NAMES         mosekopt.mexa64
    ${MOSEK_HINTS}
    PATH_SUFFIXES "toolbox/r2006b"
    DOC           "Link for MEX files for r2006b version of matlab"
    NO_DEFAULT_PATH
)

# ----------------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set *_FOUND to TRUE
# if all listed variables are found or TRUE
include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (
  MOSEK
# MESSAGE
    DEFAULT_MSG
# VARIABLES
    MOSEK_INCLUDE_DIR
    MOSEK_LIBRARY
    MOSEK_MEX_R2009b_LIBRARY
    MOSEK_MEX_R2007a_LIBRARY
    MOSEK_MEX_R2006b_LIBRARY
)



