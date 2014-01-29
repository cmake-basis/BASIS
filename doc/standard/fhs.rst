.. meta::
    :description: This article defines the filesystem hierarchy standard (FHS) of BASIS,
                  a build system and software implementation standard. The FHS defines
                  the directory structure of the project sources, the build tree, and
                  the installed software files.

=================
Filesystem Layout
=================

This document describes the filesystem hierarchy of BASIS projects, which
is based on the `Filesystem Hierarchy Standard of Linux`_.
It has a goal of supporting:

- Unix and Windows
- Installation of multiple versions of each package on a single system
- Seamless integration of BASIS software packages
- A superproject, or super-build, concept based on a bundle build

Please note that the variable names used below are defined
by BASIS using CMake, and will often refer to particular directories 
of a software project. These variables should be used where possible, 
so that directories can be renamed without breaking the build system.

The :doc:`template` provides a reference implementation of this standard.
See the :doc:`/howto/create-and-modify-project` How-to Guide for details
on how to make use of this template to create a new project which is conform
with the filesystem hierarchy standard detailed in this section.

**Legend**

- ``<project>`` (``<package>``) is a placeholder for the lowercase project (or package) name
- ``<Project>`` is the case-sensitive project name.
- ``<major>``   is the major release number
- ``<minor>``   is the minor update number
- ``<patch>``   is the patch number
- ``<version>`` is a placeholder for the project version string ``<major>.<minor>.<patch>``
- ``<source>``  is the root directory of a particular project source tree
- ``<build>``   is the root directory of the project's build or binary tree

.. _GitRepositoryOrganization:

Source Code Repository
======================

Git 
---

BASIS recommends that `Git <http://git-scm.com/>`_ distributed version control users follow the `nvie git-flow branching model <http://nvie.com/posts/a-successful-git-branching-model/>`_. 
The `Atlassian Gitflow Workflow Tutorial <https://www.atlassian.com/git/workflows#!workflow-gitflow>`_ is another excellent source for this information.

.. _HgRepositoryOrganization:

Mercurial
---------

BASIS recommends that `Mercurial <http://www.mercurial.selenic.com>`_ (hg) distributed version control users follow the hg-flow branching model.
This is identical to the git-flow branching model explained in :ref:`GitRepositoryOrganization`, but uses mercurial as the version control system. The `hg-flow extension <https://bitbucket.org/yujiewu/hgflow/wiki/Home>`_ is useful for assisting with development, but not required.

.. _SVNRepositoryOrganization:

Subversion
----------

Each Subversion_ (SVN) repository contains the top-level directories ``trunk/``,
``branches/``, and ``tags/``. No other directories may be located next to these 
three top-level directories.


The root directory of a development branch, typically the trunk 
(see :ref:`SVNRepositoryOrganization`), is denoted by ``<tag>`` 
and considered relative to the base URL of the project repository. 
The base URL is referred to as ``<url>``.

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

Below the trunk and the release branches a version of the entire source
tree should be present. Other branches below the ``branches/`` directory
may contain a subset of the trunk such as the source code
of the software without the examples and tests.


.. _SourceCodeTree:

Source Code Tree
================

The Soruce Code Tree refers to the filesystem directory structure of all 
source code that is managed by version control. The build and intallation 
trees are separate entities created and populated from the source tree, so
the source tree is essentially the "beating heart" of a software project.

**Source Categories**
Source files can fall under the categories of software, build, configuration, 
documentation, or testing. Any files essential to the execution of the 
software are also considered to be part of the software source. Examples of 
essential files include a pre-computed lookup table and 
a medical image atlas. 

**Documentation**
Examples within a software project are considered 
to be part of both documentation and testing. 

**Testing**
The testing category can be divided into system testing and unit testing. 
It is important to note the difference of system
tests and unit tests. As testing can often require a huge amount of image data, 
these datasets may be stored and managed outside the source tree. 
Please refer to the :doc:`/howto/manage-data` guide for details on this topic.

