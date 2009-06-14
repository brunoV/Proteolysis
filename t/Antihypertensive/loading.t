use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;
use Moose::Util qw(does_role);

use ok 'Proteolysis';
use ok 'Proteolysis::Pool';

my $pool = Proteolysis::Pool->new;

my $flask = Proteolysis->new( protease => 'hcl', pool => $pool );

# We can load the plugin safely
lives_ok { $flask->load_plugin('Antihypertensive') };

# And the plugin applies the Pool plugin to all pools.
ok does_role($flask->pool, 'Proteolysis::Pool::Plugin::Antihypertensive');

# Also check that it applies to all subsequently added pools.
$flask->add_pool( Proteolysis::Pool->new );

lives_ok { $flask->load_plugin('Antihypertensive') };
ok does_role($flask->pool, 'Proteolysis::Pool::Plugin::Antihypertensive');
