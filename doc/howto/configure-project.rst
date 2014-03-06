.. meta::
    :description: How to configure a software project based on BASIS,
                  a build system and software implementation standard.

===================
Configure a Project
===================

This guide demonstrates some of the more advanced details,
tricks, and tools to modify and configure your project.

.. seealso:: The guide on how to :doc:`/howto/create-and-modify-project` and the
             :doc:`/standard/template` which defines the typical project layout.

CMake Configuration
===================

.. _ConfigureBasisProject:

:apidoc:`BasisProject.cmake`
----------------------------

The key file for any project is the :apidoc:`BasisProject.cmake` file which
can be found in the root directory of each project or module if the project
is a subproject of another. It sets basic information about a project such as
its name, version, and dependencies. Therefore it calls the :apidoc:`basis_project()`
command which provides several parameters for setting these project attributes.


Dependencies
~~~~~~~~~~~~

Dependencies specified as arguments of the :apidoc:`basis_project()` command
also support  more advanced selection of specific version and package components.
If some components of an external package are optional while others are required,
multiple dependency declarations to the same package can be used which will
only differ in the list of package components.

The syntax of the dependency declarations is as follows:

.. code-block:: cmake
    
    basis_project(
      # [...]
      DEPENDS
        <package_name>[-<version>][{<componen1>,<component2>,...}]
      # [...]
    )

.. note:: The components can be separated by whitespace characters such as
          spaces, tabs, and newlines. In this case, the dependency declaration
          has to be enclosed in double quotes such that it is treated by
          CMake as a single argument of the ``basis_project`` command.

In the example below, ``ITK-4{IOKernel}`` therefore is a dependency on the
external ``ITK`` package, in particular version 4 or above and only the ``IOKernel``
component is required. You can also be more specific regarding the version
using a dependency declaration such as ``ITK-4.2`` or ``ITK-3.18.0``. Whether
or not an external dependency meets the version requirements is determined
by CMake's find_package_ command. See the CMake documentation of this command
for more details, where in particular the ``VERSION`` and ``COMPONENTS`` options
directly relate to the respective parts of the BASIS dependency declaration.

.. code-block:: cmake

    basis_project(
      # [...]
      DEPENDS
        ITK-4{IOKernel}
      OPTIONAL_DEPENDS
        PythonInterp
        JythonInterp
        Perl
        MATLAB{matlab}
        BASH
        Doxygen
        Sphinx{build}
        #<optional-dependency>
      TEST_DEPENDS
        #<test-dependency>
      OPTIONAL_TEST_DEPENDS
        MATLAB{mex}
        MATLAB{mcc}
        #<optional-test-dependency>
      # [...]
    )
 
Note that in case of a modularized project, the top-level project cannot
have one of its own modules as dependency. The modules themselves, however,
can and usually will depend on other modules of the same top-level project.
If the module should also be able to exist as a standalone project or as
part of other top-level projects, the dependency declaration should refer to
another module as ``PackageName{OtherModule}`` instead of just ``OtherModule``,
where ``PackageName`` is the name of the top-level project which provides
the other module, i.e., which defines the root namespace that the modules
belong to.


:apidoc:`Settings.cmake`
------------------------

Besides the ``BasisProject.cmake`` file, the ``config/Settings.cmake`` file
contains the second most important project build configuration settings of
a BASIS project. It is not required, but will be present in many projects.
It is included by the root ``CMakeLists.txt`` of a typical BASIS project
after the project meta-data is defined, information about the project modules
has been collected, and the default BASIS settings were set. It is used by
projects to override these default settings and to add additional project
specific CMake options to the cache, e.g., using CMake's option_ command.
Another use case of this file is to set global project build settings such
as common include directories or library paths which have not automatically
been set by BASIS. In particular if an external dependency's CMake configuration
or ``FindPackage.cmake`` module set some non-standard CMake variables,
a project can make use of these in the ``config/Settings.cmake`` file.
An example of such settings are compiler and linker flags. If you want
to add certain compiler flags or override the defaults, then do so
in the ``config/Settings.cmake`` file. It should be noted that
some BASIS settings cannot be overridden using this file if the BASIS
standard does not allow so. But most settings can be overridden using this file.

For example if you want to enable all compiler warnings for your project
and consider them moreover as errors, you would add the following to the
``config/Settings.cmake`` file:

.. code-block:: cmake

  if(CMAKE_COMPILER_IS_GNU_CXX)
    add_definitions(-Wall -Werror)
  endif()

.. _option: http://www.cmake.org/cmake/help/v2.8.12/cmake.html#command:option


:apidoc:`Depends.cmake`
-----------------------

