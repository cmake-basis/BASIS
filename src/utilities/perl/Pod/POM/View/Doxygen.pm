#** @file Doxygen.pm
# @verbatim
#####################################################################
# This program is not guaranteed to work at all, and by using this  #
# program you release the author of any and all liability.          #
#                                                                   #
# You may use this code as long as you are in compliance with the   #
# license (see the LICENSE file) and this notice, disclaimer and    #
# comment box remain intact and unchanged.                          #
#                                                                   #
# Package:     Doxygen::Filter::Perl                                #
# Class:       POD                                                  #
# Description: Methods for prefiltering Perl code for Doxygen       #
#                                                                   #
# Written by:  Bret Jordan (jordan at open1x littledot org)         #
# Created:     2011-10-13                                           #
##################################################################### 
# @endverbatim
#
# @copy 2011, Bret Jordan (jordan2175@gmail.com, jordan@open1x.org)
# $Id: POD.pm 73 2011-12-22 23:07:14Z jordan2175 $
#
# @note Modified on 6/15/2012 by Andreas Schuh to remove dependency
#       on Log::Log4perl module.
#
# @note Modified on 6/20/2012 by Andreas Schuh to make it part of
#       Pod::POM::View package, which in turn has been included
#       as part of BASIS. The original Perl module was
#       Doxygen::Filter::Perl::POD which is part of the
#       Doxygen::Filter::Perl package.
#*
package BASIS::Pod::POM::View::Doxygen;

use 5.8.8;
use strict;
use warnings;
use parent qw(BASIS::Pod::POM::View::HTML);

our $VERSION = '1.00';
$VERSION = eval $VERSION;


sub view_pod 
{
    my ($self, $pod) = @_;
    return $pod->content->present($self);
}

sub view_head1 
{
    my ($self, $head1) = @_;
    my $title = $head1->title->present($self);
    my $name = $title;
    $name =~ s/\s/_/g;
    return "\n\@section $name $title\n" . $head1->content->present($self);
}

sub view_head2 
{
    my ($self, $head2) = @_;
    my $title = $head2->title->present($self);
    my $name = $title;
    $name =~ s/\s/_/g;    
    return "\n\@subsection $name $title\n" . $head2->content->present($self);
}

sub view_seq_code 
{
    my ($self, $text) = @_;
    return "\n\@code\n$text\n\@endcode\n";
}




=head1 NAME

Pod::POM::View::Doxygen - A perl code pre-filter for Doxygen

=head1 DESCRIPTION

The Pod::POM::View::Doxygen is a helper module for use with Doxygen filter
implementations which process Perl source files in order to generate C-like
output which is understood by Doxygen. This class inherits from Pod::POM::View::HTML
and overloads some of its methods and converts their output to be in a Doxygen
style that Doxygen::Filter::Perl and other filter implementations can use.

=head1 AUTHOR

Bret Jordan <jordan at open1x littledot org> or <jordan2175 at gmail littledot com>

=head1 LICENSE

Pod::POM::View::Doxygen (originally Doxygen::Filter::Perl::POD) is dual licensed
GPLv3 and Commerical. See the LICENSE file for more details.

=cut

return 1;
