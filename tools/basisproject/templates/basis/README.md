===================================
CMake BASIS Project Template: basis
===================================

This directory/repository contains the default template files for the
creation of a new [CMake BASIS][1] based software project using the
`basisproject` tool.


Versions
========

Different versions of the templates files are organized in subdirectories
named `<major>.<minor>`, where `<major>` is the major version number
and `<minor>` the minor version number indicating only a subtle change
of the template files. Every time a template file is modified or removed,
the previous template file has to be copied to a new version directory.
This is required by the three-way diff merge used by the `basisproject`
tool to be able to update existing projects to this newer template.
Therefore it needs a reference template file reflecting the state before
any test substitution or user edits. Note that only files which were
modified or added have to be present in the new template version directory.
The `basisproject` tool will look in older template directories for any
missing files.


Installation
============

The `basis` project template is part of the standard CMake BASIS installation.

To use a project template which is not part of the standard [CMake BASIS][1]
installation, download the template files and use the `--template` option
of the `basisproject` tool to specify the template version directory of
the respective project template to use. This path must be a either an
absolute path or relative to the current working directory or the
templates directory of the CMake BASIS installation. When a project
template is used more frequently, copy the project template directory
into the CMake BASIS templates directory and name it after the project
template. The complete path of the templates directory is displayed by
the `basisproject --templates-dir` command.

For example, to install the `sbia` project template:

```
git clone --depth=1 https://github.com/cmake-basis/template-sbia && \
mv "template-sbia" "$(basisproject --templates-dir)/sbia"
```

Now you can create a new project from this template using the command:

```
basisproject create --name MyProject \
                    --author "Andreas Schuh" \
                    --description "An example project" \
                    --template sbia
```


Configuration
=============

A template `_config.py` file must be present in each project template
version directory. It defines the sets of template files needed to
populate a project source tree and the options to customize the template
files together with a brief description of each option for the help
output of the `basisproject` tool.

The `basisproject` tool copies the template file to the project source
tree and substitutes any specified `<variable>` placeholders by the
respective variable values set in the template configuration file.
These variable values can be overridden using the template options defined
in the template configuration file via command-line arguments of the
`basisproject` tool. For a list of all template options, run the command:

```
basisproject help create --template basis
```


[1]: https://cmake-basis.github.io
