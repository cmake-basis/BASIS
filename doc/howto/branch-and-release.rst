.. meta::
    :description: This BASIS how-to explains how to create new developement branches
                  and merge changes from one branch into another. It further details
                  the software release steps.

==================
Branch and Release
==================

This guide defines the process of creating a new development branch other
than the trunk and the creation of a release version of a software.
Before reading this document, you should be familiar with the basic structure
of any revision controlled software project as described in the :doc:`/standard/fhs`.


.. _HowToBranch:

Branching and Merging
=====================

See the :doc:`standard/fsh` for details.

For SVN please also read the corresponding
`SVN Book <http://svnbook.red-bean.com/en/1.5/svn.branchmerge.basicmerging.html>`_ article.

.. todo::
    Explain purpose and meaning of branches and summarize most often required commands here.


.. _HowToRelease:

Releasing Software
==================

Whenever the software of a project is to be used by another project or user,
the following steps have to be performed in order to create a new release
version of the software.

1. If the development was carried out in a branch other than the trunk,
   the changes which shall be part of the release version have to be merged
   back to the trunk. Therefore, use the ``svn merge`` command as described in the
   `SVN Book <http://svnbook.red-bean.com/en/1.5/svn.branchmerge.basicmerging.html>`_.

2. Then the trunk is copied to a branch which is used to apply release specific
   adjustments such as setting the version number or to apply bug fixes to
   this particular release version. Therefore, name this branch
   "<project>-<major>.<minor>" (note that the patch number is excluded!) to
   indicate that this branch represents the "<major>.<minor>" series of
   software releases.

   See :ref:`HowToBranch` for details on how to create a new branch.

3. Edit the :ref:`BasisProject.cmake <BasisProject>` file of the new release branch and change the
   ``VERSION`` argument to the proper version as described below.

   The version number consists of three components: the major version number,
   the minor version number, and the patch number. The format of the version
   number is "<major>.<minor>.<patch>", where the minor version number and
   patch number default to 0 if not given. Only digits are allowed except of
   the two separating dots.

   For release candidates which are made available for review, on the other
   side, instead of the patch number, prepend "rc<N>" to the release version,
   where N is the number of the release candidate. For example,
   the first release candidate of the first stable release will have the
   version number "1.0.0rc1", the second release candidate which is tagged
   after bug fixes have been applied, will have the version "1.0.0rc2", etc.
   Once the 1.0 version was reviewed and is ready for final release,
   change the version to "1.0.0". From now on, the patch number will be
   increased by one for each consecutive maintenance release of the 1.0 version.

   - Beta releases have the major version number 0. The first stable release
     the major version number 1, the second major stable release the number 2, etc.
   - A change of the major version number indicates changes of the software
     API_ (and often ABI_) and/or its behavior and/or the change or addition of
     major features.
   - A change of the minor version number indicates changes that are not only
     bug fixes and no major changes. Hence, changes of the API_, but not ABI_.
   - A change of the patch number indicates changes only related to bug fixes
     which did not change the software API_ nor ABI_. It is the least important
     component of the version number.

4. After setting the version number, tag the release branch as "<project>-<version>",
   i.e., copy the branch "branches/<project>-<major>.<minor>" to "tags/<project>-<version>".

5. Now select the reviewers and ask them to retrieve a copy of the tagged
   release candidate. According to the reviewers feedback, the release branch
   is bug fixed and a new release candidate is tagged (after increasing the
   N in "<major>.<minor>rc<N>") and made available for the next review
   iteration.

6. The prvieous step is iterated until the release candidate passed all reviews.
   Once this is the case, set the version to "<major>.<minor>.0" and create
   a corresonding tag.

7. Optionally, binary and source distribution packages are generated from the
   tagged release branch and uploaded to the public domain. See the :doc:`package`
   guide for details on how to create such distribution packages.

8. Inform the users that a new release is available and update any internal and
   external documentation related to the software package.

9. Finally, make sure that all bug fixes which were applied to the release
   branch are merged back to the trunk where the development continues.
   Do not implement new features in the created release branch. This branch
   will only be used for maintenance of the "<major>.<minor>" series of the
   software.

.. note::
    The trunk is not associated with a version other than the revision number as it
    is always in development. Therefore, the trunk always uses the invalid version 0.0.0.

    Do not forget to commit all changes to the release branch, not the trunk.
    In particular the adjustment of the version number shall not be applied
    to the trunk as it will always keep the invalid version 0.0.0.


.. _ABI: http://en.wikipedia.org/wiki/Application_binary_interface
.. _API: http://en.wikipedia.org/wiki/Application_programming_interface
