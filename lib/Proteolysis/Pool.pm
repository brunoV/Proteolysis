use MooseX::Declare;
use lib qw(/home/brunov/lib/Proteolysis/lib);

class Proteolysis::Pool {
    use Proteolysis::Types qw(Set);
    use KiokuDB::Util qw(set);

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
}

1;
