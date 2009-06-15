package Proteolysis::Pool::Plugin::Antihypertensive;
use Moose::Role;
use MooseX::Types::Moose qw(HashRef Num Undef);
use Statistics::Descriptive;
use autodie qw(open);
use Dir::Self;
use YAML::Any;
use namespace::autoclean;

has db => (
    is         => 'ro',
    isa        => HashRef,
    traits     => [qw(KiokuDB::DoNotSerialize)],
    lazy_build => 1,
);

has ace_stats => (
    is         => 'ro',
    lazy_build => 1,
    handles    => {
        mean_ace         => 'mean',
        max_ace          => 'max',
        min_ace          => 'min',
        ace_count        => 'count',
        ace_distribution => 'frequency_distribution',
    }
);

has mean_inverse_ace => (
    is  => 'ro',
    isa => Num|Undef,
    lazy_build => 1,
);

sub _build_db {
    my $self = shift;

    my $dbfile = __DIR__ . '/hipotensive_db';
    open( my $fh, '<', $dbfile );
    my $dumped = join('', <$fh>);
    my $db = Load $dumped;

    return $db;
}

sub _build_ace_stats {
    my $self = shift;

    my $stats = Statistics::Descriptive::Full->new;

    my @data;

    no warnings 'uninitialized';
    while ( my ( $p, $a ) = each %{$self->substrates}) {
        next unless $self->is_hypertensive($p);
        for ( 1 .. $a ) { push @data, $self->ace($p) }
    }

    $stats->add_data(@data);

    return $stats;
}

sub is_hypertensive {
    my ($self, $seq) = @_;

    return exists $self->db->{$seq};
}

sub ace {
    my ( $self, $seq ) = @_;

    if ( $self->is_hypertensive( $seq ) ) {
        return $self->db->{$seq}->[2];
    }
    else { return }
}

sub _build_mean_inverse_ace {
    my $self = shift;

    my $inverse_mean;

    foreach my $data_point ($self->ace_stats->get_data) {
        next unless ($data_point);
        eval { $inverse_mean += 1/$data_point };
    }

    return $inverse_mean;
}

sub inverse_ace {
    my ( $self, $seq, $amount ) = @_;

    return unless ($self->is_hypertensive($seq));
    $self->ace($seq) || return;

    return $amount / ( $self->ace($seq) );

}

1;
