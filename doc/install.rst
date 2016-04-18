.. meta::
    :description: Build and installation instructions for BASIS.

============
Installation
============


.. _BasisBuildDependencies:

Prerequisites
=============

.. note:: The stated package versions are the minimum versions for which it is known that
          BASIS is working with.


Required Packages
-----------------

This section summarizes software packages which have to be installed on your system before
BASIS can be build and installed from its sources.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{3.75cm}|m{1.5cm}|p{9.8cm}|

+----------------------------+-----------+---------------------------------------------------------------+
| Package                    | Version   | Description                                                   |
+============================+===========+===============================================================+
| CMake_                     | 2.8.12    | A cross-platform, open-source build tool used to generate     |
|                            |           | platform specific build configurations. It configures the     |
|                            |           | system for the various build tools which perform the actual   |
|                            |           | build of the software.                                        |
|                            |           |                                                               |
|                            |           | If your operating system such as certain Linux distribution   |
|                            |           | does not include a pre-build binary package of the required   |
|                            |           | version yet, download a more recent CMake version from the    |
|                            |           | `CMake download page`_ and build and install it from sources. |
|                            |           | Often this is easiest accomplished by using the CMake version |
|                            |           | provided by the Linux distribution in order to configure the  |
|                            |           | build system for the more recent CMake version. To avoid      |
|                            |           | conflict with native CMake installation, it is recommended    |
|                            |           | to install your own build of CMake in a different directory.  |
+----------------------------+-----------+---------------------------------------------------------------+
| `GNU Make`_, ninja_, etc.  |           |  All build tools supported by the CMake generator.            |
+----------------------------+-----------+---------------------------------------------------------------+
| `GNU Compiler Collection`_,|           |  A C++ compiler is required to compile the BASIS source code. |
| Clang_, etc.               |           |                                                               |
+----------------------------+-----------+---------------------------------------------------------------+


Optional Packages
-----------------

The packages named in the following table are used by BASIS only if installed on your system,
and their presence is generally not required. Hence, you will be able to use the software even without
these.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{3.75cm}|m{1.5cm}|p{9.8cm}|

+----------------------------+-----------+---------------------------------------------------------------+
| Package                    | Version   | Description                                                   |
+============================+===========+===============================================================+
| Doxygen_                   | 1.8.0     | This tools is required for the generation of the API          |
|                            |           | documentation from in-source comments in C++, CMake, Bash,    |
|                            |           | Python, and Perl. Note that only since version 1.8.0, Python  |
|                            |           | and the use of Markdown (Extra) are support by Doxygen.       |
+----------------------------+-----------+---------------------------------------------------------------+
| Python_                    | 2.7       | Python is used by the basisproject tool that generates        |
|                            |           | template projects. Python is also generally supported         |
|                            |           | for the implementation of tools and libraries following       |
|                            |           | the BASIS standard.                                           |
+----------------------------+-----------+---------------------------------------------------------------+
| Sphinx_                    | 1.2       | This tool can be used for the generation of the documentation |
|                            |           | from in-source Python comments and in particular from         |
|                            |           | reStructuredText_.                                            |
+----------------------------+-----------+---------------------------------------------------------------+
| LaTeX_                     |           | The LaTeX tools may be required for the generation of the     |
|                            |           | software manuals. Usually these are, however, already         |
|                            |           | included in PDF in which case a LaTeX installation is only    |
|                            |           | needed if you want to regenerate these from the LaTeX sources |
|                            |           | (if available after all).                                     |
+----------------------------+-----------+---------------------------------------------------------------+
| ITK_                       | 3.14      | The standalone ``basistest-driver`` executable currently      |
|                            |           | makes use of the ITK, either version 3 or 4 and above,        |
|                            |           | for the comparison of a test image to one or more             |
|                            |           | baseline images. If no installation of this library is        |
|                            |           | found, this executable is excluded from the build and         |
|                            |           | installation. Note that many packages developed at SBIA       |
|                            |           | make use of this executable in their tests. If BASIS has      |
|                            |           | been built without the ``basistest-driver``, these            |
|                            |           | packages have to be build with the ``BUILD_TESTING``          |
|                            |           | option set to ``OFF`` (the default).                          |
+----------------------------+-----------+---------------------------------------------------------------+
| MATLAB_                    | R2009b    | The MATLAB tools are used by BASIS to build `MEX-Files`_      |
|                            |           | from C++ sources. If ``BUILD_TESTING`` is set to ``ON``       |
|                            |           | and the MEX_ script is found, the tests for the build of      |
|                            |           | MEX files are run. Otherwise, these are excluded from         |
|                            |           | the test.                                                     |
+----------------------------+-----------+---------------------------------------------------------------+
| `MATLAB Compiler`_         | R2009b    | The MATLAB Compiler (MCC) is used by BASIS to build           |
|                            |           | stand-alone executables from MATLAB source files.             |
|                            |           | If ``BUILD_TESTING`` is set to ``ON`` and MCC is found,       |
|                            |           | the tests for the build of such binaries are run.             |
|                            |           | Otherwise, these are excluded from the test.                  |
+----------------------------+-----------+---------------------------------------------------------------+


.. _BasisInstallationSteps:

Build and Installation
======================

Build Steps
-----------

The steps to build, test, and install BASIS are as follows:

1. Extract source files.
2. Create build directory and change to it.
3. Run CMake to configure the build tree.
4. Build the software using selected build tool.
5. Test the built software.
6. Install the built files.

