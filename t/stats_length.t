use Test::More qw(no_plan);
use lib qw(/home/brunov/lib/Proteolysis/lib);

{
    package Bogus;
    use Moose;
    with 'Proteolysis::Role::Length';
    use MooseX::Types::Moose qw(HashRef);

    has [qw(substrate_count product_count)] => (
        is      => 'rw',
        default => 1,
    );

    has substrates => (
        is      => 'rw',
        isa     => HashRef,
        default => sub { {'AAA' => 1} },
    );

    has products => (
        is      => 'rw',
        isa     => HashRef,
        default => sub { {'A' => 1} },
    );

    sub amount_of_substrate {
        return 1;
    }

    sub amount_of_product {
        return 1;
    }

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
