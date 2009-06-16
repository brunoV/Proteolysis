package Proteolysis;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Moose;
use Proteolysis::Pool;
use Proteolysis::Types   qw(Protease Pool MutablePool);
use MooseX::Types::Moose qw(Num Str);
use KiokuDB::Class;
use namespace::autoclean;

with qw(MooseX::Object::Pluggable);

has protease => (
    is       => 'ro',
    isa      => Protease,
    required => 1,
    coerce   => 1,
    handles  => [qw(cleavage_sites)],
);

has pool => (
    is       => 'ro',
    writer   => '_set_pool',
    traits   => [qw(KiokuDB::Lazy)],
    required => 1,
    isa      => Pool,
    clearer  => 'clear_pool',
    handles  => {
        clear_previous_pools => 'clear_previous',
        dh                   => 'dh',
    }
);

has _last_pool => (
    is => 'rw',
    isa => MutablePool,
    lazy_build => 1,
);

sub _build__last_pool {
    my $self = shift;

    my $mutable_clone = $self->pool->clone_mutable;

    return $mutable_clone;
}

has detail_level => (
    is      => 'rw',
    isa     => Num,
    default => 1,
);

sub digest {
    my ($self, $times) = @_;
    $times //= -1;

    $self->protease && $self->_last_pool && $self->_last_pool->substrates
        or return;

    my $d = int( 1 / $self->detail_level );

    while ($times) {

        my $did_cut = $self->_cut();
        return unless ($did_cut);

        my $skip = --$times % $d;

        if ($did_cut and !$skip) {
            my $new_pool = $self->_last_pool->clone_immutable;
            $self->_add_pool($new_pool);
        }
    }

    return 1;
}

sub _shift_pool {
    my $self = shift;
    my ( $first, $second ) = ( $self->pool, $self->pool->previous );
    return unless ( defined $second );
    $self->_set_pool($second);
    return $first;
}

sub _add_pool {
    my ($self, $pool) = @_;

    my $previous = $self->pool;

    if (defined $previous) {
        $pool->previous($previous);
    }

    $self->_set_pool($pool);
}

sub _cut {
    my ( $self ) = @_;

    unless ( %{$self->_last_pool->substrates} ) { return; }

    my ( $head, $tail ) = $self->_cut_random_fragment;

    ( $head and $tail ) or return;

    $self->_last_pool->add_substrate($_) for ($head, $tail);

    return 1;

}

sub _cut_random_fragment {
    my $self = shift;
    my $pool = $self->_last_pool;

    my $fragment  = _pick_random_substrate(\%{$pool->substrates});
    my $protease  = $self->protease;

    until ( $protease->is_substrate($fragment) ) {

        my $amount = $pool->delete_substrate($fragment);
        $pool->add_product( $fragment, $amount );

        return if ( !%{$pool->substrates} );

        $fragment = _pick_random_substrate(\%{$pool->substrates});
    }

    $pool->take_substrate( $fragment );

    my @sites = $protease->cleavage_sites( $fragment );
    my $site  = $sites[rand @sites];

    my ($head, $tail) = $protease->cut($fragment, $site);

    return $head, $tail;
}

use Inline C => << 'EOC';

char* _pick_random_substrate(SV* hash_ref) {
    HV* hash;
    HE* hash_entry;
    int num_keys, i;
    SV* sv_key;
    SV* sv_val;

    int random_number;
    unsigned sum = 0;
    unsigned v;
    char* k;
    char* return_value;
    srand(time(0));

    if (! SvROK(hash_ref))
        croak("hash_ref is not a reference");

    hash = (HV*)SvRV(hash_ref);
    num_keys = hv_iterinit(hash);

    for (i = 0; i < num_keys; i++) {
        hash_entry = hv_iternext(hash);

        k = SvPV_nolen(hv_iterkeysv(hash_entry));
        v = SvIV(hv_iterval(hash, hash_entry));

        sum += v;
        random_number = rand() % sum;

        if ( random_number < v ) {
            return_value = k;
        }
    }

    return return_value;
}
EOC

__PACKAGE__->meta->make_immutable;
