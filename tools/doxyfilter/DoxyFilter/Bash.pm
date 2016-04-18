# ============================================================================
# Copyright (c) 2011-2012 University of Pennsylvania
# Copyright (c) 2013-2016 Andreas Schuh
# All rights reserved.
#
# See COPYING file for license information or visit
# https://cmake-basis.github.io/download.html#license
# ============================================================================

##############################################################################
# @file  DoxyFilter/Bash.pm
# @brief Doxygen filter for Bash.
#
# @ingroup BasisTools
##############################################################################

package BASIS::DoxyFilter::Bash;
use base BASIS::DoxyFilter;

# ============================================================================
# public
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Constructs a CMake Doxygen filter.
sub new
{
    my $self = shift;
    $self->SUPER::new([
        # if elif fi
        ['start', qr/^\s*if\s*\[/, undef, 'start'], # discard if's such that
                                                    # Doxygen comment is
                                                    # associated with next
                                                    # block that is supposed
                                                    # to be in the then branch.
        # source
        ['start', qr/^\s*(\.|source)\s+(\"([^\"]|\\\")*[^\\]\"|'([^']|\\')*[^\\]'|[^\s&|]*)(\s*(\|\||&&|#).*)?$/, \&_source, 'start'],
        # constant
        ['start', qr/^\s*(\[\s+.*\s+\]\s*(\|\||&&)\s*|if\s+\[\s+.*\s+\]\s*;\s*then\s+)?readonly\s+(\w+)=(\"([^\"]|\\\")*[^\\]\"|'([^']|\\')*[^\\]'|[^#]*)(\s*;\s*fi\s*)?(\s*#.*)?$/, \&_constant, 'start'],
        # function
        ['start',  qr/^\s*(function\s*(\w+)|(\w+)\s*\(\s*\))\s*{\s*(#.*)?$/, \&_fndef, 'fnbody'],
        ['start',  qr/^\s*(function\s*(\w+)|(\w+)\s*\(\s*\))\s*(#.*)?$/,     \&_fndef, 'fndef'],
        ['fndef',  qr/^{\s*(#.*)?$/,                                         undef,    'fnbody'],
        ['fnbody', qr/^}\s*(#.*)?$/,                                         undef,    'start'],
    ]);
}

# ============================================================================
# actions
# ============================================================================

# ----------------------------------------------------------------------------
sub _source
{
    my ($self, $unused, $module) = @_;
    $module =~ s/^\s*[\"']?//;
    $module =~ s/[\"']?\s*$//;
    $module =~ s/\/.\//\//g;
    $module =~ s/^\${_\w+_DIR}\///;
    $module =~ s/^\$\(exedir\)\///;
    $module =~ s/^\${?exec_dir}?\///;
    $self->_append("#include \"$module\"");
}

# ----------------------------------------------------------------------------
sub _constant
{
    my ($self, $unused1, $unused2, $name, $value) = @_;
    if ($name =~ m/^_/) {
        $self->_noneblank();
    } else {
        $value =~ s/^\s*[\"']?//;
        $value =~ s/[\"']?\s*$//;
        if ($value =~ /^[+-]?[0-9]+$/) {
            $self->_append("int $name = $value;");
        } elsif ($value =~ /^[+-]?[0-9]+[.][0-9]+$/) {
            $self->_append("float $name = $value;");
        } else {
            $self->_append("string $name = \"$value\";");
        }
    }
}

# ----------------------------------------------------------------------------
sub _fndef
{
    my ($self, $unused, $name1, $name2) = @_;
    my $name = $name1 ? $name1 : $name2;
    if ($name =~ m/^_/) {
        $self->_noneblank();
    } else {
        my @params = ();
        foreach my $paramdoc (@{$self->{'params'}}) {
            push @params, $paramdoc->{'dir'} . " " . $paramdoc->{'name'};
        }
        $self->_append("/// \@returns Nothing.") if not $self->{'returndoc'};
        $self->_append("function $name(" . join(', ', @params) . ");");
    }
}


1;
