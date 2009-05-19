use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis::Fragment;

use_ok 'Proteolysis';
use_ok 'Proteolysis::Pool';

my $flask = Proteolysis->new;
my $pool  = Proteolysis::Pool->new;

$flask->add_pool($pool);

isa_ok  $flask->pool,       'Proteolysis::Pool';
ok     !$flask->shift_pool;

