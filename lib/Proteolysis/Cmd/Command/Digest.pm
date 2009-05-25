package Proteolysis::Cmd::Command::Digest;
use Moose;
use Modern::Perl;
use namespace::autoclean;

use MooseX::Types::Moose           qw(Str Num Bool);
use MooseX::Types::Common::Numeric qw(PositiveInt);
use MooseX::Types::Path::Class     qw(File Dir);
use Moose::Util::TypeConstraints;
use File::Basename qw(basename);

use lib qw(/home/brunov/lib/Proteolysis/lib);
use Class::Autouse
    qw(Bio::Protease Proteolysis Proteolysis::DB Proteolysis::Pool
    Bio::SeqIO);

extends qw(MooseX::App::Cmd::Command);
with 'MooseX::SimpleConfig';

has protein => (
    isa => File,
    is  => 'rw',
    coerce        => 1,
    required      => 1,
    traits        => [qw(Getopt)],
    cmd_aliases   => 'i',
    documentation => 'Input sequence (filename or sequence string)',
);

has amount => (
    is  => 'rw',
    isa => PositiveInt,
    default       => 1,
    traits        => [qw(Getopt)],
    cmd_aliases   => 'n',
    documentation => 'Amount of molecules (default 1)',
);

subtype 'Proteolysis::Cmd::Specificity',
    as 'Str',
    where { $_ ~~ Bio::Protease->Specificities };

has protease => (
    isa => 'Proteolysis::Cmd::Specificity',
    is  => 'rw',
    traits        => [qw(Getopt)],
    cmd_aliases   => 'p',
    documentation => 'Protease specificity (default unspecific)',
    default       => 'hcl',
);

subtype 'Percentage',
    as 'Num',
    where { $_[0] > 0 && $_[0] <= 100 },
    message { "% of hydrolysis should be a number between 0 and 100\n" };

has dh => (
    is  => 'rw',
    isa => 'Percentage',
    traits        => [qw(Getopt)],
    cmd_aliases   => 'h',
    documentation => 'Degree of hydrolysis to achieve (default 100)',
    default       => 100,
);

has db => (
    is  => 'rw',
    isa => Str,
    traits        => [qw(Getopt)],
    cmd_aliases   => 'd',
    documentation => 'Database name to write results to',
    default       => 'db',
);

has snapshots => (
    is  => 'rw',
    isa => PositiveInt,
    traits        => [qw(Getopt)],
    cmd_aliases   => 'd',
    documentation => 'Amount of time snapshots to store (defaults to 50)',
    default       => 50,
);

has silent => (
    is  => 'rw',
    isa => Bool,
    default       => 0,
    traits        => [qw(Getopt)],
    cmd_aliases   => 's',
    documentation => "Don't output progress to standard output",
);

sub run {
    my ( $self, $opt, $args ) = @_;

    my $flask = $self->build_flask;

    $self->digest($flask);

    $self->store($flask);

}

sub build_flask {
    my $self = shift;

    my $flask = Proteolysis->new( protease => $self->protease );
    my $pool  = Proteolysis::Pool->new;

    my $seqs  = $self->load_sequences;
    $pool->add_substrate($_, $self->amount) for @$seqs;

    $flask->add_pool($pool);

    my $detail_level = $self->calculate_detail_level($flask);
    $flask->detail_level($detail_level);

    return $flask;
}

sub digest {
    my ( $self, $flask ) = @_;

    my $steps    = 0;
    my $interval = int(1/$flask->detail_level);

    say "Digesting..."            unless $self->silent;
    say "cuts made\t% hydrolysis" unless $self->silent;

    while ( $flask->dh < $self->dh ) {

        $flask->digest($interval) or last;

        $steps += $interval;

        printf("%-9i\t%-10.2f\t%i\n", $steps, $flask->dh, $flask->pool->max_length) unless $self->silent;
    }

    say "Done." unless $self->silent;
}

sub load_sequences {
    my $self = shift;

    my $seqI = Bio::SeqIO->new( -file => "<" . $self->protein )
        or die "Couldn't open file " . $self->protein . ": $!\n";

    my @seqs;
    while ( my $seq = $seqI->next_seq ) { push @seqs, $seq->seq }

    return \@seqs;
}

sub generate_id {
    my $self = shift;

    my ($suffix) = $self->protein =~ /(\.\w+)$/;
    my $basename = basename($self->protein, $suffix);

    # key: basename:amount-protease-dh-snapshots
    my $id = sprintf(
        "%s-n:%s-%s-dh:%s-s:%s",
        $basename,        # input file
        $self->amount,    # molecules
        $self->protease,  # specificity
        $self->dh,        # dh wanted (or should I put achieved?)
        $self->snapshots, # snapshots
    );

    return $id;
}

sub calculate_detail_level {
    my ($self, $flask) = @_;

    my $ss = $self->snapshots;
    my $dh = $self->dh / 100;
    my $h0 = $flask->_h0;

    my $detail_level = $ss / ( $dh * $h0 );

    if ( $detail_level > 1 ) { $detail_level = 1 };

    return $detail_level;
}

sub calculate_steps {
    my ( $self, $flask ) = @_;

    my $dh = $self->dh / 100;
    my $h0 = $flask->_h0;

    my $steps = int($dh * $h0);

    return $steps;
}

sub store  {

    my ($self, $flask) = @_;

    say "Storing..." unless $self->silent;

    my $db = Proteolysis::DB->new( dsn => "bdb:dir=" . $self->db );
    my $s  = $db->new_scope;

    my $tries  = 0;
    my $id     = $self->generate_id;
    my $exists = 1;

    while ($exists) {
        $exists = $db->lookup( $id . '-' . ++$tries );
    }

    my $actual_id;

    my $e = do {
        local $@;

        $actual_id = eval { $db->store( $id . '-' . $tries => $flask ) };

        $@;
    };

    return "storage failed: $e" if $e;

    say "id: ", $actual_id unless $self->silent;
    say "Done."            unless $self->silent;

};

__PACKAGE__->meta->make_immutable;
