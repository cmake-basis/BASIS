#!/bin/bash
set -ev

## Travis script to build Doxygen from sources

[ -n "$prefix"          ] || prefix="/tmp/local"
[ -n "$doxygen_version" ] || doxygen_version=1.8.10

# Install dependencies
if [[ $TRAVIS_OS_NAME == linux ]]; then
  sudo apt-get install -qq graphviz
fi

# Use dependencies built and installed from sources
export PATH="$INSTALL_PREFIX/bin:$PATH"
if [[ $TRAVIS_OS_NAME == linux ]]; then
  export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
else
  export DYLD_LIBRARY_PATH="$prefix/lib:$DYLD_LIBRARY_PATH"
fi

# Download and extract source files
wget ftp://ftp.stack.nl/pub/users/dimitri/doxygen-${doxygen_version}.src.tar.gz
tar xzf doxygen-${doxygen_version}.src.tar.gz

# Configure build
cd doxygen-${doxygen_version}
mkdir build && cd build
cmake -Dbuild_wizard=OFF \
      -Dbuild_doc=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      ..

# Build and install
make install
