======================
Build and Installation
======================

This document describes the common procedure to build and install any
software developed at and distributed by SBIA. In particular, software built
on top of BASIS, a meta-project which defines the Build system And Software
Implementation Standard established in the fall of 2011. See the
:doc:`/index` page for details on this meta-project.

If you obtained a binary distribution package for a supported platform,
please follow the installation instructions corresponding to your operating
system. The build step can be omitted in this case.

In case of problems to build, install, or use the software, please contact
the SBIA Group at the University of Pennsylvania, PA, at
``sbia-software at uphs.upenn.edu``.

.. note::

    The commands given in this guide have to be entered in a terminal, in particular,
    the Bourne Again Shell (BASH_). If you are not using the BASH, see the
    documentation of your particular shel for information on how to perform these
    actions using this shell instead.


.. _ObtainingTheSoftware:

Get a Copy
==========

Visit the `SBIA homepage <http://www.rad.upenn.edu/sbia/software/index.html>`_
for an overview of publicly available software distribution packages. For each of these
packages, download links of the available distribution packages can be requested by
submitting `this form <http://www.rad.upenn.edu/sbia/software/request.php>`_
with a valid email address. An email with the respective download links will be
sent to you automatically. If you do not receive an email within 24 hours, please
contact the SBIA Group at ``sbia-software at uphs.upenn.edu``.

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

Currently, `Microsoft Windows`_ is not supported as operating system. The software
development at SBIA is based on Linux, in particular CentOS_, and most software
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
is referred to as BASH_ variable:

.. code-block:: bash

    pkg=<package>-<version>


.. _BasisBuildDependencies:

Prerequisites
-------------

The following software packages are prerequisites for any software that is based on BASIS.
When you are building BASIS itself, the dependency on BASIS is obviously already fulfilled.
Furthermore, the stated package versions are the minimum versions for which it is known that
the software is working with. Newer version will usually be fine as well if not otherwise
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
|                            |           | the packing, build, testing, and installation. Refer to the   |
|                            |           | ``INSTALL`` document of the software package you want to      |
|                            |           | build for information on which particular BASIS version is    |
|                            |           | required by this package.                                     |
+----------------------------+-----------+---------------------------------------------------------------+
| `GNU Make`_                |           |  The standard CMake generator used on Unix-like systems.      |
+----------------------------+-----------+---------------------------------------------------------------+
| `GNU Compiler Collection`_ |           |  The standard compiler collection used on Unix-like systems.  |
+----------------------------+-----------+---------------------------------------------------------------+


Optional Packages
~~~~~~~~~~~~~~~~~

The packages named in the following table are used only if installed on your system, but their presence
is general no requirement and you will likely be able to use the basic components of the software without
these. See the ``INSTALL`` file of the software package for details and which packages are indeed made
use of or required by this software.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{3.75cm}|m{1.5cm}|p{9.8cm}|

+----------------------------+-----------+---------------------------------------------------------------+
| Package                    | Version   | Description                                                   |
+============================+===========+===============================================================+
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
| Doxygen_                   | 1.5.9     | This tools is required for the generation of the API          |
|                            |           | documentation from in-source comments in C++, CMake, BASH,    |
|                            |           | Python, and Perl.                                             |
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


.. _ExtractSources:

Extract sources
---------------

At first, extract the downloaded source package, e.g.:

.. code-block:: bash

    tar xzf $pkg-source.tar.gz ~

This will extract the sources to a new diretory in your home directory
named "<package>-<version>-source".


.. _ConfigureBuildTree:

Configure
---------

Create a directory for the build tree of the package and change to it, e.g.:

.. code-block:: bash

    mkdir ~/$pkg-build
    cd ~/$pkg-build

.. note::

    An in-source build, i.e., building the software within the source tree
    is not supported to force a clear separation of source and build tree.

To configure the build tree, run CMake's graphical tool ccmake_:

.. code-block:: bash

    ccmake ~/$pkg-source

Press ``c`` to trigger the configuration step of CMake. Warnings can be ignored by
pressing ``e``. Once all CMake variables are configured properly, which might require
the repeated execution of CMake's configure step, press ``g``. This will generate the
configuration files for the selected build tool (i.e., GNU Make Makefiles in our case)
and exit CMake.

