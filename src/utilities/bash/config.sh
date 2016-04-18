# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  config.sh
# @brief Defines constants such as the BASH version.
##############################################################################

[ "${_BASIS_CONFIG_INCLUDED}" == 'true' ] || {
_BASIS_CONFIG_INCLUDED='true'


## @addtogroup BasisBashUtilities
#  @{


## @brief Major version number of Bash interpreter.
BASH_VERSION_MAJOR=${BASH_VERSION%%.*}
## @brief Minor version number of Bash interpreter.
BASH_VERSION_MINOR=${BASH_VERSION#*.}
BASH_VERSION_MINOR=${BASH_VERSION_MINOR%%.*}

readonly BASH_VERSION_MAJOR
readonly BASH_VERSION_MINOR


## @}
# end of Doxygen group


} # _BASIS_CONFIG_INCLUDED
