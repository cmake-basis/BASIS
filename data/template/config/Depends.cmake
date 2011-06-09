##############################################################################
# \file  Depends.cmake
# \brief Contains find_package () commands to resolve dependencies.
#
# This file is included by the macro basis_project_initialize () if found in
# the directory PROJECT_CONFIG_DIR. It is supposed to resolve dependencies
# to other packages using find_package () or find_basis_package ().
#
# If no CMake find module (i.e., Find<package>.cmake) for an external package
# is available and the package does not provide a <package>Config.cmake or
# <package>-config.cmake file, write your own find module and store it in the
# PROJECT_CONFIG_DIR folder of the project or have someone else write one for
# you. Consider also to inform the maintainer of the BASIS package to
# integrate your module into the collection of BASIS CMake modules. If the
# external package might become popular also for use by others, it is even
# more likely that the BASIS developer will provide you with a CMake module.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################

