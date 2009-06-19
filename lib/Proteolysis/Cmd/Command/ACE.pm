package Proteolysis::Cmd::Command::ACE;
use Moose;
use namespace::autoclean;

extends qw(Proteolysis::Cmd::Base);

has '+silent' => ( default => 0 );

augment run => sub {
    my ( $self, $opt, $args ) = @_;

    my $s = $self->backend->new_scope;

    $args->[0] //= '.*'; # If no id is specified, match everything

    my @regexes;

    # Try and load entries supposing the arguments are exact ids
    foreach my $arg (@$args) {
        my $entry = $self->backend->lookup($arg);

        if ( defined $entry ) {
            $self->analyze($entry);
        }

        else { push @regexes, $arg; }
    }

    # If any lookup failed, suppose the arg was a regex, and scan the
    # root set looking for matches.
    return unless @regexes;

    my $root_set = $self->backend->root_set;

    until ( $root_set->is_done ) {
        foreach my $entry ( $root_set->items ) {
            my $id = $self->backend->object_to_id($entry);

            $self->analyze($entry)
                if id_matches_any_regexes($id, \@regexes);
        }
    }

};

sub analyze {
    my ($self, $entry) = @_;

    $self->p( "#", $self->backend->object_to_id($entry), "\n" );
    $self->p("# % dh\tinverse_ace\tamount_ace\tmean_length\tamount\tprotease\n");

    my $pool = $entry->pool;
    my $updated;

    do {
        $pool->load_plugin("Antihypertensive");

        ($updated) = $pool->has_mean_inverse_ace ? (0) : (1);

        my $dh        = $pool->dh;
        my $ace       = $pool->mean_inverse_ace // 0;
        my $ace_count = $pool->ace_count        // 0;
        my $l         = $pool->mean_length;
        my $n         = $pool->substrate_count;
        my $protease  = $entry->protease->specificity;

        $self->p(sprintf "%-6.1f\t%-11.5f\t%-10i\t%-9.2f\t%-6i\t%s\n", $dh, $ace, $ace_count, $l, $n, $protease);

        $pool = $pool->previous;

    } while ( defined $pool );

    if ( $updated and !$self->dry_run ) {
        $self->e("Storing...\n");
        $self->backend->store($entry);
    }

    return 1;
}


sub id_matches_any_regexes {
    my ( $id, $regexes ) = @_;

    my $matches = 0;

    $matches = grep { $id =~ m/$_/ } @$regexes;

    return $matches;
}

__END__

=pod

=head1 NAME

Proteolysis::Cmd::Command::ACE - Analyze presence of antihypertensive peptides

=head1 DESCRIPTION

=cut
