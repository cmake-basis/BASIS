.. meta::
    :description: Build and installation instructions for BASIS.

============
Installation
============

This page contains the instructions for both installing BASIS itself and typical packages that use BASIS.


Build from source
=================

See :ref:`BasisBuildDependencies` below for information on dependencies.

Build Steps
-----------

The common steps to build, test, and install software based on CMake,
including this software, are as follows:

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

    $ tar xzf $package-$version-source.tar.gz
    $ mkdir $package-$version-build
    $ cd $package-$version-build
    $ ccmake ../$package-$version-source

- Press 'c' to configure the build system and 'e' to ignore warnings.
- Set CMAKE_INSTALL_PREFIX and other CMake variables and options.
- Continue pressing 'c' until the option 'g' is available.
- Then press 'g' to generate the configuration files for GNU Make.

.. code-block:: bash

    $ make
    $ make test    (optional)
    $ make install (optional)

An exhaustive list of minimum build dependencies, including the build tools
along detailed step-by-step build, test, and installation instructions can
be found in the corresponding "Building from Sources" section of the BASIS
how-to guide on software installation [2].

Please refer to this guide first if you are uncertain about above steps or
have problems to build, test, or install the software on your system.
If this guide does not help you resolve the issue, please contact us at
<sbia-software at uphs.upenn.edu>. In case of failing tests, please attach
the output of the following command to your email:

.. code-block:: bash

    $ ctest -V >& test.log

In the following, only package-specific CMake settings available to
configure the build and installation of this software are documented.


CMake Options
-------------

See :doc:`howto/buildoptions` for detailed information on CMake Options.

- ITK_DIR      Specify directory of ITKConfig.cmake file. The ITK library is
               used by the basistest-driver executable if available. See
               Build Dependencies for more details.
- MATLAB_DIR   Specify installation root directory of MATLAB. This variable
               is only available if BUILD_TESTING was set to ON and setting
               it can be omitted. If a MATLAB installation was specified,
               however, the tests for the build of binaries using the MATLAB
               Compiler or the MEX script respectively can be run.


Advanced CMake Options
~~~~~~~~~~~~~~~~~~~~~~

Depending on which language interpreters are installed on your system,
the following CMake options are available:

USE_ITK            Whether to utilize the found ITK.
USE_PythonInterp   Whether to build/enable the Python utilities.
USE_Perl           Whether to build/enable the Perl utilities.
USE_BASH           Whether to build/enable the BASH utilities.

.. _BasisBuildDependencies:

Prerequisites
-------------

The following software packages are prerequisites for any software that is based on BASIS.
When you are building BASIS itself, the dependency on BASIS is obviously already fulfilled.
Furthermore, the stated package versions are the minimum versions for which it is known that
the software is working with. Newer versions will usually be fine as well if not otherwise
stated, but less certainly older versions.


Required Packages
~~~~~~~~~~~~~~~~~

This section summarizes software packages which have to be installed on your system before
this software can be build from its sources.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{3.75cm}|m{1.5cm}|p{9.8cm}|

+----------------------------+-----------+---------------------------------------------------------------+
| Package                    | Version   | Description                                                   |
+============================+===========+===============================================================+
| CMake_                     | 2.8.4     | A cross-platform, open-source build tool used to generate     |
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
| :doc:`BASIS </index>`      |           | The Build system And Software Implementation Standard (BASIS) |
|                            |           | among other features defines the project directory structure  |
|                            |           | and provides CMake implementations to ease and standardize    |
|                            |           | the packaging, build, testing, and installation. Refer to the |
|                            |           | ``INSTALL`` document of the software package you want to      |
|                            |           | build for information on which particular BASIS version is    |
|                            |           | required by this package.                                     |
+----------------------------+-----------+---------------------------------------------------------------+
| `GNU Make`, `ninja`, etc.  |           |  All build tools supported by the CMake generator             |
+----------------------------+-----------+---------------------------------------------------------------+
| `GNU Compiler Collection`,_|           |  A C++ compiler is required to compile the BASIS source code. |
| `Clang`, etc.              |           |                                                               |
+----------------------------+-----------+---------------------------------------------------------------+


