#! /usr/bin/env bash

##############################################################################
# \file  basisproject.sh
# \brief This shell script is used to create or modify a BASIS project.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See LICENSE file in project root or 'doc' directory for details.
#
# Contact: SBIA Group <sbia-software -at- uphs.upenn.edu>
##############################################################################
 
# ============================================================================
# constants
# ============================================================================

progName=${0##*/}                # name of this script
progDir=`cd \`dirname $0\`; pwd` # directory of this script

versionMajor='@VERSION_MAJOR@' # major version number
versionMinor='@VERSION_MINOR@' # minor version number
versionPatch='@VERSION_PATCH@' # version patch number

# version string
version="$versionMajor.$versionMinor.$versionPatch"

# name of CMake configuration file used to resolve dependencies
dependsFile='Depends.cmake'

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
	echo "$progName $versionMajor.$versionMinor"
	echo
	echo "Description:"
    echo "  This command-line tool can be used to create a new BASIS project from the"
    echo "  project template version $versionMajor.$versionMinor and to update or modify"
    echo "  an already existing project which was previously created using this script."
    echo
    echo "  Depending on the grade of customization or optional inclusion of template"
    echo "  components, different subsets of the fully featured project template can be"
    echo "  selected. Additional template files and folders can be added to an existing"
    echo "  project at any time."
    echo
    echo "  Besides the name of the new project and a brief description, names of external"
    echo "  packages required or optionally used by this project can be specified. For each"
    echo "  such package, an entry in the project's $dependsFile file is created. If the"
    echo "  package is not supported explicitly by this script, generic CMake statements to"
    echo "  find the package are added. Note that these may not work for this unsupported"
    echo "  package. In this case, the $dependsFile file has to be edited manually."
    echo "  Note that if an existing project is modified, the $dependsFile file is added if"
    echo "  not yet existent, i.e., ignoring the option --no-config-depends."
    echo
	echo "Usage:"
	echo "  $progName [options] <project name>"
	echo
    echo "Required options:"
    echo "  <project name>             Name of the new project."
    echo "  -d [ --description ] arg   Brief project description."
    echo "  -r [ --root ] arg          Specify root directory of new project or directory of"
    echo "                             existing project. If the specified directory already exists"
    echo "                             this program will modify this project. The project name and"
    echo "                             description options must not be given in this case as these"
    echo "                             attributes of a project cannot be modified any more."
    echo
    echo "Options:"
    echo "  -t [ --template ] arg   Root directory of project template."
    echo "  --no-update             Do not update existing files. Only add files."
    echo "                          By default, already existing files will be merged with template."
    echo "  -p [ --pkg ] arg        Name of external package required by this project."
    echo "  --optPkg arg            Name of external package optionally used by this project."
    echo "  -v [ --verbose ]        Increases verbosity of output messages. Can be given multiple times."
    echo "  -h [ --help ]           Displays help and exit."
    echo "  -u [ --usage ]          Displays usage information and exits."
    echo "  -V [ --version ]        Displays version information and exits."
	echo
    echo "Pre-configured project templates:"
    echo "  --empty                 Choose empty project template. Use select template file options"
    echo "                          to add files to the project. Can be useful in conjunction with"
    echo "                          a project root of an existing project to add additional template"
    echo "                          files which were not selected before. Another use case would be"
    echo "                          to reset only selected project files using the --overwrite option."
    echo "  --minimal               Choose minimal project template. Corresponds to not selecting any"
    echo "                          of the additional template files."
    echo "  --standard              Choose standard project template. This is the default template used"
    echo "                          if no other project template is chosen. Corresponds to:"
    echo
    echo "                            --conf-depends"
    echo "                            --conf-find"
    echo "                            --conf-settings"
    echo "                            --conf-use"
    echo "                            --example"
    echo "                            --tests"
    echo "                            --no-conf-components"
    echo "                            --no-conf-generate"
    echo "                            --no-conf-package"
    echo "                            --no-conf-script"
    echo "                            --no-conf-version"
    echo "                            --no-data"
    echo "                            --no-unit-tests"
    echo
    echo "  --full                  Choose full project template. Corresponds to selecting all files."
    echo
    echo "Options to select template files:"
    echo "  --conf-components       Whether to include custom Components.cmake file."
    echo "  --conf-find             Whether to include custom <project>Config.cmake file."
    echo "  --conf-find-version     Whether to include custom <project>ConfigVersion.cmake file."
    echo "  --conf-generate         Whether to include custom GenerateConfig.cmake script."
    echo "  --conf-package          Whether to include custom Package.cmake file."
    echo "  --conf-script           Whether to include custom ScriptConfig.cmake file."
    echo "  --conf-tests            Whether to include custom CTestCustom.cmake file."
    echo "  --conf-use              Whether to include custom <project>Use.cmake file."
    echo "  --data                  Whether to include support of auxiliary data."
    echo "  --example               Whether to include support of example."
    echo "  --tests                 Whether to include support of system tests."
    echo "  --unit-tests            Whether to include support of unit tests."
    echo
    echo "Options to deselect template files:"
    echo "  --no-conf-components    Whether to exclude custom Components.cmake file."
    echo "  --no-conf-find          Whether to exclude custom <project>Config.cmake file."
    echo "  --no-conf-find-version  Whether to exclude custom <project>ConfigVersion.cmake file."
    echo "  --no-conf-generate      Whether to exclude custom GenerateConfig.cmake script."
    echo "  --no-conf-package       Whether to exclude custom Package.cmake file."
    echo "  --no-conf-script        Whether to exclude custom ScriptConfig.cmake file."
    echo "  --no-conf-tests         Whether to exclude custom CTestCustom.cmake file."
    echo "  --no-conf-use           Whether to exclude custom <project>Use.cmake file."
    echo "  --no-data               Whether to exclude support of auxiliary data."
    echo "  --no-example            Whether to exclude support of example."
    echo "  --no-tests              Whether to exclude support of system tests."
    echo "  --no-unit-tests         Whether to exclude support of unit tests."
    echo
	echo "Example:"
	echo "  $progName SimpleExample -d \"Novel image analysis method.\""
    echo "  $progName ITKExample -d \"An example project which uses ITK.\" -p ITK"
    echo "  $progName MatlabExample -d \"An example project which uses MATLAB.\" -p Matlab"
    echo "  $progName MatlabITKExample -d \"An example project which uses MATLAB and ITK.\" -p Matlab -p ITK"
    echo "  $progName ExistingProject -r \"/path/to/existing/project\" --conf-tests"
    echo
    echo "Contact:"
    echo "  SBIA Group <sbia-software -at- uphs.upenn.edu>"
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
# \param [in]  1      The (relative) path of a file or directory
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

# root directory of project template
template="$progDir/@TEMPLATE_DIR@"

root=""            # root directory of new project (defaults to `pwd`/$name)
name=""            # name of the project to create
description=""     # project description
verbosity=0        # verbosity level of output messages
packageNames=()    # names of packages the new project depends on
packageRequired=() # whether the package at the same index in packageNames
                   # is required or optional
packageNum=0       # length of arrays packageNames and packageRequired
update=1           # whether to update existing files

minimal=1
confSettings=1
confDepends=1
confComponents=0
confPackage=0
confFind=0
confFindVersion=0
confGenerate=0
confScript=0
confTests=0
confUse=0
data=0
example=1
tests=1
unitTests=0
 
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
            shift
            if [ $# -gt 0 ]; then
                template=$(makeAbsolute $1)
            else
                usage
                echo
                echo "Option -t requires an argument!" 1>&2
                exit 1
            fi
            ;;
 
        -r|--root)
            if [ ! -z "$root" ]; then
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
            if [ ! -z "$description" ]; then
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

        --no-update)
            update=0
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

        --empty)
            shift
            minimal=0
            confSettings=0
            confDepends=0
            confComponents=0
            confPackage=0
            confFind=0
            confFindVersion=0
            confGenerate=0
            confScript=0
            confTests=0
            confUse=0
            data=0
            example=0
            tests=0
            unitTests=0
            ;;

        --minimal)
            shift
            minimal=1
            confSettings=0
            confDepends=0
            confComponents=0
            confPackage=0
            confFind=0
            confFindVersion=0
            confGenerate=0
            confScript=0
            confTests=0
            confUse=0
            data=0
            example=0
            tests=0
            unitTests=0
            ;;
        --standard)
            shift
            minimal=1
            confSettings=1
            confDepends=1
            confComponents=0
            confPackage=0
            confFind=0
            confFindVersion=0
            confGenerate=0
            confScript=0
            confTests=0
            confUse=0
            data=0
            example=1
            tests=1
            unitTests=0
            ;;

        --full)
            shift
            minimal=1
            confSettings=1
            confDepends=1
            confComponents=1
            confPackage=1
            confFind=1
            confFindVersion=1
            confGenerate=1
            confScript=1
            confTests=1
            confUse=1
            data=1
            example=1
            tests=1
            unitTests=1
            ;;

        --conf-settings)
            shift
            confSettings=1
            ;;

        --no-conf-settings)
            shift
            confSettings=0
            ;;

        --conf-depends)
            shift
            confDepends=1
            ;;

        --no-conf-depends)
            shift
            confDepends=0
            ;;

        --conf-components)
            shift
            confComponents=1
            ;;

        --no-conf-components)
            shift
            confComponents=0
            ;;

        --conf-package)
            shift
            confPackage=1
            ;;

        --no-conf-package)
            shift
            confPackage=0
            ;;

        --conf-find)
            shift
            confFind=1
            ;;

        --no-conf-find)
            shift
            confFind=0
            ;;

        --conf-find-version)
            shift
            confFindVersion=1
            ;;

        --no-conf-find-version)
            shift
            confFindVersion=0
            ;;

        --conf-generate)
            shift
            confGenerate=1
            ;;

        --no-conf-generate)
            shift
            confGenerate=0
            ;;

        --conf-script)
            shift
            confScript=1
            ;;

        --no-conf-script)
            shift
            confScript=0
            ;;

        --conf-tests)
            shift
            confTests=1
            ;;

        --no-conf-tests)
            shift
            confTests=0
            ;;

        --conf-use)
            shift
            confUse=1
            ;;

        --no-conf-use)
            shift
            confUse=0
            ;;

        --data)
            shift
            data=1
            ;;

        --no-data)
            shift
            data=0
            ;;

        --example)
            shift
            example=1
            ;;

        --no-example)
            shift
            example=0
            ;;

        --tests)
            shift
            tests=1
            ;;

        --no-tests)
            shift
            tests=0
            ;;

        --unit-tests)
            shift
            unitTests=1
            ;;

        --no-unit-tests)
            shift
            unitTests=0
            ;;

        -*)
            usage
            echo
            echo "Invalid option $1!" 1>&2
            exit 1
            ;;

        *)
            if [ ! -z "$name" ]; then
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

