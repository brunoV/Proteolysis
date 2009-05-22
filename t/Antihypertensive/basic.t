use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;
use MooseX::Declare;

use Proteolysis::Pool;

my $pool = Proteolysis::Pool->new;
$pool->add_substrate('IKP');
$pool->add_product  ('LEP');

$pool->_plugin_app_ns(['Proteolysis::Pool']);
lives_ok { $pool->load_plugin('Antihypertensive') };

is $pool->ace('IKP'), 4.265;
is $pool->ace('LEP'), 1.90546071796325;

ok $pool->is_hypertensive('IKP');
is $pool->mean_ace,  3.08523035898163, 'Mean';
is $pool->min_ace,   1.90546071796325, 'Min';
is $pool->max_ace,   4.265,            'Max';
is $pool->ace_count, 2,                'Count';

my %dist = $pool->ace_distribution([ sort $pool->ace_stats->get_data ]);

is_deeply \%dist, { 1.90546071796325, => 1, 4.265 => 1 }, 'F. Distribution';

isa_ok $pool->ace_stats, 'Statistics::Descriptive::Full';
