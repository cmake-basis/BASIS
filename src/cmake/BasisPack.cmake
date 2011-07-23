##############################################################################
#! @file  BasisPack.cmake
#! @brief CPack configuration. Include this module instead of CPack.
#!
#! This module implements the packaging of BASIS projects.
#!
#! @note This module is included by basis_project_finalize().
#!
#! Overwrite the package information set by this module either in a file
#! Package.cmake or a file Package.cmake.in located in the directory
#! specified by PROJECT_CONFIG_DIR. The latter is configured and copied to the
#! binary tree before included by this module. Further, to enable a
#! component-based installation, provide either a file Components.cmake or
#! Components.cmake.in again in the directory specified by PROJECT_CONFIG_DIR.
#! Also in this case, the latter is configured via CMake's configure_file()
#! before use. This file is referred to as components definition (file).
#!
#! Components can be added in the components definition using the command
#! basis_add_component(). Several components can be grouped together and a
#! group description be added using the command basis_add_component_group().
#! Different pre-configured install types which define a certain selection of
#! components to install can be added using basis_add_install_type().
#! Note that all these BASIS functions are wrappers around the corresponding
#! CPack functions.
#!
#! @sa CPack.cmake
#! @sa http://www.vtk.org/Wiki/CMake:Component_Install_With_CPack#Component-Based_Installers_with_CPack
#!
#! Copyright (c) 2011 Univeristy of Pennsylvania. All rights reserved.
#! See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#!
#! Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#!
#! @ingroup CMakeAPI
##############################################################################

# get directory of this file
#
# Note: This variable was just recently introduced in CMake, it is derived
#       here from the already earlier added variable CMAKE_CURRENT_LIST_FILE
#       to maintain compatibility with older CMake versions.
get_filename_component (CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)


# ============================================================================
# system libraries
# ============================================================================

# find required runtime libraries
set (CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)
include (InstallRequiredSystemLibraries)

# include system runtime libraries in the installation
if (CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS)
  if (WIN32)
    install (
      PROGRAMS    ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
      DESTINATION ${INSTALL_RUNTIME_DIR}
    )
  else ()
    install (
      PROGRAMS    ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
      DESTINATION ${INSTALL_LIBRARY_DIR}
    )
  endif ()
endif ()

# ============================================================================
# package information
# ============================================================================

# general information
set (CPACK_PACKAGE_NAME                "${PROJECT_NAME}")
set (CPACK_PACKAGE_VERSION_MAJOR       "${PROJECT_VERSION_MAJOR}")
set (CPACK_PACKAGE_VERSION_MINOR       "${PROJECT_VERSION_MINOR}")
set (CPACK_PACKAGE_VERSION_PATCH       "${PROJECT_VERSION_PATCH}")
set (CPACK_PACKAGE_VERSION             "${PROJECT_VERSION}")
set (CPACK_PACKAGE_VENDOR              "${PROJECT_PACKAGE_VENDOR}")
set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set (CPACK_RESOURCE_FILE_README        "${PROJECT_README_FILE}")
set (CPACK_RESOURCE_FILE_LICENSE       "${PROJECT_LICENSE_FILE}")

if (PROJECT_INSTALL_FILE)
  set (CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_INSTALL_FILE}")
endif ()

if (PROJECT_WELCOME_FILE)
  set (CPACK_RESOURCE_FILE_WELCOME "${PROJECT_WELCOME_FILE}")
endif ()

set (CPACK_INSTALL_PREFIX      "${CMAKE_INSTALL_PREFIX}")
set (CPACK_PACKAGE_RELOCATABLE "true")

# system name
string (TOLOWER "${CMAKE_SYSTEM_NAME}" CPACK_SYSTEM_NAME)
if (${CPACK_SYSTEM_NAME} MATCHES "windows")
  if (CMAKE_CL_64)
    set (CPACK_SYSTEM_NAME "win64")
  else ()
    set (CPACK_SYSTEM_NAME "win32")
  endif ()
endif ()

