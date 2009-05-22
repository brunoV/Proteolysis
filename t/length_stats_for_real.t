use Test::More qw(no_plan);
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Proteolysis::Pool;

my @seqs = qw(A AA AAA AAAA);

my $pool = Proteolysis::Pool->new;

$pool->add_substrate($_) for @seqs;

is $pool->mean_length, 2.5;
is $pool->min_length,  1;
is $pool->max_length,  4;