Optional Packages
~~~~~~~~~~~~~~~~~

The packages named in the following table are used only if installed on your system, and their presence
is generally not required. You will generally be able to use the software without these. 
See the ``INSTALL`` file of your specific software package for details on what is required.

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
| Python                     | 2.7       | Python is used by the basisproject tool that generates        |
|                            |           | template projects. Python is also generally supported         |
|                            |           | for the implementation of tools and libraries following       |
|                            |           | the BASIS standard.                                           |
+----------------------------+-----------+---------------------------------------------------------------+
| Sphinx_                    | 1.1.3     | This tool can be used for the generation of the documentation |
|                            |           | from in-source Python comments and in particular from         |
|                            |           | reStructuredText_.                                            |
+----------------------------+-----------+---------------------------------------------------------------+
| LaTeX_                     |           | The LaTeX tools may be required for the generation of the     |
|                            |           | software manuals. Usually these are, however, already         |
|                            |           | included in PDF in which case a LaTeX installation is only    |
|                            |           | needed if you want to regenerate these from the LaTeX sources |
|                            |           | (if available after all).                                     |
+----------------------------+-----------+---------------------------------------------------------------+
| MATLAB_                    | R2009b    | The MATLAB_ tools such as, in particular, the MEX_ script are |
|                            |           | used to build `MEX-Files`_ from C++ source code. A MEX-File   |
|                            |           | is a loadable module for MATLAB which implements a single     |
|                            |           | function. If the software package you are building does not   |
|                            |           | define any MEX build target, MATLAB might not be required.    |
+----------------------------+-----------+---------------------------------------------------------------+
| `MATLAB Compiler`_         | R2009b    | The MATLAB Compiler (MCC) is required for the build of        |
|                            |           | stand-alone executables and shared libraries from MATLAB_     |
|                            |           | source files. If the software package you are building does   |
|                            |           | not include any MATLAB sources (``.m`` files), you do not     |
|                            |           | need the MATLAB Compiler to build it.                         |
+----------------------------+-----------+---------------------------------------------------------------+

BASIS Package Optional Prerequisites
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

BASIS itself optionally makes
use of the following software packages:

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{3.75cm}|m{1.5cm}|p{9.8cm}|

+---------------------+---------+---------------------------------------------------------+
| Package             | Version | Description                                             |
+=====================+=========+=========================================================+
| ITK_                | 3.14    | The standalone ``basistest-driver`` executable currently|
|                     |         | makes use of the ITK, either version 3 or 4 and above,  |
|                     |         | for the comparison of a test image to one or more       |
|                     |         | baseline images. If no installation of this library is  |
|                     |         | found, this executable is excluded from the build and   |
|                     |         | installation. Note that many packages developed at SBIA |
|                     |         | make use of this executable in their tests. If BASIS has|
|                     |         | been built without the ``basistest-driver``, these      |
|                     |         | packages have to be build with the ``BUILD_TESTING``    |
|                     |         | option set to ``OFF`` (the default).                    |
+---------------------+---------+---------------------------------------------------------+
| MATLAB_             | R2009b  | The MATLAB tools are used by BASIS to build `MEX-Files`_|
|                     |         | from C++ sources. If ``BUILD_TESTING`` is set to ``ON`` |
|                     |         | and the MEX script is found, the tests for the build of |
|                     |         | MEX files are run. Otherwise, these are excluded from   |
|                     |         | the test.                                               |
+---------------------+---------+---------------------------------------------------------+
| `MATLAB Compiler`_  | R2009b  | The MATLAB Compiler (MCC) is used by BASIS to build     |
|                     |         | stand-alone executables from MATLAB source files.       |
|                     |         | If ``BUILD_TESTING`` is set to ``ON`` and MCC is found, |
|                     |         | the tests for the build of such binaries are run.       |
|                     |         | Otherwise, these are excluded from the test.            |
+---------------------+---------+---------------------------------------------------------+

