##############################################################################
# @file  Utilities.pm
# @brief Default implementation of BASIS Perl Utilities.
#
# This module defines the default BASIS utility functions. These default
# implementations are not project-specific, i.e., do not make use of particular
# project attributes such as the name or version of the project. The utility
# functions defined by this module are intended for use in Perl scripts that
# are not build as part of a particular BASIS project. Otherwise, the
# project-specific implementations should be used instead, i.e., those defined
# by the Basis.pm module of the project which is automatically added to the
# project during the configuration of the build tree. This Basis.pm module and
# the submodules used by it are generated from template modules which are
# customized for the particular project that is being build.
#
# The default values used by the functions defined by this module are defined
# in the SBIA::BASIS::Config module. See this module for details on how to
# customize the utility functions.
#
# Copyright (c) 2011, 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisPerlUtilities
##############################################################################

package SBIA::BASIS::Utilities;

# ============================================================================
# modules
# ============================================================================

use strict;
use warnings;

use SBIA::BASIS::Config qw(VERSION CONTACT COPYRIGHT LICENSE);
use SBIA::BASIS::Which  qw(which);

# ============================================================================
# exports
# ============================================================================

our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

BEGIN {
    use Exporter();

    $VERSION = VERSION;
    @ISA     = qw(Exporter);

    %EXPORT_TAGS = (
        default => [qw(
            print_version
            print_contact
            execute_process
            get_executable_path
            get_executable_name
            get_executable_directory
        )],

        everything => [qw(
            print_version
            print_contact
            execute_process
            get_executable_path
            get_executable_name
            get_executable_directory
            to_quoted_string
            split_quoted_string
            CONTACT
            COPYRIGHT
            LICENSE
        )]
    );

    Exporter::export_ok_tags('everything');
}


## @addtogroup BasisPerlUtilities
# @{


# ============================================================================
# executable information
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Print contact information.
#
# @param [in] contact Name of contact. If @c undef, the default contact defined
#                     by $SBIA::BASIS::Config::CONTACT is used.
#
# @sa SBIA::BASIS::Config
sub print_contact
{
    my $contact = $_[0];
    $contact = CONTACT unless $contact;
    print "Contact:\n  $contact\n";
}

# ----------------------------------------------------------------------------
## @brief Print version information including copyright and license notices.
#
# @param [in] name      Name of executable. Should not be set programmatically
#                       to the first argument of the main script, but a string
#                       literal instead.
# @param [in] version   Version of executable, e.g., release of project this
#                       executable belongs to.
# @param [in] project   Name of project this executable belongs to.
#                       If @c undef or an empty string is given, no project
#                       information is included in output.
# @param [in] copyright The copyright notice. If @c undef, the default copyright
#                       defined by $SBIA::BASIS::Config::COPYRIGHT is used.
#                       If an empty string is given, no copyright notice is printed.
# @param [in] license   Information regarding licensing. If @c undef, the default
#                       software license as defined by $SBIA::BASIS::Config::LICENSE
#                       is used. If an empty string is given, no license
#                       information is printed.
#
# @sa SBIA::BASIS::Config
sub print_version
{
    my $name     = shift or die "print_version(): Missing name argument";
    my $version  = shift or die "print_version(): Missing version argument";
    if ($name =~ m/^(project|copyright|license)$/) {
        warn "print_version(): Name argument matches option name. Missing name argument?";
    }
    if ($version =~ m/^(project|copyright|license)$/) {
        warn "print_version(): Version argument matches option name. Missing version argument?";
    }
    my %defaults = (project => undef, copyright => undef, license => undef);
    my %options  = (%defaults, @_);
    # program identification
    print $name;
    print " ($options{'project'})" if $options{'project'};
    print " ", $version, "\n";
    # copyright notice
    $options{'copyright'} = COPYRIGHT unless defined $options{'copyright'};
    print "Copyright (c) ", $options{'copyright'}, "\n" unless $options{'copyright'} eq '';
    # license information
    $options{'license'} = LICENSE unless defined $options{'license'};
    print $options{'license'}, "\n" unless $options{'license'} eq '';
}

# ----------------------------------------------------------------------------
## @brief Get absolute path of executable file.
#
# This function determines the absolute file path of an executable. If no
# arguments are given, the absolute path of this executable is returned.
# Otherwise, the named command is searched in the system PATH and its
# absolute path returned if found. If the executable is not found, @c undef
# is returned.
#
# @param [in] name Name of command or @c undef.
#
# @returns Absolute path of executable or @c undef if not found.
#          If @p name is @c undef, the path of this executable is returned.
sub get_executable_path
{
    my $path = undef;
    if (@_ == 0) { $path = realpath($0); }
    else         { $path = which($_[0]); }
    return $path;
}

# ----------------------------------------------------------------------------
## @brief Get name of executable file.
#
# @param [in] name Name of command or @c undef.
#
# @returns Name of executable file or @c undef if not found.
#          If @p name is @c undef, the path of this executable is returned.
sub get_executable_name
{
    my $path = get_executable_path(@_);
    defined $path or return undef;
    return basename($path);
}

# ----------------------------------------------------------------------------
## @brief Get directory of executable file.
#
# @param [in] name Name of command or @c undef.
#
# @returns Absolute path of directory containing executable or @c undef if not found.
#          If @p name is @c undef, the directory of this executable is returned.
sub get_executable_directory
{
    my $path = get_executable_path(@_);
    defined $path or return undef;
    return dirname($path);
}

