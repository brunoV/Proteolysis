package Proteolysis::Pool;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Moose;
use Proteolysis::Types   qw(Pool Fragment);
use MooseX::Types::Moose qw(ArrayRef);
use KiokuDB::Class;
use namespace::clean -except => 'meta';

with qw(Proteolysis::Role::WithHistory Proteolysis::Role::Length
    MooseX::Object::Pluggable);

has 'substrates' => (
    is         => 'rw',
    isa        => ArrayRef,
    metaclass  => 'Collection::Array',
    lazy       => 1,
    auto_deref => 1,
    traits     => [qw(KiokuDB::Lazy)],
    default    => sub { [] },
    provides   => {
        count  => 'substrate_count',
        push   => 'add_substrate',
    }

);

has 'products' => (
    is         => 'rw',
    isa        => ArrayRef,
    metaclass  => 'Collection::Array',
    lazy       => 1,
    auto_deref => 1,
    traits     => [qw(KiokuDB::Lazy)],
    default    => sub { [] },
    provides   => {
        count  => 'product_count',
        push   => 'add_product',
    }

);

has '+previous' => (
    isa      => Pool,
    traits   => [qw(KiokuDB::Lazy)],
);

sub count {
    my $self = shift;
    return $self->substrate_count + $self->product_count;
}

__PACKAGE__->meta->make_immutable;
1;
