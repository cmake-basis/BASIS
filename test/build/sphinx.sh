#!/bin/bash
set -ev

## Travis script to install Sphinx

[ -n "$prefix" ] || prefix="/tmp/local"

# Install prerequisites
sudo apt-get install -qq texlive-fonts-recommended 

# Use dependencies built and installed from sources
export PATH="$INSTALL_PREFIX/bin:$PATH"
if [[ $TRAVIS_OS_NAME == linux ]]; then
  export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
else
  export DYLD_LIBRARY_PATH="$prefix/lib:$DYLD_LIBRARY_PATH"
fi

# Install from binary package if possible
if [ -z "$sphinx_version" ]; then
  if [[ $TRAVIS_OS_NAME == linux ]]; then
    sudo apt-get install -qq python-sphinx
  fi
fi

# TODO