# simplify template path
cwd=$(pwd)
cd $template
if [ $? -ne 0 ]; then
    echo "Invalid project template!"
    exit 1
fi
template=$(pwd)
cd $cwd

# request to create new project
mode=0
if [ ! -z "$name" ]; then
    if [ -z "$description" ]; then
        usage
        echo
        echo "No project description given!"
        exit 1
    fi
    mode=1
    if [ -z "$root" ]; then
        root="$(pwd)/$name"
    fi
    if [ -e "$root" ]; then
        usage
        echo
        echo "Directory or file of name $root exists already." 1>&2
        echo "Please choose another project name or root directory using the -r option." 1>&2
        echo "If you want to modify an existing project, please provide the root directory using the -r option." 1>&2
        exit 1
    fi
# request to modify existing project
elif [ ! -z "$root" ]; then
    if [ $update -eq 0 ]; then
        mode=2
    else
        mode=3
    fi
    if [ ! -d "$root" ]; then
        usage
        echo
        echo "Project directory $root does not exist!" 1>&2
        echo "If you want to create a new project, please specify a project name." 1>&2
        exit 1
    fi
    if [ ! -z "$description" ]; then
        usage
        echo
        echo "Cannot modify description of existing project. You have to do this manually." 1>&2
        exit 1
    fi
