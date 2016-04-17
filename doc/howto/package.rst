.. meta::
    :description: This BASIS how-to describes the packaging of BASIS-based
                  software for distribution.

==================
Packaging Software
==================

This document describes the packaging of BASIS projects.


.. _GenerateSourcePackage:

Distribution of Sources
=======================

A source package for distribution which only includes basic tests and
selected modules can be generated using CPack_. In particular, the build target
``package_source`` is used to generate a ``.tar.gz`` file with the source
files of the distribution package. This package will include all source
files except those which match one of the patterns in the
``CPACK_SOURCE_IGNORE_FILES`` CMake list which is set to common default
patterns in the `BasisPack.cmake`_ module. Additional exclude patterns for
a particular package shall be added to the ``Settings.cmake`` file of the
project. Moreover, if the project contains different
:doc:`modules </standard/modules>`, only the enabled modules are included.
For general steps on how to configure a build tree, see the
:ref:`common build instructions <HowToBuildTheSoftware>`. Given a configured build
tree with a generated ``Makefile``, run the following command to generate the source
distribution package::

    make package_source


.. _CPack: http://www.cmake.org/cmake/help/cpack-2-8-docs.html
.. _BasisPack.cmake: https://cmake-basis.github.io/apidoc/latest/BasisPack_8cmake.html
