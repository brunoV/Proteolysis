use strict;
use warnings;
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis::Fragment;

use_ok 'Proteolysis::Pool';

my $pool = Proteolysis::Pool->new;

isa_ok $pool, 'Proteolysis::Pool';

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $fragment = Proteolysis::Fragment->new(
    parent_sequence => $seq,
    start           => 1,
    end             => length $seq,
);

# Substrates
lives_ok { $pool->add_substrate($fragment) }           'add_substrate';
is         $pool->substrate_count, 1,                  'substrate_count';
isa_ok     $pool->substrates, 'Proteolysis::Fragment', 'substrates';

# Products
lives_ok { $pool->add_product  ($fragment) }           'add_product';
is         $pool->product_count, 1,                    'product_count';
isa_ok     $pool->products, 'Proteolysis::Fragment',   'products';

my $second_pool = Proteolysis::Pool->new;

lives_ok { $second_pool->previous($pool) },             'previous';
isa_ok     $second_pool->previous, 'Proteolysis::Pool', 'previous';

lives_ok { $second_pool->clear_previous },              'clear_previous';
ok         !$second_pool->previous,                     'clear_previous';