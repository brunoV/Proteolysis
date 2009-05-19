use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use MooseX::Declare;

class Thing {
    has seq => (
        is      => 'rw',
        default => 'IKP',
    );
}

class Bogus with MooseX::Object::Pluggable {
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

$bogus->_plugin_app_ns(['Proteolysis::Pool']);
$bogus->load_plugin('Antihypertensive');

is $bogus->substrates->seq, 'IKP';
is $bogus->products  ->seq, 'IKP';

   $bogus->products->seq( 'LEP' );
is $bogus->products->seq, 'LEP'  ;

is $bogus->ace('IKP'), 4.265;
is $bogus->ace('LEP'), 1.90546071796325;

ok $bogus->is_hypertensive('IKP');
is $bogus->mean_ace,  3.08523035898163, 'Mean';
is $bogus->min_ace,   1.90546071796325, 'Min';
is $bogus->max_ace,   4.265,            'Max';
is $bogus->ace_count, 2,                'Count';

my %dist = $bogus->ace_distribution([ sort $bogus->ace_stats->get_data ]);

is_deeply \%dist, { 1.90546071796325, => 1, 4.265 => 1 }, 'F. Distribution';

isa_ok $bogus->ace_stats, 'Statistics::Descriptive::Full';
