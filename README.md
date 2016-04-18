===========
CMake BASIS
===========

[![Build Status](https://travis-ci.org/cmake-basis/BASIS.svg?branch=master)](https://travis-ci.org/cmake-basis/BASIS)

The [CMake Build system And Software Implementation Standard (BASIS)][1] makes it
easy to create sharable software and libraries that work together. This is accomplished
by combining and documenting some of the best practices and utilities available.
More importantly, BASIS supplies a fully integrated suite of functionality to make
the whole process seamless! 

  [Homepage][1]
| [GitHub](https://github.com/cmake-basis/BASIS "CMake BASIS on GitHub")
| [SourceForge](http://sourceforge.net/projects/sbia-basis/ "CMake BASIS on SourceForge")
| [Open Hub (Ohloh)](https://www.openhub.net/p/cmake-basis "CMake BASIS Statistics on Open Hub (Ohloh)")
| [Travis CI](https://travis-ci.org/cmake-basis/BASIS/builds "CMake BASIS Continuous Integration Tests")

Features
========

**Project Creation**

- Quick project setup with mad-libs style text substitution
- Customizable project templates

**Standards**

- Filesystem layout standards
- Basic software implementation standards
- Command-line parsing standards
- Guidelines on coding style

**Build system utilities**

- New CMake Module APIs
- Version Control Integration
- Automatic Packaging

**Documentation**

- Documentation generation tools
- Manuals
- PDF and HTML output of each
- Integrated with CMake APIs

**Testing**

- Unit testing
- Continuous integration
- Executable testing frameworks

**Program Execution**

- Parsing library
- Command execution library
- Unix philosophy and tool chains

**Supported Languages:**

- C++, BASH, Python, Perl, MATLAB

**Supported Packages:**

- CMake, CPack, CTest/CDash, Doxygen, Sphinx, Git, Subversion, reStructuredText,
  gtest, gflags, Boost, and many more, including custom packages.


Get Started
===========

1. Get your first taste with the [Quick Start Guide][3].
2. Check out the [How-to Guides][4] for easy introductions to common tasks.
3. Learn more [About CMake BASIS][11], where it came from and why.
4. Investigate the [Reference][5] and [API][12] for more in-depth information.

Documentation
-------------

Additional documentation is available in several locations: 

- First and foremost on the [CMake BASIS website][1].
- The [software manual as PDF](https://github.com/cmake-basis/cmake-basis.github.io/raw/gh-pages/_downloads/BASIS_Software_Manual.pdf).
- The documentation installed in the _doc_ directory for offline access.
- The [source package documentation directory](/doc) works in a pinch as well.

Installation
------------

See the [installation instructions][7] or the [INSTALL](/INSTALL.md) file.
Information on where the executables and libraries, the auxiliary data, and the 
documentation files get installed is also available there. For more concise
installation steps, have a look at the [Quick Start Installation][9].


Help
----

If you need help after searching the documentation or want to report a problem,
you can reach the CMake BASIS developers on GitHub using the [CMake BASIS Issue Tracker][8].


License
=======

Copyright (c) 2011-2013 University of Pennsylvania   <br />
Copyright (c) 2013-2015 Andreas Schuh                <br />
Copyright (c) 2013-2014 Carnegie Mellon University

CMake BASIS is available under a BSD compatible license. The complete license text
can be found on the [download page][10] and in the [COPYING.txt](/COPYING.txt) file.


Package Content
===============

Path                     | Content description
------------------------ | ----------------------------------------------------------
[BasisProject.cmake][20] | Meta-data used for the build configuration.
[CMakeLists.txt]    [21] | Root CMake configuration file.
[config/]           [22] | Package configuration files.
[doc/]              [24] | Documentation source files.
[example/]          [25] | Example files used in the tutorials.
[include/]          [26] | Public header files.
[src/cmake/]        [27] | CMake modules and corresponding auxiliary files.
[src/sphinx/]       [29] | Themes and extensions for the Sphinx documentation tool.
[src/utilities/]    [30] | Source code of utility functions.
[tools/]            [31] | Source code of command-line tools and project template.
[test/]             [32] | Unit tests for the provided libraries.


Legacy GitHub Project
=====================

This project was originally developed using Subversion as revision control system.
When CMake BASIS was made public as open source, it has been migrated to GitHub
using [git svn](https://git-scm.com/docs/git-svn). The Subversion history, however,
was quite long and included big data files such as example image data, external
libraries such as Boost, PDF files, and PowerPoint presentations. Due to the
decentralized nature of Git, having such objects in the revision history of the
repository adds significantly to the size of the repository and each clone.

With the release of CMake BASIS version 3.3.0, the history of the Git repository has
been rewritten using [git filter-branch](https://git-scm.com/docs/git-filter-branch).
Moreover, the CMake modules have been separated from the complete suite of BASIS tools
using [git subtree split](https://makingsoftware.wordpress.com/2013/02/16/using-git-subtrees-for-repository-separation/).
This reduced the size of the repositories considerably from more than 200MB to less
than 10MB and supports the use of only the CMake modules in a project that does
not require the complete functionality.
The [CMake BASIS Modules](https://github.com/cmake-basis/modules) repository is
about 2MB in size when including all revisions. A shallow clone with `--depth=1` is
less than 1MB. The [CMake BASIS Find Modules](https://github.com/cmake-basis/find-modules)
for use by the `find_package` command are hosted in another GitHub repository.
Developers may copy only those Find modules needed by their project or install the
complete set of modules as part of [CMake BASIS](https://github.com/cmake-basis/BASIS).
The shared CMake modules repositories are integrated into the main project with the
[git subtree add](https://makingsoftware.wordpress.com/2013/02/16/using-git-subtrees-for-repository-separation/)
command. Changes of the CMake modules are first pushed to the main repository and
then to the respective subtree repositories using
[git subtree push](https://makingsoftware.wordpress.com/2013/02/16/using-git-subtrees-for-repository-separation/).

CMake BASIS versions prior to version 3.3.0 have to be downloaded from the
[legacy GitHub project](https://github.com/cmake-basis/legacy) because the
intrusive history changes broke the integrity of previous versions.

<!-- --------------------------------------------------------------------------------- -->

<!-- Links to GitHub, see the local directory if you have downloaded the files already -->
[20]: /BasisProject.cmake
[21]: /CMakeLists.txt
[22]: /config
[24]: /doc
[25]: /example
[26]: /include
[27]: /src/cmake
[29]: /src/sphinx
[30]: /src/utilities
[31]: /tools
[32]: /test

<!-- Links to web page and online ressources -->
[1]:  https://cmake-basis.github.io/
[3]:  https://cmake-basis.github.io/quickstart.html
[4]:  https://cmake-basis.github.io/howto.html
[5]:  https://cmake-basis.github.io/reference.html
[12]: https://cmake-basis.github.io/apidoc.html
[8]:  https://github.com/cmake-basis/BASIS/issues
[9]:  https://cmake-basis.github.io/quickstart.html#install-basis
[11]: https://cmake-basis.github.io/about.html

<!-- Links to GitHub, see the local directory if you have downloaded the files already -->
[6]:  https://cmake-basis.github.io/apidoc.html#package-overview
[7]:  https://cmake-basis.github.io/install.html
[10]: https://cmake-basis.github.io/download.html

