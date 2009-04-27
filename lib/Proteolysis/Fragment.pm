use MooseX::Declare;

class Proteolysis::Fragment {
    use Moose::Util::TypeConstraints;
    use MooseX::Types::Moose qw(ScalarRef Int Str);

    has 'parent_sequence' => (
        is       => 'ro',
        isa      => ScalarRef,
        required => 1,
        coerce   => 1,
    );

    coerce ScalarRef, from Str, via { \$_ };

    has [ 'start', 'end' ] => (
        is       => 'ro',
        required => 1,
        isa      => Int,
    );

    method seq {
        # Return the subsequence.

        my $start  = $self->start - 1;
        my $length = $self->end - $self->start + 1;
        my $seq    = substr( ${ $self->parent_sequence }, $start, $length );

        return $seq;
    }
}

1;