This build configuration file is for advanced use only in cases where the
generic resolution of external dependencies used by BASIS fails due to
an incompatible external package. In other words, if you need to call
:apidoc:`basis_find_package` or even CMake's find_package_ directly to
find a particular external dependency, add the needed commands to the
:apidoc:`Depends.cmake` file. One use case would be if a package or the corresponding
``FindPackage.cmake`` module, respectively, requires certain
CMake variables to be set prior to the ``find_package`` call. In such
case, set these variables in ``config/Depends.cmake`` and specify the
dependency as usual in the ``BasisProject.cmake`` file. If this approach
is still not feasible for the particular package, add any code needed to
find the dependency to ``config/Depends.cmake`` and remove the dependency
declaration from ``BasisProject.cmake`` such that BASIS is not itself
attempting to resolve the dependency automatically. This should only
be needed and used in rare cases where the external dependency is not
following the usual CMake guidelines. Often such situation is better
resolved by providing a suitable ``FindPackage.cmake`` module for the
external dependency. This module can then be added to BASIS,
or put in the ``config/`` directory of the project.
If you have a CMake module to contribute to BASIS,
we encourage you to `open an issue <https://github.com/schuhschuh/cmake-basis/issues>`__
with a patch attached or to send a pull request on
`GitHub <https://github.com/schuhschuh/cmake-basis>`__.


:apidoc:`Config.cmake.in <BASISConfig.cmake>`
---------------------------------------------

The ``Config.cmake.in`` file is the template for the so-called CMake package
configuration file which is generated by BASIS at the end of the build
system configuration. The generated file will be named ``PackageConfig.cmake``,
where ``Package`` is the name of the top-level project, and contain
information about the installation, the exported library targets, and
possibly compiler options that were used to build the project. CMake's
find_package_ command in particular searches for this file when looking
for the package named ``Package`` and includes it to import the build
and installation settings. Besides the typical attributes of the build
and installation which are written automatically by BASIS to the
``PackageConfig.cmake`` file, additional custom project settings
can be added using the ``config/Config.cmake.in`` file, along with a
file named ``config/ConfigSettings.cmake`` which sets the CMake
variables that are used in the ``Config.cmake.in`` template.


:apidoc:`Version.cmake.in <BASISConfigVersion.cmake>`
-----------------------------------------------------

This file is the template for the ``PackageConfigVersion.cmake`` file which
is examined by CMake's find_package_ command in order to determine
whether the found package with the package configuration in ``PackageConfig.cmake``
meets the requested version requirements.
The default file written by BASIS contains the following CMake code which
is suitable for most projects. Otherwise, add a custom ``config/Version.cmake.in``
template file to your project and it will be used instead.

.. code-block:: cmake

  # Package version as specified in BasisProject.cmake file
  set (PACKAGE_VERSION "@PROJECT_VERSION@")

  # Perform compatibility check here using the input CMake variables.
  # See example in http://www.cmake.org/Wiki/CMake_2.6_Notes.
  set (PACKAGE_VERSION_COMPATIBLE TRUE)
  set (PACKAGE_VERSION_UNSUITABLE FALSE)

  if ("${PACKAGE_FIND_VERSION_MAJOR}" EQUAL "@PROJECT_VERSION_MAJOR@")
    if ("${PACKAGE_FIND_VERSION_MINOR}" EQUAL "@PROJECT_VERSION_MINOR@")
      set (PACKAGE_VERSION_EXACT TRUE)
    endif ()
  endif ()


:apidoc:`ScriptConfig.cmake.in <ScriptConfig.cmake>`
----------------------------------------------------

The so-called script configuration file sets CMake variables which can be
used in scripted executables or libraries (i.e., modules). The respective
build targets are added via ``basis_add_executable`` or ``basis_add_library``.
See the :doc:`/standard/scripttargets` standard for details, in particular
the section about the :ref:`ScriptConfig`.


Package.cmake and Components.cmake
----------------------------------

The configuration of CPack_ for the generation of installers or other
distribution packages such as source code or binary packages, is done by
the :apidoc:`BasisPack.cmake` module. This module includes the ``config/Package.cmake``
file after the `CPack variables`_ have been set to the BASIS defaults if it exists.

The default configuration is derived from the project information as specified in the
``BasisProject.cmake`` file. As the ``config/Package.cmake`` file is included before
the CPack module, it can be used to override the default CPack configuration.
For example, additional exclude patterns can be added to
``CPACK_SOURCE_IGNORE_FILES`` to exclude additional files from the source code
distribution package. Another example would be to change the type of installers
that should be generated by CPack by selecting the preferred `CPack generators`_.
The default generator chosen by BASIS is the `TGZ generator`_.

