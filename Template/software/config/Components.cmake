##############################################################################
# \file  Components.cmake
# \brief Specifies the CPack components.
#
# This file is included by the module SbiaPack.cmake after the CPack package
# is included by that module. It is used to enable the configuration of a
# component-based installation.
#
# Use the functions sbia_add_component () or sbia_add_component_group ()
# to add a component or component group, respectively. These functions
# will then also add custom install targets such that each component can be
# installed individually.
#
# For CPack generators which generates several packages the default behavior
# is to generate one package per component group. However, one can modify this
# default behavior by setting CPACK_COMPONENTS_GROUPING to one of the
# following values:
#
# ALL_GROUPS_IN_ONE     : Generate separate package for each component group.
# IGNORE                : Generate separate package for each component.
# ALL_COMPONENTS_IN_ONE : Generate single package for all components.
#
# \see http://www.vtk.org/Wiki/CMake:Component_Install_With_CPack \
#        #Controlling_Differents_Ways_of_packaging_components
#
# For further settings regarding component-based installers refer to the
# documentation of the macros cpack_add_component () and
# cpack_add_component_group ().
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################


