use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis::Pool;
use Proteolysis::Fragment;
use Bio::Protease;

use ok 'Proteolysis';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';
my $trypsin = Bio::Protease->new(specificity => 'trypsin');

my $flask = Proteolysis->new(
    protease        => 'trypsin',
);

isa_ok $flask,                 'Proteolysis';
isa_ok $flask->protease,       'Bio::Protease';

my $pool = Proteolysis::Pool->new;

$pool->add_substrate(
    Proteolysis::Fragment->new(
        parent_sequence => $seq,
        start           => 1,
        end             => length $seq,
    )
);

$flask->add_pool($pool);

lives_ok { $flask->digest } "lived through infinite digestion";

# Check that the products are identical to those obtained with
# Bio::Protease.

my @correct_products = sort $trypsin->digest($seq);
my @products         = sort map { $_->seq } $flask->pool->products;

is_deeply \@products, \@correct_products, "products returned are ok";

lives_ok { $flask->clear_pool };


# Check clearing history.
isa_ok $flask->pool,            'Proteolysis::Pool';
ok     !$flask->pool->previous;
