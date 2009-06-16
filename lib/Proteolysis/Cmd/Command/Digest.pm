package Proteolysis::Cmd::Command::Digest;
use Moose;
use Modern::Perl;
use namespace::autoclean;

use lib qw(/home/brunov/lib/Proteolysis/lib);
use MooseX::Types::Common::Numeric qw(PositiveInt );
use MooseX::Types::Path::Class     qw(File        );
use Proteolysis::Types             qw(Percentage  );

use File::Basename qw(basename);
use Class::Autouse qw(Proteolysis Proteolysis::Pool Bio::SeqIO);

extends qw(Proteolysis::Cmd::Base);
with qw(MooseX::SimpleConfig Proteolysis::Cmd::Protease KiokuDB::Role::UUIDs);

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

has dh => (
    is  => 'rw',
    isa => Percentage,
    traits        => [qw(Getopt)],
    cmd_aliases   => 'h',
    documentation => 'Degree of hydrolysis to achieve (default 100)',
    default       => 100,
);

has snapshots => (
    is  => 'rw',
    isa => PositiveInt,
    traits        => [qw(Getopt)],
    cmd_aliases   => 'd',
    documentation => 'Amount of time snapshots to store (default 50)',
    default       => 50,
);

has '+silent' => ( default => 0 );

augment run => sub {
    my ( $self, $opt, $args ) = @_;

    my $flask = $self->build_flask;

    $self->e("Digesting...\n");
    $self->digest($flask);

    unless ( $self->dry_run ) {
        $self->e("Storing...\n");
        $self->store($flask);
    }

};

sub build_flask {
    my $self = shift;

    my $seqs       = $self->load_sequences;
    my %substrates = map { $_, $self->amount } @$seqs;

    my $pool = Proteolysis::Pool->new(
        substrates => \%substrates,
    );

    my $flask = Proteolysis->new(
        protease => $self->protease,
        pool     => $pool,
    );

    $flask->protease->name( $self->protease );

    my $detail_level = $self->calculate_detail_level($flask);
    $flask->detail_level($detail_level);

    return $flask;
}

sub digest {
    my ( $self, $flask ) = @_;

    my $steps    = 0;
    my $interval = int(1/$flask->detail_level);

    $self->s("cuts made\t% hydrolysis");

    while ( $flask->dh < $self->dh ) {

        $flask->digest($interval) or last;

        $steps += $interval;

        $self->p(sprintf "%-9i\t%-10.2f\n", $steps, $flask->dh);
    }
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
        "%s-n:%i-%s-dh:%d-s:%i-",
        $basename,        # input file
        $self->amount,    # molecules
        $self->protease,  # specificity
        $self->dh,        # dh wanted (or should I put achieved?)
        $self->snapshots, # snapshots
    );

    my $uuid = generate_uuid();

    $id .= $uuid;

    return $id;
}

sub calculate_detail_level {
    my ($self, $flask) = @_;

    my $ss = $self->snapshots;
    my $dh = $self->dh / 100;
    my $h0 = $flask->pool->_h0;

    my $detail_level = $ss / ( $dh * $h0 );

    if ( $detail_level > 1 ) { $detail_level = 1 };

    return $detail_level;
}

sub store  {

    my ($self, $flask) = @_;

    unless ( -e $self->db ) {
        $self->e("Database ", $self->db, " not found. Creating it.\n");
        $self->create(1);
    };

    my $s  = $self->backend->new_scope;
    my $id = $self->generate_id;

    my $e = do {
        local $@;
        eval { $self->backend->store( $id => $flask ) };
        $@;
    };

    if ( $e ) { $self->e("storage failed: $e"); return }

    $self->s('id: ', $id);

}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=head1 NAME

Proteolysis::Cmd::Command::Digest - Digest a pool of proteins with an arbitrary protease

=cut
