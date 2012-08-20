#============================================================= -*-Perl-*-
#
# Pod::POM::Test
#
# DESCRIPTION
#   Module implementing some useful subroutines for testing.
#
# AUTHOR
#   Andy Wardley   <abw@kfs.org>
#
# COPYRIGHT
#   Copyright (C) 2000, 2001 Andy Wardley.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# REVISION
#   $Id: Test.pm 14 2009-03-13 08:19:40Z ford $
#
#========================================================================

package BASIS::Pod::POM::Test;

require 5.004;

use strict;
use BASIS::Pod::POM;
use base qw( Exporter );
use vars qw( $VERSION @EXPORT );

$VERSION = sprintf("%d.%02d", q$Revision: 1.1.1.1 $ =~ /(\d+)\.(\d+)/);
@EXPORT  = qw( ntests ok match assert );

my $ok_count;

sub ntests {
    my $ntests = shift;
    $ok_count  = 1;
    print "1..$ntests\n";
}

sub ok {
    my ($ok, $msg) = @_;
    if ($ok) {
	print "ok ", $ok_count++, "\n";
    }
    else {
	print "FAILED $ok_count: $msg\n" if defined $msg;
	print "not ok ", $ok_count++, "\n";
    }
}

sub assert {
    my ($ok, $err) = @_;
    return ok(1) if $ok;

    # failed
    my ($pkg, $file, $line) = caller();
    $err ||= "assert failed";
    $err .= " at $file line $line\n";
    ok(0);
    die $err;
}


sub match {
    my ($result, $expect) = @_;

    # force stringification of $result to avoid 'no eq method' overload errors
    $result = "$result" if ref $result;	   

    if ($result eq $expect) {
	ok(1);
    }
    else {
	print "FAILED $ok_count:\n  expect: [$expect]\n  result: [$result]\n";
	ok(0);
    }
}


1;
