=============
CMake Options
=============

The following CMake options/variables can be configured:

.. option:: BASIS_DIR <dir>

    Directory where the ``BASISConfig.cmake`` file is located. Alternatively, the
    installation prefix used to install BASIS can be specified instead.

.. option:: BUILD_DOCUMENTATION ON|OFF

    Whether build and installation instructions for the documentation should
    be added. If OFF, the build configuration of the doc/ directory is skipped.
    Otherwise, the ``doc`` target is added which can be used to build the documentation.

.. note:: Though surprising at first glance, the build of the documentation may
          often be preceeded by the build of the software itself. The reason is
          that the documentation can in general only be generated after script files
          have been configured. Thus, be not surprised if ``make doc`` will actually
          first build the software if not up to date before generating the API
          documentation.

.. option:: BUILD_EXAMPLE ON|OFF

    Whether the examples should be built (if required) and/or installed.

.. option:: BUILD_TESTING ON|OFF

    Whether the testing tree should be built and system tests, i.e., tests
    that execute the installed programs and compare the outputs to the expected
    results should be installed (if done so by the software package).

.. option:: CMAKE_BUILD_TYPE Debug|MinSizeRel|RelWithDebInfo|Release

    Specify the build configuration to build. If not set, the "Release"
    configuration will be build.

.. option:: `CMAKE_INSTALL_PREFIX`_ <dir>

    Prefix used for package :ref:`installation <InstallBuiltFiles>`.

.. option:: USE_<Pkg> ON|OFF

    If the software you are building has declared optional dependencies,
    i.e., software packages which it makes use of only if available, for each
    such optional package a ``USE_<Pkg>`` option is added by BASIS if this
    package was found on your system. It can be set to OFF in order to disable
    the use of this optional dependency by this software.


Advanced CMake Options
----------------------

Advanced users may further be interested in the settings of the following options
which in most cases are automatically derived from the non-advanced CMake options
summarized above. To view these options in the `CMake GUI`_, press the ``t`` key in
``ccmake`` (Unix) or check the ``Show Advanced Values`` box (Windows).

.. option:: BASIS_ALL_DOC ON|OFF

    Request the build of all documentation targets as part of the ``ALL`` target
    if ``BUILD_DOCUMENTATION`` is ``ON``.

.. option:: BASIS_COMPILE_SCRIPTS ON|OFF

    Enable compilation of Python modules. If this option is enabled, only the
    compiled ``.pyc`` files are installed.

.. option:: BASIS_COMPILE_MATLAB ON|OFF

    Whether to compile MATLAB_ sources using the `MATLAB Compiler`_ (mcc) if available.
    If set to ``OFF``, the MATLAB source files are copied as part of the installation and
    a Bash script for the execution of ``matlab`` with the ``-c`` option is generated
    on Unix or a Windows NT Command script on Windows, respectively. This allows the
    convenient execution of the executable implemented in MATLAB even without having a
    license for the MATLAB Compiler. Each instance of the built executable will take up
    one MATLAB license, however. Moreover, the startup of the executable is longer every
    time, not only the first time it is launched as is the case for mcc compiled executables.
    It is therefore recommended to enable this option and to obtain a MATLAB Compiler
    license if possible. By default, this option is ``ON``.

.. option:: BASIS_DEBUG ON|OFF

    Enable debugging messages during build configuration.

.. option:: BASIS_MCC_FLAGS <flags separated by space>

    Additional flags for MATLAB Compiler.

.. option:: BASIS_MCC_MATLAB_MODE ON|OFF

    Whether to call the `MATLAB Compiler`_ in MATLAB mode. If ``ON``, the MATLAB Compiler
    is called from within a MATLAB interpreter session, which results in the
    immediate release of the MATLAB Compiler license once the compilation is done.
    Otherwise, the license is reserved for a fixed amount of time (e.g. 30 min).

.. option:: BASIS_MCC_RETRY_ATTEMPTS <int>

    Number of times the compilation of `MATLAB Compiler`_ target is repeated in case
    of a license checkout error.

.. option:: BASIS_MCC_RETRY_DELAY <int>

    Delay in seconds between retries to build `MATLAB Compiler`_ targets after a
    license checkout error has occurred.

.. option:: BASIS_MCC_TIMEOUT <int>

    Timeout in seconds for the build of a `MATLAB Compiler`_ target. If the build
    of the target could not be finished within the specified time, the build is
    interrupted.

.. option:: BASIS_MEX_FLAGS <flags separated by space>

    Additional flags for the MEX_ script.

.. option:: BASIS_MEX_TIMEOUT <int>

    Timeout in seconds for the build of MEX-Files_.

.. option:: BASIS_REGISTER ON|OFF

    Whether to register installed package in CMake's `package registry`_. This option
    is enabled by default such that packages are found by CMake when required by other
    packages based on this build tool.

.. option:: BASIS_VERBOSE ON|OFF

    Enable verbose messages during build configuration.

.. option:: BUILD_CHANGELOG ON|OFF

    Request build of ChangeLog as part of the ``ALL`` target. Note that the ChangeLog
    is generated either from the Subversion_ history if the source tree is a SVN
    working copy, or from the Git history if it is a Git_ repository. Otherwise,
    the ChangeLog cannot be generated and this option is disabled again by BASIS.
    In case of Subversion, be aware that the generation of the ChangeLog takes
    several minutes and may require the input of user credentials for access to the
    Subversion repository. It is recommended to leave this option disabled and to
    build the ``changelog`` target separate from the rest of the software package
    instead (see :ref:`Build`).

.. option:: INSTALL_APIDOC_DIR <dir>

    Installation directory of the API documentation relative to the installation prefix.

.. option:: INSTALL_SITE_DIR <dir>

    Installation directory of the web site relative to the installation prefix.


.. _CMake GUI: http://www.cmake.org/cmake/help/runningcmake.html
.. _Git: http://git-scm.com/
.. _MATLAB: http://www.mathworks.com/products/matlab/
.. _MATLAB Compiler: http://www.mathworks.com/products/compiler/
.. _MEX: http://www.mathworks.com/help/techdoc/ref/mex.html
.. _MEX-Files: http://www.mathworks.com/help/techdoc/matlab_external/f7667.html
.. _package registry: http://www.cmake.org/Wiki/index.php?title=CMake/Tutorials/Package_Registry
.. _Subversion: http://subversion.apache.org/
