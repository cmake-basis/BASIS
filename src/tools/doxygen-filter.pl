#! /usr/bin/env perl

## @file  doxygen-filter.pl
#  @brief Doxygen input filter.
#
# This Perl script is used as pre-processor for input files to Doxygen.
# Depending on the file extension, it invokes the corresponding Doxygen
# filters which transform the input file into something that Doxygen
# understands.
#
# Based on the Doxygen Filter from Bart Schuller and Aeby Thomas.
# @sa http://www.bigsister.ch/doxygenfilter/
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeHelpers

# =======================================================================
# Doxygen Pre-Processor for Perl
# Copyright (C) 2002  Bart Schuller
# Copyright (C) 2006  Phinex Informatik AG
# Copyright (C) 2011  University of Pennsylvania
# All Rights Reserved
# 
# Doxygen Filter is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
# Larry Wall's 'Artistic License' for perl can be found in
# http://www.perl.com/pub/a/language/misc/Artistic.html
# 
# =======================================================================
# 
# Author: Aeby Thomas, Phinex Informatik AG,
# 	  Based on DoxygenFilter from Bart Schuller
# E-Mail: tom.aeby@phinex.ch
# 
# Phinex Informatik AG
# Thomas Aeby
# Kirchweg 52
# 1735 Giffers
# 
# =======================================================================


use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin";
use DoxyGen::PerlFilter;
use DoxyGen::SQLFilter;
use DoxyGen::VBFilter;

use Cwd qw(realpath);
use File::Basename;

my $exec_dir = dirname (realpath ($0));

use Getopt::Long;
$Getopt::Long::ignorecase = 0;  
my $verbose;
my $help;
unless( GetOptions( "verbose" => \$verbose, "v" => \$verbose,
	  "help" => \$help, "h" => \$help ) && $ARGV[0] ) {
    $help = 1;
}

if( $help ) {
    my $prog = $0;
    $prog =~ s#.*/##;
    print STDERR <<END;
Usage: $prog [-v] filename

Pre-processes Perl code in file <filename> and outputs
something doxygen does understand.

END
    exit 1;
}

open( FILE, "<$ARGV[0]" );
my $filehead = "";
for( my $line=0; ($line<3) && ($_ = <FILE>); $line++ ) {
    $filehead .= $_;
}
close FILE;

my $ext = "";
if( $ARGV[0] =~ /\.([a-z]+)$/i ) {
    $ext = lc($1);
}

my $filter;
if( $ext eq "sql" ) {
    print STDERR "treating file as SQL\n" if( $verbose );
    $filter = DoxyGen::SQLFilter->new(\*STDOUT);
} elsif( grep( $_ eq $ext, "pl", "pm", "perl" )
	|| $filehead =~ /^#!\s*(\/usr\/bin\/perl|\/bin\/perl|\/usr\/bin\/env\s+perl)/ ) {
    print STDERR "treating file as Perl\n" if( $verbose );
    $filter = DoxyGen::PerlFilter->new(\*STDOUT);
} elsif( $ext eq "js" ) {
    print STDERR "treating file as JavaScript\n" if( $verbose );
    exec("$exec_dir/doxygen-javascript-filter.pl", @ARGV) or exec( "js2doxy", @ARGV ) or exec( "js2doxypl", @ARGV )
    or print STDERR "js2doxy not installed? - see http://jsunit.berlios.de/internal.html\n";
} elsif( $ext eq "py" || $filehead =~ /^#!\s*(\/usr\/bin\/python|\/bin\/python|\/usr\/bin\/env\s+python)/ ) {
    print STDERR "treating file as Python\n" if( $verbose );
    exec("$exec_dir/doxygen-python-filter.py", @ARGV)
    or print STDERR "doxygen-bash-filter.py not installed?\n";
} elsif( $ext eq "sh" || $filehead =~ /^#!\s*(\/usr\/bin\/bash|\/bin\/bash|\/usr\/bin\/env\s+bash)/ ) {
    print STDERR "treating file as BASH\n" if( $verbose );
    exec("$exec_dir/doxygen-bash-filter.py", @ARGV)
    or print STDERR "doxygen-bash-filter.py not installed?\n";
} elsif( $ext eq "cmake" or $ext eq "ctest" ) {
    print STDERR "treating file as CMake\n" if( $verbose );
    exec("$exec_dir/doxygen-cmake-filter.py", @ARGV)
    or print STDERR "doxygen-cmake-filter.py not installed?\n";
} elsif( $ext eq "pas" ) {
    print STDERR "treating file as Pascal\n" if( $verbose );
    exec( "pas2dox", @ARGV )
    or print STDERR "pas2dox not installed? - see http://sourceforge.net/projects/pas2dox/\n";
} elsif( grep( $ext =~ /^$_$/i, "vb", "vbs" ) ) {
    print STDERR "treating file as Visual Basic\n" if( $verbose );
    $filter = DoxyGen::VBFilter->new(\*STDOUT);
}

if( $filter ) {
    $filter->filter($ARGV[0]);
}
else {
    print STDERR "passing file through\n" if( $verbose );
    print <>;
}
