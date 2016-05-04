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

with_bash=$utilities
with_perl=$utilities
with_python=$utilities

if [ -z "$jython" ] || [[ $jython == none ]]; then
  with_jython=off
else
  with_jython=on
fi

if [ -z "$itk" ] || [[ $itk == none ]] || [[ $tools == no ]]; then
  with_itk=off
else
  with_itk=on
fi

cmake_generator_opt=
if [[ $TRAVIS_OS_NAME == osx ]]; then
  # Use Xcode generator to test handling of IDE $<CONFIG> subdirectories
  cmake_generator_opt="-GXcode"
fi

cmake_python_opt=
if [[ $TRAVIS_OS_NAME == linux ]]; then
  if [[ $python == 3 ]]; then
    cmake_python_opt="-DPYTHON_EXECUTABLE=/usr/bin/python3"
  else
    cmake_python_opt="-DPYTHON_EXECUTABLE=/usr/bin/python"
  fi
elif [[ $TRAVIS_OS_NAME == osx ]]; then
  if [[ $python == 3 ]]; then
    cmake_python_opt="-DPYTHON_EXECUTABLE=/usr/local/bin/python3"
  else
    cmake_python_opt="-DPYTHON_EXECUTABLE=/usr/bin/python"
  fi
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
cmake $cmake_generator_opt \
      -DBUILD_TESTING=$tests \
      -DBUILD_DOCUMENTATION=$enable_doc \
      -DBUILD_SOFTWAREMANUAL=$manual \
      -DBUILD_APPLICATIONS=$tools \
      -DBUILD_EXAMPLE=$example \
      -DBUILD_BASIS_UTILITIES_FOR_CXX=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_BASH=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_PERL=$utilities \
      -DBUILD_BASIS_UTILITIES_FOR_PYTHON=$utilities \
      -DWITH_BASH=$with_bash \
      -DWITH_Perl=$with_perl \
      -DWITH_Python=$with_python \
      -DWITH_Jython=$with_jython \
      -DWITH_ITK=$with_itk \
      -DWITH_MATLAB=off \
      -DSOFTWAREMANUAL_PDF_UPDATE=no \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      $cmake_python_opt \
      ..

# Build
cmake --build . --config Release
if [[ $manual == yes ]]; then
  cmake --build . --config Release --target softwaremanual # manual + site
elif [[ $doc == yes ]]; then
  cmake --build . --config Release --target apidoc # Doxygen
fi

# Run tests
[[ $tests == no ]] || ctest -C Release -V

# Install
cmake --build . --config Release --target install
