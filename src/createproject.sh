#! /usr/bin/env bash

##############################################################################
# \file  createproject
# \brief This BASH script can be used to instantiate the project template
#        in order to create the structure for a new project.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE or Copyright file in project root directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################
 
# ============================================================================
# constants
# ============================================================================

progName=${0##*/} # name of this script

versionMajor=@PROJECT_VERSION_MAJOR@ # major version number
versionMinor=@PROJECT_VERSION_MINOR@ # minor version number
versionPatch=@PROJECT_VERSION_PATCH@ # version patch number

# version string
version="$versionMajor.$versionMinor.$versionPatch"

# repository URL of project templates
baseURL="https://sbia-svn/projects/Development_Project_Templates/RevisedCMakeProjectTemplate"

settingsFile="Settings.cmake" # name of project settings file
dependsFile="Depends.cmake"   # name of project dependencies file

# ============================================================================
# usage / help / version
# ============================================================================

# ****************************************************************************
# \brief Prints version information.
version ()
{
	echo "$progName $version"
}

# ****************************************************************************
# \brief Prints usage information.
usage ()
{
	version
	echo
	echo "Description:"
    echo "  Instantiates the project template, creating the project structure"
    echo "  for a new project."
    echo
    echo "  Besides the name of the new project and a brief description,"
    echo "  names of external packages required or optionally used by this"
    echo "  project can be specified. For each such package, an entry in the"
    echo "  file $dependsFile is created. If the package is not supported"
    echo "  explicitly by this script, generic CMake statements to find the"
    echo "  package are added. Note that these may not work for this unsupported"
    echo "  package. In this case, the $dependsFile file has to be edited manually."
    echo
	echo "Usage:"
	echo "  $progName [options] <project name>"
	echo
    echo "Required options:"
    echo "  <project name>          Name of the new project."
    echo "  -d [--description] arg  Brief project description."
    echo
    echo "Options:"
    echo "  -t [ --template ] arg   Name of the template branch, i.e., template version."
    echo "  -r [ --root ] arg       Specify root directory of new project."
    echo "  -p [ --pkg ] arg        Name of external package required by this project."
    echo "  --optPkg arg            Name of external package optionally used by this project."
    echo "  -v [ --verbose ]        Increases verbosity of output messages. Can be given multiple times."
    echo "  -h [ --help ]           Displays help and exit."
    echo "  -u [ --usage ]          Displays usage information and exits."
    echo "  -V [ --version ]        Displays version information and exits."
	echo
	echo "Example:"
	echo "  $progName SimpleExample -d \"Novel image analysis method.\""
    echo "  $progName ITKExample -d \"An example project which uses ITK.\" -p ITK"
    echo "  $progName MatlabExample -d \"An example project which uses MATLAB.\" -p Matlab"
    echo "  $progName MatlabITKExample -d \"An example project which uses MATLAB and ITK.\" -p Matlab -p ITK"
    echo
    echo "Contact:"
    echo "  SBIA Group at University of Pennsylvania <sbia-software -at- uphs.upenn.edu>"
}

# ****************************************************************************
# \brief Prints help.
help ()
{
	usage
}

# ============================================================================
# helpers
# ============================================================================

# ****************************************************************************
# \brief Make path absolute.
#
# This function returns the absolute path via command substitution, i.e.,
# use it as follows:
#
# \code
# abspath=$(makeAbsolute $relpath)
# \endcode
#
# \param [in]  $1     The (relative) path of a file or directory
#                     (does not need to exist yet).
# \param [out] stdout Prints the absolute path of the specified file or
#                     directory to STDOUT.
#
# \return 0 on success and 1 on failure.
makeAbsolute ()
{
    local path="$1"

    if [ -z "$path" ]; then
        echo "makeAbsolute (): Argument missing!" 1>&2
        return 1
    else
        [ "${path/#\//}" != "$path" ] || path="$(pwd)/$path"
    fi

    echo "$path"
    return 0
}

# ============================================================================
# options
# ============================================================================

# ----------------------------------------------------------------------------
# default options
# ----------------------------------------------------------------------------

template=""              # template (version), i.e., name of tagged branch
name=""                  # name of the project to create
root=""                  # root directory of new project (defaults to `pwd`/$name)
description=""           # project description
verbosity=0              # verbosity level of output messages
packageNames=()          # names of packages the new project depends on
packageRequired=()       # whether the package at the same index in packageNames
                         # is required or optional
packageNum=0             # length of arrays packageNames and packageRequired

# ----------------------------------------------------------------------------
# parse options
# ----------------------------------------------------------------------------

while [ $# -gt 0 ]
do
	case "$1" in
		-u|--usage)
			usage
			exit 0
			;;

		-h|--help)
			help
			exit 0
			;;

		-V|--version)
			version
			exit 0
			;;

        -v|--verbose)
            ((verbosity++))
            ;;

        -t|--template)
            if [ "X$template" != "X" ]; then
                usage
                echo
                echo "Option -t may only be given once!" 1>&2
                exit 1
            fi

            shift
            if [ $# -gt 0 ]; then
                template="$1"
            else
                usage
                echo
                echo "Option -t requires an argument!" 1>&2
                exit 1
            fi
            ;;

        -r|--root)
            if [ "X$root" != "X" ]; then
                usage
                echo
                echo "Option -r may only be given once!" 1>&2
                exit 1
            fi

            shift
            if [ $# -gt 0 ]; then
                root=$(makeAbsolute $1)
            else
                usage
                echo
                echo "Option -r requires an argument!" 1>&2
                exit 1
            fi
            ;;

        -d|--description)
            if [ "X$description" != "X" ]; then
                usage
                echo
                echo "Option -d may only be given once!" 1>&2
                exit 1
            fi

            shift
            if [ $# -gt 0 ]; then
                description="$1"
            else
                usage
                echo
                echo "Option -d requires an argument!" 1>&2
                exit 1
            fi
            ;;

        -p|--pkg)
            shift
            if [ $# -gt 0 ]; then
                packageNames[$packageNum]="$1"
                packageRequired[$packageNum]=1
                ((packageNum++))
            else
                echo "Option -p requires an argument!" 1>&2
                exit 1
            fi
            ;;

        --optPkg)
            shift
            if [ $# -gt 0 ]; then
                packageNames[$packageNum]="$1"
                packageRequired[$packageNum]=0
                ((packageNum++))
            else
                echo "Option --optPkg requires an argument!" 1>&2
                exit 1
            fi
            ;;

        -*)
            usage
            echo
            echo "Invalid option $1!" 1>&2
            exit 1
            ;;

        *)
            if [ "X$name" != "X" ]; then
                usage
                echo
                echo "Project name already specified!" 1>&2
                exit 1
            fi
            name="$1"
            ;;
	esac
    shift
