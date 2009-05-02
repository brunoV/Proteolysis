use MooseX::Declare;
use lib qw(/home/brunov/lib/Proteolysis/lib);

class Proteolysis::Fragment {
    use Moose::Util::TypeConstraints;
    use MooseX::Types::Moose qw(Int);
    use Proteolysis::Types qw(Protein);

    has 'parent_sequence' => (
        is       => 'ro',
        isa      => Protein,
        required => 1,
        coerce   => 1,
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

    method BUILD ($params) {
        unless ( $self->_has_start ) { $self->_set_start(1) };
        unless ( $self->_has_end ) {
            $self->_set_end( length $self->parent_sequence->seq )
        };
    }

    method seq {
        # Return the subsequence.

        my $start  = $self->start - 1;
        my $length = $self->end - $self->start + 1;
        my $seq    = substr( $self->parent_sequence->seq, $start, $length );

        return $seq;
    }
}

1;
