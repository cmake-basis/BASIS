=============================
Filesystem Hierarchy Standard
=============================

This document describes the filesystem hierarcy of projects following the
Build system And Software Implementation Standard (BASIS). This standard
is in particular based on the `Filesystem Hierarchy Standard of Linux`_.
The configuration of the installation is further designed such that it is
possible to account for the differences in both Unix and Windows systems as
well as the installation of multiple versions of each package. Furthermore,
the directory structure by default integrates software developed at SBIA not
only seamlessly into the target system but also the various separately managed
SBIA software packages with each other. The latter can in particular be
employed by a superproject concept based on a super-build.

In this document, names of CMake variables defined by the BASIS modules are
given. These are used within the CMake modules to refer to the particular
directories of a software project. These variables should be used either
directly or indirectly where possible such that a change of the actual
directory names does not require a modification of the software itself.

The BASIS Filesystem Hierarchy Standard is in particular implemented by
the :doc:`template`, which is the template for any software project
which follows BASIS. See the :doc:`/howto/create-and-modify-project`
guide for details on how to create a new project which complies with this
Filesystem Hierarchy Standard.


Legend
======

In the reminder, ``<project>`` is a placeholder for the project name in lowercase
letters only and ``<Project>`` is the case-sensitive project name.
 
Further, ``<version>`` is a placeholder for the project version string
``<major>.<minor>.<patch>``, where ``<major>`` is the major version number,
``<minor>`` the minor version number, and ``<patch>`` the patch number.

The root directory of a particular project source tree is denoted by ``<source>``,
while the root directory of the project binary tree is referred to as ``<build>``.
Note that each software project consists of more than one project components
(not identical to, but related with software package components).
Each component can be downloaded, configured, build, and installed separately.
See design-components file and section Source Tree for details.

The root directory of a development branch such as in particular the trunk
(see :ref:`RepositoryOrganization`), is considered relative to the base URL
of the project repository and denoted by ``<tag>``, while the base URL is
referred to as ``<url>``.


.. _RepositoryOrganization:

Repository Organization
=======================

Each Subversion_ (SVN) repository contains the top-level directories ``trunk/``,
``branches/``, and ``tags/``. No other directories may be located next to these three
top-level directories.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{7.25cm}|p{8.25cm}|

=======================================   ========================================================
             Repository Path                                    Description
=======================================   ========================================================
``trunk/``                                The current development version of the project.
                                          Most development is done in this master branch.
``branches/<name>/``                      Separate branches named ``<name>`` are developed in
                                          subdirectories under the branches directory. One
                                          reason for branching is, for example, to develop
                                          new features separate from the main development
                                          branch, i.e., the trunk, and merging the desired
                                          changes back to the trunk once the new feature is
                                          implemented and tested.
``branches/<project>-<major>.<minor>/``   This particular branch is used prior to releasing
                                          a new version of the project. This branch is
                                          commonly referred to as release candidate of version
                                          ``<major>.<minor>`` of the project. It is used to adjust
                                          the project files prior to tagging a particular release.
                                          For example, to set the correct version number in the
                                          project files. This branch is further be used to apply
                                          bug fixes to a previous release of this version, in
                                          which case the patch number has to be increased before
                                          tagging a new release of this software version.
                                          See the :doc:`/howto/branch-and-release` guide for
                                          further details.
``tags/<project>-<version>/``             Tagged release version of the project. The reason for
                                          including the project name in the name of the tagged
                                          branch is, that SVN uses the last URL part as name for
                                          the directory to which the URL's content is checked out
                                          or exported to if no name for this directory is specified.
=======================================   ========================================================

See the :doc:`/howto/branch-and-release` guide for details on how to create
new branches and the process of releasing a new version of a software project.

Underneath the trunk and the release branches, a version of the entire source
tree has to be found. Other branches underneath the ``branches/`` directory
may only contain a subset of the trunk such as, for example, only the source code
of the software but not the example or tests.


.. _SourceTree:

Source Tree
===========

The directory structure of the source tree, i.e., the directories and files
which are managed in a revision controlled repository, is summarized in what
follows. Other than the build and intallation tree, which are created and
populated from the source tree, is the source tree even because of this the
beating heart of a software project. The directories and files in the source
tree can be classified into the following categories: software, build
configuration, documentation, and testing. The example which is part of a
software project is considered to be part of both documentation and testing.
Furthermore, any files essential to the execution of the software are
considered to be part of the software. Examples are a pre-computed lookup
table and a medical image atlas.
 
