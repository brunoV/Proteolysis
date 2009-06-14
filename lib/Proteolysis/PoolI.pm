package Proteolysis::PoolI;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Moose;
use MooseX::AttributeHelpers;
use MooseX::Types::Moose qw(HashRef);
use namespace::autoclean;

has 'substrates' => (
    isa        => HashRef,
    is         => 'ro',
    default    => sub { {} },
    metaclass  => 'Collection::Hash',
    required   => 1,
);

sub _substrate_count {
    my $self = shift;

    my $count;
    map { $count += $_ } values %{$self->substrates};

    $count ||= '0';

    return $count;
}

__PACKAGE__->meta->make_immutable;
