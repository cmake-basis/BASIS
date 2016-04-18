#!/bin/bash
set -e

echo "
################################################################################
# This script performs the steps of the BASIS Quick Start tutorial
#
#   http://cmake-basis.github.io/quickstart.html
#
# It is recommended, however, to perform these steps manually in order to
# get familiar with BASIS.
#
# Requirements: git, cmake, ninja or make
################################################################################
"

print_help_and_exit()
{
  echo "usage: `basename "$0"` [working_directory] [branch]" 1>&2
  exit 1
}

[ $# -le 2 ] || print_help_and_exit

# set working directory
LOCALDIR="${PWD}/BASIS Quick Start"
[ $# -lt 1 ] || LOCALDIR="$(mkdir -p "$1" 2> /dev/null && cd "$1" && pwd)"

# select Git branch
branch='master'
[ $# -lt 2 ] || branch="$2"
 
# choose CMake generator and corresponding build tool
buildtool=`which ninja` && generator='Ninja'
[ $? -eq 0 ] || { buildtool=`which make` && generator='Unix Makefiles'; }
[ $? -eq 0 ] || { echo "Either GNU Make or Ninja must be installed!" 1>&2; exit 1; }

# remove quick start example directories if they are already there
if [ -d "${LOCALDIR}/src/hellobasis" ]; then
  rm -rf "${LOCALDIR}/src/hellobasis"
fi
if [ -d "${LOCALDIR}/src/HelloTopLevel" ]; then
  rm -rf "${LOCALDIR}/src/HelloTopLevel"
fi

echo "
################################################################################
# Clone BASIS
################################################################################
"

    mkdir -p "${LOCALDIR}/src" && cd "${LOCALDIR}/src"
    if [ -d cmake-basis ]; then
      current_branch="$(cd cmake-basis && git rev-parse --abbrev-ref HEAD 2> /dev/null)"
    fi
    if [[ $current_branch == $branch ]]; then
      cd cmake-basis
      git pull
    elif [ -n "$current_branch" ]; then
      cd cmake-basis
      git checkout "$branch"
      git pull
    else
      git clone -b "$branch" https://github.com/cmake-basis/BASIS.git
      cd cmake-basis
    fi

echo "
################################################################################
# Build and Install BASIS
################################################################################
"

    mkdir -p build && cd build
    cmake .. "-G${generator}" "-DCMAKE_INSTALL_PREFIX=${LOCALDIR}" "-DBASIS_INSTALL_SCHEME=usr" -DBUILD_EXAMPLE=ON
    
    "${buildtool}" install

echo "
################################################################################
# Set variables to simplify later steps
################################################################################
"

    export PATH="${LOCALDIR}/bin:${PATH} "
    export BASIS_EXAMPLE_DIR="${LOCALDIR}/share/basis/example"
    export HELLOBASIS_RSC_DIR="${BASIS_EXAMPLE_DIR}/hellobasis"

echo "
################################################################################
# Create a BASIS project
################################################################################
"

    basisproject create --name HelloBasis --description "This is a BASIS project." --root "${LOCALDIR}/src/hellobasis"

echo "
################################################################################
# Add an Executable
################################################################################
"

    cd "${LOCALDIR}/src/hellobasis"
    cp "${HELLOBASIS_RSC_DIR}/helloc++.cxx" src/
    
    echo "
    basis_add_executable(helloc++.cxx)
    " >> src/CMakeLists.txt


echo "
################################################################################
# Add a private Library
################################################################################
"

    cd "${LOCALDIR}/src/hellobasis"
    cp "${HELLOBASIS_RSC_DIR}"/foo.* src/
    
    echo "
    basis_add_library(foo foo.cxx)
    " >> src/CMakeLists.txt

echo "
################################################################################
# Add a public Library
################################################################################
"

    cd "${LOCALDIR}/src/hellobasis"
    mkdir include/hellobasis
    
    echo "
    basis_add_library(bar bar.cxx)
    " >> src/CMakeLists.txt
    
    cp "${HELLOBASIS_RSC_DIR}/bar.cxx" src/
    cp "${HELLOBASIS_RSC_DIR}/bar.h" include/hellobasis/
    
echo "
################################################################################
# Compile HelloBasis Module
################################################################################
"

    mkdir "${LOCALDIR}/src/hellobasis/build"
    cd "${LOCALDIR}/src/hellobasis/build"
    cmake .. "-G${generator}" -DBUILD_DOCUMENTATION=ON "-DCMAKE_INSTALL_PREFIX=${LOCALDIR}"
    
    "${buildtool}" install

echo "
################################################################################
# Create a top-level project
################################################################################
"
    TOPLEVEL_DIR="${LOCALDIR}/src/HelloTopLevel"
    basisproject create --name HelloTopLevel --description "This is a BASIS TopLevel project. It demonstrates how easy it is to create a simple BASIS project." --root "${TOPLEVEL_DIR}" --toplevel

    
echo "
################################################################################
# Create a subproject which provides a library
################################################################################
"
    MODA_DIR="${LOCALDIR}/src/HelloTopLevel/modules/moda"
    basisproject create --name moda --description "Subproject library to be used elsewhere" --root "${MODA_DIR}" --module --include
    cp "${HELLOBASIS_RSC_DIR}/moda.cxx" "${MODA_DIR}/src/"
    mkdir "${MODA_DIR}/include/hellotoplevel"
    cp "${HELLOBASIS_RSC_DIR}/moda.h" "${MODA_DIR}/include/hellotoplevel/"
    
    echo "
    basis_add_library(moda SHARED moda.cxx)
    " >> "${MODA_DIR}/src/CMakeLists.txt"
    
echo "
################################################################################
# Create another subproject which uses the library of the first module
################################################################################
"
    MODB_DIR="${LOCALDIR}/src/HelloTopLevel/modules/modb"
    basisproject create --name modb --description "User example subproject executable utility repository that uses the library"  --root "${MODB_DIR}" --module --src --use moda
    cp "${HELLOBASIS_RSC_DIR}/userprog.cxx" "${MODB_DIR}/src/"
    
    echo "
    basis_add_executable(userprog.cxx)
    basis_target_link_libraries(userprog moda)
    " >> "${MODB_DIR}/src/CMakeLists.txt"

echo "
################################################################################
# Compile HelloTopLevel Module
################################################################################
"

    mkdir "${TOPLEVEL_DIR}/build"
    cd "${TOPLEVEL_DIR}/build"
    cmake .. "-G${generator}" "-DCMAKE_INSTALL_PREFIX=${LOCALDIR}" "-DBASIS_INSTALL_SCHEME=usr"
    
    "${buildtool}" install

echo "
################################################################################
# Testing the installed example executables
################################################################################
"

    export LD_LIBRARY_PATH="${LOCALDIR}/lib/hellotoplevel"
    export DYLD_LIBRARY_PATH="${LD_LIBRARY_PATH}"

    "${LOCALDIR}/bin/helloc++" | grep "How is it going?"           | echo "helloc++ test passed"
    "${LOCALDIR}/bin/userprog" | grep "Called the moda() function" | echo "userprog test passed"

echo "
################################################################################
# Execution complete!                              
#                                                  
# Be sure to browse the BASIS Quick Start working directory
#
#    '$LOCALDIR'
#
# to see how BASIS sets up project repositories.
#
# After you run and read this script,                         
# check out the BASIS tutorials, documentation, and website at:
#
#   http://cmake-basis.github.io/quickstart.html 
#
################################################################################
"