# invalid usage
else
    usage
    echo
    echo "Either project name or project root must be specified!" 1>&2
    exit 1
fi

# print template and root path
if [ $verbosity -gt 0 ]; then
    echo
    echo "Root directories:"
    echo "  Project:  $root"
    echo "  Template: $template"
    echo
fi

# ============================================================================
# main
# ============================================================================

# ****************************************************************************
# \brief Extract project name from existing project.

getProjectName ()
{
    # \todo Should probably be more sophisticated...
    cat $root/CMakeLists.txt | grep 'NAME[ ]\+' | sed 's/.*\"\(.*\)\".*/\1/' 
}

if [ -z $name ]; then
    name=$(getProjectName)
fi

# ****************************************************************************
# \brief Add or modify project directory or file.
#
# Only the named directory or file is added or modified.
#
# \param [in] 1 The path of the directory or file relative to the template
#               or project root, respectively.

merge ()
{
    local path="$1"
    local exists=0
    local ok=1

    if [ ! -e $template/$path ]; then
        echo "E $root/$path - template missing"
        return 1
    fi

    if [ -e $root/$path ]; then
        exists=1
        if [ -d $template/$path ]; then
            if [ ! -d $root/$path ]; then
                echo "E $root/$path - not a directory"
                return 1
            else
                return 0
            fi
        elif [ -f $template/$path ]; then
            if [ ! -f $root/$path ]; then
                echo "E $root/$path - not a file"
                return 1
            fi
            if [ $mode -ne 3 ]; then
                echo "S $root/$path"
                return 0
            fi
        fi
    fi

    if [ -d "$template/$path" ]; then
        mkdir -p "$root/$path"
        if [ $? -ne 0 ]; then
            echo "E $root/$path - failed to make directory"
            ok=0
        else
            echo "A $root/$path"
        fi
    elif [ -f "$template/$path" ]; then
        local dir=`dirname $root/$path`
        local base=`basename $root/$path`
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            if [ $? -ne 0 ]; then
                echo "E $dir - failed to make directory"
                ok=0
            else
                echo "A $dir"
            fi
        fi
        if [ $ok -eq 1 -a $exists -eq 0 ]; then
            cp "$template/$path" "$root/$path"
            if [ $? -ne 0 ]; then
                echo "E $root/$path - failed to add file"
                ok=0
            else
                cp "$template/$path" "$dir/.$base"
                if [ $? -ne 0 ]; then
                    echo "W $root/$path - file added, but failed to create hidden backup (will not be able to update file later)"
                else
                    echo "A $root/$path"
                fi
            fi
            if [ $ok -eq 1 ]; then
                sed -i '~' "s/ReplaceByProjectName/$name/g" "$root/$path"
                if [ $? -ne 0 -a -f "$root/$path~" ]; then
                    cp "$root/$path~" "$root/$path"
                fi
                sed -i '~' "s/ReplaceByProjectDescription/$description/g" "$root/$path"
                if [ $? -ne 0 -a -f "$root/$path~" ]; then
                    cp "$root/$path~" "$root/$path"
                fi
                if [ $verbosity -gt 0 ]; then
                    diff "$root/$path" "$root/$path~" > /dev/null
                    if [ $? -ne 0 ]; then
                        echo "M $root/$path"
                    fi
                fi
                rm -f "$root/$path~"
            fi
        elif [ $ok -eq 1 ]; then
            if [ -f "$dir/.$base" ]; then
                cp "$root/$path" "$dir/$base~"
                if [ $? -ne 0 ]; then
                    echo "S $root/$path - failed to backup file"
                    ok=0
                else
                    diff3 -m "$root/$path" "$dir/.$base" "$template/$path" > "$root/$path.merged"
                    if [ $? -ne 0 ]; then
                        echo "E $root/$path - failed to update file"
                        ok=0
                    else
                        diff "$root/$path" "$root/$path.merged" > /dev/null
                        if [ $? -ne 0 ]; then
                            mv "$root/$path.merged" "$root/$path"
                            echo "U $root/$path"
                        else
                            rm -f "$root/$path.merged"
                        fi
                    fi
                fi
            else
                echo "S $root/$path - missing backup of template"
                ok=0
            fi
        fi
    fi

    if [ $ok -eq 0 ]; then
        return 1
    else
        return 0
    fi
}