- **System Tests**
  System tests are usually implemented in
  a scripting language such as Python, Perl, or BASH. System tests simply run
  the built executables with different test input data and compare the output to
  the expected results. Therefore, system tests can also be performed on a
  target system using the installed software where both the software and system
  tests are distributed as separate binary distribution packages. Large data sets, 
  such as medical image data sets in their entirety, should only be required for
  system tests and downsampled to a very low resolution for practical
  reasons whenever possible.

- **Unit Tests**
  Unit tests, provide a specialized test of a single software module such as a C++ class or
  Python module. Generally, the size and amount of additional data required for unit
  tests is kept reasonably small.  The unit tests are compiled into separate executable files called test
  drivers. These executable files are not essential for the functioning of the
  software and are solely build for the purpose of testing.


**Source Code Filesystem Heirarchy**
The filesystem hierarchy of a software project's source tree is defined below.
The names of the CMake variables defined by BASIS are on the left, 
while the actual names of the directories are listed on the right::

    - PROJECT_SOURCE_DIR              - <source>/
        + PROJECT_CODE_DIR                + src/
        + PROJECT_CONFIG_DIR              + config/
        + PROJECT_DATA_DIR                + data/
        + PROJECT_DOC_DIR                 + doc/
        + PROJECT_EXAMPLE_DIR             + example/
        + PROJECT_MODULES_DIR             + modules/
        + PROJECT_TESTING_DIR             + test/
        + PROJECT_SUBDIRS                 + <multiple additonal subdirs>

Here are CMake variables defined in place of the default name for each of the following directories:


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
``PROJECT_SUBDIRS``         List of additional directories for source code files.
=========================   =====================================================


.. _BuildTree:

Build Tree
==========

CMake supports but recommends against in-source builds. Therefore, BASIS
requires that the build tree be outside the source tree. Only the files in
the source tree are considered to be important.

Directories in the build tree are separate from the source tree, 
and they are created and populated when CMake configuration and 
the build step are run.

::

    - PROJECT_BINARY_DIR              - <build>/
        + RUNTIME_OUTPUT_DIRECTORY        + bin/
        + LIBRARY_OUTPUT_DIRECTORY        + lib/
        + ARCHIVE_OUTPUT_DIRECTORY        + lib/
        + TESTING_RUNTIME_DIR             + Testing/bin/
        + TESTING_LIBRARY_DIR             + Testing/lib/
        + TESTING_OUTPUT_DIR              + Testing/Temporary/

Here are CMake variables defined in place of the default name for each of the following directories:

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

The following directory structure is used when installing the software package, 
either by building the install target with "make install",
extracting a binary distribution package, or running an installer.

Different installation hierarchies are defined in order to account 
for different installation schemes depending on the location
and target system on which the software is being installed.

The first installation scheme is referred to as the ``usr`` scheme which is in
compliance with the `Linux Filesystem Hierarchy Standard for /usr <http://www.pathname.com/fhs/pub/fhs-2.3.html#THEUSRHIERARCHY>`_::

    - CMAKE_INSTALL_PREFIX           - <prefix>/
        + INSTALL_CONFIG_DIR             + lib/cmake/<package>/
        + INSTALL_RUNTIME_DIR            + bin/
        + INSTALL_LIBEXEC_DIR            + lib/<package>/
        + INSTALL_LIBRARY_DIR            + lib/<package>/
        + INSTALL_ARCHIVE_DIR            + lib/<package>/
        + INSTALL_INCLUDE_DIR            + include/<package>/
        + INSTALL_SHARE_DIR              + share/
            + INSTALL_DATA_DIR               + <package>/data/
            + INSTALL_DOC_DIR                + doc/<package>/
            + INSTALL_EXAMPLE_DIR            + <package>/example/
            + INSTALL_MAN_DIR                + man/
            + INSTALL_INFO_DIR               + info/

