##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of testing ressources.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

basis_add_executable (dummy_command dummy_command.cxx)
basis_set_target_properties(dummy_command PROPERTIES SYMLINK_NAME none)
