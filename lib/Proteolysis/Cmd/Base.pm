package Proteolysis::Cmd::Base;

BEGIN { local $@; eval "use Time::HiRes qw(time)" };

use Moose;
use namespace::autoclean;

extends qw(MooseX::App::Cmd::Command);
with qw(MooseX::SimpleConfig Proteolysis::Cmd::Silent Proteolysis::Cmd::DB);

sub run {
    my ( $self, $opts, $args ) = @_;

    my $t  = -time();
    my $tc = -times;

    inner();

    $t  += time();
    $tc += times;

    $self->e(sprintf "completed in %.2fs (%.2fs cpu)\n", $t, $tc);

}

__PACKAGE__->meta->make_immutable;
__END__

=pod

=head1 NAME

Proteolysis::Cmd::Base - Base class for writing L<Proteolysis> command line tools.

=head1 SYNOPSIS

    package KiokuDB::Cmd::Command::Blort;
    use Moose;

    extends qw(KiokuDB::Cmd::Base);

    augment run => sub {
        ...
    };

=head1 DESCRIPTION

This class provides shared functionality for L<Proteolysis> command line tools.
