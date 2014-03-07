.. meta::
    :description: This article details the project modularization implemented by
                  BASIS, a build system and software implementation standard.

======================
Project Modularization
======================

Project modularization is a technique that aims to maximize 
code reusability, allowing components to be split up as
independent modules that can be shared with other projects,
while only building and packaging the components that are
really needed.

.. _TopLevelProjectDefinition:

**Top Level Project**

A top level project is a project that is split into separate 
independent subprojects, and each of those subprojects are 
referred to as modules. A top level project will often have 
no source files of its own, simply serving as a lightweight 
container for its modules.


.. _ProjectModuleDefinition:

**Project Module**

A (project) module is a completely independent BASIS project with its
own dependencies that resides in the ``modules/`` directory of a top-level project.
Each module will often reside in a separate repository that is designed 
to be shared with other projects.

Because modules are usually developed by the same development team,
name conflicts are uncommon and can be avoided by appropriate naming
conventions. Therefore, all modules share a common *namespace*,
namely the one of the top-level project.

For example, if ``BASIS_USE_TARGET_UIDS`` is enabled in ``config/Settings.cmake``
of the top-level project, the actual build target names of the top-level
project and its modules are of the form ``<toplevel>.<target>``, where
``<toplevel>`` is the package name of the top-level project which usually
is the same as the name of the top-level project, and ``<target>`` is
the target name argument of :apidoc:`basis_add_executable()` or
:apidoc:`basis_add_library()`.
Note that if ``BASIS_USE_FULLY_QUALIFIED_TARGET_UIDS`` is disabled (the default),
the ``<toplevel>`` part is only used for the export of the target.

The :apidoc:`basis_project()` call of a module must use the ``NAME``
parameter to set the name of the module (instead of ``SUBPROJECT``).


.. _SubprojectDefinition:

**Subproject**

A subproject is very similar to a project module with a few important differences.
While project modules are lightweight subprojects which are tightly integrated
into the top-level project, subprojects are more self-sustained and should
be treated as separate smaller projects. The top-level project serves as
meta-project to group multiple subprojects. A use case would be to bundle several
more or less independent software projects in a single package. The top-level
project can be thus be seen as collection of related software packages,
which may or may not depend on each other.

Because subprojects are usually developed by different development teams,
name conflicts are more likely to occur. Therefore, each subproject has
its own (nested) *namespace* inside the namespace of the package it belongs
to, whereas the symbols of modules have no own namespace, but are directly
defined within the namespace of the top-level project.

For example, if ``BASIS_USE_TARGET_UIDS`` is enabled in ``config/Settings.cmake``
of the top-level project, the actual build target names are of the form
``<package>.<subproject>.<target>``, where ``<package>`` is the package name
of the subproject which corresponds to the package name of the top-level 
project if not specified, and ``<target>`` is the target name argument
of :apidoc:`basis_add_executable()` or :apidoc:`basis_add_library()`.
Note that if ``BASIS_USE_FULLY_QUALIFIED_TARGET_UIDS`` is disabled (the default),
the ``<package>`` part is only used for the export of the target.

Other differences are that BASIS will install separate uninstaller scripts
for each subproject and also register each subproject installation if
:option:`-DBASIS_REGISTER` is enabled. Therefore, a subproject which is
installed by one package can be used directly by other packages as if
the subproject was installed separate from the other subprojects and
modules of the top-level project.

The :apidoc:`basis_project()` call of a subproject must use the ``SUBPROJECT``
parameter to set the name of the subproject (instead of ``NAME``).
Additionally, as subprojects are likely shared by multiple top-level
projects, it is recommended to set the ``PACKAGE_NAME`` (short ``PACKAGE``)
to the name of the package which this subproject belongs to primarily.
Note that this package need not actually exist. By providing this
package name, the namespace of the subproject will always be the same
no matter what the name of the top-level project is.

