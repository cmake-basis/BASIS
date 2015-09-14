#!/bin/bash
set -e

## Travis script to install CMake

version=${1:-3.3.1}
prefix="${2:-/opt/cmake-$version}"

if [[ $version == any ]]; then
  [[ $TRAVIS_OS_NAME != linux ]] || exec sudo apt-get install -y cmake
  [[ $TRAVIS_OS_NAME != osx   ]] || exec brew install cmake
fi

# Download and extract source files
wget http://www.cmake.org/files/v${version%.*}/cmake-${version}.tar.gz
tar xzf cmake-${version}.tar.gz

# Configure build
cd cmake-$version
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      ..

# Build and install
make install
