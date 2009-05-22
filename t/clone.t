use Test::More qw(no_plan);
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Proteolysis::Pool;
use Scalar::Util qw(refaddr);

my $pool       = Proteolysis::Pool->new;
my $other_pool = Proteolysis::Pool->new;

$pool->previous($other_pool);

$pool->add_substrate('foo');
$pool->add_product  ('bar');

$pool->length_stats;

my $copy = $pool->clone;

isnt( refaddr($pool), refaddr($copy) );

isnt( refaddr($pool->products),   refaddr($copy->products) );
isnt( refaddr($pool->substrates), refaddr($copy->substrates) );

is $pool->previous, $other_pool;
is $copy->previous, undef;

isnt( refaddr($pool->length_stats), refaddr($copy->length_stats) );
