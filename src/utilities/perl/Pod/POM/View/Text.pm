#============================================================= -*-Perl-*-
#
# Pod::POM::View::Text
#
# DESCRIPTION
#   Text view of a Pod Object Model.
#
# AUTHOR
#   Andy Wardley   <abw@kfs.org>
#
# COPYRIGHT
#   Copyright (C) 2000 Andy Wardley.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# REVISION
#   $Id: Text.pm 77 2009-08-20 20:44:14Z ford $
#
#========================================================================

package BASIS::Pod::POM::View::Text;

require 5.004;

use strict;
use BASIS::Pod::POM::View;
use parent qw( BASIS::Pod::POM::View );
use vars qw( $VERSION $DEBUG $ERROR $AUTOLOAD $INDENT );
use Text::Wrap;

$VERSION = sprintf("%d.%02d", q$Revision: 1.3 $ =~ /(\d+)\.(\d+)/);
$DEBUG   = 0 unless defined $DEBUG;
$INDENT  = 0;


sub new {
    my $class = shift;
    my $args  = ref $_[0] eq 'HASH' ? shift : { @_ };
    bless { 
	INDENT => 0,
	%$args,
    }, $class;
}


sub view {
    my ($self, $type, $item) = @_;

    if ($type =~ s/^seq_//) {
	return $item;
    }
    elsif (UNIVERSAL::isa($item, 'HASH')) {
	if (defined $item->{ content }) {
	    return $item->{ content }->present($self);
	}
	elsif (defined $item->{ text }) {
	    my $text = $item->{ text };
	    return ref $text ? $text->present($self) : $text;
	}
	else {
	    return '';
	}
    }
    elsif (! ref $item) {
	return $item;
    }
    else {
	return '';
    }
}


sub view_head1 {
    my ($self, $head1) = @_;
    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
    my $pad = ' ' x $$indent;
    local $Text::Wrap::unexpand = 0;
    my $title = wrap($pad, $pad, 
		     $head1->title->present($self));
    
    $$indent += 4;
    my $output = "$title\n" . $head1->content->present($self);
    $$indent -= 4;

    return $output;
}


sub view_head2 {
    my ($self, $head2) = @_;
    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
    my $pad = ' ' x $$indent;
    local $Text::Wrap::unexpand = 0;
    my $title = wrap($pad, $pad, 
		     $head2->title->present($self));

    $$indent += 4;
    my $output = "$title\n" . $head2->content->present($self);
    $$indent -= 4;

    return $output;
}


sub view_head3 {
    my ($self, $head3) = @_;
    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
    my $pad = ' ' x $$indent;
    local $Text::Wrap::unexpand = 0;
    my $title = wrap($pad, $pad, 
		     $head3->title->present($self));

    $$indent += 4;
    my $output = "$title\n" . $head3->content->present($self);
    $$indent -= 4;

    return $output;
}


sub view_head4 {
    my ($self, $head4) = @_;
    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
    my $pad = ' ' x $$indent;
    local $Text::Wrap::unexpand = 0;
    my $title = wrap($pad, $pad, 
		     $head4->title->present($self));

    $$indent += 4;
    my $output = "$title\n" . $head4->content->present($self);
    $$indent -= 4;

    return $output;
}


#------------------------------------------------------------------------
# view_over($self, $over)
#
# Present an =over block - this is a blockquote if there are no =items
# within the block.
#------------------------------------------------------------------------

sub view_over {
    my ($self, $over) = @_;

    if (@{$over->item}) {
	return $over->content->present($self);
    }
    else {
	my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
	my $pad = ' ' x $$indent;
	$$indent += 4;
	my $content = $over->content->present($self);
	$$indent -= 4;
    
	return $content;
    }
}

sub view_item {
    my ($self, $item) = @_;
    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
    my $pad = ' ' x $$indent;
    local $Text::Wrap::unexpand = 0;
    my $title = wrap($pad . '* ', $pad . '  ', 
		     $item->title->present($self));

    $$indent += 2;
    my $content = $item->content->present($self);
    $$indent -= 2;
    
    return "$title\n\n$content";
}


sub view_for {
    my ($self, $for) = @_;
    return '' unless $for->format() =~ /\btext\b/;
    return $for->text()
	. "\n\n";
}

    
sub view_begin {
    my ($self, $begin) = @_;
    return '' unless $begin->format() =~ /\btext\b/;
    return $begin->content->present($self);
}

    
sub view_textblock {
    my ($self, $text) = @_;
    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
    $text =~ s/\s+/ /mg;

    $$indent ||= 0;
    my $pad = ' ' x $$indent;
    local $Text::Wrap::unexpand = 0;
    return wrap($pad, $pad, $text) . "\n\n";
}


sub view_verbatim {
    my ($self, $text) = @_;
    my $indent = ref $self ? \$self->{ INDENT } : \$INDENT;
    my $pad = ' ' x $$indent;
    $text =~ s/^/$pad/mg;
    return "$text\n\n";
}


sub view_seq_bold {
    my ($self, $text) = @_;
    return "*$text*";
}


sub view_seq_italic {
    my ($self, $text) = @_;
    return "_${text}_";
}


sub view_seq_code {
    my ($self, $text) = @_;
    return "'$text'";
}


sub view_seq_file {
    my ($self, $text) = @_;
    return "_${text}_";
}

my $entities = {
    gt   => '>',
    lt   => '<',
    amp  => '&',
    quot => '"',
};


sub view_seq_entity {
    my ($self, $entity) = @_;
    return $entities->{ $entity } || $entity;
}

sub view_seq_index {
    return '';
}

sub view_seq_link {
    my ($self, $link) = @_;
    if ($link =~ s/^.*?\|//) {
	return $link;
    }
    else {
	return "the $link manpage";
    }
}
	
    

1;

=head1 NAME

Pod::POM::View::Text

=head1 DESCRIPTION

Text view of a Pod Object Model.

=head1 METHODS

=over 4

=item C<view($self, $type, $item)>

=item C<view_pod($self, $pod)>

=item C<view_head1($self, $head1)>

=item C<view_head2($self, $head2)>

=item C<view_head3($self, $head3)>

=item C<view_head4($self, $head4)>

=item C<view_over($self, $over)>

=item C<view_item($self, $item)>

=item C<view_for($self, $for)>

=item C<view_begin($self, $begin)>

=item C<view_textblock($self, $textblock)>

=item C<view_verbatim($self, $verbatim)>

=item C<view_meta($self, $meta)>

=item C<view_seq_bold($self, $text)>

Returns the text of a C<BE<lt>E<gt>> sequence in 'bold' (i.e. surrounded by asterisks, like *this*).

=item C<view_seq_italic($self, $text)>

Returns the text of a C<IE<lt>E<gt>> sequence in 'italics' (i.e. surrounded by underscores, like _this_).

=item C<view_seq_code($self, $text)>

=item C<view_seq_file($self, $text)>

=item C<view_seq_entity($self, $text)>

=item C<view_seq_index($self, $text)>

Returns an empty string.  Index sequences are suppressed in text view.

=item C<view_seq_link($self, $text)>

=back

=head1 AUTHOR

Andy Wardley E<lt>abw@kfs.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2000 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
