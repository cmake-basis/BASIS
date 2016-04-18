Introduction
============

The online [CMake BASIS Installation Guide](http://schuhschuh.github.io/cmake-basis/install.html) 
is the best source for installation instructions. This document only contains basic build and
installation instructions for offline use.



Binary Distribution Package
===========================

Please see the corresponding section of the [BASIS Installation Guide][3].



Runtime Requirements
====================

This software has no runtime dependencies.



Building the Software
=====================

Build Dependencies
------------------

The following software has to be installed (if not optional).

Package             | Version | Description
------------------- | ------- | --------------------------------------------------------
[ITK][1] (optional) | >= 3.14 | The standalone basistest-driver executable currently makes use of the ITK, either version 3 or 4 and above, for the comparison of a test image to one or more baseline images. If no installation of this library is found, this executable is excluded from the build and installation. Note that many packages developed at SBIA make use of this executable in their tests. If BASIS has been built without the *basistest-driver*, these packages have to be build with BUILD_TESTING option set to OFF.



Build Steps
-----------

The common steps to build, test, and install software based on CMake,
including this software, are as follows:

1. Extract source files.
2. Create build directory and change to it.
3. Run CMake to configure the build tree.
4. Build the software using selected build tool.
5. Test the built software.
6. Install the built files.

On Unix-like systems with GNU Make as build tool, these build steps can be
summarized by the following sequence of commands executed in a shell,
where $package and $version are shell variables which represent the name
of this package and the obtained version of the software.

    $ tar xzf cmake-basis-$version.tar.gz
    $ mkdir cmake-basis-$version/build
    $ cd cmake-basis-$version/build
    $ ccmake ..

    - Press 'c' to configure the build system and 'e' to ignore warnings.
    - Set CMAKE_INSTALL_PREFIX and other CMake variables and options.
    - Continue pressing 'c' until the option 'g' is available.
    - Then press 'g' to generate the configuration files for GNU Make.

    $ make
    $ make test    (optional)
    $ make install (optional)

An exhaustive list of minimum build dependencies, including the build tools
along detailed step-by-step build, test, and installation instructions can
be found in the corresponding "Building the Software from Sources" section
of the [BASIS how-to guide on software installation][2].

Please refer to this guide first if you are uncertain about above steps or
have problems to build, test, or install the software on your system.
If this guide does not help you resolve the issue, please report an issue
on GitHub. In case of failing tests, please attach the output of the
following command:

    $ ctest -V >& test.log

In the following, only package-specific CMake settings available to
configure the build and installation of this software are documented.


CMake Options
-------------

Option             | Description
------------------ | -------------------------------------------------------------------
DEPENDS_ITK_DIR    | Specify directory of ITKConfig.cmake file. The ITK library is used by the basistest-driver executable if available. See Build Dependencies for more details.
DEPENDS_MATLAB_DIR | Specify installation root directory of MATLAB. This variable is only available if BUILD_TESTING was set to ON and setting it can be omitted. If a MATLAB installation was specified, however, the tests for the build of binaries using the MATLAB Compiler or the MEX script respectively can be run.


Advanced CMake Options
----------------------

Depending on which language interpreters are installed on your system,
the following CMake options are available:

Option      | Description
----------- | -------------------------------------------------------------
WITH_ITK    |  Whether to link standalone test driver with ITK.
WITH_Python |  Whether to build/enable the Python utilities.
WITH_Perl   |  Whether to build/enable the Perl utilities.
WITH_BASH   |  Whether to build/enable the BASH utilities.



<!-- REFERENCES -->
[1]: http://www.itk.org
[2]: https://cmake-basis.github.io/howto/install.html
[3]: https://cmake-basis.github.io/howto/install.html#binary-distribution-package
