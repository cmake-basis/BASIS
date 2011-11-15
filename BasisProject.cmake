##############################################################################
# @file  BasisProject.cmake
# @brief Meta-data of this BASIS project.
#
# This file defines project meta-data, i.e., attributes, which are used by
# BASIS to setup the project. Moreover, if the project is a subproject of
# another BASIS project, the dependencies to other subprojects are specified
# here such that the super-project can analyze the dependencies among its
# subprojects. Besides intra-project dependencies, dependencies on external
# packages are specified here as well.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# Note: The #Add*DependencyHere pattern is required by the basisproject tool.

basis_project (
  NAME             "BASIS"
  VERSION          "0.0.0"
  DESCRIPTION      "This package implements and supports the development of "
                   "software which follows the SBIA Build system And Software "
                   "Implementation Standard (BASIS)."
  DEPENDS          #AddDependencyHere
  DEPENDS_OPTIONAL "PythonInterp" "Perl" "PerlLibs" #AddOptionalDependencyHere
)
