use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Test::Exception;
use Proteolysis;
use Proteolysis::Pool;
use Devel::SimpleTrace;


{
#    local $TODO = 'Calling dh without a pool dies';
    my $flask = Proteolysis->new;

    lives_ok { $flask->dh } 'Calling dh without a pool lives';
}

{
#    local $TODO = 'Calling dh with an empty pool dies';

    my $flask = Proteolysis->new;
    $flask->add_pool(
        Proteolysis::Pool->new
    );

    lives_ok { $flask->dh; } 'dh with an empty pool lives';
}
