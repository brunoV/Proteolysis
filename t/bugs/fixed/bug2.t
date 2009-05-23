use strict;
use warnings;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Test::Exception qw(no_plan);
use Proteolysis;
use Devel::SimpleTrace;

my $flask = Proteolysis->new( protease => 'trypsin' );

{
#    local $TODO = 'trying to digest without pools dies';

#    eval " lives_ok { $flask->digest } ";

#    todo_skip "shit dies and it shouldn't", 1 if $@;

    lives_ok { $flask->digest; };
}
