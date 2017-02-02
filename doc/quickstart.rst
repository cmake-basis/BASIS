.. _QuickStartGuides:

===========
Quick Start
===========


.. _FirstSteps:
.. _FirstStepsIntro:

First Steps
===========

The following steps will show you how to

- download and install BASIS on your system.
- use the so-called “basisproject” command line tool to create a new empty project.
- add some example source files and edit the build configuration files to build the executable and library files.
- build and test the example project.

You need to have a Unix-like operating system such as Linux or Mac OS X installed on your
machine in order to follow these steps. At the moment, there is no separate tutorial
available for Windows users, but you can install CygWin as an alternative.
Note, however, that BASIS can also be installed and used on Windows.
Only the tools for :doc:`automated software tests <howto/run-automated-tests>` will not
be available then. These tools are for advanced users who want to set up an automated
software build and test on dedicated test machines. The testing tools are not needed
for what follows.


Install BASIS
-------------

Get a copy of the source code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Clone the `Git <http://git-scm.com/>`__ repository from `GitHub <https://github.com/cmake-basis/BASIS/>`__ as follows:

.. code-block:: bash
    
    mkdir -p ~/local/src
    cd ~/local/src
    git clone --depth=1 https://github.com/cmake-basis/BASIS.git basis
    cd basis
    
or :doc:`download` a pre-packaged ``.tar.gz`` of the latest BASIS release and unpack it using the following command:

.. code-block:: bash

    mkdir -p ~/local/src
    cd ~/local/src
    tar xzf /path/to/downloaded/cmake-basis-$version.tar.gz
    cd cmake-basis-$version


Configure the build
~~~~~~~~~~~~~~~~~~~

Configure the build system using CMake 2.8.4 or a more recent version:

.. code-block:: bash
    
    mkdir build && cd build
    ccmake ..

- Press ``c`` to configure the project.
- Change ``CMAKE_INSTALL_PREFIX`` to ``~/local``.
- Set options ``BUILD_APPLICATIONS`` and ``BUILD_EXAMPLE`` to ``ON``.
- Press ``g`` to generate the Makefiles and exit ``ccmake``.

Build and install BASIS
~~~~~~~~~~~~~~~~~~~~~~~

CMake has generated Makefiles for GNU Make. The build is thus triggered by the make command:

.. code-block:: bash
    
    make

To install BASIS after the successful build, run the following command:

.. code-block:: bash
    
    make install

As a result, CMake copies the built files into the installation tree as specified by the
``CMAKE_INSTALL_PREFIX`` variable.

.. _GettingStartedEnvironment:

Set up the environment
~~~~~~~~~~~~~~~~~~~~~~

For the following tutorial steps, set up your environment as follows. In general, however,
only the change of the ``PATH`` environment variable is recommended. The other environment
variables are only needed for the tutorial sessions.

Using the C or TC shell (csh/tcsh):

.. code-block:: bash
    
    setenv PATH "${HOME}/local/bin:${PATH}"
    setenv BASIS_EXAMPLE_DIR "${HOME}/local/share/basis/example"
    setenv HELLOBASIS_RSC_DIR "${BASIS_EXAMPLE_DIR}/hellobasis"

Using the Bourne Again SHell (bash):

.. code-block:: bash
    
    export PATH="${HOME}/local/bin:${PATH} "
    export BASIS_EXAMPLE_DIR="${HOME}/local/share/basis/example"
    export HELLOBASIS_RSC_DIR="${BASIS_EXAMPLE_DIR}/hellobasis"


Create an Example Project
-------------------------

Create a new and empty project as follows:

.. code-block:: bash
    
    basisproject create --name HelloBasis --description "This is a BASIS project." \
                 --root ~/local/src/hellobasis

The next command demonstrates that you can modify a previously created project by using the
project tool again, this time with the `update` command.

.. code-block:: bash
    
    basisproject update --root ~/local/src/hellobasis --noexample --config-settings

Here we removed the ``example/`` subdirectory and added some configuration file used by BASIS.
These options could also have been given to the initial command above instead.

.. seealso:: The guide on how to :doc:`howto/create-and-modify-project`, :ref:`BasisProject.cmake <BasisProject>`, and `basis_project()`_.


Install Your Project
--------------------

