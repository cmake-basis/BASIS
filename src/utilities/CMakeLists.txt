##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of utilities.
#
# Copyright (c) 2011-2012 University of Pennsylvania. <br />
# Copyright (c) 2013-2014 Andreas Schuh.              <br />
# All rights reserved.                                <br />
#
# See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
# or COPYING file for license information.
#
# Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
#          report issues at https://github.com/schuhschuh/cmake-basis/issues
##############################################################################

basis_make_target_uid (ALL_UTILITIES utilities)
add_custom_target (${ALL_UTILITIES})

# ----------------------------------------------------------------------------
# C++ utilities
add_subdirectory (cxx)

# ----------------------------------------------------------------------------
# Java utilities
if (Java_FOUND)
  add_subdirectory (java)
endif ()

# ----------------------------------------------------------------------------
# Python utilities
if (PythonInterp_FOUND)
  add_subdirectory (python)
endif ()

# ----------------------------------------------------------------------------
# Perl utilities
if (Perl_FOUND)
  add_subdirectory (perl)
endif ()

# ----------------------------------------------------------------------------
# BASH utilities
if (BASH_FOUND)
  add_subdirectory (bash)
endif ()

# ----------------------------------------------------------------------------
# MATLAB utilities
if (MATLAB_FOUND)
  add_subdirectory (matlab)
endif ()
