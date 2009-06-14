package Proteolysis::Pool::Immutable;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Moose;
use Proteolysis::Types qw(Pool Fragment);
use MooseX::Types::Common::Numeric qw(PositiveInt);
use KiokuDB::Class;
use namespace::autoclean;
require Proteolysis::Pool::Mutable;

extends 'Proteolysis::Pool';
with qw(Proteolysis::Role::WithHistory Proteolysis::Role::Length
    MooseX::Object::Pluggable);

has '+substrates' => ( lazy => 1 );

has '+length_stats' => (
    traits  => [qw(KiokuDB::DoNotSerialize)],
);

has '+previous' => (
    isa      => Pool,
    traits   => [qw(KiokuDB::Lazy)],
);

has substrate_count => (
    is  => 'ro',
    isa => PositiveInt,
    lazy_build => 1,
);

sub _build_substrate_count {
    my $self = shift;

    return $self->_substrate_count;
}

sub clone_mutable {
    my $self = shift;

    my $copy = Proteolysis::Pool::Mutable->new(
        substrates => { %{$self->substrates} },
    );

    return $copy;
}

__PACKAGE__->meta->make_immutable;