.. note::

   It should be noted that the concept of a *namespace* can be extended to all aspects of a
   software project, not only symbols of programming languages which have it built in such
   as C++. Therefore, the *symbols* which belong to the package namespace include project
   modules, target names, C++ classes and functions, as well as scripted libraries.

.. seealso:: See :ref:`HowToModularizeAProject` for usage instructions and :doc:`template` for a reference implementation.


Filesystem Layout
=================

By default each module is placed in its own ``modules/<module_name>`` 
subdirectory, but this can be configured in ``config/Settings.cmake`` by 
modifying the ``PROJECT_MODULES_DIR`` variable. More details can be found in 
the :doc:`/standard/fhs`.

The Top Level project often excludes the ``src/`` subdirectory,
and instead includes the ``modules/`` directory where the 
project's modules reside.

Dependency Requirements
=======================

There are several features and limitations when one top level or subproject uses code from another.

 - Modules may depend on each other. 
 - Each module of a top level project may depend on other modules of the same project, or external projects and packages. 
 - Only one level of submodules are allowed in a top level project
 - An external project can also be another top-level project with its own modules.

.. _ModuleCMakeVariables:

Module CMake Variables
======================

CMake variables available to any project utilizing BASIS. These options can 
be modified with the ``ccmake`` command. :doc:`/howto/cmake-options` describes 
other important CMake options.

.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{5cm}|p{10.5cm}|

============================     =============================================================================================
    CMake Variable                              Description
============================     =============================================================================================
``MODULE_<module>``              Builds the module named ``<module>`` when set to ``ON`` and excludes it when ``OFF``.
                                 It is automatically set to ``ON`` if it is required by another module that is ``ON``.
``BUILD_MODULES_BY_DEFAULT``     Sets the default state of each ``MODULE_<module>`` switch. ``ON`` by default.
``BUILD_ALL_MODULES``            Global switch enabling the build of all modules. Overrides all ``MODULE_<module>`` variables.
``PROJECT_IS_MODULE``            Specifies if the current project is a module of another project.
============================     =============================================================================================

It is recommended that customized defaults for these variables be set in :ref:`config/Settings.cmake <Settings>`.

Implementation
==============

The modularization is mainly implemented with the following hierarchy presented
in the same manner as a stack trace with the top function being the last function
called:

    - :apidoc:`ProjectTools.cmake`     - :apidoc:`basis_project_modules()`
    - :apidoc:`ProjectTools.cmake`     - :apidoc:`basis_project_begin()`
    - :apidoc:`BasisProject.cmake`     - script file that is executed directly
    - ``CMakeLists.txt``               - root file of any CMake project

The script then takes the following steps:

1. The :apidoc:`basis_project_modules()` function searches the subdirectories in the 
   ``modules/`` directory for the presence of the :apidoc:`BasisProject.cmake` file. 
2. :apidoc:`BasisProject.cmake` is then loaded to retrieve the meta-data of each module 
   such as its name and dependencies. 
3. A ``MODULE_<module>`` option is added to the build configuration for each module and
   module dependencies are defined that correspond to the settings in :apidoc:`BasisProject.cmake`. 
   This enables the eventual execution of the build step to be in the correct topological order.
   The ``MODULE_<module>`` settings obey the following constraints:

     - When ``OFF`` the module is excluded from both the project build and any package generated by CPack_. 
     - When ``ON`` the module builds as part of the top-level project.
     - If one module requires another, the required module will automatically be set to ``ON``.
     - All ``MODULE_<module>`` options are superceded by the ``BUILD_ALL_MODULES`` when it is set to ``ON``.

Besides adding these options, the :apidoc:`basis_project_modules()`
function ensures that the modules are configured with the right dependencies
so that the generated build files will compile them correctly. 

It also helps the :apidoc:`basis_find_package()` function find the other modules' package 
configuration files, which are either generated from the default
:apidoc:`Config.cmake.in <BASISConfig.cmake>` file or a corresponding file found
in the ``config/`` directory of each module.

