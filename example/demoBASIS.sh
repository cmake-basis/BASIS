set -e
# Demo script:
#clone BASIS (or basis template?)

export START=`pwd`

# build basis

echo "
############################################
# Clone BASIS
############################################
"

    mkdir -p ${START}/demobasis/src
    cd ${START}/demobasis/src
    git clone https://github.com/schuhschuh/cmake-basis.git
    cd cmake-basis
    # begin temporary workaround until after 3.1 release:
    git fetch
    git checkout feature/#365-quickstart-script
    # end temporary workaround until after 3.1 release

echo "
############################################
# Build and Install BASIS
############################################
"

    mkdir build && cd build
    cmake .. -GNinja -DCMAKE_INSTALL_PREFIX=${START}/demobasis -DBUILD_EXAMPLE=ON
    
    ninja install


echo "
############################################
# Set variables to simplify later steps
############################################
"

    export PATH="${START}/demobasis/bin:${PATH} "
    export BASIS_EXAMPLE_DIR="${START}/demobasis/share/basis/example"
    export HELLOBASIS_RSC_DIR="${BASIS_EXAMPLE_DIR}/hellobasis"

echo "
############################################
# Create a BASIS project
############################################
"

    basisproject create --name HelloBasis --description "This is a BASIS project."  --root ${START}/demobasis/src/hellobasis --full

echo "
############################################
# Add an Executable
############################################
"

    cd ${START}/demobasis/src/hellobasis
    
    cp ${HELLOBASIS_RSC_DIR}/helloc++.cxx src/
    
    echo "
    basis_add_executable(helloc++.cxx)
    " >> src/CMakeLists.txt


echo "
############################################
# Add a private Library
############################################
"

    cd ${START}/demobasis/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/foo.* src/
    
    echo "
    basis_add_library(foo.cxx)
    " >> src/CMakeLists.txt

echo "
############################################
# Add a public Library
############################################
"

    cd ${START}/demobasis/src/hellobasis
    mkdir include/hellobasis
    
    echo "
    basis_add_library(bar.cxx)
    " >> src/CMakeLists.txt
    
    cp ${HELLOBASIS_RSC_DIR}/bar.cxx src/
    cp ${HELLOBASIS_RSC_DIR}/bar.h include/hellobasis/
    
    cd ${START}/demobasis/src/

echo "
############################################
# Compile HelloBasis Module
############################################
"

    mkdir ${START}/demobasis/src/hellobasis/build
    cd ${START}/demobasis/src/hellobasis/build
    cmake -GNinja -DBUILD_DOCUMENTATION=ON -D CMAKE_INSTALL_PREFIX=${START}/demobasis ..
    
    ninja install
    
    
echo "
############################################
# Create a top-level repository
############################################
"
    export TOPLEVEL_DIR="${START}/demobasis/src/HelloTopLevel"
    basisproject create --name HelloTopLevel --description "This is a BASIS TopLevel project. It demonstrates how easy it is to create a simple BASIS project."  --root ${TOPLEVEL_DIR}  --toplevel

    
echo "
############################################
# Create a subproject library repository
############################################
"
    export MODA_DIR="${START}/demobasis/src/HelloTopLevel/modules/moda"
    basisproject create --name moda --description "Subproject library to be used elsewhere" --root ${MODA_DIR} --module --include
    cp ${HELLOBASIS_RSC_DIR}/moda.cxx ${MODA_DIR}/src/
    mkdir ${MODA_DIR}/include/moda
    cp ${HELLOBASIS_RSC_DIR}/moda.h ${MODA_DIR}/include/moda/
    
    
    echo "
    basis_add_library(moda SHARED moda.cxx)
    " >> ${MODA_DIR}/src/CMakeLists.txt
    
    
    
echo "
#########################################################################
# Create a subproject executable utility repository that uses the library
#########################################################################
"
    export MODB_DIR="${START}/demobasis/src/HelloTopLevel/modules/modb"
    basisproject create --name modb --description "User example subproject executable utility repository that uses the library"  --root ${MODB_DIR} --module --src --use moda
    cp ${HELLOBASIS_RSC_DIR}/userprog.cpp ${MODB_DIR}/src/
    
    echo "
    basis_add_executable(userprog.cpp)
    basis_target_link_libraries(userprog moda)
    " >> ${MODB_DIR}/src/CMakeLists.txt


echo "
############################################
# Compile HelloTopLevel Module
############################################
"

    mkdir ${TOPLEVEL_DIR}/build
    cd ${TOPLEVEL_DIR}/build
    cmake -GNinja -D CMAKE_INSTALL_PREFIX=${START}/demobasis ..
    
    ninja install
    
    
    