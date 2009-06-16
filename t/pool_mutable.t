use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;
use Scalar::Util qw(refaddr);

use_ok 'Proteolysis::Pool::Mutable';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $pool = Proteolysis::Pool::Mutable->new;

# Substrates
lives_ok { $pool->add_substrate($seq   ) }        'add_substrate';
lives_ok { $pool->add_substrate($seq, 3) }        'add_substrate';
is         $pool->substrate_count,           4,   'substrate_count';
is         $pool->amount_of_substrate($seq), 4,   'amount_of_substrate';

my $taken = $pool->take_substrate($seq);

is $taken,                           $seq, 'take_substrate';
is $pool->amount_of_substrate($seq),    3, 'take_substrate';

$pool->take_substrate($seq, 2);
is $pool->amount_of_substrate($seq), 1,    'take_substrate';

# Products
lives_ok { $pool->add_product  ($seq   ) }    'add_product';
lives_ok { $pool->add_product  ($seq, 2) }    'add_product';

is         $pool->product_count,           3, 'product_count';
is         $pool->amount_of_product($seq), 3, 'amount_of_product';
is         $pool->count,                   4, 'total count';



my $immutable_clone = $pool->clone_immutable;

isa_ok $immutable_clone, 'Proteolysis::Pool';

is $immutable_clone->substrate_count, $pool->count;
