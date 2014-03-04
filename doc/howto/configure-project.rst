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
``config/Settings.cmake`` file (GCC):

.. code-block:: cmake

  add_definitions(-Wall -Werror)

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

Header files will be part of the public API of a project if they are placed
in ``include/<package>/header1.hpp`` for a top-level project,
or ``<module>/include/<package>/header2.hpp`` for a project module.
Notice the recommended subdirectory structure that helps prevent the
collision of header file names, where ``<package>`` is usually the name of
the top-level project which in case of a module is the argument of the
``PACKAGE_NAME`` paramter of :apidoc:`basis_project()`.

If header files are placed in any other source code directory, i.e., those
named as arguments of the ``CODE_DIRS`` parameter of :apidoc:`basis_project()`
which is ``src`` by default, these header files can be included
in a source code files without the need for adding these directories to
the include search path explicitly. BASIS already adds each of these
directories to the search path, but will not install the header files
located in a source code directory. Only those in the ``INCLUDE_DIRS``
will be installed automatically. Alternatively, as for these header
files are not part of the public API and therefore there is no name
conflict with external libraries to expect, they can be included by
the source files relative to the location of the ``.cpp`` files as in:

.. code-block:: c++

  #include "private.h"

Header files should be in
``modulename/include/toplevelproject/myheader.hpp`` if the module is an
"internal" module of the top-level project, i.e., if it belongs to the
namespace of that package. Otherwise, they should be in
``modulename/include/package/myheader.hpp`` where package corresponds to the
name of the ``PACKAGE`` parameter specified in :apidoc:`basis_project()` the
module belongs to as specified in the :apidoc:`BasisProject.cmake` file of
the module.

Header files which are not part of the public API should just be somewhere
in the PROJECT_CODE_DIR, possibly just next to the .cpp files. There is no
need for these to have namespace specific subdirectories, but you may still
want to organize them somehow. Use :apidoc:`basis_include_directories()` in
config/:apidoc:`Settings.cmake` to add additional include paths.

The :apidoc:`basis_project_impl()` macro adds three directories to the
include search path by default using the BEFORE option of CMake's
``include_directories()`` command. This means that it will always be
included before any paths imported from other packages or those added in
config/Settings.cmake) with the following order of precedence:

- ``BINARY_INCLUDE_DIR``
- ``PROJECT_INCLUDE_DIR``
- ``PROJECT_CODE_DIR``

Install Path
============

The ``PROJECT_PACKAGE_VENDOR`` variable (i.e., short VENDOR option of the
:apidoc:`basis_project()` command) also defines the short package ID folder
used for the installation path.

If a project developer wishes to use a different default for certain settings 
such as the ``CMAKE_INSTALL_PREFIX``, they can always do so in the 
config/:apidoc:`Settings.cmake` file which is included after the directory 
variables have been initialized. ``CMAKE_INSTALL_PREFIX`` can also be modified 
at any time from the command line via cmake's -D command-line option.


Test Configuration
==================

CDash
-----

BASIS also integrates support provided by the continuous 
integration tool related to CMake called CDash.

.. seealso:: :ref:`HowToIntegrateCDash` for more detailed information.

Code Coverage
-------------

You need to upload the test results to a CDash server which can visualize the
coverage. This is done by CTest according to the configuration file
(CTestConfig.cmake). We had a CDash server running at SBIA, but it was barely
used. A lot has certainly been improved for CDash since then so would be
interesting to see how things work now...

.. seealso:: http://www.vtk.org/Wiki/CMake/Testing_With_CTest

Just run the tests as usual with gcov and then use the usual command-line
tools (I don't remember them right now and would have to search the internet
as well) to get a graphical coverage report.

Another good read is a blog on `how to use gcov and lcov`_
to get a nice coverage report. Note, however, that CDash has its
own built in tools to visualize the coverage data generated by gcov or other
such tools that it supports.

The relevant compiler options when using the GNU Compiler Collection are
added by the basistest.ctest script if the coverage option is passed in as in

.. code-block:: bash

    ctest -S basistest.ctest,coverage

The analysis of the gcov (or Bullseye) output and its conversion to the XML
format used by CDash is done by the ``ctest_coverage`` CTest command.


Custom Layout
=============

The BASIS layout has been battle tested and is based on standards. It is both
reusable and cross-platform with a design that prevents subtle incompatibilities 
and assumptions that we have encountered with other layouts. Through experience
and standardization we settled on the receommended layout which we believe should
be effective for most use cases.

Nonetheless, we understand that requirements and existing code cannot always 
accomodate the standard layout, so it is possible to customize the layout.

.. note:: Using a custom project layout is not recommended.

To set up a custom layout do one or both of the following:

1. In the :apidoc:`BasisProject.cmake` file
      - Modify the :apidoc:`basis_project()` function
      - The ``INCLUDE_DIRS`` parameter sets
        additional directories that should be included.
      - The ``MODULE_DIRS`` parameter specifies a 
        path to each nonstandard module directory.

2. In the :apidoc:`config/Settings.cmake <Settings.cmake>` file
     - Set the CMake BASIS variables listed under :ref:`SourceCodeTree`
       with a call to ``set(VARIABLE path/to/dir)``.

More information can be found in :doc:`/standard/template`.

Redistributable Files
=====================

In general, try to keep redistributable sources and binaries as small as possible.


.. _how to use gcov and lcov: http://qiaomuf.wordpress.com/2011/05/26/use-gcov-and-lcov-to-know-your-test-coverage/
.. _find_package:             http://www.cmake.org/cmake/help/v2.8.12/cmake.html#command:find_package
