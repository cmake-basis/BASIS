.. title:: Help

.. meta::
    :description: Report any issues with BASIS or request new features on GitHub.

============
Getting Help
============

Please report any issues with BASIS, including bug reports, feature requests, or support questions, on GitHub_.

.. _GitHub: https://github.com/schuhschuh/cmake-basis/issues


Frequently Asked Questions
==========================

CMake
~~~~~

Using Standard Calls
--------------------

**Can I still use standard CMake calls such as add_library, or is some BASIS functionality lost?**

Probably. However, you will definitely lose much of the useful functionality 
that BASIS was created to provide. This kind of usage has also not been heavily 
tested so it is not recommended. The BASIS philosophy is definitely that a 
project that switches to BASIS uses the basis_ CMake commands wherever possible. 
Consider BASIS an extension to CMake, but if you run into issues you can 
file a ticket and we will attempt to address the problem.

Config.cmake
------------

**Can I use the <Package>Config.cmake files of projects that don't use BASIS?**

In <Package>Config.cmake files of other projects, it is fine that there will 
be standard CMake commands add include/library directories or import targets. 
BASIS is "smart" enough to extract this information properly by overriding 
the standard CMake commands.