The build and installation of the just created empty example project is identical to the build
and installation of BASIS itself:

.. code-block:: bash
    
    mkdir ~/local/src/hellobasis/build
    cd ~/local/src/hellobasis/build
    cmake -D CMAKE_INSTALL_PREFIX=~/local ..
    make

.. seealso:: The guide on how to :doc:`howto/install`.


Add an Executable
-----------------

Copy the source file from the example to ``src/``:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/helloc++.cxx src/

Add the following line to ``src/CMakeLists.txt`` under the section "executable target(s)":

.. code-block:: cmake
    
    basis_add_executable(helloc++.cxx)

Alternatively, you can use the implementation of this example executable in
Python, Perl, BASH or MATLAB. In case of MATLAB, add also a dependency to MATLAB:
 
.. code-block:: cmake

    basisproject update --root ~/local/src/hellobasis --use MATLAB

.. note:: The ``basis_add_executable`` command, if given only a single (existing)
          source code file or directory as argument, uses the name of this source
          file without extension or the name of the directory containing all
          source files of the executable, respectively, as the build target name.

Change target properties
~~~~~~~~~~~~~~~~~~~~~~~~

- The name of the output file is given by the ``OUTPUT_NAME`` property.
- To change this property, add the following line to the ``src/CMakeLists.txt`` file
  (**after** ``basis_add_executable``):

.. code-block:: cmake
    
    basis_set_target_properties(helloc++ PROPERTIES OUTPUT_NAME "hellobasis")

If you used another source file, you need to replace "helloc++" by its name (excl. the extension).

Test the Executable
~~~~~~~~~~~~~~~~~~~

Now build the executable from the previously added source code. As the build system
has been configured before using CMake, only GNU ``make`` has to be invoked.
It will recognize the change of the ``CMakeLists.txt`` file and therefore reconfigure
the build system before re-building the software.

.. code-block:: bash
    
    cd ~/local/src/hellobasis/build
    make
    bin/hellobasis
    How is it going?

Install the executable and test it:

.. code-block:: bash
    
    make install
    hellobasis
    How is it going?

Note that the ``hellobasis`` executable was installed into the ``~/local/bin/`` directory
as we set the installation root directory to ``~/local`` using the ``CMAKE_INSTALL_PREFIX``
CMake variable. This directory should be listed in your *PATH* environment variable
when you followed the :ref:`environment set up <GettingStartedEnvironment>` steps at the
begin of this tutorial.


Add Libraries
-------------

Next, you will add three kinds of libraries, i.e., collections of binary or script code, to your example project.
We distinguish here between private, public, and script libraries. A private library is a library without
public interface which is only used by other libraries and in particular executables of the project itself.
A public library provides a public interface for users of your software. Therefore, the declarations of
the interface given by ``.h`` files in case of C/C++ are copied to the installation directory along with
the binary library file upon installation. Another kind of library is one written in a scripting
language such as Python, Perl, or BASH. Such library is more commonly referred to as *module*.

Add a private library
~~~~~~~~~~~~~~~~~~~~~

Copy the files from the example to ``src/``:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/foo.* src/

Add the following line to ``src/CMakeLists.txt`` under the section "library target(s)":

.. code-block:: cmake
    
    basis_add_library(foo foo.cxx)

Add a public library
~~~~~~~~~~~~~~~~~~~~

Create the subdirectory tree for the public header files declaring the public interface:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    basisproject update --root . --include
    mkdir include/hellobasis

Copy the files from the example. The public interface is given by ``bar.h``.

.. code-block:: bash
    
    cp ${HELLOBASIS_RSC_DIR}/bar.cxx src/
    cp ${HELLOBASIS_RSC_DIR}/bar.h include/hellobasis/

Add the following line to ``src/CMakeLists.txt`` under the section "library target(s)":

.. code-block:: cmake
    
    basis_add_library(bar bar.cxx)

Add a scripted module
~~~~~~~~~~~~~~~~~~~~~

Copy the example Perl module to ``src/``:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/FooBar.pm.in src/

Add the following line to ``src/CMakeLists.txt`` under the section "library target(s)":

.. code-block:: cmake
    
    basis_add_library(FooBar.pm)

