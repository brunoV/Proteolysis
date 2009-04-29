use MooseX::Declare;

class Proteolysis::DB extends KiokuX::Model {

    has '+dsn'        => ( default => 'dbi:SQLite:dbname=db' );
    has '+extra_args' => ( default => sub { { connect => 1 } } );

}
