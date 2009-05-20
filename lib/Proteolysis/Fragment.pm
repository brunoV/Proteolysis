package Proteolysis::Fragment;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Int);
use Proteolysis::Types qw(Protein);
use namespace::clean -except => 'meta';

has 'parent_sequence' => (
    is       => 'ro',
    isa      => Protein,
    required => 1,
);

has start => (
    is        => 'ro',
    writer    => '_set_start',
    isa       => Int,
    predicate => '_has_start',
);

has end => (
    is        => 'ro',
    writer    => '_set_end',
    isa       => Int,
    predicate => '_has_end',
);

sub BUILD {
    my ($self, $params) = @_;
    unless ( $self->_has_start ) { $self->_set_start(1) };
    unless ( $self->_has_end ) {
        $self->_set_end( length $self->parent_sequence )
    };
}

sub seq {
    # Return the subsequence.

    my $self   = shift;

    my $start  = $self->start - 1;
    my $length = $self->length;
    my $seq    = substr( $self->parent_sequence, $start, $length );

    return $seq;
}

sub length {
    # return the fragment length

    my $self = shift;

    return $self->end - $self->start + 1;
}


__PACKAGE__->meta->make_immutable;
1;
