package Proteolysis::Pool;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Moose;
use Proteolysis::Types   qw(Pool Fragment);
use MooseX::Types::Moose qw(HashRef);
use KiokuDB::Class;
use namespace::autoclean;
use Storable qw(dclone);

with qw(Proteolysis::Role::WithHistory Proteolysis::Role::Length
    MooseX::Object::Pluggable);

has '+length_stats' => (
    traits  => [qw(KiokuDB::DoNotSerialize)],
);

has 'substrates' => (
    is         => 'rw',
    isa        => HashRef,
    metaclass  => 'Collection::Hash',
    lazy       => 1,
    auto_deref => 1,
    traits     => [qw(KiokuDB::Lazy)],
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

sub substrate_count {
    my $self = shift;

    my $count;
    map { $count += $_ } values %{$self->substrates};

    $count ||= '0';

    return $count;
}

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
    is         => 'rw',
    isa        => HashRef,
    metaclass  => 'Collection::Hash',
    lazy       => 1,
    auto_deref => 1,
    traits     => [qw(KiokuDB::Lazy)],
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

has '+previous' => (
    isa      => Pool,
    traits   => [qw(KiokuDB::Lazy)],
);

sub count {
    my $self = shift;

    my $substrate_count = $self->substrate_count // 0;
    my $product_count   = $self->product_count   // 0;

    return $substrate_count + $product_count;
}

sub clone {
    my $self = shift;

    my $copy = __PACKAGE__->new;

    $copy->substrates( {$self->substrates} );
    $copy->products  ( {$self->products}   );

    return $copy;
}

__PACKAGE__->meta->make_immutable;
