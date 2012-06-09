.. title:: Home

=====
BASIS
=====

Overview
========

The Build system And Software Implementation Standard (BASIS) project was
started early in 2011 in order to improve and standardize the software packages
developed at SBIA_. Based on the decision to use CMake_ and its accompanying
tools for testing and packaging software, the standard for building software
from source code was based on this popular, easy to use, and yet powerful
cross-platform, open-source build system. The previously used CMake Project
Template was entirely reworked and became a major component of BASIS.
In fact, the BASIS project evolved from this initial project template
and greatly improved it. See the :doc:`standard/template` page
of the :doc:`standard/buildsystem` for a description of the template.

See the :doc:`standard/implementation` for details on the standard for
implementing software.

:doc:`howto` which help to understand the standard and how to comply
with it can be found here as well.

Projects following the standard include the
`BASIS Modules <apidoc/group__BasisModules.html>`_ and make use of the
`BASIS Utilities <apidoc/group__BasisUtilities.html>`_. They are hence dependent
on the BASIS package, similarly to a software implemented in C++ depends on
third-party libraries used by this implementation, for example. Therefore,
in order to be able to build a BASIS project, the BASIS package has to be
installed. Note, however, that BASIS is not necessarily required during the
runtime, i.e., for executing the software. This depends on which utilities
are used by the software.

A Power Point :download:`presentation introducing BASIS <BASIS Introduction.pptx>`
explains the purpose and the parts it is made of.

------------------------------------------------------------------------------

.. toctree::
    :hidden:

    download
    installation
    documentation
    tutorials


.. _CMake: http://www.cmake.org
.. _SBIA: http://www.rad.upenn.edu/sbia/
