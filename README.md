===================
CMake BASIS Modules
===================

This directory contains the CMake modules of the [CMake BASIS][1] project only.
These modules are required by any project which takes advantage of the extended
CMake commands of CMake BASIS. Other components of CMake BASIS such as the
CMake BASIS Utilities (a library of common functions for each supported programming
language) and CMake BASIS Tools (e.g., the ```basisproject``` tool) are installed
through the CMake BASIS project.

License
=======

Copyright (c) 2011-2013 University of Pennsylvania   <br />
Copyright (c) 2013-2015 Andreas Schuh                <br />
Copyright (c) 2013-2014 Carnegie Mellon University

CMake BASIS is available under a BSD compatible license. The complete license text
can be found in the [COPYING.txt](/COPYING.txt) file.

Installation
============

Developers requiring only the CMake BASIS Modules are encouraged to include the
[CMake BASIS Modules][2] Git repository as submodule into their Git controlled project
source tree. To utilize these modules, we recommend the use of the ```basis-modules```
project template (TODO: Add template files to CMake BASIS and link them here).


```bash
git submodule add git@github.com:schuhschuh/cmake-basis-modules.git basis
git add .gitmodules
git commit -m 'add: CMake BASIS Modules'
```


[1]: http://opensource.andreasschuh.com/cmake-basis
[2]: https://github.com/schuhschuh/cmake-basis-modules
