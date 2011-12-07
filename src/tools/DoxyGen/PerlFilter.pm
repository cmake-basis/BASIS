
# =======================================================================
# Doxygen Pre-Processor for Perl
# Copyright (C) 2002  Bart Schuller
# Copyright (C) 2006  Phinex Informatik AG
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
# 
# @(#) $Id: PerlFilter.pm,v 1.6 2009/01/08 09:32:48 aeby Exp $
# 
# Revision History:
# 
# $Log: PerlFilter.pm,v $
# Revision 1.6  2009/01/08 09:32:48  aeby
# added support for @var command (suggested by Mike Richardson)
#
# Revision 1.5  2006/02/15 15:59:29  aeby
# filter(): "@method" handling: drop auto-recognized $self argument at
# first position
#
# Revision 1.4  2006/01/31 17:46:06  aeby
# filter(): avoid warnings about uninitialized values
# analyze_sub(): added some more argument recognition patterns
#
# Revision 1.3  2006/01/31 16:53:52  aeby
# added copyright info
#
#  
# =======================================================================

## @file PerlFilter.pm
# @brief Implementation of DoxyGen::PerlFilter.


## @class
# Filter from perl syntax API docs to Doxygen-compatible syntax.
# This class is meant to be used as a filter for the
# <a href="http://www.doxygen.org/">Doxygen</a> documentation tool.
package SBIA::BASIS::DoxyGen::PerlFilter;

use warnings;
use strict;
use base qw(SBIA::BASIS::DoxyGen::Filter);
my $id = __PACKAGE__;

## @method void filter($infh)
# Do the filtering.
# @param infh input filehandle, normally STDIN
sub filter {
    my($self, $infile) = @_;
    open(my $infh, $infile);
    my $current_class = "";
    my $file = [];
    while( <$infh> ) {
        push( @$file, $_ );
    }
    $self->file_contents( $file );
    my $objcontext = 
        grep( /^\s*use\s+base\s/, @$file )
        || grep( /\@ISA/, @$file )
        || grep( /^\s*bless/, @$file )
        || grep( /^\s*sub\s+new\s/, @$file )
        || grep( /\$self/, @$file );

    push( @$file, "" );  # in order to have a delimiting empty line at EOF
    for( my $line=0; $line <= $#$file; ) {
        $_ = $file->[$line++];
        if (/^##\s*\@(\S+)\s*(.*)/) {
            my($command, $args) = ($1, $2);
            my @more;
            while ( $_ = $file->[$line++] ) {
                if (/^#\s?(.+)/s) {
                    push @more, $1;
                } else {
                    last;
                }
            }
            if ($command eq 'file') {
                $args ||= $infile;
                $self->start("\@$command $args");
                $self->more(@more);
                $self->end;
            } elsif ($command eq 'class') {
		$objcontext = 1;
                unless ($args) {
                    ($args) = /package\s(.*);/;
                }
                if ($current_class) {
                    $self->flush;
                    $self->print("};\n");
                }
                $current_class = $args;
		$self->emit_class( $args, $line, [
		    "\@$command $args",
		    @more,
		    "\@nosubgrouping"
		] );
            } elsif ($command  eq 'cmethod') {
                unless ($args) {
		    ($args) = $self->analyze_sub( $line-1 );
                }
                $args = $self->munge_parameters($args);
                $self->push($self->protection($args).' Class Methods');
                $self->start("\@fn $args")->more(@more)->end;
                $self->print($args, ";\n");
                $self->pop;
            } elsif ($command  eq 'fn') {
                unless ($args) {
		    ($args) = $self->analyze_sub( $line-1 );
                }
                $args = $self->munge_parameters($args);
                $self->push($self->protection($args).' Functions');
                $self->start("\@fn $args")->more(@more)->end;
                $self->print($args, ";\n");
                $self->pop;
            } elsif ($command  eq 'method') {
                unless ($args) {
		    my( $name, @args );
		    ($args, $name, @args) = $self->analyze_sub( $line-1 );
		    $args =~ s/\$self,*\s*// if( $args[0] eq '$self' );
                }
                $args = $self->munge_parameters($args);
                $self->push($self->protection($args).' Object Methods');
                $self->start("\@fn $args")->more(@more)->end;
                $self->print($args, ";\n");
                $self->pop;
            } elsif ($command  eq 'enum') {
                $self->start("\@$command $args");
                $self->more(@more);
                $self->end;
                $self->print("$command $args;\n");
	    } elsif ($command  eq 'var') {
		$args =~ /([\w:]+)\s*([\w]+)\s*(.*)/ ;
		my $type = $1 ;
		my $name = $2 ;
		my $text = $3 ;
		$self->start( $text );
		$self->more( @more );
		$self->end();
		$self->print("$type $name;\n\n");
            } else {
                $self->start("\@$command $args");
                $self->more(@more);
                $self->end;
            }
            # We ate a line when we got the rest of the comment lines
            redo if defined $_;
        } elsif (/^use\s+([\w:]+)/) {
            my $inc = $1;
            $inc =~ s/::/\//g;
            $self->print("#include \"$inc.pm\"\n");
        } elsif (/^package\s+([\w:]+)/) {
	    if ($current_class) {
		$self->flush;
		$self->print("};\n");
	    }
	    next unless( $objcontext );
	    $current_class = $1;
	    $self->emit_class( $current_class, $line );
        } elsif (/^\s*sub\s+([\w:]+)/) {
	    my( $proto, $name, @args ) = $self->analyze_sub( $line-1 );
	    if( $current_class && @args && ($args[0] eq "\$self") ) {
		$self->push($self->protection($proto).' Object Methods');
		$proto =~ s/\$self,*\s*//;
	    } elsif( $current_class 
	    	&& ((@args && ($args[0] eq "\$class")) || ($name eq "new")) ) {
		$self->push($self->protection($proto).' Class Methods');
	    } else {
		$self->push($self->protection($proto).' Functions');
	    }
	    $proto = $self->munge_parameters($proto);
	    $self->print($proto, ";\n");
	    $self->pop;
	}
    }
    $self->flush();
    if ($current_class) {
        $self->print("};\n");
    }
}



