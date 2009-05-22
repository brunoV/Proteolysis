use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis::Pool;
use Bio::Protease;
use List::MoreUtils qw(uniq);

use ok 'Proteolysis';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';
my $hcl = Bio::Protease->new(specificity => 'hcl');

my $flask = Proteolysis->new(
    protease        => $hcl,
);

isa_ok $flask,                 'Proteolysis';
isa_ok $flask->protease,       'Bio::Protease';

my $pool = Proteolysis::Pool->new;

$pool->add_substrate($seq);

$flask->add_pool($pool);

lives_ok { $flask->digest() } "lived through infinite digestion";

my @correct_products = uniq sort $hcl->digest($seq);
my @products         = sort keys %{$flask->pool->products};

is_deeply(\@products, \@correct_products);

lives_ok { $flask->clear_previous_pools };


# Check clearing history.
isa_ok  $flask->pool,            'Proteolysis::Pool';
ok     !$flask->pool->previous;
