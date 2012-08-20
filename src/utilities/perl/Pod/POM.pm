#============================================================= -*-Perl-*-
#
# Pod::POM
#
# DESCRIPTION
#   Parses POD from a file or text string and builds a tree structure,
#   hereafter known as the POD Object Model (POM).
#
# AUTHOR
#   Andy Wardley   <abw@wardley.org>
#
#   Andrew Ford    <A.Ford@ford-mason.co.uk> (co-maintainer as of 03/2009)
#
# COPYRIGHT
#   Copyright (C) 2000-2009 Andy Wardley.  All Rights Reserved.
#   Copyright (C) 2009 Andrew Ford.  All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# REVISION
#   $Id: POM.pm 88 2010-04-02 13:37:41Z ford $
#
#========================================================================

package BASIS::Pod::POM;

require 5.004;

use strict;
use BASIS::Pod::POM::Constants qw( :all );
use BASIS::Pod::POM::Nodes;
use BASIS::Pod::POM::View::Pod;

use vars qw( $VERSION $DEBUG $ERROR $ROOT $TEXTSEQ $DEFAULT_VIEW );
use base qw( Exporter );

$VERSION = '0.27';
$DEBUG   = 0 unless defined $DEBUG;
$ROOT    = 'BASIS::Pod::POM::Node::Pod';               # root node class
$TEXTSEQ = 'BASIS::Pod::POM::Node::Sequence';          # text sequence class
$DEFAULT_VIEW = 'BASIS::Pod::POM::View::Pod';          # default view class


#------------------------------------------------------------------------
# allow 'meta' to be specified as a load option to activate =meta tags
#------------------------------------------------------------------------

use vars qw( @EXPORT_FAIL @EXPORT_OK $ALLOW_META );
@EXPORT_OK   = qw( meta );
@EXPORT_FAIL = qw( meta );
$ALLOW_META  = 0;

sub export_fail {
    my $class = shift;
    my $meta  = shift;
    return ($meta, @_) unless $meta eq 'meta';
    $ALLOW_META++;
    return @_;
}



#------------------------------------------------------------------------
# new(\%options)
#------------------------------------------------------------------------

sub new {
    my $class  = shift;
    my $config = ref $_[0] eq 'HASH' ? shift : { @_ };

    bless {
	CODE     => $config->{ code } || 0,
	WARN     => $config->{ warn } || 0,
	META     => $config->{ meta } || $ALLOW_META,
	WARNINGS => [ ],
	FILENAME => '',
	ERROR    => '',
    }, $class;
}


#------------------------------------------------------------------------
# parse($text_or_file)
#
# General purpose parse method which attempts to Do The Right Thing in
# calling parse_file() or parse_text() according to the argument
# passed.  A hash reference can be specified that contains a 'text'
# or 'file' key and corresponding value.  Otherwise, the argument can
# be a reference to an input handle which is passed off to parse_file().
# If the argument is a text string that contains '=' at the start of 
# any line then it is treated as Pod text and passed to parse_text(),
# otherwise it is assumed to be a filename and passed to parse_file().
#------------------------------------------------------------------------

sub parse {
    my ($self, $input) = @_;
    my $result;

    if (ref $input eq 'HASH') {
	if ($input = $input->{ text }) {
	    $result = $self->parse_text($input, $input->{ name });
	}
	elsif ($input = $input->{ file }) {
	    $result = $self->parse_file($input);
	}
	else {
	    $result = $self->error("no 'text' or 'file' specified");
	}
    }
    elsif (ref $input || $input !~ /^=/m) {	# doesn't look like POD text
	$result = $self->parse_file($input);
    }
    else {					# looks like POD text
	$result = $self->parse_text($input);
    }

    return $result;
}


#------------------------------------------------------------------------
# parse_file($filename_or_handle)
#
# Reads the content of a Pod file specified by name or file handle, and
# passes it to parse_text() for parsing.
#------------------------------------------------------------------------

sub parse_file {
    my ($self, $file) = @_;
    my ($text, $name);

    if (ref $file) {		# assume open filehandle
	local $/ = undef;
	$name = '<filehandle>';
	$text = <$file>;
    }
    else {			# a file which must be opened
	local *FP;
	local $/ = undef;
	$name = ( $file eq '-' ? '<standard input>' : $file );
	open(FP, $file) || return $self->error("$file: $!");
	$text = <FP>;
	close(FP);
    }

    $self->parse_text($text, $name);
}


#------------------------------------------------------------------------
# parse_text($text, $name)
#
# Main parser method.  Scans the input text for Pod sections and splits
# them into paragraphs.  Builds a tree of Pod::POM::Node::* objects
# to represent the Pod document in object model form.
#------------------------------------------------------------------------

