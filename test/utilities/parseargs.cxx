/**
 * @file  parseargs.cxx
 * @breif Test program for C++ command-line parsing library.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

#include <basis/basis.h> // include BASIS C++ utilities


// acceptable in .cxx file
using namespace std;
using namespace basis;


// ===========================================================================
// smoothing filters
// ===========================================================================

// ---------------------------------------------------------------------------
int gaussianfilter(const string& imagefile, vector<unsigned int> r, double std)
{
    static_cast<void>(imagefile); // avoid unused warnings
    static_cast<void>(r);         // avoid unused warnings
    static_cast<void>(std);       // avoid unused warnings
    // [...]
    return 0;
}

// ---------------------------------------------------------------------------
int anisotropicfilter(const string& imagefile)
{
    static_cast<void>(imagefile); // avoid unused warnings
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

    MultiUIntArg gaussian_kernel(                // alternative for --radius
        "", "kernel", "", false, "<rx> <ry> <rz>", 3, true);

    DoubleArg gaussian_std(                      // floating-point argument value
        "s", "std",                              // short and long option name
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
        vector<string> examples; // usage examples

        examples.push_back(
                "EXECNAME --gaussian --std 3.5 --radius 5 5 3 brain.nii\n"
                "Smooths the image brain.nii using a Gaussian with standard"
                " deviation 3.5 voxel units and 5 voxels in-slice radius and"
                " 3 voxels radius across slices.");

        examples.push_back(
                "EXECNAME --anisotropic brain.nii\n"
                "Smooths the image brain.nii using an anisotropic diffusion filter.");

        CmdLine cmd(
                // program identification
                "smoothimage", PROJECT,
                // description
                "This program smooths an input image using either a Gaussian "
                "filter or an anisotropic diffusion filter.",
                // example usage
                examples,
                // version information
                RELEASE, "2011, 2012 University of Pennsylvania");

        cmd.xorAdd(gaussian, anisotropic);
        cmd.add(gaussian_std);
        cmd.xorAdd(gaussian_kernel, gaussian_radius);
        cmd.add(imagefile);

        cmd.parse(argc, argv);
    } catch (CmdLineException& e) {
        // invalid command-line specification
        cerr << e.error() << endl;
        exit(1);
    }

    // -----------------------------------------------------------------------
    // smooth image - access parsed argument values using Arg::getValue()
    if (gaussian.getValue()) {
        return gaussianfilter(imagefile.getValue(),
                              gaussian_radius.getValue(),
                              gaussian_std.getValue());
    } else {
        return anisotropicfilter(imagefile.getValue());
    }
}
