use MooseX::Declare;

class Proteolysis::Fragment {
    use Moose::Util::TypeConstraints;
    use MooseX::Types::Moose qw(ScalarRef Int Str);
    use Proteolysis::Types qw(Protein);

    has 'parent_sequence' => (
        is       => 'ro',
        isa      => Protein,
        required => 1,
        coerce   => 1,
    );

    has [ 'start', 'end' ] => (
        is       => 'ro',
        required => 1,
        isa      => Int,
    );

    method seq {
        # Return the subsequence.

        my $start  = $self->start - 1;
        my $length = $self->end - $self->start + 1;
        my $seq    = substr( $self->parent_sequence->seq, $start, $length );

        return $seq;
    }
}

1;