sub parse_text {
    my ($self, $text, $name) = @_;
    my ($para, $paralen, $gap, $type, $line, $inpod, $code, $result, $verbatim);
    my $warn = $self->{ WARNINGS } = [ ];

    my @stack = ( );
    my $item = $ROOT->new($self);
    return $self->error($ROOT->error())
	unless defined $item;
    push(@stack, $item);

    $name = '<input text>' unless defined $name;
    $self->{ FILENAME } = $name;

    $code   =  $self->{ CODE };
    $line   = \$self->{ LINE };
    $$line  = 1;
    $inpod  = 0;

    my @encchunks = split /^(=encoding.*)/m, $text;
    $text = shift @encchunks;
    while (@encchunks) {
        my($encline,$chunk) = splice @encchunks, 0, 2;
        require Encode;
        my($encoding) = $encline =~ /^=encoding\s+(\S+)/;
        Encode::from_to($chunk, $encoding, "utf8");
        Encode::_utf8_on($chunk);
        # $text .= "xxx$encline";
        $text .= $chunk;
    }

# patch from JJ    
#    while ($text =~ /(?:(.*?)(\n{2,}))|(.+$)/sg) {
    while ($text =~ /(?:(.*?)((?:\s*\n){2,}))|(.+$)/sg) {
	($para, $gap) = defined $1 ? ($1, $2) : ($3, '');

	if ($para =~ s/^==?(\w+)\s*//) {
	    $type = $1;
	    # switch on for =pod or any other =cmd, switch off for =cut
	    if    ($type eq 'pod') { $inpod = 1; next }
	    elsif ($type eq 'cut') { $inpod = 0; next }
	    else                   { $inpod = 1 };

	    if ($type eq 'meta') {
		$self->{ META }
		    ? $stack[0]->metadata(split(/\s+/, $para, 2))
		    : $self->warning("metadata not allowed", $name, $$line);
		next;
	    }
	}
	elsif (! $inpod) {
	    next unless $code;
	    $type  = 'code';
	    $para .= $gap;
	    $gap   = '';
	}
	elsif ($para =~ /^\s+/) {
            $verbatim .= $para;
            $verbatim .= $gap;
            next;
	}
	else {
	    $type = 'text';
	    chomp($para);	    # catches last line in file
	}

        if ($verbatim) {
    	    while(@stack) {
                $verbatim =~ s/\s+$//s;
       	        $result = $stack[-1]->add($self, 'verbatim', $verbatim);
            
	        if (! defined $result) {
                    $self->warning($stack[-1]->error(), $name, $$line);
                    undef $verbatim;
		    last;
	        }
	        elsif (ref $result) {
                    push(@stack, $result);
                    undef $verbatim;
		    last;
	        }
	        elsif ($result == REDUCE) {
                    pop @stack;
                    undef $verbatim;
		    last;
	        }
	        elsif ($result == REJECT) {
                    $self->warning($stack[-1]->error(), $name, $$line);
		    pop @stack;
	        }
	        elsif (@stack == 1) {
                    $self->warning("unexpected $type", $name, $$line);
                    undef $verbatim;
		    last;
	        }
	        else {
                    pop @stack;
	        }
	    }
        }

	while(@stack) {
	    $result = $stack[-1]->add($self, $type, $para);
            
	    if (! defined $result) {
		$self->warning($stack[-1]->error(), $name, $$line);
		last;
	    }
	    elsif (ref $result) {
		push(@stack, $result);
		last;
	    }
	    elsif ($result == REDUCE) {
		pop @stack;
		last;
	    }
	    elsif ($result == REJECT) {
		$self->warning($stack[-1]->error(), $name, $$line);
		pop @stack;
	    }
	    elsif (@stack == 1) {
		$self->warning("unexpected $type", $name, $$line);
		last;
	    }
	    else {
		pop @stack;
	    }
	}
    }
    continue {
	$$line += ($para =~ tr/\n//);
	$$line += ($gap  =~ tr/\n//);
    }

    if ($verbatim) {
	while(@stack) {
            $verbatim =~ s/\s+$//s;
	    $result = $stack[-1]->add($self, 'verbatim', $verbatim);
            
	    if (! defined $result) {
		$self->warning($stack[-1]->error(), $name, $$line);
                undef $verbatim;
		last;
	    }
	    elsif (ref $result) {
		push(@stack, $result);
                undef $verbatim;
		last;
	    }
	    elsif ($result == REDUCE) {
		pop @stack;
                undef $verbatim;
		last;
	    }
	    elsif ($result == REJECT) {
		$self->warning($stack[-1]->error(), $name, $$line);
		pop @stack;
	    }
	    elsif (@stack == 1) {
		$self->warning("unexpected $type", $name, $$line);
                undef $verbatim;
		last;
	    }
	    else {
		pop @stack;
	    }
	}
    }

    return $stack[0];
}


#------------------------------------------------------------------------
# parse_sequence($text)
#
# Parse a text paragraph to identify internal sequences (e.g. B<foo>)
# which may be nested within each other.  Returns a simple scalar (no
# embedded sequences) or a reference to a Pod::POM::Text object.
#------------------------------------------------------------------------

sub parse_sequence {
    my ($self, $text) = @_;
    my ($cmd, $lparen, $rparen, $plain);
    my ($name, $line, $warn) = @$self{ qw( FILENAME LINE WARNINGS ) };
    my @stack;

    push(@stack, [ '', '', 'EOF', $name, $line, [ ] ] );
    
    while ($text =~ / 
                      (?: ([A-Z]) (< (?:<+\s)?) )	  # open
		    | ( (?:\s>+)? > )			  # or close
		    | (?: (.+?)				  # or text...
			    (?=				  # ...up to
				(?: [A-Z]< )              #   open
			      | (?: (?: \s>+)? > )        #   or close  
                              | $                         #   or EOF
                            ) 
                      )
	   /gxs) {
	if (defined $1) {
	    ($cmd, $lparen) = ($1, $2);
	    $lparen =~ s/\s$//;
	    ($rparen = $lparen) =~ tr/</>/;
	    push(@stack, [ $cmd, $lparen, $rparen, $name, $line, [ ] ]);
	}
	elsif (defined $3) {
	    $rparen = $3;
	    $rparen =~ s/^\s+//;
	    if ($rparen eq $stack[-1]->[RPAREN]) {
		$cmd = $TEXTSEQ->new(pop(@stack))
		    || return $self->error($TEXTSEQ->error());
		push(@{ $stack[-1]->[CONTENT] }, $cmd);
	    }
	    else {
		$self->warning((scalar @stack > 1 
			      ? "expected '$stack[-1]->[RPAREN]' not '$rparen'"
			      : "spurious '$rparen'"), $name, $line);
		push(@{ $stack[-1]->[CONTENT] }, $rparen);
	    }
	}
	elsif (defined $4) {
	    $plain = $4;
	    push(@{ $stack[-1]->[CONTENT] }, $plain);
	    $line += ($plain =~ tr/\n//);
	}
	else {
	    $self->warning("unexpected end of input", $name, $line);
	    last;
	}
    }

    while (@stack > 1) {
	$cmd = pop @stack;
	$self->warning("unterminated '$cmd->[CMD]$cmd->[LPAREN]' starting", 
		       $name, $cmd->[LINE]);
	$cmd = $TEXTSEQ->new($cmd)
	    || $self->error($TEXTSEQ->error());
	push(@{ $stack[-1]->[CONTENT] }, $cmd);
    }

    return $TEXTSEQ->new(pop(@stack))
	|| $self->error($TEXTSEQ->error());
}


#------------------------------------------------------------------------
# default_view($viewer)
#
# Accessor method to return or update the $DEFVIEW package variable,
# loading the module for any package name specified.
#------------------------------------------------------------------------

sub default_view {
    my ($self, $viewer) = @_;
    return $DEFAULT_VIEW unless $viewer;
    unless (ref $viewer) {
	my $file = $viewer;
	$file =~ s[::][/]g;
	$file .= '.pm';
	eval { require $file };
	return $self->error($@) if $@;
    }

    return ($DEFAULT_VIEW = $viewer);
}


#------------------------------------------------------------------------
# warning($msg, $file, $line)
#
# Appends a string of the form " at $file line $line" to $msg if 
# $file is specified and then stores $msg in the internals 
# WARNINGS list.  If the WARN option is set then the warning is
# raised, either via warn(), or by dispatching to a subroutine
# when WARN is defined as such.
#------------------------------------------------------------------------

sub warning {
    my ($self, $msg, $file, $line) = @_;
    my $warn = $self->{ WARN };
    $line = 'unknown' unless defined $line && length $line;
    $msg .= " at $file line $line" if $file;

    push(@{ $self->{ WARNINGS } }, $msg);

    if (ref $warn eq 'CODE') {
	&$warn($msg);
    }
    elsif ($warn) {
	warn($msg, "\n");
    }
}


#------------------------------------------------------------------------
# warnings()
#
# Returns a reference to the (possibly empty) list of warnings raised by
# the most recent call to any of the parse_XXX() methods
#------------------------------------------------------------------------

sub warnings {
    my $self = shift;
    return wantarray ? @{ $self->{ WARNINGS } } : $self->{ WARNINGS };
}


#------------------------------------------------------------------------
# error($msg)
#
# Sets the internal ERROR member and returns undef when called with an
# argument(s), returns the current value when called without.
#------------------------------------------------------------------------

sub error {
    my $self = shift;
    my $errvar;

    { 
	no strict qw( refs );
	if (ref $self) {
	    $errvar = \$self->{ ERROR };
	}
	else {
	    $errvar = \${"$self\::ERROR"};
	}
    }
    if (@_) {
	$$errvar = ref($_[0]) ? shift : join('', @_);
	return undef;
    }
    else {
	return $$errvar;
    }
}



sub DEBUG {
    print STDERR "DEBUG: ", @_ if $DEBUG;
}

1;

__END__

=head1 NAME

Pod::POM - POD Object Model

=head1 SYNOPSIS

    use Pod::POM;

    my $parser = Pod::POM->new(\%options);

    # parse from a text string
    my $pom = $parser->parse_text($text)
        || die $parser->error();

    # parse from a file specified by name or filehandle
    my $pom = $parser->parse_file($file)
        || die $parser->error();

    # parse from text or file 
    my $pom = $parser->parse($text_or_file)
        || die $parser->error();

    # examine any warnings raised
    foreach my $warning ($parser->warnings()) {
	warn $warning, "\n";
    }

    # print table of contents using each =head1 title
    foreach my $head1 ($pom->head1()) {
	print $head1->title(), "\n";
    }

    # print each section
    foreach my $head1 ($pom->head1()) {
	print $head1->title(), "\n";
        print $head1->content();
    }

    # print the entire document as HTML
    use Pod::POM::View::HTML;
    print Pod::POM::View::HTML->print($pom);

    # create custom view
    package My::View;
    use base qw( Pod::POM::View::HTML );

    sub view_head1 {
	my ($self, $item) = @_;
	return '<h1>', 
	       $item->title->present($self), 
               "</h1>\n",
	       $item->content->present($self);
    }
    
    package main;
    print My::View->print($pom);

=head1 DESCRIPTION

This module implements a parser to convert Pod documents into a simple
object model form known hereafter as the Pod Object Model.  The object
model is generated as a hierarchical tree of nodes, each of which
represents a different element of the original document.  The tree can
be walked manually and the nodes examined, printed or otherwise
manipulated.  In addition, Pod::POM supports and provides view objects
which can automatically traverse the tree, or section thereof, and
generate an output representation in one form or another.

Let's look at a typical Pod document by way of example.

    =head1 NAME

    My::Module - just another My::Module

    =head1 DESCRIPTION

    This is My::Module, a deeply funky piece of Perl code.

    =head2 METHODS

    My::Module implements the following methods

    =over 4

    =item new(\%config)

    This is the constructor method.  It accepts the following 
    configuration options:

    =over 4

    =item name

    The name of the thingy.

    =item colour

    The colour of the thingy.

    =back

    =item print()

    This prints the thingy.

    =back

    =head1 AUTHOR

    My::Module was written by me E<lt>me@here.orgE<gt>

This document contains 3 main sections, NAME, DESCRIPTION and 
AUTHOR, each of which is delimited by an opening C<=head1> tag.
NAME and AUTHOR each contain only a single line of text, but 
DESCRIPTION is more interesting.  It contains a line of text
followed by the C<=head2> subsection, METHODS.  This contains
a line of text and a list extending from the C<=over 4> to the 
final C<=back> just before the AUTHOR section starts.  The list
contains 2 items, C<new(\%config)>, which itself contains some 
text and a list of 2 items, and C<print()>.

Presented as plain text and using indentation to indicate the element 
nesting, the model then looks something like this :

    NAME
        My::Module - just another My::Module

    DESCRIPTION
	This is My::Module, a deeply funky piece of Perl code.

        METHODS
	    My::Module implements the following methods

	    * new(\%config)
	        This is the constructor method.  It accepts the 
	        following configuration options:

	        * name
		    The name of the thingy.

                * colour
		    The colour of the thingy.

	    * item print()
	        This prints the thingy.

    AUTHOR
        My::Myodule was written by me <me@here.org>

Those of you familiar with XML may prefer to think of it in the
following way:

    <pod>
      <head1 title="NAME">
        <p>My::Module - just another My::Module</p>
      </head1>

      <head1 title="DESCRIPTION">
        <p>This is My::Module, a deeply funky piece of 
           Perl code.</p>

        <head2 title="METHODS">
	  <p>My::Module implements the following methods</p>

	  <over indent=4>
	    <item title="item new(\%config)">
	      <p>This is the constructor method.  It accepts
	         the following configuration options:</p>

	      <over indent=4>
		<item title="name">
	          <p>The name of the thingy.</p>
	        </item>

	        <item title="colour">
	          <p>The colour of the thingy.</p>
	        </item>
              </over>
            </item>

            <item title="print()">
	      <p>This prints the thingy.</p>
	    </item>
          </over>
        </head2>
      </head1>

      <head1 title="AUTHOR">
	<p>My::Myodule was written by me &lt;me@here.org&gt;
      </head1>
    </pod>

Notice how we can make certain assumptions about various elements.
For example, we can assume that any C<=head1> section we find begins a
new section and implicitly ends any previous section.  Similarly, we
can assume an C<=item> ends when the next one begins, and so on.  In
terms of the XML example shown above, we are saying that we're smart
enough to add a C<E<lt>/head1E<gt>> element to terminate any
previously opened C<E<lt>head1E<gt>> when we find a new C<=head1> tag
in the input document.

However you like to visualise the content, it all comes down to the
same underlying model.  The job of the Pod::POM module is to read an
input Pod document and build an object model to represent it in this
structured form. 

Each node in the tree (i.e. element in the document) is represented
by a Pod::POM::Node::* object.  These encapsulate the attributes for
an element (such as the title for a C<=head1> tag) and also act as
containers for further Pod::POM::Node::* objects representing the
content of the element.  Right down at the leaf nodes, we have simple
object types to represent formatted and verbatim text paragraphs and
other basic elements like these.

=head2 Parsing Pod

The Pod::POM module implements the methods parse_file($file),
parse_text($text) and parse($file_or_text) to parse Pod files and
input text.  They return a Pod::POM::Node::Pod object to represent the
root of the Pod Object Model, effectively the C<E<lt>podE<gt>> element
in the XML tree shown above.

    use Pod::POM;

    my $parser = Pod::POM->new();
    my $pom = $parser->parse_file($filename)
        || die $parser->error();

The parse(), parse_text() and parse_file() methods return
undef on error.  The error() method can be called to retrieve the
error message generated.  Parsing a document may also generate
non-fatal warnings.  These can be retrieved via the warnings() method
which returns a reference to a list when called in scalar context or a
list of warnings when called in list context.

    foreach my $warn ($parser->warnings()) {
	warn $warn, "\n";
    }

Alternatively, the 'warn' configuration option can be set to have
warnings automatically raised via C<warn()> as they are encountered.

    my $parser = Pod::POM->new( warn => 1 );

=head2 Walking the Object Model

Having parsed a document into an object model, we can then select 
various items from it.  Each node implements methods (via AUTOLOAD)
which correspond to the attributes and content elements permitted
within in.

So to fetch the list of '=head1' sections within our parsed document,
we would do the following:

    my $sections = $pom->head1();

Methods like this will return a list of further Pod::POM::Node::* 
objects when called in list context or a reference to a list when 
called in scalar context.  In the latter case, the list is blessed
into the Pod::POM::Node::Content class which gives it certain 
magical properties (more on that later).

Given the list of Pod::POM::Node::Head1 objects returned by the above,
we can print the title attributes of each like this:

    foreach my $s (@$sections) {
	print $s->title();
    }

Let's look at the second section, DESCRIPTION.

    my $desc = $sections->[1];

We can print the title of each subsection within it:

    foreach my $ss ($desc->head2()) {
	print $ss->title();
    }

Hopefully you're getting the idea by now, so here's a more studly
example to print the title for each item contained in the first list
within the METHODS section:

    foreach my $item ($desc->head2->[0]->over->[0]->item) {
	print $item->title(), "\n";
    }

=head2 Element Content

This is all well and good if you know the precise structure of a 
document in advance.  For those more common cases when you don't,
each node that can contain other nodes provides a 'content' method
to return a complete list of all the other nodes that it contains.
The 'type' method can be called on any node to return its element
type (e.g. 'head1', 'head2', 'over', item', etc).

    foreach my $item ($pom->content()) {
	my $type = $item->type();
	if ($type eq 'head1') {
	    ...
	}
	elsif ($type eq 'head2') {
	    ...
	}
	...
    }

The content for an element is represented by a reference to a list,
blessed into the Pod::POM::Node::Content class.  This provides some
magic in the form of an overloaded stringification operator which 
will automatically print the contents of the list if you print 
the object itself.  In plain English, or rather, in plain Perl,
this means you can do things like the following:

    foreach my $head1 ($pom->head1()) {
	print '<h1>', $head1->title(), "</h1>\n\n";
	print $head1->content();
    }

    # print all the root content
    foreach my $item ($pom->content()) {
	print $item;
    }

    # same as above
    print $pom->content();

In fact, all Pod::POM::Node::* objects provide this same magic, and
will attempt to Do The Right Thing to present themselves in the
appropriate manner when printed.  Thus, the following are all valid.

    print $pom;			# entire document
    print $pom->content;	# content of document
    print $pom->head1->[0];	# just first section
    print $pom->head1;		# print all sections
    foreach my $h1 ($pom->head1()) {
	print $h1->head2();	# print all subsections
    }

=head2 Output Views

To understand how the different elements go about presenting
themselves in "the appropriate manner", we must introduce the concept
of a view.  A view is quite simply a particular way of looking at the
model.  In real terms, we can think of a view as being some kind of
output type generated by a pod2whatever converter.  Notionally we can
think in terms of reading in an input document, building a Pod Object
Model, and then generating an HTML view of the document, and/or a
LaTeX view, a plain text view, and so on.

A view is represented in this case by an object class which contains
methods for displaying each of the different element types that could
be encountered in any Pod document.  There's a method for displaying
C<=head1> sections (view_head1()), another method for displaying
C<=head2> sections (view_head2()), one for C<=over> (view_over()),
another for C<=item> (view_item()) and so on.

If we happen to have a reference to a $node and we know it's a 'head1'
node, then we can directly call the right view method to have it
displayed properly:

    $view = 'Pod::POM::View::HTML';
    $view->view_head1($node);

Thus our earlier example can be modified to be I<slightly> less laborious
and I<marginally> more flexible.

    foreach my $node ($pom->content) {
	my $type = $node->type();
	if ($type eq 'head1') {
	    print $view->view_head1($node);
	}
	elsif ($type eq 'head2') {
	    print $view->view_head2($node);
	}
	...
    }

However, this is still far from ideal.  To make life easier, each
Pod::POM::Node::* class inherits (or possibly redefines) a
C<present($view)> method from the Pod::POM::Node base class.  This method
expects a reference to a view object passed as an argument, and it
simply calls the appropriate view_xxx() method on the view object,
passing itself back as an argument.  In object parlance, this is known
as "double dispatch".  The beauty of it is that you don't need to know
what kind of node you have to be able to print it.  You simply pass
it a view object and leave it to work out the rest.

    foreach my $node ($pom->content) {
	print $node->present($view);
    }

If $node is a Pod::POM::Node::Head1 object, then the view_head1($node)
method gets called against the $view object.  Otherwise, if it's a
Pod::POM::Node::Head2 object, then the view_head2($node) method is
dispatched.  And so on, and so on, with each node knowing what it is
and where it's going as if determined by some genetically pre-programmed
instinct.  Fullfilling their destinies, so to speak.

Double dispatch allows us to do away with all the explicit type
checking and other nonsense and have the node objects themselves worry
about where they should be routed to.  At the cost of an extra method
call per node, we get programmer convenience, and that's usually 
a Good Thing.

Let's have a look at how the view and node classes might be
implemented.

    package Pod::POM::View::HTML;

    sub view_pod {
	my ($self, $node) = @_;
	return $node->content->present($self);
    }

    sub view_head1 {
	my ($self, $node) = @_;
	return "<h1>", $node->title->present($self), "</h1>\n\n"
	     . $node->content->present($self);
    }

    sub view_head2 {
	my ($self, $node) = @_;
	return "<h2>", $node->title->present($self), "</h2>\n\n"
	     . $node->content->present($self);
    }

    ...

    package Pod::POM::Node::Pod;

    sub present {
	my ($self, $view) = @_;
	$view->view_pod($self);
    }

    package Pod::POM::Node::Head1;

    sub present {
	my ($self, $view) = @_;
	$view->view_head1($self);
    }

    package Pod::POM::Node::Head2;

    sub present {
	my ($self, $view) = @_;
	$view->view_head2($self);
    }

    ...

Some of the view_xxx methods make calls back against the node objects
to display their attributes and/or content.  This is shown in, for
example, the view_head1() method above, where the method prints the
section title in C<E<lt>h1E<gt>>...C<E<lt>h1E<gt>> tags, followed by
the remaining section content.

Note that the title() attribute is printed by calling its present()
method, passing on the reference to the current view.  Similarly,
the content present() method is called giving it a chance to Do
The Right Thing to present itself correctly via the view object.

There's a good chance that the title attribute is going to be regular
text, so we might be tempted to simply print the title rather than 
call its present method.

    sub view_head1 {
	my ($self, $node) = @_;
	# not recommended, prefer $node->title->present($self)
	return "<h1>", $node->title(), "</h1>\n\n", ...
    }

However, it is entirely valid for titles and other element attributes,
as well as regular, formatted text blocks to contain code sequences,
such like C<BE<lt>thisE<gt>> and C<IE<lt>thisE<gt>>.  These are used
to indicate different markup styles, mark external references or index
items, and so on.  What's more, they can be C<BE<lt>nested
IE<lt>indefinatelyE<gt>E<gt>>.  Pod::POM takes care of all this by
parsing such text, along with any embedded sequences, into Yet Another
Tree, the root node of which is a Pod::POM::Node::Text object,
possibly containing other Pod::POM::Node::Sequence objects.  When the
text is presented, the tree is automatically walked and relevant
callbacks made against the view for the different sequence types.  The
methods called against the view are all prefixed 'view_seq_', e.g.
'view_seq_bold', 'view_seq_italic'.

Now the real magic comes into effect.  You can define one view to
render bold/italic text in one style:

    package My::View::Text;
    use base qw( Pod::POM::View::Text );

    sub view_seq_bold {
	my ($self, $text) = @_;
	return "*$text*";
    }

    sub view_seq_italic {
	my ($self, $text) = @_;
	return "_$text_";
    }

And another view to render it in a different style:

    package My::View::HTML;
    use base qw( Pod::POM::View::HTML );

    sub view_seq_bold {
	my ($self, $text) = @_;
	return "<b>$text</b>";
    }

    sub view_seq_italic {
	my ($self, $text) = @_;
	return "<i>$text</i>";
    }

Then, you can easily view a Pod Object Model in either style:

    my $text = 'My::View::Text';
    my $html = 'My::View::HTML';

    print $pom->present($text);
    print $pom->present($html);

And you can apply this technique to any node within the object
model.

    print $pom->head1->[0]->present($text);
    print $pom->head1->[0]->present($html);

In these examples, the view passed to the present() method has 
been a class name.  Thus, the view_xxx methods get called as 
class methods, as if written:

    My::View::Text->view_head1(...);

If your view needs to maintain state then you can create a view object
and pass that to the present() method.  

    my $view = My::View->new();
    $node->present($view);

In this case the view_xxx methods get called as object methods.

    sub view_head1 {
	my ($self, $node) = @_;
	my $title = $node->title();
	if ($title eq 'NAME' && ref $self) {
	    $self->{ title } = $title();
	}
	$self->SUPER::view_head1($node);
    }

Whenever you print a Pod::POM::Node::* object, or do anything to cause
Perl to stringify it (such as including it another quoted string "like
$this"), then its present() method is automatically called.  When
called without a view argument, the present() method uses the default
view specified in $Pod::POM::DEFAULT_VIEW, which is, by default,
'Pod::POM::View::Pod'.  This view regenerates the original Pod
document, although it should be noted that the output generated may
not be exactly the same as the input.  The parser is smart enough to
detect some common errors (e.g. not terminating an C<=over> with a C<=back>)
and correct them automatically.  Thus you might find a C<=back>
correctly placed in the output, even if you forgot to add it to the 
input.  Such corrections raise non-fatal warnings which can later
be examined via the warnings() method.

You can update the $Pod::POM::DEFAULT_VIEW package variable to set the 
default view, or call the default_view() method.  The default_view() 
method will automatically load any package you specify.  If setting
the package variable directly, you should ensure that any packages
required have been pre-loaded.

    use My::View::HTML;
    $Pod::POM::DEFAULT_VIEW = 'My::View::HTML';

or

    Pod::POM->default_view('My::View::HTML');

=head2 Template Toolkit Views

One of the motivations for writing this module was to make it easier
to customise Pod documentation to your own look and feel or local
formatting conventions.  By clearly separating the content
(represented by the Pod Object Model) from the presentation style
(represented by one or more views) it becomes much easier to achieve
this.

The latest version of the Template Toolkit (2.06 at the time of
writing) provides a Pod plugin to interface to this module.  It also
implements a new (but experimental) VIEW directive which can be used
to build different presentation styles for converting Pod to other
formats.  The Template Toolkit is available from CPAN:

    http://www.cpan.org/modules/by-module/Template/

Template Toolkit views are similar to the Pod::POM::View objects
described above, except that they allow the presentation style for
each Pod component to be written as a template file or block rather
than an object method.  The precise syntax and structure of the VIEW
directive is subject to change (given that it's still experimental),
but at present it can be used to define a view something like this:

    [% VIEW myview %]

       [% BLOCK view_head1 %]
          <h1>[% item.title.present(view) %]</h1>
          [% item.content.present(view) %]
       [% END %]
 
       [% BLOCK view_head2 %]
          <h2>[% item.title.present(view) %]</h2>
          [% item.content.present(view) %]
       [% END %]

       ...

    [% END %]

A plugin is provided to interface to the Pod::POM module:

    [% USE pod %]
    [% pom = pod.parse('/path/to/podfile') %]

The returned Pod Object Model instance can then be navigated and
presented via the view in almost any way imaginable:

    <h1>Table of Contents</h1>
    <ul>
    [% FOREACH section = pom.head1 %]
       <li>[% section.title.present(view) %]
    [% END %]
    </ul>

    <hr>

    [% FOREACH section = pom.head1 %]
       [% section.present(myview) %]
    [% END %]

You can either pass a reference to the VIEW (myview) to the 
present() method of a Pod::POM node:

    [% pom.present(myview) %]	    # present entire document

Or alternately call the print() method on the VIEW, passing the 
Pod::POM node as an argument:

    [% myview.print(pom) %]

Internally, the view calls the present() method on the node,
passing itself as an argument.  Thus it is equivalent to the 
previous example.

The Pod::POM node and the view conspire to "Do The Right Thing" to 
process the right template block for the node.  A reference to the
node is available within the template as the 'item' variable.

   [% BLOCK view_head2 %]
      <h2>[% item.title.present(view) %]</h2>
      [% item.content.present(view) %]
   [% END %]

The Template Toolkit documentation contains further information on
defining and using views.  However, as noted above, this may be
subject to change or incomplete pending further development of the 
VIEW directive.

=head1 METHODS

=head2 new(\%config)

Constructor method which instantiates and returns a new Pod::POM 
parser object.  

    use Pod::POM;

    my $parser = Pod::POM->new();

A reference to a hash array of configuration options may be passed as
an argument.

    my $parser = Pod::POM->new( { warn => 1 } );

For convenience, configuration options can also be passed as a list of
(key =E<gt> value) pairs.

    my $parser = Pod::POM->new( warn => 1 );

The following configuration options are defined:

=over 4

=item code

This option can be set to have all non-Pod parts of the input document
stored within the object model as 'code' elements, represented by 
objects of the Pod::POM::Node::Code class.  It is disabled by default
and code sections are ignored.  

    my $parser = Pod::POM->new( code => 1 );
    my $podpom = $parser->parse(\*DATA);

    foreach my $code ($podpom->code()) {
	print "<pre>$code</pre>\n";
    }

    __DATA__
    This is some program code.

    =head1 NAME

    ...

This will generate the output:

    <pre>This is some program code.</pre>

Note that code elements are stored within the POM element in which
they are encountered.  For example, the code element below embedded
within between Pod sections is stored in the array which can be
retrieved by calling C<$podpom-E<gt>head1-E<gt>[0]-E<gt>code()>.

    =head1 NAME

    My::Module::Name;

    =cut

    Some program code embedded in Pod.

    =head1 SYNOPSIS

    ...

=item warn

Non-fatal warnings encountered while parsing a Pod document are stored 
internally and subsequently available via the warnings() method.

    my $parser = Pod::POM->new();
    my $podpom = $parser->parse_file($filename);

    foreach my $warning ($parser->warnings()) {
	warn $warning, "\n";
    }

The 'warn' option can be set to have warnings raised automatically 
via C<warn()> as and when they are encountered.

    my $parser = Pod::POM->new( warn => 1 );
    my $podpom = $parser->parse_file($filename);

If the configuration value is specified as a subroutine reference then
the code will be called each time a warning is raised, passing the
warning message as an argument.

    sub my_warning {
	my $msg = shift;
	warn $msg, "\n";
    };

    my $parser = Pod::POM->new( warn => \&my_warning );
    my $podpom = $parser->parse_file($filename);

=item meta

The 'meta' option can be set to allow C<=meta> tags within the Pod
document.  

    my $parser = Pod::POM->new( meta => 1 );
    my $podpom = $parser->parse_file($filename);

This is an experimental feature which is not part of standard
POD.  For example:

    =meta author Andy Wardley

These are made available as metadata items within the root
node of the parsed POM.

    my $author = $podpom->metadata('author');

See the L<METADATA|METADATA> section below for further information.

=back

=head2 parse_file($file)

Parses the file specified by name or reference to a file handle.
Returns a reference to a Pod::POM::Node::Pod object which represents
the root node of the Pod Object Model on success.  On error, undef
is returned and the error message generated can be retrieved by calling
error().

    my $podpom = $parser->parse_file($filename)
        || die $parser->error();

    my $podpom = $parser->parse_file(\*STDIN)
        || die $parser->error();

Any warnings encountered can be examined by calling the 
warnings() method.

    foreach my $warn ($parser->warnings()) {
	warn $warn, "\n";
    }

=head2 parse_text($text)

Parses the Pod text string passed as an argument into a Pod Object
Model, as per parse_file().

=head2 parse($text_or_$file)

General purpose method which attempts to Do The Right Thing in calling
parse_file() or parse_text() according to the argument passed.  

A hash reference can be passed as an argument that contains a 'text'
or 'file' key and corresponding value. 

    my $podpom = $parser->parse({ file => $filename })
        || die $parser->error();

Otherwise, the argument can be a reference to an input handle which is
passed off to parse_file().  

    my $podpom = $parser->parse(\*DATA)
        || die $parser->error();

If the argument is a text string that looks like Pod text (i.e. it
contains '=' at the start of any line) then it is passed to parse_text().

    my $podpom = $parser->parse($podtext)
        || die $parser->error();

Otherwise it is assumed to be a filename and is passed to parse_file().

    my $podpom = $parser->parse($podfile)
        || die $parser->error();

=head1 NODE TYPES, ATTRIBUTES AND ELEMENTS

This section lists the different nodes that may be present in a Pod Object
Model.  These are implemented as Pod::POM::Node::* object instances 
(e.g. head1 =E<gt> Pod::POM::Node::Head1).  To present a node, a view should
implement a method which corresponds to the node name prefixed by 'view_'
(e.g. head1 =E<gt> view_head1()).

=over 4

=item pod

The C<pod> node is used to represent the root node of the Pod Object Model.

Content elements: head1, head2, head3, head4, over, begin, for,
verbatim, text, code.

=item head1

A C<head1> node contains the Pod content from a C<=head1> tag up to the 
next C<=head1> tag or the end of the file.

Attributes: title

Content elements: head2, head3, head4, over, begin, for, verbatim, text, code.

=item head2

A C<head2> node contains the Pod content from a C<=head2> tag up to the 
next C<=head1> or C<=head2> tag or the end of the file.

Attributes: title

Content elements: head3, head4, over, begin, for, verbatim, text, code.

=item head3

A C<head3> node contains the Pod content from a C<=head3> tag up to the 
next C<=head1>, C<=head2> or C<=head3> tag or the end of the file.

Attributes: title

Content elements: head4, over, begin, for, verbatim, text, code.

=item head4

A C<head4> node contains the Pod content from a C<=head4> tag up to the 
next C<=head1>, C<=head2>, C<=head3> or C<=head4> tag or the end of the file.

Attributes: title

Content elements: over, begin, for, verbatim, text, code.

=item over

The C<over> node encloses the Pod content in a list starting at an C<=over> 
tag and continuing up to the matching C<=back> tag.  Lists may be nested 
indefinately.

Attributes: indent (default: 4)

Content elements: over, item, begin, for, verbatim, text, code.

=item item

The C<item> node encloses the Pod content in a list item starting at an 
C<=item> tag and continuing up to the next C<=item> tag or a C<=back> tag
which terminates the list.

Attributes: title (default: *)

Content elements: over, begin, for, verbatim, text, code.

=item begin

A C<begin> node encloses the Pod content in a conditional block starting 
with a C<=begin> tag and continuing up to the next C<=end> tag.

Attributes: format

Content elements: verbatim, text, code.

=item for

A C<for> node contains a single paragraph containing text relevant to a 
particular format.

Attributes: format, text

=item verbatim

A C<verbatim> node contains a verbatim text paragraph which is prefixed by
whitespace in the source Pod document (i.e. indented).

Attributes: text

=item text

A C<text> node contains a regular text paragraph.  This may include 
embedded inline sequences.

Attributes: text

=item code

A C<code> node contains Perl code which is by default, not considered to be 
part of a Pod document.  The C<code> configuration option must be set for
Pod::POM to generate code blocks, otherwise they are ignored.

Attributes: text

=back

=head1 INLINE SEQUENCES

Embedded sequences are permitted within regular text blocks (i.e. not
verbatim) and title attributes.  To present these sequences, a view
should implement methods corresponding to the sequence name, prefixed
by 'view_seq_' (e.g. bold =E<gt> view_seq_bold()).

=over 4

=item code

Code extract, e.g. CE<lt>my codeE<gt>

=item bold

Bold text, e.g. BE<lt>bold textE<gt>

=item italic

Italic text, e.g. IE<lt>italic textE<gt>

=item link

A link (cross reference), e.g. LE<lt>My::ModuleE<gt>

=item space

Text contains non-breaking space, e.g.SE<lt>Buffy The Vampire SlayerE<gt>

=item file

A filename, e.g. FE<lt>/etc/lilo.confE<gt>

=item index

An index entry, e.g. XE<lt>AngelE<gt>

=item zero

A zero-width character, e.g. ZE<lt>E<gt>

=item entity

An entity escape, e.g. EE<lt>ltE<gt>

=back

=head1 BUNDLED MODULES AND TOOLS

The Pod::POM module distribution includes a number of sample view
objects for rendering Pod Object Models into particular formats.  These
are incomplete and may require some further work, but serve at present to 
illustrate the principal and can be used as the basis for your own view
objects.

=over 4

=item Pod::POM::View::Pod

Regenerates the model as Pod.

=item Pod::POM::View::Text

Presents the model as plain text.

=item Pod::POM::View::HTML

Presents the model as HTML.

=back

A script is provided for converting Pod documents to other format by
using the view objects provided.  The C<pom2> script should be called 
with two arguments, the first specifying the output format, the second
the input filename.  e.g.

    $ pom2 text My/Module.pm > README
    $ pom2 html My/Module.pm > ~/public_html/My/Module.html

You can also create symbolic links to the script if you prefer and 
leave it to determine the output format from its own name.

    $ ln -s pom2 pom2text	
    $ ln -s pom2 pom2html
    $ pom2text My/Module.pm > README
    $ pom2html My/Module.pm > ~/public_html/My/Module.html

The distribution also contains a trivial script, C<podlint>
(previously C<pomcheck>), which checks a Pod document for
well-formedness by simply parsing it into a Pod Object Model with
warnings enabled.  Warnings are printed to STDERR.

    $ podlint My/Module.pm

The C<-f> option can be set to have the script attempt to fix any problems
it encounters.  The regenerated Pod output is printed to STDOUT.

    $ podlint -f My/Module.pm > newfile

=head1 METADATA

This module includes support for an experimental new C<=meta> tag.  This
is disabled by default but can be enabled by loading Pod::POM with the 
C<meta> option.

    use Pod::POM qw( meta );

Alternately, you can specify the C<meta> option to be any true value when 
you instantiate a Pod::POM parser:

    my $parser = Pod::POM->new( meta => 1 );
    my $pom    = $parser->parse_file($filename);

Any C<=meta> tags in the document will be stored as metadata items in the 
root node of the Pod model created.  

For example:

    =meta module Foo::Bar

    =meta author Andy Wardley

You can then access these items via the metadata() method.

    print "module: ", $pom->metadata('module'), "\n";
    print "author: ", $pom->metadata('author'), "\n";

or

    my $metadata = $pom->metadata();
    print "module: $metadata->{ module }\n";
    print "author: $metadata->{ author }\n";

Please note that this is an experimental feature which is not supported by
other POD processors and is therefore likely to be most incompatible.  Use
carefully.

=head1 AUTHOR

Andy Wardley E<lt>abw@kfs.orgE<gt>

Andrew Ford E<lt>A.Ford@ford-mason.co.ukE<gt> (co-maintainer as of 03/2009)

=head1 VERSION

This is version 0.25 of the Pod::POM module.

=head1 COPYRIGHT

Copyright (C) 2000-2009 Andy Wardley.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

For the definitive reference on Pod, see L<perlpod>.

For an overview of Pod::POM internals and details relating to subclassing
of POM nodes, see L<Pod::POM::Node>.

There are numerous other fine Pod modules available from CPAN which
perform conversion from Pod to other formats.  In many cases these are
likely to be faster and quite possibly more reliable and/or complete
than this module.  But as far as I know, there aren't any that offer
the same kind of flexibility in being able to customise the generated
output.  But don't take my word for it - see your local CPAN site for
further details:

    http://www.cpan.org/modules/by-module/Pod/

