#!/bin/bash
set -e

## Travis script to install Doxygen

version=${1:-1.8.10}
prefix=${2:-/opt/doxygen-$version}

if [[ $version == any ]]; then
  [[ $TRAVIS_OS_NAME != linux ]] || exec sudo apt-get install -y doxygen
  [[ $TRAVIS_OS_NAME != osx   ]] || exec brew install doxygen
fi

# Download and extract source files
wget ftp://ftp.stack.nl/pub/users/dimitri/doxygen-${version}.src.tar.gz
tar xzf doxygen-${version}.src.tar.gz

# Configure build
cd doxygen-$version
mkdir build && cd build
cmake -Dbuild_wizard=OFF \
      -Dbuild_doc=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      ..

# Build and install
make install
