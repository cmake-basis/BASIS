#!/bin/bash
set -ev

## Travis script to install or build ITK

[ -n "$prefix"    ] || prefix="/tmp/local"
[ -n "$build_itk" ] || build_itk=no

# Install from binary package if possible
if [ -n "$itk_version" ] && [[ $build_itk == no ]]; then
  if [[ $TRAVIS_OS_NAME == linux ]]; then
    if [ $itk_version -eq 3 ]; then
      sudo apt-get install -qq libgdcm2-dev libvtkgdcm2-dev libfftw3-dev libvtk5-dev libinsighttoolkit3-dev
    else
      build_itk=yes
    fi
  else
    build_itk=yes
  fi
fi

# Otherwise, build and install from source files
[ -n "$itk_version" ] || build_itk=no
if [[ $build_itk == yes ]]; then

  # Use dependencies built and installed from sources
  export PATH="$INSTALL_PREFIX/bin:$PATH"
  if [[ $TRAVIS_OS_NAME == linux ]]; then
    export LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
  else
    export DYLD_LIBRARY_PATH="$prefix/lib:$DYLD_LIBRARY_PATH"
  fi

  # Download and extract source files
  wget -O InsightToolkit-${itk_version} http://sourceforge.net/projects/itk/files/itk/${itk_version%.*}/InsightToolkit-${itk_version}.tar.gz/download
  tar xzf InsightToolkit-${itk_version}

  # Configure build
  cd InsightToolkit-${itk_version}
  mkdir build && cd build

  if [ ${itk_version/.*} -ge 4 ]; then
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
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX="$prefix" \
          -DBUILD_EXAMPLES=OFF \
          -DBUILD_TESTING=OFF \
          -DBUILD_SHARED_LIBS=ON \
          ..
  fi

  # Build and install
  make install

fi
