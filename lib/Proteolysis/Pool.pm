use MooseX::Declare;
use lib qw(/home/brunov/lib/Proteolysis/lib);

class Proteolysis::Pool
    with Proteolysis::Role::WithHistory
    with Proteolysis::Role::Length
    with MooseX::Object::Pluggable {

    use Proteolysis::Types   qw(Pool Fragment);
    use MooseX::Types::Moose qw(ArrayRef);
    use KiokuDB::Class;

    has 'substrates' => (
        is         => 'rw',
        isa        => ArrayRef,
        metaclass  => 'Collection::Array',
        lazy       => 1,
        auto_deref => 1,
        traits     => [qw(KiokuDB::Lazy)],
        default    => sub { [] },
        provides   => {
            count  => 'substrate_count',
            push   => 'add_substrate',
        }

    );

    has 'products' => (
        is         => 'rw',
        isa        => ArrayRef,
        metaclass  => 'Collection::Array',
        lazy       => 1,
        auto_deref => 1,
        traits     => [qw(KiokuDB::Lazy)],
        default    => sub { [] },
        provides   => {
            count  => 'product_count',
            push   => 'add_product',
        }

    );

    has '+previous' => (
        isa      => Pool,
        traits   => [qw(KiokuDB::Lazy)],
    );

    method count {
        return $self->substrate_count + $self->product_count;
    }

}

1;
