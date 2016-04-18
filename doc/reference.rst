.. raw:: latex

  \pagebreak

.. _Reference:

=========
Reference
=========

Basic Tools
===========

In order to ease certain tasks, the BASIS package also includes the following command-line tools:

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{3cm}|p{12.5cm}|

=================  ===============================================================================
|basisproject|     Creates a new project or modifies an existing one in order to add
                   or remove certain components of the template or to upgrade to a newer template.
|basistest|        Implements automated software tests.
*doxyfilter*       Doxygen filter for all supported languages.
=================  ===============================================================================


CMake Modules
=============

The CMake modules and corresponding auxiliary files are used by  any BASIS project
for the configuration of the CMake-based build system, so that many setup steps
can be automated. These commands often replace the standard CMake commands.
For example, the CMake function :apidoc:`basis_add_executable()` replaces CMake's 
`add_executable() <http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable>`_
command.

The main CMake modules are:

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{3cm}|p{12.5cm}|

============================  ===============================================================
:apidoc:`BasisProject.cmake`  File in every BASIS project defining basic project information.
:apidoc:`BasisTools.cmake`    Defines CMake functions, macros, and variables.
:apidoc:`BasisTest.cmake`     Replacement for the CTest.cmake module of CMake.
:apidoc:`BasisPack.cmake`     Replacement for the CPack.cmake module of CMake.
============================  ===============================================================


Utilities
=========

For each supported programming language, BASIS provides a library of
`utility functions <https://cmake-basis.github.io/apidoc/latest/group__BasisUtilities.html>`__. 
Some of these utilities are project independent and thus built and installed as
part of the CMake BASIS package itself. Other utility implementations are project dependent.
Therefore, the BASIS installation contains only template files which are customized and built
during the configuration and build, respectively, of the particular BASIS project. This customization
is done by the functions implemented by the :apidoc:`UtilitiesTools.cmake` module which is
included and utilized by the main :apidoc:`BasisTools.cmake` module.

The BASIS utilities address the following aspects of the software implementation standard:

- :doc:`standard/cmdline`
- :doc:`standard/execution`
- *Software Testing* (TODO)

.. Old links for reference:
    [1]:  http://www.cbica.upenn.edu/sbia/
    [2]:  http://www.cbica.upenn.edu/sbia/software/license.html
    [3]:  http://www.cbica.upenn.edu/sbia/software/basis/help.html
    [4]:  http://www.cbica.upenn.edu/sbia/software/basis/standard/template.html
    [5]:  http://www.cbica.upenn.edu/sbia/software/basis/standard/fhs.html
    [6]:  http://www.cbica.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisModules.html
    [7]:  http://www.cbica.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisUtilities.html
    [8]:  http://www.cbica.upenn.edu/sbia/software/basis/standard/implementation.html
    [9]:  http://www.kitware.com/products/html/BuildingExternalProjectsWithCMake2.8.html
    [10]: http://www.vtk.org/Wiki/ITK/Release_4/Modularization
    [11]: http://www.cbica.upenn.edu/sbia/software/basis/howto/create-and-modify-project.html
    [12]: http://www.cbica.upenn.edu/sbia/software/basis/apidoc/latest/group__CMakeAPI.html#gab7b7600c0ab4197db811f810a04670be
    [13]: http://www.cmake.org/cmake/help/cmake-2-8-docs.html#command:add_executable
    [14]: http://www.cbica.upenn.edu/sbia/software/basis/apidoc/latest/BasisTools_8cmake.html
    [15]: http://www.cbica.upenn.edu/sbia/software/basis/apidoc/latest/BasisTest_8cmake.html
    [16]: http://www.cbica.upenn.edu/sbia/software/basis/apidoc/latest/BasisPack_8cmake.html
    [17]: http://www.cbica.upenn.edu/sbia/software/basis/apidoc/latest/group__Tools.html
    [18]: http://www.cbica.upenn.edu/sbia/software/basis/howto/run-automated-tests.html
    [19]: http://www.cbica.upenn.edu/sbia/software/basis/apidoc/latest/UtilitiesTools_8cmake.html
    [20]: http://www.cbica.upenn.edu/sbia/software/basis/standard/cmdline.html
    [21]: http://www.cbica.upenn.edu/sbia/software/basis/standard/execution.html
    [22]: https://github.com/cmake-basis/BASIS/
    [23]: http://sphinx.pocoo.org/

Project Layout
==============

A brief summary of the common project layout required by all projects that follow BASIS is given below.
Project templates are supplied by the BASIS package to make it easy for projects to follow
this :ref:`BASIS Project Directory Layout <SourceCodeTree>` and standard :doc:`/standard/template`.
How to create and use such template is explained in the :doc:`howto/use-and-customize-templates` guide.
The |basisproject| command-line tool further automates and simplifies the creation of new projects
based on a project template.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{4cm}|p{11.5cm}|

==============================  =====================================================================
**config/**                     Package configuration files.
**data/**                       Data files required by the software.
**doc/**                        Documentation source files.
**example/**                    Example files for users to try out the software.
**include/**                    Header files of the public API of libraries.
**lib/**                        Module files for scripting languages.
**modules/**                    Project :doc:`Modules <standard/modules>` (i.e., subprojects).
**src/**                        Source code files.
**test/**                       Implementations of unit and regression tests.
AUTHORS (.txt|.md)              A list of the people who contributed to this sofware.
:apidoc:`BasisProject.cmake`    Calls :apidoc:`basis_project()` to set basic project information.
CMakeLists.txt                  Root CMake configuration file.
COPYING (.txt|.md)              The copyright and license notices.
INSTALL (.txt|.md)              Build and installation instructions.
README (.txt|.md)               Basic summary and references to the documentation.
==============================  =====================================================================

.. seealso:: The :doc:`/standard/template` for a complete list of required and other standard project files.
             The :ref:`CMake BASIS Package <BasisPackageContent>` itself also serves as an example of a 
             project following this standard layout.

.. note:: Not all of the named subdirectories must exist in every project.

.. |basisproject|  replace:: :doc:`basisproject <howto/create-and-modify-project>`
.. |basistest|     replace:: :doc:`basistest    <howto/run-automated-tests>`

