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
    protein         => $seq,
);

isa_ok $flask,                 'Proteolysis';
isa_ok $flask->protease,       'Bio::Protease';
isa_ok $flask->protein_object, 'Bio::Seq';
is     $flask->protein,        $seq,            'protein sequence is ok';

my $pool = Proteolysis::Pool->new;

$pool->add_substrate(
    Proteolysis::Fragment->new(
        parent_sequence => $flask->protein,
        start           => 1,
        end             => length $flask->protein,
    )
);

$flask->add_pool($pool);

lives_ok { $flask->digest } "lived through infinite digestion";

# Check that the products are identical to those obtained with
# Bio::Protease.

my @correct_products = sort $trypsin->digest($seq);
my @products         = sort map { $_->seq } $flask->pool->products;

is_deeply \@products, \@correct_products, "products returned are ok";

#while ( my $pool = $flask->shift_pool ) {
#
#    say "new timestep---*";
#
#    say "substrates:";
#    say "\t", $_->seq for $pool->substrates;
#
#    say "products:";
#    say "\t", $_->seq for $pool->products;
#}
