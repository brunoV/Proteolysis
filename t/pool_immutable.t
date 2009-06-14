use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;
use Scalar::Util qw(refaddr);

use_ok 'Proteolysis::Pool';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $pool = Proteolysis::Pool->new(
    substrates => { $seq => 2 },
);

my $clone;
lives_ok { $clone = $pool->clone_mutable } "clone_mutable";

# Check that substrates is an actual copy
ok refaddr($clone->substrates) != refaddr($pool->substrates), "clone_mutable";

$clone->add_substrate($seq);
