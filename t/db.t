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
        dsn    => 'dbi:SQLite:dbname=' . $dbname,
        extra_args => { create => 1 },
    );

} 'Database instantiation';

ok -e $dbname, 'Database created ok';

my $seq   = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $pool = Proteolysis::Pool->new(
    substrate => { $seq => 1 }
);

my $flask = Proteolysis->new(
    protease => 'hcl',
    pool     => $pool,
);

$flask->_add_pool($pool);

is $flask->protease->specificity, 'hcl';

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
    my $pool  = $db->lookup($id);

    isa_ok $pool,           'Proteolysis::Pool';
    isa_ok $pool->previous, 'Proteolysis::Pool';
}

use SQL::Abstract;
# Retrieving using queries.
my %queries = (
    pools   => { class    => 'Proteolysis::Pool' },
    hcl     => { protease => 'hcl'               },
);

{
    my $scope = $db->new_scope;
    $db->insert($flask);
}

{
    my $scope   = $db->new_scope;
    my @entries = $db->search($queries{pools})->all;

    is scalar @entries, 1;
    isa_ok $_, 'Proteolysis::Pool' for @entries;

    @entries = $db->search($queries{hcl})->all;

    is scalar @entries, 1;
    isa_ok $_, 'Proteolysis' for @entries;
}

# Cleanup
unlink 'db';
