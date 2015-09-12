#!/bin/bash
set -ev

## Travis script to build CMake from sources

[ -n "$prefix"        ] || prefix="/tmp/local"
[ -n "$cmake_version" ] || cmake_version=3.3.1

# Use dependencies built and installed from sources
export PATH="$INSTALL_PREFIX/bin:$PATH"
if [[ $TRAVIS_OS_NAME == linux ]]; then
  export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
else
  export DYLD_LIBRARY_PATH="$prefix/lib:$DYLD_LIBRARY_PATH"
fi

# Download and extract source files
wget http://www.cmake.org/files/v${cmake_version%.*}/cmake-${cmake_version}.tar.gz
tar xzf cmake-${cmake_version}.tar.gz

# Configure build
cd cmake-${cmake_version}
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      ..

# Build and install
make install
