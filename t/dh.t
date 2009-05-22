use Test::More qw(no_plan);
use Modern::Perl;
use lib qw(/home/brunov/lib/Proteolysis/lib);

use ok 'Proteolysis';

my $seq   = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';
my $flask = Proteolysis->new( protease => 'hcl' );

my $pool  = Proteolysis::Pool->new();

$pool->add_substrate($seq);

$flask->add_pool($pool);

#$flask->add_pool($pool->clone);
#
#is $flask->pool->number,                1;
#is $flask->pool->previous->number,      0;
#is $flask->_get_pool_number(0)->number, 0;
#is $flask->_get_first_pool->number, 0;


is $flask->dh, 0, 'DH before digesting is 0';
is $flask->pool->mean_length, 28;

$flask->digest();

is $flask->dh, 100, 'DH after full digest is 100';
ok $flask->pool->product_count != $flask->pool->previous->product_count;

my $p = $flask->pool;

do {
    say $p->count;
} while ( $p = $p->previous );