The testing at SBIA can further be divided into two subcategories: system
testing and unit testing. It is important to note the difference of system
tests and unit tests. Most often, only system tests will be performed due to
the research character of the projects. These tests are usually implemented in
a scripting language such as Python, Perl, or BASH. System tests simply run
the built executables with different test input data and compare the output to
the expected results. Therefore, system tests can also be performed on a
target system using the installed software where both the software and system
tests are distributed as separate binary distribution packages. Unit tests,
on the other side, only test a single software module such as a C++ class or
Python module, for example. The size of the  additional data required for unit
tests shall be reasonably small. Entire medical image data sets should only be
required for system tests. The unit tests are compiled into separate executable
files called test drivers. These executable files are not essential for the
functioning of the software and are solely build for the purpose of testing.

As the testing as well as the example in the field of medical imaging often
requires a huge amount of image data, these datasets are stored and managed
outside the source tree. Please refer to the :doc:`/howto/manage-data` guide
for details on this topic.


Filesystem Hierarchy
--------------------

Below, the filesystem hierarchy of the source tree of a software project is
delineated. On the left side the names of the CMake variables defined by
BASIS are given, while on the right side the actual names of the directories
are listed::

    - PROJECT_SOURCE_DIR              - <source>/
        + PROJECT_CODE_DIR                + src/
        + PROJECT_CONFIG_DIR              + config/
        + PROJECT_DATA_DIR                + data/
        + PROJECT_DOC_DIR                 + doc/
        + PROJECT_EXAMPLE_DIR             + example/
        + PROJECT_MODULES_DIR             + modules/
        + PROJECT_TESTING_DIR             + test/

Following a description of the directories, where the names of the CMake
variables defined by BASIS are used instead of the actual directory names:


=========================   =====================================================
   Directory Variable                        Description
=========================   =====================================================
``PROJECT_SOURCE_DIR``      Root directory of source tree.
``PROJECT_CODE_DIR``        All source code files.
``PROJECT_CONFIG_DIR``      BASIS configuration files.
``PROJECT_DATA_DIR``        Software configuration files including auxiliary data
                            such as medical atlases.
``PROJECT_DOC_DIR``         Software documentation.
``PROJECT_EXAMPLE_DIR``     Example application of software.
``PROJECT_MODULES_DIR``     :doc:`Project Modules <modules>`, each residing in
                            its own subdirectory.
``PROJECT_TESTING_DIR``     Implementation of tests and test data.
=========================   =====================================================


.. _BuildTree:

Build Tree
==========

Even though CMake supports in-source tree builds, BASIS permits this and
requires that the build tree is outside the source tree. Only the files in
the source tree are considered of importance.

In the following, only the directories which do not reflect the source
tree are considered as these directories are created and populated by
CMake itself.


Filesystem Hierarchy
--------------------

::

    - PROJECT_BINARY_DIR              - <build>/
        + RUNTIME_OUTPUT_DIRECTORY        + bin/
        + LIBRARY_OUTPUT_DIRECTORY        + lib/
        + ARCHIVE_OUTPUT_DIRECTORY        + lib/
        + TESTING_RUNTIME_DIR             + Testing/bin/
        + TESTING_LIBRARY_DIR             + Testing/lib/
        + TESTING_OUTPUT_DIR              + Testing/Temporary/

Following a description of the directories, where the names of the CMake
variables defined by BASIS are used instead of the actual directory names:

============================   ================================================
    Directory Variable                         Description
============================   ================================================
``RUNTIME_OUTPUT_DIRECTORY``   All executables and shared libraries (Windows).
``LIBRARY_OUTPUT_DIRECTORY``   Shared libraries (Unix).
``ARCHIVE_OUTPUT_DIRECTORY``   Static libraries and import libraries (Windows).
``TESTING_RUNTIME_DIR``        Directory of test executables.
``TESTING_LIBRARY_DIR``        Directory of libraries only used for testing.
``TESTING_OUTPUT_DIR``         Directory used for test results.
============================   ================================================


.. _InsallationTree:

Installation Tree
=================

When installing the software package by building either the install target,
extracting a binary distribution package, or running an installer of a binary
distribution package, the following directory structure is used.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{3cm}|p{12.5cm}|

==================   ======================================================
     Option                           Description