## @method @ analyze_sub( int line )
# analyzes a subroutine declaration starting at the given line. Tries
# to determine whicht arguments it takes.
#
# @param line The line number at which the sub starts
# @return A function prototype, the name of the function and a
#   list of arguments it takes
sub analyze_sub {
    my( $self, $line ) = @_;

    my $file = $self->file_contents();
    $file->[$line] =~ /sub\s+(.*)\{/;
    my $name = $1;
    my $proto;
    my @args;
    if( $name =~ /^(.*)\s*\((.*)\)/ ) {
        $name = $1;
	$proto = $2;
    }
    else {
        my $forward = 5;
        for( my $i=0; $forward && ($i+$line <= $#$file) && ! $proto; $i++ ) {
	    $_ = $file->[$i+$line];
	    if( /^\s*my\s*\((.*)\)\s*=\s*\@_/ ) {
	        $proto = $1;
	    }
	    elsif( /^\s*(local|my)\s*([^\s]*)\s*=\s*shift\s*;/ ) {
	        push( @args, $2 );
	    }
	    elsif( /^\s*(local|my)\s*([^\s]*)\s*=\s*\$_\[\s*(\d+)\s*]/ ) {
	        $args[$3] = $2;
	    }
	    elsif( /shift\s*->\s*[a-z0-9_]+\(/ ) {
	        # assuming anonymously used shifted value is $self
		push( @args, '$self' );
	    }
	    elsif( /^\s*\n/ || /^\s*#/ ) {
	        ;
	    }
	    elsif( /}/ ) {
	        $forward = 0;
	    }
	    else {
	        $forward--;
	    }
	}
    }
    if( $proto ) {
        $proto =~ s/\s+//g;
	$proto =~ s/,/, /g;
	@args = split( ", ", $proto );
    }
        
    $name =~ s/\s+$//;
    my $protection = "";
    if( substr( $name, 0, 1 ) eq "_" ) {
        $protection = "protected";
    }
    return( "$protection retval $name( ".join(", ", @args )." )", $name, @args );
}



## @method emit_class( string class, int line, arrayref doc )
# Emit one class definition. If the doc parameter is defined,
# emits the array as a comment just before the class definition,
# otherwise, only the class definition is emitted.
#
# @param class the name of the class
# @param line the current line number
# @param doc (optional) an array with comment lines
sub emit_class {
    my( $self, $class, $line, $doc ) = @_;

    my(@current_isa, @current_include);
    my $file = $self->file_contents();
    while ($_ = $file->[$line++] ) {
	if (/^\s*(?:use base|\@ISA\s*=|\@${class}::ISA\s*=)\s+(.+);/) {
	    @current_isa = eval $1;
	    $file->[$line-1] = "\n";
	} elsif (/^use\s+([\w:]+)/) {
	    my $inc = $1;
	    $inc =~ s/::/\//g;
	    push @current_include, $inc;
	    $file->[$line-1] = "\n";
	} elsif (/^package/) {
	    last;
	}
    }

    $self->print("#include \"$_.pm\"\n") foreach @current_include;
    $self->print("\n");
    
    if( $doc ) {
        $self->start($doc->[0]);
	$self->more( @$doc[1 .. $#$doc] );
	$self->end();
    }
    $self->print("class $class");

    if (@current_isa) {
	$self->print(":",
	    join(", ", map {"public $_"} @current_isa) );
    }
    $self->print(" {\npublic:\n");
}



## @method arrayref file_contents( arrayref contents )
# set/get an array containing the whole input file, each
# line at one array index.
#
# @param contents (optional) file array ref
# @return The file array ref
sub file_contents {
    my( $self, $contents ) = @_;

    $self->{"$id file"} = $contents if( defined $contents );
    return( $self->{"$id file"} );
}



## @method munge_parameters($args)
# Munge the argument list. Because DoxyGen does not seem to handle $, @ and %
# as argument types properly, we replace them with full length strings.
#
# @param args String specifying anything after a directive
# @return Processed string.
sub munge_parameters {
    my ($this, $args) = @_;

    $args =~ s/\$\@/scalar_or_list /g;
    $args =~ s/\@\$/scalar_or_list /g;
    $args =~ s/\$/scalar /g;
    $args =~ s/\@/list /g;
    $args =~ s/\%/hash /g;

#    my ($ret, $remainder) = ($args =~ /^\s*(\S+)(.+)/);
#    if ($ret) {
#        if ($ret eq '$') {
#            $ret = 'scalar';
#        } elsif ($ret eq '@') {
#            $ret = 'list';
#        } elsif ($ret eq '$@') {
#            $ret = 'scalar_or_list';
#        } elsif ($ret eq '@$') {
#            $ret = 'list_or_scalar';
#        }
#
#        $args = "$ret$remainder";
#    }

    return $args;
}


1;
