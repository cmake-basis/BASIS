#!/bin/bash
set -e

## Travis script to install CMake

version=${1:-3.3.1}
prefix="${2:-/opt/cmake-$version}"

if [[ $version == any ]]; then
  [[ $TRAVIS_OS_NAME != linux ]] || exec sudo apt-get install -y cmake
  [[ $TRAVIS_OS_NAME != osx   ]] || exec brew install cmake
fi

if [[ $TRAVIS_OS_NAME == linux ]]; then

  # Download and extract binary distribution package
  wget http://www.cmake.org/files/v${version%.*}/cmake-${version}-Linux-x86_64.tar.gz
  tar --strip-components 1 -C "$prefix" -xzf cmake-${version}-Linux-x86_64.tar.gz

elif [[ $TRAVIS_OS_NAME == osx ]]; then

  # Download and extract binary distribution package
  wget http://www.cmake.org/files/v${version%.*}/cmake-${version}-Darwin-x86_64.tar.gz
  tar -xzf cmake-${version}-Darwin-x86_64.tar.gz

  # Copy extracted files to installation prefix
  for d in bin doc man share; do
    mkdir -p "$prefix/$d" && mv -f "cmake-${version}-Darwin-x86_64/$d/*" "$prefix/$d/"
  done

else

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

fi
