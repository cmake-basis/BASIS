#! /usr/bin/env perl

##############################################################################
# @file  doxyfilter.pl
# @brief Doxygen filter for CMake, Python, Perl, Bash, and MATLAB.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

use File::Basename qw(fileparse);
use BASIS::Basis   qw(exename execute istarget);

use BASIS::DoxyFilter::Bash;
use BASIS::DoxyFilter::CMake;


if (@ARGV != 1) {
    print STDERR "Usage: " . exename() . " <file>\n";
    exit 1;
}

my $filename = $ARGV[0];
my $lang     = undef;
my $filter   = undef;
my $status   = -1;

# get file name extension
my ($dir, $base, $ext) = fileparse($filename, '\..*');
# select filter according to file extension
if    ($ext =~ /\.(pl|pm)/)       { $lang = 'perl';   }
elsif ($ext eq '.py')             { $lang = 'python'; }
elsif ($ext eq '.sh')             { $lang = 'bash';   }
elsif ($ext =~ /\.(cmake|ctest)/) { $lang = 'cmake';  }
elsif ($ext eq '.m')              { $lang = 'matlab'; }
# otherwise, consider shebang directive if given
if (not $lang) {
    open FILE, $filename or die "Failed to open file \"$filename\"!";
    $lang = $2 if <FILE> =~ /^#!\s*(\/usr\/bin\/|\/bin\/|\/usr\/bin\/env\s+)(python|perl|bash)/;
    close FILE;
}
# create filter for source language
if ($lang) {
    if    ($lang eq 'bash')  { $filter = new BASIS::DoxyFilter::Bash;  }
    elsif ($lang eq 'cmake') { $filter = new BASIS::DoxyFilter::CMake; }
}
# execute filter
if (defined $filter) {
    $filter->process($filename);
    print $filter->output();
    $status = 0;
} elsif ($lang and istarget("doxyfilter-$lang")) {
    my @cmd = ("doxyfilter-$lang");
    push @cmd, '-f' if $lang eq 'python';
    push @cmd, $filename;
    $status = execute(\@cmd, allow_fail=>1);
}
# otherwise, just pass input through unfiltered
if ($status ne 0) {
    open FILE, $filename;
    print $_ while <FILE>;
    close FILE;
}