For instructions on how to build or install these prerequisites, please refer to
the documentation of the respective software package.


Build and Installation
----------------------

These are the build, test, and installation steps 
common to any BASIS based software, including BASIS itself.


This document describes how to build and install any
software developed on top of BASIS, a meta-project which defines 
the Build system And Software Implementation Standard established 
in the fall of 2011. See the :doc:`/index` page for details on 
this meta-project.

If you obtained a binary distribution package for a supported platform,
please follow the installation instructions corresponding to your operating
system. The build step can be omitted in this case.

In case of problems to build, install, or use the software, please contact
the SBIA Group at the University of Pennsylvania, PA, at
``sbia-software at uphs.upenn.edu``.

.. note::

    The commands given in this guide have to be entered in a terminal, in particular,
    the Bourne Again Shell (Bash_). If you are not using the Bash, see the
    documentation of your particular shell for information on how to perform these
    actions using this shell instead.


.. _PackageNames:

Package Names
=============

The file names of the distribution packages follow the convention
``<package>-<version>-<arch><ext>``, where ``<package>`` is the name of the
package in lowercase letters, and ``<version>`` is the package version in the
format ``<major>.<minor>.<patch>``. The ``<arch>`` file name part specifies the
operating system and hardware architecture, i.e.,

================   =================
<arch>             Description
================   =================
``linux-x86``      Linux, 32-bit
``linux-x86_64``   Linux, 64-bit
``darwin-i386``    Darwin x86 Intel
``darwin-ppc``     Darwin Power PC
``win32``          Windows, 32-bit
``win64``          Windows, 64-bit
``source``         Source files
================   =================

The file name extension ``<ext>`` is ``.tar.gz`` for a compressed tarball,
``.deb`` for a Debian package, and ``.rpm`` for a RPM package.


.. _InstallingBinaryPackage:

Binary Distribution Package
===========================


.. _InstallingDebianPackage:

Debian Package
--------------

This package can be installed on Debian_ and its derivatives such as Ubuntu_
using the Advanced Package Tool (APT_)::

    sudo apt-get install <package>-<version>-<arch>.deb


.. _InstallingRPMPackage:

RPM Package
-----------

This package can be installed on `Red Hat Enterprise Linux`_ and its derivatives
such as CentOS_ and openSUSE_ using the Yellowdog Updater, Modified (YUM_)::

    sudo yum install <package>-<version>-<arch>.rpm


.. _InstallingMacOSBundle:

Mac OS
------

Bundles for `Mac OS`_ might be available for some software packages, but this is not
supported by default. Please refer to the ``INSTALL`` file which is located in the
top directory of the respective software package.


.. _InstallingWindows:

Windows
-------

Currently, `Microsoft Windows`_ has limited support as an operating system. The
most tested platform is the Linux platform CentOS_, in particular, and most software
packages are therefore dependent on a Unix-based operating system. Thus, building
and executing SBIA software under Windows will most likely require an installation
of Cygwin_ and the build of the software from sources as described below.
Some packages, on the other side, can be build on Windows as well, using, for example,
`Microsoft Visual Studio`_ as build tool. The Visual Studio project files have
to be generated using CMake (see :ref:`HowToBuildTheSoftware`).

As an alternative, consider the use of a Live Linux Distribution,
a dual boot installation of Linux or an installation of a Linux operating
system in a virtual machine using virtualization tools such as VirtualBox_ or
proprietary virtualization solutions available for your host operating system.


.. _HowToBuildTheSoftware:

Building From Sources
=====================

In the following, we assume you obtained a copy of the source package as
compressed tarball (``.tar.gz``). The name and version part of the package file
is referred to as Bash_ variable:

