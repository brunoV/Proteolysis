package Proteolysis::Role::Length;
use Moose::Role;
use Statistics::Descriptive;
use namespace::autoclean;

has length_stats => (
    is         => 'ro',
    lazy_build => 1,
    clearer    => 'clear_length_stats',
    handles    => {
        mean_length         => 'mean',
        max_length          => 'max',
        min_length          => 'min',
        length_distribution => 'frequency_distribution',
    }
);

sub _build_length_stats {
    my $self = shift;

    my $stats = Statistics::Descriptive::Full->new;

    my @data;

    no warnings 'uninitialized';
    while ( my ( $p, $a ) = each %{$self->substrates}) {
        for ( 1 .. $a ) { push @data, length($p) }
    }

    $stats->add_data(@data);

    return $stats;
}

1;
