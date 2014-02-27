.. meta::
    :description: How to configure a software project based on BASIS,
                  a build system and software implementation standard.

===================
Configure a Project
===================

This guide demonstrates some of the more advanced details,
tricks, and tools to modify and configure your project.

 .. seealso:: The guide on how to :doc:`/howto/create-and-modify-project`, :ref:`BasisProject.cmake <BasisProject>`, 
              and `basis_project()`_. :doc:`/standard/template` describes the typical project layout.       


CMake Configuration
===================

.. _ConfigureBasisProject:

::apidoc::`BasisProject.cmake`
------------------------------

The key file for any project is the BasisProject.cmake file. It sets basic information 
about a BASIS Project and calls the :apidoc:`basis_project()` command.


Note that there are several rules for how this works.

- TopLevel projects cannot have modules as dependencies
- Modules can depend on other modules

Dependencies
~~~~~~~~~~~~

Dependencies specified in the :apidoc:`basis_project()` command also support 
more advanced selection of specific version and package components.
Dependencies can also be specified multiple times if some components
are optional, while others are required.

The syntax for specifying dependencies is:

.. code-block:: cmake
    
    basis_project(
      # [...]
      DEPENDS
        <package_name>[-<version>][{<componen1>,<component2>,...}]
      # [...]
    )
    
    
In the example below, ``ITK-4{IOKernel}``, you would require version 4 of the 
ITK package. You can also be more specific using ``ITK-4.2`` or ``ITK-3.18.0``.

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
    
    
:apidoc:`Settings.cmake`
------------------------

.. todo:: explain and give an example of what you can configure with this file

:apidoc:`Config.cmake.in`
-------------------------

.. todo:: explain and give an example of what you can configure with this file

:apidoc:`Version.cmake.in`
--------------------------

.. todo:: explain and give an example of what you can configure with this file

:apidoc:`ScriptConfig.cmake.in`
-------------------------------

.. todo:: explain and give an example of what you can configure with this file

:apidoc:`Package.cmake`
-----------------------

.. todo:: explain and give an example of what you can configure with this file

:apidoc:`Depends.cmake`
----------------------

Headers
=======

Headers will be part of the public API of a project if they are placed in
``<module>/include/<module>/myheader.hpp``. Notice the recommended
"stuttered" module name that helps prevent the collision of header file names.

If headers are placed in src in a module of a toplevel project, 
how can we make sure the include paths still work correctly?

I know they will work if the headers are placed in but what if they are in
``modulename/src/myheader.hpp``?

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

1. In the :apidoc:`BasisConfig.cmake` file
      - Modify the :apidoc:`basis_project()` function
      - The ``INCLUDE_DIRS`` parameter sets
        additional directories that should be included.
      - The ``MODULE_DIRS`` parameter specifies a 
        path to each nonstandard module directory.
        
3. In the config/:apidoc:`Settings.cmake` file
     - Set the CMake BASIS variables listed under SourceCodeTree_
       with a call to ``set(VARIABLE path/to/dir)``.

More information can be found in :doc:`/standard/template`.

Redistributable Files
=====================

In general, try to keep redistributable sources and binaries as small as possible.


.. _how to use gcov and lcov: http://qiaomuf.wordpress.com/2011/05/26/use-gcov-and-lcov-to-know-your-test-coverage/
