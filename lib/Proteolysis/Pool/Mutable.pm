package Proteolysis::Pool::Mutable;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Moose;
use Proteolysis::Types   qw(Pool Fragment);
use MooseX::Types::Moose qw(HashRef);
use MooseX::AttributeHelpers;
use namespace::autoclean;
extends 'Proteolysis::PoolI';

has 'substrates' => (
    is         => 'ro',
    isa        => HashRef,
    metaclass  => 'Collection::Hash',
    default    => sub { {} },
    provides   => {
        set    => '_set_substrate',
        get    => 'amount_of_substrate',
        exists => 'substrate_exists',
        delete => 'delete_substrate',
    }
);

sub add_substrate {
    my ( $self, $s, $amount ) = @_;

    $amount //= 1;
    my $total;

    if ($self->substrate_exists($s)) {
        $total = $self->amount_of_substrate($s) + $amount;
    } else {
        $total = $amount;
    }

    $self->_set_substrate( $s => $total );
}

no warnings;
*substrate_count = \&Proteolysis::PoolI::_substrate_count;
use warnings;

sub take_substrate {
    my ( $self, $s, $amount ) = @_;

    $amount //= 1;

    $self->substrate_exists($s) or return;

    $self->_set_substrate(
        $s => $self->amount_of_substrate($s) - $amount
    );

    if ( $self->amount_of_substrate($s) <= 0 ) {
        $self->delete_substrate($s)
    }

    return $s;
}

has 'products' => (
    is         => 'ro',
    isa        => HashRef,
    metaclass  => 'Collection::Hash',
    default    => sub { {} },
    provides   => {
        set    => '_set_product',
        get    => 'amount_of_product',
        exists => 'product_exists',
        delete => 'delete_product',
    }
);

sub product_count {
    my $self = shift;

    my $count;
    map { $count += $_ } values %{$self->products};

    return $count;
}

sub add_product {
    my ( $self, $p, $amount) = @_;

    $amount //= 1;
    my $total;

    if ($self->product_exists($p)) {
        $total = $self->amount_of_product($p) + $amount;
    } else {
        $total = $amount;
    }

    $self->_set_product( $p => $total );
}

sub count {
    my $self = shift;

    my $substrate_count = $self->substrate_count // 0;
    my $product_count   = $self->product_count   // 0;

    return $substrate_count + $product_count;
}

sub clone {
    my $self = shift;

    my $copy = __PACKAGE__->new(
        substrates => { %{$self->substrates} },
        products   => { %{$self->products}   },
    );

    return $copy;
}

sub clone_immutable {
    my $self = shift;

    my $copy = $self->clone;

    foreach my $product (keys %{$copy->products}) {
        my $amount = $copy->amount_of_product($product);
        $copy->add_substrate($product => $amount);
    }

    my $immutable_copy = Proteolysis::Pool->new(
        substrates => { %{$copy->substrates} },
    );

    return $immutable_copy;
}

__PACKAGE__->meta->make_immutable;