done

# check required options
if [ -z "$name" ]; then
    usage
    echo
    echo "No project name specified!" 1>&2
    exit 1
fi

# set default template
if [ -z "$template" ]; then
    #template="@PROJECT_VERSION_MAJOR@"
    template="trunk"
fi

# set project root from project name if not explicitly specified
if [ -z "$root" ]; then
    root="$(pwd)/$name"
fi

# test if project root already exists
if [ -d "$root" ]; then
    usage
    echo
    echo "Project root directory already exists!" 1>&2
    echo "Please choose another project name or specify a non-existent directory using the -d option." 1>&2
    exit 1
elif [ $verbosity -gt 0 ]; then
    echo "Project root: $root"
fi

# ============================================================================
# instantiate template
# ============================================================================

# ----------------------------------------------------------------------------
# create project structure
# ----------------------------------------------------------------------------

# export project template
if [[ "$template" == "trunk" || "$template" == "HEAD" ]]; then
    URL="$baseURL/trunk/src/template"
else
    URL="$baseURL/tags/@PROJECT_NAME@-$template/src/template"
fi

svn export $URL $root

if [ $? -ne 0 ]; then
    echo
    echo "Failed to export project template!" 1>&2
    exit 1
fi

echo

# ----------------------------------------------------------------------------
# alter project settings
# ----------------------------------------------------------------------------

