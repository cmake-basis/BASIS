.. title:: About

=================
About CMake BASIS
=================

.. _History:

History
=======

The CMake BASIS project was started early in 2011 to improve and standardize software
packages developed at the `Section of Biomedical Image Analysis (SBIA) <http://www.cbica.upenn.edu/sbia/>`__
of the `University of Pennsylvania <http://www.upenn.edu/>`__. It started with the decision 
to use CMake_ as a build system which has been greatly extended using custom CMake
macros and functions and the implementation of a standardized project template.
The initial idea was to provide a project template based on CMake which would 
standardize the project directory structure as well as the software build. This 
project template would allow the developers to concentrate on actual software 
development rather than on deciding upon the directory structure, the directory names, 
and the basic CMake configuration. Over time, these components were transformed into 
important parts of the CMake BASIS package.

Purpose
=======

The CMake BASIS software package documents and implements a standard for 
project organization, software build, implementation and documentation. 
We aim to provide a comprehensive way to streamline software development.
 
CMake BASIS includes a software development standard, a :doc:`/standard/template` 
implementing the :doc:`standard/fhs`, `CMake Modules`_ which not only follow the Filesystem 
Hierarchy Standard, but also implement the build system standard as well as the 
standard for testing and packaging software developed using BASIS.

CMake BASIS provides basic `utility functions`_ for each
supported programming language which implement certain aspects of the 
:doc:`software implementation standard <standard>` such as the calling 
conventions on how to execute subprocesses and the parsing of command-line 
arguments. Where possible, these utility implementations were adopted from 
other open source software projects and integrated with BASIS.

.. include:: people.rst

.. _CMake: http://www.cmake.org
.. _`CMake Modules`: https://cmake-basis.github.io/apidoc/latest/group__BasisModules.html
.. _`utility functions`: https://cmake-basis.github.io/apidoc/latest/group__BasisUtilities.html
