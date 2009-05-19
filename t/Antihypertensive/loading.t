use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;
use Moose::Util qw(does_role);

use ok 'Proteolysis';
use ok 'Proteolysis::Pool';

my $flask = Proteolysis->new;

# We can load the plugin safely
lives_ok { $flask->load_plugin('Antihypertensive') };

my $pool = Proteolysis::Pool->new;
$flask->add_pool( $pool );

# And the plugin applies the Pool plugin to all pools.
ok does_role($flask->pool, 'Proteolysis::Pool::Plugin::Antihypertensive');

# Also check that it applies to all pre-existent pools.

$flask = Proteolysis->new;
$pool  = Proteolysis::Pool->new;

$flask->add_pool( $pool );

lives_ok { $flask->load_plugin('Antihypertensive') };
ok does_role($flask->pool, 'Proteolysis::Pool::Plugin::Antihypertensive');
