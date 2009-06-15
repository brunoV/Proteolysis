package Proteolysis::Cmd::Command::Rm;
use Moose;
use namespace::autoclean;

extends qw(Proteolysis::Cmd::Base);
with 'Proteolysis::Cmd::DB';

has '+silent' => ( default => 0 );

augment run => sub {
    my ( $self, $opt, $args ) = @_;

    my $db = $self->backend;

    my $scope = $db->new_scope;

    my $root_set = $db->root_set;

    my $deleted = 0;

    until ( $root_set->is_done ) {
        foreach my $item ( $root_set->items ) {
            my $id = $db->object_to_id($item);

            my $matches = grep { $id =~ m/$_/ } @$args;

            if ( $matches ) {
                $self->e("Deleting $id\n");
                $db->delete($id);
                ++$deleted;
            }
        }
    }

    if ( $deleted ) { # Do garbage collection
        eval 'use KiokuDB::GC::Naive';
        eval 'use KiokuDB::Backend::BDB';

        my $gc = KiokuDB::GC::Naive->new(
            backend => KiokuDB::Backend::BDB->new(
                manager => {
                    home => $self->db,
                    create => 0,
                }
            )
        );

        $db->delete( $gc->garbage->members );
    }

    $self->e("Deleted $deleted entries\n");

};

__PACKAGE__->meta->make_immutable;

__END__

=pod

=head1 NAME

Proteolysis::Cmd::Command::Rm - Remove database entries

=head1 DESCRIPTION

=cut