Variables which specify the location of other required or optionally used packages
if available are named ``<Pkg>_DIR``. These variables usually have to be set to the
directory which contains a file named ``<Pkg>Config.cmake`` or ``<pkg>-config.cmake``.
Alternatively, or if the package does not provide such CMake package configuration
file, the installation prefix, i.e., root directory should be specified. See the
build instructions of the particular software package you are building for more
details on the particular ``<Pkg>_DIR`` variables that may have to be set if the
packages were not found automatically by CMake.

Common configuration options are:

.. option:: BASIS_DIR <dir>

    Directory where the ``BASISConfig.cmake`` file is located. Alternatively, the
    installation prefix used to install BASIS can be specified instead.

.. option:: BUILD_DOCUMENTATION ON|OFF

    Whether build and installation instructions for the documentation should
    be added. If OFF, the build configuration of the doc/ directory is skipped.
    Otherwise, the "doc" target is added which is used to build the documentation.

.. option:: BUILD_EXAMPLE ON|OFF

    Whether the examples should be built (if required) and/or installed.

.. option:: BUILD_TESTING ON|OFF

    Whether the testing tree should be built and system tests, i.e., tests
    that execute the installed programs and compare the outputs to the expected
    results should be installed (if done so by the software package).

.. option:: CMAKE_BUILD_TYPE Debug|MinSizeRel|RelWithDebInfo|Release

    Specify the build configuration to build. If not set, the "Release"
    configuration will be build.

.. option:: INSTALL_PREFIX <dir>

    Prefix used for package :ref:`installation <InstallBuiltFiles>`.

.. note::

    The ``INSTALL_PREFIX`` option is initialized by the value of
    CMAKE_INSTALL_PREFIX_, the default used by CMake to specify the installation
    prefix. Then, the value of ``CMAKE_INSTALL_PREFIX`` is forced to be identical
    to ``INSTALL_PREFIX``, effectively renaming ``CMAKE_INSTALL_PREFIX`` to
    ``INSTALL_PREFIX``.

.. option:: INSTALL_SINFIX ON|OFF

    Whether to use suffix/infix for :ref:`installation <InstallBuiltFiles>`.

.. option:: USE_<Pkg> ON|OFF

    If the software you are building has declared optional dependencies,
    i.e., software packages which it makes use of if available, for each
    such optional package a ``USE_<Pkg>`` option is added by BASIS if this
    package was found on your system. It can be set to OFF in order to disable
    the use of this optional dependency by this software.

The advanced configuration options are:

.. option:: BASIS_ALL_DOC ON|OFF

    Request the build of all documentation targets as part of the ``ALL`` target
    if ``BUILD_DOCUMENTATION`` is ``ON``.

.. option:: BASIS_COMPILE_SCRIPTS ON|OFF

    Enable compilation of Python modules. If this option is enabled, only the
    compiled ``.pyc`` files are installed.

.. option:: BASIS_DEBUG ON|OFF

    Enable debugging messages during build configuration.

.. option:: BASIS_INSTALL_SINFIX <sinfix>

    The sinfix to use for the installation if ``INSTALL_SINFIX``
    is set to ``ON``. Otherwise, this values is ignored.

.. option:: BASIS_MCC_FLAGS <flags separated by space>

    Additional flags for MATLAB Compiler.

.. option:: BASIS_MCC_MATLAB_MODE ON|OFF

    Whether to call the MATLAB Compiler in MATLAB mode. If ``ON``, the MATLAB Compiler
    is called from within a MATLAB interpreter session, which results in the
    immediate release of the MATLAB Compiler license once the compilation is done.
    Otherwise, the license is reserved for a fixed amount of time (e.g. 30 min).

.. option:: BASIS_MCC_RETRY_ATTEMPTS <int>

    Number of times the compilation of MATLAB Compiler target is repeated in case
    of a license checkout error.

.. option:: BASIS_MCC_RETRY_DELAY <int>

    Delay in seconds between retries to build MATLAB Compiler targets after a
    license checkout error has occurred.

.. option:: BASIS_MCC_TIMEOUT <int>

    Timeout in seconds for the build of a MATLAB Compiler target. If the build
    of the target could not be finished within the specified time, the build is
    interrupted.

