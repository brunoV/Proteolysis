use MooseX::Declare;
use lib qw(/home/brunov/lib/Proteolysis/lib);

class Proteolysis {
    use Proteolysis::Pool;
    use Proteolysis::Types qw(Set Protease Protein);
    use MooseX::Types::Common::Numeric qw(PositiveInt);
    use MooseX::Types::Moose qw(Str);
    use KiokuDB::Util qw(set);

    has protease => (
        is       => 'ro',
        isa      => Protease,
        required => 1,
        coerce   => 1,
        handles  => [qw(cleavage_sites)],
    );

    has protein => (
        is       => 'ro',
        isa      => Protein,
        reader   => 'protein_object',
        required => 1,
        handles  => {
            'protein' => 'seq',
        },
        coerce   => 1,
    );

    has pools => (
        is      => 'ro',
        reader  => '_pools',
        default => sub { set() },
        isa     => Set,
        handles => {
            'pools'       => 'members',
            'add_pool'    => 'insert',
            'pool_count'  => 'size',
            'remove_pool' => 'remove',
        }
    );

    after add_pool ($pool) {
        $self->_latest_pool($pool);
    }

    has _latest_pool => (
        is         => 'rw',
        isa        => 'Proteolysis::Pool',
        lazy_build => 1,
    );

    method _build__latest_pool {
        # If called and empty, build a pool with one molecule
        # of "protein" attr.

        my $pool     = Proteolysis::Pool->new;
        my $fragment = Proteolysis::Fragment->new(
            parent_sequence => $self->protein,
            start           => 1,
            end             => length $self->protein,
        );

        $pool->add_substrate($fragment);
        return $pool;
    }


    method digest (PositiveInt $times = 1) {

        while ($times) {
            my ($s, $p, $did_cut) = $self->_cut($self->_latest_pool);

            my $pool = Proteolysis::Pool->new;
            $pool->add_substrate($_) for @$s;
            $pool->add_product($_)   for @$p;

            if ($did_cut) {
                $self->add_pool($pool);
                --$times;
            }
            else {
                $self->_latest_pool($pool);
            }


            last if (!@$s);
        }

    }

    method _cut ($pool) {
        my @products   = $pool->products;
        my @substrates = $pool->substrates;

        unless (@substrates) {
            return \@substrates, \@products, undef;
        }

        my ($fragment, @sites) = _cut_random_fragment(\@substrates, \@products, $self->protease);

        if (!@sites) {
            push @products, $fragment;
            return \@substrates, \@products, undef
        };


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
        my ($substrates, $products, $protease) = @_;

        my $ids        = int rand @$substrates;
        my $fragment   = splice @$substrates, $ids, 1;

        my @sites = $protease->cleavage_sites( $fragment->seq );

        return ($fragment, @sites);
    }

}

1;
