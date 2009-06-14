use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;

use_ok 'Proteolysis::PoolI';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $pool = Proteolysis::PoolI->new(
    substrates => { $seq => 2 }
);

isa_ok $pool, 'Proteolysis::PoolI';

# Substrates
is         $pool->_substrate_count,           2,   'substrate_count';
