package Proteolysis::Role::Length;
use Moose::Role;
use Statistics::Descriptive;
use MooseX::Types::Moose qw(Num);
use namespace::autoclean;

has length_stats => (
    is         => 'ro',
    lazy_build => 1,
    handles    => {
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

# The reason to add all this attributes is to be able to cache the final
# result instead of having the Statistics::Descriptive object (which
# contains a copy of all of the data) be loaded every time a simple
# statistical metric is wanted. For more complicated things like
# frequency distributions which change upon user-defined parameters, the
# full data has to be loaded.

has mean_length => (
    is   => 'ro',
    isa  => Num,
    lazy => 1,
    default => sub { shift->length_stats->mean },
);

has max_length => (
    is   => 'ro',
    isa  => Num,
    lazy => 1,
    default => sub { shift->length_stats->max },
);

has min_length => (
    is   => 'ro',
    isa  => Num,
    lazy => 1,
    default => sub { shift->length_stats->min },
);

1;