.. note:: Unlike C++ libraries, which are commonly build from multiple source files,
          libraries written in a scripting language are separate script module files.
          Therefore, ``basis_add_library`` can be called with only a single argument,
          the name of the library source file. The name of this source file will be used
          as build target name including the file name extension, with ``.`` replaced by ``_``.
          This is to avoid name conflicts between library modules written in different
          languages which have the same name such as, for example, the BASIS Utilities
          for Python (``basis.py``), Perl (``basis.pm``), and Bash (``basis.sh``).

.. raw:: latex

  \clearpage


The .in suffix
~~~~~~~~~~~~~~

- Note that some of these files have a ``.in`` file name suffix.
- This suffix can be omitted in the ``basis_add_library`` statement. It has however an impact on how this function treats this file.
- The .in suffix indicates that the file is not usable as is, but contains patterns such as ``@PROJECT_NAME@`` which BASIS should replace during the build of the module.
- The substitution of these ``@*@`` patterns is what we refer to as “building” script files.

Install the libraries
~~~~~~~~~~~~~~~~~~~~~

Now build the libraries and install them:

.. code-block:: bash
    
    cd ~/local/src/hellobasis/build
    make && make install


Create a Modularized Repository
-------------------------------

BASIS is designed to integrate multiple BASIS libraries as 
part of a modular build system where components can be added 
and removed with ease. A top-level repository contains one or 
more modules or sub-projects, then builds those modules based
on their dependencies.

.. seealso:: See :ref:`HowToModularizeAProject` for usage instructions,
             :doc:`/standard/template` for a reference implementation,
             and :doc:`/standard/modules` for the design.

Create a Top Level Project
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    export TOPLEVEL_DIR="${HOME}/local/src/collection"
    basisproject create --name Collection --description "This is a BASIS TopLevel project. It demonstrates a modular project organization."  --root ${TOPLEVEL_DIR}  --toplevel

Create a Sub-project Containing a Library
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a sub-project module similarly to how helloBasis was created earlier.

.. code-block:: bash

    export MODA_DIR="${HOME}/local/src/collection/modules/moda"
    basisproject create --name moda --description "Subproject library to be used elsewhere" --root ${MODA_DIR} --module --include
    cp ${HELLOBASIS_RSC_DIR}/moda.cxx ${MODA_DIR}/src/
    mkdir ${MODA_DIR}/include/moda
    cp ${HELLOBASIS_RSC_DIR}/moda.h ${MODA_DIR}/include/moda/

Add the following line to ``${MODA_DIR}/src/CMakeLists.txt`` under the section "library target(s)":

.. code-block:: cmake
    
    basis_add_library(moda SHARED moda.cxx)
    

Create a Sub-project that uses the Library
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Create a sub-project module similarly to how helloBasis was created earlier.

.. code-block:: bash
    
    export MODB_DIR="${TOPLEVEL_DIR}/modules/modb"
    basisproject create --name modb --description "User example subproject executable utility repository that uses the library"  --root ${MODB_DIR} --module --src --use moda
    cp ${HELLOBASIS_RSC_DIR}/userprog.cxx ${MODB_DIR}/src/

Add the following line to ``${MODB_DIR}/src/CMakeLists.txt`` under the section "executable target(s)":

.. code-block:: cmake
    
    basis_add_executable(userprog.cxx)
    basis_target_link_libraries(userprog moda)


Install the Projects
~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash
    
    mkdir ${TOPLEVEL_DIR}/build
    cd ${TOPLEVEL_DIR}/build
    cmake -D CMAKE_INSTALL_PREFIX=~/local -D MODULE_moda=ON -D MODULE_modb=ON  ..
    
    make install

    
Next Steps
----------

Congratulations! You just finished your first BASIS tutorial.

So far you have already learned how to install BASIS on your system and set up
your own software project. You have also seen how you can add your own source
files to your newly created project and build the respective executables
and libraries. The essentials of any software package! Thanks to BASIS, only
few lines of CMake code are needed to accomplish this.

Now check out the various :doc:`How-to Guides <howto>` which will introduce
you to even more BASIS concepts and best practices.


.. _basis_project(): https://cmake-basis.github.io/apidoc/latest/group__CMakeAPI.html#gad82d479d14499d09c5aeda3af646b9f6
