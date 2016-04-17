.. meta::
    :description: This BASIS how-to describes the basistest family of scripts
                  and the process which was implemented at SBIA for the
                  automated software test execution.

=================
Automated Testing
=================

This how-to guide describes the implementation and configuration of
automated tests of software implemented on top of BASIS. Note that this guide
is mainly of interest for software maintainers who have permissions to change
the configuration of the software testing process and system administrators.
Other lab members and software developers generally do not need to bother with
these details. Note, however, that the automated tests can generally also be
setup on any machine outside the lab. But in order for CTest_ to be able to
submit test results to the CDash server, a VPN connection to the
University of Pennsylvania Health System (UPHS) network is required.

.. note:: This how-to guide details the automated software testing at SBIA
          and is therefore specific to the lab's computing environment.

.. _BasisTestScripts:

The basistest family of scripts
===============================

The BASIS package comes with a family of scripts whose name starts with
the prefix ``basistest``. All these scripts respond to the usual command-line
options such as ``--help`` and ``--version`` to provide detailed
information regarding usage and version. Further, a wrapper script named
``basistest`` is available which understands the subcommands ``cron``,
``master``, ``slave`` (the default), and ``svn``.

- :ref:`BasisTestCron`:
    The command executed by the scheduled cron job.

- :ref:`BasisTestMaster`:
    The master script which runs the scheduled tests.

- :ref:`BasisTestSlave`:
    The test execution command which is executed by the master script for each test job.

- :ref:`BasisTestSvn`:
    The wrapper for the svn_ command which can be run non-interactively.


.. _BasisTestCron:

basistest-cron
--------------

This command is run by a cron job. The configuration of the test execution command is
coded into this script, optionally including the submission command used to submit
test jobs to the batch-queuing system such as the `Oracle Grid Engine`_,
formerly known as Sun Grid Engine (SGE), in particular. Moreover, the location of the
test configuration file and test schedule file, both used by the ``basistest-master``
script, are specified here. Another reason for implementing this script is the setup
of the environment for the execution of the master script because cron jobs are run
with a minimal configuration of environment variables. Therefore, the ``basistest-cron``
script sources the ``~swtest/.bashrc`` file of the ``swtest`` user which is used at
our lab for the automated software testing in order to, for example, add the
``~swtest/bin/`` directory where all the ``basistest`` scripts are installed to the
``PATH`` environment variable.


.. _BasisTestMaster:

basistest-master
----------------

