package Proteolysis::Cmd::Silent;
use Moose::Role;
use MooseX::Getopt;
use namespace::autoclean;

use MooseX::Types::Moose qw(Bool);

has silent => (
    is  => 'ro',
    isa => Bool,
    traits        => [qw(Getopt)],
    cmd_aliases   => 's',
    documentation => "Don't output progress to standard output",
);

sub BUILD {
    my $self = shift;

    unless ($self->silent) {
        STDERR->autoflush(1);
        STDOUT->autoflush(1);
    }
}

sub e {
    my $self = shift;
    return if $self->silent;

    STDERR->print(@_);
}

sub p {
    my $self = shift;
    return if $self->silent;

    STDOUT->print(@_);
}

sub s {
    my $self = shift;
    return if $self->silent;

    STDOUT->say(@_);
}

1;
__END__

=pod

=head1 NAME

Proteolysis::Cmd::Silent - A role for command line tools that have a
C<--silent> option.

=head1 SYNOPSIS

    # These messages will only be printed if --silent is set to false.
    $self->p("blah blah\n");    # printed to STDOUT
    $self->s("blah blah");      # printed to STDOUT, appended newline.
    $self->pf("%.3f", $result); # printf  to STDOUT
    $self->e("Couldn't log");   # printed to STDERR

=head1 DESCRIPTION

This role provides the C<silent> attribute and command line option, and
a C<p>, C<pf>, C<s> and C<pf> methods that you can use to emit verbose
output to C<STDOUT> or C<STDERR>.
