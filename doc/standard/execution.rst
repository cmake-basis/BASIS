.. meta::
    :description: This article details the calling conventions, i.e., the
                  execution of subprocesses, of BASIS, a build system and software
                  implementation standard.

===================
Calling Conventions
===================

This document discusses and describes the conventions for calling other
executables from a program. The calling conventions address problems
stemming from the use of relative or absolute file paths when calling 
executables. It also introduce a name mapping from build target names 
to actual executable file paths. These calling conventions are handled
through automatically generated utility functions for each supported
programming language. See :ref:`CallingConventionsImpl` for details on the
specific implementations in each language.

Purpose
=======

One nice feature about using the target name instead of the actual executable file allows a developer of project B to call executables of project A using the ("full qualified") target names, e.g.,

.. code-block:: cmake
    
  execute(“projecta.utility”);

This target has been imported from the export file during CMake configuration and the BASIS execute function will map this target name to the installed executable of project A. The developer of project A can rename the executable or change the installation location as they wish. They only need to keep the internal target name.

The file name of executable scripts, for example, will be different on Unix and Windows. On Unix, we don’t use file name extensions and instead rely on the `hashbang/shebang #!`_ directive such that script executables look and are used just like binary executables. On Windows, any executable script (i.e., only Python or Perl at the moment) is wrapped into a Windows Command file with the .cmd file name extension. This file contains a few lines additional Windows Command code to invoke the script interpreter with the very same file. The Windows Command code is just a comment to the Python/Perl interpreter which will ignore it.

.. _RelVsAbsExecPath:

Relative vs. Absolute Paths
===========================

Relative paths such as only the executable file name require a proper setting
of the ``PATH`` environment variable. If more than one version of a particular
software package should be installed or in case of name conflicts with other
packages, this is not trivial and it may not be guaranteed that the correct
executable is executed. Absolute executable file paths, on the other side,
restrict the relocatability and thus distribution of pre-build binary packages.
Therefore, BASIS proposes and implements the following convention on how
absolute paths of (auxiliary) executables are determined at runtime by taking
the absolute path of the directory of the calling executable into consideration.

Main executables in the ``bin/`` directory call utility executables relative
to their own location. For example, a Bash_ script called ``main`` that executes
a utility script ``util`` in the ``lib/`` directory would do so as demonstrated
in the following example code (for details on the ``@VAR@`` patterns, please refer
to the :doc:`scripttargets` page):

.. code-block:: bash

    # among others, defines the get_executable_directory() function
    . ${BASIS_Bash_UTILITIES} || { echo "Failed to import BASIS utilities!" 1>&2; exit 1; }
    # get absolute directory path of auxiliary executable
    exedir _EXEC_DIR && readonly _EXEC_DIR
    _LIBEXEC_DIR=${_EXEC_DIR}/@LIBEXEC_DIR@
    # call utility executable in libexec directory
    ${_LIBEXEC_DIR}/util

where LIBEXEC_DIR_ is set in the BasisScriptConfig.cmake_ configuration file
to either the output directory of auxiliary executables in the build tree
relative to the directory of the script built for the build tree or to the path
of the installed auxiliary executables relative to the location of the installed
script. Note that in case of script files, two versions are build by BASIS,
one that is working directly inside the build tree and one which is copied to
the installation tree. In case of compiled executables, such as in particular
programs built from C++ source code files, a different but similar approach is
used to avoid the build of two different binary executable files. Here, the
executable determines at runtime whether it is executed from within the build
tree or not and uses the appropriate path depending on this.

If an executable in one directory wants to execute another executable in the same
directory, it can simply do so as follows:

.. code-block:: bash

    # call other main executable
    ${_EXEC_DIR}/othermain


.. _ExecPathVsTargetName:

File vs. Target Name
=====================

In order to be independent of the actual names of the executable files--which
may vary depending on the operating system (e.g., with or without file name
extension in case of script files) and the context in which a project was
built--executables should not be called by their respective file name,
but their build target name.

