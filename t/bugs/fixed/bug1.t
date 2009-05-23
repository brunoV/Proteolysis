use Test::More qw(no_plan);
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Proteolysis;
use Proteolysis::Pool;

my $flask = Proteolysis->new( protease => 'trypsin' );
my $pool = Proteolysis::Pool->new;
$pool->add_substrate( 'MAEERRRRRRLLEEKKELLAKKCKVKAKA', 1 );
$flask->add_pool( $pool );

$flask->digest;

is $flask->pool->substrate_count, 0;

$flask->protease('hcl');

ok $flask->pool->substrate_count > 0;
ok $flask->pool->product_count   > 0;

$flask->digest;

is $flask->dh, 100;
