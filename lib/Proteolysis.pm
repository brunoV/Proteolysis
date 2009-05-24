package Proteolysis;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Moose;
use Proteolysis::Pool;
use Proteolysis::Types qw(Protease);
use MooseX::Types::Moose qw(Num);
use KiokuDB::Class;
use namespace::autoclean;

with qw(Proteolysis::Role::DH MooseX::Object::Pluggable);

has protease => (
    is       => 'rw',
    isa      => Protease,
    coerce   => 1,
    handles  => [qw(cleavage_sites)],
    traits   => [qw(KiokuDB::DoNotSerialize)],
    trigger  => \&_resort_pools,
);

has pool => (
    is      => 'ro',
    writer  => '_set_pool',
    traits  => [qw(KiokuDB::Lazy)],
    isa     => 'Proteolysis::Pool',
    clearer => 'clear_pool',
    handles => {
        clear_previous_pools => 'clear_previous',
    }
);

has detail_level => (
    is      => 'rw',
    isa     => Num,
    default => 1,
);

sub shift_pool {
    my $self = shift;
    my ( $first, $second ) = ( $self->pool, $self->pool->previous );
    return unless ( defined $second );
    $self->_set_pool($second);
    return $first;
}

sub add_pool {
    my ($self, $pool) = @_;

    my $previous = $self->pool;

    if (defined $previous) {
        $pool->previous($previous);
    }

    $self->_set_pool($pool);
}

sub digest {
    my ($self, $times) = @_;
    $times //= -1;

    $self->protease && $self->pool && $self->pool->substrates
        or return;

    my $d = int( 1 / $self->detail_level );

    while ($times) {

        my $did_cut = $self->_cut();
        last unless ($did_cut);

        my $skip = --$times % $d;

        if ($did_cut and !$skip) {
            my $new_pool = $self->pool->clone;
            $self->add_pool($new_pool);
        }
    }

    return 1;
}

sub _cut {
    my ( $self ) = @_;

    unless (%{$self->pool->substrates}) { return; }

    my ( $head, $tail ) = $self->_cut_random_fragment;

    ( $head and $tail ) or return;

    $self->pool->add_substrate($_) for ($head, $tail);

    return 1;

}

sub _cut_random_fragment {
    my $self = shift;
    my $pool = $self->pool;

    my $fragment  = _pick_random_substrate(\%{$pool->substrates});

    until ( $self->protease->is_substrate($fragment) ) {

        my $amount = $pool->delete_substrate($fragment);
        $pool->add_product( $fragment, $amount );

        return unless (%{$pool->substrates});

        $fragment = _pick_random_substrate(\%{$pool->substrates});
    }

    $pool->take_substrate( $fragment );

    my @sites = $self->protease->cleavage_sites( $fragment );
    my $site  = $sites[rand @sites];

    my $head = substr($fragment, 0, $site);
    my $tail = substr($fragment, $site);

    return $head, $tail;
}

sub _resort_pools {
    my ( $self, $protease) = @_;

    # A protease has been set, and we have all these pools that have
    # their peptides divided into "substrates" and "products".
    # Basically, review everything.
    my $pool = $self->pool // return;

    do {
        _resort_pool( $pool, $protease );
    } while ( $pool = $pool->previous );

}

sub _resort_pool {
    my ( $pool, $protease ) = @_;

    # Combine substrates and products into substrates.
    _merge(\%{$pool->substrates}, \%{$pool->products});

    # put all non-cleavable substrates into products.
    _filter_substrates($pool, $protease);
}

sub _merge {
    # Take two hash references that are assumed to be non nested and
    # contain numerical values. Leftmost hash will contain the sum of
    # the values of both hashes, and the rightmost hash will be left
    # empty.

    my ($left, $right) = @_;

    foreach my $key (keys %$left) {
        next unless (defined $right->{$key});
        $left->{$key} += $right->{$key};
        delete $right->{$key};
    }

    foreach my $key (keys %$right) {
        $left->{$key} = $right->{$key};
        delete $right->{$key};
    }

    return 1;
}

sub _filter_substrates {
    my ($pool, $protease) = @_;

    foreach my $s (keys %{$pool->substrates}) {
        next if ($protease->is_substrate($s));
        $pool->add_product($s => $pool->delete_substrate($s));
    }

    return 1;
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
