use MooseX::Declare;

class Proteolysis::DB extends KiokuX::Model {
    use KiokuDB::TypeMap;
    use KiokuDB::TypeMap::Entry::Naive;

    has '+dsn'        => ( default => 'dbi:SQLite:dbname=db' );
    has '+extra_args' => (
        default => sub { {
            create  => 1,
            typemap => KiokuDB::TypeMap->new(
                isa_entries => {
                    "Bio::Root::Root" => KiokuDB::TypeMap::Entry::Naive->new,
                }
            ),
        } }
    );
}
