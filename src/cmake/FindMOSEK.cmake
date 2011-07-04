##############################################################################
# \file  FindMOSEK.cmake
# \brief Find MOSEK (http://www.mosek.com) package.
#
# Input variables:
#
#   MOSEK_DIR            The MOSEK package files are searched under the specified
#                        root directory. If they are not found there, the default
#                        search paths are considered.
#                        This variable can also be set as environment variable.
#   MOSEK_NO_OMP         Whether to use the link libraries build without
#                        OpenMP, i.e., multi-threading, enabled. By default,
#                        the multi-threaded libraries are used.
#   MOSEK_MATLAB         Whether the MATLAB components of the MOSEK packages
#                        should be found. Defaults to 1, if MATLAB_FOUND
#                        evaluates to true and 0 otherwise.
#   MOSEK_JAVA           Whether the Java components of the MOSEK package should
#                        be found. Defaults to 0.
#   MOSEK_PYTHON         Whether the Python components of the MOSEK package
#                        should be found. Defaults to 0.
#   MOSEK_TOOLS_SUFFIX   Platform specific path suffix for tools, i.e.,
#                        "tools/platform/linux64x86" on 64-bit Linux systems.
#                        If not specified, this module determines the right
#                        suffix depending on the CMake system variables.
#   MATLAB_RELEASE       Release of MATLAB installation. Set to the 'Release'
#                        return value of the "ver ('MATLAB')" command of MATLAB
#                        without brackets. If this variable is not set and the
#                        basis_get_matlab_release command is available, it is
#                        invoked to determine the release version automatically.
#                        Otherwise, the release version defaults to "R2009b".
#   MEX_EXT              The extension of MEX-files. If this variable is not set
#                        and the basis_mexext command is available, it is invoked
#                        to determine the extension automatically. Otherwise,
#                        the MEX extension defaults to "mexa64".
#   PYTHON_VERSION       Version of Python installation. Set to first two or three
#                        return values of "sys.version_info" separated by a period (.).
#                        If this variable is not set and the basis_get_python_version
#                        command is available, it is invoked to determine the version
#                        automatically. Otherwise, the Python version defaults to 2.6.
#
# Sets the following CMake variables:
#
#   MOSEK_FOUND          Whether the package was found and the following CMake
#                        variables are valid.
#   MOSEK_INCLUDE_DIR    Package include directories.
#   MOSEK_INCLUDES       Include directories including prerequisite libraries (non-cached).
#   MOSEK_LIBRARY        Package libraries.
#   MOSEK_LIBRARIES      Package libraries and prerequisite libraries (non-cached).
#   MOSEK_mosekopt_MEX   Package mosekopt MEX-file.
#   MOSEK_MEX_FILES      List of MEX-files (non-cached).
#   MOSEK_mosek_JAR      Package mosek Java library (.jar file).
#   MOSEK_CLASSPATH      List of Java package libraries and prerequisite
#                        libraries (non-cached).
#   MOSEK_PYTHONPATH     Path to Python modules of this package.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# initialize search
if (NOT MOSEK_DIR)
  set (MOSEK_DIR "$ENV{MOSEK_DIR}" CACHE PATH "Installation prefix for MOSEK.")
endif ()

# MATLAB components
if (NOT DEFINED MOSEK_MATLAB)
  set (MOSEK_MATLAB ${MATLAB_FOUND})
endif ()

if (MOSEK_MATLAB)
  # MATLAB version
  if (NOT MATLAB_RELEASE)
    if (COMMAND basis_get_matlab_release)
      basis_get_matlab_release ()
      if (NOT MATLAB_RELEASE)
        message (FATAL_ERROR "Failed to determine release version of MATLAB installation. "
                             "This information is required to be able to find the right MOSEK MEX-files. "
                             "Set MATLAB_RELEASE manually and try again.")
      endif ()
    else ()
      set (MATLAB_RELEASE "R2009b")
    endif ()
  endif ()
  # search path for MOSEK MATLAB toolbox
  if (NOT MOSEK_TOOLBOX_SUFFIX)
    string (TOLOWER TMP "${MATLAB_RELEASE}")
    set (MOSEK_TOOLBOX_SUFFIX "toolbox/${TMP}")
  endif ()
  # extension of MEX-files
  if (NOT MEX_EXT)
    if (COMMAND basis_mexext)
      basis_mexext (MEX_EXT)
    else ()
      set (MEX_EXT "mexa64")
    endif ()
  endif ()
