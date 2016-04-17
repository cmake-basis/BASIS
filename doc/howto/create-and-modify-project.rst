.. meta::
    :description: How to create/modify a software project based on BASIS,
                  a build system and software implementation standard.

=======================
Create/Modify a Project
=======================

This how-to guide introduces the ``basisproject`` command-line tool which
is installed as part of BASIS. This tool is used to create a new project 
based on BASIS or to modify an existing BASIS project. The creation of a 
new project based on BASIS is occasionally also referred to as 
instantiating the :doc:`/standard/template`.

For a detailed description and overview of the available command options,
please refer to the output of the following command::

    basisproject --help


.. _HowToCreateAProject:

Create a New Project
====================

The fastest way to create a new project is to call ``basisproject`` with the name
of the new project and a brief project description as arguments:

.. code-block:: bash

    basisproject create --name MyProject \
            --description "This is a brief description of the project."

.. note:: Use the `--full` option to create a project from all template features.
          Most projects, however, will only need the default set of features.

This will create a subdirectory called ``MyProject`` under the current working directory
and populate it with the standard project directory structure and BASIS configuration.
No CMake commands to resolve dependencies to other software packages will be added.
These can be added later either manually or as described :ref:`below <HowToModifyAProject>`.
However, if you know already that your project will depend, for example, on ITK_ and
optionally make use of VTK_ if available, you can specify these dependencies
when creating the project using the ``--use`` or ``--useopt`` option, respectivley:

.. code-block:: bash

    basisproject create --name MyProject \
            --description "This is a brief description of the project." \
            --use ITK --useopt VTK

The ``basisproject`` tool will in turn modify the :ref:`BasisProject.cmake <BasisProject>`
file to add the named packages to the corresponding lists of dependencies.

.. note::

    In order for ``basisproject`` to be able to find the correct place where to insert
    the new dependencies, the ``#<dependency>`` et al. placeholders have to be present.
    See the  :ref:`BasisProject.cmake <BasisProject>` template file.


.. _HowToModifyAProject:

Modify an Existing Project
==========================

``basisproject`` allows a detailed selection of the features included in the project
template for a particular BASIS project. Which of these features are needed will
often not be known during the creation of the project, but change during the work on
the project. Therefore, an existing BASIS project which was created as
described :ref:`above <HowToCreateAProject>` can be modified using ``basisproject``
to add or remove certain project features and to conveniently add CMake commands to
resolve further dependencies on other software packages. How this is done is
described in the following.

General Notes
-------------

The two project attributes which cannot be modified using ``basisproject`` are the
project name and its description. These attributes need to be modified manually by
editing the project files. Be aware that changing the project name may require the
modification of several project files including source files. Furthermore, the
project name is used to identify the project within the lab and possibly even externally.
Therefore, it should be fixed as early as possible. In order to change the project
description, simply edit the  :ref:`BasisProject.cmake <BasisProject>` file which you can find
in the top directory of the source tree. Specifically, the argument for the
``DESCRIPTION`` option of the `basis_project()`_ function.

Hence, in order to modify an existing project, the ``--name`` and
``--description`` options cannot be used. Instead, use the ``--root``
option to specify the root directory of the source tree of the project you want
to modify or run the command without either of these options with the root directory
as current working directory.

Adding Features
---------------

By features, we refer here to the set of directories and contained CMake/BASIS
configuration files for which template files exist in the BASIS project template.
For a list of available project features, please have a look at the help output of
``basisproject``. You can either select a pre-configured project template consisting
of a certain set of directories and configuration files and optionally modify these
sets by removing features from them and/or adding other features, or you can simply
remove and/or add selected features only from/to the current set of directories and
configuration files which already exist in the project's source tree.

For example, if you created a project using the standard project template
(i.e., by supplying no particular option or the option ``--standard`` during
the project creation), but your software requires auxiliary data such as a
pre-computed lookup table or a medical image atlas, you can add the ``data/``
directory in which these auxiliary files should be stored in the source tree using
the command::

    basisproject update --data

As another example, if you want to extend the default :ref:`script configuration file <ScriptConfig>`
which is used to configure the build of scripts written in Python, Perl, BASH, or any
other scripting language (even if not currently supported by BASIS will it likely
still be able to "build" these), use the command::

    basisproject update --config-script


Removing Features
-----------------

For example, in order to remove the ``conf/Settings.cmake`` file and the ``example/``
directory tree, run the command::

    basisproject update --noconfig-settings --noexample

If any of the project files which were initially added during the project creation
differ from the original project file, the removal of such files will fail with
an error message. If you are certain that the changes are not important and still
want to remove those files from the project, use the ``--force`` option.
Moreover, if a directory is not empty, it will only be removed if the ``--force``
option is given. Note that a directory is also considered empty if it only contains
hidden subdirectories which are used by the revision control software to manage
the revisions of the files inside this directory, i.e., the ``.svn/`` subdirectory
in case of Subversion or the ``.git/`` subdirectory in case of Git. Before using the
``--force`` option, you should be certain which directories would be removed and if
their content is no longer needed. Thus, run any command first without the ``--force``
option, and only if it failed consider to add the ``--force`` option.