.. code-block:: bash

    package=<package>-<version>



.. _ExtractSources:

Extract sources
---------------

At first, extract the downloaded source package, e.g.:

.. code-block:: bash

    tar -xzf $package-source.tar.gz ~

This will extract the sources to a new diretory in your home directory
named "<package>-<version>-source".


.. _ConfigureBuildTree:

Configure
---------

Create a directory for the build tree of the package and change to it, e.g.:

.. code-block:: bash

    mkdir ~/$package-build
    cd ~/$package-build

.. note::

    An in-source build, i.e., building the software within the source tree
    is not supported to force a clear separation of source and build tree.

To configure the build tree, run CMake's graphical tool ccmake_:

.. code-block:: bash

    ccmake ~/$package-source

Press ``c`` to trigger the configuration step of CMake. Warnings can be ignored by
pressing ``e``. Once all CMake variables are configured properly, which might require
the repeated execution of CMake's configure step, press ``g``. This will generate the
configuration files for the selected build tool (i.e., GNU Make Makefiles in our case)
and exit CMake.

Variables which specify the location of other required or optionally used packages
if available are named ``<Package>_DIR``. These variables usually have to be set to the
directory which contains a file named ``<Package>Config.cmake`` or ``<package>-config.cmake``.
Alternatively, or if the package does not provide such CMake package configuration
file, the installation prefix, i.e., root directory should be specified. See the
build instructions of the particular software package you are building for more
details on the particular ``<Package>_DIR`` variables that may have to be set if the
packages were not found automatically by CMake.

See the documentation of the available :doc:`default configuration options <howto/buildoptions>`
for more options that can be used to configure the build of any BASIS-based project.
Please refer also to the package specific build instructions given in the ``INSTALL`` file
or software manual of the corresponding package for information on available
additional project specific configuration options.

.. note::
    The ccmake_ tool also provides a brief description to each variable in the status bar.

.. toctree::
    :hidden:

    howto/buildoptions


.. _Build:

Build
-----

To build the executables and libraries, run GNU Make in the root directory of
the configured build tree::

    make

In order to build the documentation, the :option:`-DBUILD_DOCUMENTATION` option
has to be set to ``ON``. Detailed information on CMake Options can be found at 
:doc:`howto/buildoptions`. If not set before, this option can be enabled using
the command:

.. code-block:: bash

    cmake -D BUILD_DOCUMENTATION:BOOL=ON ~/$package-build

Note that the build of the documentation may require the build of the software
beforehand. If the software was not build before, the build of the documentation
will also trigger the build of the software.

Each software package provides different documentation. In general, however,
each software has a manual, which by default is being build by the ``manual``
target if the software manual is not already included as PDF document. In the
latter case, the manual does not have to be build. Instead, the PDF file will
simply be copied (and renamed) during the installation. Otherwise, in order
to build the manual from source files such as reStructuredText_ or LaTeX_, run
the command::

    make manual

If the software provides a software library for use in your own code, the API
documentation may be useful which can be build using the ``apidoc`` target::

    make apidoc

The advanced :option:`-DBASIS_INSTALL_APIDOC_DIR` configuration option can be set to an
absolute path or a path relative to the :option:`-DCMAKE_INSTALL_PREFIX` directory
in order to modify the installation directory for the API documentation which is
generated from the in-source comments using tools such as Doxygen_ and Sphinx_.
This can be useful, for example, to install the documentation in the document
directory of a web server.

Some software packages further generate a project web site from text files
marked up using a lightweight markup language such as reStructuredText_.
This web site can be build using the ``site`` target::

    make site

This will generate the HTML pages and corresponding static files of the
web site in ``doc/site/html/``. If you prefer a single directory per document
which results in prettier URLs without the ``.html`` extension, run
the following command instead::

    make site_dirhtml