endif ()

# Java components
if (NOT DEFINED MOSEK_JAVA)
  set (MOSEK_JAVA 0)
endif ()

# Python components
if (NOT DEFINED MOSEK_PYTHON)
  set (MOSEK_PYTHON 0)
endif ()

if (MOSEK_PYTHON)
  # Python version
  if (NOT PYTHON_VERSION)
    if (COMMAND basis_get_python_version)
      basis_get_python_version ()
      if (NOT PYTHON_VERSION)
        message (FATAL_ERROR "Failed to determine version of Python installation. "
                             "This information is required to be able to find the right MOSEK Python modules. "
                             "Set PYTHON_VERSION manually and try again.")
      endif ()
    else ()
      set (PYTHON_VERSION "2.6")
    endif ()
  endif ()
  # major version of Python
  string (REGEX REPLACE "^([0-9]+)" "\\1" PYTHON_VERSION_MAJOR "${PYTHON_VERSION}")
endif ()

# library name
set (MOSEK_LIBRARY_NAME "mosek")
if (MOSEK_NO_OMP)
  set (MOSEK_LIBRARY_NAME "${MOSEK_LIBRARY_NAME}noomp")
endif ()
set (MOSEK_LIBRARY_NAMES "${MOSEK_LIBRARY_NAME}")
if (WIN32)
  foreach (VERSION_SUFFIX "6_0")
    list (APPEND MOSEK_LIBRARY_NAMES "${MOSEK_LIBRARY_NAME}${VERSION_SUFFIX}")
  endforeach ()
else ()
  if (CMAKE_SIZE_OF_VOID_P GREATER 4)
    set (MOSEK_LIBRARY_NAME "${MOSEK_LIBRARY_NAME}64")
  endif ()
endif ()

# search path for MOSEK tools
if (NOT MOSEK_TOOLS_SUFFIX)
  set (MOSEK_TOOLS_SUFFIX "tools/platform/")
  if (WIN32)
    set (MOSEK_TOOLS_SUFFIX "${MOSEK_PATH_SUFFIX}win")
  elseif (APPLE)
    set (MOSEK_TOOLS_SUFFIX "${MOSEK_PATH_SUFFIX}osx")
  else ()
    set (MOSEK_TOOLS_SUFFIX "${MOSEK_PATH_SUFFIX}linux")
  endif ()
  if (CMAKE_SIZE_OF_VOID_P EQUAL 4)
    set (MOSEK_TOOLS_SUFFIX "${MOSEK_PATH_SUFFIX}32")
  else ()
    set (MOSEK_TOOLS_SUFFIX "${MOSEK_PATH_SUFFIX}64")
  endif ()
  set (MOSEK_TOOLS_SUFFIX "${MOSEK_PATH_SUFFIX}x86")
endif ()

#-------------------------------------------------------------
# find paths/files
if (MOSEK_DIR)

  find_path (
    MOSEK_INCLUDE_DIR
      NAMES         mosek.h
      HINTS         "${MOSEK_DIR}"
      PATH_SUFFIXES "${MOSEK_PATH_SUFFIX}/h"
      DOC           "Include directory for MOSEK libraries."
      NO_DEFAULT_PATH
  )

  find_library (
    MOSEK_LIBRARY
      NAMES         ${MOSEK_LIBRARY_NAMES}
      HINTS         "${MOSEK_DIR}"
      PATH_SUFFIXES "${MOSEK_PATH_SUFFIX}/bin"
      DOC           "MOSEK link library."
      NO_DEFAULT_PATH
  )

else ()

  find_path (
    MOSEK_INCLUDE_DIR
      NAMES mosek.h
      HINTS ENV C_INCLUDE_PATH ENV CXX_INCLUDE_PATH
      DOC   "Include directory for MOSEK libraries."
  )

  find_library (
    MOSEK_LIBRARY
      NAMES ${MOSEK_LIBRARY_NAMES}
      HINTS ENV LD_LIBRARY_PATH
      DOC   "MOSEK link library."
  )

