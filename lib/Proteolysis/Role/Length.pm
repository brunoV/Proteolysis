package Proteolysis::Role::Length;
use Moose::Role;
use Statistics::Descriptive;
use namespace::clean -except => 'meta';

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

sub length {
    my $self = shift;

    my $length_stats = $self->length_stats;
    return $length_stats->mean;
}

sub _build_length_stats {
    my $self = shift;

    my $stats = Statistics::Descriptive::Full->new;

    $stats->add_data(
        map { $_->length } ( $self->substrates, $self->products )
    );

    return $stats;
}

1;