.. option:: BASIS_MEX_FLAGS <flags separated by space>

    Additional flags for the MEX script.

.. option:: BASIS_MEX_TIMEOUT <int>

    Timeout in seconds for the build of MEX-files.

.. option:: BASIS_REGISTER ON|OFF

    Whether to register installed package in CMake's `package registry`_. This option
    is enabled by default such that packages are found by CMake when required by other
    packages based on this build tool.

.. option:: BASIS_VERBOSE ON|OFF

    Enable verbose messages during build configuration.

.. option:: BUILD_CHANGELOG ON|OFF

    Request build of ChangeLog as part of the ``ALL`` target. Note that the ChangeLog
    is generated either from the Subversion_ history if the source tree is a SVN
    working copy, or from the Git history if it is a Git_ repository. Otherwise,
    the ChangeLog cannot be generated and this option is disabled again by BASIS.
    In case of Subversion, be aware that the generation of the ChangeLog takes
    several minutes and may require the input of user credentials for access to the
    Subversion repository. It is recommended to leave this option disabled and to
    build the "changelog" target separate from the rest of the software package
    instead (see :ref:`Build`).

.. option:: INSTALL_APIDOC_DIR <dir>

    Installation directory of the API documentation relative to the ``INSTALL_PREFIX``.

.. option:: INSTALL_SITE_DIR <dir>

    Installation directory of the web site relative to the ``INSTALL_PREFIX``.

.. option:: INSTALL_LINKS ON|OFF

    Whether (symbolic) links should be created (see step 5).

Please refer also to the package specific build instructions given in the
``INSTALL`` file of the corresponding package which is located in the top directory
of the source tree. In this document, additional project specific configuration options
are document if existent.

.. note::
    The ccmake_ tool also provides a brief description to each variable in the status bar.


.. _Build:

Build
-----

To build the executables and libraries, run GNU Make in the root directory of
the configured build tree::

    make

In order to build the documentation, the ``BUILD_DOCUMENTATION`` option
has to be set to ``ON``. If not done before, this option can be enabled using
the command:

.. code-block:: bash

    cmake -D BUILD_DOCUMENTATION:BOOL=ON ~/$pkg-build

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

The advanced ``INSTALL_APIDOC_DIR`` configuration option can be set to an
absolute path or a path relative to the ``INSTALL_PREFIX`` directory in order
to modify the installation directory for the API documentation which is
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
Optionally, the advanced ``INSTALL_SITE_DIR`` configuration option can be
set to an absolute path or a path relative to the ``INSTALL_PREFIX`` directory
in order to modify the installation directory for the generated web site.
This can be useful, for example, to install the web site in the document
directory of a web server.

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

    ctest -V >& $pkg-test.log

and attach the file ``$pkg-test.log`` to the issue report.

.. note::
    If the software package does not include tests, follow the steps in the
    software manual to test the software manually with the provided example
    dataset.


.. _InstallBuiltFiles:

Install
-------

First, make sure that the CMake configuration option ``INSTALL_PREFIX`` and
``INSTALL_SINFIX`` are set properly by running CMake:

.. code-block:: bash

    cmake -D "INSTALL_PREFIX:PATH=<prefix>" -D "INSTALL_SINFIX:BOOL=ON|OFF" ~/$pkg-build

This can be omitted if these variables were set already during the
configuration of the build tree or if the default values should be used.
On Linux, ``INSTALL_PREFIX`` is by default set to ``/usr/local``. Note that the
following strings can be used in the specification of this variable which
will be substituted by the corresponding package specific values.

===========================   ================================================
         Pattern                            Description
===========================   ================================================
``@PROJECT_NAME@``            The case-sensitive name of the software package.
``@PROJECT_NAME_UPPER@``      The name of the package in uppercase only.
``@PROJECT_NAME_LOWER@``      The name of the package in lowercase only.
``@PROJECT_VERSION@``         The package version.
``@PROJECT_VERSION_MAJOR@``   The major number of the package version.
``@PROJECT_VERSION_MINOR@``   The minor number of the package version.
``@PROJECT_VERSION_PATCH@``   The patch number of the package version.
===========================   ================================================

