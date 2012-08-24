##############################################################################
# @file  DoxyFilter.pm
# @brief Base class for Doxygen filter implementations.
#
# @note Not to confuse with the Doxygen::Filter::Perl package available on CPAN.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

use 5.8.3;
use strict;
use warnings;

package BASIS::DoxyFilter;

# ============================================================================
# exports
# ============================================================================

use Exporter qw(import);

our $VERSION     = '1.0.0';
our @EXPORT_OK   = qw(FROM CONDITION ACTION TO CODE LABELS);
our %EXPORT_TAGS = (indices => [qw(FROM CONDITION ACTION TO CODE LABELS)]);

# ============================================================================
# constants
# ============================================================================

## @brief Array indices for transition 4-tuple.
use constant {
    FROM      => 0, # current state of filter
    CONDITION => 1, # condition (regex line must match) for transition
    ACTION    => 2, # action to perform upon transition
    TO        => 3  # state to transition to
};

## @brief Array indices for output lines.
use constant {
    CODE   => 0, # line of output code
    LABELS => 1  # array of labels associated with this line
};

# ============================================================================
# public
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Constructs a Doxygen filter object.
sub new
{
    my $class         = shift;
    my $transitions   = shift;
    my $doxydoc_begin = shift;
    my $doxydoc_line  = shift;
    my $doxydoc_end   = shift;
    # default settings
    $doxydoc_begin = qr/##+/  unless defined $doxydoc_begin;
    $doxydoc_line  = qr/##*/  unless defined $doxydoc_line;
    $doxydoc_end   = qr/[^#]/ unless defined $doxydoc_end;
    $transitions   = []       unless defined $transitions;
    # add default transitions for handling of Doxygen comment blocks
    push @$transitions, ['start',   qr/^$doxydoc_begin(.*)$/, \&_doxydoc_begin, 'doxydoc'];
    push @$transitions, ['doxydoc', qr/^$doxydoc_line(\s*[\@])param\s*(\[\s*in\s*\]|\[\s*out\s*\]|\[\s*in,\s*out\s*\]|\[\s*out,\s*in\s*\])?\s+(\w+)\s+(.*)$/, \&_doxydoc_param, 'doxydoc'];
    push @$transitions, ['doxydoc', qr/^$doxydoc_line((\s*[\@])returns?\s+.*)$/, \&_doxydoc_returns, 'doxydoc'];
    push @$transitions, ['doxydoc', qr/^$doxydoc_line(.*)$/, \&_doxydoc_comment, 'doxydoc'];
    push @$transitions, ['doxydoc', qr/^$doxydoc_end|^$/, \&_doxydoc_end, 'start'];
    # last transition is handling all none-blank lines
    push @$transitions, ['start',   qr/[^\s]+/, \&_noneblank, 'start'];
    # initialize object and return it
    return bless {
        'transitions' => $transitions, # reference to array defining the transitions
        'output'      => []            # generated output lines
    }, $class;
}

# ----------------------------------------------------------------------------
## @brief Process input file.
sub process
{
    my $self     = shift;
    my $filename = shift;
    my ($line, $next, @match);

    $self->{'state'}     = 'start';   # initial start state of filter
    $self->{'history'}   = ['start']; # linear history of visited states
    $self->{'reprocess'} = 0;         # can be set by actions to request a
                                      # reprocessing of the current line after
                                      # the state has been changed
    $self->{'line'}      = '';        # current input line
    $self->{'lineno'}    = 0;         # current line number of input
    $self->{'params'}    = [];        # parameters extracted from comment

    open FILE, $filename or die "Failed to open file $filename!";
    while ($self->{'reprocess'} == 1 or $self->{'line'} = <FILE>) {
        if ($self->{'reprocess'}) {
            $self->{'reprocess'} = 0;
        } else {
            chomp $self->{'line'};
            $self->{'lineno'} += 1;
        }
        foreach my $transition (@{$self->{'transitions'}}) {
            if ($transition->[+FROM] eq $self->{'state'}) {
                if (@match = ($self->{'line'} =~ /$transition->[+CONDITION]/)) {
                    # Fill-in blank lines until next output line matches
                    # current input line. Otherwise warnings and errors
                    # of Doxygen cannot be easily related to the input source.
                    $self->_append('', 'blank') until @{$self->{'output'}} >= $self->{'lineno'} - 1;
                    # perform action of transition
                    $self->{'transition'} = $transition;
                    $transition->[+ACTION]->($self, @match) if defined $transition->[+ACTION];
                    # keep track of visited states
                    push  @{$self->{'history'}}, $self->{'state'}
                            unless $self->{'history'}->[-1] eq $self->{'state'};
                    # transition to next state
                    $self->{'state'} = $transition->[+TO];
                    last;
                }
            }
        }
    }
    close FILE;
}

# ----------------------------------------------------------------------------
## @brief Get filter output.
sub output
{
    my $self   = shift;
    my $output = '';
    foreach my $line (@{$self->{'output'}}) {
        $output .= $line->[+CODE] . "\n";
    }
    return $output;
}

# ============================================================================
# protected
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Append line to output.
sub _append
{
    my $self = shift;
    my $line = shift;
    push @{$self->{'output'}}, [$line, [@_]];
}

# ----------------------------------------------------------------------------
## @brief Handle none-blank line.
#
# This action inserts a dummy class definition which is ignored by Doxygen
# if the previous block was a Doxygen comment that is not associated with
# any following declaration. Otherwise, another transition would have handled
# this declaration before.
sub _noneblank
{
    my $self = shift;
    if ($self->{'history'}->[-1] eq 'doxydoc') {
        $self->_append("class DO_NOT_MERGE_WITH_FOLLOWING_COMMENT;", 'prevent-merge');
    }
}


# ----------------------------------------------------------------------------
## @brief Start of Doxygen comment.
sub _doxydoc_begin
{
    my ($self, $comment) = @_;
    $self->{'params'}  = [];
    $self->{'returndoc'} = 0;
    $self->{'returndoc'} = 1 if $comment =~ /[\@]returns?\s+/;
    $self->_doxydoc_comment($comment);
}

# ----------------------------------------------------------------------------
## @brief Doxygen comment line.
sub _doxydoc_comment
{
    my ($self, $comment) = @_;
    $self->_append("///$comment", 'doxydoc');
}

# ----------------------------------------------------------------------------
## @brief Doxygen parameter documentation.
#
# The documentation lines which document function/method/macro parameters
# are extracted and the information stored in the filter object. These parameter
# documentations can then be used by the particular Doxygen filter to generate
# a proper parameter list in case of languages which do by themselves not
# explicitly specify the type and name of the function parameters such as in
# Perl and Bash, in particular. Moreover, CMake provides the special ARGN
# parameter which stores all additional unnamed arguments.
sub _doxydoc_param
{
    my ($self, $prefix, $dir, $name, $comment) = @_;
    $dir = '' if not defined $dir;
    $self->_append("///" . $prefix . "param$dir $name $comment", 'doxydoc', 'param');
    if    ($dir =~ /out/ and $dir =~ /in/) { $dir = 'inout'; }
    elsif ($dir =~ /out/)                  { $dir = 'out';   }
    else                                   { $dir = 'in';    }
    push @{$self->{'params'}}, {'dir' => $dir, 'name' => $name};
}

# ----------------------------------------------------------------------------
## @brief Doxygen return value documentation.
#
# This function simply records in the 'returndoc' member of the filter that
# a "@returns" or "\returns" Doxygen is present in the current Doxygen comment.
# Some filters such as the one for CMake or Bash, use a pseudo return type
# which indicates the type of the function rather than the actual type of
# a return value. Often these functions do not return any particular value.
# In this case, if the Doxygen comment does not include a documentation for
# the pseudo return value, Doxygen will warn. To avoid this warning, a standard
# documentation for the pseudo return value may be added by the filter.
sub _doxydoc_returns
{
    my ($self, $comment) = @_;
    $self->{'returndoc'} = 1;
    $self->_doxydoc_comment($comment);
}

# ----------------------------------------------------------------------------
## @brief End of Doxygen comment.
sub _doxydoc_end
{
    my $self = shift;
    # mark current line that it needs to be reprocessed as this transition
    # only leaves the current state but another transition may actually apply
    $self->{'reprocess'} = 1;
}


1;
