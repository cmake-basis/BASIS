#============================================================= -*-Perl-*-
#
# Pod::POM::View
#
# DESCRIPTION
#   Visitor class for creating a view of all or part of a Pod Object 
#   Model.
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
#   $Id: View.pm 32 2009-03-17 21:08:25Z ford $
#
#========================================================================

package BASIS::Pod::POM::View;

require 5.004;

use strict;
use vars qw( $VERSION $DEBUG $ERROR $AUTOLOAD $INSTANCE );

$VERSION = sprintf("%d.%02d", q$Revision: 1.4 $ =~ /(\d+)\.(\d+)/);
$DEBUG   = 0 unless defined $DEBUG;


#------------------------------------------------------------------------
# new($pom)
#------------------------------------------------------------------------

sub new {
    my $class = shift;
    my $args  = ref $_[0] eq 'HASH' ? shift : { @_ };
    bless { %$args }, $class;
}


sub print {
    my ($self, $item) = @_;
    return UNIVERSAL::can($item, 'present')
	? $item->present($self) : $item;
}
    

sub view {
    my ($self, $type, $node) = @_;
    return $node;
}


sub instance {
    my $self  = shift;
    my $class = ref $self || $self;

    no strict 'refs';
    my $instance = \${"$class\::_instance"};

    defined $$instance
	 ?  $$instance
	 : ($$instance = $class->new(@_));
}


sub visit {
    my ($self, $place) = @_;
    $self = $self->instance() unless ref $self;
    my $visit = $self->{ VISIT } ||= [ ];
    push(@$visit, $place);
    return $place;
}


sub leave {
    my ($self, $place) = @_;
    $self = $self->instance() unless ref $self;
    my $visit = $self->{ VISIT };
    return $self->error('empty VISIT stack') unless @$visit;
    pop(@$visit);
}


sub visiting {
    my ($self, $place) = @_;
    $self = $self->instance() unless ref $self;
    my $visit = $self->{ VISIT };
    return 0 unless $visit && @$visit;

    foreach (reverse @$visit) {
	return 1 if $_ eq $place;
    }
    return 0;
}
    

sub AUTOLOAD {
    my $self = shift;
    my $name = $AUTOLOAD;
    my $item;

    $name =~ s/.*:://;
    return if $name eq 'DESTROY';

    if ($name =~ s/^view_//) {
	return $self->view($name, @_);
    }
    elsif (! ref $self) {
	die "can't access $name in $self\n";
    }
    else {
	die "no such method for $self: $name ($AUTOLOAD)"
	    unless defined ($item = $self->{ $name });

	return wantarray ? ( ref $item eq 'ARRAY' ? @$item : $item ) : $item;
    }
}


1;

=head1 NAME

Pod::POM::View

=head1 DESCRIPTION

Visitor class for creating a view of all or part of a Pod Object Model.

=head1 METHODS

=over 4

=item C<new>

=item C<print>

=item C<view>

=item C<instance>

=item C<visit>

=item C<leave>

=item C<visiting>

=back

=head1 AUTHOR

Andy Wardley E<lt>abw@kfs.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2000, 2001 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
