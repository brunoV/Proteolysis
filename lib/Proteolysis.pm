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
    traits   => [qw(KiokuDB::DoNotSerialize)]
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

    if ($previous) {
        $pool->previous($previous);
    }

    $self->_set_pool($pool);
}

sub digest {
    my ($self, $times) = @_;
    $times //= -1;

    $self->protease or return;
    my $d = int( 1 / $self->detail_level );

    while ($times) {
        my ( $s, $p, $did_cut ) = $self->_cut( $self->pool );

        my $pool = Proteolysis::Pool->new;
        $pool->add_substrate(@$s);
        $pool->add_product  (@$p);

        my $skip = $times % $d;

        if ($did_cut) {
            --$times;

            if ($skip) {
                $self->shift_pool;
                $self->add_pool($pool);
            }
            else {
                $self->add_pool($pool);
            }
        }
        else {
            $self->shift_pool;
            $self->add_pool($pool);
        }

        return if ( !@$s );
    }

    return 1;

}

sub _cut {
    my ( $self, $pool ) = @_;

    my @products   = $pool->products;
    my @substrates = $pool->substrates;

    unless (@substrates) {
        return \@substrates, \@products, undef;
    }

    my ( $fragment, @sites ) = _cut_random_fragment(
        \@substrates, \@products, $self->protease
    );

    if ( !@sites ) {
        push @products, $fragment;
        return \@substrates, \@products, undef;
    }

    my $idf = int rand @sites;

    my $head = Proteolysis::Fragment->new(
        parent_sequence => $fragment->parent_sequence,
        start           => $fragment->start,
        end             => $sites[$idf] + $fragment->start - 1,
    );

    my $tail = Proteolysis::Fragment->new(
        parent_sequence => $fragment->parent_sequence,
        start           => $sites[$idf] + $fragment->start,
        end             => $fragment->end,
    );

    push @substrates, ( $head, $tail );

    return \@substrates, \@products, 1;
}

sub _cut_random_fragment {
    my ( $substrates, $products, $protease ) = @_;

    my $ids = int rand @$substrates;
    my $fragment = splice @$substrates, $ids, 1;

    my @sites = $protease->cleavage_sites( $fragment->seq );

    return ( $fragment, @sites );
}

__PACKAGE__->meta->make_immutable;
1;
