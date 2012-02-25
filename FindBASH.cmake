##############################################################################
# @file  FindBASH.cmake
# @brief Find BASH interpreter.
#
# Sets the CMake variables @c BASH_FOUND and @c BASH_EXECUTABLE.
#
# Copyright (c) 2012, University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeFindModules
##############################################################################

# ----------------------------------------------------------------------------
# find BASH executable
find_program (BASH_EXECUTABLE bash)
mark_as_advanced (BASH_EXECUTABLE)

# ----------------------------------------------------------------------------
# handle the QUIETLY and REQUIRED arguments and set *_FOUND to TRUE
# if all listed variables are found or TRUE
include (FindPackageHandleStandardArgs)

find_package_handle_standard_args (
  BASH
  REQUIRED_VARS
    BASH_EXECUTABLE
)
