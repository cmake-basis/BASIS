
  Section of Biomedical Image Analysis
  Department of Radiology
  University of Pennsylvania
  3600 Market Street, Suite 380
  Philadelphia, PA 19104

  Web:   https://www.rad.upenn.edu/sbia/
  Email: sbia-software at uphs.upenn.edu

  Copyright (c) 2011 University of Pennsylvania. All rights reserved.
  See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.



INTRODUCTION
============

  The Build system And Software Implementation Standard (BASIS) software package
  not only provides a project template which standardizes the project directory
  structure, it also accompanies this template with CMake implementations.
  These CMake implementations ease and standardize the build, testing,
  packaging, and installation of software packages developed at SBIA.
  Besides the software components, the documentation of BASIS defines the
  lab standard for various aspects of a software development project.
  Moreover, fundamental utility source files and libraries written both at
  SBIA and external sites are integrated as components of BASIS.

  Every SBIA software project which was started after the introduction of BASIS
  in June 2011 is required to built on top of BASIS, i.e., to instantiate the
  project template and utilize the provided CMake implementations. An extensive
  documentation is provided with BASIS to ease this task as much as possible.

  The BASIS package, when build and installed once globally on a target system
  on which other SBIA software is to be built, is used for the build of these
  dependent SBIA projects. Alternatively, if the package is not found, each SBIA
  project which is built on top of BASIS and implements the super-build feature,
  retrieves and builds a local copy using CMake's ExternalProject module
  (http://www.kitware.com/products/html/BuildingExternalProjectsWithCMake2.8.html).

  Another feature of BASIS is, that it not only eases the developement and
  maintenance of separatly managed software projects, it also enables the fusion
  of these more or less independently developed software packages into so-called
  superprojects following the super-build methodology which more recently gained
  more and more attraction on the CMake community. In this context, the separately
  managed software packages are considered components of the superproject.



PACKAGE OVERVIEW
================

  CMake Modules
  -------------

  The CMake modules and corresponding auxiliary files are not only used by the
  BASIS package itself, but also any SBIA project which follows BASIS for the
  configuration of the CMake-based build system. These CMake modules in
  particular define many functions which are used as replacement of CMake's
  built-in functions. For example, the function basis_add_executable () is used
  by SBIA projects as replacement for CMake's add_executable () command.
  The SBIA CMake functions are convenient to use, extend the functionality of
  CMake's built-in functions and enable BASIS to impose its standard on the
  configured build systems.


  Project Template
  ----------------

  Every SBIA project that wants to follow BASIS has to be derived from the BASIS
  Project Template. For convenience, a project creation script is provided which
  automates the instantiation of the template for new projects.