To define any package components for installers which support the installation
of selected components, you can use the :apidoc:`basis_add_component`,
:apidoc:`basis_add_component_group`, :apidoc:`basis_add_install_type`,
and :apidoc:`basis_configure_downloads` commands.
The respective CPack commands used by these ``basis_`` counterparts are defined
by the ``CPack.cmake`` module which is included, however, after the ``config/Package.cmake``
file as required by CPack.
Therefore, the BasisPack module considers another project configuration file named
``config/Components.cmake``. This optional file should contain any custom installation
component definitions using aforementioned ``basis_add_`` commands.

.. seealso:: cpack_add_component_, cpack_add_component_group_, cpack_add_install_type_, cpack_configure_downloads_


.. _CPack:                     http://www.cmake.org/cmake/help/v2.8.12/cpack.html
.. _CPack generators:          http://www.cmake.org/cmake/help/v2.8.12/cpack.html#section_Generators
.. _CPack variables:           http://www.cmake.org/cmake/help/v2.8.12/cpack.html#section_VariablescommontoallCPackgenerators
.. _TGZ generator:             http://www.cmake.org/cmake/help/v2.8.12/cpack.html#gen:TGZ
.. _cpack_add_component:       http://www.cmake.org/cmake/help/v2.8.12/cpack.html#command:cpack_add_component
.. _cpack_add_component_group: http://www.cmake.org/cmake/help/v2.8.12/cpack.html#command:cpack_add_component_group
.. _cpack_add_install_type:    http://www.cmake.org/cmake/help/v2.8.12/cpack.html#command:cpack_add_install_type
.. _cpack_configure_downloads: http://www.cmake.org/cmake/help/v2.8.12/cpack.html#command:cpack_configure_downloads


Header Files
============

Header files are considered part of the public interface of a project, if they
are placed in any of the directories specified using the ``INCLUDE_DIRS`` parameter
of the :apidoc:`basis_project()` command, which by default is the ``include`` directory
of the project source tree. By default, public header files should be in
``include/<package>/`` for a top-level project or ``<module>/include/<package>/``
for a project module (i.e. subproject).
Notice the recommended subdirectories inside the include directory that help prevent
the collision of header file names across packages. Here, ``<package>`` is usually
the name of the top-level project which in case of a module is the argument of
the ``PACKAGE_NAME`` (or short ``PACKAGE``) parameter of :apidoc:`basis_project()`
in the ``BasisProject.cmake`` file of the module itself. In most cases, where the
module is considered an *internal* module of the top-level project, this package
name is identical to the project/package name of the top-level project.
In cases where the module is imported from another package, however, using for example
a submodule feature of the used version control system, the module is considered
*external* to the importing top-level project which only includes the module directly
in its source tree for convenience. Therefore the package which the module belongs
to is the one it was imported from. Such meta top-level project need not exist,
and may only be defined by the ``PACKAGE_NAME`` given in the ``BasisProject.cmake``
file of the module. In general, the package name of any project should correspond
to the *namespace* which all symbols of a software project belong to.
It should be noted that the concept of a *namespace* can be extended to all aspects
of a software project, not only certain programming languages which have it built in
such as C++. Therefore, the symbols which belong to the package namespace include
project modules, target names, C++ classes and functions, as well as script modules.

Header files which are located in a source code directory can be included in a
source file without the need for using aforementioned subdirectory structure.
These files are not automatically installed, however, as they are assumed
to be only used by ``.cpp`` modules which are eventually linked to an executable binary.
Header files which are included by other public header files or contain public
definitions of object classes that are linked to a library for use by other projects,
are by definition part of the public interface and therefore must be located in one
of the include directories.

Private header files are generally located nearby the ``.cpp`` files that make
use of them. These header files can be included using relative paths and the
preprocessor directive ``#include "header.h"`` rather than ``#include <header.h>``.
Both are valid, however, and additional include paths can always be added
using the :apidoc:`basis_include_directories()` command. This can be done
either in the ``CMakeLists.txt`` of the respective source code subtree or
in the ``config/Settings.cmake`` file (recommended).

All directories which are given as arguments of either the ``INCLUDE_DIRS``
or the ``CODE_DIRS`` parameter of :apidoc:`basis_project()` are automatically
added to the include search path using the ``BEFORE`` option of CMake's
``include_directories`` command to ensure that the header files of the
current project are preferred by the preprocessor.


Installation Prefix
===================

