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

Clone the `Git <http://git-scm.com/>`__ repository from `GitHub <https://github.com/schuhschuh/cmake-basis/>`__ as follows:

.. code-block:: bash
    
    mkdir -p ~/local/src
    cd ~/local/src
    git clone https://github.com/schuhschuh/cmake-basis.git
    cd cmake-basis
    
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
- Set option ``BUILD_EXAMPLE`` to ``ON``.
- Make sure that option ``BUILD_PROJECT_TOOL`` is enabled.
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
    
    setenv PATH "~/local/bin:${PATH}"
    setenv BASIS_EXAMPLE_DIR "~/local/share/basis/example"
    setenv HELLOBASIS_RSC_DIR "${BASIS_EXAMPLE_DIR}/hellobasis"

Using the Bourne Again SHell (bash):

.. code-block:: bash
    
    export PATH="~/local/bin:${PATH} "
    export BASIS_EXAMPLE_DIR="~/local/share/basis/example"
    export HELLOBASIS_RSC_DIR="${BASIS_EXAMPLE_DIR}/hellobasis"


Create an Example Project
-------------------------

Create a new and empty project as follows:

.. code-block:: bash
    
    basisproject create --name HelloBasis --description "This is a BASIS project."
                 --root ~/local/src/hellobasis

The next command demonstrates that you can modify a previously created project by using the
project tool again:

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
    
    basis_add_executable(hellocpp helloc++.cxx)

Alternatively, you can use the implementation of this example executable in
Python, Perl, BASH or MATLAB. In case of MATLAB, add also a dependency to MATLAB:
 
.. code-block:: cmake

    basisproject update --root ~/local/src/hellobasis --use MATLAB

Change target properties
~~~~~~~~~~~~~~~~~~~~~~~~

- The name of the output file is given by the ``OUTPUT_NAME`` property.
- To change this property, add the following line to the ``src/CMakeLists.txt`` file
  (**after** ``basis_add_executable``):

.. code-block:: cmake
    
    basis_set_target_properties(hellocpp PROPERTIES OUTPUT_NAME "hellobasis")

If you used a target name other than hellocpp, you need to replace it with the name you chose.

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
    
    basis_add_library(foo.cxx)

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
    
    basis_add_library(bar.cxx)
    
Add a scripted module
~~~~~~~~~~~~~~~~~~~~~

Copy the example Perl module to ``src/``:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/FooBar.pm.in src/

Add the following line to ``src/CMakeLists.txt`` under the section "library target(s)":

.. code-block:: cmake
    
    basis_add_library(FooBar.pm)


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

Next Steps
----------

Congratulations! You just finished your first BASIS tutorial.

So far you have already learned how to install BASIS on your system and set up
your own software project. You have also seen how you can add your own source
files to your newly created project and build the respective executables
and libraries. The essentials of any software package! Thanks to BASIS, only
few lines of CMake code are needed to accomplish this.

Now check out the :ref:`Tutorials` for more details regarding each of the
above steps and in-depth information about the used BASIS commands
if you like, or move on to the various :doc:`How-to Guides <howto>` which
will introduce you to even more BASIS concepts and best practices.


.. _Tutorials:

Advanced Tutorials
==================

The tutorial slides linked here for download give a slide-by-slide introduction to BASIS and
its use including in-depth information and references to further documentation. For a less
comprehensive tutorial-like introduction, please refer to the :ref:`FirstSteps` above.

0. Download :download:`BASIS Introduction <BASIS_Introduction.pptx>` for an explanation of the components and purpose of BASIS
   (`ref <http://opensource.andreasschuh.com/cmake-basis/_downloads/BASIS_Introduction.pptx>`__).
1. Download :download:`Getting Started <tutorials/BASIS Tutorial - 01 Getting Started.pptx>`
   (`ref <http://opensource.andreasschuh.com/cmake-basis/_downloads/BASIS%20Tutorial%20-%2001%20Getting%20Started.pptx>`__)


.. _basis_project(): http://opensource.andreasschuh.com/cmake-basis/apidoc/latest/group__CMakeAPI.html#gad82d479d14499d09c5aeda3af646b9f6

.. The ref link is required for the PDF version as the download directive in
   this case does not translate to a hyperlink, but text only.

