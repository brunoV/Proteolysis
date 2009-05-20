use MooseX::Declare;
use lib qw(/home/brunov/lib/Proteolysis/lib);

class Proteolysis
    with Proteolysis::Role::DH with MooseX::Object::Pluggable {

    use Proteolysis::Pool;
    use Proteolysis::Types qw(Protease);
    use MooseX::Types::Moose qw(Num);
    use KiokuDB::Class;

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

    method shift_pool {
        my ( $first, $second ) = ( $self->pool, $self->pool->previous );
        return unless ( defined $second );
        $self->_set_pool($second);
        return $first;
    }

    method add_pool ( $pool! ) {
        my $previous = $self->pool;

        if ($previous) {
            $pool->previous($previous);
        }

        $self->_set_pool($pool);
    }

    method digest ( Num $times = -1 ) {

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

    method _cut ($pool) {
        my @products   = $pool->products;
        my @substrates = $pool->substrates;

        unless (@substrates) {
            return \@substrates, \@products, undef;
        }

        my ( $fragment, $site ) = _cut_random_fragment(
            \@substrates, \@products, $self->protease
        );

        if ( !$site ) {
            push @products, $fragment;
            return \@substrates, \@products, undef;
        }

        my $head = Proteolysis::Fragment->new(
            parent_sequence => $fragment->parent_sequence,
            start           => $fragment->start,
            end             => $site + $fragment->start - 1,
        );

        my $tail = Proteolysis::Fragment->new(
            parent_sequence => $fragment->parent_sequence,
            start           => $site + $fragment->start,
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

        my $site  = $sites[rand @sites];

        return ( $fragment, $site );
    }

}
