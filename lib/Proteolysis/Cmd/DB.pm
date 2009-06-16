package Proteolysis::Cmd::DB;
use Moose::Role;
use MooseX::Getopt;
use namespace::autoclean;

use lib qw(/home/brunov/lib/Proteolysis/lib);
use Proteolysis::Types   qw(DB      );
use MooseX::Types::Moose qw(Str Bool);
use Moose::Util::TypeConstraints;

use Proteolysis::DB;

has db => (
    is  => 'rw',
    isa => Str,
    traits        => [qw(Getopt)],
    default       => 'db',
    cmd_aliases   => 'D',
    documentation => 'Database name to write results to',
);

has backend => (
    is  => 'ro',
    isa => DB,
    lazy_build => 1,
    traits     => [qw(NoGetopt)],
);

has create => (
    is  => 'rw',
    isa => Bool,
    traits  => [qw(NoGetopt)],
    default => 0,
);

has 'dry_run' => (
    is => 'rw',
    isa => Bool,
    traits        => [qw(Getopt)],
    default       => 0,
    cmd_flag      => 'dry-run',
    documentation => 'Perform a dry run (do not write anything to database)',
);

sub _build_backend {
    my $self = shift;

    my $backend = Proteolysis::DB->new(
        dsn => 'dbi:SQLite:dbname=' . $self->db,

        extra_args => { create => $self->create },
    );

    return $backend;
}

1;

__END__

=pod

=head1 NAME

Proteolysis::Cmd::DB - A role for command line tools that have a
C<--db> option.

=head1 SYNOPSIS

    # Returns a Bio::Protease object specified from the command line
    $self->protease

=head1 DESCRIPTION

This role provides the C<db> attribute and command line option,
neccesary for every action that requires a connection to the database.
