===========
CMake BASIS
===========

The [CMake Build system And Software Implementation Standard (BASIS)][1] makes it
easy to create sharable software and libraries that work together. This is accomplished
by combining and documenting some of the best practices and utilities available.
More importantly, BASIS supplies a fully integrated suite of functionality to make
the whole process seamless! 

Web:  [CMake BASIS Website]  [1]
Code: [CMake BASIS on GitHub][2]


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
3. Investigate the [Reference][5] for more in-depth information.

Documentation
-------------

Additional documentation is available in several locations: 

- First and foremost on the [CMake BASIS website][1].
- The [software manual as PDF](/doc/BASIS_Software_Manual.pdf).
- The documentation installed in the _doc_ directory for offline access.
- The [source package documentation directory](/doc) works in a pinch as well.

Installation
------------

See the [installation instructions][7] or the [INSTALL.txt](/INSTALL.txt) file.

Details on where the executables and libraries, the auxiliary data, and the 
documentation files are installed is also there.

Source Package Content
----------------------

<table>
<tr><td>   BasisProject.cmake   </td><td>   Meta-data used for the build configuration.                </td></tr>
<tr><td>   CMakeLists.txt       </td><td>   Root CMake configuration file.                             </td></tr>
<tr><td>   config/              </td><td>   Package configuration files.                               </td></tr>
<tr><td>   data/templates/      </td><td>   Project templates.                                         </td></tr>
<tr><td>   doc/                 </td><td>   Documentation source files.                                </td></tr>
<tr><td>   example/             </td><td>   Example files used in the tutorials.                       </td></tr>
<tr><td>   include/             </td><td>   Public header files.                                       </td></tr>
<tr><td>   src/cmake/           </td><td>   CMake implementations and corresponding auxiliary files.   </td></tr>
<tr><td>   src/geshi/           </td><td>   A language file written in PHP for the use with GeSHi,
                                            a source code highlighting extension for MediaWiki.        </td></tr>
<tr><td>   src/sphinx/          </td><td>   Themes and extensions for the Sphinx documentation tool.   </td></tr>
<tr><td>   src/tools/           </td><td>   Source code of command-line tools.                         </td></tr>
<tr><td>   src/utilities/       </td><td>   Source code of utility functions.                          </td></tr>
<tr><td>   test/                </td><td>   Unit tests for the provided libraries.                     </td></tr>
</table>

Help
----

If you need help after searching the documentation or want to report a problem,
you can reach the CMake BASIS developers on GitHub using the [CMake BASIS Issue Tracker][8].


License
=======

Copyright (c) 2011-2013 University of Pennsylvania   <br />
Copyright (c) 2013-2014 Andreas Schuh                <br />
Copyright (c) 2013-2014 Carnegie Mellon University

CMake BASIS is available under a BSD compatible license. The complete license text is
can be found on the [download page][10] and in the [COPYING.txt](/COPYING.txt) file.


<!-- Links to web page and online ressources -->
[1]: http://opensource.andreasschuch.com/cmake-basis
[2]: https://github.com/schuhschuh/cmake-basis
[3]: http://opensource.andreasschuh.com/cmake-basis/quickstart.html
[4]: http://opensource.andreasschuh.com/cmake-basis/howto.html
[5]: http://opensource.andreasschuh.com/cmake-basis/apidoc.html
[8]: https://github.com/schuhschuh/cmake-basis/issues

<!-- Links to GitHub, see the local directory if you have downloaded the files already -->
[6]:  http://opensource.andreasschuh.com/cmake-basis/apidoc.html#package-overview
[7]:  http://opensource.andreasschuh.com/cmake-basis/install.html
[10]:  http://opensource.andreasschuh.com/cmake-basis/download.html