The other BASIS CMake functions may also change their actual behaviour
depending on the ``PROJECT_IS_MODULE`` variable, which specifies whether the
project that is currently being configured is a module of another project
(i.e., ``PROJECT_IS_MODULE`` is ``TRUE``) or a top-level project
(i.e., ``PROJECT_IS_MODULE`` is ``FALSE``).

Origin
------

The modularization concepts and part of the CMake implementation
are from the `ITK 4`_ project. See the Wiki of this project for 
details on the `ITK 4 Modularization`_.


Reuse
=====

Modules can be built standalone without a Top Level Project. 

This is why the :apidoc:`BasisProject.cmake` meta-data requires an explicit ``PACKAGE_NAME``.
When you configure the build system of a project module directly, i.e.,
by using the module's subdirectory as root of the source tree, it will still
build as if it was part of a Top Level Project with name equal to the ``PACKAGE_NAME``
of the project.

The explicit package name is also important for the executable (target) referencing
that is used for subprocess invocations covered in :doc:`/standard/execution`.
A developer can use the target name (e.g., basis.basisproject) in the BASIS utility
functions for executing a subprocess, and the path to the actually installed binary
is resolved by BASIS. This allows the developer of the respective module to change
the location/name of a binary file through the CMake configuration and other code
which uses this module's executable can still call it by its unchanged build target name.
As the target name includes the package name of a project to avoid name conflicts
among packages, the package name which a module belongs to must be known even if
the module is build independently without any Top Level Project.


.. _SuperBuildOfModules:

Superbuild
==========

.. todo:: Finalize superbuild of modules and document it.

.. note:: **The superbuild of project modules is yet experimental and not fully documented!**

CMake's ExternalProject_ module is sometimes used to create a superbuild,
where components of a software or its external dependencies are compiled separately.
This has already been done with several projects.

An experimental superbuild of project modules is implemented by the :apidoc:`basis_add_module`
function. It is disabled by default, i.e. each module is configured right away using
``add_subdirectory``. The :option:`-DBASIS_SUPERBUILD_MODULES` option can be used to
enable the superbuild of modules. This can dramatically speed up the build system
configuration for projects which contain a large number of modules, because the
configuration of each module is deferred until the build step. Moreover, only modules
which were modified since the last build will be reconfigured when the top-level project
is re-build. Without the superbuild approach, the entire build system of the top-level
project needs to be reconfigured in such case.

If the superbuild of modules should always be enabled, add the following
CMake code to ``config/Settings.cmake``:

.. code-block:: cmake

    if (NOT BASIS_SUPERBUILD_MODULES)
      set (
        BASIS_SUPERBUILD_MODULES ON CACHE BOOLEAN
          "This project always builds the modules using a superbuild approach."
        FORCE
      )
      message (WARNING "Option BASIS_SUPERBUILD_MODULES set to ON as this project"
                       " always builds its modules using a superbuild approach."
                       " The BASIS_SUPERBUILD_MODULES option cannot be changed.")
    endif ()

Alternatively, the following line would be sufficient as well without feedback for the user:

.. code-block:: cmake

    set (BASIS_SUPERBUILD_MODULES OFF)

.. seealso:: A superbuild can also take care of building BASIS itself if it is not
             installed on the system, as well as any other external library that is
             specified as dependency of the project.
             See the :ref:`Superbuild of BASIS and other dependencies <SuperBuildOfDependencies>`.


.. _ITK 4:                http://www.itk.org/Wiki/ITK_Release_4
.. _ITK 4 Modularization: http://www.vtk.org/Wiki/ITK_Release_4/Modularization
.. _CPack:                http://www.cmake.org/cmake/help/v2.8.8/cpack.html
.. _ExternalProject:      http://www.cmake.org/cmake/help/v2.8.12/cmake.html#module:ExternalProject
