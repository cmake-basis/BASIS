.. meta::
    :description: This BASIS how-to guide gives examples on how to parse the
                  command-line arguments in C++ programs.

=========================================
Parsing the Command-line Arguments in C++
=========================================

For the parsing of command-line arguments in C++, BASIS includes a slightly
extended version of the Templatized C++ Command Line Parser (TCLAP_) Library.
For details and usage of this library, please refer to the TCLAP documentation.
It is in particular recommended to read the `TCLAP manual`_.
Further, the `TCLAP API documentation` is a good reference on the available
command-line argument classes. The API documentation of the TCLAP classes can
also be found as part of this documentation.

.. note::

    BASIS provides its own subclass of the ``TCLAP::CmdLine`` class
    which is also named ``CmdLine``, but in the ``basis`` namespace, i.e.,
    ``basis::CmdLine``. Most of the argument implementations are, however,
    simply typedefs of the commonly used ``TCLAP::Arg`` subclasses.
    See the `API documentation <https://cmake-basis.github.io/apidoc/latest/group__CxxCmdLine.html>`_
    for a list of command-line arguments which are made available as part of
    the ``basis`` namespace.

The usage of the command-line parsing library shall be demonstrated in the
following on the implementation of an example command-line program. It should
be noted that the try-catch block in the ``main()`` function will only help to
track errors in the command-line specification, but once the ``cmd`` instance
is initialized properly, all runtime exceptions related to the parsing of
the command-line are handled by BASIS.

.. code-block:: c++

    /**
     * @file  smoothimage.cxx
     * @breif Smooth image using Gaussian or anisotropic diffusion filtering.
     */

    #include <package/basis.h> // include BASIS C++ utilities


    // acceptable in .cxx file
    using namespace std;
    using namespace basis;


    // ===========================================================================
    // smoothing filters
    // ===========================================================================

    // ---------------------------------------------------------------------------
    int gaussianfilter(const string&               imagefile,
                       const vector<unsigned int>& r,
                       double                      std)
    {
        // [...]
        return 0;
    }

    // ---------------------------------------------------------------------------
    int anisotropicfilter(const string& imagefile)
    {
        // [...]
        return 0;
    }

    // ===========================================================================
    // main
    // ===========================================================================

    // ---------------------------------------------------------------------------
    int main(int argc, char* argv[])
    {
        // -----------------------------------------------------------------------
        // define command-line arguments
        SwitchArg gaussian(                          // option switch
            "g", "gaussian",                         // short and long option name
            "Smooth image using a Gaussian filter.", // argument help
            false);                                  // default value

        SwitchArg anisotropic(                       // option switch
            "a", "anisotropic",                      // short and long option name
            "Smooth image using anisotropic diffusion filter.", // argument help
            false);                                  // default value

        MultiUIntArg gaussian_radius(                // unsigned integer values
            "r", "radius",                           // short and long option name
            "Radius of Gaussian kernel in each dimension.", // argument help
            false,                                   // required?
            "<rx> <ry> <rz>",                        // value type description
            3,                                       // number of values per argument
            true);                                   // accept argument only once

        DoubleArg gaussian_std(                      // floating-point argument value
            "", "std",                               // only long option name
            "Standard deviation of Gaussian in voxel units.", // argument help
            false,                                   // required?
            2.0,                                     // default value
            "<float>");                              // value type description

        // [...]

        PositionalArg imagefile(                     // positional, i.e., unlabeled
            "image",                                 // only long option name
            "Image to be smoothed.",                 // argument help
            true,                                    // required?
            "",                                      // default value
            "<image>");                              // value type description

        // -----------------------------------------------------------------------
        // parse command-line
        try {
            vector<string> examples;

            examples.push_back(
                    "EXENAME --gaussian --std 3.5 --radius 5 5 3 brain.nii\n"
                    "Smooths the image brain.nii using a Gaussian with standard"
                    " deviation 3.5 voxel units and 5 voxels in-slice radius and"
                    " 3 voxels radius across slices.");

            examples.push_back(
                    "EXENAME  --anisotropic brain.nii\n"
                    "Smooths the image brain.nii using an anisotropic diffusion filter.");

            CmdLine cmd(
                    // program identification
                    "smoothimage", PROJECT,
                    // program description
                    "This program smooths an input image using either a Gaussian "
                    "filter or an anisotropic diffusion filter.",
                    // example usage
                    examples,
                    // version information
                    RELEASE, "2011 University of Pennsylvania");

            // The constructor of the CmdLine class has already added the standard
            // arguments --help, --helpshort, --helpxml, --helpman, and --version.

            cmd.xorAdd(gaussian, anisotropic);
            cmd.add(gaussian_std);
            cmd.add(gaussian_radius);
            cmd.add(imagefile);

            cmd.parse(argc, argv);
        } catch (CmdLineException& e) {
            // invalid command-line specification
            cerr << e.error() << endl;
            exit(1);
        }

        // -----------------------------------------------------------------------
        // smooth image - access parsed argument value using Arg::getValue()
        unsigned int r[3];

        if (gaussian.getValue()) {
            return gaussianfilter(imagefile.getValue(),
                                  gaussian_radius.getValue(),
                                  gaussian_std.getValue());
        } else {
            return anisotropicfilter(imagefile.getValue());
        }
    }

Running the above program with the ``--help`` option will give the output::

    SYNOPSIS
        smoothimage [--std <float>] [--radius <rx> <ry> <rz>] [--verbose|-v]
                    {--gaussian|--anisotropic} <image>
        smoothimage [--help|-h|--helpshort|--helpxml|--helpman|--version]

    DESCRIPTION
        This program smooths an input image using either a Gaussian filter or
        an anisotropic diffusion filter.

    OPTIONS
        Required arguments:
           -g or --gaussian
                Smooth image using a Gaussian filter.
           or -a or --anisotropic
                Smooth image using anisotropic diffusion filter.

           <image>
                Image to be smoothed.

        Optional arguments:
           -s or --std <float>
                Standard deviation of Gaussian in voxel units.

           -r or --radius <rx> <ry> <rz>
                Radius of Gaussian kernel in each dimension.

        Standard arguments:
           -- or --ignore_rest
                Ignores the rest of the labeled arguments following this flag.

           -v or --verbose
                Increase verbosity of output messages.

           -h or --help
                Display help and exit.

           --helpshort
                Display short help and exit.

           --helpxml
                Display help in XML format and exit.

           --helpman
                Display help as man page and exit.

           --version
                Display version information and exit.

    EXAMPLE
        smoothimage --gaussian --std 3.5 --radius 5 5 3 brain.nii

            Smooths the image brain.nii using a Gaussian with standard
            deviation 3.5 voxel units and 5 voxels in-slice radius and 3 voxels
            radius across slices.

        smoothimage --anisotropic brain.nii

            Smooths the image brain.nii using an anisotropic diffusion filter.

    CONTACT
        SBIA Group <sbia-software at uphs.upenn.edu>

The ``--helpshort`` output contains the synopsis of the full help only::

    smoothimage [--std <float>] [--radius <rx> <ry> <rz>] [--verbose|-v]
                {--gaussian|--anisotropic} <image>
    smoothimage [--help|-h|--helpshort|--helpxml|--helpman|--version]


.. _TCLAP: http://tclap.sourceforge.net/
.. _TCLAP manual: http://tclap.sourceforge.net/manual.html
.. _TCLAP API documentation: http://tclap.sourceforge.net/html/index.html
