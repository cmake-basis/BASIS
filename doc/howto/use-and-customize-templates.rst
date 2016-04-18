.. meta::
    :description: How to create a project template for BASIS,
                  a build system and software implementation standard.
                  
===============================
Using and Customizing Templates
===============================

The BASIS Project Templates define how the ``basisproject`` utility performs quick project
setup with mad-libs style text substitution. In other words, the template defines what 
substitution options are available when you run the ``basisproject`` command, and what files
are created in a new or updated project.


.. _AvailableTemplates:

Available Templates
===================


.. The tabularcolumns directive is required to help with formatting the table properly
   in case of LaTeX (PDF) output.

.. tabularcolumns:: |p{1cm}|p{1cm}|p{13cm}|

+------------+-----------+-------------------------------------------------------------------------------------+
| Name       | Version   | Description                                                                         |
+============+===========+=====================================================================================+
| basis_     | 1.1_      | This is the default template provided by BASIS and the one we recommend.            |
|            |           | It is easy to get started with and follows all of the BASIS :doc:`/standard`.       |
|            |           | To use it simply follow the :doc:`/quickstart`.                                     |
+------------+-----------+-------------------------------------------------------------------------------------+
| sbia_      | 1.8       | The original template for the                                                       |
|            |           | `Section of Biomedical Image Analysis (SBIA) <http://www.cbica.upenn.edu/sbia/>`__  |
|            |           | of the `University of Pennsylvania <http://www.upenn.edu/>`__. This template        |
|            |           | will only be useful as an example for those that are not a member of this group.    |
+------------+-----------+-------------------------------------------------------------------------------------+
| *custom*   | n/a       | You can create your own custom template. For instructions see the                   |
|            |           | :ref:`HowToCreateATemplate` section below.                                          |
+------------+-----------+-------------------------------------------------------------------------------------+

You can find the actual templates provided by BASIS in the ``data/templates`` directory.

.. _basis: https://github.com/cmake-basis/BASIS/tree/master/data/templates/basis
.. _1.1:   https://github.com/cmake-basis/BASIS/tree/master/data/templates/basis/1.1
.. _sbia:  https://github.com/cmake-basis/BASIS/tree/master/data/templates/sbia

.. _HowToUseATemplate:

Use a Template
==============

To use a template provided by BASIS or one that you have created, 
specify the name of the template including the version as subdirectory
as part of the ``basisproject`` command as follows:

.. code-block:: bash

    basisproject create --name MyProject --template basis/1.1

If you want to use your own custom template, simply specify the full path to
the respective template directory which contains the template configuration file
named ``_config.py``. A relative file path must be relative to the current
working directory. Other than that you can use your custom template in
the same manner as described in
:doc:`The How-To on Creating and Modifying a Project <create-and-modify-project>`.


Change the Default Template
---------------------------

During the installation of BASIS, it is possible to specify a custom template as the 
default used by ``basisproject`` when called without the ``--template`` argument.
See the :ref:`BasisInstallationOptions` for details.


.. _HowToCreateATemplate:

Create a Custom Template
========================

The template includes the files that are generated and the parameters that
are available to the ``basisproject`` utility. If you plan to create new
projects frequently and have some special requirements or files that you
need it may be worthwhile to create a custom template. That way everything 
can be instantly set up in exactly the way you need.

.. seealso:: The :doc:`Project Template Standard </standard/template>` explains the layout of templates, versioning, and how custom substitutions work.

In addition to creating new projects from an existing project template,
the ``basisproject`` command-line tool can also be used to generate a new
:doc:`/standard/template` customized for your needs.

The fastest way to create a new template is to call ``basisproject`` with 
the name of the new template and the option ``--new-template``. Use :

.. code-block:: bash

    basisproject create --name MyTemplate --new-template [--optional-command-options]

This will create a subdirectory called ``MyTemplate/1.0`` under the current 
working directory and populate it with the current default project template 
structure and BASIS configuration. To copy an entire existing template,
use the ``--full`` option and possibly ``--template`` to specify the location
or name and version of the existing template.

For a detailed description and overview of the available command options,
please refer to the output of the ``basisproject help create`` command.
The template options of the existing template can be used to specify which 
features to copy when creating the new template.

With this you can modify the the default substitutions and file contents 
for your needs. You can also create new versions so that users can update 
their source tree automatically as you improve and update your customized 
template.