After the package was configured successfully, the executables and
auxiliary files can be installed using the either the command::

    make install

or::

    make install/strip

in the top directory of the build tree. The available install targets
copy the files intended for installation to the directories specified during
the configuration step. The ``install/strip`` target additionally strips
installed binary executable and shared object files, which can save disk space.
 
The package files are installed in the following locations on Unix:

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{7.3cm}|p{8.2cm}|

=======================================   =========================================
           Directory                              Installed Files
=======================================   =========================================
``<prefix>/bin/<sinfix>/``                Main executable files.
``<prefix>/etc/<sinfix>/``                Package configuration files.
``<prefix>/include/sbia/<package>/``      Include files, where ``<prefix>/include/``
                                          needs to be in the includes search path.
``<prefix>/lib/<sinfix>/``                Libraries and auxiliary executables.
``<prefix>/lib/cmake/<package>/``         CMake package configuration files.
``<prefix>/lib/python/sbia/<package>/``   Python modules.
``<prefix>/lib/perl5/SBIA/<Package>/``    Perl modules.
``<prefix>/share/<sinfix>/doc/``          Package documentation files.
``<prefix>/share/<sinfix>/example/``      Example files used by software manual.
``<prefix>/share/<sinfix>/man/man.1/``    Man pages of main executables.
``<prefix>/share/<sinfix>/man/man.3/``    Man pages of library files.
=======================================   =========================================

where <prefix> is the value of ``INSTALL_PREFIX`` and <sinfix> is an empty
string if ``INSTALL_SINFIX`` is OFF and the package name in lowercase otherwise
preceded by the common infix ``sbia/`` (the default).

Additionally, if both ``INSTALL_SINFIX`` and ``INSTALL_LINKS`` are ``ON`` (the default),
the following (symbolic) links are created:

.. The tabularcolumns directive is required such that table is not too wide in PDF.

.. tabularcolumns:: |p{6.8cm}|p{8.7cm}|

=====================================   ==============================================
                Link                                    Target
=====================================   ==============================================
``<prefix>/bin/<exec>``                 ``<prefix>/bin/<sinfix>/<exec>``
``<prefix>/share/man/man.1/<exec>.1``   ``<prefix>/share/<sinfix>/man/man.1/<exec>.1``
``<prefix>/share/man/man.3/<func>.3``   ``<prefix>/share/<sinfix>/man/man.3/<func>.3``
=====================================   ==============================================

On Windows, the installation directories are named as follows instead:

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{8.2cm}|p{7.3cm}|

===========================================   =========================================
              Directory                                Installed Files
===========================================   =========================================
``<prefix>/Bin/<sinfix>/``                    Main executable files.
``<prefix>/CMake/``                           CMake package configuration files.
``<prefix>/Config/<sinfix>/``                 Package configuration files.
``<prefix>/Include/sbia/<package>/``          Include files, where ``<prefix>/include/``
                                              needs to be in the includes search path.
``<prefix>/Library/<sinfix>/``                Libraries and auxiliary executables.
``<prefix>/Library/Python/sbia/<package>/``   Python modules.
``<prefix>/Library/Perl5/SBIA/<Package>/``    Perl modules.
``<prefix>/Doc/<sinfix>/``                    Package documentation files.
``<prefix>/Example/<sinfix>/``                Example files used by software manual.
``<prefix>/Share/<sinfix>/``                  Shared files of this software package.
===========================================   =========================================

where <sinfix> is an empty string if ``INSTALL_SINFIX`` is OFF and the package
name otherwise (the default).

If more than one version of a software package shall be installed,
include the package version in the <prefix> by setting ``INSTALL_PREFIX``
to ``/usr/local/@PROJECT_NAME_LOWER@-@PROJECT_VERSION@``, for example,
and disable the use of the <sinfix> by setting ``INSTALL_SINFIX`` to OFF.

Besides the installation of the built files of the software package to the
named locations, the directory where the CMake configuration file of the package
was installed is added to CMake's `package registry`_ if the advanced option
``BASIS_REGISTER`` is set to ``ON`` (the default). This helps CMake to find the
installed package when used by another software package based on CMake.

