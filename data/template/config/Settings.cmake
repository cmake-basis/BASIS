##############################################################################
# @file  Settings.cmake
# @brief General project build configuration.
#
# This file is included by basis_project_impl() after it looked for the
# required and optional dependencies and the CMake variables related to the
# project directory structure was included (see
# &lt;Project&gt;Directories.cmake file in @c PROJECT_BINARY_DIR).
# It is further included before the &lt;Project&gt;Settings.cmake file.
#
# In particular, build options should be added in this file using CMake's
# option() command. Further, any common settings related to using a found
# dependency can be set here if the basis_use_package() command was enable
# to import the required configuration of a particular external package.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

