use MooseX::Declare;

role Proteolysis::Role::Length {

    use Statistics::Descriptive;

    has length_stats => (
        is         => 'ro',
        lazy_build => 1,
        traits     => [qw(KiokuDB::DoNotSerialize)],
        handles    => {
            mean_length         => 'mean',
            max_length          => 'max',
            min_length          => 'min',
            length_distribution => 'frequency_distribution',
        }
    );

    method length {
        my $length_stats = $self->length_stats;
        return $length_stats->mean;
    }

    method _build_length_stats {
        my $stats = Statistics::Descriptive::Full->new;

        $stats->add_data(
            map { $_->length } ( $self->substrates, $self->products )
        );

        return $stats;
    }

}
