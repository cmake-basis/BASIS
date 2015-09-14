#!/bin/bash
set -e

## Travis script to install ITK

version=${1:-4.8.0}
prefix=${2:-/opt/itk-$version}

# Install from binary package
if [[ $version == any ]]; then
  if [[ $TRAVIS_OS_NAME == linux ]]; then
    sudo apt-get install -qq libgdcm2-dev libvtkgdcm2-dev libfftw3-dev libvtk5-dev libinsighttoolkit3-dev
    exit 0
  elif [[ $TRAVIS_OS_NAME == osx ]]; then
    brew install homebrew/science/insighttoolkit
    exit 0
  fi
  version=4.8.0
fi

major=${version/.*}
minor=${version#*.}
minor=${minor/.*}

# Download and extract source files
wget -O InsightToolkit-${version}.tar.gz http://sourceforge.net/projects/itk/files/itk/$major.$minor/InsightToolkit-${version}.tar.gz/download
tar xzf InsightToolkit-${version}.tar.gz
rm -f InsightToolkit-${version}.tar.gz

# Configure build
cd InsightToolkit-$version
mkdir build && cd build

if [ ${version/.*} -ge 4 ]; then
  cmake -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$prefix" \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DITK_BUILD_DEFAULT_MODULES=OFF \
        -DITKGroup_Core=ON \
        -DITKGroup_IO=ON \
        ..
else
  cmake -Wno-dev \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$prefix" \
        -DITK_USE_SYSTEM_TIFF=ON \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS=ON \
        ..
fi

# Build and install
make -j8 install

# Remove sources and temporary build files
cd ../.. && rm -rf InsightToolkit-$version
