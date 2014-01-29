.. meta::
    :description: Common CMake options for the build configuration of BASIS-based software.


.. _CMakeOptions:

=============
CMake Options
=============

The following BASIS specific options are available when building packages. 
For the full set of options and descriptions use the ccmake_ tool. For CMake_ 
specific options see the documentation for your CMake installation.

The following standard CMake_ options/variables can be configured, 
see the documentation of CMake_ itself for more details:


Standard CMake
==============

.. option:: -DCMAKE_BUILD_TYPE:STRING

    Specify the build configuration to build. If not set, the ``Release``
    configuration will be build. Common values are ``Release`` or ``Debug``.

.. option:: -DCMAKE_INSTALL_PREFIX:PATH

    Prefix used for package :ref:`installation <InstallBuiltFiles>`. See also the
    `CMake reference <http://www.cmake.org/cmake/help/v2.8.8/cmake.html#variable:CMAKE_INSTALL_PREFIX>`_.

.. option:: -DUSE_<Package>:BOOL

    If the software you are building has declared optional dependencies,
    i.e., software packages which it makes use of only if available, for each
    such optional package a ``USE_<Package>`` option is added by BASIS if this
    package was found on your system. It can be set to OFF in order to disable
    the use of this optional dependency by this software.

BASIS Options
==============

There are a number of CMake options that are specific to BASIS listed throughout 
the following documents:

- :doc:`/standard/fhs`
- :ref:`ModuleCMakeVariables`

Frequently Used
---------------

.. option:: -DBASIS_DIR:PATH

    Directory where the ``BASISConfig.cmake`` file is located. Alternatively, the
    installation prefix used to install BASIS can be specified instead.

.. option:: -DBUILD_DOCUMENTATION:BOOL

    Whether build and installation instructions for the documentation should
    be added. If OFF, the build configuration of the doc/ directory is skipped.
    Otherwise, the ``doc`` target is added which can be used to build the documentation. 
    You may still need to run make doc, make manual, make site, etc. by hand, this option 
    enables those settings.

.. note:: Though surprising at first glance, the build of the documentation may
          often be preceeded by the build of the software itself. The reason is
          that the documentation can in general only be generated after script files
          have been configured. Thus, do not be surprised if ``make doc`` will actually
          first build the software if not up to date before generating the API
          documentation.

.. option:: -DBUILD_EXAMPLE:BOOL

    Whether the examples should be built (if required) and/or installed.

.. option:: -DBUILD_TESTING:BOOL

    Whether the testing tree should be built and system tests, i.e., tests
    that execute the installed programs and compare the outputs to the expected
    results should be installed (if done so by the software package).


.. _AdvancedCMakeOptions:

Advanced
--------

Advanced users may further be interested in the settings of the following options
which in most cases are automatically derived from the non-advanced CMake options
summarized above. To view these options in the `CMake GUI`_, press the ``t`` key in
``ccmake`` (Unix) or check the ``Show Advanced Values`` box (Windows).

.. option:: -DBASIS_ALL_DOC:BOOL

    Request the build of all documentation targets as part of the ``ALL`` target
    if ``BUILD_DOCUMENTATION`` is ``ON``.

.. option:: -DBASIS_COMPILE_SCRIPTS:BOOL

    Enable compilation of Python modules. If this option is enabled, only the
    compiled ``.pyc`` files are installed.

.. option:: -DBASIS_COMPILE_MATLAB:BOOL

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

.. option:: -DBASIS_DEBUG:BOOL

    Enable debugging messages during build configuration.

.. option:: -DBASIS_INSTALL_APIDOC_DIR:PATH

    Installation directory of the API documentation relative to the installation prefix.

.. option:: -DBASIS_INSTALL_SCHEME:STRING

    Installation scheme, i.e., filesystem hierarchy, to use for the installation of the
    software files relative to the installation prefix specified by the :option:`-DCMAKE_INSTALL_PREFIX`.
    Valid values are ``default``, ``usr``, ``opt``, or ``win``. See :ref:`InstallationTree`
    as defined by the :doc:`/standard/fhs` of BASIS for more details.

