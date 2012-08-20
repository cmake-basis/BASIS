#============================================================= -*-Perl-*-
#
# Pod::POM::Node::Sequence
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
#   $Id: Sequence.pm 76 2009-08-20 20:41:33Z ford $
#
#========================================================================

package BASIS::Pod::POM::Node::Sequence;

use strict;

use BASIS::Pod::POM::Constants qw( :all );
use parent qw( BASIS::Pod::POM::Node );
use vars qw( %NAME );

%NAME = (
    C => 'code',
    B => 'bold',
    I => 'italic',
    L => 'link',
    S => 'space',
    F => 'file',
    X => 'index',
    Z => 'zero',
    E => 'entity',
);
    
sub new {
    my ($class, $self) = @_;
    local $" = '] [';
    return bless \$self, $class;
}

sub add {
    return IGNORE;
}

sub present {
    my ($self, $view) = @_;
    my ($cmd, $method, $result);
    $view ||= $BASIS::Pod::POM::DEFAULT_VIEW;

    $self = $$self;
    return $self unless ref $self eq 'ARRAY';

    my $text = join('', 
                    map { ref $_ ? $_->present($view) 
                                 : $view->view_seq_text($_) } 
                    @{ $self->[CONTENT] });
    
    if ($cmd = $self->[CMD]) {
        my $method = $NAME{ $cmd } || $cmd;
        $method = "view_seq_$method";
        return $view->$method($text);
    }
    else {
        return $text;
    }
}

1;

=head1 NAME

Pod::POM::Node::Sequence -

=head1 SYNOPSIS

    use Pod::POM::Nodes;

=head1 DESCRIPTION

This module implements a specialization of the node class to represent sequence elements.

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
