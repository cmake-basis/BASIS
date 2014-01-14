.. _QuickStartGuides:

===========
Quick Start
===========


.. _FirstSteps:
.. _FirstStepsIntro:

First Steps
===========

The following steps will show you how to

- download and install <project> on your system.
- use the library to create an example
- build and test the example project.

You need to have a Unix-like operating system such as Linux or Mac OS X installed on your
machine in order to follow these steps. At the moment, there is no separate tutorial
available for Windows users, but you can install CygWin as an alternative.
Note, however, that <project> can also be installed and used on Windows.


Install <project>
-----------------

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
- Press ``g`` to generate the Makefiles.

Build and install <project>
~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    setenv <project>_EXAMPLE_DIR "~/local/share/<project>/example"
    setenv HELLO<project>_RSC_DIR "${BASIS_EXAMPLE_DIR}/hello<project>"

Using the Bourne Again SHell (bash):

.. code-block:: bash
    
    export PATH="~/local/bin:${PATH} "
    export <project>_EXAMPLE_DIR="~/local/share/basis/example"
    export HELLO<project>_RSC_DIR="${BASIS_EXAMPLE_DIR}/hello<project>"


Create an Example
-----------------

Create an example using <project>:

.. code-block:: bash
    
    voluptate --velit esse --cillum dolore --eu



Test the Example
~~~~~~~~~~~~~~~

Excepteur sint occaecat cupidatat non proident, 
sunt in culpa qui officia deserunt mollit anim 
id est laborum.


.. code-block:: bash
    
    ipsum --in molestie


Next Steps
----------

Congratulations! You just finished your first <project> tutorial.

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

The advanced tutorial slides give a more in-depth introduction to <project> and
its use including in-depth information and references to further documentation. For a less
comprehensive tutorial-like introduction, please refer to the :ref:`FirstSteps` above.

.. The ref link is required for the PDF version as the download directive in
   this case does not translate to a hyperlink, but text only.

