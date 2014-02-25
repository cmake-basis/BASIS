# ============================================================================
# Copyright (c) 2014 Carnegie Mellon University
# All rights reserved.
#
# See COPYING file for license information or visit
# http://opensource.andreasschuh.com/cmake-basis/download.html#license
# ============================================================================

if (__BASIS_SUPER_BUILD_INCLUDED)
  return ()
else ()
  set (__BASIS_SUPER_BUILD_INCLUDED TRUE)
endif ()

include(ExternalProject)

##
# @brief super build for BASIS modules
#
function(basis_super_build PACKAGE_NAME)
  set(options )
  set(singleValueArgs DIR CMAKE_MODULE_PATH BINARY_DIR CMAKE_INSTALL_PREFIX)
  set(multiValueArgs  DEPENDS)
  
  cmake_parse_arguments(${PACKAGE_NAME} ${options} ${singleValueArgs} ${multiValueArgs} ${ARGN})

  # TODO: consider combining this variable with MODULE_${PACKAGE_NAME} variable
  #option (USE_SYSTEM_${PACKAGE_NAME} "Skip build of ${PACKAGE_NAME} if already installed." OFF)
  
  if(NOT ${PACKAGE_NAME}_CMAKE_MODULE_PATH)
    set(${PACKAGE_NAME}_CMAKE_MODULE_PATH "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")
  endif()
  
    # TODO: make sure default install prefix does not typically trample the installation
  if(NOT ${PACKAGE_NAME}_CMAKE_INSTALL_PREFIX)
    set(${PACKAGE_NAME}_CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
  endif()
  
  # set directory where binaries will build if it was not already set by the arguments
  if(NOT ${PACKAGE_NAME}_BINARY_DIR)
    if(MODULE_${PACKAGE_NAME}_BINARY_DIR)
      set(${PACKAGE_NAME}_BINARY_DIR ${MODULE_${PACKAGE_NAME}_BINARY_DIR})
    elseif(NOT MODULE_${PACKAGE_NAME}_BINARY_DIR)
      set(MODULE_${PACKAGE_NAME}_BINARY_DIR ${PROJECT_BINARY_DIR})
    endif()
  endif()
  
  if(NOT ${PACKAGE_NAME}_DIR AND MODULE_${MODULE}_SOURCE_DIR)
    set(${PACKAGE_NAME}_DIR "${MODULE_${MODULE}_SOURCE_DIR}")
  endif()

  # TODO: Fix DEPENDS parameter. May need to separate basis module and regular dependencies so they can specified separately for the super build.
  # TODO: Consider using the EP_BASE path with SET(ep_base ${${PACKAGE_NAME}_BINARY_DIR}) instead. (ep stands for external project) 
  # TODO: Figure out why a few intermediate files are still being put in the ${CMAKE_BINARY_DIR}/${PACKAGE_NAME}-prefix/ directory
  # TODO: Check for additional useful -D parameters.


  if(BASIS_DEBUG)
      message(STATUS 
    "basis_super_build() Module:
      ExternalProject_Add(${PACKAGE_NAME}
                          #DEPENDS ${${PACKAGE_NAME}_DEPENDS}
                          SOURCE_DIR ${${PACKAGE_NAME}_DIR}
                          CMAKE_ARGS 
                            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> 
                            -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} 
                            -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} 
                            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} 
                            ${${PACKAGE_NAME}_CMAKE_MODULE_PATH}
                            -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
                          CMAKE_GENERATOR
                            ${CMAKE_GENERATOR}
                          CMAKE_TOOLSET
                            ${CMAKE_TOOLSET}
                          BINARY_DIR
                            ${${PACKAGE_NAME}_BINARY_DIR}
                          INSTALL_DIR
                            ${${PACKAGE_NAME}_CMAKE_INSTALL_PREFIX}
                          )
    "  )
  endif()
  
    #if(USE_SYSTEM_${PACKAGE_NAME})
    #  find_package(${PACKAGE_NAME})
    #elseif()
    
      ExternalProject_Add(${PACKAGE_NAME}
                          #DEPENDS ${${PACKAGE_NAME}_DEPENDS}
                          SOURCE_DIR ${${PACKAGE_NAME}_DIR}
                          CMAKE_ARGS 
                            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> 
                            -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} 
                            -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS} 
                            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} 
                            ${${PACKAGE_NAME}_CMAKE_MODULE_PATH}
                            -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
                          CMAKE_GENERATOR
                            ${CMAKE_GENERATOR}
                          CMAKE_TOOLSET
                            ${CMAKE_TOOLSET}
                          BINARY_DIR
                            ${${PACKAGE_NAME}_BINARY_DIR}
                          INSTALL_DIR
                            ${${PACKAGE_NAME}_CMAKE_INSTALL_PREFIX}
                          )
                        
  #endif()
endfunction()