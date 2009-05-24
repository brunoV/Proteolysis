use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;

use_ok 'Proteolysis::Pool';

my $pool = Proteolysis::Pool->new;

isa_ok $pool, 'Proteolysis::Pool';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

# Substrates
lives_ok { $pool->add_substrate($seq) }           'add_substrate';
lives_ok { $pool->add_substrate($seq) }           'add_substrate';
is         $pool->substrate_count, 2,             'substrate_count';
is         $pool->amount_of_substrate($seq), 2,   'amount_of_substrate';
#isa_ok     ${$pool->substrates}->{0, 'Proteolysis::Fragment', 'substrates';

my $taken = $pool->take_substrate($seq);
is $taken,                           $seq, 'take_substrate';
is $pool->amount_of_substrate($seq), 1,    'take_substrate';

# Products
lives_ok { $pool->add_product  ($seq) }       'add_product';
is         $pool->product_count, 1,           'product_count';
is         $pool->amount_of_product($seq), 1, 'amount_of_product';

is         $pool->count, 2,                   'total count';

#isa_ok ${$pool->products}[0], 'Proteolysis::Fragment', 'products';

my $second_pool = Proteolysis::Pool->new;

lives_ok { $second_pool->previous($pool) }              'previous';
isa_ok     $second_pool->previous, 'Proteolysis::Pool', 'previous';

is         $second_pool->number,                        '1';

lives_ok { $second_pool->clear_previous }               'clear_previous';
ok         !$second_pool->previous,                     'clear_previous';

