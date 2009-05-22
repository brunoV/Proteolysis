package Proteolysis::Role::WithHistory;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Moose::Role;;
use Modern::Perl;
use MooseX::Types::Common::Numeric qw(PositiveInt);
use Proteolysis::Types qw(Pool);
use namespace::clean -except => 'meta';

has previous => (
    is       => 'rw',
    trigger  => sub { shift->_increase_number(@_) },
    clearer  => 'clear_previous',
);

has number => (
    is      => 'rw',
    isa     => PositiveInt,
    default => 0,
);

sub _increase_number {
    my ($self, $previous) = @_;

    my $prev_no = $previous->number;
    $prev_no  //= '0';

    $self->number(++$prev_no);
}

1;