It is in the responsibility of the BASIS auxiliary functions to properly map this
project specific and (presumably) constant build target name to the absolute
file path of the built (and installed) executable file. This gives BASIS the
ability to modify the executable name during the configuration step of the
project, for example, to prepand them with a unique project-specific prefix,
in order to ensure uniqueness of the executable file name. Moreover, if an
executable should be renamed, this can be done simply through the build
configuration and does not require a modification of the source code files
which make use of this executable.


.. _SystemSearchPaths:

Search Paths
============

All considered operating systems--or more specifically the used shell and dynamic
loader--provide certain ways to configure the search paths for executable files
and shared libraries which are dynamically loaded on demand. The details on how
these search paths can be configured are summarized next including the pros and
cons of each method to manipulate these search paths. Following these
considerations, the solution aimed at by BASIS is detailed.


.. _UnixSearchPaths:

Unix
----

On Unix-based systems (including in particular all variants of Linux and
Mac OS) executables are searched in directories specified by the ``PATH``
environment variable. Shared libraries, on the other side, are first
searched in the directories specified by the ``LD_LIBRARY_PATH`` environment
variable, then in the directories given by the ``RPATH`` which is set within
the binary files at compile time, and last the directories specified in
the ``/etc/ld.so.conf`` system configuration file.

The most flexible method which can also easily be applied by a user is
setting the ``LD_LIBRARY_PATH`` environment variable. It is, however, not always
trivial or possible to set this search path in a way such that all used and
installed software works correctly. There are many discussions on why this
method of setting the search path is considered evil among the Unix community
(see for example `here <http://xahlee.org/UnixResource_dir/_/ldpath.html>`_).
The second option of setting the ``RPATH`` seems to be the
most secure way to set the search path at compile time. This, however, only
for shared libraries which are distributed and installed with the software
because only in this case can we make use of the ``$ORIGIN`` variable in the
search path to make it relative to the location of the binary file.
Otherwise, it is either required that the software is being compiled
directly on the target system or the paths to the used shared libraries
on the target system must match the paths of the system on which the
executable was built. Hence, using the ``RPATH`` can complicate or restrict
the relocatability of a software. Furthermore, unfortunately is the
``LD_LIBRARY_PATH`` considered before the ``RPATH`` and hence any user setting
of the ``LD_LIBRARY_PATH`` can still lead to the loading of the wrong shared
library. The system configuration ``/etc/ld.so.conf`` is not an option for
setting the search paths for each individual software. This search path
should only be set to a limited number of standard system search paths
as changes affect all users. Furthermore, directories on network drives
may not be included in this configuration file as they will not be
available during the first moments of the systems start-up. Finally, only
an administrator can modify this configuration file.

The anticipated method to ensure that the correct executables and shared
libraries are found by the system for Unix-based systems is as follows.
As described in the previous sections, executables which are part of the
same software package are called by the full absolute path and hence no
search path needs to be considered. To guarantee that shared libraries
installed as part of the software package are considered first, the
directory to which these libraries where installed is prepended to the
``LD_LIBRARY_PATH`` prior to the execution of any other executable.
Furthermore, the ``RPATH`` of binary executable files is set using the
``$ORIGIN`` variable to the installation directory of the package's
shared libraries. This ensures that also for the execution of the main
executable, the package's own shared libraries are considered first. To not
restrict the administrator of the target system on where other external
packages need to be installed, no precaution is taken to ensure that executables
and shared libraries of these packages are found and loaded properly.
This is in the responsibility of the administrator of the target system.
However, by including most external packages into the distributed binary
package, these become part of the software package and thus above methods
apply.

.. note::
    The inclusion of the runtime requirements should be done
    during the packaging of the software and thus these packages should still
    not be integrated into the project's source tree.