After the successful installation, the build tree can be deleted. It should
be verified before, however, that the installation indeed was successful.


.. _InstallEnvironment:

Environment
-----------

In order to ease the execution of the main executable files, we suggest to
add either the path ``~/$pkg-build/bin/`` or ``<prefix>/bin/`` to the search
path for executable files, i.e., the ``PATH`` environment variable. This is,
however, generally not requirement for the correct functioning of the software.

For example, if you use BASH_ add the following line to the ``~/.bashrc`` file:

.. code-block:: bash

    export PATH="<prefix>/bin/:<prefix>/bin/<sinfix>/:${PATH}"

To be able to use the provided Python modules of the software package if any
in your own Python scripts, you need to add the path ``<prefix>/python/``
to the search path for Python modules, e.g.:

.. code-block:: bash

    export PYTHONPATH="${PYTHONPATH}:<prefix>/lib/python/"

or in your Python script:

.. code-block:: python

    #! /usr/bin/env python
    import sys
    sys.path.append('<prefix>/lib/python/')
    from sbia.package import module

To be able to use the provided Perl modules of the software package if any
in your own Perl scripts, you need to add the path <prefix>/perl5/ to
the search path for Perl modules, e.g.:

.. code-block:: bash

    export PERL5LIB="${PERL5LIB}:<prefix>/lib/perl5/"

or in your Perl script:

.. code-block:: perl

    use lib '<prefix>/lib/perl5';
    use SBIA::Package::Module;


.. _Uninstall:

Deinstallation
==============


.. _MakeUninstall:

Makefile-based Deinstallation
-----------------------------

In order to undo the installation of the package files built from the sources,
run the following command in the root directory of the build tree which was
used to install the package:

.. code-block:: bash

    cd ~/$pkg-build
    make uninstall

.. warning::

    With the current implementation, this command will simply delete all the
    files which were installed during the **last** build of the install target
    (``make install``).


.. _Deinstallation:

Uninstaller Script
------------------

During the installation, a manifest of all installed files and a CMake
script which reads in this list in order to remove these files again
is generated and installed in ``<prefix>/lib/cmake/$pkg/``.

If ``INSTALL_SINFIX`` was set to ``ON`` during the installation, a shell script
named ``uninstall`` was written to the ``<prefix>/bin/<sinfix>/``
directory on Unix and a corresponding Batch file on Windows. Additionally,
if ``INSTALL_LINKS`` was set to ``ON``, a symbolic link named ``uninstall-$pkg``
was created in ``<prefix>/bin/``. Otherwise, if ``INSTALL_SINFIX`` was set
to ``OFF``, the uninstaller is located in ``<prefix>/bin/`` and named
``uninstall-$pkg``.

Hence, in order to remove all files installed by this package as well
as the empty directories left behind inside the installation root directory
given by ``<prefix>``, run the command:

.. code-block:: bash

    uninstall-$pkg

assuming that you added ``<prefix>/bin/`` to your ``PATH`` environment variable.

.. note::

    The advantage of the uninstaller is, that the build tree is no longer
    required in order to uninstall the software package. Thus, you do not
    need to keep a copy of the build tree once you installed the software
    only to be able to uninstall the package again.


.. _APT: http://en.wikipedia.org/wiki/Advanced_Packaging_Tool
.. _BASH: http://www.gnu.org/software/bash/
.. _CentOS: http://www.centos.org/
.. _CMake: http://www.cmake.org/
.. _CMake download page: http://www.cmake.org/cmake/resources/software.html
.. _ccmake: http://www.cmake.org/cmake/help/runningcmake.html
.. _CTest: http://www.cmake.org/cmake/help/v2.8.8/ctest.html
.. _CMAKE_INSTALL_PREFIX: http://www.cmake.org/cmake/help/v2.8.8/cmake.html#variable:CMAKE_INSTALL_PREFIX
.. _Cygwin: http://www.cygwin.com/
.. _Debian: http://www.debian.org/
.. _Doxygen: http://www.stack.nl/~dimitri/doxygen/
.. _Git: http://git-scm.com/
.. _GNU Make: http://www.gnu.org/software/make/
.. _GNU Compiler Collection: http://gcc.gnu.org/
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
