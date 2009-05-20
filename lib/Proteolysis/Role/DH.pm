package Proteolysis::Role::DH;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Moose::Role;
use Proteolysis::Types   qw( Pool );
use MooseX::Types::Moose qw( Num  );
use namespace::clean -except => 'meta';

has _first_pool => (
    is         => 'ro',
    isa        => Pool,
    lazy_build => 1,
);

sub dh {
    my ($self, $pool) = @_;

    $pool //= $self->pool;

    my $original_pool = $self->_first_pool;

    my $h0 = _peptidic_bond_count( $original_pool );
    my $h  = _peptidic_bond_count( $pool          );

    my $dh = 100 * ( 1 - $h / $h0 );

    return $dh;
}

sub _build__first_pool {
    my $self = shift;

    my $i = 0;
    my $pool;

    until ( defined $pool ) {
        $pool = $self->_get_pool_number($i++);
    }

    return $pool;
}

sub _peptidic_bond_count {
    my $pool = shift;

    my $avg_length     = $pool->length;
    my $molecule_count = $pool->count;

    my $bond_count     = $molecule_count * ($avg_length - 1);

    return $bond_count;
}

sub _get_pool_number {
    my ( $self, $number ) = @_;

    my $pool = $self->pool;
    die unless defined $pool;

    while ( $pool->number > $number ) {
        $pool = $pool->previous;
    }

    if ( $pool->number == $number ) { return $pool }
    else                            { return       }
}

1;
