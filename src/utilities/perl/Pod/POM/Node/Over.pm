#============================================================= -*-Perl-*-
#
# Pod::POM::Node::Over
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
#   $Id: Over.pm 76 2009-08-20 20:41:33Z ford $
#
#========================================================================

package BASIS::Pod::POM::Node::Over;

use strict;

use parent qw( BASIS::Pod::POM::Node );
use vars qw( %ATTRIBS @ACCEPT $EXPECT $ERROR );

%ATTRIBS =   ( indent => 4 );
@ACCEPT  = qw( over item begin for text verbatim code );
$EXPECT  = 'back';

sub list_type {
    my $self = shift;
    my ($first, @rest) = $self->content;

    my $first_type = $first->type;
    return;
}


1;

=head1 NAME

Pod::POM::Node::Over - POM '=over' node class

=head1 SYNOPSIS

    use Pod::POM::Nodes;

=head1 DESCRIPTION

This class implements '=over' Pod nodes.  As described by the L<perlpodspec> man page =over/=back regions are
used for various kinds of list-like structures (including blockquote paragraphs).

  =item 1.

ordered list

  =item *

  text paragraph

unordered list

  =item text

  text paragraph

definition list



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