On Unix-like systems with GNU Make as build tool, these build steps can be
summarized by the following sequence of commands executed in a shell,
where $package and $version are shell variables which represent the name
of this package and the obtained version of the software.

.. code-block:: bash

    $ tar xzf cmake-basis-$version.tar.gz
    $ cd cmake-basis-$version
    $ mkdir build && cd build
    $ ccmake ..

- Press 'c' to configure the build system and 'e' to ignore warnings.
- Set CMAKE_INSTALL_PREFIX and other CMake variables and options.
- Continue pressing 'c' until the option 'g' is available.
- Then press 'g' to generate the configuration files for GNU Make.

.. code-block:: bash

    $ make
    $ make test    (optional)
    $ make install (optional)

Please refer to the detailed :doc:`Build and Installation How-To Guide <howto/install>`
which applies to any project developed using BASIS if you are uncertain about above
steps or have problems to build, test, or install the software on your system.
If this guide does not help you resolve the issue, please
`Report the Issue on GitHub <https://github.com/cmake-basis/BASIS/issues>`__.
In case of failing tests, please attach the output of the following
command:

.. code-block:: bash

    $ ctest -V >& test.log


.. _BasisInstallationOptions:

CMake Options
-------------

In the following, only CMake settings available to configure the build and
installation of BASIS itself are documented. See :doc:`howto/cmake-options`
for detailed information on general CMake Options available for the build
and installation of any package developed with BASIS.

.. option:: -DDEPENDS_ITK_DIR:PATH

   Specify directory of ITKConfig.cmake file. The ITK library is
   used by the basistest-driver executable if available. See
   Build Dependencies for more details.

.. option:: -DDEPENDS_MATLAB_DIR:PATH

   Specify installation root directory of MATLAB_. This variable
   is only available if BUILD_TESTING was set to ON and setting
   it can be omitted. If a MATLAB installation was specified,
   however, the tests for the build of binaries using the `MATLAB Compiler`_
   or the MEX_ script respectively can be run.

.. option:: -DDEFAULT_TEMPLATE:PATH

   Path to the directory and version of the default mad-libs style text substitution project
   template that will be installed with BASIS. See the
   :doc:`Template Customization How-To <howto/use-and-customize-templates>` for details.

.. option:: -DINSTALL_TEMPLATE_DIR:BOOL

   Custom installation directory for project templates.


Advanced CMake Options
~~~~~~~~~~~~~~~~~~~~~~

Depending on which language interpreters are installed on your system,
the following CMake options are available:

.. option:: -DWITH_ITK:BOOLEAN

   Whether to link the standalone test driver with ITK.

.. option:: -DWITH_Python:BOOLEAN

   Whether to build/enable the Python utilities.

.. option:: -DWITH_Perl:BOOLEAN

   Whether to build/enable the Perl utilities.

.. option:: -DWITH_BASH:BOOLEAN

   Whether to build/enable the BASH utilities.


.. _BasisEnvironmentSetUp:

Set up the Environment
======================

In order to ease the execution of the main executable files, we suggest to
add the path ``<prefix>/bin/`` to the search path for executable files, i.e.,
the ``PATH`` environment variable. This is, however, generally not required.
It only eases the execution of the command-line tools provided by the software
package.

For example, if you use Bash_ add the following line to the ``~/.bashrc`` file:

.. code-block:: bash

    export PATH="<prefix>/bin:${PATH}"


.. _BasisDeinstallation:

Deinstallation
==============

During the installation, a manifest of all installed files and a CMake
script which reads in this list in order to remove these files again
is generated and installed in ``<prefix>/lib/cmake/basis/``.

The uninstaller is located in ``<prefix>/bin/`` and named ``uninstall-basis``.
In order to remove all files installed by this package as well as the empty
directories left behind inside the installation root directory given by ``<prefix>``,
run the command:

.. code-block:: bash

    uninstall-basis

assuming that you added ``<prefix>/bin/`` to your :envvar:`PATH` environment variable.


.. _Bash: http://www.gnu.org/software/bash/
.. _CMake: http://www.cmake.org/
.. _CMake download page: http://www.cmake.org/cmake/resources/software.html
.. _ccmake: http://www.cmake.org/cmake/help/runningcmake.html
.. _CTest: http://www.cmake.org/cmake/help/v2.8.8/ctest.html
.. _Doxygen: http://www.stack.nl/~dimitri/doxygen/
.. _GNU Make: http://www.gnu.org/software/make/
.. _ninja: http://martine.github.io/ninja/
.. _GNU Compiler Collection: http://gcc.gnu.org/
.. _Clang: http://clang.llvm.org/
.. _LaTeX: http://www.latex-project.org/
.. _MATLAB: http://www.mathworks.com/products/matlab/
.. _MATLAB Compiler: http://www.mathworks.com/products/compiler/
.. _MEX: http://www.mathworks.com/help/techdoc/ref/mex.html
.. _MEX-Files: http://www.mathworks.com/help/techdoc/matlab_external/f7667.html
.. _reStructuredText: http://docutils.sourceforge.net/rst.html
.. _Sphinx: http://sphinx.pooco.org/
.. _ITK: http://www.itk.org/
.. _MEX-Files: http://www.mathworks.com/help/techdoc/matlab_external/f7667.html
.. _Python: http://www.python.org/
