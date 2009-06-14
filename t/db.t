use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use KiokuDB::Backend::Hash;
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis;
use Proteolysis::Pool;

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

my $pool = Proteolysis::Pool->new(
    substrate => { $seq => 1 }
);

my $flask = Proteolysis->new(
    protease => 'trypsin',
    pool     => $pool,
);

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
