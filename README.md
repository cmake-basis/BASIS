===================
CMake BASIS Modules
===================

This directory contains the CMake modules of the [CMake BASIS][1] project only.
These modules are required by any project which takes advantage of the extended
CMake commands of CMake BASIS. Other components of CMake BASIS such as the
CMake BASIS Utilities (a library of common functions for each supported programming
language) and CMake BASIS Tools (e.g., the ```basisproject``` tool) are installed
through the CMake BASIS project.

Developers requiring only the CMake BASIS Modules are encouraged to include the
[CMake BASIS Modules][2] Git repository as submodule into their Git controlled project
source tree. To utilize these modules, we recommend the use of the ```basis-modules```
project template (TODO: Add template files to CMake BASIS and link them here).

How to add the CMake BASIS submodule
------------------------------------

```bash
git submodule add git@github.com:schuhschuh/cmake-basis-modules.git basis
git add .gitmodules
git commit -m 'add: CMake BASIS Modules'
```


[1]: http://opensource.andreasschuh.com/cmake-basis
[2]: https://github.com/schuhschuh/cmake-basis-modules