`Mac OS bundles`_ differ from the default Unix-like way of installing
software. Here, an information property list file (Info.plist) is used
to specify for each bundle separately the specific properties including
the location of frameworks, i.e., private shared libraries (shared libraries
distributed with the bundle). Most shared libraries required by the software
will be included in the bundle.


.. _WindowsSearchPaths:

Windows
-------

On Windows systems, executable files are first searched in the current
working directory. Then, the directories specified by the ``PATH`` environment
variable are considered as search path for executable files where the extensions
``.exe``, ``.com``, ``.bat``, and ``.cmd`` are considered by default and need not be
included in the name of the executable that is to be executed. Shared libraries,
on the other side, are first searched in the directory where the using module
is located, then in the current working directory, the Windows system directory
(e.g., ``C:\WINDOWS\system32\``), and then the Windows installation directory
(e.g., ``C:\WINDOWS``). Finally, the directories specified by the ``PATH``
environment variable are searched for the shared libraries.

As described in the previous sections, executables which are part of the
software package are called by the full absolute path and hence no search path
is considered. Further, shared runtime libraries belonging to the software package
are installed in the same directory as the executables and hence will be
considered by the operating system before any other shared libraries.


.. _CallingConventionsImpl:

Implementation
==============

In the following the implementation of the calling conventions in each supported
programming language is summarized.

Note that the `BASIS Utilities`_ provide an ``execute()`` function for each
of these languages which accepts either an executable file path or
a build target name as first argument of the command-line to execute.


.. _CxxCallingConventionsImpl:

C++
---

For C++ programs, the BASIS C++ utilities provide the function
`exepath() <https://cmake-basis.github.io/apidoc/latest/group__BasisCxxUtilities.html>`__
which maps a build target name to the absolute path of the executable file
built by this target. This function makes use of an implementation of the
:apidoc:`basis::util::IExecutableTargetInfo` interface whose constructor is automatically
generated during the configuration of a project. This constructor initializes the
data structures required for the mapping of target names to absolute file paths.
Note that BASIS generates different implementations of this module for different projects,
the whose documentation is linked here is the one generated for BASIS itself.

The project implementations will, however, mainly make use of the
`execute() <https://cmake-basis.github.io/apidoc/latest/group__BasisCxxUtilities.html>`__
function which accepts either an actual executable file
path or a build target name as first argument of the command-line to execute.
This function shall be used in C++ code as a substitution for the commonly
used `system()`_ function on Unix. The advantage of ``execute()`` is further,
that it is implemented for all operating systems which are supported by BASIS,
i.e., Linux, Mac OS, and Windows. The declaration of the ``execute()``
function can be found in the ``basis.h`` header file. Note that this file is unique
to each BASIS project.


.. _JavaCallingConventionsImpl:

Java
----

The Java programming language is not yet supported by BASIS.


.. _PythonCallingConventionsImpl:

Python
------

A Python module named basis.py_ stores the location of the executables relative
to its own path in a dictionary where the UIDs of the corresponding build targets
are used as keys. The functions
`exename() <https://cmake-basis.github.io/apidoc/latest/group__BasisPythonUtilities.html#gad832403b77ea714613fe9d8792fc2d76>`__,
`exedir() <https://cmake-basis.github.io/apidoc/latest/group__BasisPythonUtilities.html#gae4a179b411575e221d6363bdc5e08946>`__,
and `exepath() <https://cmake-basis.github.io/apidoc/latest/group__BasisPythonUtilities.html#ga300b1dc5bb4d6d7d13dc8ac4fec9a368>`__
can be used to get the name, directory, or path, respectively, of the executable file built by the
specified target. If no target is specified, the name, directory, or path of the
calling executable itself is returned.


.. _PerlCallingConventionsImpl:

Perl
----

