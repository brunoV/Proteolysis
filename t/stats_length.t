use Test::More qw(no_plan);
use lib qw(/home/brunov/lib/Proteolysis/lib);
use MooseX::Declare;
use Devel::SimpleTrace;

class Thing {
    has length => (
        is      => 'rw',
        default => 5,
    );
}

class Bogus with Proteolysis::Stats::Length {
    has [qw(substrate_count product_count)] => (
        is      => 'rw',
        default => 1,
    );

    has [qw(substrates products)] => (
        is      => 'rw',
        isa     => 'Thing',
        default => sub { Thing->new },
    );
}

my $bogus = Bogus->new;

isa_ok $bogus, 'Bogus';

isa_ok $bogus->substrates, 'Thing';
isa_ok $bogus->products,   'Thing';

is     $bogus->substrates->length, 5;
is     $bogus->products  ->length, 5;

$bogus->products->length(1);

is $bogus->products->length, 1;

is $bogus->mean_length, 3, 'Mean';
is $bogus->min_length,  1, 'Min';
is $bogus->max_length,  5, 'Max';
is $bogus->count,       2, 'Count';

my %dist = $bogus->length_distribution(2);
is_deeply( \%dist, { 1 => 1, 5 => 1 } );

my $stats = $bogus->length_stats;
isa_ok $stats, 'Statistics::Descriptive::Full';
