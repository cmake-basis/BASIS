============
Installation
============

Prerequisites
-------------

See the :ref:`BasisBuildDependencies` listed in the :doc:`howto/install` guide
for a list of software tools required to build BASIS. These are further the tools
required to build any software which is based on BASIS. Moreover, BASIS makes
use of the following software packages:

ITK_ *>= 3.14* (optional)
    The standalone ``basistest-driver`` executable currently makes use of the ITK,
    either version 3 or 4 and above, for the comparison of a test image to one
    or more baseline images. If no installation of this library is found, this
    executable is excluded from the build and installation. Note that many
    packages developed at SBIA make use of this executable in their tests.
    If BASIS has been built without the ``basistest-driver``, these packages
    have to be build with the ``BUILD_TESTING`` option set to ``OFF`` (the default).

MATLAB_ *>= R2009b* (optional)
    The MATLAB tools are used by BASIS to build `MEX-Files`_ from C++ sources.
    If ``BUILD_TESTING`` is set to ``ON`` and the MEX script is found, the tests
    for the build of MEX files are run. Otherwise, these are excluded from the test.

`MATLAB Compiler`_ *>= R2009b* (optional)
    The MATLAB Compiler (MCC) is used by BASIS to build stand-alone executables
    from MATLAB source files. If ``BUILD_TESTING`` is set to ``ON`` and MCC is found,
    the tests for the build of such binaries are run. Otherwise, these are excluded
    from the test.

For instructions on how to build or install these prerequisites, please refer to
the documentation of the respective software package.


This Software
-------------

The build, test, and installation steps which are common to any BASIS based
software, including BASIS itself, are given in the :doc:`howto/install` guide.

If you have problems to build, test, or install the software on your system and
this guide does not help you to resolve the issue, please contact us at
**<sbia-software at uphs.upenn.edu>**.


.. _ITK: http://www.itk.org/
.. _MATLAB: http://www.mathworks.com/products/matlab/
.. _MATLAB Compiler: http://www.mathworks.com/products/compiler/
.. _MEX-Files: http://www.mathworks.com/help/techdoc/matlab_external/f7667.html