The Basis.pm_ Perl module uses a hash reference to store the locations of the
executable files relative to the module itself. The functions
`exename() <https://cmake-basis.github.io/apidoc/latest/group__BasisPerlUtilities.html#gabcdbfcbc0a8f61d74af795ec1cc3201c>`__,
`exedir() <https://cmake-basis.github.io/apidoc/latest/group__BasisPerlUtilities.html#gae2fad71a402bbbe877cc62e6c8dad4d7>`__, and
`exepath() <https://cmake-basis.github.io/apidoc/latest/group__BasisPerlUtilities.html#gaaafd1e575a71a6eb230c712f1ae9f72b>`__ can be used to get the name, directory, or path,
respectively, of the executable file built by the specified target.
If no target is specified, the name, directory, or path of the calling
executable itself is returned.


.. _BashCallingConventionsImpl:

Bash
----

The module basis.sh_ imitates associative arrays to store the location
of the built executable files relative to this module. The functions
`exename() <https://cmake-basis.github.io/apidoc/latest/group__BasisBashUtilities.html#gae51069427c675de3fdc22e3b8edbd282>`__,
`exedir() <https://cmake-basis.github.io/apidoc/latest/group__BasisBashUtilities.html#ga910356e76596e5bdbedb544186ff395b>`__,
and `exepath() <https://cmake-basis.github.io/apidoc/latest/group__BasisBashUtilities.html#ga40ae56f084f0786fe49bfc98e2fabf1f>`__
can be used to get the name, directory, or path, respectively, of the
executable file built by the specified target. If no target is specified,
the name, directory, or path of the calling executable itself is returned.

Additionally, the basis.sh_ module can setup aliases named after the UID of the
build targets for the absolute file path of the corresponding executables.
The target names can then be simply used as aliases for the actual executables.
The initialization of the aliases is, however, at the moment expensive and delays
the load time of the executable which sources the basis.sh_ module. Note further
that this approach requires the option ``expand_aliases`` to be set via
``shopt -s expand_aliases`` which is done by the ``basis.sh`` module if aliases
were enabled. A ``shopt -u expand_aliases`` disables the expansion of aliases and
hence should not be used in Bash scripts which execute other executables using
the aliases defined by basis.sh_.


.. _UnsupportedCallingConventions:

Unsupported Languages
=====================

In the following, languages for which the calling conventions are not implemented
are listed. Reasons for not supporting these languages regarding the execution
of other executables are given for each such programming language. Support for
all other programming languages which are not supported yet and not listed here
may be added in future releases of BASIS.


.. _MatlabCallingConventionsImpl:

MATLAB
------

Visit `this MathWorks page <http://www.mathworks.com/help/techdoc/matlab_external/bp_kqh7.html>`_
for a documentation of external interfaces MathWorks_ provides for the development
of applications in MATLAB_. An implementation of the ``execute()`` function in
MATLAB is yet not provided by BASIS.


.. _basis.py: https://cmake-basis.github.io/apidoc/latest/basis_8py.html
.. _basis.sh: https://cmake-basis.github.io/apidoc/latest/basis_8sh.html
.. _Basis.pm: https://cmake-basis.github.io/apidoc/latest/Basis_8pm.html
.. _BASIS Utilities: https://cmake-basis.github.io/apidoc/latest/group__BasisUtilities.html
.. _Bash: http://www.gnu.org/software/bash/
.. _Mac OS Bundles: http://developer.apple.com/library/mac/#documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html
.. _MathWorks: http://www.mathworks.com/
.. _MATLAB: http://www.mathworks.com/products/matlab/
.. _LIBEXEC_DIR: https://cmake-basis.github.io/apidoc/latest/group__BasisScriptConfig.html#gab41b55712c871a1c6ef0407894d58958
.. _BasisScriptConfig.cmake: https://cmake-basis.github.io/apidoc/latest/BasisScriptConfig_8cmake.html
.. _system(): http://www.cplusplus.com/reference/clibrary/cstdlib/system/
.. _`hashbang/shebang #!`: http://en.wikipedia.org/wiki/Shebang_(Unix)
