use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use KiokuDB::Backend::Hash;
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis;
use Proteolysis::Pool;
use Proteolysis::Fragment;

use ok 'Proteolysis::DB';

unlink 'db';

my $dbname = 'db';
my $db;

lives_ok { 
    $db = Proteolysis::DB->new(
        dsn => 'bdb:dir=' . $dbname,
    );

} 'Database instantiation';

ok -e $dbname, 'Database created ok';

my $seq   = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $flask = Proteolysis->new(
    protease => 'trypsin',
    protein  => $seq,
);

my $pool = Proteolysis::Pool->new;

$pool->add_substrate(
    Proteolysis::Fragment->new(
        parent_sequence => $seq,        # $flask->protein,
        start           => 1,
        end             => length $seq, # $flask->protein,
    )
);

$flask->add_pool($pool);
$flask->add_pool($pool);

my $id;

{
    $flask->digest;

    my $scope = $db->new_scope;
    my $pool = $flask->pool;
    $id = $db->insert($pool);
    undef $pool;
}

{
    my $scope = $db->new_scope;
    my $pool = $db->lookup($id);

    isa_ok $pool,           'Proteolysis::Pool';
    isa_ok $pool->previous, 'Proteolysis::Pool';
}
