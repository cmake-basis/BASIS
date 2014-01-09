.. _APIDocumentation:

=========
Reference
=========

.. toctree::
    :maxdepth: 2

    apidoc/modules
    apidoc/namespaces
    apidoc/classlist
    apidoc/files


Package Overview
================

Project Template
----------------

The :doc:`standard/template` is supplied to make it easy to generate a project 
that follows the BASIS standards, as explained in :doc:`howto/use-and-customize-templates`.

The **basisproject** command-line tool automates and simplifies the 
instantiation of the project template for new projects as explained 
in :doc:`howto/create-and-modify-project`.

CMake Modules
-------------

The CMake modules and corresponding auxiliary files are used by 
any BASIS project for the configuration of the CMake-based build
system, so that many setup steps can be automated. These commands 
often replace the versions provided by CMake, such as
:apidoc:`basis_add_executable()`, which replaces CMake's 
`add_executable() <http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable>`_
command.

The main CMake modules are:

- :apidoc:`BasisProject.cmake`  File in every BASIS project defining basic project information.
- :apidoc:`BasisTools.cmake`    Defines CMake functions, macros, and variables.
- :apidoc:`BasisTest.cmake`     Replacement for the CTest.cmake module of CMake.
- :apidoc:`BasisPack.cmake`     Replacement for the CPack.cmake module of CMake.


Tools
-----

In order to ease certain tasks, the BASIS package also includes the following
[command-line tools][17]:

- :doc:`basisproject<howto/create-and-modify-project>`  Creates a new project or modifies an existing project in order to add or remove certain components of the project template or to upgrade to a newer BASIS template.
- :doc:`basistest<howto/run-automated-tests>`           Implements automated software tests.
- **doxyfilter:**                                       Doxygen filters for the supported programming languages.


Utilities
---------

For each supported programming language, BASIS provides a library of `BASIS Utilities`_. 
Some of these utility functions are project independent and thus
built and installed as part of BASIS itself. Other utility implementations
are project dependent. Therefore, the BASIS package provides only template
files which are customized and built during the configuration and build,
respectively, of the particular BASIS project. This customization is done
by the functions implemented by the :apidoc:`UtilitiesTools.cmake` module which is
included and utilized by the main :apidoc:`BasisTools.cmake` module.

The BASIS utilities address the following aspects of the software
implementation :doc:`standard`:

- :doc:`standard/cmdline`
- :doc:`standard/execution`
- **Software Testing:**       Standard on how to implement software tests.


Source Package
--------------