Adding Dependencies
-------------------

A dependency is either a program required by your software at runtime or an external
software package such as the nifticlib_ or ITK_. ``basisproject`` can be used to add
the names of packages your project depends on to the lists of dependencies which are
given as arguments to the `basis_project()`_ command. For each named package in this
list, the `basis_find_package()`_ command is called to look for a corresponding
package installation. In order to understand how CMake searches for external software
packages, please read the documentation of CMake's `find_package()`_ command.

The BASIS package provides so-called `Find modules`_ (e.g., `FindMATLAB.cmake`_ or
`FindNiftiCLib.cmake`_) for external software packages which are commonly used
at SBIA and not (yet) part of CMake or improve upon the standard modules. If you have
problems resolving the dependency on an external software package required by your
software due to a missing corresponding Find module, please contact the maintainer of
the BASIS project and state your interest in a support by BASIS for this particular
software package. Alternatively, you can write such Find module yourself and save it
in the `PROJECT_CONFIG_DIR`_ of your project.

As an example on how to add another dependency to an existing BASIS project,
consider the following scenario. We created a project without any dependency and now
notice that we would like to make use of ITK in our implementation.
Thus, in order to add CMake code to the build configuration to resolve the dependency
on ITK, which also includes the so-called Use file of ITK (named ``UseITK.cmake``)
to import its build configuration, run the command::

    basisproject update --use ITK

If your project can optionally make use of the features of a certain external software
package, but will also built and run without this package being installed, you can use
the ``--useopt`` option to exploit CMake code which tries to find the software package,
but will not cause CMake to fail if the package was not found. In this case, you will
need to consider the ``<Pkg>_FOUND`` variable in order to decide whether to make use of
the software package or not. Note that the package name is case sensitive and that the
case must match the one of the first argument of `basis_find_package()`_.

For example, let's assume your software can optionally make use of CUDA.
Therefore, as CMake includes already a ``FindCUDA.cmake`` module, we can run the
following command in order to have CMake look for an installation of the CUDA libraries::

    basisproject update --useopt CUDA

If this search was successful, the CMake variable ``CUDA_FOUND`` will be ``TRUE``,
and ``FALSE`` otherwise.

Another example of a dependency on an external package is the compilation of
MATLAB source files using the `MATLAB Compiler`_ (MCC). In this case, you need to
add a dependency on the MATLAB package. Please note that it is important to capitalize
the package name and not to use ``Matlab`` as this would refer to the ``FindMatlab.cmake``
module included with CMake. The `FindMATLAB.cmake`_ module which we are using is included
with BASIS. It improves the way CMake looks for a MATLAB installation and furthermore
looks for executables required by BASIS, such as in particular ``matlab``, ``mcc``, and
``mex``. Use the following command to add a dependency on MATLAB::

    basisproject update --use MATLAB


Removing Dependencies
---------------------

``basisproject`` does not currently support the removal of previously added
dependencies. Therefore, please edit the  :ref:`BasisProject.cmake <BasisProject>` file manually
and simply remove all CMake code referring to the particular package you do no
longer require or use.


.. _HowToModularizeAProject:

Modularize a Project
====================

:doc:`Project Modularization </standard/modules>` is a 
technique that aims to maximize code reusability, allowing 
components to be split up as independent modules that can 
be shared with other projects while only building and 
packaging the components that are really needed. 
Modularized projects consist of a Top Level
Project and one or more Project Modules.

Create the Top Level Project
----------------------------

First create the top-level project as follows (or simply add a ``modules/``
directory to an existing project):

.. code-block:: bash

    basisproject create --name MyToolkit --description "A modularized project." --toplevel

Create the Modules
------------------

To add modules to your Top Level project, which has a ``modules/`` 
subdirectory, change to the modules/ subdirectory of the
top-level project, and run the command:

.. code-block:: bash

    cd MyToolkit/modules
    basisproject create --name MyModule --description "A module in MyToolkit." --module
    
More than one module can be in the same folder:

.. code-block:: bash

    basisproject create --name OtherModule --description "Another module in MyToolkit." --module

You may also add an existing BASIS project module to 
the ``/modules`` folder, but not another Top Level project.


Configure the build
-------------------

Configure the build system using CMake 2.8.4 or a more recent version:

.. code-block:: bash
    
    cd ../..
    mkdir build && cd build
    ccmake ../MyToolkit

- Press ``c`` to configure the project.
- Change ``CMAKE_INSTALL_PREFIX`` to ``~/local``.
- Set option ``BUILD_ALL_MODULES`` to ``ON``.
- Press ``g`` to generate the Makefiles and exit ``ccmake``.

