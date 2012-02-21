#! /usr/bin/env perl

##############################################################################
# @file  runtest.pl
# @brief Helper script for execution of test command.
#
# Copyright (c) University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

use Cwd        qw(getcwd);
use File::Path qw(rmtree);
use Sys::Hostname;


# ============================================================================
# auxiliary functions
# ============================================================================

# ----------------------------------------------------------------------------
## Remove all files and directories from the current working directory.
sub clean
{
    my $root = shift;
    eval {
        opendir my $dh, $root or die "Failed to open directory $root: $!";
        my @files = grep { !/^\.\.?$/ } readdir $dh;
        closedir $dh;
        foreach my $f (@files) {
            if (-d $f) {
                rmtree $f;
            } else {
                unlink $f;
            }
        }
    };
    print STDERR "Failed to clean directory $root: $@\n" if $@;
}

# ----------------------------------------------------------------------------
## Output special information for inclusion in submission to CDash.
sub print_dart_measurements
{
    print "<DartMeasurement name=\"Host Name\" type=\"string\">";
    print hostname;
    print "</DartMeasurement>\n";
    print "<DartMeasurement name=\"Working Directory\" type=\"string\">";
    print getcwd;
    print "</DartMeasurement>\n";
}

# ============================================================================
# main
# ============================================================================

my $clean_before = 0;
my $clean_after  = 0;
my $dart         = 1;
my @cmd          = ();

while (@ARGV) {
    my $arg = shift;
    if ($arg eq '--clean-before') {
        $clean_before = 1;
    } elsif ($arg eq '--clean-after') {
        $clean_after = 1;
    } elsif ($arg eq '--nodart') {
        $dart = 0;
    } elsif ($arg eq '--') {
        break;
    } else {
        push @cmd, $arg;
    }
}
push @cmd, @ARGV;

if (@cmd == 0) {
    print STDERR "Missing test command!\n";
    exit 1;
}

my $cwd = getcwd;
print_dart_measurements if $dart;
clean $cwd if $clean_before;
my $retval = system('"' . join('" "', @cmd) . '"');
clean $cwd if $clean_after;

exit $retval;