The resulting web site can then be found in ``doc/site/dirhtml/``.
Optionally, the advanced :option:`-DBASIS_INSTALL_SITE_DIR` configuration option can be
set to an absolute path or a path relative to the :option:`-DCMAKE_INSTALL_PREFIX`
directory in order to modify the installation directory for the generated
web site. This can be useful, for example, to install the web site in the
document directory of a web server.

For maintainers of the software, a developer's guide may be provided which
would then be build by the ``guide`` target if not included as PDF document::

    make guide

If the source tree is a Subversion_ working copy and you have access to the
Subversion repository of the project or if the project source tree is a Git_
repository, a ChangeLog file can be generated from the commit history by
building the ``changelog`` target::

    make changelog

In case of Subversion, be aware that the generation of the ChangeLog takes
several minutes and may require the input of your user credentials for access
to the Subversion repository. Moreover, if the command svn2cl_ is installed
on your system, it will be used to format the ChangeLog prettier. Otherwise,
the plain output of the ``svn log`` command is written to the ``ChangeLog`` file.

.. note::

    Not all of the above build targets are provided by each software package.
    You can see a list of available build targets by running ``make help``.
    All available documentation targets, except the ChangeLog, can be build
    by executing the command ``make doc``.


.. _TestBuiltFiles:

Test
----

In order to run the software tests, execute the command::

    make test

For more verbose test output, which in particularly is of importance when
submitting an issue report to <sbia-software at uphs.upenn.edu>, run CTest_
directly with the ``-V`` option instead:

.. code-block:: bash

    ctest -V >& $package-test.log

and attach the file ``$package-test.log`` to the issue report.

.. note::
    If the software package does not include tests, follow the steps in the
    software manual to test the software manually with the provided example
    dataset.


.. _InstallBuiltFiles:

Install
-------

Detailed information on CMake Options can be found at :doc:`howto/buildoptions`.

First, make sure that the CMake configuration options :option:`-DCMAKE_INSTALL_PREFIX`,
:option:`-DBASIS_INSTALL_SCHEME`, and :option:`-DBASIS_INSTALL_SITE_PACKAGES` are set properly,
where for normal use cases only :option:`-DCMAKE_INSTALL_PREFIX` may be modified.
These variables can be set as follows:

.. code-block:: bash

    cmake -D "CMAKE_INSTALL_PREFIX:PATH=<prefix>" ~/$package-build

or:

.. code-block:: bash

    cmake -D "CMAKE_INSTALL_PREFIX:PATH=<prefix>" \
          -D "BASIS_INSTALL_SCHEME:STRING=default|usr|opt|win" \
          -D "BASIS_INSTALL_SITE:BOOL=ON|OFF" \
          ~/$package-build

This can be omitted if these variables were set already during the configuration
of the build tree or if the default values should be used.
On Linux, :option:`-DCMAKE_INSTALL_PREFIX` is by default set to ``/opt/<provider>/<package>[-<version>]``
and on Windows to ``C:/Program Files/<Provider>/<Package>[-<version>]``.

The advanced :option:`-DBASIS_INSTALL_SCHEME` option specifies how to install the files relative
to this installation prefix. If it is set to ``default`` (the default), BASIS will
decide the appropriate directory structure based on the set installation prefix. On Unix,
if the installation prefix contains the package name, the ``opt`` installation scheme
is selected which skips the addition of subdirectories named after the package within
the different installation subdirectories. This corresponds to the suggested
`Linux Filesystem Hierarchy for Add-on Packages <http://www.pathname.com/fhs/pub/fhs-2.3.html#OPTADDONAPPLICATIONSOFTWAREPACKAGES>`_
, where the installation prefix is set to ``/opt/<package>`` or
``/opt/<provider>/<package>``. Otherwise, the ``usr`` installation scheme
is chosen which will append the package name to each installation directory to avoid
conflicts between software packages installed in the same location. This installation
scheme follows the `Linux Filesystem Hierarchy Standard for /usr <http://www.pathname.com/fhs/pub/fhs-2.3.html#THEUSRHIERARCHY>`_.
Given the installation prefix ``/usr/local``, for example, the package library files
will be installed into ``/usr/local/lib/<package>``. On Windows, the ``win`` scheme
is used which does not add any package specific subdirectories to the installation path
similar to the ``opt`` scheme. Furthermore, the directory names are more Windows-like
and start with a capital letter. For example, the default installation directory for
package library files on Windows given the installation prefix
``C:\Program Files\<Provider>\<Package>`` is ``C:\Program Files\<Provider>\<Package>\Lib``.

