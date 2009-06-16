use Test::More tests => 13;
use App::Cmd::Tester;

use lib qw(/home/brunov/lib/Proteolysis/lib);
use Proteolysis::Cmd;
use File::Path qw(rmtree);

my $test_file = 't/test.fasta';

#my $result = test_app(Proteolysis::Cmd => [ qw(command --opt value) ]);

# Digest -- dry run
my $result = test_app(Proteolysis::Cmd => [ qw(digest -h 5 --dry-run -i), $test_file ]);

like   $result->stderr, qr/completed in/;
unlike $result->stderr, qr/storing/i;

like $result->stdout, qr/cuts made/;

# Digest -- save to new database
$result = test_app(Proteolysis::Cmd => [ qw(digest -h 5 --db testdb -i), $test_file ]);

like $result->stderr, qr/completed in/;
like $result->stderr, qr/database testdb not found/i;
like $result->stderr, qr/storing/i;

like $result->stdout, qr/cuts made/;

# Digest -- save to existent database
$result = test_app(Proteolysis::Cmd => [ qw(digest -h 5 --db testdb -i), $test_file ]);

like   $result->stderr, qr/completed in/;
unlike $result->stderr, qr/database not found/i;
like   $result->stderr, qr/storing/i;

like $result->stdout, qr/cuts made/;

# Digest -- silent 
$result = test_app(Proteolysis::Cmd => [ qw(digest -h 5 --dry-run --silent -i), $test_file ]);

is $result->output, '';

# Cleanup
unlink('testdb');

ok 1;
