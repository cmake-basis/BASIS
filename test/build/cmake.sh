#!/bin/bash
set -e

## Travis script to install CMake

version=${1:-3.3.1}
prefix="${2:-/opt/cmake-$version}"

if [[ $version == any ]]; then
  if [[ $TRAVIS_OS_NAME == linux ]]; then
    sudo apt-get install -y cmake
    exit 0
  elif [[ $TRAVIS_OS_NAME == osx   ]]; then
    brew install cmake
    exit 0
  fi
  version=3.3.1
fi

major=${version/.*}
minor=${version#*.}
minor=${minor/.*}

# 64-bit binaries are only available since CMake 3.1
if [ $major -gt 3 ] || [ $major -eq 3 -a $minor -gt 0 ]; then
  os=$TRAVIS_OS_NAME
fi
arch=x86_64

if [[ $os == linux ]]; then

  # Download and extract binary distribution package
  mkdir -p "$prefix"
  wget http://www.cmake.org/files/v$major.$minor/cmake-${version}-Linux-${arch}.tar.gz
  tar --strip-components 1 -C "$prefix" -xzf cmake-${version}-Linux-${arch}.tar.gz
  rm -f cmake-${version}-Linux-${arch}.tar.gz

elif [[ $os == osx ]]; then

  # Download and extract binary distribution package
  wget http://www.cmake.org/files/v$major.$minor/cmake-${version}-Darwin-${arch}.tar.gz
  tar -xzf cmake-${version}-Darwin-${arch}.tar.gz

  # Move extracted files to installation prefix
  for d in bin doc man share; do
    mkdir -p "$prefix/$d"
    mv -f "cmake-${version}-Darwin-x86_64/CMake.app/Contents/$d/"* "$prefix/$d/"
  done

  # Remove unused files
  rm -rf cmake-${version}-Darwin-${arch}

else

  # Download and extract source files
  wget http://www.cmake.org/files/v$major.$minor/cmake-${version}.tar.gz
  tar xzf cmake-${version}.tar.gz
  rm -f cmake-${version}.tar.gz

  # Configure build
  cd cmake-$version
  mkdir build && cd build
  cmake -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$prefix" \
        ..
  
  # Build and install
  make -j8 install

  # Remove sources and temporary build files
  cd ../.. && rm -rf cmake-$version

fi
