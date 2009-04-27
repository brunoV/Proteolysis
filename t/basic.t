use lib qw(/home/brunov/lib/Proteolysis/lib);
use Modern::Perl;
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis::Pool;
use Proteolysis::Fragment;

use ok 'Proteolysis';

my $flask = Proteolysis->new(
    protease        => 'trypsin',
    protein         => 'MAAAEELLKRKARPYWGGNGCCVIKPWR',
);

isa_ok $flask,                 'Proteolysis';
isa_ok $flask->protease,       'Bio::Protease';
isa_ok $flask->protein_object, 'Bio::Seq';
is     $flask->protein,        'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $pool = Proteolysis::Pool->new;
$pool->add_substrate(
    Proteolysis::Fragment->new(
        parent_sequence => $flask->protein,
        start           => 1,
        end             => length $flask->protein,
    )
);


lives_ok { $flask->_latest_pool };
isa_ok $flask->_latest_pool, 'Proteolysis::Pool';

lives_ok { $flask->digest(300) };

my @pools = $flask->pools;

my @fragments;
push @fragments, $pool->substrates;
push @fragments, $pool->products;

foreach my $pool (@pools) {
    say '---new pool---';
    foreach my $fragment ($pool->substrates, $pool->products) {
        say $fragment->seq,
    }
}

my $last_pool = $flask->_latest_pool;

say '--- last pool ---';
foreach my $fragment ($last_pool->substrates, $last_pool->products) {
    say $fragment->seq;
}