This so-called master script is executed by the ``basistest-cron`` command.
On each run, it reads in the configuration file given by the ``--config`` option
line-by-line. Each line in the configuration file specifies one test job to be executed.
The format of the configuration file is detailed here. Comments within the configuration
file start with a pound (#) character at the beginning of each line.
  
For each test of a specific branch of a project, the configuration file contains a
line following the format::

    <m> <h> <d> <project> <branch> <model> <options>

where::

    <m>         Interval in minutes between consecutive test runs.
                Defaults to "0" if "*" is given.
    <h>         Interval in hours between consecutive test runs.
                Defaults to "0" if "*" is given.
    <d>         Interval in days (i.e., multiples of 24 hours) between consecutive
                test runs. Defaults to "0" if "*" is given.
    <project>   Name of the BASIS project.
    <branch>    Branch within the project's SVN repository, e.g., "tags/1.0.0".
                Defaults to "trunk" if a "*" is given.
    <model>     Dashboard model, i.e., either one of "Nightly", "Continuous",
                and "Experimental". Defaults to "Nightly".
    <options>   Additional options to the CTest script.
                The "basisctest" script of BASIS is used by default.
                Run "ctest -S <path>/basistest.ctest,help" to get a list of
                available options. By default, the default options of the
                CTest script are used. Note that this option can in particular
                be used to define CMake variables for the build configuration.

Note that either <m>, <h>, or <d> needs to be a positive number such that the
interval is valid. Otherwise, the master script will report a configuration error
and skip the test.
  
.. note::
    Neither of these entries may contain any whitespace character!

For example, nightly tests of the main development branch (trunk) of the
project BASIS itself which are run once every day including coverage analysis
are scheduled by::

    * * 1 BASIS trunk Nightly coverage,memcheck

Besides the configuration file, which has to be edited manually, a test schedule
file is maintained by the testing master. For each configured test job, the master
consults the current schedule to see whether the test is already due for execution
given the testing interval specified in the configuration file and the last time
the test was executed. If the test is due for execution, the testing command,
i.e., by default the :ref:`BasisTestSlave`, is executed and the test schedule
updated by the testing master. Otherwise, the execution of the test is skipped.


.. _BasisTestSlave:

basistest-slave
---------------

This script wraps the execution of the CTest script used for the automated
testing of BASIS projects including the submission of the test results to the
sbiaCDash_ server. It mainly converts the command-line arguments to the correct
command-line for the invocation of the CTest script.

The `basistest.ctest`_ script performs the actual testing of a BASIS
project, i.e., the

- initial check out of the sources from the Subversion controlled repository,
- update of an existing working copy,
- build of the test executables,
- execution of the tests,
- optional coverage analysis,
- optional memory checks,
- submission of test results to the CDash server.

Run the following command in a shell to have the CTest script print its help
to screen and exit. However, the ``basistest-slave`` script should be
used instead of executing this CTest script directly. The help displayed by this
command can be used in order to determine which additional options
are available (such as ``coverage`` and ``memcheck``).

::

    ctest -S basistest.ctest,help


.. _BasisTestSvn:

basistest-svn
-------------

This script simply wraps the execution of the svn_ command as the ``svnuser``
user as this allows for non-interactive check outs and updates of working
copies without the need to provide a user name and password. The code of the
script is at the moment the single line::

    exec sudo -u svnuser /bin/sh /sbia/home/svn/bin/svnwrap "$@"

.. note::
    There is another wrapper script named ``svnwrap`` owned by
    the ``svnuser`` involved which does the actual invocation of the
    ``svn`` command.
    

.. _HowToIntegrateCDash:
    
CDash Integration
=================

The first step for CDash_ integration is to set up a CDash server by following
the instructions provided in the CDash documentation.

Then you need to create a project on the CDash site of your server through the
Admin interface.

Finally, you can configure CTest through the :apidoc:`CTestConfig.cmake` file
which must be in a project's top-level directory to specify the URL of the
CDash server as well as the project to submit test results to.

Running tests via ``ctest`` (**not** ``make test``) will then try to submit the
results to the CDash server.

.. todo:: Add more details about how to configure CDash Integration




.. _AdministrationOfAutomatedTests:

Administration of Software Testing
==================================

The following describes the setup and configuration of the automated software
tests at SBIA. Hence, these instructions are only of interest for the
administrators of the automated software testing at our lab. Other users
do not have the permission to become the ``swtest`` user.
To become the ``swtest`` user execute::

    sudo -u swtest sudosh

.. note::
    If you want to start with a clean setup, keep in mind that the
    directories ``~swtest/etc/`` and ``~swtest/var/`` contain
    files which are not part of the BASIS project.
    These need to be preserved and backed up separately.


.. _AutomatedTestingInstallation:

Initial BASIS Installation
--------------------------

The testing scripts described above are part of the BASIS project.
As long as this project is not installed system-wide, it has to be
installed locally for use by the ``swtest`` user.
Executing the following commands as this testing user will install BASIS
locally in its home directory.

1. Check-out the BASIS sources into the directory ``~swtest/src/``:

.. code-block:: bash

    cd
    svn --username <your own username> co "https://sbia-svn/projects/BASIS/trunk" src

2. Create a directory for the build tree and configure it such that BASIS
will be installed in the home directory of the ``swtest``` user:

.. code-block:: bash

    mkdir build
    cd build
    ccmake -DINSTALL_PREFIX:PATH=~ -DINSTALL_SINFIX:BOOL=OFF \
            -DINSTALL_LINKS:BOOL=OFF \
            -DBUILD_DOCUMENTATION:BOOL=OFF \
            -DBUILD_EXAMPLE:BOOL=OFF \
            -DBUILD_TESTING:BOOL=OFF \
            ../src

3. Build and install BASIS with ``~swtest`` as installation prefix::

    make install

The testing scripts described above are then installed in the directory
``~swtest/bin/`` and the CTest script is located in ``~swtest/share/cmake/``.


.. _UpdateOfAutomatedTestingInstallation:

Updating the BASIS Installation
-------------------------------

In order to update the testing scripts, run the following commands as
the ``swtest`` user on ``olympus`` (this is important because the cron job which
executes the tests will run on ``olympus``).

.. code-block:: bash

    cd
    svn up src
    cmake build
    make -C build install
    make clean

This updates the working copy of the BASIS sources in ``~swtest/src/``
and builds the project in the build tree ``~swtest/build/``.
Finally, the updated BASIS project is installed. Note that the explicit
execution of CMake might be redundant. However, some modifications may
not re-trigger a configuration even though it is required. Thus, it is
better to run CMake manually before the make. The final
``make clean`` is optional. It is done in order to remove the temporary
object and binary files from the build tree and thus reduce the disk space occupied.


.. _ConfigurationOfAutomatedTests:

Configuring Test Jobs
---------------------

Setting up the Test Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All tests are executed by the ``swtest`` user. Therefore, the common test
environment can be set up in the ``~swtest/.bashrc`` file. Here, the
`environment modules`_ which are required by all tests should be loaded.
Moreover, a particular project can depend on another project and should always be
build using the most recent version of that other project. Every BASIS project,
in particular, depends on BASIS. Thus, after each successful test of a project
which is required by other projects, the files of this project are installed
locally in the home directory of the ``swtest`` user. By setting the ``<Pkg>_DIR``
environment variable, CMake will use this reference installation if available.
Otherwise, it will keep looking in the default system locations.

For an example on how the test environment can be set up, have a look at the
following example lines of the ``~swtest/.bashrc``:

.. code-block:: bash

    # BASIS is required by all tested projects
    module load basis
    # ITK 3.* is required by BASIS (for the test driver), HardiTk, GLISTR
    module unload itk
    module load itk/3.20
    # Boost (>= 1.45) is required by HardiTk
    module load boost
    # TRILINOS is required by HardiTk
    module load trilinos

    # root directory for installation of project files after successful test execution
    #
    # Note: When logged in on olympus, we usually want to configure
    #       the setup of the test environment such as updating the BASIS
    #       installation used by the automated testing infrastructure itself.
    #       In this case, we actually want to install the files in ~swtest/
    #       and not in the DESTDIR set here.
    if ! [[ `hostname` =~ "olympus" ]]; then
            export DESTDIR="${HOME}/comp_space/destdir"
    fi

    # Set <Project>_DIR environment variables such that the most recent
    # installations in DESTDIR are used. If a particular installation is
    # not available yet, the default installation as loaded by the module
    # commands above will be used instead.
    export BASIS_DIR="${DESTDIR}/usr/local/lib/cmake/basis"

.. note::

    The environment set up this way is common for the build of all tested projects.
    Hence, all projects which use ITK will use ITK version 3.20 in this example.
    If certain projects would require a different ITK version, the environment for these
    test jobs would need to be adjusted before the execution of ``ctest``. This is
    currently not further supported by BASIS, but is an open feature to be implemented.


.. _AddingTestsToBasisTestConfiguration:

Adding Test Job to basistest Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The automated tests of BASIS projects are configured in the test configuration file
of the :ref:`BasisTestMaster` script. The format of this configuration file is detailed
:ref:`here <BasisTestMaster>`. Where this file is located and how it is named is
configured in the :ref:`BasisTestCron` script. By default, the ``basistest-master``
script looks for the file ``/etc/basistest.conf``, but the current installation is setup
such that the configuration is located in ``~swtest/etc/``. The current test schedule
file which is maintained and updated by the :ref:`BasisTestMaster` script is at the moment
saved as ``~swtest/var/run/basistest.schedule``. The log files of the test executions are
saved in the directory ``~swtest/var/log/``. Note that these paths are configured
in the :ref:`BasisTestCron` script. Old log files are deleted by the :ref:`BasisTestCron`
script after each execution of the test master.

An example test jobs configuration file is given below::

    # MM HH DD   Project Name      Branch   Dashboard   Arguments
    #                                                   (e.g., build configuration)
    # -----------------------------------------------------------------------------------
    # Note: The destination directory for installations is specified by the DESTDIR
    #       environment variable as set in the ~swtest/.bashrc file as well as the
    #       default CMAKE_INSTALL_PREFIX.
    # -----------------------------------------------------------------------------------
      0  1  0    BASIS             trunk    Continuous
      0  0  1    BASIS             trunk    Nightly     doxygen,coverage,memcheck,install
    # -----------------------------------------------------------------------------------
      0  6  0    DRAMMS            trunk    Continuous
      0  0  1    DRAMMS            trunk    Nightly     doxygen,coverage,memcheck,install
    # -----------------------------------------------------------------------------------
      0  0  1    GLISTR            trunk    Continuous  include=sbia
      0  0  7    GLISTR            trunk    Nightly     doxygen,memcheck,coverage,install
      0  0 61    GLISTR            trunk    Nightly     exclude=sbia  # non-parallel
    # -----------------------------------------------------------------------------------
      0  1  0    HardiTk           trunk    Continuous  BUILD_ALL_MODULES=ON
      0  0  1    HardiTk           trunk    Nightly     install,BUILD_ALL_MODULES=ON
    # -----------------------------------------------------------------------------------
      0  0  1    MICO              trunk    Continuous
      0  0  7    MICO              trunk    Nightly     doxygen,memcheck,coverage,install


.. _AdjustmentOfTestSchedule:

Adjustment of Test Schedule
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The current implementation of the :ref:`BasisTestMaster` script does not allow
to specify specific times at which a test job is to be executed.
It only allows for the specification of the interval between test executions.
Hence, if the test master script is executed the first time with a job that
should be executed every day, the job will be executed immediately and then
every 24 hours later. For nightly tests, it is however often desired to actually
run these tests after midnight (more specifically after the nightly start time
configured in CDash such that the test results are submitted to the dashboard
of the current day). To adjust the time when a test job is executed, one has
to edit the test schedule file (i.e., ``~swtest/var/run/basistest.schedule``)
manually. This file lists in the first two columns the date and time after
when the next execution of the test job corresponding to the particular row
should be run. Note that the actual execution time depends on when the
:ref:`BasisTestCron` script is executed. So for the example of nightly test jobs,
the time in the second column for this test job should be changed to "3:30:00"
for example. Choosing a time after midnight will show the nightly test results
on the dashboard page of CDash for the "following" work day. The nightly test
of BASIS itself which is used by the other projects should be executed first
such that the updated BASIS installation is already used by the other tests.

.. note::

    As the test schedule file is generated by the :ref:`BasisTestMaster` script,
    run either this script or the :ref:`BasisTestCron` script with the ``--dry``
    option if this file is missing or was not generated yet. This will skip 
    the immediate execution of all tests, but only create the test schedule
    file which then can be edited manually to adjust the times.

The following is an example of such test schedule file::

    2012-01-11 13:55:04 BASIS trunk Continuous
    2012-01-11 13:55:05 HardiTk trunk Continuous BUILD_ALL_MODULES=ON
    2012-01-11 18:55:04 DRAMMS trunk Continuous
    2012-01-12 03:00:00 BASIS trunk Nightly doxygen,coverage,memcheck,install
    2012-01-12 02:00:00 DRAMMS trunk Nightly doxygen,coverage,memcheck,install
    2012-01-12 12:55:04 GLISTR trunk Continuous include=sbia
    2012-01-12 02:00:00 HardiTk trunk Nightly install,BUILD_ALL_MODULES=ON
    2012-01-12 12:55:05 MICO trunk Continuous
    2012-01-18 03:30:00 GLISTR trunk Nightly doxygen,memcheck,coverage,install
    2012-01-18 03:30:00 MICO trunk Nightly doxygen,memcheck,coverage,install
    2012-03-12 03:30:00 GLISTR trunk Nightly exclude=sbia

Remember that the test schedule is processed by the :ref:`BasisTestMaster`
script on every script invocation. It will output the scheduled tests in chronic
order of their next due date. If a test has been removed from the test configuration
file, it will also no longer show up in the test schedule.


.. _TestingCronJob:

Setting up a Cron Job for Automated Testing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before you schedule a cron job for the automated software testing, open the
:ref:`BasisTestCron` script located in the ``~swtest/bin/`` directory and ensure
that the settings are correct.

Then run crontab_ -e as ``swtest`` user on ``olympus`` and add an entry such as::

    */5 * * * * /sbia/home/swtest/bin/basistest cron

This will run the :ref:`BasisTestCron` script and hence the testing master
script every 5 minutes on ``olympus``. Note that the actual interval for executing
the test jobs in particular depends on the test configuration. Hence, even when
the cron job is executed every 5 minutes, the actual tests may only be run once a
night, a week, a month,... depending on the
:ref:`configuration file <AddingTestsToBasisTestConfiguration>` which is provided
for the :ref:`BasisTestMaster` script, no matter if any files were modified or not.


.. _basistest.ctest: https://cmake-basis.github.io/apidoc/latest/basistest_8ctest.html
.. _crontab: http://adminschoice.com/crontab-quick-reference
.. _sbiaCDash: https://sbia-portal.uphs.upenn.edu/cdash
.. _CTest: http://www.cmake.org/cmake/help/v2.8.8/ctest.html
.. _environment modules: http://modules.sourceforge.net/
.. _Oracle Grid Engine: http://en.wikipedia.org/wiki/Oracle_Grid_Engine
.. _svn: http://svnbook.red-bean.com/en/1.7/svn.ref.svn.html
.. _CDash: http://www.cdash.org/
