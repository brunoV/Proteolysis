package Proteolysis::Cmd::Command::Ls;
use Moose;
use namespace::autoclean;

extends qw(Proteolysis::Cmd::Base);

has '+silent' => ( default => 0 );

augment run => sub {
    my ( $self, $opt, $args ) = @_;

    my $db = $self->backend;

    my $scope = $db->new_scope;

    my $root_set = $db->root_set;

    until ( $root_set->is_done ) {
        foreach my $item ( $root_set->items ) {
            my $id = $db->object_to_id($item);
            $self->s($id);
        }
    }

};

__PACKAGE__->meta->make_immutable;

__END__

=pod

=head1 NAME

Proteolysis::Cmd::Command::Ls - List currently stored reaction flasks

=cut
