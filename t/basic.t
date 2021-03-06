use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis::Pool;
use Bio::Protease;
use List::MoreUtils qw(uniq);

use ok 'Proteolysis';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $pool = Proteolysis::Pool->new(
    substrates => { $seq => 1 }
);

my $hcl = Bio::Protease->new(specificity => 'hcl');

my $flask = Proteolysis->new( protease => $hcl, pool => $pool );

isa_ok $flask,           'Proteolysis';
isa_ok $flask->protease, 'Bio::Protease';

lives_ok { $flask->digest() } "lived through infinite digestion";

my @correct_products = uniq sort $hcl->digest($seq);
my @products         = sort keys %{$flask->pool->substrates};

is_deeply(\@products, \@correct_products);

# Some edge case checking
undef for ($flask, $pool);

$flask = Proteolysis->new(
    protease => 'hcl',
    pool     => Proteolysis::Pool->new( substrates => { } ),
);

lives_ok { $flask->digest } 'digest with empty pool lives';

lives_ok { $flask->detail_level(0.25) } 'Valid detail level';

throws_ok { $flask->detail_level(5) } qr/Quotient should be a number/;
