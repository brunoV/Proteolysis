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

__END__

=pod

=head1 NAME

Proteolysis - Partial proteolysis simulation and anaysis

=head1 DESCRIPTION

This module aids in the simulation of enzymic cleavage of protein
substrates and in the analysis of its results.

It supports partial cleavage of multiple protein substrates
simultaneously, and serialization of the results by writing to a
database for further statistical analysis.

Cleavage is done using Bio::Protease, a module that supports more than
30 endonuclease specificities, and also supports customized specificity
models.

Substrates are considered to be proteins of known sequence (although
having it is not mandatory), so any sequence information in the
substrates is transferred to the products. This allows for
sequence-dependent analysis of results, such as ocurrence bioactive
peptides.

=head1 SYNOPSIS

    # Instantiate the main Proteolysis digestor object, with a single
    # substrate molecule of sequence $seq.
    my $flask = Proteolysis->new(
        protease => 'trypsin',
        pool     => Proteolysis::Pool->new( substrates => { $seq => 1 }),
    }

    # Perform a full digestion.
    $flask->digest;

    # Retrieve the results for the final state:

    my %substrates = $flask->pool->substrates;

    # To get the substrates of previous snapshots in time, you can
    # traverse the reaction (advance?) backwards by calling "previous"

    %old_substrates = $flask->pool->previous->substrates;

    # A "Pool" is a point in time of the proteolytic reaction, contained
    # in the main Proteolysis object. It has information of all the
    # products, and also has useful analytical methods.

    my $pool = $flask->pool;

    # Get the degree of hydrolysis achieved
    $pool->dh;

    # Inspect the minimum, mean, and maximum length of the products.

    my $min  = $pool->min_length;
    my $mean = $pool->mean_length;
    my $max  = $pool->max_length;

    # Pools and Proteolysis objects are pluggable. One such plugins is
    # Antihypertensive, that analyzes presence of ACE-inhibitory
    # peptides among the peptidic products.

    $pool->load_plugin("Antihypertensive");
    my $antihypertensive_power = $pool->mean_inverse_ace;

    # Lastly, results can be easily serialized using Proteolysis::DB,
    # which is a wrapper around KiokuDB that used the BerkeleyDB
    # backend.

    my $db = Proteolysis::DB->new;
    my $s = $db->new_scope;

    my $id = $db->store($flask) # $flask stored in database.

    undef $flask;

    $flask = $db->lookup($id);

=head1 METHODS

=over 4

=item new

    my $flask = Proteolysis->new( pool => $pool, protease => $protease );

Constructor. Requires that values for C<pool> and C<protein> are passed:

=item digest

    $flask->digest($n);

Digest the latest pool cutting $n bonds. Returns true if successful,
false if there are no more siscile bonds left in the substrate pool. If
the argument is omitted, will digest the substrate pool until
completion.

=back

=head1 ATTRIBUTES

=over 4

=item pool

Required. A L<Proteolysis::Pool> object that defines the initial state
of the substrate mix.

=item protease

Required. A L<Bio::Protease> object that defines the specificity with which
the substrates will be cleaved. Alternatively, a string can be passed
that matches any of the 32 built-in specificities of L<Bio::Protease>.

=item detail_level

A number between 0 and 1 that defines the granularity with which the
time snapshots are saved. With a value of 1, a new pool is saved after
each cleavage is done; with 0.5, a pool is saved once every two cuts,
and so forth.

Defaults to 1, so consider changing it to a lower value in the case that
the pool contains many cleavable bonds Defaults to 1, so consider
changing it to a lower value in the case that the pool contains many
cleavable bonds.

=back

=cut
