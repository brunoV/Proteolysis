use Test::More qw(no_plan);
use Modern::Perl;
use lib qw(/home/brunov/lib/Proteolysis/lib);

use ok 'Proteolysis';
use Proteolysis::Pool;

my $seq   = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';
my $pool  = Proteolysis::Pool->new(
    substrates => { $seq => 1 },
);

my $flask = Proteolysis->new( protease => 'hcl', pool => $pool );

is $flask->dh, 0, 'DH before digesting is 0';
is $flask->pool->mean_length, 28;

$flask->digest();

is $flask->dh, 100, 'DH after full digest is 100';
ok $flask->pool->substrate_count != $flask->pool->previous->substrate_count;