Another common installation scheme, here referred to as the ``opt`` scheme and the
default used by BASIS packages, follows the
`Linux Filesystem Hierarchy Standard for Add-on Packages <http://www.pathname.com/fhs/pub/fhs-2.3.html#OPTADDONAPPLICATIONSOFTWAREPACKAGES>`_::

    - CMAKE_INSTALL_PREFIX           - <prefix>/
        + INSTALL_CONFIG_DIR             + lib/cmake/<package>/
        + INSTALL_RUNTIME_DIR            + bin/
        + INSTALL_LIBEXEC_DIR            + lib/
        + INSTALL_LIBRARY_DIR            + lib/
        + INSTALL_ARCHIVE_DIR            + lib/
        + INSTALL_INCLUDE_DIR            + include/<package>/
        + INSTALL_SHARE_DIR              + share/
            + INSTALL_DATA_DIR               + data/
            + INSTALL_DOC_DIR                + doc/
            + INSTALL_EXAMPLE_DIR            + example/
            + INSTALL_MAN_DIR                + man/
            + INSTALL_INFO_DIR               + info/

The installation scheme for Windows is::

    - CMAKE_INSTALL_PREFIX           - <prefix>/
        + INSTALL_CONFIG_DIR             + CMake/
        + INSTALL_RUNTIME_DIR            + Bin/
        + INSTALL_LIBEXEC_DIR            + Lib/
        + INSTALL_LIBRARY_DIR            + Lib/
        + INSTALL_ARCHIVE_DIR            + Lib/
        + INSTALL_INCLUDE_DIR            + Include/<package>/
        + INSTALL_SHARE_DIR              + Share/
        + INSTALL_DATA_DIR               + Data/
        + INSTALL_DOC_DIR                + Doc/
        + INSTALL_EXAMPLE_DIR            + Example/

In order to install different versions of a software, choose an installation
prefix that includes the package name and software version, for example,
``/opt/<package>-<version>`` (Unix) or ``C:/Program Files/<Package>-<version>`` (Windows).

Note that the directory for CMake package configuration files is chosen such that
CMake finds these files automatically given that the ``<prefix>`` is a system default
location or the ``INSTALL_RUNTIME_DIR`` is in the ``PATH`` environment.

It is important to note that the include directory always contains the package name.
This way, project header files must use an include path that avoids conflicts with 
other packages that use identical header names. Here is a usage example:

.. code-block:: c++

    #include <package/header.h>

Thus, the include directory that is added to the search path must be set
to the ``include/`` directory, but not the ``<package>`` subdirectory.

Here are CMake variables defined in place of the default name for each of the following directories:

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{5cm}|p{10.5cm}|

=========================   ===================================================================
  Directory Variable                                 Description
=========================   ===================================================================
``CMAKE_INSTALL_PREFIX``    Common prefix (``<prefix>``) of installation directories.
                            Defaults to ``/opt/<provider>/<package>-<version>`` on Unix
                            and ``C:/Program Files/<Provider>/<Package>-<version>`` on Windows.
                            All other directories are specified relative to this prefix.
``INSTALL_CONFIG_DIR``      CMake package configuration files.
``INSTALL_RUNTIME_DIR``     Main executables and shared libraries on Windows.
``INSTALL_LIBEXEC_DIR``     Utility executables which are called by other executables only.
``INSTALL_LIBRARY_DIR``     Shared libraries on Unix and module libraries.
``INSTALL_ARCHIVE_DIR``     Static and import libraries on Windows.
``INSTALL_INCLUDE_DIR``     Public header files of libraries.
``INSTALL_DATA_DIR``        Auxiliary data files required for the execution of the software.
``INSTALL_DOC_DIR``         Documentation files including the software manual in particular.
``INSTALL_EXAMPLE_DIR``     All data required to follow example as described in manuals.
``INSTALL_MAN_DIR``         Man pages.
``INSTALL_MAN_DIR/man1/``   Man pages of the executables in ``INSTALL_RUNTIME_DIR``.
``INSTALL_MAN_DIR/man3/``   Man pages of libraries.
``INSTALL_SHARE_DIR``       Shared package files including required auxiliary data files.
=========================   ===================================================================


.. _Filesystem Hierarchy Standard of Linux: http://www.pathname.com/fhs/pub/fhs-2.3.html
.. _Subversion: http://subversion.apache.org/
