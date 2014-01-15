##############################################################################
# @file  config.sh
# @brief Defines constants such as the BASH version.
#
# Copyright (c) 2011-2012 University of Pennsylvania. <br />
# Copyright (c) 2013-2014 Andreas Schuh.              <br />
# All rights reserved.                                <br />
#
# See http://opensource.andreasschuh.com/cmake-basis/download.html#software-license
# or COPYING file for license information.
#
# Contact: Andreas Schuh <andreas.schuh.84@gmail.com>,
#          report issues at https://github.com/schuhschuh/cmake-basis/issues
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