# binary package
set (CPACK_GENERATOR                   "TGZ")
set (CPACK_INCLUDE_TOPLEVEL_DIRECTORY  "1")
set (CPACK_TOPLEVEL_TAG                "${CPACK_SYSTEM_NAME}")
set (CPACK_PACKAGE_FILE_NAME           "${PROJECT_NAME_LOWER}-${PROJECT_VERSION}-${CPACK_SYSTEM_NAME}")
if (CMAKE_SYSTEM_PROCESSOR)
  set (CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
endif ()

# source package
set (CPACK_SOURCE_GENERATOR         "TGZ")
set (CPACK_SOURCE_TOPLEVEL_TAG      "${CPACK_SYSTEM_NAME}-source")
set (CPACK_SOURCE_PACKAGE_FILE_NAME "${PROJECT_NAME_LOWER}-${PROJECT_VERSION}-source")

# ----------------------------------------------------------------------------
#! @todo The proper values for the following options still need to be
#!       figured. For the moment, just ignore these settings. NSIS might
#!       anyways not be supported in the near future.
# ----------------------------------------------------------------------------

if (WIN32 AND NOT UNIX)
  # There is a bug in NSI that does not handle full unix paths properly. Make
  # sure there is at least one set of four (4) backlasshes.
#  set (CPACK_PACKAGE_ICON             "${CMake_SOURCE_DIR}/Utilities/Release\\\\InstallIcon.bmp")
#  set (CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\MyExecutable.exe")
#  set (CPACK_NSIS_DISPLAY_NAME        "${CPACK_PACKAGE_INSTALL_DIRECTORY} ${PROJECT_NAME}")
#  set (CPACK_NSIS_HELP_LINK           "http:\\\\\\\\www.my-project-home-page.org")
#  set (CPACK_NSIS_URL_INFO_ABOUT      "http:\\\\\\\\www.my-personal-home-page.com")
  set (CPACK_NSIS_CONTACT             "sbia-software at uphs.upenn.edu")
  set (CPACK_NSIS_MODIFY_PATH         "ON")
else ()
#  set (CPACK_STRIP_FILES        "bin/MyExecutable")
#  set (CPACK_SOURCE_STRIP_FILES "")
endif ()

# ============================================================================
# source package
# ============================================================================

#! @brief Patterns to be ignored when creating source package.
#!
#! @ingroup CMakeAPI
set (
  CPACK_SOURCE_IGNORE_FILES
    "${CPACK_SOURCE_IGNORE_FILES}"
	"/CVS/"
	"/.svn/"
	".swp$"
	".#"
	"/#"
	".*~"
	"cscope.*"
	"[b|B]uild"
)

# ============================================================================
# include project package information
# ============================================================================

if (EXISTS "${PROJECT_CONFIG_DIR}/Package.cmake.in")
  configure_file ("${PROJECT_CONFIG_DIR}/Package.cmake.in"
                  "${PROJECT_BINARY_DIR}/Package.cmake" @ONLY)
  include ("${PROJECT_BINARY_DIR}/Package.cmake")
elseif (EXISTS "${PROJECT_CONFIG_DIR}/Package.cmake")
  include ("${PROJECT_CONFIG_DIR}/Package.cmake")
endif ()

# ============================================================================
# build package
# ============================================================================

include (CPack)

# ============================================================================
# components
# ============================================================================

# ----------------------------------------------------------------------------
# utilities
# ----------------------------------------------------------------------------

#! @addtogroup CMakeAPI
#! @{

# ****************************************************************************
#! @brief Add component group.
#!
#! @attention This functionality is not yet entirely implemented.
#! @todo Come up and implement components concept which fits into superproject concept.
#!
#! @sa http://www.cmake.org/pipermail/cmake/2008-August/023336.html
#! @sa cpack_add_component_group()
#!
#! @param [in] GRPNAME Name of the component group.
#! @param [in] ARGN    Further arguments passed to cpack_add_component_group().
#!
#! @returns Adds the component group @p GRPNAME.

function (basis_add_component_group GRPNAME)
  set (OPTION_NAME)
  set (PARENT_GROUP)

  foreach (ARG ${ARGN})
    if (OPTION_NAME)
      set (${OPTION_NAME} "${ARG}")
      set (OPTION_NAME)
      break ()
    else ()
      if ("${ARG}" STREQUAL "PARENT_GROUP")
        set (OPTION_NAME "PARENT_GROUP")
      endif ()
    endif ()
  endforeach ()

  cpack_add_component_group (${GRPNAME} ${ARGN})

  add_custom_target (install_${GRPNAME})

  if (PARENT_GROUP)
    add_dependencies (install_${PARENT_GROUP} install_${GRPNAME})
  endif ()
endfunction ()

# ****************************************************************************
#! @brief Add component.
#!
#! @attention This functionality is not yet entirely implemented.
#! @todo Come up and implement components concept which fits into superproject concept.
#!
#! @sa http://www.cmake.org/pipermail/cmake/2008-August/023336.html
#! @sa cpack_add_component()
#!
#! @param [in] COMPNAME Name of the component.
#! @param [in] ARGN     Further arguments passed to cpack_add_component().
#!
#! @returns Adds the component named @p COMPNAME.

function (basis_add_component COMPNAME)
  set (OPTION_NAME)
  set (GROUP)

  foreach (ARG ${ARGN})
    if (OPTION_NAME)
      set (${OPTION_NAME} "${ARG}")
      set (OPTION_NAME)
      break ()
    else ()
      if ("${ARG}" STREQUAL "GROUP")
        set (OPTION_NAME "GROUP")
      endif ()
    endif ()
  endforeach ()

  cpack_add_component (${COMPNAME} ${ARGN})

  add_custom_target (
    install_${COMPNAME}
    COMMAND "${CMAKE_COMMAND}" -DCOMPONENT=${COMPNAME}
            -P "${PROJECT_BINARY_DIR}/cmake_install.cmake"
  )

  if (GROUP)
    add_dependencies (install_${GROUP} install_${COMPNAME})
  endif ()
endfunction ()

# ****************************************************************************
#! @brief Add pre-configured install type.
#!
#! @sa CPack.cmake
#! @sa cpack_add_install_type ()
#!
#! @param [in] ARGN Arguments for cpack_add_install_type().
#!
#! @returns Adds a pre-configured installation type.

function (basis_add_install_type)
  cpack_add_install_type (${ARGN})
endfunction ()

# ****************************************************************************
#! @brief Configure installation-time downloads of selected components.
#!
#! @sa CPack.cmake
#! @sa cpack_configure_downloads()
#!
#! @param [in] ARGN Arguments for cpack_configure_downloads().
#!
#! @returns Nothing.

function (basis_configure_downloads)
  cpack_configure_downloads (${ARGN})
endfunction ()

#! @}

# ----------------------------------------------------------------------------
# include components definition
# ----------------------------------------------------------------------------

if (EXISTS "${PROJECT_CONFIG_DIR}/Components.cmake.in")
  configure_file ("${PROJECT_CONFIG_DIR}/Components.cmake.in"
                  "${PROJECT_BINARY_DIR}/Components.cmake" @ONLY)
  include ("${PROJECT_BINARY_DIR}/Components.cmake")
elseif (EXISTS "${PROJECT_CONFIG_DIR}/Components.cmake")
  include ("${PROJECT_CONFIG_DIR}/Components.cmake")
endif ()