# ----------------------------------------------------------------------------
# modify project files

set +e # "automatically" bail-out on error

if   [ $mode -eq 1 ]; then
    msg="Adding project files"
elif [ $mode -eq 2 ]; then
    msg="Adding project files"
elif [ $mode -eq 3 ]; then
    msg="Adding/Updating project files"
else
    echo "Invalid mode $mode!"
    exit 1
fi
echo "$msg..."

# minimal project structure
if [ $minimal -ne 0 ]; then
    merge "AUTHORS"
    merge "README"
    merge "INSTALL"
    merge "LICENSE"
    merge "CMakeLists.txt"
    merge "doc/CMakeLists.txt"
    merge "src/CMakeLists.txt"
fi

# additional configuration files
if [ $confSettings -ne 0 ]; then
    merge "config/Settings.cmake"
fi
if [ $confDepends -ne 0 -o $packageNum -gt 0 ]; then
    merge "config/Depends.cmake"
fi
if [ $confComponents -ne 0 ]; then
    merge "config/Components.cmake"
fi
if [ $confPackage -ne 0 ]; then
    merge "config/Package.cmake"
fi
if [ $confFind -ne 0 ]; then
    merge "config/Config.cmake.in"
    merge "config/ConfigBuild.cmake"
    merge "config/ConfigInstall.cmake"