If the :option:`-DBASIS_INSTALL_SITE_PACKAGES` option is ``ON``, module libraries written
in a scripting language such as Python or Perl are installed to the system-wide default
directories for site packages of these languages. As this requires write permission to
these directories, this option is disabled by default.

.. note:: The binary executables which are intended to be called by the user are
          copied to the ``bin/`` directory, where no package subdirectory is created
          regardless of the installation scheme. It is in the responsibility of the
          package provider to choose names of the executables that are unique enough
          to avoid conflicts with other available software packages. Auxiliary executables,
          on the other side, i.e., executables which are called by the executables in
          the ``bin/`` directory, are installed in the directory for library files.

The executables and auxiliary files can be installed using either the command::

    make install

or::

    make install/strip

in the top directory of the build tree. The available install targets
copy the files intended for installation to the directories specified during
the configuration step. The ``install/strip`` target additionally strips
installed binary executable and shared object files, which can save disk space.

If more than one version of a software package shall be installed,
include the package version in the installation prefix by setting
:option:`-DCMAKE_INSTALL_PREFIX` to ``/opt/[<provider>/]/<package>[-<version>]``,
for example (the default). Otherwise, you may choose to install the package
in ``/usr/local``, which will by default make the executables in the
``bin/`` directory and the header files available to other packages without
the need to change any environment settings.

Besides the installation of the built files of the software package to the
named locations, the directory where the CMake configuration file of the package
was installed is added to CMake's `package registry`_ if the advanced option
:option:`-DBASIS_REGISTER` is set to ``ON`` (the default). This helps CMake to find the
installed package when used by another software package based on CMake.

After the successful installation, the build tree can be deleted. It should
be verified before, however, that the installation indeed was successful.


.. _InstallEnvironment:

Environment
-----------

.. envvar:: PATH

In order to ease the execution of the main executable files, we suggest to
add the path ``<prefix>/bin/`` to the search path for executable files, i.e.,
the ``PATH`` environment variable. This is, however, generally not required.
It only eases the execution of the command-line tools provided by the software
package.

For example, if you use Bash_ add the following line to the ``~/.bashrc`` file:

.. code-block:: bash

    export PATH="<prefix>/bin:${PATH}"


.. envvar:: PYTHONPATH

To be able to use any provided Python modules of the software package
in your own Python scripts, you need to add the path
``<prefix>/lib/[<package>/]python<version>/`` to the search path for Python
modules if such path exists after installation:

.. code-block:: bash

    export PYTHONPATH=${PYTHONPATH}:/opt/<provider>/<package>-<version>/lib/python2.7

or, alternatively, insert the following code at the top of your Python scripts:

.. code-block:: python

    #! /usr/bin/env python
    import sys
    sys.path.append('/opt/<provider>/<package>-<version>/lib/python2.7')
    from package import module


.. envvar:: PERL5LIB

To be able to use the provided Perl modules of the software package in your own
Perl scripts, you need to add the path ``<prefix>/perl5/`` to the search path for
Perl modules if such path exists after installation:

.. code-block:: bash

    export PERL5LIB=${PERL5LIB}:/opt/<provider>/<package>-<version>/lib/perl5

or, alternatively, insert the following code at the top of your Perl scripts:

.. code-block:: perl

    use lib '/opt/<provider>/<package>-<version>/lib/perl5';
    use Package::Module;


