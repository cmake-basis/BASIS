##############################################################################
# @file  DoxyFilter/CMake.pm
# @brief Doxygen filter for CMake.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup BasisTools
##############################################################################

package BASIS::DoxyFilter::CMake;
use base BASIS::DoxyFilter;

# ============================================================================
# public
# ============================================================================

# ----------------------------------------------------------------------------
## @brief Constructs a CMake Doxygen filter.
sub new
{
    shift->SUPER::new([
        # if() else() endif()
        ['start', qr/^\s*if\s*\(/, undef, 'start'], # discard if()'s such that
                                                    # Doxygen comment is
                                                    # associated with next
                                                    # block that is supposed
                                                    # to be in the then branch.
        # include()
        ['start', qr/^\s*include\s*\((.+)\)\s*(#.*)?$/, \&_include, 'start'],
        # option()
        ['start',         qr/^\s*option\s*\(\s*(\w+)\s+(\"([^\"]|\\\")*[^\\]\")\s+(ON|OFF)\s*\)\s*(#.*)?$/, \&_option,       'start'],
        ['start',         qr/^\s*option(.*)[^\)]\s*(#.*)?$/,                                                \&_option_begin, 'option'],
        ['option',        qr/(^|^.*\s+)\"([^\"]|\\\")*$/,                                                   \&_option_line,  'option_doc'],
        ['option_doc',    qr/(^|^.*[^\\])\".*\s+\"([^\"]|\\\")*$/,                                          \&_option_line,  'option_doc'],
        ['option_doc',    qr/(^|^.*[^\\])\".*\)\s*(#.*)?$/,                                                 \&_option_end,   'start'],
        ['option_doc',    qr/(^|^.*[^\\])\".*$/,                                                            \&_option_line,  'option'],
        ['option_doc',    qr/.*/,                                                                           \&_option_line,  'option_doc'],
        ['option',        qr/^.*\)\s*(#.*)?$/,                                                              \&_option_end,   'start'],
        ['option',        qr/.*$/,                                                                          \&_option_line,  'option'],
        # set()
        ['start',         qr/^\s*(set|basis_set_if_empty|basis_set_if_not_set|basis_set_script_path)\s*\(\s*(\w+)\s+(.*)\s*\)\s*(#.*)?$/,                     \&_set_nocache, 'start'],
        ['start',         qr/^\s*(set|basis_set_if_empty|basis_set_if_not_set|basis_set_script_path)\s*\(\s*(\w+)\s+(.*)\s+CACHE\s+(\w+)\s+(.*)\)\s*(#.*)?$/, \&_set_cache,   'start'],
        ['start',         qr/^\s*(set|basis_set_if_empty|basis_set_if_not_set|basis_set_script_path)(.*)[^\)]\s*(#.*)?$/,                                     \&_set_begin,   'set'],
        ['set',           qr/(^|^.*\s+)\"([^\"]|\\\")*$/,                                                                               \&_set_line,    'set_value'],
        ['set_value',     qr/(^|^.*[^\\])\".*\s+\"([^\"]|\\\")*$/,                                                                      \&_set_line,    'set_value'],
        ['set_value',     qr/(^|^.*[^\\])\".*\)\s*(#.*)?$/,                                                                             \&_set_end,     'start'],
        ['set_value',     qr/(^|^.*[^\\])\".*$/,                                                                                        \&_set_line,    'set'],
        ['set_value',     qr/.*/,                                                                                                       \&_set_line,    'set_value'],
        ['set',           qr/^.*\)\s*(#.*)?$/,                                                                                          \&_set_end,     'start'],
        ['set',           qr/.*$/,                                                                                                      \&_set_line,    'set'],
        # function()/macro()
        ['start',  qr/^\s*(macro|function)\s*\(\s*(\w+)(\s+[^\)]*)?\)\s*(#.*)?$/, \&_fndef,       'fnbody'],
        ['start',  qr/^\s*(macro|function)\s*\(\s*(\w+)(\s+[^\)]*)?\s*(#.*)?$/,   \&_fndef_begin, 'fndef'],
        ['fndef',  qr/^[^\)]*$/,                                                  \&_fndef_line,  'fndef'],
        ['fndef',  qr/^.*\)\s*(#.*)?$/,                                           \&_fndef_end,   'fnbody'],
        ['fnbody', qr/^\s*end(macro|function)\s*\(\s*(\w+)?\s*\)\s*(#.*)?$/,      undef,          'start'],
        ['fnbody', qr/^\s*end(macro|function)\s*.*[^\)]\s*(#.*)?$/,               undef,          'fnend'],
        ['fnend',  qr/^.*\)\s*(#.*)?$/,                                           undef,          'start'],
    ]);
}

# ============================================================================
# actions
# ============================================================================

# ----------------------------------------------------------------------------
# include()
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
sub _include
{
    my ($self, $module) = @_;
    $module =~ s/^\s*\"?//;
    $module =~ s/\"?\s*$//;
    $module =~ s/\${(CMAKE_CURRENT_LIST_DIR|BASIS_MODULE_PATH|\${NS}MODULE_PATH)}|\@BASIS_MODULE_PATH\@//;
    $module =~ s/ (OPTIONAL|NO_POLICY_SCOPE)//g;
    $module =~ s/\.cmake$//;
    $self->_append("#include \"$module.cmake\"");
}

# ----------------------------------------------------------------------------
# option()
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
sub _option
{
    my $self = shift;
    $self->_option_append($self->{'line'});
}

# ----------------------------------------------------------------------------
sub _option_begin
{
    my $self = shift;
    my $line = $self->{'line'};
    $line =~ s/\s*#.*$//;
    $self->{'buffer'} = "$line";
}

# ----------------------------------------------------------------------------
sub _option_line
{
    my $self = shift;
    my $line = $self->{'line'};
    $line =~ s/\s*#.*$//;
    $self->{'buffer'} .= " $line";
}

# ----------------------------------------------------------------------------
sub _option_end
{
    my $self = shift;
    my $line = $self->{'line'};
    $self->{'buffer'} .= " $line";
    $self->_option_append($self->{'buffer'});
}

# ----------------------------------------------------------------------------
sub _option_append
{
    my ($self, $line) = @_;
    if ($line =~ /^\s*option\s*\(\s*(\w+)\s+(\"([^\"]|\\\")*[^\\]\")\s+(ON|OFF)\s*\)\s*(#.*)?$/) {
        my $name    = $1;
        my $default = $4;
        $self->_append("option $name = $default;");
    }
}

# ----------------------------------------------------------------------------
# set()
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
sub _set_cache
{
    my ($self, $setfn, $name, $value, $type) = @_;
    $type = lc $type;
    $self->_append("$type $name;");
}

# ----------------------------------------------------------------------------
sub _set_nocache
{
    my ($self, $setfn, $name, $value) = @_;
    $self->_append("cmake $name;");
}

# ----------------------------------------------------------------------------
sub _set_begin
{
    my $self = shift;
    my $line = $self->{'line'};
    $line =~ s/\s*#.*$//;
    $self->{'buffer'} = "$line";
}

# ----------------------------------------------------------------------------
sub _set_line
{
    my $self = shift;
    my $line = $self->{'line'};
    $line =~ s/\s*#.*$//;
    $self->{'buffer'} .= " $line";
}

# ----------------------------------------------------------------------------
sub _set_end
{
    my $self = shift;
    my $line = $self->{'line'};
    $self->{'buffer'} .= " $line";
    if ($self->{'buffer'} =~ /\s*(set|basis_set_if_empty|basis_set_if_not_set)\s*\(\s*(\w+)\s+(\"([^\"]|\\\")*[^\\]\"|[^\s]+)(\s+PARENT_SCOPE|\s+CACHE\s+(\w+)\s+(.*))?\s*\)\s*$/) {
        my $type  = '';
        my $name  = $2;
        my $value = $3;
        $type = lc $6 if defined $6;
        $value =~ s/^\s*\"?//;
        $value =~ s/\"?\s*$//;
        $self->_append("$type $name = \"$value\"");
    }
}

# ----------------------------------------------------------------------------
# function()/macro()
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
sub _fndef
{
    my ($self, $dummy, $name) = @_;
    $self->_fndef_append($self->{'line'}) unless $name =~ m/^_/;
}

# ----------------------------------------------------------------------------
sub _fndef_begin
{
    my ($self, $dummy, $name) = @_;
    if ($name =~ m/^_/) {
        $self->{'skip'} = 1;
    } else {
        $self->{'buffer'} = "$self->{'line'}";
    }
}

# ----------------------------------------------------------------------------
sub _fndef_line
{
    my $self = shift;
    $self->{'buffer'} .= " $self->{'line'}" unless $self->{'skip'};
}

# ----------------------------------------------------------------------------
sub _fndef_end
{
    my $self = shift;
    if (not $self->{'skip'}) {
        $self->{'buffer'} .= " $self->{'line'}";
        $self->_fndef_append($self->{'buffer'});
    } else {
        $self->{'skip'} = 0;
    }
}

# ----------------------------------------------------------------------------
sub _fndef_append
{
    my ($self, $line) = @_;
    if ($line =~ /^\s*(macro|function)\s*\(\s*(\w+)(\s+[^\)]*)?\)\s*(#.*)?$/) {
        my $type   = $1;
        my $name   = $2;
        my $params = $3;
        my @params = ();
        if ($params) {
            chomp $params;
            $params =~ s/^\s+//;
            @params = split /\s+/, $params;
            for (my $i = 0; $i <= $#params; $i++) {
                my $dir = 'in';
                foreach my $paramdoc (@{$self->{'params'}}) {
                    if ($paramdoc->{'name'} eq $params[$i]) {
                        $dir = $paramdoc->{'dir'};
                        last;
                    }
                }
                $params[$i] = "$dir $params[$i]";
            }
        }
        foreach my $paramdoc (@{$self->{'params'}}) {
            push @params, $paramdoc->{'dir'} . " " . $paramdoc->{'name'}
                    if $paramdoc->{'name'} =~ /^ARG(N|V[0-9])$/;
        }
        $self->_append("/// \@returns Nothing.") if not $self->{'returndoc'};
        $self->_append("$type $name(" . join(', ', @params) . ");");
    }
}


1;
