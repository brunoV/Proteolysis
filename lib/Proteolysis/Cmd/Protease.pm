package Proteolysis::Cmd::Protease;
use Moose::Role;
use MooseX::Getopt;
use namespace::autoclean;

use Moose::Util::TypeConstraints;

subtype 'Proteolysis::Cmd::Specificity',
    as 'Str',
    where { $_ ~~ Bio::Protease->Specificities };

has protease => (
    is  => 'rw',
    isa => 'Proteolysis::Cmd::Specificity',
    traits        => [qw(Getopt)],
    cmd_aliases   => 'p',
    documentation => 'Protease specificity (default unspecific)',
    default       => 'hcl',
);

1;

__END__

=pod

=head1 NAME

Proteolysis::Cmd::Protease - A role for command line tools that have a
C<--protease> option.

=head1 SYNOPSIS

    # Returns a Bio::Protease object specified from the command line
    $self->protease

=head1 DESCRIPTION

This role provides the C<protease> attribute and command line option. If
no protease is specified, it defaults to unspecific cleavage (hcl).
