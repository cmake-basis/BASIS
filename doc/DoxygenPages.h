/*
 * @file  DoxygenPages.h
 * @brief Documentation of Doxygen modules.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.
 * See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 */

// ===========================================================================
// groups
// ===========================================================================

// ---------------------------------------------------------------------------
// CMake Modules
// ---------------------------------------------------------------------------

/*!
 * @defgroup CMakeModules CMake Modules
 * @brief    CMake Modules.
 *
 *
 * The BASIS package in particular provides CMake implementations which
 * standardize the build system and support the developer of a project in
 * setting up a software development project.
 */

/*!
 * @defgroup CMakeAPI Public CMake Interface
 * @brief    Public interface of CMake modules.
 *
 * The variables, functions, and macros listed here are intended to be used
 * by the developer of a software development project based on BASIS in their
 * project specific CMake implementation and the CMakeLists.txt files.
 *
 * @ingroup CMakeModules
 */

/*!
 * @defgroup CMakeFindModules Find Package Modules
 * @brief    CMake Find modules used by find_package() command.
 *
 * The BASIS package provides CMake Find module implementations for third-party
 * packages which are commonly used at SBIA but do not provide a CMake
 * package configuration file (\<Package\>Config.cmake or \<package\>-config.cmake)
 * such that CMake cannot find the package by default in config-mode.
 *
 * @ingroup CMakeModules
 */

/*!
 * @defgroup CMakeTools Auxiliary CMake Modules
 * @brief    Auxiliary CMake modules included and used by the main modules.
 *
 * @ingroup CMakeModules
 */

/*!
 * @defgroup CMakeUtilities CMake Utilities
 * @brief    Utility implementations used by the CMake modules.
 *
 * @ingroup CMakeModules
 */

/*!
 * @defgroup CMakeHelpers  Non-CMake Implementations and Input Files
 * @brief    Auxiliary non-CMake implementations and input files used by the CMake modules.
 *
 *
 *
 * @ingroup CMakeModules
 */

// ---------------------------------------------------------------------------
// C++ Utilities
// ---------------------------------------------------------------------------

/*!
 * @defgroup CppUtilities C++ Utilities
 * @brief    Auxiliary implementations for use in C++ implementations.
 */
