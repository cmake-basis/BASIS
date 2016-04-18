.. meta::
    :description: Download the CMake BASIS software and manual for Unix (Linux, OS X) and Microsoft Windows.

========
Download
========

Source Code
===========

The source code of the CMake BASIS package is hosted on `GitHub <https://github.com/cmake-basis/BASIS/>`__
from which all releases and latest development versions can be downloaded. See the :doc:`changelog` for a summary
of changes in each release.

Either clone the Git repository:

.. code-block:: bash
    
    git clone --depth=1 https://github.com/cmake-basis/BASIS.git

or download the `latest BASIS release package <https://github.com/cmake-basis/BASIS/releases>`__.

.. seealso:: The :doc:`Quick Start Guide <quickstart>` can help you get up and running.


System Requirements
-------------------

**Operating System:**  Linux, Mac OS X, Microsoft Windows

**Software Packages:** See the :ref:`BasisBuildDependencies` for a full list of dependencies.


.. This reference is used in the file headers to refer to the software license!
.. _License:

Software License
----------------

The CMake BASIS package is distributed under the `BSD 2-Clause License`_. A number of source files
included and used by CMake BASIS originate from other Open Source projects and are thus bound by
their own respective Open Source license. For a complete list of copyright and license notices,
have a look at the COPYING_ file.

The original "BASIS" package was developed at the
`Section of Biomedical Image Analysis (SBIA) <http://www.cbica.upenn.edu/sbia/>`__ of the
`University of Pennsylvania <http://www.upenn.edu>`__.
The "BASIS" package was released under the
`SBIA Contribution and Software License Agreement <http://www.cbica.upenn.edu/sbia/software/license.html>`__,
a BSD-style Open Source software license. Since 2013, the forked and slightly renamed "CMake BASIS"
package is further developed and maintained by its original author Andreas Schuh after leaving SBIA.
Andrew Hundt from `Carnegie Mellon University <http://www.cmu.edu/>`__ joined the development
of CMake BASIS soon after. 

.. _BSD 2-Clause License: http://opensource.org/licenses/BSD-2-Clause
.. _COPYING: https://github.com/cmake-basis/BASIS/blob/master/COPYING.txt


.. _BasisPackageContent:

Package Content
---------------

The following table summarizes the content of the CMake BASIS package briefly with
links to the `master branch`_ of the Git repository hosted on GitHub which allows
browsing through the files online.

====================   ============================================================
BasisProject.cmake_    Meta-data used for the build configuration.
CMakeLists.txt_        Root CMake configuration file.
`config/`_             Package configuration files.
`doc/`_                Documentation source files.
`example/`_            Example files used in the tutorials.
`include/`_            Public header files.
`src/cmake/`_          CMake modules and corresponding auxiliary files.
`src/sphinx/`_         Themes and extensions for the Sphinx documentation tool.
`src/utilities/`_      Source code of utility functions.
`tools/`_              Source code of command-line tools and project templates.
`test/`_               Unit tests for the provided libraries.
====================   ============================================================

.. _master branch:      https://github.com/cmake-basis/BASIS/tree/master
.. _BasisProject.cmake: https://github.com/cmake-basis/BASIS/tree/master/BasisProject.cmake
.. _CMakeLists.txt:     https://github.com/cmake-basis/BASIS/tree/master/CMakeLists.txt
.. _config/:            https://github.com/cmake-basis/BASIS/tree/master/config
.. _doc/:               https://github.com/cmake-basis/BASIS/tree/master/doc
.. _example/:           https://github.com/cmake-basis/BASIS/tree/master/example
.. _include/:           https://github.com/cmake-basis/BASIS/tree/master/include
.. _src/cmake/:         https://github.com/cmake-basis/BASIS/tree/master/src/cmake
.. _src/sphinx/:        https://github.com/cmake-basis/BASIS/tree/master/src/sphinx
.. _src/utilities/:     https://github.com/cmake-basis/BASIS/tree/master/src/utilities
.. _tools/:             https://github.com/cmake-basis/BASIS/tree/master/tools
.. _test/:              https://github.com/cmake-basis/BASIS/tree/master/test


Documentation
=============

.. only:: html
    
    :download:`BASIS Manual <BASIS_Software_Manual.pdf>`: PDF version of software manual.
 
.. only:: latex
    
    `BASIS Manual <https://cmake-basis.github.io/>`__:
    Online version of this manual
