use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis;
use Proteolysis::Pool;
use Proteolysis::Fragment;

use ok 'Proteolysis::DB';

unlink 'db';

my $db;
lives_ok { $db = Proteolysis::DB->new } 'Database instantiation';

ok -e 'db',                             'Database created ok';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $flask = Proteolysis->new(
    protease => 'trypsin',
    protein  => $seq,
);

my $pool = Proteolysis::Pool->new;

$pool->add_substrate(
    Proteolysis::Fragment->new(
        parent_sequence => $flask->protein,
        start           => 1,
        end             => length $flask->protein,
    )
);

$flask->add_pool($pool);

my $id;

{
    $flask->digest;

    my $scope = $db->new_scope;
    $id = $db->insert($flask);
    undef $flask;
}

{
    my $scope = $db->new_scope;
    my $flask = $db->lookup($id);

    isa_ok $flask, 'Proteolysis';
}

