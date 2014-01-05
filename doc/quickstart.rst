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

1. :download:`Getting Started <tutorials/BASIS Quick Start Guide - 01 Getting Started.pptx>`
   (`ref <http://opensource.andreasschuh.com/cmake-basis/_downloads/BASIS%20Quick%20Start%20Guide%20-%2001%20Getting%20Started.pptx>`__)


.. _FirstStepsIntro:

Introduction
============

- Download and install BASIS on your system.
- Use the so-called “basisproject” command line tool to create a new empty project.
- Add some example source files and edit the build configuration files to build the executable and library files.
- Finally, build and test the example project.
- For a more detailed explanation of each step, have a look at the corresponding BASIS Tutorial. 


To follow the steps in this quick start guide, you need to 
have a Unix-like operating system such as Linux or Mac OS X. 

.. note:: BASIS can also be installed and used on Windows. The tools for creating a new project and for automated software tests are, however, only available for Unix.

At the moment, there is no separate tutorial available for 
Windows users, but you can install CygWin as an alternative. 
This would also allow you to use the BASIS tools which are 
not available for native Windows.


Installing BASIS
================

Get a copy of BASIS
-------------------

.. code-block:: bash
    
    mkdir -p ~/local/src
    cd ~/local/src
    git clone https://github.com/schuhschuh/cmake-basis.git

Configure BASIS
---------------

Before you can build BASIS, you need to configure it using CMake 2.8.4 or greater.

Configure the build system using CMake:

.. code-block:: bash
    
    mkdir basis-build
    cd basis-build
    ccmake ../basis

- Hit ``c`` to configure the project.
- Change ``INSTALL_PREFIX`` to ~/local.
- Disable any of the ``BUILD_*_UTILITIES`` options depending on whether you have Python or Perl installed on your system and intend to use these languages.
- Hit ``g`` to generate the Makefiles.

Build BASIS
-----------

CMake has generated Makefiles for GNU Make.

Therefore, the build is triggered by the make command:

.. code-block:: bash
    
    make

Install BASIS
-------------

To install BASIS, we “build” the install target:

.. code-block:: bash
    
    make install

As a result, CMake copies the built files into the installation tree as specified by the ``INSTALL_PREFIX`` variable.

Additionally, BASIS may create some symbolic links on Unix systems if the ``INSTALL_LINKS`` option was set to ON during the configuration of BASIS.


Setup the Environment
---------------------

Set the following environment variables:

.. code-block:: bash
    
    setenv PATH "~/local/bin:${PATH}"
    setenv BASIS_EXAMPLE_DIR "~/local/share/basis/example"
    setenv HELLOBASIS_RSC_DIR "${BASIS_EXAMPLE_DIR}/hellobasis"

Using BASH:

.. code-block:: bash
    
    export PATH="~/local/bin:${PATH} "
    export BASIS_EXAMPLE_DIR="~/local/share/basis/example"
    export HELLOBASIS_RSC_DIR="${BASIS_EXAMPLE_DIR}/hellobasis"


Creating a New Project
======================

These are the quick instructions for creating a new BASIS conforming project, you can find more detailed steps at :doc:`/howto/create-and-modify-project`.

Create a new and empty project as follows:


.. code-block:: bash
    
    basisproject --name HelloBasis	--description "This is a BASIS project. " --root ~/local/src/hellobasis

The next command demonstrates that you can modify a previously created project by using the project tool again:

.. code-block:: bash
    
    basisproject --root ~/local/src/hellobasis	--noexample --config-settings

Here we removed the example/ subdirectory and added some configuration file used by BASIS. These options could also have been given to the initial command above instead.


Installing Your Project
=======================

The build and installation of this BASIS project is identical to the build and installation of BASIS itself.

In fact, all CMake-based projects are build this way. The Build and Installation How-to summarizes these steps.

Build and install the (currently empty) project:

.. code-block:: bash
    
    mkdir ~/local/src/hellobasis-build
    cd ~/local/src/hellobasis-build
    cmake -D INSTALL_PREFIX=~/local ../hellobasis
    make


Adding Executables
==================

Copy the source file from the example to src/:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/helloc++.cxx src/

Add the following line to src/CMakeLists.txt under the section “executable target(s)”:


.. code-block:: cmake
    
    basis_add_executable (helloc++.cxx)


.. note:: Alternatively, you can use the implementation of this example executable in Python, Perl, BASH or MATLAB.

In case of MATLAB, add also a dependency to MATLAB:


.. code-block:: bash
    
    basisproject --root ~/local/src/hellobasis --use MATLAB

Change Properties
-----------------

- The name of the output file is given by the ``OUTPUT_NAME`` property.
- The name of the symbolic link is given by the ``SYMLINK_NAME`` property.
- To change these properties, add the following lines to the ``src/CMakeLists.txt`` (**after** ``basis_add_executable()``):

.. code-block:: cmake
    
    basis_set_target_properties (
        helloc++
        PROPERTIES
            OUTPUT_NAME  "hellobasis"
            SYMLINK_NAME "helloworld"
    )

.. note:: If you used another example, you need to replace helloc++ by the name of the source file you used excluding the extension.


src/CMakeLists.txt
------------------

To conclude, your src/CMakeLists.txt file should now contain CMake code similar to the following snippet:

.. code-block:: cmake
    
    basis_add_executable (helloc++.cxx)
    basis_set_target_properties (
        helloc++
        PROPERTIES
            OUTPUT_NAME  "hellobasis"
            SYMLINK_NAME "helloworld"
    )

Test the Executable
-------------------

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


Adding Libraries
================

Private Library
---------------

.. note:: A private library is a library without public interface.

Copy the files from the example to src/:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/foo.* src/

Add the following line to src/CMakeLists.txt(section “library target(s)”):

.. code-block:: cmake
    
    basis_add_library (foo.cxx)


Public Library
--------------

.. note:: A public library has an installed public interface as declared in a header.

In this case the public interface is declared in ``bar.h``.

Create the subdirectory tree for the public header files:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    basisproject --root . --include

Copy the files from the example:

.. code-block:: bash
    
    cp ${HELLOBASIS_RSC_DIR}/bar.cxx src/
    cp ${HELLOBASIS_RSC_DIR}/bar.h include/sbia/hellobasis/

Add the following line to ``src/CMakeLists.txt`` (section “library target(s)”):

.. code-block:: cmake
    
    basis_add_library (bar.cxx)
    
Add a Script Module
-------------------

Another kind of libraries are modules written in a scripting language such as Perl.

Copy the module file to src/:

.. code-block:: bash
    
    cd ~/local/src/hellobasis
    cp ${HELLOBASIS_RSC_DIR}/FooBar.pm.in src/

Add the following line to src/CMakeLists.txt(section “library target(s)” ):

.. code-block:: cmake
    
    basis_add_library (FooBar.pm)


The .in Suffix
--------------

- Note that some of these files have a .in file name suffix.
- This suffix can be omitted in the basis_add_library() statement. It has however an impact on how this function treats this file.
- The .in suffix indicates that the file is not usable as is, but contains patterns such as @PROJECT_NAME@ which BASIS should replace during the build of the module.
- The substitution of these ``@*@`` patterns is what we refer to as “building” script files.


Install the Libraries
---------------------

Now build the libraries:

.. code-block:: bash
    
    cd ~/local/src/hellobasis-build
    make

And install them:

.. code-block:: bash
    
    make install

Conclusion
==========

**Congratulations, You just finished your first BASIS Quick Start Guide!**

If this was not clear enough or you would like to know more, have a look at the  :ref:`Tutorials` which give more details about each of the steps described here.


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

