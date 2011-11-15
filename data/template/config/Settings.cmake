##############################################################################
# @file  Settings.cmake
# @brief General project build configuration.
#
# This file is included by basis_project_initialize() and can be used to
# overwrite the BASIS build configuration as defined by the Settings.cmake
# module of BASIS and to add project specific settings.
#
# In particular, build options should be added in this file using CMake's
# option() command. Further, any common settings related to using a found
# dependency can be set here if basis_use_package() was not sufficient for
# a particular external package in case it is not CMake-aware.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