# ============================================================================
# command execution
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Convert list to double quoted string.
#
# @param [in] args Array of arguments.
#
# @returns Double quoted string, i.e., string where array elements are separated
#          by a space character and surrounded by double quotes if necessary.
#          Double quotes within an array element are escaped with a backslash.
sub to_quoted_string
{
    my $str = '';
    if (ref($_[0]) eq 'ARRAY') {
        my $args = $_[0];
        for my $arg (@$_[0]) {
            $arg =~ s/"/\\"/g;                          # escape double quotes
            $arg = '"' . $arg . '"' if $arg =~ m/'|\s/; # quote if necessary
            $str .= ' ' if $str != '';
            $str .= $arg;
        }
    } else {
        $str = $_[0];
        $str =~ s/"/\\"/g;                          # escape double quotes
        $str = '"' . $str . '"' if $str =~ m/'|\s/; # quote if necessary
    }
    return $str;
}

# ----------------------------------------------------------------------------
## @brief Split quoted string.
#
# @param [in] str Quoted string.
sub split_quoted_string
{
    my $str  = shift;
    my $max  = shift;
    my $arg  = '';
    my @args = ();
    LOOP: {
        while ($str =~ /[ ]*('([^']|\\\')*[^\\]'|\"([^\"]|\\\")*[^\\]\"|[^ ]+)(.*)/) {
            $arg = $1;                           # matched element including quotes
            $str = $4;                           # continue with residual command-line
            $arg =~ s/^['\"]|(^|[^\\])['\"]$//g; # remove quotes
            $arg =~ s/[\\]('|\")/$1/g;           # unescape quotes
            push @args, $arg;                    # add to resulting array
            last LOOP if defined $max and scalar(@args) >= $max;
        }
    }
    if (defined $max) {
        if ($max eq 1) { return ($args[0], $str); }
        else           { return (@args, $str); }
    } else             { return @args; }
}

# ----------------------------------------------------------------------------
## @brief Split/Convert quoted string or array of arguments into command name
#         and quoted string of command arguments.
#
# @param [in] args Array of command name and arguments or quoted string.
#
# @returns Tuple of command name and quoted string of command arguments.
sub split_command_and_arguments
{
    my $args      = $_[0];
    my $command   = '';
    my $arguments = '';
    if (ref($args) eq 'ARRAY') {
        $command   = shift @$args or die "execute_process(): No command specified for execution";
        $arguments = to_quoted_string($args);
    } elsif (ref($args) eq '') {
        ($command, $arguments) = split_quoted_string($args, 1);
    } else {
        die "Argument must be either array reference or string";
    }
    return ($command, $arguments);
}

# ----------------------------------------------------------------------------
## @brief Execute command as subprocess.
#
# This command takes either an array reference or a string as first argument.
# All other arguments are keyword arguments using hash notation.
#
# Example:
# @code
# # only returns exit code of command but does not output anything
# my $status = execute_process(['ls', '/'], quiet => 1);
# # returns exit code of command and returns command output w/o printing to stdout
# my ($status, $stdout) = execute_process('ls /', quiet => 1, stdout => 1);
# @endcode
#
# @param [in] args       Command with arguments given either as single quoted
#                        string or array of command name and arguments.
# @param [in] quiet      Turns off output of @c stdout of child process to
#                        @c stdout of parent process.
# @param [in] stdout     Whether to return the command output.
# @param [in] allow_fail If true, does not raise an exception if return
#                        value is non-zero. Otherwise, an exception is
#                        raised by this function using die.
# @param [in] verbose    Verbosity of output messages.
#                        Does not affect verbosity of executed command.
# @param [in] simulate   Whether to simulate command execution only.
#
# @return A tuple consisting of exit code of executed command and command
#         output if both @p stdout and @p allow_fail are true.
#         If only @p stdout is true, only the command output is returned.
#         If only @p allow_fail is true, only the exit code is returned.
#         Otherwise, this function always returns 0.
#
# @throws die If command execution failed. This exception is not raised
#             if the command executed with non-zero exit code but
#             @p allow_fail is true.
sub execute_process
{
    # arguments
    my $args = shift or die "execute_process(): No command specified for execution";
    if ($args =~ m/^(quiet|stdout|allow_fail|verbose|simulate)$/) {
        warn "First argument matches option name. Missing args argument?";
    }
    my %defaults = (quiet => 0, stdout => 0, allow_fail => 0, verbose => 0, simulate => 0);
    my %options  = (%defaults, @_);
    # get absolute path of executable
    my ($command, $arguments) = split_command_and_arguments($args);
    my $exec_path = get_executable_path($command);
    defined $exec_path or die "$command: Command not found";
    $exec_path = '"' . $exec_path . '"' if $exec_path =~ m/'|\s/; # quote if necessary
    $args = $exec_path . $arguments;
    # some verbose output
    if ($options{'verbose'} gt 0) {
        print "\$ ", $args;
        $options{'simulate'} and print " (simulated)";
        print "\n";
    }
    # execute command
    my $status = 0;
    my $output = '';
    if (not $options{'simulate'}) {
        open CMD, "$args |" or die "$command: Failed to open subprocess";
        my $ofh = select STDOUT;
        $|++;
        while (<CMD>) {
            print $_ unless $options{'quiet'};
            $output .= $_ if $options{'stdout'};
        }
        $|--;
        select $ofh;
        close CMD;
        $status = $?;
    }
    # if command failed, throw an exception
    if ($status != 0 and not $options{'allow_fail'}) {
        die "Command $args failed";
    }
    # return
    if    ($options{'stdout'} and $options{'allow_fail'}) { return ($status, $output); }
    elsif ($options{'stdout'})                            { return $output; }
    else                                                  { return $status; }
}


## @}
# end of Doxygen group


1; # indicate success of module loading
