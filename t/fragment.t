use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);

use ok Proteolysis::Fragment;

my $seq = 'MAAAEELLKRKARPYWGGNGCCVIKPWR';

my $fragment = Proteolysis::Fragment->new(
    parent_sequence => $seq,
    start           => 1,
    end             => length $seq,
);

isa_ok $fragment, 'Proteolysis::Fragment';

is $fragment->start, 1,           'start';
is $fragment->end,   length $seq, 'end';
is $fragment->seq,   $seq,        'seq';
