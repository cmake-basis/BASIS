#!/bin/bash
set -e

## Travis build script for BASIS itself

[ -n "$prefix"    ] || prefix="/tmp/local"
[ -n "$utilities" ] || utilities=yes
[ -n "$tools"     ] || tools=yes
[ -n "$example"   ] || example=yes
[ -n "$doc"       ] || doc=no
[ -n "$manual"    ] || manual=no
[ -n "$tests"     ] || tests=no

cmake_python_opt=
if [[ $TRAVIS_OS_NAME == linux ]]; then
  [[ $python == 3 ]] || python=''
  cmake_python_opt="-DPYTHON_EXECUTABLE=/usr/bin/python$python"
fi

# Use dependencies built and installed from sources
export PATH="$prefix/bin:$PATH"
[[ $TRAVIS_OS_NAME != linux ]] || export   LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
[[ $TRAVIS_OS_NAME != osx   ]] || export DYLD_LIBRARY_PATH="$prefix/lib:$DYLD_LIBRARY_PATH"

# Configure build
if [[ $doc == yes ]] || [[ $manual == yes ]]; then
  enable_doc=yes
else
  enable_doc=no
fi
mkdir build && cd build
cmake -DBUILD_TESTING=$tests \
      -DBUILD_DOCUMENTATION=$enable_doc \
      -DBUILD_PROJECT_TOOL=$tools \
      -DBUILD_EXAMPLE=$example \
      -DBUILD_BASIS_UTILITIES_FOR_CXX=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_BASH=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_PERL=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_PYTHON=$utilities \
      -DSOFTWAREMANUAL_PDF_UPDATE=no \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      $cmake_python_opt \
      ..

# Build and install
make -j8
[[ $doc    == no ]] || make softwaremanual_html
[[ $manual == no ]] || make softwaremanual_pdf
make -j8 install

# Run tests
[[ $tests == no ]] || ctest -C Release -V
