package Proteolysis::Pool::Plugin::Antihypertensive;
use Moose::Role;
use MooseX::Types::Moose qw(HashRef Str);
use Statistics::Descriptive;
use autodie qw(open);
use Dir::Self;
use YAML::Any;
use namespace::clean -except => 'meta';

has db => (
    is         => 'ro',
    isa        => HashRef,
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

    while ( my ( $p, $a ) = each %{$self->products}) {
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

1;