- :apidoc:`BasisProject.cmake:`        Calls :apidoc:`basis_project()` to set basic project information, such as the name and dependencies.
- **CMakeLists.txt:**                  Root CMake configuration file.
- **config/:**                         Package configuration files.
- **data/template/<version>/**         Project template(s).
- **doc/:**                            Documentation source files of BASIS.
- **include/:**                        Public header files.
- **src/:**                            Source code files.
- **src/cmake/:**                      CMake implementations and corresponding auxiliary files.
- **src/geshi/:**                      A language file written in PHP for use with GeSHi,
                                       a source code highlighting extension for MediaWiki.
- **src/sphinx/:**                     Themes and extensions for the `Sphinx <http://sphinx-doc.org>`_ documentation tool.
- **src/tools/:**                      Source code of command-line tools.
- **src/utilities/:**                  Source code of utility functions.
- **test/:**                           Tests of the implementations in src/.
- **AUTHORS:**                         A list of the people who contributed to this sofware.
- **COPYING:**                         The copyright and license notices.
- **INSTALL:**                         Build and installation instructions.
- **README:**                          Basic summary and references to the documentation.


.. _`Basis Utilities`: http://opensource.andreasschuh.com/cmake-basis/apidoc/latest/group__BasisUtilities.html

.. Old links for reference:
[1]:  http://www.rad.upenn.edu/sbia/
[2]:  http://www.rad.upenn.edu/sbia/software/license.html
[3]:  http://www.rad.upenn.edu/sbia/software/basis/help.html
[4]:  http://www.rad.upenn.edu/sbia/software/basis/standard/template.html
[5]:  http://www.rad.upenn.edu/sbia/software/basis/standard/fhs.html
[6]:  http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisModules.html
[7]:  http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisUtilities.html
[8]:  http://www.rad.upenn.edu/sbia/software/basis/standard/implementation.html
[9]:  http://www.kitware.com/products/html/BuildingExternalProjectsWithCMake2.8.html
[10]: http://www.vtk.org/Wiki/ITK/Release_4/Modularization
[11]: http://www.rad.upenn.edu/sbia/software/basis/howto/create-and-modify-project.html
[12]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__CMakeAPI.html#gab7b7600c0ab4197db811f810a04670be
[13]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable
[14]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/BasisTools_8cmake.html
[15]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/BasisTest_8cmake.html
[16]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/BasisPack_8cmake.html
[17]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__Tools.html
[18]: http://www.rad.upenn.edu/sbia/software/basis/howto/run-automated-tests.html
[19]: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/UtilitiesTools_8cmake.html
[20]: http://www.rad.upenn.edu/sbia/software/basis/standard/cmdline.html
[21]: http://www.rad.upenn.edu/sbia/software/basis/standard/execution.html
[22]: https://github.com/schuhschuh/cmake-basis/
[23]: http://sphinx.pocoo.org/


Older Versions
==============

* Tools                     |Tools v2.1|_            |Tools v2.0|_            |Tools v1.3|_            |Tools v1.2|_            |Tools v1.1|_            |Tools v1.0|_
* Modules                   |Modules v2.1|_          |Modules v2.0|_          |Modules v1.3|_          |Modules v1.2|_          |Modules v1.1|_          |Modules v1.0|_

  - Public CMake Functions  |CMake API v2.1|_        |CMake API v2.0|_        |CMake API v1.3|_        |CMake API v1.2|_        |CMake API v1.1|_        |CMake API v1.0|_
  - Find Package Modules    |Find Modules v2.1|_     |Find Modules v2.0|_     |Find Modules v1.3|_     |Find Modules v1.2|_     |Find Modules v1.1|_     |Find Modules v1.0|_
  - Settings                |Settings v2.1|_         |Settings v2.0|_         |Settings v1.3|_         |Settings v1.2|_         |Settings v1.1|_         |Settings v1.0|_
  - Package Configuration   |Config v2.1|_           |Config v2.0|_           |Config v1.3|_           |Config v1.2|_           |Config v1.1|_           |Config v1.0|_
  - Project Directories     |Directories v2.1|_      |Directories v2.0|_      |Directories v1.3|_      |Directories v1.2|_      |Directories v1.1|_      |Directories v1.0|_
  - Script Configuration    |ScriptConfig v2.1|_     |ScriptConfig v2.0|_     |ScriptConfig v1.3|_     |ScriptConfig v1.2|_     |ScriptConfig v1.1|_     |ScriptConfig v1.0|_

* Utilities                 |Utilities v2.1|_        |Utilities v2.0|_        |Utilities v1.3|_        |Utilities v1.2|_        |Utilities v1.1|_        |Utilities v1.0|_

  - C++ Utilities           |C++ Utilities v2.1|_    |C++ Utilities v2.0|_    |C++ Utilities v1.3|_    |C++ Utilities v1.2|_    |C++ Utilities v1.1|_    |C++ Utilities v1.0|_
  - Python Utilities        |Python Utilities v2.1|_ |Python Utilities v2.0|_ |Python Utilities v1.3|_ |Python Utilities v1.2|_ |Python Utilities v1.1|_ |Python Utilities v1.0|_
  - Perl Utilities          |Perl Utilities v2.1|_   |Perl Utilities v2.0|_   |Perl Utilities v1.3|_   |Perl Utilities v1.2|_   |Perl Utilities v1.1|_   |Perl Utilities v1.0|_
  - BASH Utilities          |BASH Utilities v2.1|_   |BASH Utilities v2.0|_   |BASH Utilities v1.3|_   |BASH Utilities v1.2|_   |BASH Utilities v1.1|_   |BASH Utilities v1.0|_

.. role:: apilink
    :class: apilink
    

.. Breathe doxygen index, currently dumps all classes on to this page, so it isn't quite what we want
.. .. doxygenindex::

.. |Tools v2.1|              replace:: :apilink:`v2.1`
.. |Modules v2.1|            replace:: :apilink:`v2.1`
.. |CMake API v2.1|          replace:: :apilink:`v2.1`
.. |Find Modules v2.1|       replace:: :apilink:`v2.1`
.. |Settings v2.1|           replace:: :apilink:`v2.1`
.. |Config v2.1|             replace:: :apilink:`v2.1`
.. |Directories v2.1|        replace:: :apilink:`v2.1`
.. |ScriptConfig v2.1|       replace:: :apilink:`v2.1`
.. |Utilities v2.1|          replace:: :apilink:`v2.1`
.. |C++ Utilities v2.1|      replace:: :apilink:`v2.1`
.. |Python Utilities v2.1|   replace:: :apilink:`v2.1`
.. |Perl Utilities v2.1|     replace:: :apilink:`v2.1`
.. |BASH Utilities v2.1|     replace:: :apilink:`v2.1`

.. _Tools v2.1:              http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__Tools.html
.. _Modules v2.1:            http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisModules.html
.. _CMake API v2.1:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__CMakeAPI.html
.. _Find Modules v2.1:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__CMakeFindModules.html
.. _Settings v2.1:           http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisSettings.html
.. _Config v2.1:             http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisConfig.html
.. _Directories v2.1:        http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisDirectories.html
.. _ScriptConfig v2.1:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisScriptConfig.html
.. _Utilities v2.1:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisUtilities.html
.. _C++ Utilities v2.1:      http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisCxxUtilities.html
.. _Python Utilities v2.1:   http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisPythonUtilities.html
.. _Perl Utilities v2.1:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisPerlUtilities.html
.. _BASH Utilities v2.1:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.1/group__BasisBASHUtilities.html


.. |Tools v2.0|              replace:: :apilink:`v2.0`
.. |Modules v2.0|            replace:: :apilink:`v2.0`
.. |CMake API v2.0|          replace:: :apilink:`v2.0`
.. |Find Modules v2.0|       replace:: :apilink:`v2.0`
.. |Settings v2.0|           replace:: :apilink:`v2.0`
.. |Config v2.0|             replace:: :apilink:`v2.0`
.. |Directories v2.0|        replace:: :apilink:`v2.0`
.. |ScriptConfig v2.0|       replace:: :apilink:`v2.0`
.. |Utilities v2.0|          replace:: :apilink:`v2.0`
.. |C++ Utilities v2.0|      replace:: :apilink:`v2.0`
.. |Python Utilities v2.0|   replace:: :apilink:`v2.0`
.. |Perl Utilities v2.0|     replace:: :apilink:`v2.0`
.. |BASH Utilities v2.0|     replace:: :apilink:`v2.0`

.. _Tools v2.0:              http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__Tools.html
.. _Modules v2.0:            http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisModules.html
.. _CMake API v2.0:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__CMakeAPI.html
.. _Find Modules v2.0:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__CMakeFindModules.html
.. _Settings v2.0:           http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisSettings.html
.. _Config v2.0:             http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisConfig.html
.. _Directories v2.0:        http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisDirectories.html
.. _ScriptConfig v2.0:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisScriptConfig.html
.. _Utilities v2.0:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisUtilities.html
.. _C++ Utilities v2.0:      http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisCxxUtilities.html
.. _Python Utilities v2.0:   http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisPythonUtilities.html
.. _Perl Utilities v2.0:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisPerlUtilities.html
.. _BASH Utilities v2.0:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v2.0/group__BasisBASHUtilities.html


.. |Tools v1.3|              replace:: :apilink:`v1.3`
.. |Modules v1.3|            replace:: :apilink:`v1.3`
.. |CMake API v1.3|          replace:: :apilink:`v1.3`
.. |Find Modules v1.3|       replace:: :apilink:`v1.3`
.. |Settings v1.3|           replace:: :apilink:`v1.3`
.. |Config v1.3|             replace:: :apilink:`v1.3`
.. |Directories v1.3|        replace:: :apilink:`v1.3`
.. |ScriptConfig v1.3|       replace:: :apilink:`v1.3`
.. |Utilities v1.3|          replace:: :apilink:`v1.3`
.. |C++ Utilities v1.3|      replace:: :apilink:`v1.3`
.. |Python Utilities v1.3|   replace:: :apilink:`v1.3`
.. |Perl Utilities v1.3|     replace:: :apilink:`v1.3`
.. |BASH Utilities v1.3|     replace:: :apilink:`v1.3`

.. _Tools v1.3:              http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__Tools.html
.. _Modules v1.3:            http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisModules.html
.. _CMake API v1.3:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__CMakeAPI.html
.. _Find Modules v1.3:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__CMakeFindModules.html
.. _Settings v1.3:           http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisSettings.html
.. _Config v1.3:             http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisConfig.html
.. _Directories v1.3:        http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisDirectories.html
.. _ScriptConfig v1.3:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisScriptConfig.html
.. _Utilities v1.3:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisUtilities.html
.. _C++ Utilities v1.3:      http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisCxxUtilities.html
.. _Python Utilities v1.3:   http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisPythonUtilities.html
.. _Perl Utilities v1.3:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisPerlUtilities.html
.. _BASH Utilities v1.3:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__BasisBASHUtilities.html


.. |Tools v1.2|              replace:: :apilink:`v1.2`
.. |Modules v1.2|            replace:: :apilink:`v1.2`
.. |CMake API v1.2|          replace:: :apilink:`v1.2`
.. |Find Modules v1.2|       replace:: :apilink:`v1.2`
.. |Settings v1.2|           replace:: :apilink:`v1.2`
.. |Config v1.2|             replace:: :apilink:`v1.2`
.. |Directories v1.2|        replace:: :apilink:`v1.2`
.. |ScriptConfig v1.2|       replace:: :apilink:`v1.2`
.. |Utilities v1.2|          replace:: :apilink:`v1.2`
.. |C++ Utilities v1.2|      replace:: :apilink:`v1.2`
.. |Python Utilities v1.2|   replace:: :apilink:`v1.2`
.. |Perl Utilities v1.2|     replace:: :apilink:`v1.2`
.. |BASH Utilities v1.2|     replace:: :apilink:`v1.2`

.. _Tools v1.2:              http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__Tools.html
.. _Modules v1.2:            http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisModules.html
.. _CMake API v1.2:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__CMakeAPI.html
.. _Find Modules v1.2:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__CMakeFindModules.html
.. _Settings v1.2:           http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisSettings.html
.. _Config v1.2:             http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisConfig.html
.. _Directories v1.2:        http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisDirectories.html
.. _ScriptConfig v1.2:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisScriptConfig.html
.. _Utilities v1.2:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisUtilities.html
.. _C++ Utilities v1.2:      http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisCxxUtilities.html
.. _Python Utilities v1.2:   http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisPythonUtilities.html
.. _Perl Utilities v1.2:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisPerlUtilities.html
.. _BASH Utilities v1.2:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.2/group__BasisBASHUtilities.html


.. |Tools v1.1|              replace:: :apilink:`v1.1`
.. |Modules v1.1|            replace:: :apilink:`v1.1`
.. |CMake API v1.1|          replace:: :apilink:`v1.1`
.. |Find Modules v1.1|       replace:: :apilink:`v1.1`
.. |Settings v1.1|           replace:: :apilink:`v1.1`
.. |Config v1.1|             replace:: :apilink:`v1.1`
.. |Directories v1.1|        replace:: :apilink:`v1.1`
.. |ScriptConfig v1.1|       replace:: :apilink:`v1.1`
.. |Utilities v1.1|          replace:: :apilink:`v1.1`
.. |C++ Utilities v1.1|      replace:: :apilink:`v1.1`
.. |Python Utilities v1.1|   replace:: :apilink:`v1.1`
.. |Perl Utilities v1.1|     replace:: :apilink:`v1.1`
.. |BASH Utilities v1.1|     replace:: :apilink:`v1.1`

.. _Tools v1.1:              http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__Tools.html
.. _Modules v1.1:            http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisModules.html
.. _CMake API v1.1:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__CMakeAPI.html
.. _Find Modules v1.1:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__CMakeFindModules.html
.. _Settings v1.1:           http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisSettings.html
.. _Config v1.1:             http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisConfig.html
.. _Directories v1.1:        http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisDirectories.html
.. _ScriptConfig v1.1:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisScriptConfig.html
.. _Utilities v1.1:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisUtilities.html
.. _C++ Utilities v1.1:      http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisCxxUtilities.html
.. _Python Utilities v1.1:   http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisPythonUtilities.html
.. _Perl Utilities v1.1:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisPerlUtilities.html
.. _BASH Utilities v1.1:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.1/group__BasisBASHUtilities.html


.. |Tools v1.0|              replace:: :apilink:`v1.0`
.. |Modules v1.0|            replace:: :apilink:`v1.0`
.. |CMake API v1.0|          replace:: :apilink:`v1.0`
.. |Find Modules v1.0|       replace:: :apilink:`v1.0`
.. |Settings v1.0|           replace:: :apilink:`v1.0`
.. |Config v1.0|             replace:: :apilink:`v1.0`
.. |Directories v1.0|        replace:: :apilink:`v1.0`
.. |ScriptConfig v1.0|       replace:: :apilink:`v1.0`
.. |Utilities v1.0|          replace:: :apilink:`v1.0`
.. |C++ Utilities v1.0|      replace:: :apilink:`v1.0`
.. |Python Utilities v1.0|   replace:: :apilink:`v1.0`
.. |Perl Utilities v1.0|     replace:: :apilink:`v1.0`
.. |BASH Utilities v1.0|     replace:: :apilink:`v1.0`

.. _Tools v1.0:              http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__Tools.html
.. _Modules v1.0:            http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisModules.html
.. _CMake API v1.0:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__CMakeAPI.html
.. _Find Modules v1.0:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__CMakeFindModules.html
.. _Settings v1.0:           http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisSettings.html
.. _Config v1.0:             http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisConfig.html
.. _Directories v1.0:        http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisDirectories.html
.. _ScriptConfig v1.0:       http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisScriptConfig.html
.. _Utilities v1.0:          http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisUtilities.html
.. _C++ Utilities v1.0:      http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisCxxUtilities.html
.. _Python Utilities v1.0:   http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisPythonUtilities.html
.. _Perl Utilities v1.0:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisPerlUtilities.html
.. _BASH Utilities v1.0:     http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.0/group__BasisBASHUtilities.html