==================   ======================================================
``INSTALL_PREFIX``   Installation directories prefix (``<prefix>``).
                     Defaults to ``/usr/local`` on Unix-like systems
                     and ``C:\Program Files\SBIA`` on Windows.
                     Note that this variable is initialized by the value
                     of ``CMAKE_INSTALL_PREFIX``, the default variable used
                     by CMake. Once it is initialized, the value of CMake's
                     ``CMAKE_INSTALL_PREFIX`` variable is forced to always
                     reflect the value of this variable.
``INSTALL_SINFIX``   Installation directories suffix or infix, respectively
                     (``<sinfix>``). Defaults to ``@PROJECT_NAME_LOWER@``.

==================   ======================================================

In order to install different versions of a software, choose an installation
prefix that includes the package name and software version, for example,
``/usr/local/@PROJECT_NAME_LOWER@-@PROJECT_VERSION@``. In this case,
``INSTALL_SINFIX`` should be set to an empty string.


Filesystem Hierarchy
--------------------

Based on above options, the installation directories are set as follows::

    - INSTALL_PREFIX                 - <prefix>/
        + INSTALL_CONFIG_DIR             + lib/cmake/<sinfix>/ (Unix) | cmake/ (Windows)
        + INSTALL_RUNTIME_DIR            + bin/<sinfix>/
        + INSTALL_LIBEXEC_DIR            + lib/<sinfix>/ | bin/<sinfix>/ (Windows)
        + INSTALL_LIBRARY_DIR            + lib/<sinfix>/
        + INSTALL_ARCHIVE_DIR            + lib/<sinfix>/
        + INSTALL_INCLUDE_DIR            + include/sbia/<project>/
        + INSTALL_SHARE_DIR              + share/
            + INSTALL_DOC_DIR                + <sinfix>/doc/
            + INSTALL_EXAMPLE_DIR            + <sinfix>/example/
            + INSTALL_MAN_DIR                + <sinfix>/man/

Note that the include directory by intention always ends in ``sbia/<project>``,
such that header files of a project have to be included as follows:

.. code-block:: c++

    #include <sbia/<project>/header.h>

Hence, the include directory which is added to the search path has to be set
to ``<prefix>/include/``.

Following a description of the directories, where the names of the CMake
variables defined by BASIS are used instead of the actual directory names:

=========================   ===================================================================
  Directory Variable                                 Description
=========================   ===================================================================
``INSTALL_CONFIG_DIR``      CMake package configuration files.
``INSTALL_RUNTIME_DIR``     Main executables and shared libraries on Windows.
``INSTALL_LIBEXEC_DIR``     Utility executables which are called by other executables only.
``INSTALL_LIBRARY_DIR``     Shared libraries on Unix and module libraries.
``INSTALL_ARCHIVE_DIR``     Static and import libraries on Windows.
``INSTALL_INCLUDE_DIR``     Public header files of libraries.
``INSTALL_DOC_DIR``         Documentation files including the software manual in particular.
``INSTALL_EXAMPLE_DIR``     All data required to follow example as described in manuals.
``INSTALL_MAN_DIR``         Man pages are installed to this directory.
``INSTALL_MAN_DIR/man1/``   Man pages of main executables.
``INSTALL_MAN_DIR/man3/``   Man pages of libraries.
``INSTALL_SHARE_DIR``       Shared package files including required auxiliary data files.
=========================   ===================================================================


Links
-----

On Unix, the following symbolic links are created when the option ``INSTALL_LINKS``
is set to ``ON``. Note that the link creation will fail if a file or directory with
the links' name already exists. This is desired and will simply be reported to the
user. If a symbolic name of the same name already exists, it is replaced however.

.. The tabularcolumns directive is required such that table is not too wide in PDF.

.. tabularcolumns:: |p{6.8cm}|p{8.7cm}|

=====================================   ==============================================
                Link                                    Target
=====================================   ==============================================
``<prefix>/bin/<exec>``                 ``INSTALL_RUNTIME_DIR/<exec>``
``<prefix>/share/doc/<sinfix>/``        ``INSTALL_DOC_DIR``
``<prefix>/share/man/man.?/<name>.?``   ``INSTALL_MAN_DIR/man.?/<name>.?``
=====================================   ==============================================

.. _Filesystem Hierarchy Standard of Linux: http://proton.pathname.com/fhs/
.. _Subversion: http://subversion.tigris.org/
