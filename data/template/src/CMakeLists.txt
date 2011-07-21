##############################################################################
#! @file  CMakeLists.txt
#! @brief Build configuration of software.
#!
#! Copyright (c) 2011 University of Pennsylvania. All rights reserved.
#! See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#!
#! Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# library target(s)
# ============================================================================

# Add library target for each static or shared library (including MEX-files)
# using basis_add_library (). Note that basis_add_library() is used the same
# way as the CMake command add_library().
#
# See documentation of basis_add_executable() for details.
#
# See basis_add_library()
# See http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_library



# ============================================================================
# executable target(s)
# ============================================================================

# Add executable target for each executable program using basis_add_executable()
# which is used just the same way as the CMake command add_executable() is used.
#
# See basis_add_executable()
# See http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable
#
# The source_group() command can be used to group source files within IDEs
# such as the Microsoft Visual Studio IDE, in particular.
#
# \see http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:source_group
#
# Add script target for each executable script using basis_add_script().
#
# For convenience, the functions basis_add_scripts_by_extension() and
# basis_add_scripts_by_extensions() add all scripts within the current
# source directory with the given extensions. The filenames of the scripts
# may contain an optional ".in" suffix or ".in." as any part of the name.
#
# Moreover, basis_add_scripts() adds all scripts of common scripting languages
# given that the usual filename extensions are used. Hence, in most cases,
# the calling basis_add_scripts() is sufficient.
#
# The drawback of using one of these convenience functions is that when a
# script is added, CMake does not notice this because this CMakeLists.txt
# file has not changed. In this case, the execution of CMake has to be
# triggered manually.
#
# See basis_add_script()
# See basis_add_scripts_by_extension()
# See basis_add_scripts_by_extensions()
# See basis_add_scripts()

basis_add_scripts ()


