.. _QuickStartGuides:

===========
Quick Start
===========


.. _FirstSteps:

First Steps
===========

The following tutorial-like quick start guides aim to introduce you to BASIS and
help you to get started as quickly as possible. When you are ready for more details,
you can try out the :ref:`Tutorials` below.

.. 1. :download:`Getting Started <tutorials/BASIS Quick Start Guide - 01 Getting Started.pptx>`
   (`ref <http://opensource.andreasschuh.com/cmake-basis/_downloads/BASIS%20Quick%20Start%20Guide%20-%2001%20Getting%20Started.pptx>`__)


.. _FirstStepsIntro:
.. _GettingStarted:

Getting Started
---------------

The following brief sections will demonstrate

- how to download and install BASIS on your system.
- how to use the so-called “basisproject” command line tool to create a new empty project.
- how to add some example source files and edit the build configuration files to build the executable and library files.
- how to build and test the example project.
- where to find more detailed and advanced documentation.

To follow these steps, you need to have a Unix-like operating system such as Linux or Mac OS X.
At the moment, there is no separate tutorial available for Windows users, but you can install
CygWin as an alternative.

.. note::

  BASIS can also be installed and used on Windows.
  The tools for :doc:`automated software tests <howto/run-automated-tests>` are, however, only available for Unix.


Install BASIS
-------------

Get a copy of the sources
~~~~~~~~~~~~~~~~~~~~~~~~~

Download either a pre-packaged ``.tar.gz`` of the latest BASIS release and unpack it using the following command:

.. code-block:: bash

    mkdir -p ~/local/src
    cd ~/local/src
    tar xzf /path/to/downloaded/cmake-basis-$version.tar.gz
    cd cmake-basis-$version

or clone the Git repository as follows:

.. code-block:: bash
    
    mkdir -p ~/local/src
    cd ~/local/src
    git clone https://github.com/schuhschuh/cmake-basis.git
    cd cmake-basis

Configure the build
~~~~~~~~~~~~~~~~~~~

Configure the build system using CMake 2.8.4 or a more recent version:

.. code-block:: bash
    
    mkdir build && cd build
    ccmake ..

- Hit ``c`` to configure the project.
- Change ``INSTALL_PREFIX`` to ~/local.
- Hit ``g`` to generate the Makefiles.

Build and install BASIS
~~~~~~~~~~~~~~~~~~~~~~~

CMake has generated Makefiles for GNU Make. The build is thus triggered by the make command:

.. code-block:: bash
    
    make

To install BASIS after the successful build, run the following command:

.. code-block:: bash
    
    make install

As a result, CMake copies the built files into the installation tree as specified by the
``INSTALL_PREFIX`` variable.

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


Create Example Project
----------------------

Create a new and empty project as follows:

.. code-block:: bash
    
    basisproject --name HelloBasis --description "This is a BASIS project." --root ~/local/src/hellobasis

The next command demonstrates that you can modify a previously created project by using the
project tool again:

.. code-block:: bash
    
    basisproject --root ~/local/src/hellobasis --noexample --config-settings

Here we removed the ``example/`` subdirectory and added some configuration file used by BASIS.
These options could also have been given to the initial command above instead.

.. note:: More details on how to use ``basisproject`` are given by the :doc:`howto/create-and-modify-project` How-to Guide.


Install Your Project
--------------------

The build and installation of the just created empty example project is identical to the build
and installation of BASIS itself:

.. code-block:: bash
    
    mkdir ~/local/src/hellobasis/build
    cd ~/local/src/hellobasis/build
    cmake -D INSTALL_PREFIX=~/local ..
    make

.. note:: More details on build and installation are given by the :doc:`howto/install` How-to Guide.


Add an Executable
-----------------

Copy the source file from the example to ``src/``:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/helloc++.cxx src/

Add the following line to ``src/CMakeLists.txt`` under the section "executable target(s)":


.. code-block:: cmake
    
    basis_add_executable(helloc++.cxx)


.. note::

  Alternatively, you can use the implementation of this example executable in
  Python, Perl, BASH or MATLAB. In case of MATLAB, add also a dependency to MATLAB:
  
    basisproject --root ~/local/src/hellobasis --use MATLAB

Change target properties
~~~~~~~~~~~~~~~~~~~~~~~~

- The name of the output file is given by the ``OUTPUT_NAME`` property.
- To change this property, add the following line to the ``src/CMakeLists.txt`` file
  (**after** ``basis_add_executable``):

.. code-block:: cmake
    
    basis_set_target_properties(helloc++ PROPERTIES OUTPUT_NAME  "hellobasis")

.. note:: If you used another example, you need to replace helloc++ by the name of the
          source file you used excluding the extension.

Test the Executable
~~~~~~~~~~~~~~~~~~~

Now build the executable and test it:

.. code-block:: bash
    
    cd ~/local/src/hellobasis-build
    make
    bin/hellobasis
    How is it going?

.. note:: As you configured the build system before using CMake, we only need to run GNU Make. CMake will recognize the change of src/CMakeLists.txt and reconfigure the build system automatically.

Install the executable and test it:

.. code-block:: bash
    
    make install
    helloworld
    How is it going?

.. note:: The symbolic link named helloworld is in ``~/local/bin/`` which is already in our search path for executables (PATH).


Add Libraries
-------------

Next, you will add a three kinds of libraries, i.e., collections of binary or script code, to your example project.
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
    basisproject --root . --include

Copy the files from the example. The public interface is given by ``bar.h``.

.. code-block:: bash
    
    cp ${HELLOBASIS_RSC_DIR}/bar.cxx src/
    cp ${HELLOBASIS_RSC_DIR}/bar.h include/sbia/hellobasis/

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

Conclusion
----------

**Congratulations, You just finished your first BASIS Quick Start Guide!**

If above steps were to concise and thus not clear enough or you would simply like to know more,
have also a look at the :ref:`Tutorials` which give many more details about each of these steps.


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


.. The ref link is required for the PDF version as the download directive in
   this case does not translate to a hyperlink, but text only.

