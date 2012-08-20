#============================================================= -*-Perl-*-
#
# Pod::POM::Node::Text
#
# DESCRIPTION
#   Module implementing specific nodes in a Pod::POM, subclassed from
#   Pod::POM::Node.
#
# AUTHOR
#   Andy Wardley   <abw@kfs.org>
#   Andrew Ford    <a.ford@ford-mason.co.uk>
#
# COPYRIGHT
#   Copyright (C) 2000, 2001 Andy Wardley.  All Rights Reserved.
#   Copyright (C) 2009 Andrew Ford.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# REVISION
#   $Id: Text.pm 76 2009-08-20 20:41:33Z ford $
#
#========================================================================

package BASIS::Pod::POM::Node::Text;

use strict;

use BASIS::Pod::POM::Constants qw( :all );
use parent qw( BASIS::Pod::POM::Node );
use vars qw( %ATTRIBS $ERROR );

%ATTRIBS = ( text => '' );

sub new {
    my $class = shift;
    my $pom   = shift;
    my $text  = shift;
    $text = $pom->parse_sequence($text)
        || return $class->error($pom->error())
            if length $text && ! $pom->{in_begin};
    return $class->SUPER::new($pom, $text);
}

sub add {
    return IGNORE;
}

sub present {
    my ($self, $view) = @_;
    my $text = $self->{ text };
    $view ||= $BASIS::Pod::POM::DEFAULT_VIEW;

    $text = $text->present($view) 
	if ref $text;

    return $view->view_textblock($text);
}

1;

=head1 NAME

Pod::POM::Node::Text -

=head1 SYNOPSIS

    use Pod::POM::Nodes;

=head1 DESCRIPTION

This module implements a specialization of the node class to represent text elements.

=head1 AUTHOR

Andrew Ford E<lt>a.ford@ford-mason.co.ukE<gt>

Andy Wardley E<lt>abw@kfs.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2000, 2001 Andy Wardley.  All Rights Reserved.

Copyright (C) 2009 Andrew Ford.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

Consult L<Pod::POM::Node> for a discussion of nodes.
