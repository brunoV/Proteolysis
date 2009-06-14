use Test::More qw(no_plan);
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Proteolysis::Pool;

my $pool = Proteolysis::Pool->new(
    substrates => { A => 1, AA => 1, AAA => 1, AAAA => 1 }
);

is $pool->mean_length, 2.5;
is $pool->min_length,  1;
is $pool->max_length,  4;
