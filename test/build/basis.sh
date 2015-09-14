#!/bin/bash
set -e

## Travis build script for BASIS itself

[ -n "$prefix"    ] || prefix="/tmp/local"
[ -n "$utilities" ] || utilities=yes
[ -n "$tools"     ] || tools=yes
[ -n "$example"   ] || example=yes
[ -n "$doc"       ] || doc=no
[ -n "$tests"     ] || tests=no

# Use dependencies built and installed from sources
export PATH="$prefix/bin:$PATH"
[[ $TRAVIS_OS_NAME != linux ]] || export   LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
[[ $TRAVIS_OS_NAME != osx   ]] || export DYLD_LIBRARY_PATH="$prefix/lib:$DYLD_LIBRARY_PATH"

# Configure build
mkdir build && cd build
cmake -DBUILD_TESTING=$tests \
      -DBUILD_DOCUMENTATION=$doc \
      -DBASIS_ALL_DOC=yes \
      -DBUILD_PROJECT_TOOL=$tools \
      -DBUILD_EXAMPLE=$example \
      -DBUILD_BASIS_UTILITIES_FOR_CXX=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_BASH=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_PERL=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_PYTHON=$utilities \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      ..

# Build and install
make -j8 install

# Run tests
[[ $tests == no ]] || ctest -C Release -V
