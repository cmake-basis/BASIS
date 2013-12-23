##############################################################################
# @file  Settings.cmake
# @brief Non-default project settings.
#
# This file is included by basis_project_impl(), after it looked for the
# required and optional dependencies and the CMake variables related to the
# project directory structure were defined (see Directories.cmake file in
# @c BINARY_CONFIG_DIR). It is further included before the BasisSettings.cmake
# file.
#
# In particular build options should be added in this file using CMake's
# <a href="http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:option">
# option()</a> command. Further, any common settings related to using a found
# dependency can be set here if the basis_use_package() command was enable
# to import the required configuration of a particular external package.
#
# Copyright (c) <copyright>
# All rights reserved.
#
# <license>
#
# Contact: <contact>
#
# @ingroup BasisSettings
##############################################################################