The ``CMAKE_INSTALL_PREFIX`` is initialized by BASIS based on the platform
which the build is configured on and the package vendor ID, i.e., the argument
of the ``PACKAGE_VENDOR`` (short ``VENDOR``) parameter of :apidoc:`basis_project()`.
This package vendor ID is usually set to a combination of package provider
and division or an acronym which the respective division is known by.
This default installation prefix can be overriden by the project in the
``config/Settings.cmake`` file. It can also be modified at any time from
the command line, i.e.,

.. code-block:: bash

  cmake -DCMAKE_INSTALL_PREFIX:PATH=/path/to/installation /path/to/code


Test Configuration
==================

CDash
-----

BASIS supports the tools CTest_/CDash_ which are related to CMake
and provide continuous integration testing.

.. seealso:: :ref:`HowToIntegrateCDash` for more detailed information.


Code Coverage
-------------

The test results such as the summary files generated by gcov_ are uploaded by CTest_
to a CDash_ server which can visualize these.
The analysis of the gcov (or Bullseye) output and its conversion to the XML
format used by CDash is done by the ctest_coverage_ CTest command.
The information needed by CTest for the upload is read from a configuration
file named ``CTestConfig.cmake`` which must be located in the top-level directory of the project.
To get a visual report without a CDash server, the command-line tool
lcov_ can be used to transform the gcov output into an HTML page.

The relevant compiler options when using the GNU Compiler Collection (GCC) are
added by the ``basistest.ctest`` script when the coverage option is passed in, i.e.,

.. code-block:: bash

    ctest -S basistest.ctest,coverage

.. seealso:: - `Introduction to CTest <http://www.vtk.org/Wiki/CMake/Testing_With_CTest>`__
             - `How to use gcov and lcov <http://qiaomuf.wordpress.com/2011/05/26/use-gcov-and-lcov-to-know-your-test-coverage/>`__

.. _CDash:          http://www.cdash.org/
.. _CTest:          http://cmake.org/cmake/help/v2.8.12/ctest.html
.. _ctest_coverage: http://cmake.org/cmake/help/v2.8.12/ctest.html#command:ctest_coverage
.. _gcov:           http://gcc.gnu.org/onlinedocs/gcc/Gcov.html
.. _lcov:           http://ltp.sourceforge.net/coverage/lcov.php


Custom Layout
=============

.. note:: Using a custom project layout is not recommended.

The :ref:`BASIS layout <SourceCodeTree>` has been battle tested and is based
on standards. It is both reusable and cross-platform with a design that prevents subtle incompatibilities 
and assumptions that we have encountered with other layouts. Through experience
and standardization we settled on the receommended layout which we believe should
be effective for most use cases.

Nonetheless, we understand that requirements and existing code cannot always 
accomodate the standard layout, so it is possible to customize the layout.
Therefore, the :apidoc:`basis_project()` command provides several options
to change the default directories and add additional custom include and source
code directories to be considered by BASIS during the build system configuration.

For example, a project may contain source code of a common static library in the
``Common`` subdirectory, image processing related library code in ``ImageProcessing``,
and implementations of executables in ``Tools``, while the documentation is located
in the subdirectory named ``Documentation`` and any CMake BASIS configuration files
in ``Configuration``. The ``BasisProject.cmake`` file of this project could contain
the following ``basis_project()`` call:

.. code-block:: cmake

  basis_project(
    NAME        CustomLayoutProject
    DESCRIPTION "A project which demonstrates the use of a custom source tree layout."
    CONFIG_DIR   Configuration
    DOC_DIR      Documentation
    INCLUDE_DIRS Common ImageProcessing
    CODE_DIRS    Common ImageProcessing Tools
  )

Another example for customization is given below for a top-level project which
contains different subprojects named ``ModulaA``, ``ModuleB``, and ``ModuleC``.
By default, BASIS would look for these modules in the ``modules`` directory.
This can be changed using either of the following ``basis_project`` commands,
where in the first case it is assumed that all modules are located in
a common subdirectory named ``Components``:

.. code-block:: cmake

  basis_project(
    NAME        TopLevelProjectWithCustomModulesDirectory
    DESCRIPTION "A project which demonstrates the use of a custom modules directory."
    MODULES_DIR Components
  )

.. code-block:: cmake

  basis_project(
    NAME        TopLevelProjectWithCustomModuleDirectories
    DESCRIPTION "A project which demonstrates the use of custom module directories."
    MODULE_DIRS ModuleA ModuleB ModuleC
  )


Redistributable Files
=====================

In general, try to keep redistributable sources and binaries as small as possible.



.. _find_package:  http://www.cmake.org/cmake/help/v2.8.12/cmake.html#command:find_package
