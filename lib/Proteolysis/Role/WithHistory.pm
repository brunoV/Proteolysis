use MooseX::Declare;
use Modern::Perl;

role Proteolysis::Role::WithHistory {
    use MooseX::Types::Common::Numeric qw(PositiveInt);
    use Proteolysis::Types qw(Pool);

    has previous => (
        is       => 'rw',
        isa      => Pool,
        trigger  => sub { shift->_increase_number(@_) },
        clearer  => 'clear_previous',
    );

    has number => (
        is      => 'rw',
        isa     => PositiveInt,
        default => 0,
    );

    method _increase_number ($previous) {
        my $prev_no = $previous->number;
        $prev_no  //= '0';

        $self->number(++$prev_no);
    }

}

1;
