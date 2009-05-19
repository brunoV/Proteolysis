use MooseX::Declare;

role Proteolysis::Stats::Antihypertensive {
    use MooseX::Types::Moose qw(HashRef Str);
    use Statistics::Descriptive;
    use autodie qw(open);
    use Dir::Self;
    use YAML::Any;

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

    method _build_db {
        my $dbfile = __DIR__ . '/hipotensive_db';
        open( my $fh, '<', $dbfile );
        my $dumped = join('', <$fh>);
        my $db = Load $dumped;

        return $db;
    }

    method _build_ace_stats {
        my $stats = Statistics::Descriptive::Full->new;

        $stats->add_data(
            map  { $self->ace( $_->seq )             }
            grep { $self->is_hypertensive( $_->seq ) }
            ( $self->substrates, $self->products )
        );

        return $stats;
    }

    method is_hypertensive ( Str $seq ) {
        return exists $self->db->{$seq};
    }

    method ace ( Str $seq ) {
        if ( $self->is_hypertensive( $seq ) ) {
            return $self->db->{$seq}->[2];
        }
        else { return }
    }

}