.. option:: -DBASIS_INSTALL_SITE_DIR:PATH

    Installation directory of the web site relative to the installation prefix.

.. option:: -DBASIS_INSTALL_SITE_PACKAGES:BOOL

    Whether to install public module libraries written in a scripting language such as
    Python or Perl in the system-wide default locations for site packages. This option is
    disabled by default as write permission to these directories are required otherwise.

.. option:: -DBASIS_MCC_FLAGS:STRING

    Additional flags for MATLAB Compiler separated by spaces.

.. option:: -DBASIS_MCC_MATLAB_MODE:BOOL

    Whether to call the `MATLAB Compiler`_ in MATLAB mode. If ``ON``, the MATLAB Compiler
    is called from within a MATLAB interpreter session, which results in the
    immediate release of the MATLAB Compiler license once the compilation is done.
    Otherwise, the license is reserved for a fixed amount of time (e.g. 30 min).

.. option:: -DBASIS_MCC_RETRY_ATTEMPTS:INT

    Number of times the compilation of `MATLAB Compiler`_ target is repeated in case
    of a license checkout error.

.. option:: -DBASIS_MCC_RETRY_DELAY:INT

    Delay in number of seconds between retries to build `MATLAB Compiler`_ targets after a
    license checkout error has occurred.

.. option:: -DBASIS_MCC_TIMEOUT:INT

    Timeout in seconds for the build of a `MATLAB Compiler`_ target. If the build
    of the target could not be finished within the specified time, the build is
    interrupted.

.. option:: -DBASIS_MEX_FLAGS:STRING

    Additional flags for the MEX_ script separated by spaces.

.. option:: -DBASIS_MEX_TIMEOUT:INT

    Timeout in seconds for the build of MEX-Files_.

.. option:: -DBASIS_REGISTER:BOOL

    Whether to register installed package in CMake's `package registry`_. This option
    is enabled by default such that packages are found by CMake when required by other
    packages based on this build tool.

.. option:: -DBASIS_VERBOSE:BOOL

    Enable verbose messages during build configuration.

.. option:: -DBUILD_CHANGELOG:BOOL

    Request build of ChangeLog as part of the ``ALL`` target. Note that the ChangeLog
    is generated either from the Subversion_ history if the source tree is a SVN
    working copy, or from the Git history if it is a Git_ repository. Otherwise,
    the ChangeLog cannot be generated and this option is disabled again by BASIS.
    In case of Subversion, be aware that the generation of the ChangeLog takes
    several minutes and may require the input of user credentials for access to the
    Subversion repository. It is recommended to leave this option disabled and to
    build the ``changelog`` target separate from the rest of the software package
    instead (see :ref:`Build`).

.. option:: -DITK_DIR:PATH

    Path to the directory of your ITK installation, if applicable.   
    
.. option:: -DMATLAB_DIR:PATH

    Path to the directory of your MATLAB installation, if applicable. 
    
.. option:: -DSPHINX_DIR:PATH

    Path to the directory of your Sphinx installation, if applicable. 



.. _CMake: http://www.cmake.org/
.. _ccmake: http://www.cmake.org/cmake/help/runningcmake.html
.. _CMake GUI: http://www.cmake.org/cmake/help/runningcmake.html
.. _Git: http://git-scm.com/
.. _MATLAB: http://www.mathworks.com/products/matlab/
.. _MATLAB Compiler: http://www.mathworks.com/products/compiler/
.. _MEX: http://www.mathworks.com/help/techdoc/ref/mex.html
.. _MEX-Files: http://www.mathworks.com/help/techdoc/matlab_external/f7667.html
.. _package registry: http://www.cmake.org/Wiki/index.php?title=CMake/Tutorials/Package_Registry
.. _Subversion: http://subversion.apache.org/
