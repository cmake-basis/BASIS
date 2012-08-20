##############################################################################
# @file  config.sh
# @brief Defines constants such as the BASH version.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
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
