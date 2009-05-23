package Proteolysis;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Moose;
use Proteolysis::Pool;
use Proteolysis::Types qw(Protease);
use MooseX::Types::Moose qw(Num);
use KiokuDB::Class;
use namespace::clean -except => 'meta';

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

        --$times;
        my $skip = $times % $d;

        if ($did_cut and !$skip) {
            my $new_pool = $self->pool->clone;
            $self->add_pool($new_pool);
        }
    }

    return 1;
}

sub _cut {
    my ( $self ) = @_;

    unless (%{$self->pool->substrates}) {
        return;
    }

    while (1) {
        my ( $fragment, $site ) = $self->_cut_random_fragment();

        if ( !%{$self->pool->substrates} and !$site ) {
            $self->pool->add_product($fragment);
            return 0;
        }

        if ( !$site ) {
            $self->pool->add_product($fragment);
            next;
        }

        my $head = substr($fragment, 0, $site);
        my $tail = substr($fragment, $site);

        $self->pool->add_substrate($_) for ($head, $tail);
        return 1;
   };

}

sub _cut_random_fragment {
    # This looks ok.
    my $self = shift;

    my $fragment = $self->pool->take_random_substrate;
    my @sites = $self->protease->cleavage_sites( $fragment );
    my $site  = $sites[rand @sites];

    return ( $fragment, $site );
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

__PACKAGE__->meta->make_immutable;
1;
