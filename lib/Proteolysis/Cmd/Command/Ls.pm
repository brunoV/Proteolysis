package Proteolysis::Cmd::Command::Ls;
use Moose;
use Modern::Perl;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Proteolysis::Types qw(DB);
use Proteolysis::DB;

extends qw(MooseX::App::Cmd::Command);
with 'MooseX::SimpleConfig';

has db => (
    is  => 'ro',
    isa => DB,
    traits        => [qw(Getopt)],
    cmd_aliases   => 'd',
    documentation => 'Database name to write results to',
    coerce        => 1,
    lazy_build    => 1,
);

coerce DB,
    from 'Str',
    via { return Proteolysis::DB->new( dsn => "bdb:dir=" . $_[0] ) };

sub _build_db {
    my $self = shift;

    my $db = Proteolysis::DB->new( dsn => "bdb:dir=db" );

    return $db;
}

sub run {
    my ( $self, $opt, $args ) = @_;

    my $scope = $self->db->new_scope;

    my $root_set = $self->db->root_set;

    until ( $root_set->is_done ) {
        foreach my $item ( $root_set->items ) {
            my $id = $self->db->object_to_id($item);
            say $id;
        }
    }

}

1;
