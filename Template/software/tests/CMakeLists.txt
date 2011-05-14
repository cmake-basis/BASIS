##############################################################################
# \file  CMakeLists.txt
# \brief Root CMakeLists.txt file of unit testing tree.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

# ============================================================================
# custom settings
# ============================================================================

# configure custom CTest settings and/or copy them to binary tree
configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/CTestCustom.cmake.in"
  "${PROJECT_BINARY_DIR}/CTestCustom.cmake"
  @ONLY
)

# ============================================================================
# unit tests
# ============================================================================

