#============================================================= -*-Perl-*-
#
# Pod::POM::Node::Head3
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
#   $Id: Head3.pm 76 2009-08-20 20:41:33Z ford $
#
#========================================================================

package BASIS::Pod::POM::Node::Head3;

use strict;

use parent qw( BASIS::Pod::POM::Node );
use vars qw( %ATTRIBS @ACCEPT $ERROR );

%ATTRIBS =   ( title => undef );
@ACCEPT  = qw( head4 over begin for text verbatim code );

sub new {
    my ($class, $pom, $title) = @_;
    $title = $pom->parse_sequence($title)
	|| return $class->error($pom->error())
	    if length $title;
    return $class->SUPER::new($pom, $title);
}

1;

=head1 NAME

Pod::POM::Node::Head3 -

=head1 SYNOPSIS

    use Pod::POM::Nodes;

=head1 DESCRIPTION

This module implements a specialization of the node class to represent C<=head3> elements.

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
