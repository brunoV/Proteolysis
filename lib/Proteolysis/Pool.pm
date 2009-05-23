package Proteolysis::Pool;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Moose;
use Proteolysis::Types   qw(Pool Fragment);
use MooseX::Types::Moose qw(HashRef);
use KiokuDB::Class;
use namespace::clean -except => 'meta';
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

    if ( $self->substrate_exists($s) ) {
        $self->_set_substrate($s => $self->amount_of_substrate($s) - $amount);

        if ( $self->amount_of_substrate($s) <= 0 ) {
            $self->delete_substrate($s)
        }

        return $s;
    }
    else { return }
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

sub take_random_substrate {
    my $self = shift;

    my $substrate = _pick_random_substrate(\%{$self->substrates});
    $self->take_substrate($substrate);
    return $substrate;
}

sub clone {
    my $self = shift;

    my $copy = __PACKAGE__->new;

    $copy->substrates( {%{$self->substrates}} );
    $copy->products  ( {%{$self->products  }} );

    #my $copy = dclone $self;

    #$copy->clear_previous;
    #$copy->clear_length_stats;

    return $copy;
}

use Inline C => <<'END_OF_C_CODE';

main() {
    srand(time(0));
}

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

END_OF_C_CODE

__PACKAGE__->meta->make_immutable;
1;
