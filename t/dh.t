use Test::More qw(no_plan);
use Modern::Perl;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Devel::SimpleTrace;

use ok 'Proteolysis';
use ok 'Proteolysis::Pool';
use ok 'Proteolysis::Fragment';

my $seq   = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';
my $flask = Proteolysis->new( protease => 'hcl' );

my $pool = Proteolysis::Pool->new();

$pool->add_substrate(
    Proteolysis::Fragment->new( parent_sequence => $seq )
);

$flask->add_pool($pool);

is $flask->dh, 0, 'DH before digesting is 0';

$flask->digest;

is $flask->dh, 100, 'DH after full digest is 100';
