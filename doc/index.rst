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




==============
BASIS Overview
==============

BASIS makes it easy to create sharable software and libraries that work together. 
This is accomplished by combining and documenting some of the best practices and 
utilities available. More importantly, BASIS supplies a fully integrated suite of 
functionality to make the whole process seamless! 

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

CMake_, CPack, CDash, Doxygen, Sphinx, Git, Svn, reStructured Text, gtest_, gflags_, Boost_, and many more, including custom packages.


Install
=======

See :doc:`install` for installation and dependency details.

.. _History:

History
========

The **Build system And Software Implementation Standard (BASIS)** project was
started early in 2011 to improve and standardize the software packages
developed at the University of Pennsylvania's SBIA_. It started with the decision 
to use CMake_ as a build system, then the implementation of a project creation template.
Over time, these components were transformed to important parts of BASIS.


People
------

**Former Advisors at SBIA**

- `Christos Davatzikos <http://www.rad.upenn.edu/sbia/Christos.Davatzikos>`_
- `Kilian M. Pohl <http://www.rad.upenn.edu/sbia/Kilian.Pohl>`_

**Software Development**

- `Andreas Schuh <http://www.rad.upenn.edu/sbia/Andreas.Schuh>`_
- `Andrew Hundt <ahundt@cmu.edu>`_

**Contributors**

The following people notably helped to define and shape BASIS.

- `Dominique Belhachemi <http://www.rad.upenn.edu/sbia/Dominique.Belhachemi>`_
- `Kayhan N. Batmanghelich <http://www.rad.upenn.edu/sbia/Nematollah.Batmanghelich/Kayhan.Batmanghelich/Home.html>`_
- `Luke Bloy <http://www.rad.upenn.edu/sbia/Luke.Bloy>`_
- `Yangming Ou <http://www.rad.upenn.edu/sbia/Yangming.Ou>`_




Table of Contents
=================

.. toctree::
    :maxdepth: 3

    self

.. toctree::
    :maxdepth: 4
    
    quickstart
    howto
    standard
    apidoc

.. toctree::
    :maxdepth: 3

    download
    install
    help
    changelog   



.. _Doxygen: http://www.stack.nl/~dimitri/doxygen/



.. _CMake Module APIs: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisModules.html
.. _Build system utilities: http://www.rad.upenn.edu/sbia/software/basis/apidoc/latest/group__BasisUtilities.html
.. _CMake: http://www.cmake.org
.. _SBIA: http://www.rad.upenn.edu/sbia/
.. _Boost: http://www.boost.org
.. _gtest: https://code.google.com/p/googletest/
.. _gflags: https://github.com/schuhschuh/gflags
