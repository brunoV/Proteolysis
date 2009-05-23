package Proteolysis::Role::DH;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Moose::Role;
use Proteolysis::Types   qw( Pool );
use MooseX::Types::Moose qw( Num  );
use namespace::autoclean;

sub dh {
    my ($self, $pool) = @_;

    $pool //= $self->pool // return;
    my $first_pool = $self->_get_first_pool;

    my $h  = _peptidic_bond_count( $pool       );
    my $h0 = _peptidic_bond_count( $first_pool ) || return;

    my $dh = 100 * ( 1 - $h / $h0 );

    return $dh;
}

sub _get_first_pool {
    my $self = shift;

    my $max_number;

    eval  {
        $max_number = $self->pool->number;
    };
    return if $@;

    my $i = 0;
    my $pool;

    until ( defined $pool ) {
        $pool = $self->_get_pool_number($i++);
        last if $i == $max_number;
    }

    return $pool;
}

sub _peptidic_bond_count {
    my $pool = shift // return;

    my $avg_length     = $pool->mean_length;
    my $molecule_count = $pool->count;

    my $bond_count     = $molecule_count * ($avg_length - 1);

    return $bond_count;
}

sub _get_pool_number {
    my ( $self, $number ) = @_;

    my $pool = $self->pool;
    return unless defined $pool;

    if ( $number > $pool->number ) { return }

    while ( $pool->number > $number ) {
        $pool = $pool->previous;
    }

    if ( $pool->number == $number ) { return $pool }
    else                            { return       }
}

1;
