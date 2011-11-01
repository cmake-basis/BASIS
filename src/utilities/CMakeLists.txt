##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of utilities.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# C++ utilities
if (BUILD_UTILITIES_FOR_CXX)
  add_subdirectory (cxx)
endif ()

# ----------------------------------------------------------------------------
# Java utilities
if (BUILD_UTILITIES_FOR_JAVA)
  add_subdirectory (java)
endif ()

# ----------------------------------------------------------------------------
# Python utilities
if (BUILD_UTILITIES_FOR_PYTHON)
  add_subdirectory (python)
endif ()

# ----------------------------------------------------------------------------
# Perl utilities
if (BUILD_UTILITIES_FOR_PERL)
  add_subdirectory (perl)
endif ()

# ----------------------------------------------------------------------------
# BASH utilities
if (BUILD_UTILITIES_FOR_BASH)
  add_subdirectory (bash)
endif ()

# ----------------------------------------------------------------------------
# MATLAB utilities
if (BUILD_UTILITIES_FOR_MATLAB)
  add_subdirectory (matlab)
endif ()
