.. title:: Home

.. meta::
    :description: BASIS makes it easy to create sharable software and libraries 
                  that work together. This is accomplished by combining and 
                  documenting some of the best practices and utilities available. 
                  More importantly, BASIS supplies a fully integrated suite of 
                  functionality to make the whole process seamless!
    :google-site-verification: FEpJ4EO1PvGXLyfXp-Q6EJsypA0xGqYctXtmoP3pLJw

.. raw:: latex

    \pagebreak


.. toctree::
    :hidden:
    :maxdepth: 1

    BASIS Overview <self>
    Contents <contents>

.. toctree::
    :hidden:
    :maxdepth: 3

    quickstart
    howto
    standard
    apidoc

.. toctree::
    :hidden:
    :maxdepth: 3

    download
    install
    help
    changelog  


===========
CMake BASIS
===========

The **CMake Build system And Software Implementation Standard (BASIS)** package makes it
easy to create sharable software and libraries that work together. This is accomplished
by combining and documenting some of the best practices and utilities available.
More importantly, BASIS supplies a fully integrated suite of functionality to make
the whole process seamless! 

.. _Features:

Features
========

**Project Creation**

- Quick setup with mad-libs style text substitution with basisproject
- Customizable project templates

**Standards**

- Filesystem layout standards
- Implementation standard
- Command line standards
- Style Guides
   
**Build system utilities**

- New `CMake Module APIs`_
- Version Control Integration
- Automatic Packaging
   
**Documentation**

- Documentation generation tools
- Manuals
- API Docs
- PDF and html output of each
- Integrated with CMake APIs

**Testing**

- Unit testing
- Continuous Integration
- Executable testing frameworks

**Program Execution**

- Parsing library
- Command execution library
- Unix philosophy
- One tool can run others

**Supported Programming Languages**

C++, BASH, MATLAB, Python


**Supported Packages**

CMake_, CPack_, CTest_/CDash_, Doxygen_, Sphinx_, Git_, Subversion_, reStructuredText_,
gtest_, gflags_, Boost_, and many more, including custom packages.


Installation
============

See the :doc:`Installation Instructions <install>` for details on installation and prerequisites.


.. _History:

History
=======

The BASIS project was started early in 2011 to improve and standardize the software
packages developed at the `Section of Biomedical Analysis (SBIA) <http://www.rad.upenn.edu/sbia/>`__
of the `University of Pennsylvania <http://www.upenn.edu/>`__. It started with the decision 
to use CMake_ as a build system which has been greatly extended using custom CMake
macros and functions and the implementation of a standardized project template. Over time,
these components were transformed to important parts of the CMake BASIS package.


People
======

**Software Development**

- `Andreas Schuh <http://www.rad.upenn.edu/sbia/Andreas.Schuh>`_
- `Andrew Hundt <ahundt@cmu.edu>`_

**Contributors**

The following people notably helped to define and shape BASIS.

- `Dominique Belhachemi <http://www.rad.upenn.edu/sbia/Dominique.Belhachemi>`_
- `Kayhan N. Batmanghelich <http://www.rad.upenn.edu/sbia/Nematollah.Batmanghelich/Kayhan.Batmanghelich/Home.html>`_
- `Luke Bloy <http://www.rad.upenn.edu/sbia/Luke.Bloy>`_
- `Yangming Ou <http://www.rad.upenn.edu/sbia/Yangming.Ou>`_

**Former Advisors at SBIA**

- `Christos Davatzikos <http://www.rad.upenn.edu/sbia/Christos.Davatzikos>`_
- `Kilian M. Pohl <http://www.rad.upenn.edu/sbia/Kilian.Pohl>`_


.. _Doxygen: http://www.stack.nl/~dimitri/doxygen/
.. _CMake Module APIs: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisModules.html
.. _CPack: http://www.cmake.org/Wiki/CMake:Packaging_With_CPack
.. _CTest: http://cmake.org/Wiki/CMake/Testing_With_CTest
.. _CDash: http://www.cdash.org/
.. _Git: http://git-scm.com/
.. _Subversion: http://subversion.apache.org/
.. _reStructuredText: http://docutils.sourceforge.net/rst.html
.. _CMake: http://www.cmake.org
.. _Sphinx: http://sphinx-doc.org/
.. _Boost: http://www.boost.org
.. _gtest: https://code.google.com/p/googletest/
.. _gflags: https://github.com/schuhschuh/gflags
