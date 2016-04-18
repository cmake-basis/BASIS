#!/bin/bash
set -e

## Travis script to install CMake
os=$TRAVIS_OS_NAME

version=${1:-3.3.1}
prefix="${2:-/opt/cmake-$version}"

if [[ $version == any ]]; then
  if [[ $os == linux ]]; then
    sudo apt-get install -y cmake
    exit 0
  elif [[ $os == osx   ]]; then
    brew install cmake
    exit 0
  fi
  version=3.3.1
fi

major=${version/.*}
minor=${version#*.}
minor=${minor/.*}

if [[ $os == linux ]]; then

  # Download and extract binary distribution package
  if [ $major -gt 3 ] || [ $major -eq 3 -a $minor -gt 0 ]; then
    os_and_arch=Linux-x86_64
  else
    os_and_arch=Linux-i386
  fi

  mkdir -p "$prefix"
  wget --no-check-certificate https://cmake.org/files/v$major.$minor/cmake-${version}-${os_and_arch}.tar.gz
  tar --strip-components 1 -C "$prefix" -xzf cmake-${version}-${os_and_arch}.tar.gz
  rm -f cmake-${version}-${os_and_arch}.tar.gz

elif [[ $os == osx ]]; then

  # Download and extract binary distribution package
  if [ $major -gt 3 ] || [ $major -eq 3 -a $minor -gt 0 ]; then
    os_and_arch=Darwin-x86_64
  else
    os_and_arch=Darwin64-universal
  fi
  wget --no-check-certificate https://cmake.org/files/v$major.$minor/cmake-${version}-${os_and_arch}.tar.gz
  tar -xzf cmake-${version}-${os_and_arch}.tar.gz

  # Move extracted files to installation prefix
  for d in bin doc man share; do
    mkdir -p "$prefix/$d"
    mv -f "cmake-${version}-${os_and_arch}/CMake.app/Contents/$d/"* "$prefix/$d/"
  done

  # Remove unused files
  rm -rf cmake-${version}-Darwin-${arch}

else

  # Download and extract source files
  wget --no-check-certificate https://cmake.org/files/v$major.$minor/cmake-${version}.tar.gz
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
