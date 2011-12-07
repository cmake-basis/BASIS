##############################################################################
# @file  BasisProject.cmake
# @brief Meta-data of this BASIS project.
#
# This file defines project meta-data, i.e., attributes, which are used by
# BASIS to setup the project. Moreover, if the project is a module of another
# BASIS project, the dependencies to other modules have to be specified here
# such that the top-level project can analyze the inter-module dependencies.
# However, not only dependencies to other modules can be specified here,
# but also dependencies on external packages. A more flexible alternative to
# resolve external dependencies is to add the corresponding basis_find_package()
# statements to the Depends.cmake file. This should, however, only be done
# if specifying the dependencies as arguments to the basis_project() function
# cannot be used to resolve the dependencies properly. If you only need to
# make use of additional variables set by the package configuration file
# of the external package or the corresponding Find<Package>.cmake module,
# add the related CMake code to the Settings.cmake file instead.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisSettings
##############################################################################

# Note: The #Add*DependencyHere patterns are required by the basisproject tool
#       and should be kept at the end of the corresponding line.

basis_project (
  NAME                 "BASIS"
  VERSION               "0.0.0"
  DESCRIPTION           "This package implements and supports the development of "
                        "software which follows the SBIA Build system And Software "
                        "Implementation Standard (BASIS)."
  DEPENDS               #AddDependencyHere
  OPTIONAL_DEPENDS      PythonInterp Perl PerlLibs #AddOptionalDependencyHere
  TEST_DEPENDS          #AddTestDependencyHere
  OPTIONAL_TEST_DEPENDS MATLAB #AddOptionalTestDependencyHere
)