.. seealso:: :ref:`ModuleCMakeVariables`


Build the Top Level Project and its Modules
-------------------------------------------

CMake has generated Makefiles for GNU Make. The build and installation are then thus triggered with the make command:

.. code-block:: bash
    
    make
    make install


As a result, CMake copies the built files into the installation tree as specified by the
``CMAKE_INSTALL_PREFIX`` variable.

.. _HowToUpdateAProject:

Upgrade a Project
=================

Occasionally, the project template of BASIS may be modified as the development
of BASIS progresses, you may want or need to upgrade the files from a previous
version to the current version of the template. ``basisproject`` provides the
ability to upgrade by using a three-way file comparison similar to Subversion 
to merge changes in the template files with those changes you have made to the
corresponding files of your project. If such merge fails because both the
template as well as the project file have been changed at the same lines,
a merge conflict occurs which has to be resolved manually. However,
``basisproject`` will never discard your changes. There will always be a backup of
your current project file before the automatic file merge is performed.

To upgrade the project files, run the following command in the root directory
of your project's source tree::

    basisproject upgrade

If the project template has not been changed since the last upgrade, no files
will be modified by this command.


.. _HowToResolveProjectUpdateConflicts:

Resolving Merge Conflicts
-------------------------

When the same lines of the template file as well as the project file have
been modified since the creation or last update of the project, you will
get a merge conflict. A merge conflict results in a merged project file
which contains the changes of both the template and your current project
file. Markers such as the following are used to highlight the lines of
the merged file which are in conflict with each other.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{1.75cm}|p{13.75cm}|

===========   =================================================================
  Marker                                Description
===========   =================================================================
``<<<<<<<``   Marks the start of conflicting lines. This marker is followed by
              your changes from the corresponding lines of your project file.
``|||||||``   Marks the start of the corresponding lines from the original
              template file which was used to create the project or which the
              project has been updated to last.
``=======``   Marks the start of the corresponding lines from the current
              template file, i.e., the one the project file should be updated
              to.
``>>>>>>>``   Marks the end of the conflicting lines.
===========   =================================================================


In order to resolve the conflicts in one file, you have to edit the merged
project file manually. For reference, ``basisproject`` writes the new template
file to a file named like the project file in conflict with this project file,
using .template as file name suffix. It further keeps a backup of your current
project file before the update. The file name suffix for this backup file is
``.mine``. For example, if conflicts occured when updating the ``README.txt``
file, the following files are written to your project's directory.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{4cm}|p{11.5cm}|

=======================   ==========================================================
      File Name                                 Description
=======================   ==========================================================
``README.txt.mine``       A copy of the project file before the update.
``README.txt.template``   A copy of the current template file which differs from
                          the template file used to create the project or
                          corresponds to the version of the template file of the
                          last update.
``README.txt``            The file containing changes from both the
                          ``README.txt.template`` and ``README.txt.mine`` file,
                          where conflicts have been highlighted using above markers.
=======================   ==========================================================


After you edited the project files which contain conflicts, possibly using
merge tools installed on your system, you need to remove the ``.template`` and
``.mine`` files to let ``basisproject`` know that the conflicts are resolved.
Otherwise, when you run the update command again, it will fail with an
error message indicating that there are unresolved merge conflicts.
You can delete those files either manually or using the following command
in the root directory of your project's source tree.

::

    basisproject upgrade --cleanup


.. _basis_project(): https://cmake-basis.github.io/apidoc/latest/group__CMakeAPI.html#gad82d479d14499d09c5aeda3af646b9f6
.. _basis_find_package(): https://cmake-basis.github.io/apidoc/latest/group__CMakeAPI.html#gac9a1326ff8b06b17aebbb6b852ca73af
.. _find_package(): http://www.cmake.org/cmake/help/v2.8.8/cmake.html#command:find_package
.. _Find modules: https://cmake-basis.github.io/apidoc/latest/group__CMakeFindModules.html
.. _FindMATLAB.cmake: https://cmake-basis.github.io/apidoc/latest/FindMATLAB_8cmake.html
.. _FindNiftiCLib.cmake: https://cmake-basis.github.io/apidoc/latest/FindNiftiCLib_8cmake.html
.. _MATLAB Compiler: http://www.mathworks.com/products/compiler/
.. _nifticlib: http://niftilib.sourceforge.net/
.. _PROJECT_CONFIG_DIR: https://cmake-basis.github.io/apidoc/latest/group__BasisDirectories.html#ga6eca623aced1386555dcea2557fb8747
.. _ITK: http://www.itk.org/
.. _ITK 4 Modularization: http://www.vtk.org/Wiki/ITK/Release_4/Modularization
.. _VTK: http://www.vtk.org/
