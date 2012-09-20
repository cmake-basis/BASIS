
**Section of Biomedical Image Analysis**  
Department of Radiology  
University of Pennsylvania  
3600 Market Street, Suite 380  
Philadelphia, PA 19104  

**Web:**   [http://www.rad.upenn.edu/sbia/][1]  
**Email:** sbia-software at uphs.upenn.edu

Copyright (c) 2011, 2012, University of Pennsylvania. All rights reserved.  
See [http://www.rad.upenn.edu/sbia/software/license.html][2] or **COPYING** file.



INTRODUCTION
============

The **Build system And Software Implementation Standard (BASIS)** software
package documents and implements the lab's standard for project organization,
software build, and software implementation and documentation. The BASIS
project was started in February 2011. The initial idea was only to provide a
project template based on CMake which would standardize the project directory
structure as well as the software build. Besides, this project template
would allow the developers to concentrate on the actual software rather than
on deciding upon the directory structure, the directory names, and the basic
CMake configuration. To provide an even more comprehensive basis for the
software development at SBIA, the BASIS project goes, however, two steps
further.
 
In first place, BASIS has to be considered as a standard regarding the software
development at SBIA which is documented as part of the [Software Manual][3].
Based on this standard, a [project template][4] is provided which implements
the [Filesystem Hierarchy Standard][5]. This template is further accompanied by
[CMake modules][6] which not only follow the Filesystem Hierarchy Standard,
but also implement the build system standard as well as the standard on testing
and packaging software developed at SBIA.

The BASIS package moreover provides basic [utility functions][7] for each
supported programming language which implement certain aspects of the [software
implementation standard][8] such as, for example, the calling conventions on
how to execute subprocesses and the parsing of command-line arguments. Where
possible, these utility implementations were adopted from other open source
software projects and integrated with BASIS. For a more detailed overview of
the BASIS package, see sections **COMPONENTS** and **PACKAGE OVERVIEW**.

Every SBIA software project which was started after the first release of BASIS
in November 2011 is required to built on top of BASIS, i.e., to instantiate the
project template, utilize the provided CMake implementations and follow the
software implementation standard. An extensive documentation is provided with
BASIS to ease this task as much as possible. See section **DOCUMENTATION** for
a summary of the available documentation.

The BASIS package, when built and installed once on a target system on which
other SBIA software is to be built, is used for the build of these dependent
SBIA projects. Alternatively, if the package is not found, each SBIA project
which is built on top of BASIS and implements the super-build feature,
retrieves and builds a local copy using CMake's [ExternalProject.cmake][9]
module This super-build methodology, which gains more and more attraction in
the CMake community, is further utilized by BASIS to not only ease the
development and maintenance of separately managed software projects, but also
enable the fusion of these more or less independently developed software
packages into so-called superprojects. In this context, the separately managed
software packages are considered components of the superproject.
*TODO: The super-build methodology is not yet implemented as part of BASIS!*

Besides the super-build of BASIS projects, BASIS provides an implementation
of a tighter coupling of software components. Here, the top-level project
(i.e., the superproject) contains other BASIS projects as modules, and these
modules define the dependencies to other modules of the project. When the
superproject is configured, a subset of these modules can be selected and only
these will be build and installed. This type of modularization closely follows
the [modularization approach of the ITK 4 project][10].



COMPONENTS
==========

Project Template
----------------

Every project that wants to follow BASIS has to be derived from the [Software
Project Template][4]. For convenience, the command-line tool **basisproject**
for the creation of a new project and the modification of such created BASIS
project is provided. This tool automates and thus simplifies the instantiation
of the project template for new projects. See [this how-to guide][11] for details
on how to use the **basisproject** command-line tool to create or modify a project.


CMake Modules
-------------

The CMake modules and corresponding auxiliary files are not only used by the
BASIS package itself, but also any SBIA project which follows BASIS for the
configuration of the CMake-based build system. These CMake modules in
particular define many functions which are used as replacement of CMake's
built-in functions. For example, the function [basis\_add\_executable()][12]
is used by BASIS projects as replacement for CMake's [add\_executable()][13]
command. The BASIS CMake functions are convenient to use, extend the
functionality of CMake's built-in functions, and enable BASIS to impose its
standard on the configured build system.

The main CMake modules are:

- **[BasisTools.cmake][14]:**   Defines CMake functions, macros, and variables.
- **[BasisTest.cmake][15]:**    Replacement for the CTest.cmake module of CMake.
- **[BasisPack.cmake][16]:**    Replacement for the CPack.cmake module of CMake.

A comprehensive [documentation of these modules][6] and the functions and macros
defined by them is available as part of the reference documentation.


Tools
-----

In order to ease certain tasks, the BASIS package also includes the following
[command-line tools][17]:

- **basisproject:**   Creates a new project or modifies an already previously
                      created project in order to add or remove certain components
                      of the project template or to upgrade to a newer BASIS template.
                      See [this how-to guide][11] for more information.
- **basistest:**      Implements automated software tests.
                      See [this how-to guide][18] on how to setup automated software
                      test using these command-line tools.
- **doxyfilter:**     Doxygen filters for the supported programming languages.


Utilities
---------

For each supported programming language, BASIS provides a library of [utility
functions][7]. Some of these utility functions are project independent and thus
built and installed as part of BASIS itself. Other utility implementations
are project dependent. Therefore, the BASIS package provides only template
files which are customized and built during the configuration and build,
respectively, of the particular BASIS project. This customization is done
by the functions implemented by the [UtilitiesTools.cmake][19] module which is
included and utilized by the main BasisTools.cmake module.

The BASIS utilities address the following aspects of the [software
implementation standard][8]:

- **Command-line Parsing:**   Standard on [how to parse command-line arguments][20].
- **Calling Conventions:**    Standard on [how to execute subprocesses][21].
- **Software Testing:**       Standard on how to implement software tests.



PACKAGE OVERVIEW
================

Source Package
--------------

- **BasisProject.cmake:**              Meta-data used by BASIS to configure the project.
- **CMakeLists.txt:**                  Root CMake configuration file.
- **config/:**                         Package configuration files.
- **data/template-&lt;version&gt;/**   Project template(s).
- **doc/:**                            Documentation source files of BASIS.
- **include/:**                        Public header files.
- **src/:**                            Source code files.
- **src/cmake/:**                      CMake implementations and corresponding auxiliary files.
- **src/geshi/:**                      A language file written in PHP for the use with GeSHi,
                                       a source code highlighting extension for MediaWiki.
- **src/sphinx/:**                     Themes and extensions for the [Sphinx][15] documentation tool.
- **src/tools/:**                      Source code of command-line tools.
- **src/utilities/:**                  Source code of utility functions.
- **test/:**                           Tests of the implementations in src/.
- **AUTHORS:**                         A list of the people who contributed to this sofware.
- **COPYING:**                         The copyright and license notices.
- **INSTALL:**                         Build and installation instructions.
- **README:**                          This readme file.


Binary Package
--------------

Please refer to the **INSTALL** file for details on where the built executables
and libraries, the auxiliary data, and the documentation files are installed.



LICENSING
=========

See [http://www.rad.upenn.edu/sbia/software/license.html][2] or **COPYING** file.



INSTALLATION
============

See build and installation instructions given in the **INSTALL** file.



DOCUMENTATION
=============

The PowerPoint 2007 presentation named **BASIS Tutorial - 01 Introduction.pptx**
gives a more detailed and in parts visual introduction of the BASIS project.
It can be found in the doc/tutorials/ directory of the BASIS package.
Further tutorials can be found here as well.

See the [BASIS Web Site][22] for details on the build system and implementation
standard. How-to guides found on this page further help to comply with BASIS.

The API documentation [here][6], on the other side, is a great reference of the
CMake implementations, whereas a reference of the utility functions
available for the different supported programming languages can be found on
[this page][7].



[1]:  http://www.rad.upenn.edu/sbia/
[2]:  http://www.rad.upenn.edu/sbia/software/license.html
[3]:  http://www.rad.upenn.edu/sbia/software/basis/help.html
[4]:  http://www.rad.upenn.edu/sbia/software/basis/standard/template.html
[5]:  http://www.rad.upenn.edu/sbia/software/basis/standard/fhs.html
[6]:  http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisModules.html
[7]:  http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisUtilities.html
[8]:  http://www.rad.upenn.edu/sbia/software/basis/standard/implementation.html
[9]:  http://www.kitware.com/products/html/BuildingExternalProjectsWithCMake2.8.html
[10]: http://www.vtk.org/Wiki/ITK/Release_4/Modularization
[11]: http://www.rad.upenn.edu/sbia/software/basis/howto/create-and-modify-project.html
[12]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__CMakeAPI.html#gab7b7600c0ab4197db811f810a04670be
[13]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable
[14]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/BasisTools_8cmake.html
[15]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/BasisTest_8cmake.html
[16]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/BasisPack_8cmake.html
[17]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__Tools.html
[18]: http://www.rad.upenn.edu/sbia/software/basis/howto/run-automated-tests.html
[19]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/UtilitiesTools_8cmake.html
[20]: http://www.rad.upenn.edu/sbia/software/basis/standard/cmdline.html
[21]: http://www.rad.upenn.edu/sbia/software/basis/standard/execution.html
[22]: http://www.rad.upenn.edu/sbia/software/basis/
[23]: http://sphinx.pocoo.org/