fi
if [ $confFindVersion -ne 0 ]; then
    merge "config/ConfigVersion.cmake.in"
fi
if [ $confGenerate -ne 0 ]; then
    merge "config/GenerateConfig.cmake"
fi
if [ $confScript -ne 0 ]; then
    merge "config/ScriptConfig.cmake.in"
fi
if [ $confTests -ne 0 ]; then
    merge "config/CTestCustom.cmake.in"
fi
if [ $confUse -ne 0 ]; then
    merge "config/Use.cmake.in"
fi

# auxiliary data
if [ $data -ne 0 ]; then
    merge "data/CMakeLists.txt"
fi

# testing tree
if [ $tests -ne 0 -o $unitTests -ne 0 ]; then
    merge "CTestConfig.cmake"
    merge "test/CMakeLists.txt"
    merge "test/data"
    merge "test/expected"
fi
if [ $tests -ne 0 ]; then
    merge "test/system/CMakeLists.txt"
fi
if [ $unitTests -ne 0 ]; then
    merge "test/unit/CMakeLists.txt"
fi

# example
if [ $example -ne 0 ]; then
    merge "example/CMakeLists.txt"
fi

# done
echo "$msg... - done"

set -e # let us handle errors ourselves again

# ****************************************************************************
# \brief Append find_package () commands to CMake configuration file.
#
# \param [in] 1 The path to the CMake configuration file.
# \param [in] 2 The name of the package.
# \param [in] 3 Whether this package is required.
# \param [in] 4 Whether to use uppercase only prefix for variables.
# \param [in] 5 Whether this package provides a <name>Use.cmake file.
# \param [in] 6 Prefix to use for package variables. Defaults to package name.

findPackage ()
{
    local file=$1
    local package=$2
    local required=$3
    local uppercasePrefix=$4
    local useFile=$5
    local prefix=$package

    if [ $# -gt 5 ]; then
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
    # \note According to an email on the CMake mailing list, it is not a good idea
    #       to use link_directories () any more given that the arguments to
    #       target_link_libraries () are absolute paths to the library files.
    #echo >> $file
    #echo "  if (${prefix}_LIBRARY_DIRS)" >> $file
    #echo "    link_directories (\${${prefix}_LIBRARY_DIRS})" >> $file
    #echo "  elseif (${prefix}_LIBRARY_DIR)" >> $file
    #echo "    link_directories (\${${prefix}_LIBRARY_DIR})" >> $file
    #echo "  endif ()" >> $file
    fi
    echo "endif ()" >> $file
}

# ----------------------------------------------------------------------------
# modify dependencies

if [ $packageNum -gt 0 ]; then
    echo "Adding dependencies..."

    dependsFilePath="$(find "$root" -name "$dependsFile")"

    if [ -z "$dependsFilePath" ]; then
        echo "Dependencies file $dependsFile not found!" 1>&2
        exit 1
    fi

    if [ $verbosity -gt 0 ]; then
        echo
        echo "Dependencies configuration file: $dependsFilePath"
        echo
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

    echo "Adding dependencies... - done"
fi

# ============================================================================
# done
# ============================================================================

echo
if [ $mode -eq 1 ]; then
    msg="Project \"$name\" created successfully"
else
    msg="Project \"$name\" modified successfully"
fi
echo $msg

exit 0

