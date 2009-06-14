use Test::More qw(no_plan);
use lib qw(/home/brunov/lib/Proteolysis/lib);

{
    package Bogus;
    use Moose;
    with 'Proteolysis::Role::Length';
    use MooseX::Types::Moose qw(HashRef);

    has substrate_count => (
        is      => 'rw',
        default => 2,
    );

    has substrates => (
        is      => 'rw',
        isa     => HashRef,
        default => sub { {'AAA' => 1, 'A' => 1} },
    );

}

my $bogus = Bogus->new;

isa_ok $bogus, 'Bogus';

is $bogus->mean_length, 2, 'Mean';
is $bogus->min_length,  1, 'Min';
is $bogus->max_length,  3, 'Max';

my %dist = $bogus->length_distribution([sort $bogus->length_stats->get_data]);
is_deeply( \%dist, { 1 => 1, 3 => 1 } );

my $stats = $bogus->length_stats;
isa_ok $stats, 'Statistics::Descriptive::Full';
