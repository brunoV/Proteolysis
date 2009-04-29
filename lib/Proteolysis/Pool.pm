use MooseX::Declare;
use lib qw(/home/brunov/lib/Proteolysis/lib);

class Proteolysis::Pool with Proteolysis::Role::WithHistory {
    use Proteolysis::Types qw(Set Pool);
    use KiokuDB::Util qw(set);
    use KiokuDB::Class;

    has 'substrates' => (
        is     => 'ro',
        isa    => Set,
        reader => '_substrates',
        lazy   => 1,
        default => sub { set() },
        handles => {
            add_substrate   => 'insert',
            substrates      => 'members',
            substrate_count => 'size',
        }
    );

    has 'products' => (
        is     => 'ro',
        isa    => Set,
        reader => '_products',
        lazy   => 1,
        default => sub { set() },
        handles => {
            add_product   => 'insert',
            products      => 'members',
            product_count => 'size',
        }
    );

    has '+previous' => (
        isa    => Pool,
        traits => [qw(KiokuDB::Lazy)],
    );

}

1;
