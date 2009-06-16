use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;

use_ok 'Proteolysis';
use_ok 'Proteolysis::Pool';

my $pool  = Proteolysis::Pool->new;
my $flask = Proteolysis->new( pool => $pool, protease => 'hcl' );

isa_ok  $flask->pool,       'Proteolysis::Pool';
ok     !$flask->_shift_pool;

