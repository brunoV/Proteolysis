package Proteolysis::Role::DH;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Moose::Role;
use Proteolysis::Types             qw( Pool Percentage );
use MooseX::Types::Common::Numeric qw( PositiveInt     );
use MooseX::Types::Moose           qw( Undef           );
use namespace::autoclean;

requires '_build_substrate_count';

has dh => (
    is  => 'ro',
    isa => Percentage|Undef,
    lazy_build => 1,
);

has _h0 => (
    is  => 'ro',
    isa => PositiveInt,
    lazy_build => 1,
);

sub _build_dh {
    my $self = shift;

    my $h  = $self->_peptidic_bond_count;
    my $h0 = $self->_h0 || return;

    my $dh = 100 * ( 1 - $h / $h0 );

    return $dh;
}

sub _build__h0 {
    my $self = shift;

    my $h0;

    if ( $self->number == 0 ) {
        $h0 = $self->_peptidic_bond_count;
    }
    else {
        $h0 = $self->previous->_h0;
    }

    return $h0;
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
    my $self = shift;

    my $avg_length     = $self->mean_length;
    my $molecule_count = $self->substrate_count;

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
