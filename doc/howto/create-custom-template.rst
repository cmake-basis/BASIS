.. meta::
    :description: How to create a project template for BASIS,
                  a build system and software implementation standard.

========================
Create a Custom Template
========================

In addition to creating new projects from an existing project template,
the ``basisproject`` command-line tool can also be used to generate a new
:doc:`/standard/template` customized for your needs.

For a detailed description and overview of the available command options,
please refer to the output of the following command::

    basisproject --help



.. _HowToCreateATemplate:

Create a New Template
=====================

The fastest way to create a new template is to call ``basisproject`` with the name
of the new template and the option ``--new-template``:

.. code-block:: bash

    basisproject --name MyTemplate --new-template

This will create a subdirectory called ``MyTemplate/1.0`` under the current working directory
and populate it with the current default project template structure and BASIS configuration.
With this you can modify the the default substitutions and file contents for your needs, and
create new versions so that users can update their source tree automatically as you improve
and update your customized template.

.. note:: Use the template options of the existing template to specify which features
          of this template to copy when creating the new template.



.. _HowToUseATemplate:

Use a Custom Template
=====================

To use a custom template that you have created, specify the path to the template including the
version subdirectory as part of the ``basisproject`` command as follows:

.. code-block:: bash

    basisproject --name MyProject --template path/to/MyTemplate/1.0

Other than that you can use your custom template in the same manner as described in
:doc:`The How-To on Creating and Modifying a Project <create-and-modify-project>`.


Make Custom Template the Default
--------------------------------

During the installation of BASIS, it is possible to specify a custom template as the default
used by ``basisproject`` when called without the ``--template`` argument.
See the :ref:`BasisInstallationOptions` for details.



.. _TemplateLayout:

Template Layout
===============

::

  - template_name/
      - 1.0/
          + _config.py
          + src/
          + config/
          + data/
          + doc/
          + example/
          + modules/
          + test/
      - 1.1/
      - 2.0/
      - 2.1/
      - .../

.. note:: Only the files which were modified or added have to be present in the new template.
          The ``basisproject`` tool will look in older template directories for any missing files.


Template Versions
-----------------

The template system is designed to help automate updates of existing libraries to new template versions.
Whenever a template file is modified or removed, the previous project template has to be copied to a
new directory with an updated template version! Otherwise, the three-way diff merge used by the
``basisproject`` tool to update existing projects to this newer template will fail.


Custom Substitutions
====================

The template configuration file named ``_config.py`` and located in the top directory of each project
template defines not only which files constitute a project, but also the available substitution parameters
and defaults used by ``basisproject``. It requires a basic understanding of the Python syntax, but is
fairly easy to understand even without much experience in using Python given the following example.

.. code-block:: python

    # project template configuration script for basisproject tool

    # ------------------------------------------------------------------------------
    # required project files
    required = [
      'AUTHORS.txt',
      'README.txt',
      'INSTALL.txt',
      'COPYING.txt',
      'CMakeLists.txt',
      'BasisProject.cmake'
    ]

    # ------------------------------------------------------------------------------
    # optional project files
    options = {
      'config-settings' : {
        'desc' : 'Include/exclude custom Settings.cmake file.',
        'path' : [ 'config/Settings.cmake' ]
      },
      'config' : {
        'desc' : 'Include/exclude all custom configuration files.',
        'deps' : [
                   'config-settings'
                 ]
      },
      'data' : {
        'desc' : 'Add/remove directory for auxiliary data files.',
        'path' : [ 'data/CMakeLists.txt' ]
      }
    }

    # ------------------------------------------------------------------------------
    # preset template options
    presets = {
      'minimal' : {
        'desc' : 'Choose minimal project template.',
        'args' : [ 'src' ]
      },
      'default' : {
        'desc' : 'Choose default project template.',
        'args' : [ 'doc', 'doc-rst', 'example', 'include', 'src', 'test' ]
      },
      'toplevel' : {
        'desc' : 'Create toplevel project.',
        'args' : [ 'doc', 'doc-rst', 'example', 'modules' ]
      },
      'module' : {
        'desc' : 'Create module of toplevel project.',
        'args' : [ 'include',   'src',   'test' ]
      }
    }

    # ------------------------------------------------------------------------------
    # additional substitutions besides <project>, <template>,...
    from datetime import datetime as date

    substitutions = {
      # fixed computed substitutions
      'date'  : date.today().strftime('%x'),
      'day'   : date.today().day,
      'month' : date.today().month,
      'year'  : date.today().year,
      # substitutions which can be overridden using a command option
      'vendor' : {
        'help'    : "Package vendor ID (e.g., acronym of provider and/or division).",
        'default' : "SBIA"
      },
      'copyright' : {
        'help'    : "Copyrigth statement optionally including years, but not \". All rights reserved.\".",
        'default' : str(date.today().year) + " University of Pennsylvania"
      },
      'license' : {
        'help'    : "Software license statement, e.g., \"Simplified BSD\" or reference to license text.",
        'default' : "See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file."
      },
      'contact' : {
        'help'    : "Package contact information.",
        'default' : "SBIA Group <sbia-software at uphs.upenn.edu>"
      }