.. _Uninstall:

Uninstall
=========


.. _MakeUninstall:

Makefile-based Uninstall
------------------------

In order to undo the installation of the package files built from the sources,
run the following command in the root directory of the build tree which was
used to install the package:

.. code-block:: bash

    cd ~/$package-build
    make uninstall

.. warning::

    This command will only delete all files which were installed during the
    **last** build of the install target (``make install``).


.. _Deinstallation:

Uninstaller Script
------------------

During the installation, a manifest of all installed files and a CMake
script which reads in this list in order to remove these files again
is generated and installed in ``<prefix>/lib/cmake/<package>/``.

The uninstaller is located in ``<prefix>/bin/`` and named ``uninstall-<package>``.
In order to remove all files installed by this package as well as the empty
directories left behind inside the installation root directory given by ``<prefix>``,
run the command:

.. code-block:: bash

    uninstall-$package

assuming that you added ``<prefix>/bin/`` to your :envvar:`PATH` environment variable.

.. note::

    The advantage of the uninstaller is, that the build tree is no longer
    required in order to uninstall the software package. Thus, you do not
    need to keep a copy of the build tree once you installed the software
    only to be able to uninstall the package again.


.. _APT: http://en.wikipedia.org/wiki/Advanced_Packaging_Tool
.. _Bash: http://www.gnu.org/software/bash/
.. _CentOS: http://www.centos.org/
.. _CMake: http://www.cmake.org/
.. _CMake download page: http://www.cmake.org/cmake/resources/software.html
.. _ccmake: http://www.cmake.org/cmake/help/runningcmake.html
.. _CTest: http://www.cmake.org/cmake/help/v2.8.8/ctest.html
.. _Cygwin: http://www.cygwin.com/
.. _Debian: http://www.debian.org/
.. _Doxygen: http://www.stack.nl/~dimitri/doxygen/
.. _Git: http://git-scm.com/
.. _GNU Make: http://www.gnu.org/software/make/
.. _ninja: http://martine.github.io/ninja/
.. _GNU Compiler Collection: http://gcc.gnu.org/
.. _Clang: http://clang.llvm.org/
.. _LaTeX: http://www.latex-project.org/
.. _Mac OS: http://www.apple.com/macosx/
.. _MATLAB: http://www.mathworks.com/products/matlab/
.. _MATLAB Compiler: http://www.mathworks.com/products/compiler/
.. _MEX: http://www.mathworks.com/help/techdoc/ref/mex.html
.. _MEX-Files: http://www.mathworks.com/help/techdoc/matlab_external/f7667.html
.. _Microsoft Windows: http://windows.microsoft.com/en-US/windows/home
.. _Microsoft Visual Studio: http://www.microsoft.com/visualstudio/en-us
.. _Subversion: http://subversion.apache.org/
.. _openSUSE: http://www.opensuse.org/en/
.. _package registry: http://www.cmake.org/Wiki/index.php?title=CMake/Tutorials/Package_Registry
.. _Red Hat Enterprise Linux: http://www.redhat.com/products/enterprise-linux/
.. _reStructuredText: http://docutils.sourceforge.net/rst.html
.. _Sphinx: http://sphinx.pooco.org/
.. _svn2cl: http://arthurdejong.org/svn2cl
.. _Ubuntu: http://www.ubuntu.com/
.. _VirtualBox: http://www.virtualbox.org
.. _YUM: http://en.wikipedia.org/wiki/Yellowdog_Updater,_Modified
.. _The Open Source Initiative: http://opensource.org/
.. _license: http://www.rad.upenn.edu/sbia/software/license.html
.. _ITK: http://www.itk.org/
.. _MATLAB: http://www.mathworks.com/products/matlab/
.. _MATLAB Compiler: http://www.mathworks.com/products/compiler/
.. _MEX-Files: http://www.mathworks.com/help/techdoc/matlab_external/f7667.html