endif ()

mark_as_advanced (MOSEK_INCLUDE_DIR)
mark_as_advanced (MOSEK_LIBRARY)

# MATLAB components
if (MOSEK_MATLAB)
  if (MOSEK_DIR)

    find_file (
      MOSEK_mosekopt_MEX
        NAMES         mosekopt.${MEX_EXT}
        HINTS         "${MOSEK_DIR}"
        PATH_SUFFIXES "${MOSEK_TOOLBOX_SUFFIX}"
        DOC           "The mosekopt MEX-file of the MOSEK package."
        NO_DEFAULT_PATH
    )

  else ()

    find_file (
      MOSEK_mosekopt_MEX
        NAMES         mosekopt.${MEX_EXT}
        PATH_SUFFIXES "${MOSEK_TOOLBOX_SUFFIX}"
        DOC           "The mosekopt MEX-file of the MOSEK package."
    )

  endif ()

  if (MOSEK_mosekopt_MEX)
    set (MOSEK_MEX_FILES "${MOSEK_mosekopt_MEX}")
  endif ()

  mark_as_advanced (MOSEK_mosekopt_MEX)
endif ()

# Java components
if (MOSEK_JAVA)
  if (MOSEK_DIR)

    find_file (
      MOSEK_mosek_JAR
        NAMES         mosek.jar
        HINTS         "${MOSEK_DIR}"
        PATH_SUFFIXES "${MOSEK_TOOLS_SUFFIX}/bin"
        DOC           "The Java library (.jar file) of the MOSEK package."
        NO_DEFAULT_PATH
    )

  else ()

    find_file (
      MOSEK_mosek_JAR
        NAMES mosek.jar
        HINTS ENV CLASSPATH
        DOC   "The Java library (.jar file) of the MOSEK package."
    )

  endif ()

  if (MOSEK_mosek_JAR)
    set (MOSEK_CLASSPATH "${MOSEK_mosek_JAR}")
  endif ()

  mark_as_advanced (MOSEK_mosek_JAR)
endif ()

# Python components
if (MOSEK_PYTHON)
  if (MOSEK_DIR)

    find_path (
      MOSEK_PYTHONPATH
        NAMES "mosek/array.py"
        HINTS ENV PYTHONPATH
        DOC   "Path to MOSEK Python module."
    )

  else ()

    find_path (
      MOSEK_PYTHONPATH
        NAMES "mosek/array.py"
        HINTS "${MOSEK_DIR}/${MOSEK_PATH_SUFFIX}/python/${PYTHON_VERSION_MAJOR}"
        DOC   "Path to MOSEK Python module."
        NO_DEFAULT_PATH
    )

  endif ()

  mark_as_advanced (MOSEK_PYTHONPATH)
endif ()

# ----------------------------------------------------------------------------
# prerequisite libraries
set (MOSEK_INCLUDES  "${MOSEK_INCLUDE_DIR}")
set (MOSEK_LIBRARIES "${MOSEK_LIBRARY}")

# ----------------------------------------------------------------------------
# aliases / backwards compatibility
set (MOSEK_INCLUDE_DIRS "${MOSEK_INCLUDES}")

# ----------------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set *_FOUND to TRUE
# if all listed variables are found or TRUE
include (FindPackageHandleStandardArgs)

set (MOSEK_REQUIRED_VARS
  MOSEK_INCLUDE_DIR
  MOSEK_LIBRARY
)

if (MOSEK_MATLAB)
  list (APPEND MOSEK_REQUIRED_VARS MOSEK_mosekopt_MEX)
endif ()
if (MOSEK_JAVA)
  list (APPEND MOSEK_REQUIRED_VARS MOSEK_mosek_JAR)
endif ()
if (MOSEK_PYTHON)
  list (APPEND MOSEK_REQUIRED_VARS MOSEK_PYTHONPATH)
endif ()

find_package_handle_standard_args (
  MOSEK
# MESSAGE
    DEFAULT_MSG
# VARIABLES
    ${MOSEK_REQUIRED_VARS}
)

