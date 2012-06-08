====================
Documenting Software
====================

.. todo::

    This how-to guide has to be written yet.

ChangeLog
=========

Generated from revision history.

Software Manual
===============

Introduces users to software tools and guides them through example application.

Developer's Guide
=================

Describes implementation details.

API Documentation
=================

Documentation generated from source code, e.g., using Doxygen, Epydoc, Sphinx,...


Software Web Site
=================

A web site can be created using the documentation generation tool Sphinx_.
The main input to this tool are text files written in the lightweight markup language
reStructuredText_. A default theme for use at SBIA has been created which is part
of BASIS. This theme together with the text files that define the content and
structure of the site, the HTML pages of the software web site can be generated
by ``sphinx-build``. The CMake function `basis_add_doc()`_ provides an easy way
to add such web site target to the build configuration. For example, the
template ``doc/CMakeLists.txt`` file contains the following section:

.. code-block:: cmake

    # ----------------------------------------------------------------------------
    # web site (optional)
    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/site/index.rst")
      basis_add_doc (
        site
        GENERATOR    Sphinx
        BUILDER      html dirhtml pdf man
        MAN_SECTION  7
        SHOW_RELEASE false
        RELLINKS     news download examples help publications
        COPYRIGHT    "<year> University of Pennsylvania"
        AUTHOR       "<author>"
      )
    endif ()

where <year> and <author> should be replaced by the proper values. This is usually done
by the :doc:`basisproject <create-and-modify-project>` command-line tool upon creation
of a new project.

This CMake code adds a build target named ``site`` which invokes ``sphinx-build``
with the proper default configuration to generate a web site from the reStructuredText
source files with file name extension ``.rst`` found in the ``site/`` subdirectory.
The source file of the main page, the so-called master document, of the web site
must be named ``index.rst``. The main pages which are linked in the top
navigation bar are named using the ``RELLINKS`` option of `basis_add_sphinx_doc()`_,
the CMake function which implements the addition of a Sphinx documentation target.
The corresponding source files must be named after these links. For example, given
above CMake code, the reStructuredText source of the page with the download
instructions has to be saved in the file ``site/download.rst``.

See the :ref:`corresponding section <Build>` of the :doc:`install`
guide for details on how to generate the HTML pages from the reStructuredText source
files given the specification of a Sphinx documentation build target such as the
``site`` target defined by above template CMake code.


.. _basis_add_doc(): http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/group__CMakeAPI.html#ga06f94c5d122393ad4e371f73a0803cfa
.. _basis_add_sphinx_doc(): http://www.rad.upenn.edu/sbia/software/basis/apidoc/v1.3/DocTools_8cmake.html#a628468ae6c7b29570a73a2d63eebf257
.. _Sphinx: http://sphinx.pocoo.org/
.. _reStructuredText: http://docutils.sourceforge.net/rst.html