echo "Altering project settings..."

settingsFilePath="$(find "$root" -name "$settingsFile")"

if [ -z "$settingsFilePath" ]; then
    echo "Settings file $settingsFile not found!" 1>&2
    exit 1
fi

if [ $verbosity -gt 0 ]; then
    echo "Settings file: $settingsFilePath"
fi

sed -i "s/PROJECT_NAME \".*\"/PROJECT_NAME \"$name\"/g" "$settingsFilePath"

if [ $? -ne 0 ]; then
    echo "Failed to set project name!" 1>&2
fi

sed -i "s/PROJECT_DESCRIPTION \".*\"/PROJECT_DESCRIPTION \"$description\"/g" "$settingsFilePath"

if [ $? -ne 0 ]; then
    echo "Failed to set project description!" 1>&2
fi

echo "Altering project settings... - done"

# ============================================================================
# dependencies
# ============================================================================

findPackage ()
{
    local file=$1
    local package=$2
    local required=$3
    local useFile=$4
    local prefix=$package

    if [ $# -gt 3 ]; then
        prefix=$(echo $prefix | tr [:lower:] [:upper:])
    fi

    echo >> $file
    echo "# ----------------------------------------------------------------------------" >> $file
    echo "# $package" >> $file
    echo "# ----------------------------------------------------------------------------" >> $file
    echo >> $file
    if [ $required -ne 0 ]; then
    echo "find_package (${package} REQUIRED)" >> $file
    else
    echo "find_package (${package})" >> $file
    fi
    echo >> $file
    echo "if (${prefix}_FOUND)" >> $file
    if [ $useFile -ne 0 ]; then
    echo "  include (\${${prefix}_USE_FILE})" >> $file
    else
    echo "  if (${prefix}_INCLUDE_DIRS)" >> $file
    echo "    include_directories (\${${prefix}_INCLUDE_DIRS})" >> $file
    echo "  elseif (${prefix}_INCLUDE_DIR)" >> $file
    echo "    include_directories (\${${prefix}_INCLUDE_DIR})" >> $file
    echo "  endif ()" >> $file
    echo >> $file
    echo "  if (${prefix}_LIBRARY_DIRS)" >> $file
    echo "    link_directories (\${${prefix}_LIBRARY_DIRS})" >> $file
    echo "  elseif (${prefix}_LIBRARY_DIR)" >> $file
    echo "    link_directories (\${${prefix}_LIBRARY_DIR})" >> $file
    echo "  endif ()" >> $file
    fi
    echo "endif ()" >> $file
}

if [ $packageNum -gt 0 ]; then
    echo "Setting up project dependencies..."

    dependsFilePath="$(find "$root" -name "$dependsFile")"

    if [ -z "$dependsFilePath" ]; then
        echo "Dependencies file $dependsFile not found!" 1>&2
        exit 1
    fi

    if [ $verbosity -gt 0 ]; then
        echo "Dependencies file: $dependsFilePath"
    fi

    idx=0

    while [ $idx -lt $packageNum ]
    do
        pkg="${packageNames[$idx]}"
        required="${packageRequired[$idx]}"

        case "$pkg" in
            # use package name for both find_package ()
            # and <pkg>_VARIABLE variable names
            # -> package provides <PKG>_USE_FILE
            ITK)
                findPackage $dependsFilePath $pkg $required 0 1
                ;;
            # use package name for find_package ()
            # and <PKG>_VARIABLE variable names
            Matlab)
                findPackage $dependsFilePath $pkg $required 1 0
                ;;
            # default, use package name for both find_package ()
            # and <pkg>_VARIABLE variable names
            *)
                findPackage $dependsFilePath $pkg $required 0 0
                ;;
        esac

        ((idx++))
    done

    echo "Setting up project dependencies... - done"
fi

# ============================================================================
# done
# ============================================================================

echo
echo "Project \"$name\" created in $root"
exit 0
