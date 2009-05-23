use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::More qw(no_plan);
use Proteolysis;
use Proteolysis::Pool;
use Devel::SimpleTrace;


TODO: {
    local $TODO = 'make DH calculation work please';
    my $flask = Proteolysis->new( protease => 'hcl' );
    $flask->add_pool(
        Proteolysis::Pool->new( substrates => { 'MAEELLKKKV' => 10 } )
    );
    my $dh1 = $flask->dh;
    $flask->digest(1);

    my $other_flask = Proteolysis->new(protease => 'hcl');
    $other_flask->add_pool($flask->pool->previous);
    my $dh2 = $other_flask->dh;

    is $dh2, $dh1, "Consistent dh";

}
