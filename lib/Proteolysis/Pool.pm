use MooseX::Declare;
use lib qw(/home/brunov/lib/Proteolysis/lib);

class Proteolysis::Pool {
    use Proteolysis::Types qw(Set Pool);
    use MooseX::Types::Common::Numeric qw(PositiveInt);
    use KiokuDB::Util qw(set);
    use KiokuDB::Class;

    has previous => (
        is       => 'rw',
        isa      => Pool,
        traits   => [qw(KiokuDB::Lazy)],
        triggers => sub { shift->_increase_number(@_) },
    );

    has number => (
        is  => 'rw',
        isa => PositiveInt,
    );

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

    method _increase_number ($previous) {
        my $prev_no = $previous->number;
        $prev_no //= '0';

        $self->number(++$prev_no);
    }

}

1;
