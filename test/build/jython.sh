#!/bin/bash
set -ev

## Travis script to install Sphinx

if [ -n "$jython_version" ]; then

  [ -n "$prefix" ] || prefix="/tmp/local"

  # Use dependencies built and installed from sources
  export PATH="$INSTALL_PREFIX/bin:$PATH"
  if [[ $TRAVIS_OS_NAME == linux ]]; then
    export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
  else
    export DYLD_LIBRARY_PATH="$prefix/lib:$DYLD_LIBRARY_PATH"
  fi

  # Install from binary package if possible
  if [[ $jython_version == any ]]; then
    if [[ $TRAVIS_OS_NAME == linux ]]; then
      sudo apt-get install -qq jython
    fi
  fi
 
  # TODO: Install from sources otherwise

fi
