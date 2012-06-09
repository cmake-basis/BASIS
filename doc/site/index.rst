.. title:: Home

========
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
and greatly improved it. See the :doc:`standard/template` of the
:doc:`standard/buildsystem` for a details on the template.

See the :doc:`standard/implementation` for details on the standard for
implementing software.

:doc:`howto` which help to understand the standard and how to comply
with it can be found here as well.

Projects following the standard include the `BASIS Modules`_ and make use of the
`BASIS Utilities`_. They are hence dependent on the BASIS package, similarly to
a software implemented in C++ depends on third-party libraries used by this
implementation, for example. Therefore, in order to be able to build a BASIS
project, the BASIS package has to be installed. Note, however, that BASIS is not
necessarily required during the runtime, i.e., for executing the software.
This depends on which utilities are used by the software.

The :download:`BASIS Introduction <BASIS Introduction.pptx>` slides
further explain its purpose and the parts it is made of
(`ref <http://www.rad.upenn.edu/sbia/software/basis/>`_).

.. The ref link is required for the PDF version as the download directive in
   this case does not translate to a hyperlink, but text only.


.. toctree::
    :hidden:

    self
    download
    installation
    documentation
    tutorials


.. _BASIS Modules: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisModules.html
.. _BASIS Utilities: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisUtilities.html
.. _CMake: http://www.cmake.org
.. _SBIA: http://www.rad.upenn.edu/sbia/
