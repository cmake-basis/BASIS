# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of utilities.
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
