# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2014 Carnegie Mellon University
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  BasisProject.cmake
# @brief Sets basic information about a BASIS Project and calls basis_project().
#
# This file defines basic information about a project by calling 
# the basis_project() function. This basic information, also known as metadata, 
# is used by BASIS to setup the project. Moreover, if the project is a module 
# of another BASIS project, the dependencies to other modules have to be specified 
# here such that the top-level project can analyze the inter-module dependencies.
#
# @sa https://cmake-basis.github.io/standard/modules.html
#
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
# Example:
# @code
# basis_project (
#   # ------------------------------------------------------------------------
#   # meta-data
#   NAME              MyProject
#   PACKAGE_VENDOR    shortvname  # Note: Part of default CMAKE_INSTALL_PREFIX
#   VERSION           1.1.5
#   DESCRIPTION       "This is the description of the project, which is useful for this"
#                     " important thing and that important thing."
#                     " MyProject follows the BASIS implementation standard."
#   AUTHOR            "Ima Nauthor"
#   PROVIDER_NAME     "Great Product Co"
#   PROVIDER_WEBSITE  "http://www.greatproductcompany.com"
#   PROVIDER_LOGO     "${PROJECT_SOURCE_DIR}/doc/logo.png"
#   DIVISION_NAME     "Awesome App Division"
#   DIVISION_WEBSITE  "http://www.awesomeapp.greatproductcompany.com"
#   DIVISION_LOGO     ""${PROJECT_SOURCE_DIR}/doc/division_logo.png""
#   COPYRIGHT         "Copyright (c) 2014 Great Product Co"
#   LICENSE           "See COPYING file."
#   CONTACT           "Contact <info@greatproductcompany.com>"
#   # ------------------------------------------------------------------------
#   # dependencies
#   DEPENDS          
#     NiftiCLib 
#     Python{Interp}
#   OPTIONAL_DEPENDS 
#     Jython{Interp}
#     Perl
#     MATLAB{matlab}
#     BASH
#     Doxygen
#     Sphinx{build}
#   TEST_DEPENDS     
#     Perl
#   OPTIONAL_TEST_DEPENDS
#     MATLAB{mex}
#     MATLAB{mcc}
# )
# @endcode
#
# @ingroup BasisSettings
##############################################################################

# Note: The #<*dependency> patterns are required by the basisproject tool
#       and should be kept on a separate line as last commented argument of
#       the corresponding options of the basis_project() command.

basis_project (
  # --------------------------------------------------------------------------
  # meta-data
  NAME          "BASIS"
  VERSION       "3.3.0"
  AUTHORS       "Andreas Schuh"
  DESCRIPTION   "This package implements and supports the development of "
                "software which follows the CMake Build system And Software "
                "Implementation Standard (BASIS)."
  WEBSITE       "https://cmake-basis.github.io"
  COPYRIGHT     "2011-12 University of Pennsylvania, 2013-14 Carnegie Mellon University, 2013-16 Andreas Schuh"
  LICENSE       "See https://cmake-basis.github.io/download.html#license or COPYING file."
  CONTACT       "andreas.schuh.84@gmail.com"
  TEMPLATE      "basis/1.4"
  PACKAGE_LOGO  "doc/static/logo.svg"

  # --------------------------------------------------------------------------
  # dependencies
  DEPENDS
    #<dependency>
  OPTIONAL_DEPENDS
    Python{Interp}  # enables support for Python if package found
    Jython{Interp}  # enables support for Jython if package found
    Perl            # enables support for Perl   if package found
    MATLAB{matlab}  # enabled support for MATLAB if package found
    BASH            # enables support for Bash   if package found
    #<optional-dependency>
  TOOLS_DEPENDS
    Perl
    Python{Interp}
  OPTIONAL_TOOLS_DEPENDS
    ITK             # optionally used by basistest-driver, TODO: get rid of this dependency
  TEST_DEPENDS
    #<test-dependency>
  OPTIONAL_TEST_DEPENDS
    MATLAB{mex}     # enables test of MEX-file generation
    MATLAB{mcc}     # enables test of MATLAB .m file compilation
    #<optional-test-dependency>
)
