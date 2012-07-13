##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of utilities.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
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
